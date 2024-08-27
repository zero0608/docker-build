#!/bin/bash

# Set default UID and GID if not provided
UID=${UID:-1000}
GID=${GID:-1000}

echo "Starting with UID: $UID and GID: $GID"

# Update group ID if the group exists
if getent group dev > /dev/null; then
    current_gid=$(getent group dev | cut -d: -f3)
    if [ "$current_gid" -ne "$GID" ]; then
        echo "Updating GID of 'dev' group from $current_gid to $GID"
        sudo groupmod --gid $GID dev || { echo "Failed to update GID"; exit 1; }
    else
        echo "Group 'dev' already has the correct GID"
    fi
else
    sudo groupadd --gid $GID dev || { echo "Failed to add group"; exit 1; }
fi

# Update user ID if the user exists
if id -u dev > /dev/null 2>&1; then
    current_uid=$(id -u dev)
    if [ "$current_uid" -ne "$UID" ]; then
        echo "Updating UID of 'dev' user from $current_uid to $UID"
        sudo usermod --uid $UID dev || { echo "Failed to update UID"; exit 1; }
        # Update ownership of files owned by old UID
        sudo find / -xdev -user $current_uid -exec chown -h $UID {} \;
    else
        echo "User 'dev' already has the correct UID"
    fi
else
    sudo useradd --uid $UID --gid $GID --shell /bin/bash --home /home/dev --create-home dev || { echo "Failed to add user"; exit 1; }
fi

# Set ownership and permissions for scripts if they exist
for file in /app/start.sh /app/stop.sh; do
    if [ -f "$file" ]; then
        sudo chown dev:dev "$file"
        sudo chmod +x "$file"
    fi
done

# Set ownership and permissions for the config directory if it exists
if [ -d "/app/config" ]; then
    sudo chown -R dev:dev /app/config
    sudo chmod -R 755 /app/config
fi

# Define directories for ownership changes
directories=(
    /app
    /usr/local/bundle
    /usr/local/rbenv
    /usr/local/bin
    /usr/local/lib
    /usr/local/include
    /usr/local/share
    /usr/local/n
)

# Create directories and set ownership
for dir in "${directories[@]}"; do
    # Create directory if it doesn't exist
    sudo mkdir -p "$dir"
    # Change ownership to 'dev:dev'
    sudo chown -R dev:dev "$dir"
done

# Set the home directory environment variable
export HOME=/home/dev

# Set up rbenv in bash sessions
if ! grep -q 'eval "$(rbenv init -)"' ${HOME}/.bashrc; then
    echo 'eval "$(rbenv init -)"' >> ${HOME}/.bashrc
fi

# Switch to dev user and run the command or shell
if [ -n "$1" ]; then
    exec sudo -E -u dev "$@"
else
    exec sudo -E -u dev /bin/bash
fi