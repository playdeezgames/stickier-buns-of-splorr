#!/usr/bin/env bash
# Runs the original Lua coordinate code under LÖVE (headless) and records its answers in
# odin/game/testdata/iso_reference.txt, which the Odin tests compare against.
set -euo pipefail
cd "$(dirname "$0")/.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cp -r src "$tmp/ref"
cat > "$tmp/ref/conf.lua" <<'LUA'
function love.conf(t)
    t.window = false
    t.modules.window = false
    t.modules.graphics = false
    t.modules.audio = false
    t.modules.sound = false
    t.modules.joystick = false
end
LUA
cat > "$tmp/ref/main.lua" <<'LUA'
local uimanager = require("uimanager")
local mousemap = require("mousemap")
function love.load()
    uimanager.load()
    local lines = {}
    for x = 0, 7 do
        for y = 0, 7 do
            local px, py = uimanager.plotXY(x, y)
            lines[#lines + 1] = string.format("P %d %d %d %d", x, y, px, py)
        end
    end
    for sx = 0, 1279, 17 do
        for sy = 0, 719, 13 do
            local mx, my = mousemap.mapXY(sx, sy)
            lines[#lines + 1] = string.format("M %d %d %d %d", sx, sy, mx, my)
        end
    end
    local f = assert(io.open(os.getenv("REF_OUT"), "w"))
    f:write(table.concat(lines, "\n"), "\n")
    f:close()
    os.exit(0)
end
LUA
REF_OUT="$PWD/odin/game/testdata/iso_reference.txt" love "$tmp/ref"
wc -l odin/game/testdata/iso_reference.txt
