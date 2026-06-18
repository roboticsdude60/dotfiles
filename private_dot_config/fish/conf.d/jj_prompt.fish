status is-interactive || exit

set --global _fish_jj_prompt _fish_jj_prompt_$fish_pid

function $_fish_jj_prompt --on-variable $_fish_jj_prompt
    commandline --function repaint
end

function _jj_prompt_check --on-variable PWD
    # Quick check if we should skip jj prompt - runs on directory change
    if not command -sq jj
        set --global _jj_prompt_skip
        return 1
    end
    
    if not jj root --ignore-working-copy --quiet 2>/dev/null >/dev/null
        set --global _jj_prompt_skip
        return 1
    else
        # We're in a jj repo - enable jj prompt
        set --erase _jj_prompt_skip
        return 0
    end
end

function jj_prompt_is_repo --description 'Check if current directory is in a jj repo (for use in prompt configs)'
    # Return 0 (success) if in a jj repo, 1 (failure) otherwise
    command -sq jj || return 1
    jj root --ignore-working-copy --quiet 2>/dev/null >/dev/null
end

# Initialize on load
_jj_prompt_check

function _jj_prompt_async --on-event fish_prompt
    command kill $_jj_prompt_last_pid 2>/dev/null

    # If we should skip jj prompt, clear the variable and return
    if set --query _jj_prompt_skip
        set --universal $_fish_jj_prompt ""
        return
    end

    fish --private --command "_jj_prompt_fetch $_fish_jj_prompt" &

    set --global _jj_prompt_last_pid $last_pid
end

function _jj_prompt_exit --on-event fish_exit
    set --erase $_fish_jj_prompt
end

function _jj_prompt_install --on-event jj_prompt_install
    # Plugin installed - trigger initial check
    _jj_prompt_check
end

function _jj_prompt_update --on-event jj_prompt_update
    # Plugin updated - trigger check to refresh state
    _jj_prompt_check
end

function _jj_prompt_uninstall --on-event jj_prompt_uninstall
    # Clean up all plugin variables and functions
    set --names |
        string replace --filter --regex -- "^_fish_jj_prompt|^_jj_prompt" "set --erase \$0" |
        source
    functions --erase (functions --all | string match --entire --regex "^_jj_prompt")
    functions --erase fish_jj_prompt
end

