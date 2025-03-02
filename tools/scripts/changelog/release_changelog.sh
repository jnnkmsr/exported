#!/usr/bin/env bash

# ANSI color codes.
GREEN="\033[1;92m"
END_COLOR="\033[0m"

# Melos environment variables.
PACKAGE="$MELOS_PACKAGE_NAME"
PACKAGE_PATH="$MELOS_PACKAGE_PATH"

# Call `cider release` for the current package.
cider --project-root="$PACKAGE_PATH" release
echo -e "  └> ${GREEN}Released all changes in $PACKAGE/CHANGELOG.md${END_COLOR}"
exit 0
