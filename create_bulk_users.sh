#!/usr/bin/env bash

# Configuration
STORAGE_BASE_DIRECTORY="/var/vmail/vmail1"
PASSWORD_SCHEME="SSHA512"
DEFAULT_QUOTA="0"
MAILDIR_STYLE="hashed"
MYSQL_DB="vmail"
MYSQL_USER="root"
MYSQL_PASS="YourMySQLRootPassword"  # ❗ Replace securely

# Check for CSV filepath
if [ $# -ne 1 ]; then
    echo "Usage: $0 <csv_file>"
    echo "CSV format: email,password"
    exit 1
fi

CSV_FILE="$1"

if [ ! -f "$CSV_FILE" ]; then
    echo "❌ File not found: $CSV_FILE"
    exit 1
fi

# Read CSV line by line
while IFS=',' read -r EMAIL PASSWORD; do
    EMAIL=$(echo "$EMAIL" | tr '[:upper:]' '[:lower:]' | xargs)
    PASSWORD=$(echo "$PASSWORD" | xargs)

    # Skip header or blank lines
    [[ "$EMAIL" == "username" || -z "$EMAIL" || -z "$PASSWORD" ]] && continue

    # Skip postmaster
    if [[ "$EMAIL" == postmaster@* ]]; then
        echo "⚠️  Skipping postmaster: $EMAIL"
        continue
    fi

    # Check if user exists
    USER_EXISTS=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -s -N -e "SELECT COUNT(*) FROM mailbox WHERE username='$EMAIL';" "$MYSQL_DB")
    if [ "$USER_EXISTS" -gt 0 ]; then
        echo "⚠️  Skipping existing user: $EMAIL"
        continue
    fi

    # Prepare user info
    USERNAME=$(echo "$EMAIL" | cut -d@ -f1)
    DOMAIN=$(echo "$EMAIL" | cut -d@ -f2)
    DATE=$(date +%Y.%m.%d.%H.%M.%S)
    HASHED_PASS=$(doveadm pw -s "$PASSWORD_SCHEME" -p "$PASSWORD")

    if [ "$MAILDIR_STYLE" == "hashed" ]; then
        str1="${USERNAME:0:1}"
        str2="${USERNAME:1:1}"
        str3="${USERNAME:2:1}"
        str2=${str2:-$str1}
        str3=${str3:-$str2}
        MAILDIR="$DOMAIN/$str1/$str2/$str3/${USERNAME}-${DATE}/"
    else
        MAILDIR="$DOMAIN/${USERNAME}-${DATE}/"
    fi

    MAILDIR_PATH="$STORAGE_BASE_DIRECTORY/$MAILDIR"

    # SQL
    SQL=$(cat <<EOF
INSERT INTO mailbox (username, password, name, storagebasedirectory, storagenode, maildir, quota, domain, active, passwordlastchange, created)
VALUES ('$EMAIL', '$HASHED_PASS', '$USERNAME', '$(dirname $STORAGE_BASE_DIRECTORY)', '$(basename $STORAGE_BASE_DIRECTORY)', '$MAILDIR', '$DEFAULT_QUOTA', '$DOMAIN', 1, NOW(), NOW());

INSERT INTO forwardings (address, forwarding, domain, dest_domain, is_forwarding)
VALUES ('$EMAIL', '$EMAIL', '$DOMAIN', '$DOMAIN', 1);
EOF
    )

    echo "$SQL" | mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" "$MYSQL_DB"

    if [ $? -eq 0 ]; then
        mkdir -p "$MAILDIR_PATH"/{cur,new,tmp}
        chown -R vmail:vmail "$STORAGE_BASE_DIRECTORY/$DOMAIN/"
        chmod -R 0700 "$STORAGE_BASE_DIRECTORY/$DOMAIN/"
        echo "✅ Created user: $EMAIL"
    else
        echo "❌ Failed to create user: $EMAIL"
    fi

done < "$CSV_FILE"
