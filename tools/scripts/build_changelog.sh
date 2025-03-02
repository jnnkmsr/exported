#!/usr/bin/env bash

# ANSI color codes.
RED="\033[1;31m"
GREEN="\033[1;92m"
BLUE="\033[1;34m"
GRAY="\033[1;90m"
END_COLOR="\033[0m"

# Locate the `changelog.yaml` file for the current package.
PACKAGE="$MELOS_PACKAGE_NAME"
PACKAGE_PATH="$MELOS_PACKAGE_PATH"
YAML_FILE="$PACKAGE_PATH/changelog.yaml"
YAML_HEADER="# Staging changelog for $PACKAGE
#
# This file contains changelog entries to be written into the \"Unreleased\"
# section of the CHANGELOG.md file.
#
# The content should be a YAML list of entries with a type (or type alias) and
# a description.
# - type: added, changed, deprecated, fixed, removed, security.
# - type alias: a, c, d, f, r, s.
# - description: A short description of the change. Can use Markdown.
#
# Example format:
# - changed: \"New turbo V6 engine installed.\"
# - added: \"Support for rocket fuel and kerosene.\"
# - fixed: \"Wheels falling off sporadically.\"
#
# To process, run release:build-changelog through the Melos CLI.

# - added:
# - changed:
# - deprecated:
# - fixed:
# - removed:
# - security: "

# Create a `changelog.yaml` if it doesn't exist and exit.
if [[ ! -f $YAML_FILE ]]; then
  echo -e "  └> ${BLUE}Creating initial $PACKAGE/changelog.yaml...${END_COLOR}"
  echo "$YAML_HEADER" > "$YAML_FILE"
  echo -e "  └> ${GREEN}$PACKAGE/CHANGELOG.md up-to-date${END_COLOR}"
  exit 0
fi

# Extract YAML entries.
entries=$(yq eval '.[] | to_entries | .[] | "\(.key): \(.value)"' "$YAML_FILE")
num_entries=$(echo "$entries" | grep -Ec '^[a-zA-Z]+: .+')
if [[ "$num_entries" -eq 0 ]]; then
  echo -e "  └> ${BLUE}No entries in $PACKAGE/changelog.yaml...${END_COLOR}"
  echo "$YAML_HEADER" > "$YAML_FILE"
  echo -e "  └> ${GREEN}$PACKAGE/CHANGELOG.md up-to-date${END_COLOR}"
  exit 0
fi

# Write all entries into CHANGELOG.md.
if [[ "$num_entries" -eq 1 ]]; then
  entry_word="entry"
else
  entry_word="entries"
fi
echo -e "  └> ${BLUE}Writing $num_entries $entry_word into $PACKAGE/CHANGELOG.md...${END_COLOR}"
while IFS=": " read -r type description; do
  # Trim leading whitespace.
  description="${description#"${description%%[![:space:]]*}"}"

  # Run cider log to write into the "Unreleased" section of CHANGELOG.md.
  echo -e "     - ${RED}$type${END_COLOR}: ${GRAY}$description${END_COLOR}"
  cider --project-root="$MELOS_PACKAGE_PATH" log "$type" "$description"
done <<< "$entries"

# Clear/rewrite the `changelog.yaml` file with the header.
echo "$YAML_HEADER" > "$YAML_FILE"
echo -e "  └> ${GREEN}$PACKAGE/CHANGELOG.md up-to-date${END_COLOR}"
exit 0
