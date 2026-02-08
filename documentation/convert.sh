for file in liver_*.nii.gz; do
    # Check if files exist to avoid errors in empty folders
    [ -e "$file" ] || continue

    # Extract the number (the part between 'liver_' and '.nii.gz')
    num=$(echo "$file" | sed 's/liver_\(.*\)\.nii\.gz/\1/')

    # Format the number to be 3 digits with leading zeros (e.g., 0 becomes 000)
    # If your source is "0", this makes it "000". If it's "1", it becomes "001".
    new_num=$(printf "%03d" "$num")

    # Construct the new filename
    new_name="liver_${new_num}s.nii.gz"

    # Rename the file
    mv "$file" "$new_name"
    
    echo "Renamed: $file -> $new_name"
done