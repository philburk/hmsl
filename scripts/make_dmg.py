"""Build the HMSL DMG with dmgbuild, using scripts/dmg_settings.py.

Usage: make_dmg.py app_path repo_path volume_name output.dmg

Requires dmgbuild 1.6.7 or later, which shows the background image
correctly on macOS 26.2 and later.
"""

import os
import sys

import dmgbuild

app, repo, volume_name, output = sys.argv[1:5]
settings = os.path.join(repo, "scripts", "dmg_settings.py")
dmgbuild.build_dmg(output, volume_name, settings, defines={"app": app, "repo": repo})
