function pyenvc -d "Create new python environment using pyenv"
    # Parse arguments
    set -l version ""
    set -l env_name ""
    set -l i 1
    
    while test $i -le (count $argv)
        switch $argv[$i]
            case --version -v
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set version $argv[$i]
                else
                    echo "Error: --version requires a value"
                    return 1
                end
            case -*
                echo "Error: Unknown option $argv[$i]"
                return 1
            case '*'
                if test -z "$env_name"
                    set env_name $argv[$i]
                else
                    echo "Error: Multiple environment names specified"
                    return 1
                end
        end
        set i (math $i + 1)
    end
    
    # Check if environment name was provided
    if test -z "$env_name"
        echo "Error: Environment name is required"
        echo "Usage: pyenvc [--version VERSION] ENV_NAME"
        return 1
    end
    
    # Create the virtual environment
    if test -n "$version"
        echo "Creating Python $version environment: $env_name"
        pyenv virtualenv $version $env_name
    else
        echo "Creating Python environment: $env_name (using default Python version)"
        pyenv virtualenv $env_name
    end
end

function pyenvl -d "Load python environment using pyenv"
    ls $HOME/.pyenv/versions/*/bin/activate | \
        cut -d'/' -f6 | \
        fzf --height 10% --layout=reverse --border | \
        read -l result; and source "$HOME/.pyenv/versions/$result/bin/activate.fish"
end

# function tmk -d "Kill tmux session"
#     tmux list-sessions -F "#{session_name}" | fzf --height 10% --layout=reverse --border | read -l result; and tmux kill-session -t "$result"
# end
