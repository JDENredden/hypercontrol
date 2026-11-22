"""Install the compiled Hyper Control rules into the live Karabiner config.

Usage: uv run --no-project python install.py NEW_JSON PREVIOUS_JSON

NEW_JSON       the freshly compiled hypercontrol.json
PREVIOUS_JSON  the copy that was installed last time (Karabiner's assets
               folder); may be missing on a first install

Why a script and not just a copy: Karabiner keeps its own snapshot of every
enabled rule inside karabiner.json. Copying hypercontrol.json into the assets
folder only updates the "Add rule" menu, so the live rules must be replaced
in karabiner.json itself. That file also holds settings this project doesn't
own (the HHKB device mapping, tap timeout, other rule sets), so only Hyper
Control's rule groups are touched and everything else is left as it is.
"""

import json
import shutil
import sys
from datetime import datetime
from pathlib import Path

KARABINER = Path.home() / ".config" / "karabiner"
LIVE = KARABINER / "karabiner.json"
BACKUPS = KARABINER / "automatic_backups"


def rule_names(path: Path) -> set[str]:
    """Descriptions of the rule groups in a complex-modifications file."""
    if not path.exists():
        return set()
    return {r["description"] for r in json.loads(path.read_text())["rules"]}


def main() -> None:
    new_path, prev_path = Path(sys.argv[1]), Path(sys.argv[2])
    new_rules = json.loads(new_path.read_text())["rules"]

    # Our groups = anything we're installing now, plus anything we installed
    # last time (so renamed or deleted groups get removed, not left behind).
    ours = rule_names(new_path) | rule_names(prev_path)

    live = json.loads(LIVE.read_text())

    # Back up before changing anything; restore by copying it back.
    BACKUPS.mkdir(exist_ok=True)
    backup = BACKUPS / f"karabiner_before_make_install_{datetime.now():%Y%m%d_%H%M%S}.json"
    shutil.copy2(LIVE, backup)

    def our_positions(profile: dict) -> list[int]:
        rules = profile.get("complex_modifications", {}).get("rules", [])
        return [i for i, r in enumerate(rules) if r["description"] in ours]

    # First install (no profile has our rules yet): use the selected profile.
    first_install = not any(our_positions(p) for p in live["profiles"])

    fresh = [{"description": r["description"], "manipulators": r["manipulators"]} for r in new_rules]
    changed = False
    for profile in live["profiles"]:
        positions = our_positions(profile)
        if not positions and not (first_install and profile.get("selected")):
            continue  # profile doesn't use Hyper Control; leave it alone
        rules = profile.setdefault("complex_modifications", {}).setdefault("rules", [])
        old = [rules[i] for i in positions]
        # Drop our old groups and insert the new ones where the first one was
        # (or at the top on a first install), keeping the order relative to
        # any other rule sets in the profile.
        insert_at = positions[0] if positions else 0
        keep = [r for i, r in enumerate(rules) if i not in set(positions)]
        profile["complex_modifications"]["rules"] = keep[:insert_at] + fresh + keep[insert_at:]
        if [(r["description"], r["manipulators"]) for r in old] != [
            (r["description"], r["manipulators"]) for r in fresh
        ]:
            changed = True
            print(f"profile {profile.get('name')!r}: updated {len(fresh)} rule groups")

    if not changed:
        backup.unlink()  # nothing changed, so no backup needed
        print("live config already up to date")
        return

    LIVE.write_text(json.dumps(live, indent=4, ensure_ascii=False))
    print(f"backup: {backup}")
    print(f"undo:   cp '{backup}' '{LIVE}'")


if __name__ == "__main__":
    main()
