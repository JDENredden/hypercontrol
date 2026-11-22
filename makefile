# Hyper Control build steps.
#   make          compile + lint (safe, touches nothing outside this folder)
#   make install  compile + lint, then load the rules into Karabiner
#   make snapshot copy the live karabiner.json into this folder (to commit)
# Note: recipe lines must start with a TAB, not spaces, or make refuses to run.

KARABINER_CLI := /Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli
ASSETS := $(HOME)/.config/karabiner/assets/complex_modifications

all: lint

# YAML (what we edit) -> JSON (what Karabiner reads)
compile:
	yq eval hypercontrol.yml -o=json > hypercontrol.json

# Karabiner's own checker: catches unknown key codes, bad fields, etc.
lint: compile
	"$(KARABINER_CLI)" --lint-complex-modifications hypercontrol.json

# 1. update the live rules in karabiner.json (backs it up first; Karabiner
#    reloads it automatically), then
# 2. copy the JSON into the assets folder so the "Add rule" menu matches.
# install.py reads the old assets copy to know which groups were ours.
install: lint
	mkdir -p "$(ASSETS)"
	uv run --no-project python install.py hypercontrol.json "$(ASSETS)/hypercontrol.json"
	cp hypercontrol.json "$(ASSETS)/hypercontrol.json"

# The live config holds things hypercontrol.yml doesn't: per-keyboard
# settings (HHKB Control -> Caps Lock, MacBook fn keys), the global tap
# timeout, and other rule sets. Snapshot it so those are versioned too.
# To restore on a new Mac: cp karabiner.json ~/.config/karabiner/
snapshot:
	cp "$(HOME)/.config/karabiner/karabiner.json" karabiner.json

.PHONY: all compile lint install snapshot
