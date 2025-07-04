#!/usr/bin/env bash

# Configuration
STORAGE_BASE_DIRECTORY="/var/vmail/vmail1"
MYSQL_DB="vmail"
MYSQL_USER="root"
MYSQL_PASS="4hFBgy2QSW3Sv51RbwMIjG033Ny4qa08"  # ❗ Replace with a secure method

# Check input
if [ $# -ne 1 ]; then
    echo "Usage: $0 <email>"
    exit 1
fi

EMAIL=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# Skip postmaster (RFC required)
if [[ "$EMAIL" == postmaster@* ]]; then
    echo "⚠️  Skipping deletion of postmaster account: $EMAIL"
    exit 0
fi

# Extract username and domain
USERNAME=$(echo "$EMAIL" | cut -d@ -f1)
DOMAIN=$(echo "$EMAIL" | cut -d@ -f2)

# Fetch maildir path from DB
MAILDIR=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -s -N -e "SELECT maildir FROM mailbox WHERE username='$EMAIL';" "$MYSQL_DB")

if [ -z "$MAILDIR" ]; then
    echo "❌ User $EMAIL not found in database."
    exit 1
fi

# Delete from database
mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" "$MYSQL_DB" <<EOF
DELETE FROM mailbox WHERE username = '$EMAIL';
DELETE FROM forwardings WHERE address = '$EMAIL' OR forwarding = '$EMAIL';
EOF

if [ $? -ne 0 ]; then
    echo "❌ Failed to delete $EMAIL from database."
    exit 1
fi

# Delete maildir
MAILDIR_PATH="$STORAGE_BASE_DIRECTORY/$MAILDIR"
if [ -d "$MAILDIR_PATH" ]; then
    rm -rf "$MAILDIR_PATH"
    echo "🗑️  Deleted maildir: $MAILDIR_PATH"
else
    echo "ℹ️  Maildir not found: $MAILDIR_PATH"
fi

echo "✅ User $EMAIL fully deleted."
