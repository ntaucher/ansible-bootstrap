#!/bin/bash

# --- Script to create a new user for Ansible ---

# --- Variables ---
# Set the username for the new user
NEW_USER="ansible"

# Set the public SSH key for the new user
# IMPORTANT: Replace the placeholder with the actual public key
SSH_PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILwDUPCNDt/4fXHWjw7UK3S+D+gir1wFVnEQvnspsiTY ntaucher@gmail.com"

# --- Script Execution ---

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Create the new user
if getent passwd "$NEW_USER" &>/dev/null; then
  echo "User '$NEW_USER' already exists."
else
  useradd -m -s /bin/bash "$NEW_USER"
  echo "User '$NEW_USER' created."
fi

# --- GRANT SUDO PERMISSIONS VIA SUDOERS.D ---
# Create a new sudoers file for the ansible user
# This grants passwordless sudo privileges
SUDOERS_FILE="/etc/sudoers.d/$NEW_USER"
echo "$NEW_USER ALL=(ALL) NOPASSWD: ALL" > "$SUDOERS_FILE"
echo "Created sudoers file at $SUDOERS_FILE."

# Set the correct permissions for the sudoers file.
# This is critical for security.
chmod 0440 "$SUDOERS_FILE"
echo "Set permissions for $SUDOERS_FILE to 0440."
# --- END SUDO PERMISSIONS SECTION ---

# Create the .ssh directory and authorized_keys file
HOME_DIR=$(eval echo ~$NEW_USER)
SSH_DIR="$HOME_DIR/.ssh"
AUTHORIZED_KEYS_FILE="$SSH_DIR/authorized_keys"

mkdir -p "$SSH_DIR"
touch "$AUTHORIZED_KEYS_FILE"

# Add the public key to the authorized_keys file
echo "$SSH_PUBLIC_KEY" >> "$AUTHORIZED_KEYS_FILE"
echo "Public key added to $AUTHORIZED_KEYS_FILE."

# Set the correct permissions
chown -R "$NEW_USER":"$NEW_USER" "$SSH_DIR"
chmod 700 "$SSH_DIR"
chmod 600 "$AUTHORIZED_KEYS_FILE"

echo "Permissions set for '$NEW_USER'."

echo "Ansible user '$NEW_USER' created successfully."

