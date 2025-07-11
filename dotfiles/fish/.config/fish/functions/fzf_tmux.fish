function tmc -d "Create or attach to current folders session"
    # Get the current directory path relative to home, or absolute if outside home
    set current_path (pwd)
    set home_path $HOME
    
    if string match -q "$home_path/*" $current_path
        # Inside home directory - use relative path with ~ prefix
        set session_name (string replace $home_path "~" $current_path)
    else
        # Outside home directory - use absolute path but remove leading slash
        set session_name (string sub -s 2 $current_path)
    end
    
    # Sanitize the session name (replace problematic characters)
    set session_name (string replace -a " " "_" $session_name)
    
    # Check if we should create the session or if it already exists
    if not tmux has-session -t $session_name 2>/dev/null
        echo "Creating new session '$session_name'..."
        tmux new-session -d -s $session_name
    end

    if not test -n "$TMUX"
        tmux attach-session -t $session_name
    else
        tmux switch-client -t $session_name
    end
end

function tma -d "Attach tmux session"
  if not test -n "$TMUX"
      tmux list-sessions -F "#{session_name}" | fzf --height 10% --layout=reverse --border | read -l result; and tmux attach -t "$result"
  else
      tmux list-sessions -F "#{session_name}" | fzf --height 10% --layout=reverse --border | read -l result; and tmux switch-client -t "$result"
  end
end

function tmm -d "Mirror tmux session"
    tmux list-sessions -F "#{session_name}" | fzf --height 10% --layout=reverse --border | read -l result; and tmux new-session -t "$result" -s "$result"--mirror; and tmux switch-client -t "$result"--mirror
end

function tmk -d "Kill tmux session"
    tmux list-sessions -F "#{session_name}" | fzf --height 10% --layout=reverse --border | read -l result; and tmux kill-session -t "$result"
end

function tmd -d "Detach tmux session"
    tmux detach
end
