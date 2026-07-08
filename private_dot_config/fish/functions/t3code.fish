function t3code
    # Launching via the app bundle directly (not `open -a`) lets us override
    # SHELL just for this process, so T3 Code's built-in terminal uses fish
    # instead of the account's login shell.
    set -lx SHELL /opt/homebrew/bin/fish
    exec "/Applications/T3 Code (Alpha).app/Contents/MacOS/T3 Code (Alpha)"
end
