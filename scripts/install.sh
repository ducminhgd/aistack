#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE_DIRS=(agents commands rules skills)

usage() {
    echo "Usage: install [AI Agent] [--global|-g] [--dir|-d <dirs>] [--force|-f]"
    echo ""
    echo "Arguments:"
    echo "  AI Agent              Target AI client: claude, codex, gemini, cursor, augment"
    echo "  --global, -g          Install to user home directory (e.g., ~/.claude)"
    echo "  --dir, -d <dirs>      Install to .claude inside given directory(ies)."
    echo "                        Multiple dirs: comma-separated or repeated --dir flags"
    echo "  --force, -f           Overwrite existing directories without error"
    echo ""
    echo "Examples:"
    echo "  make install ARGS=\"claude --global\""
    echo "  make install ARGS=\"claude --dir /path/to/project\""
    echo "  make install ARGS=\"claude --global --dir /path1,/path2 --force\""
}

# --- Argument parsing ---

AGENT=""
GLOBAL=false
DIRS=()
FORCE=false

if [ $# -eq 0 ]; then
    echo "Error: AI Agent argument is required." >&2
    usage >&2
    exit 1
fi

# First positional arg is the agent (unless it starts with -)
if [[ "$1" != -* ]]; then
    AGENT="$1"
    shift
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --global|-g)
            GLOBAL=true
            shift
            ;;
        --dir|-d)
            if [ $# -lt 2 ]; then
                echo "Error: --dir requires a value." >&2
                exit 1
            fi
            shift
            # Support comma-separated list in one --dir value
            IFS=',' read -ra _new_dirs <<< "$1"
            for _d in "${_new_dirs[@]}"; do
                _d="${_d%/}"   # strip trailing slash
                DIRS+=("$_d")
            done
            shift
            ;;
        --force|-f)
            FORCE=true
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option '$1'." >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [ -z "$AGENT" ]; then
    echo "Error: AI Agent argument is required." >&2
    usage >&2
    exit 1
fi

# --- Agent dispatch ---

install_claude() {
    local dot_dir="$1"   # e.g. /home/user/.claude or /some/project/.claude
    local client_dir=".claude"

    local dest="$dot_dir/$client_dir"
    echo "Installing to: $dest"

    mkdir -p "$dest"

    for src_name in "${SOURCE_DIRS[@]}"; do
        local src="$PROJECT_ROOT/$src_name"
        local dest_sub="$dest/$src_name"

        if [ ! -d "$src" ]; then
            echo "  [skip] $src_name/ not found in project root"
            continue
        fi

        # Collect items to copy (everything except top-level README.md)
        local has_items=false
        while IFS= read -r -d '' item; do
            has_items=true
            local item_name
            item_name="$(basename "$item")"
            local dest_item="$dest_sub/$item_name"

            if [ -e "$dest_item" ]; then
                if [ "$FORCE" = false ]; then
                    echo "Error: '$dest_item' already exists. Use --force to overwrite." >&2
                    exit 1
                else
                    echo "  [overwrite] $dest_sub/$item_name"
                    rm -rf "$dest_item"
                fi
            else
                echo "  [copy] $src_name/$item_name -> $dest_sub/$item_name"
            fi

            mkdir -p "$dest_sub"
            cp -r "$item" "$dest_sub/"
        done < <(find "$src" -mindepth 1 -maxdepth 1 ! -name "README.md" -print0)

        if [ "$has_items" = false ]; then
            echo "  [skip] $src_name/ has no installable items"
        fi
    done
}

do_install_claude() {
    local targets=()

    if [ "$GLOBAL" = true ]; then
        targets+=("$HOME")
    fi

    for d in "${DIRS[@]+"${DIRS[@]}"}"; do
        if [ ! -d "$d" ]; then
            echo "Error: Directory '$d' does not exist." >&2
            exit 1
        fi
        targets+=("$d")
    done

    if [ ${#targets[@]} -eq 0 ]; then
        echo "Error: Specify at least one of --global or --dir." >&2
        usage >&2
        exit 1
    fi

    for target in "${targets[@]}"; do
        install_claude "$target"
    done

    echo "Done."
}

case "$AGENT" in
    claude)
        do_install_claude
        ;;
    codex|gemini|cursor|augment)
        echo "Error: Agent '$AGENT' is not implemented yet." >&2
        exit 1
        ;;
    *)
        echo "Error: Unknown AI Agent '$AGENT'." >&2
        echo "Supported agents: claude, codex, gemini, cursor, augment" >&2
        exit 1
        ;;
esac
