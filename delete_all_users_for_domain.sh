#!/usr/bin/env bash

# Configuration
STORAGE_BASE_DIRECTORY="/var/vmail/vmail1"
MYSQL_DB="vmail"
MYSQL_USER="root"
MYSQL_PASS="4hFBgy2QSW3Sv51RbwMIjG033Ny4qa08"  # ❗ Replace or load securely

# Check input
if [ $# -ne 1 ]; then
    echo "Usage: $0 <domain>"
    echo "Example: $0 citricollab.com"
    exit 1
fi

DOMAIN=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# Get all users for the domain except postmaster
EMAILS=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -s -N -e \
  "SELECT username, maildir FROM mailbox WHERE domain='$DOMAIN' AND username != 'postmaster@$DOMAIN';" "$MYSQL_DB")

if [ -z "$EMAILS" ]; then
    echo "ℹ️  No non-postmaster users found under domain: $DOMAIN"
    exit 0
fi

# Loop over each user and delete
echo "$EMAILS" | while read -r EMAIL MAILDIR; do
    echo "🔹 Deleting user: $EMAIL"

    # Remove from database
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" "$MYSQL_DB" <<EOF
DELETE FROM mailbox WHERE username = '$EMAIL';
DELETE FROM forwardings WHERE address = '$EMAIL' OR forwarding = '$EMAIL';
EOF

    # Remove maildir
    if [ -n "$MAILDIR" ]; then
        MAILDIR_PATH="$STORAGE_BASE_DIRECTORY/$MAILDIR"
        if [ -d "$MAILDIR_PATH" ]; then
            rm -rf "$MAILDIR_PATH"
            echo "🗑️  Deleted maildir: $MAILDIR_PATH"
        else
            echo "⚠️  Maildir not found: $MAILDIR_PATH"
        fi
    fi

    echo "✅ Deleted user: $EMAIL"
done

echo "🎯 All users under $DOMAIN (except postmaster) have been deleted."
