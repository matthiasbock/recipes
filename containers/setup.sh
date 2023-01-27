
# Specify where to find common resources
export project_root="$(realpath "$(dirname "$scriptpath")/../")"
echo "Project root: $project_root"
export common="$project_root/shared"

# The configuration for the container is provided in the form of a bash script.
if [ "${container_config}" == "" ]; then
  echo "Argument required: Path to image configuration script. Aborting."
  exit 1
fi

# Verify, that file exists
if [ ! -f "${container_config}" ]; then
  # Maybe the path was specified relative to the initial working directory
  container_config="${initial_pwd}/${container_config}"
  if [ ! -f "${container_config}" ]; then
    echo "Error: Configuration script '$container_config' not found. Aborting."
    exit 1
  fi
fi

# Use absolute path, if possible
if [ -f "$(realpath ${container_config})" ]; then
  container_config=$(realpath ${container_config})
fi
export container_config_dir=$(dirname $container_config)

# Load configuration
echo "Info: Using configuration file ${container_config}."
source "${container_config}" \
 || { echo "Error: Failed to load container configuration. Aborting."; exit 1; }

# Include container management routines for bash
export bash_container_library="$common/bash-container-library"
source "$bash_container_library/include.sh" \
 || { echo "Error: Failed to load bash container library. Aborting."; exit 1; }
