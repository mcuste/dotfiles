function gt
    set -l config_home $XDG_CONFIG_HOME
    if not set -q XDG_CONFIG_HOME
        set config_home $HOME/.config
    end
    set -l script "$config_home/graphite-worktrees/gt-worktree.sh"
    if not test -f "$script"
        command gt $argv
        return $status
    end

    set -l result_file (mktemp)
    or return 1
    env GT_WORKTREE_RESULT_FILE="$result_file" bash "$script" $argv
    set -l exit_status $status
    if test -s "$result_file"
        set -l result_path (cat "$result_file")
        if test -d "$result_path"
            cd "$result_path"
        end
    end
    rm -f "$result_file"
    return $exit_status
end
