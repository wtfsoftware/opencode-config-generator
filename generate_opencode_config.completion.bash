# Bash completion for generate_opencode_config.sh
# Install: cp this file to /etc/bash_completion.d/ or ~/.local/share/bash-completion/completions/

_generate_opencode_config() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="--local --remote --output --dry-run --interactive --include --exclude --with-embed --no-context-lookup --num-ctx --merge --default-model --small-model --no-cache --version --help -l -r -o -n -i -v -h"

    # Handle flags that take arguments
    case "$prev" in
        -l|--local|-r|--remote|-o|--output|--num-ctx|--default-model|--small-model)
            if [[ "$prev" == "-o" || "$prev" == "--output" ]]; then
                COMPREPLY=( $(compgen -f -- "$cur") )
            elif [[ "$prev" == "-l" || "$prev" == "--local" || "$prev" == "-r" || "$prev" == "--remote" ]]; then
                COMPREPLY=( $(compgen -W "http://localhost:11434 http://192.168.1.100:11434" -- "$cur") )
            elif [[ "$prev" == "--num-ctx" ]]; then
                COMPREPLY=( $(compgen -W "0 4096 8192 16384 32768 65536" -- "$cur") )
            fi
            return 0
            ;;
        --include|--exclude)
            # Try to complete with available model names (best effort)
            if command -v ollama &>/dev/null; then
                local models
                models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | head -20)
                COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            fi
            return 0
            ;;
    esac

    # Default: complete flags
    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
        return 0
    fi

    # Complete file paths for output
    COMPREPLY=( $(compgen -f -- "$cur") )
}

complete -F _generate_opencode_config generate_opencode_config.sh
