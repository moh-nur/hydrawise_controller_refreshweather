#!/bin/bash

# Create and activate virtual environment...
virtualenv -p $runtime env_$function_name
source $path_cwd/env_$function_name/bin/activate

# Create deployment package...
SCRIPT_DIR="$(dirname $0)"
TARGET_DIR="$SCRIPT_DIR/dist"

rm -rf "$TARGET_DIR"
mkdir "$TARGET_DIR"
pip3 install -r "$SCRIPT_DIR/requirements.txt" --target "$TARGET_DIR"
cp "$SCRIPT_DIR/lambda.py" "$TARGET_DIR"

# Removing virtual environment folder...
echo "Removing virtual environment folder..."
rm -rf $path_cwd/env_$function_name