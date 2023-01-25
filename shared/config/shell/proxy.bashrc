
#
# If a proxy is configured via environment variables,
# automatically adjust the configuration of some programs accordingly:
# - apt client
# - git client
# - docker client
#
# Note:
# Requires jq to be installed and
# sudo to be configured with NOPASSWD for the current user.
#

#
# Ensure environment variable name capitalization
#
if [ "${http_proxy}" != "" ]; then
  export HTTP_PROXY=${http_proxy}
fi
if [ "${https_proxy}" != "" ]; then
  export HTTPS_PROXY=${https_proxy}
fi
if [ "${no_proxy}" != "" ]; then
  export NO_PROXY=${no_proxy}
fi

#
# Use proxy to access Debian package archives
#
APT_PROXY_CONF="/etc/apt/apt.conf.d/proxy.conf"
sudo mkdir -p $(dirname ${APT_PROXY_CONF})
sudo echo > ${APT_PROXY_CONF}
sudo chmod 644 ${APT_PROXY_CONF}
if [ "${HTTP_PROXY}" != "" ]; then
  # HTTP proxy
  sudo echo "Acquire::http::Proxy \"${HTTP_PROXY}\";" >> ${APT_PROXY_CONF}

  # If no separate proxy is defined for HTTPS, use the HTTP proxy.
  if [ "${HTTPS_PROXY}" == "" ]; then
    sudo echo "Acquire::https::Proxy \"${HTTP_PROXY}\";" >> ${APT_PROXY_CONF}
  fi
fi;

# Dedicated proxy for HTTPS
if [ "${HTTPS_PROXY}" != "" ]; then
  sudo echo "Acquire::https::Proxy \"${HTTPS_PROXY}\";" >> ${APT_PROXY_CONF}
fi

#
# Use proxy to access git repositories
#
if [ "$(which git)" != "" ]; then
  # If git is installed...
  if [ "${HTTP_PROXY}" != "" ]; then
    # Configure HTTP proxy
    git config --global http.proxy "${HTTP_PROXY}"

    # If no separate proxy is defined for HTTPS, use the HTTP proxy.
    if [ "${HTTPS_PROXY}" == "" ]; then
      git config --global https.proxy "${HTTP_PROXY}"
    fi
  fi;

  # Dedicated proxy for HTTPS
  if [ "${HTTPS_PROXY}" != "" ]; then
    git config --global https.proxy "${HTTPS_PROXY}"
  fi
fi

#
# Use proxy to access docker container registries
#
if [ "$(which docker)" != "" ]; then
  if [ "$(which jq)" == "" ]; then
    echo "Warning: jq is required for docker proxy setup. Install with \"sudo apt install jq\"."
  else
    DOCKER_CONFIG="~/.docker/config.json"
    DOCKER_CONFIG_TMP=${DOCKER_CONFIG}.tmp

    # If no docker config is present, create an empty one.
    mkdir -p $(dirname ${DOCKER_CONFIG})
    if [ ! -e ${DOCKER_CONFIG} ]; then
      echo "{}" > ${DOCKER_CONFIG}
    fi

    # HTTP proxy
    if [ "${HTTP_PROXY}" != "" ]; then
      jq --indent 2 ".proxies.default.httpProxy = \"${HTTP_PROXY}\"" ${DOCKER_CONFIG} > ${DOCKER_CONFIG_TMP}
      mv ${DOCKER_CONFIG_TMP} ${DOCKER_CONFIG}

      # If no separate proxy is defined for HTTPS, use the HTTP proxy.
      if [ "${HTTPS_PROXY}" == "" ]; then
        jq --indent 2 ".proxies.default.httpsProxy = \"${HTTP_PROXY}\"" ${DOCKER_CONFIG} > ${DOCKER_CONFIG_TMP}
        mv ${DOCKER_CONFIG_TMP} ${DOCKER_CONFIG}
      fi
    fi;

    # Dedicated proxy for HTTPS
    if [ "${HTTPS_PROXY}" != "" ]; then
      jq --indent 2 ".proxies.default.httpsProxy = \"${HTTPS_PROXY}\"" ${DOCKER_CONFIG} > ${DOCKER_CONFIG_TMP}
      mv ${DOCKER_CONFIG_TMP} ${DOCKER_CONFIG}
    fi

    # Proxy exceptions
    if [ "${NO_PROXY}" != "" ]; then
      jq --indent 2 ".proxies.default.noProxy = \"${NO_PROXY}\"" ${DOCKER_CONFIG} > ${DOCKER_CONFIG_TMP}
      mv ${DOCKER_CONFIG_TMP} ${DOCKER_CONFIG}
    fi
  fi
fi
