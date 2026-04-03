function gwt
    set -l dir (command gwt $argv)
    and test -d "$dir"; and cd "$dir"; or echo "$dir"
end
