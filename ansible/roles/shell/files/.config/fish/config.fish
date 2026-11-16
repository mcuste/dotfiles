source "$HOME/.config/shell/common.fish"
status is-interactive; or return

set -g fish_greeting
fish_config theme choose CatppuccinMocha

if type -q starship
    starship init fish | source
end
if type -q fzf
    fzf --fish | source
end
if type -q zoxide
    zoxide init fish | source
end

# Worktrees share the repository's Cargo build output.
function _update_cargo_target_dir --on-variable PWD
    if set -l common_dir (command git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
        set -gx CARGO_TARGET_DIR "$common_dir/cargo-target"
    else
        set -e CARGO_TARGET_DIR
    end
end

_update_cargo_target_dir
