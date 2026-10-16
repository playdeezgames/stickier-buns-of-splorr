#!/usr/bin/env bash
# Captures assets/screenshots/ from the real build with headless Chrome, using the ?scene=N QA hook.
set -euo pipefail
cd "$(dirname "$0")/.."
tools/build.sh >/dev/null
mkdir -p assets/screenshots
port=8801
while ss -ltn | grep -q ":$port "; do port=$((port + 1)); done
python3 -m http.server "$port" --bind 127.0.0.1 -d build/web >/dev/null 2>&1 &
server=$!
trap 'kill $server' EXIT
sleep 1
shot() { # scene file
	google-chrome --headless=new --no-sandbox --disable-gpu --hide-scrollbars --window-size=1280,720 \
		--virtual-time-budget=6000 --screenshot="assets/screenshots/$2" "http://127.0.0.1:$port/?scene=$1" 2>/dev/null
	echo "assets/screenshots/$2"
}
shot 1 01-play.png
shot 2 02-shoppe.png
shot 3 03-dead.png
