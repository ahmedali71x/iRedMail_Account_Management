Thanks for sharing the DNS records screenshot from Cloudflare. Based on it, I’ll guide you on how to script adding **all of these records** using Cloudflare's API and a bash script.

---

### ✅ Requirements

1. Cloudflare **API Token** with `DNS:Edit` permission
2. Your **Zone ID**
3. Install `curl` and `jq`

---

### 📜 Bash Script to Add All Records

Here’s a ready-made bash script that you can adapt:

```bash
#!/bin/bash

CF_API_TOKEN="YOUR_API_TOKEN"
ZONE_ID="YOUR_ZONE_ID"

# Function to create a DNS record
create_record() {
  TYPE=$1
  NAME=$2
  CONTENT=$3
  TTL=$4
  PROXIED=$5

  curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{
      "type": "'"$TYPE"'",
      "name": "'"$NAME"'",
      "content": "'"$CONTENT"'",
      "ttl": '"$TTL"',
      "proxied": '"$PROXIED"'
    }' | jq
}

# A records
create_record "A" "mail.citricollab.com" "91.99.226.44" 1 false
create_record "A" "www.citricollab.com" "74.208.75.213" 1 true

# AAAA
create_record "AAAA" "citricollab.com" "2607:f1c0:f084:7b00::1" 1 true

# CNAMEs
create_record "CNAME" "autoconfig.citricollab.com" "mail.citricollab.com" 1 false
create_record "CNAME" "autodiscover.citricollab.com" "mail.citricollab.com" 1 false
create_record "CNAME" "imap.citricollab.com" "mail.citricollab.com" 1 false
create_record "CNAME" "smtp.citricollab.com" "mail.citricollab.com" 1 false
create_record "CNAME" "webmail.citricollab.com" "mail.citricollab.com" 1 false

# MX
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "MX",
    "name": "citricollab.com",
    "content": "mail.citricollab.com",
    "priority": 10,
    "ttl": 1
  }' | jq

# SRV Records (must use a different endpoint format)
# For simplicity, these can be added manually unless you want an extended version

# TXT Records
create_record "TXT" "_acme-challenge.citricollab.com" "KLGzdaHalxQiQ_iQCXyjjUXik...." 1 false
create_record "TXT" "_autodiscover._tcp.citricollab.com" "\"v=autodiscover1\"" 1 false
create_record "TXT" "citricollab.com" "\"v=spf1 mx ip4:91.99.226.44 ~all\"" 1 false
create_record "TXT" "dkim._domainkey.citricollab.com" "\"v=DKIM1; p=MIIBIjANBgkqhkiG...\"" 1 false
create_record "TXT" "_dmarc.citricollab.com" "\"v=DMARC1; p=quarantine; rua=mailto:...\"" 1 false
```

---

### 📌 Notes

* `TTL = 1` → means **Auto**
* `proxied = true` only for www and AAAA (from your screenshot)
* SRV records are trickier because they have multiple fields (can provide another script if needed)
* `jq` is used for pretty-printing the JSON response; install it using `sudo apt install jq`

---

### ▶️ Run the Script

1. Save as `add_cf_records.sh`
2. Make executable:

```bash
chmod +x add_cf_records.sh
./add_cf_records.sh
```

---

Would you like me to also script the **SRV records** portion for you?
