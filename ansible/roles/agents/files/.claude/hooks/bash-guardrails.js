#!/usr/bin/env node
// Ported from omp's agent/hooks/pre/bash-guardrails.ts.
// Forces a permission prompt (even when Bash is allowlisted) for:
// dangerous commands, git state changes, and IaC write operations.

const READ_ONLY_GIT_COMMANDS = {
  annotate: true, blame: true, "cat-file": true, "check-attr": true,
  "check-ignore": true, "check-mailmap": true, "count-objects": true,
  describe: true, diff: true, difftool: true, fsck: true, grep: true,
  help: true, log: true, "ls-files": true, "ls-remote": true, "ls-tree": true,
  "merge-base": true, "name-rev": true, "rev-list": true, "rev-parse": true,
  shortlog: true, show: true, "show-branch": true, status: true,
  "symbolic-ref": true, "verify-commit": true, "verify-pack": true,
  "verify-tag": true, version: true, whatchanged: true,
};

const GIT_GLOBAL_OPTIONS_WITH_VALUE = {
  "-C": true, "-c": true, "--config-env": true, "--exec-path": true,
  "--git-dir": true, "--namespace": true, "--super-prefix": true, "--work-tree": true,
};

const PRIVILEGE_WRAPPERS = { chroot: true, doas: true, pkexec: true, sudo: true };
const PARTITIONING_COMMANDS = { cfdisk: true, fdisk: true, parted: true, sfdisk: true, sgdisk: true };
const DESTRUCTIVE_DISK_COMMANDS = { blkdiscard: true, shred: true, wipefs: true };
const INLINE_INTERPRETERS = { node: true, perl: true, php: true, python: true, python2: true, python3: true, ruby: true };
const IAC_WRITE_ACTIONS = { apply: true, destroy: true, "force-unlock": true, import: true, taint: true, untaint: true, up: true };

function commandBasename(value) {
  const parts = value.split("/");
  return (parts[parts.length - 1] ?? "").toLowerCase();
}

function splitShellFragments(command) {
  const fragments = [];
  let quote, escaped = false, start = 0;
  for (let index = 0; index < command.length; index += 1) {
    const character = command[index];
    if (escaped) { escaped = false; continue; }
    if (character === "\\" && quote !== "'") { escaped = true; continue; }
    if (quote) { if (character === quote) quote = undefined; continue; }
    if (character === "'" || character === '"') { quote = character; continue; }
    if (character === ";" || character === "\n" || character === "|" || character === "&") {
      const fragment = command.slice(start, index).trim();
      if (fragment) fragments.push(fragment);
      if ((character === "|" || character === "&") && command[index + 1] === character) index += 1;
      start = index + 1;
    }
  }
  const fragment = command.slice(start).trim();
  if (fragment) fragments.push(fragment);
  return fragments;
}

function shellWords(source) {
  const words = [];
  let current = "", quote, escaped = false;
  const push = () => { if (current) { words.push(current); current = ""; } };
  for (const character of source) {
    if (escaped) { current += character; escaped = false; continue; }
    if (character === "\\" && quote !== "'") { escaped = true; continue; }
    if (quote) { if (character === quote) quote = undefined; else current += character; continue; }
    if (character === "'" || character === '"') { quote = character; continue; }
    if (/\s/.test(character)) { push(); continue; }
    current += character;
  }
  push();
  return words;
}

function isShellAssignment(word) { return /^[A-Za-z_][A-Za-z0-9_]*=/.test(word); }

function unwrapDangerousCommand(input) {
  let index = 0;
  while (isShellAssignment(input[index] ?? "")) index += 1;
  for (let count = 0; count < 4 && index < input.length; count += 1) {
    const name = commandBasename(input[index] ?? "");
    if (name === "env") {
      index += 1;
      while ((input[index]?.startsWith("-") ?? false) || isShellAssignment(input[index] ?? "")) index += 1;
      continue;
    }
    if (name === "command" || name === "builtin" || name === "nohup") {
      index += 1;
      while (input[index]?.startsWith("-")) index += 1;
      continue;
    }
    break;
  }
  return input.slice(index);
}

function hasShortOption(words, flag) {
  return words.slice(1).some((word) => /^-[^-]+$/.test(word) && word.slice(1).toLowerCase().includes(flag.toLowerCase()));
}

function hasLongOption(words, option) {
  return words.slice(1).some((word) => word === option || word.startsWith(`${option}=`));
}

function optionValue(words, index, option) {
  const word = words[index];
  if (word === option) return words[index + 1];
  return word.startsWith(`${option}=`) ? word.slice(option.length + 1) : undefined;
}

function recursiveWorldWritable(words) {
  const recursive = hasShortOption(words, "R") || hasLongOption(words, "--recursive");
  const worldWritable = words.some((word) => /^0?[0-7]*[2367]$/.test(word) || /(?:^|,)(?:a|o|go|ugo)(?:[+=][^,]*w)/.test(word));
  return recursive && worldWritable;
}

function dangerousContainer(words) {
  const name = commandBasename(words[0] ?? "");
  if (name !== "docker" && name !== "podman") return;
  const subcommandIndex = words.findIndex((word) => word === "run" || word === "create");
  if (subcommandIndex < 0) return;
  const args = words.slice(subcommandIndex + 1);
  const normalized = args.map((arg) => arg.toLowerCase());
  if (normalized.includes("--privileged") || normalized.includes("--privileged=true")) return "container privileged mode";
  const hostModes = { "--cap-add": "all", "--ipc": "host", "--net": "host", "--network": "host", "--pid": "host", "--userns": "host", "--uts": "host" };
  for (let index = 0; index < args.length; index += 1) {
    for (const [option, expected] of Object.entries(hostModes)) {
      if (optionValue(args, index, option)?.toLowerCase() === expected) return `container ${option} ${expected}`;
    }
  }
  if (args.some((arg) => arg === "--device" || arg.startsWith("--device="))) return "container host device mapping";
  for (let index = 0; index < args.length; index += 1) {
    for (const option of ["-v", "--volume"]) {
      const value = optionValue(args, index, option);
      if (value?.startsWith("/:")) return "container host-root mount";
    }
    const mount = optionValue(args, index, "--mount");
    if (mount?.split(",").some((part) => part === "source=/" || part === "src=/")) return "container host-root mount";
  }
}

function inlineInterpreterCode(name, words) {
  if (!INLINE_INTERPRETERS[name]) return false;
  const args = words.slice(1);
  if (name.startsWith("python")) return args.some((word) => /^-[^-]*c/.test(word) || word === "--command");
  if (name === "node") return args.some((word) => /^-(?:e|p)/.test(word) || word === "--eval" || word.startsWith("--eval=") || word === "--print" || word.startsWith("--print="));
  if (name === "ruby" || name === "perl") return args.some((word) => /^-[^-]*[eE]/.test(word));
  return args.some((word) => /^-[^-]*[rBRFE]/.test(word) || word === "--run" || word.startsWith("--run="));
}

function dangerousCommand(wordsInput) {
  const words = unwrapDangerousCommand(wordsInput);
  const name = commandBasename(words[0] ?? "");
  if (!name) return;
  if (PRIVILEGE_WRAPPERS[name]) return "privileged command execution";
  if (name === "eval") return "dynamic shell evaluation";
  if (inlineInterpreterCode(name, words)) return "inline interpreter code";
  if (name === "rm" && (hasShortOption(words, "r") || hasLongOption(words, "--recursive")) && (hasShortOption(words, "f") || hasLongOption(words, "--force"))) return "recursive force delete";
  if (name === "dd" && words.some((word) => /^of=/.test(word))) return "disk write operation";
  if (name === "mkfs" || name.startsWith("mkfs.")) return "filesystem format";
  if (DESTRUCTIVE_DISK_COMMANDS[name]) return "destructive disk or file operation";
  if (PARTITIONING_COMMANDS[name]) return "disk partitioning";
  if (name === "chmod" && recursiveWorldWritable(words)) return "recursive world-writable permissions";
  if ((name === "chown" || name === "chgrp") && (hasShortOption(words, "R") || hasLongOption(words, "--recursive"))) return "recursive ownership change";
  return dangerousContainer(words);
}

function nestedShellSource(words) {
  const name = commandBasename(words[0] ?? "");
  if (!{ bash: true, dash: true, ksh: true, sh: true, zsh: true }[name]) return;
  const codeOption = words.slice(1).findIndex((word) => /^-[^-]*c/.test(word) || word === "--command");
  if (codeOption < 0) return;
  return words.slice(codeOption + 2).join(" ");
}

function piBuiltinDanger(command, depth = 0) {
  if (depth >= 3) return;
  for (const fragment of splitShellFragments(command)) {
    const words = shellWords(fragment);
    const direct = dangerousCommand(words);
    if (direct) return direct;
    const nested = nestedShellSource(unwrapDangerousCommand(words));
    if (nested) {
      const match = piBuiltinDanger(nested, depth + 1);
      if (match) return match;
    }
  }
  for (const match of command.matchAll(/\$\(([^()]*)\)/g)) {
    const nested = piBuiltinDanger(match[1], depth + 1);
    if (nested) return nested;
  }
}

function gitSubcommand(wordsInput) {
  const words = unwrapDangerousCommand(wordsInput);
  if (commandBasename(words[0] ?? "") !== "git") return;
  let index = 1;
  while (index < words.length) {
    const word = words[index];
    if (word === "--") return words[index + 1];
    if (GIT_GLOBAL_OPTIONS_WITH_VALUE[word]) { index += 2; continue; }
    if (word.startsWith("-")) { index += 1; continue; }
    return word;
  }
}

function changesGitState(command) {
  return splitShellFragments(command).some((fragment) => {
    const subcommand = gitSubcommand(shellWords(fragment));
    return subcommand !== undefined && !READ_ONLY_GIT_COMMANDS[subcommand];
  });
}

function firstAction(words) { return words.slice(1).find((word) => !word.startsWith("-")); }

function writesIacState(command) {
  return splitShellFragments(command).some((fragment) => {
    const words = unwrapDangerousCommand(shellWords(fragment));
    const name = commandBasename(words[0] ?? "");
    const action = firstAction(words);

    if (name === "terraform" || name === "tofu" || name === "terragrunt") {
      if (IAC_WRITE_ACTIONS[action ?? ""]) return true;
      if (action === "state") return !{ list: true, pull: true, show: true }[firstAction(words.slice(1)) ?? ""];
      if (action === "workspace") return !{ list: true, show: true }[firstAction(words.slice(1)) ?? ""];
      return false;
    }
    if (name === "pulumi") {
      if (IAC_WRITE_ACTIONS[action ?? ""] || action === "refresh" || action === "cancel") return true;
      if (action === "config") return ["rm", "remove", "set", "set-all"].includes(firstAction(words.slice(1)) ?? "");
      if (action === "stack") return ["init", "rm", "remove", "select"].includes(firstAction(words.slice(1)) ?? "");
      return false;
    }
    if (name === "cdk") return action === "deploy" || action === "destroy";
    if (name === "ansible-playbook") return true;
    if (name === "helm") return ["install", "rollback", "uninstall", "upgrade"].includes(action ?? "");
    if (name === "aws" && words[1] === "cloudformation") return ["create-stack", "delete-stack", "deploy", "update-stack"].includes(words[2] ?? "");
    if (name === "gcloud" && words[1] === "infra-manager" && words[2] === "deployments") return ["apply", "delete"].includes(words[3] ?? "");
    if (name === "gcloud" && words[1] === "deployment-manager" && words[2] === "deployments") return ["create", "delete", "update"].includes(words[3] ?? "");
    return false;
  });
}

function reasonsForApproval(command) {
  const reasons = [];
  const piDanger = piBuiltinDanger(command);
  if (piDanger) reasons.push(piDanger);
  if (changesGitState(command)) reasons.push("Git state change");
  if (writesIacState(command)) reasons.push("IaC write operation");
  return reasons;
}

let raw = "";
process.stdin.on("data", (chunk) => { raw += chunk; });
process.stdin.on("end", () => {
  let payload;
  try { payload = JSON.parse(raw || "{}"); } catch { payload = {}; }
  const command = String(payload.tool_input?.command ?? "");
  const reasons = reasonsForApproval(command);
  if (reasons.length === 0) process.exit(0);

  process.stdout.write(JSON.stringify({
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: `Guarded: ${reasons.join(", ")}`,
    },
  }));
  process.exit(0);
});
