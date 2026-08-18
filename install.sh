#!/usr/bin/env bash
# Install (or update) this checkout's plasmoid, then reload Plasma Shell.
set -euo pipefail

package_id="org.rpa.codexbar"
package_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/package"
package_type="Plasma/Applet"

if ! command -v kpackagetool6 >/dev/null; then
    echo "kpackagetool6 is required (install KDE Plasma 6 development tools)." >&2
    exit 1
fi
if ! command -v plasmashell >/dev/null; then
    echo "plasmashell is required; run this from a KDE Plasma session." >&2
    exit 1
fi

if kpackagetool6 --type "$package_type" --list | grep -qx "$package_id"; then
    echo "Updating $package_id…"
    kpackagetool6 --type "$package_type" --upgrade "$package_dir"
else
    echo "Installing $package_id…"
    kpackagetool6 --type "$package_type" --install "$package_dir"
fi

echo "Restarting Plasma Shell…"
nohup plasmashell --replace >/tmp/codexbar-plasmashell.log 2>&1 &

echo "CodexBar installed. Add it from the Widgets panel if it is not already on a panel."
