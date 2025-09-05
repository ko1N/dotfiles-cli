function cd
    if command -q zoxide
        z $argv
    else
        builtin cd $argv
    end
end

function find
    if command -q fd
        fd $argv
    else
        command find $argv
    end
end

function cat
    if command -q bat
        bat --style=plain $argv
    else
        command cat $argv
    end
end

function vi
    if command -q nvim
        nvim $argv
    else
        command vi $argv
    end
end

function vim
    if command -q nvim
        nvim $argv
    else
        command vim $argv
    end
end

function ranger
    if command -q yazi
        yazi $argv
    else
        command ranger $argv
    end
end

function files
    if command -q yazi
        yazi $argv
    else
        echo "yazi not found, and no fallback for 'files' command"
        return 1
    end
end
