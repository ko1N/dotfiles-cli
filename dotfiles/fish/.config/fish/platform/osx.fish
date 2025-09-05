# This is currently disabled as brew is super slow and causes fish startup issues:
# Check if homebrew is installed
# if command -q -v brew >/dev/null 2>&1
#     # Check if python3 is installed via homebrew
#     if brew list python3 >/dev/null 2>&1
#         fish_add_path (brew --prefix python3)/bin
#     end
#
#     # Check if rustup is installed via homebrew
#     if brew list rustup >/dev/null 2>&1
#         set rustup_prefix (brew --prefix rustup)/bin
#         set -gx RUSTBIN $rustup_prefix $RUSTBIN
#         fish_add_path $rustup_prefix
#     end
# end

# Instead we just use hardcoded (default) paths:
if test -d /opt/homebrew/opt/python3/bin
    fish_add_path /opt/homebrew/opt/python3/bin
else if test -d /usr/local/opt/python3/bin
    fish_add_path /usr/local/opt/python3/bin
end

if test -d /opt/homebrew/opt/rustup/bin
    set -gx RUSTBIN /opt/homebrew/opt/rustup/bin $RUSTBIN
    fish_add_path /opt/homebrew/opt/rustup/bin
else if test -d /usr/local/opt/rustup/bin
    set -gx RUSTBIN /usr/local/opt/rustup/bin $RUSTBIN
    fish_add_path /usr/local/opt/rustup/bin
end
