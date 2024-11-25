#!/bin/bash

find \
    . -maxdepth 14 \
    -name "*.sh"  \
    -not -path "./lib/ansible/*" \
    -print0 \
| while IFS= read -r -d $'\0' FILE; do
    echo "Searching file: $FILE"
    grep -oE '\$[a-z_0-9]+' "$FILE" | while read -r LINE; do
        echo $LINE
        # var_name=$(echo "$line" | cut -d= -f1)
        # if [[ "$var_name" =~ ^[a-z_0-9]+$ ]]; then
        #     echo "  $var_name"
        # fi
    done
    echo ""
done

