function tma -d "Attach tmux session"
  tmux list-sessions -F "#{session_name}" | fzf | read -l result; and tmux attach -t "$result"
end

function tms -d "Switch tmux session"
  tmux list-sessions -F "#{session_name}" | fzf | read -l result; and tmux switch-client -t "$result"
end

function tmm -d "Mirror tmux session"
  tmux list-sessions -F "#{session_name}" | fzf | read -l result; and tmux new-session -t "$result" -s "$result"_mirror; and tmux switch-client -t "$result"_mirror
end

function tmk -d "Kill tmux session"
  tmux list-sessions -F "#{session_name}" | fzf | read -l result; and tmux kill-session -t "$result"
end

function tmd -d "Detach tmux session"
  tmux detach
end
