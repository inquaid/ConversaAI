#!/bin/bash
# Cleanup script to remove non-contributing directories

echo "Cleaning up non-contributing directories..."

# Set the base directory
BASE_DIR="/home/turjo-pop/Documents/ConversaAI/codebase/lib"

# Directories to remove
REMOVE_DIRS=(
  "$BASE_DIR/prac"
  "$BASE_DIR/tempP"
)

# Remove each directory
for dir in "${REMOVE_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "Removing $dir..."
    rm -rf "$dir"
    echo "✓ Removed $dir"
  else
    echo "✗ Directory $dir does not exist"
  fi
done

echo "Cleanup complete!"