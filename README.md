Here is the `README.md` content in Markdown format:

````markdown
# 📧 iRedMail Mail Server Setup – `mail.citricollab.com`

## 🚀 Automated Installation

Run the following command to automate the initial setup:

```bash
curl -sSL https://raw.githubusercontent.com/CyberITEX/cyberitex-flask-api/main/user-data/install.sh | bash -s -- root 8G mail.citricollab.com
````

---

## 🛠️ Manual Installation

### Step 1: Download and Extract iRedMail

```bash
cd /home
wget https://github.com/iredmail/iRedMail/archive/refs/tags/1.7.4.tar.gz
tar -xzf iRedMail-1.7.4.tar.gz
cd iRedMail-1.7.4/
sudo bash iRedMail.sh
```

### Step 2: Installation Prompts

During the iRedMail installer, follow these options:

* **Mail storage**: `/var/vmail`
* **Web server**: `Nginx`
* **Database**: `MariaDB` → Set root password
* **Mail domain**: `citricollab.com`
* **Postmaster email**: `postmaster@citricollab.com` → Set a password
* **Email services**: Select Roundcube, SOGo, etc. as desired

---

## 🔗 Web Interfaces After Installation

* 📬 **Roundcube Webmail**: [https://mail.citricollab.com/mail/](https://mail.citricollab.com/mail/)
* 📆 **SOGo Groupware** (if selected): [https://mail.citricollab.com/SOGo/](https://mail.citricollab.com/SOGo/)
* 📊 **Netdata Monitor**: [https://mail.citricollab.com/netdata/](https://mail.citricollab.com/netdata/)
* 🛠️ **iRedAdmin Web Panel**: [https://mail.citricollab.com/iredadmin/](https://mail.citricollab.com/iredadmin/)

> ⚠️ **Please reboot the system after installation:**

```bash
sudo reboot
```

---

## 👥 Mailbox Management Scripts

For mailbox automation (create, delete, bulk), use:

🔗 [iRedMail\_Account\_Management Scripts](https://github.com/ahmedali71x/iRedMail_Account_Management)

---

## 🔐 SSL Certificate Setup (Let’s Encrypt)

Install Certbot and request SSL certificates:

```bash
sudo apt install certbot python3-certbot-nginx -y

sudo certbot --nginx \
-d mail.citricollab.com \
-d autoconfig.citricollab.com \
-d autodiscover.citricollab.com \
-d webmail.citricollab.com
```

### 🔧 Nginx Configuration

Edit `/etc/nginx/sites-available/00-default-ssl.conf`:

```nginx
server_name mail.citricollab.com autoconfig.citricollab.com autodiscover.citricollab.com webmail.citricollab.com;
```

Replace self-signed certs with Let’s Encrypt certs:

```bash
sudo ln -sf /etc/letsencrypt/live/mail.citricollab.com/fullchain.pem /etc/ssl/certs/iRedMail.crt
sudo ln -sf /etc/letsencrypt/live/mail.citricollab.com/privkey.pem /etc/ssl/private/iRedMail.key
```

---

## ✉️ DKIM Setup

To generate DKIM DNS entry:

```bash
amavisd -c /etc/amavisd/amavisd.conf showkeys
```

* Copy the output and add it to your domain's DNS records via Cloudflare.

---

## 🧪 Mail Troubleshooting

### Check if services are running:

```bash
sudo systemctl status postfix
sudo systemctl status amavis
```

### Check mail logs:

```bash
tail -f /var/log/mail.log
```

---

✅ You’re all set to use your mail server!

```

Let me know if you want this saved as a downloadable `.md` file or want to include badge icons or additional features.
```
