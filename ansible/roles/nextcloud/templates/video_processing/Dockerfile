
FROM debian:bookworm-slim

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Set up a non-root user
RUN groupadd -r -g "{{ UID }}" www-data && \
    useradd -r -u "{{ GID }}" -G www-data -s /bin/bash www-data

# Install necessary packages for HTTPS and package verification
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        apt-transport-https \
        debian-keyring \
        && \
    rm -rf /var/lib/apt/lists/*

# Install ffmpeg and other required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        inotify-tools \
        && \
    rm -rf /var/lib/apt/lists/*

# Copy scripts
COPY "{{ PROCESS_VIDEO | basename }}" "{{ PROCESS_VIDEO }}"
RUN chmod +x "{{ PROCESS_VIDEO }}"

COPY "{{ CONTAINER_CMD | basename }}" "{{ CONTAINER_CMD }}"
RUN chmod +x "{{ CONTAINER_CMD }}"

# Switch to non-root user
USER www-data

CMD ["{{ CONTAINER_CMD }}"]
