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

        # Save current state
        tms --silent
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

    # Save current state
    # TODO: does not work if we delete the session we are currently in
    tms --silent
end

function tmd -d "Detach tmux session"
    tmux detach
end

function tms -d "Save all tmux sessions"
    set save_file ~/.tmux_sessions_save
    set silent_mode false

    # Check for --silent flag
    if contains -- --silent $argv
        set silent_mode true
    end

    # Get all current sessions with their working directories
    set sessions (tmux list-sessions -F "#{session_name}:#{session_path}")

    if test (count $sessions) -eq 0
        if not $silent_mode
            echo "No tmux sessions to save."
        end
        return 1
    end

    if not $silent_mode
        echo "Saving the following tmux sessions:"
        for session in $sessions
            set session_parts (string split ":" $session)
            set session_name $session_parts[1]
            set session_path $session_parts[2]
            echo "  - $session_name (in $session_path)"
        end
    end

    # Save sessions to file
    printf "%s\n" $sessions >$save_file

    if not $silent_mode
        echo ""
        echo "Saved "(count $sessions)" session(s) to $save_file"
    end
end

function tmr -d "Restore saved tmux sessions"
    set save_file ~/.tmux_sessions_save

    if not test -f $save_file
        echo "No saved sessions file found at $save_file"
        return 1
    end

    # Read saved sessions
    set saved_sessions (cat $save_file)

    if test (count $saved_sessions) -eq 0
        echo "No saved sessions found in $save_file"
        return 1
    end

    # Check if there are currently active sessions
    set current_sessions (tmux list-sessions -F "#{session_name}" 2>/dev/null)

    if test (count $current_sessions) -gt 0
        echo "Warning: The following tmux sessions are currently active:"
        for session in $current_sessions
            echo "  - $session"
        end
        echo ""
        echo "About to restore the following saved sessions:"
        for session in $saved_sessions
            set session_parts (string split ":" $session)
            set session_name $session_parts[1]
            set session_path $session_parts[2]
            echo "  - $session_name (in $session_path)"
        end
        echo ""
        read -P "Continue with restore? [y/N]: " -l confirm

        if not string match -qi "y*" $confirm
            echo "Restore cancelled."
            return 0
        end
    else
        echo "Restoring the following saved sessions:"
        for session in $saved_sessions
            set session_parts (string split ":" $session)
            set session_name $session_parts[1]
            set session_path $session_parts[2]
            echo "  - $session_name (in $session_path)"
        end
        echo ""
    end

    # Restore each session
    set restored_count 0
    for session in $saved_sessions
        set session_parts (string split ":" $session)
        set session_name $session_parts[1]
        set session_path $session_parts[2]

        # Check if session already exists
        if tmux has-session -t $session_name 2>/dev/null
            echo "Session '$session_name' already exists, skipping..."
            continue
        end

        # Create session in the saved directory
        if test -d $session_path
            tmux new-session -d -s $session_name -c $session_path
            echo "Restored session '$session_name' in $session_path"
            set restored_count (math $restored_count + 1)
        else
            echo "Warning: Directory '$session_path' no longer exists, creating session in current directory"
            tmux new-session -d -s $session_name
            set restored_count (math $restored_count + 1)
        end
    end

    echo ""
    echo "Restored $restored_count session(s)"
end
