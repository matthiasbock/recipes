
# Specify where to find common resources
project_root="$(realpath "$(dirname "$script_filename")/../")"
echo "Project root: $project_root"
shared_dir="$project_root/shared"
echo "Shared files directory: $shared_dir"

# The configuration for the container is provided in the form of a bash script.
if [ "$container_config" == "" ]; then
  echo "Error: Argument required: Path to image configuration script."
  exit 1
fi

# Verify, that file exists
if [ ! -f "$container_config" ]; then
  # Maybe the path was specified relative to the initial working directory
  container_config="$initial_dir/$container_config"
  if [ ! -f "$container_config" ]; then
    echo "Error: Configuration script not found: \"$container_config\""
    exit 1
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
 || { echo "Error: Failed to include container configuration from \"$container_config\"."; exit 1; }

# Include container management routines for bash
bash_container_library="$shared_dir/bash-container-library"
echo "Including bash container library from \"$bash_container_library\"..."
bash_container_library_include="$bash_container_library/include.sh"
. "$bash_container_library_include" \
 || { echo "Error: Failed to include \"$bash_container_library_include\"."; exit 1; }
