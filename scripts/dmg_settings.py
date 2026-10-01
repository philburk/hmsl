# Layout of the HMSL DMG installer window, used by dmgbuild.
# Used by scripts/make_dmg.py, which is called from scripts/release.sh.
# The icon positions must match the arrow in scripts/make_dmg_background.swift.

import os

app = defines["app"]
repo = defines["repo"]
app_name = os.path.basename(app)

format = "UDZO"
filesystem = "HFS+"

files = [app]
symlinks = {"Applications": "/Applications"}

icon = os.path.join(repo, "resources/hmsl.icns")
background = os.path.join(repo, "resources/dmg-background.png")  # also uses @2x

# The height includes the title bar, so the 400 point background fits below it.
window_rect = ((200, 120), (640, 428))
default_view = "icon-view"
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False

icon_size = 128
text_size = 14
icon_locations = {
    app_name: (170, 165),
    "Applications": (470, 165),
}
