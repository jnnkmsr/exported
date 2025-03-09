#!/bin/sh

# Copyright (c) 2025 Jannik Möser
# Use of this source code is governed by the BSD 3-Clause License.
# See the LICENSE file for full license information.

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
