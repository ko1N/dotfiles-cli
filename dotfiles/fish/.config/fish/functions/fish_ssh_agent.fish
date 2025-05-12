function __ssh_agent_is_started -d "check if ssh agent is already started"
   if begin; test -f $SSH_ENV; and test -z "$SSH_AGENT_PID"; end
      source $SSH_ENV > /dev/null
   end

   if test -z "$SSH_AGENT_PID"
      return 1
   end

   ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep -q ssh-agent
   #pgrep ssh-agent
   return $status
end


function __ssh_agent_start -d "start a new ssh agent"
   ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
   chmod 600 $SSH_ENV
   source $SSH_ENV > /dev/null
   true  # suppress errors from setenv, i.e. set -gx
end


function fish_ssh_agent --description "Start ssh-agent if not started yet, or uses already started ssh-agent."
   if test -z "$SSH_ENV"
      set -xg SSH_ENV $HOME/.ssh/environment
   end

   if not __ssh_agent_is_started
      __ssh_agent_start
   end
end


function fish_ssh_remove_all_keys --description "Remove all currently added SSH keys from the agent"
   # Ensure SSH agent is started
   fish_ssh_agent
   
   # Now remove all keys
   ssh-add -D
   echo "All SSH keys have been removed from the agent."
end

function fish_ssh_yubikey --description "Reload YubiKey SSH key"
   # Ensure SSH agent is started
   fish_ssh_agent
   
   # Remove all existing keys first
   ssh-add -L | grep "PIV AUTH" | ssh-add -d -
   
   # Add YubiKey SSH key using PKCS#11 provider
   ssh-add -s /usr/lib/opensc-pkcs11.so
   echo "YubiKey SSH key has been loaded."
end

