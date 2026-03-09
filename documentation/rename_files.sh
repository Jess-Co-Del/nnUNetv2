#!/bin/bash

# ============================================================
# rename_files.sh
# Renames files like liver_0.nii.gz -> liver_000_0000.nii.gz
#   - Zero-pads the number to 3 digits
#   - Replaces the file extension
# ============================================================

# --- Configuration (edit these or pass as arguments) ---
FOLDER="${1:-.}"                  # Target folder (default: current dir)
OLD_EXT="${2:-.nii.gz}"           # Old extension to replace
NEW_EXT="${3:-_0000.nii.gz}"      # New extension
PREFIX="${4:-liver_}"             # Filename prefix before the number

DRY_RUN=true                      # Set to false to actually rename

# --- Main ---
if [ ! -d "$FOLDER" ]; then
    echo "Error: '$FOLDER' is not a valid directory."
    exit 1
fi

count=0

for file in "$FOLDER"/*; do
    [ -f "$file" ] || continue

    filename=$(basename "$file")
    dirpath=$(dirname "$file")

    # Check if file matches the expected pattern: {PREFIX}{number}{OLD_EXT}
    if [[ "$filename" == ${PREFIX}*${OLD_EXT} ]]; then
        # Extract the number between prefix and old extension
        temp="${filename#$PREFIX}"        # remove prefix
        number="${temp%$OLD_EXT}"         # remove old extension

        # Validate that it's actually a number
        if ! [[ "$number" =~ ^[0-9]+$ ]]; then
            echo "Skipping (not a number): $filename"
            continue
        fi

        # Zero-pad to 3 digits
        padded=$(printf "%03d" "$number")

        newname="${PREFIX}${padded}${NEW_EXT}"

        if [ "$DRY_RUN" = true ]; then
            echo "[DRY RUN] $filename -> $newname"
        else
            mv "$dirpath/$filename" "$dirpath/$newname"
            echo "Renamed: $filename -> $newname"
        fi

        ((count++))
    else
        echo "Skipping (no match): $filename"
    fi
done

echo ""
echo "Total files ${DRY_RUN:+would be }renamed: $count"
if [ "$DRY_RUN" = true ]; then
    echo "This was a dry run. Set DRY_RUN=false in the script to apply changes."
fi
