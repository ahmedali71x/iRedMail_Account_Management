summarise this to readme.md file:
```javascript
 -sSL https://raw.githubusercontent.com/CyberITEX/cyberitex-flask-api/main/user-data/install.sh | bash -s -- root 8G mail.citricollab.com
```



```javascript
cd /home
wget https://github.com/iredmail/iRedMail/archive/refs/tags/1.7.4.tar.gz
tar -xzf iRedMail-1.7.4.tar.gz
cd iRedMail-1.7.4/
```

`sudo bash iRedMail.sh`

setup


1. /var/vmail
2. (\*) Nginx 
3. (\*) MariaDB >> setup DB root Password
4. First mail domain(part after @): `citricollab.com`
5. domain email: `postmaster@citricollab.com `>> Enter password
6. Select email services



After installed web URLs :

 \* - Roundcube webmail: https://mail.citricollab.com/mail/ 

\* - SOGo groupware: https://mail.citricollab.com/SOGo/  (if selected during installation)

\* - netdata (monitor): https://mail.citricollab.com/netdata/ \* 

\* - Web admin panel (iRedAdmin): https://mail.citricollab.com/iredadmin/   

### **Please ==reboot== your system to enable all mail services.**

Sudo Reboot


Scripts to create mailbox, delete mailbox, bulk create, bulk delete

<https://github.com/ahmedali71x/iRedMail_Account_Management>


### Certified Setup

```javascript
Setup the email certificate

sudo apt install certbot python3-certbot-nginx -y

sudo certbot --nginx \
-d mail.citricollab.com \
-d autoconfig.citricollab.com \
-d autodiscover.citricollab.com \
-d webmail.citricollab.com
```

* /etc/nginx/sites-available/00-default-ssl.conf
* add : server_name mail.citricollab.com autoconfig.citricollab.com autodiscover.citricollab.com webmail.citricollab.com;


* add symbolic link to replace the self-signed certificates as it is not secure
* sudo ln -sf /etc/letsencrypt/live/mail.citricollab.com/fullchain.pem /etc/ssl/certs/iRedMail.crt sudo ln -sf /etc/letsencrypt/live/mail.citricollab.com/privkey.pem /etc/ssl/private/iRedMail.key



DKIM Setup


1. `amavisd -c /etc/amavisd/amavisd.conf showkeys`
2. Change the output format to match dkim DNS record


Mail troubleshooting if mail not sent


1. check service status for postfix and amavis, should be running
2. Check mail logs after sending email: /var/log/mail.log 
