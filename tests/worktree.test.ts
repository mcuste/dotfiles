import { describe, expect, it } from "bun:test";

import worktree from "../stow/.omp/agent/tools/worktree";

type Command = {
  args: string[];
  command: string;
  cwd: string;
};

type Result = {
  code: number;
  killed: boolean;
  stderr: string;
  stdout: string;
};

const schema = {
  optional() {
    return schema;
  },
};

const zod = {
  array() {
    return schema;
  },
  boolean() {
    return schema;
  },
  enum() {
    return schema;
  },
  object() {
    return schema;
  },
  string() {
    return schema;
  },
};

function commandResult(stdout = "", code = 0, stderr = ""): Result {
  return { code, killed: false, stderr, stdout };
}

function fixture(results: Result[]) {
  const commands: Command[] = [];
  const tool = worktree({
    cwd: "/repo",
    exec: async (command, args, { cwd }) => {
      commands.push({ args, command, cwd });
      const result = results.shift();
      if (!result) {
        throw new Error(`Unexpected command: ${command} ${args.join(" ")}`);
      }
      return result;
    },
    zod,
  });

  return { commands, tool };
}

const createdWorktree = JSON.stringify({
  result: {
    workspace: { workspace_id: "w-child" },
    worktree: { path: "/worktrees/child" },
  },
});

describe("Graphite worktrees", () => {
  it("tracks a normal worktree create on the current Graphite branch", async () => {
    const { commands, tool } = fixture([
      commandResult("true\n"),
      commandResult("feature-parent\n"),
      commandResult("main\n"),
      commandResult(createdWorktree),
      commandResult(),
    ]);

    const result = await tool.execute("id", { action: "create", branch: "feature-child" });

    expect(commands).toEqual([
      { args: ["rev-parse", "--is-inside-work-tree"], command: "git", cwd: "/repo" },
      { args: ["branch", "--show-current"], command: "git", cwd: "/repo" },
      { args: ["trunk", "--no-interactive"], command: "gt", cwd: "/repo" },
      {
        args: [
          "worktree",
          "create",
          "--cwd",
          "/repo",
          "--branch",
          "feature-child",
          "--no-focus",
          "--base",
          "feature-parent",
        ],
        command: "herdr",
        cwd: "/repo",
      },
      {
        args: ["track", "feature-child", "--parent", "feature-parent", "--no-interactive"],
        command: "gt",
        cwd: "/worktrees/child",
      },
    ]);
    expect(JSON.parse(result.content[0].text)).toMatchObject({
      graphite: { parent: "feature-parent", tracked: true, trunk: "main" },
    });
  });

  it("leaves non-Graphite worktree creation unchanged", async () => {
    const { commands, tool } = fixture([
      commandResult("true\n"),
      commandResult("main\n"),
      commandResult("", 127, "gt: command not found"),
      commandResult(createdWorktree),
    ]);

    await tool.execute("id", { action: "create", branch: "feature-child" });

    expect(commands).toEqual([
      { args: ["rev-parse", "--is-inside-work-tree"], command: "git", cwd: "/repo" },
      { args: ["branch", "--show-current"], command: "git", cwd: "/repo" },
      { args: ["trunk", "--no-interactive"], command: "gt", cwd: "/repo" },
      {
        args: ["worktree", "create", "--cwd", "/repo", "--branch", "feature-child", "--no-focus"],
        command: "herdr",
        cwd: "/repo",
      },
    ]);
  });

  it("removes the managed worktree before deleting its Graphite branch", async () => {
    const { commands, tool } = fixture([
      commandResult("true\n"),
      commandResult("main\n"),
      commandResult("main\n"),
      commandResult(
        JSON.stringify({
          result: {
            source: { source_checkout_path: "/repo" },
            worktrees: [
              { branch: "main", open_workspace_id: "w-main", path: "/repo" },
              { branch: "feature-child", open_workspace_id: "w-child", path: "/worktrees/child" },
            ],
          },
        }),
      ),
      commandResult(),
      commandResult(),
    ]);

    await tool.execute("id", { action: "graphite_delete", branch: "feature-child" });

    expect(commands).toEqual([
      { args: ["rev-parse", "--is-inside-work-tree"], command: "git", cwd: "/repo" },
      { args: ["branch", "--show-current"], command: "git", cwd: "/repo" },
      { args: ["trunk", "--no-interactive"], command: "gt", cwd: "/repo" },
      { args: ["worktree", "list", "--cwd", "/repo"], command: "herdr", cwd: "/repo" },
      { args: ["worktree", "remove", "--workspace", "w-child"], command: "herdr", cwd: "/repo" },
      { args: ["delete", "feature-child", "--no-interactive"], command: "gt", cwd: "/repo" },
    ]);
  });

  it("restores a removed worktree when Graphite refuses deletion", async () => {
    const { commands, tool } = fixture([
      commandResult("true\n"),
      commandResult("main\n"),
      commandResult("main\n"),
      commandResult(
        JSON.stringify({
          result: {
            source: { source_checkout_path: "/repo" },
            worktrees: [{ branch: "feature-child", open_workspace_id: "w-child", path: "/worktrees/child" }],
          },
        }),
      ),
      commandResult(),
      commandResult("", 1, "branch is not merged"),
      commandResult(),
      commandResult(),
    ]);

    await expect(
      tool.execute("id", { action: "graphite_delete", branch: "feature-child" }),
    ).rejects.toThrow("branch is not merged");
    expect(commands.slice(-2)).toEqual([
      { args: ["worktree", "add", "/worktrees/child", "feature-child"], command: "git", cwd: "/repo" },
      {
        args: ["worktree", "open", "--cwd", "/repo", "--path", "/worktrees/child"],
        command: "herdr",
        cwd: "/repo",
      },
    ]);
  });
});
