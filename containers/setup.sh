
# Specify where to find common resources
project_root="$(realpath "$script_dir/../")"
echo "Project root: $project_root"
lib_dir="$project_root/lib"

# Include container management routines for bash
if [ "$BASH_CONTAINER_LIBRARY" == "" ]; then
  # Default path, if no path is specified
  bash_container_library="$lib_dir/container"
else
  bash_container_library="$BASH_CONTAINER_LIBRARY"
  if [ ! -d "$bash_container_library" ]; then
    bash_container_library="../$BASH_CONTAINER_LIBRARY"
  fi
fi
bash_container_library="$(realpath -m "$bash_container_library")"
echo "Including bash container library from \"$bash_container_library\"..."
bash_container_library_include="$bash_container_library/include.sh"
. "$bash_container_library_include" \
|| { echo "Error: Failed to include \"$bash_container_library_include\"."; exit 11; }

# shared_dir="$project_root/lib/"
shared_dir="$assets_dir"
echo "Shared files directory: $shared_dir"

# The configuration for the container is provided in the form of a bash script.
if [ "$container_config" == "" ]; then
  echo "Error: Argument required: Path to image configuration script."
  exit 1
fi

# Verify, that configuration file exists
if [ ! -f "$container_config" ]; then
  # Maybe the path was specified relative to the initial working directory
  f="$initial_dir/$container_config"
  if [ -f "$f" ]; then
    container_config="$f"
  else
    # ...or relative to the script directory
    f="$script_dir/$container_config"
    if [ -f "$f" ]; then
      container_config="$f"
    else
      # ...or relative to the project root
      f="$project_root/$container_config"
      if [ -f "$f" ]; then
        container_config="$f"
      else
        echo "Error: Configuration script not found: \"$container_config\""
        exit 12
      fi
    fi
  fi
fi

# Use absolute path, if possible
container_config_realpath="$(realpath "$container_config")"
if [ -f "$container_config_realpath" ]; then
  container_config="$container_config_realpath"
fi

# The directory containing the config script
container_config_dir="$(dirname "$container_config")"

# Load configuration
echo "Including container configuration from \"$container_config\"..."
. "$container_config" \
|| { echo "Error: Failed to include container configuration from \"$container_config\"."; exit 13; }
