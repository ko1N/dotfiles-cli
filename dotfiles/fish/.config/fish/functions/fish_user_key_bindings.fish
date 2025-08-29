function fish_user_key_bindings
    # Add fzf keybindings via brew
    if command -v brew >/dev/null 2>&1
        source (brew --prefix)/opt/fzf/shell/key-bindings.fish
    end

    fzf_key_bindings
end
