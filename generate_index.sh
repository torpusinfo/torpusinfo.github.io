#!/bin/bash
# generate_index.sh - Generate static HTML index files for directories
# Usage: ./generate_index.sh [path/to/directory]
# Default path is /home/lain/dox/files/archive/

# Set default directory if not provided
if [ -z "$1" ]; then
  WEB_ROOT="./archive"
else
  WEB_ROOT="$1"
fi

EXCLUDE_FILES=("index.htm" "styles.css" "monoe.png" "generate_index.sh")

# Function to generate index.html for a directory
generate_index() {
  local dir="$1"
  local rel_path="${dir#$WEB_ROOT}"
  rel_path="${rel_path#/}"
  
  local title_path="/archive/"
  if [ -n "$rel_path" ]; then
    title_path="/archive/$rel_path/"
  fi

  local rel_to_root=""
  if [ -n "$rel_path" ]; then
    local levels=$(echo "$rel_path" | tr -cd '/' | wc -c)
    levels=$((levels + 1))
    for ((i=0; i<levels; i++)); do
      rel_to_root="${rel_to_root}../"
    done
  fi
  
  echo "Generating index for: $dir"
  
  cat > "$dir/index.htm" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Index of ${title_path}</title>
	<link rel="stylesheet" href="${rel_to_root}styles.css">
</head>
<body>
	<h1>Index of ${title_path}</h1>
	<hr style="border: 1px solid white;">
	<main>
EOF

  echo '		<li><a href="../">../</a></li>' >> "$dir/index.htm"

  find "$dir" -maxdepth 1 -mindepth 1 -type d | sort | while read subdir; do
    subdir_name=$(basename "$subdir")

    echo "		<li><a href=\"$subdir_name/\">$subdir_name/</a></li>" >> "$dir/index.htm"
  done

  find "$dir" -maxdepth 1 -mindepth 1 -type f | sort | while read file; do
    filename=$(basename "$file")
    
    skip=false
    for excluded in "${EXCLUDE_FILES[@]}"; do
      if [ "$filename" = "$excluded" ]; then
        skip=true
        break
      fi
    done
    
    if ! $skip; then
      echo "		<li><a href=\"$filename\">$filename</a></li>" >> "$dir/index.htm"
    fi
  done

  cat >> "$dir/index.htm" << EOF
	</main>
	<hr style="border: 1px solid white;">
	<img src="${rel_to_root}monoe.png" class="monoe">
</body>
</html>
EOF
}

generate_index "$WEB_ROOT"

find "$WEB_ROOT" -type d | while read dir; do
  if [ "$dir" != "$WEB_ROOT" ]; then
    generate_index "$dir"
  fi
done

echo "All index.htm files have been generated!"

