#!/bin/sh

PROJECT_ROOT=$(git rev-parse --show-toplevel)
HOOKS_SOURCE=$(dirname "$0")
HOOKS_TARGET="$PROJECT_ROOT/.git/hooks"

# Copy all hooks to the .git/hooks directory.
for script in "$HOOKS_SOURCE"/*; do
  if [ "$script" != "$0" ]; then # Skip the current script
    echo "Copying $script to $HOOKS_TARGET..."
    cp "$script" "$HOOKS_TARGET"
    chmod +x "$HOOKS_TARGET/$(basename "$script")"
  fi
done
