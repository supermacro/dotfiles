#!/bin/bash

printf '%s\n' \
    '#!/bin/sh' \
    '#' \
    '# name: Kitty' \
    "# icon: $HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png" \
    '# description: Launch Kitty' \
    '# keywords: kitty terminal \' \
    '' \
    "$HOME/.local/kitty.app/bin/kitty"
