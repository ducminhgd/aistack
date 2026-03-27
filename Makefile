.DEFAULT_GOAL := help

# Everything after 'install' (agent name + flags) is forwarded to the script.
# Use '--' to stop make from interpreting -g/-d/-f as its own flags.
_ARGS := $(filter-out install help,$(MAKECMDGOALS))

.PHONY: help install $(_ARGS)

help:
	@echo "Usage:"
	@echo "  make install -- <agent> [-g|--global] [-d|--dir <dirs>] [-f|--force]"
	@echo ""
	@echo "Arguments:"
	@echo "  agent              AI client: claude, codex, gemini, cursor, augment"
	@echo "  -g, --global       Install to user home directory (~/.claude)"
	@echo "  -d, --dir <dirs>   Install into .claude inside given directory(ies)."
	@echo "                     Multiple dirs: comma-separated  (-d /path1,/path2)"
	@echo "  -f, --force        Overwrite existing directories without error"
	@echo ""
	@echo "  '--' stops make from treating -g/-d/-f as its own flags."
	@echo ""
	@echo "Examples:"
	@echo "  make install -- claude -g"
	@echo "  make install -- claude --global --dir /path/to/project"
	@echo "  make install -- claude -g -d /path1,/path2 -f"

install:
	@bash scripts/install.sh $(_ARGS)

# Absorb extra goals (agent name and flags) so make does not produce spurious output
ifneq ($(_ARGS),)
$(_ARGS):
	@:
endif
