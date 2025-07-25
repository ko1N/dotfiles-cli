function how
    set --local argv $argv[1..-1]
    ollama run deepseek-coder:6.7b "give me the linux terminal command. i am using the bash shell. just print one command example. start by writing the command and a write a very brief explanation for each argument in one sentence. the command should do: $argv"
end
