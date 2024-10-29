# Using certbot with Red hat IDM

For self service certificate request we can use ACME (Automated Certificate Management Environment) to request a certificate from Red Hat IDM
and then use the certificate for our webserver

To set up ACME we will first install the Red Hat IDM server and then download the certbot client and using it to request a certificate

## Install Red Hat IDM 
In order to install the Red Hat IDM we first need to log into the IDM server and install the package.

Generate the FQDN for the server and make sure it is resolved :
```bash
$ echo '192.168.200.15   idm-server.example.com idm-server' | sudo tee -a /etc/hosts
``` 

### Client Side

Log in to Servera
```bash
$ ssh ec2-user@servera
```

In order to install certbot it's a very simple process (in a connected environment) All we need to do is to enable EPEL and then install the certbot package and update the server:
```bash
$ sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
$ sudo dnf update -y
```

Now let's install the certbot package :
```bash
$ sudo dnf install -y certbot
$ exit
```

### Server side
login to the Server
```bash
$ ssh ec2-user@idm-server
$ sudo su -
#
```

Now install the following packages :
```bash
# dnf install ipa-server ipa-server-dns -y
```

Once all the package are installed let's make sure the umask is in the right set of credentials as required :
```bash
# umask 0022
```

Now we are going to one line install the IDM server and setup the root and Directory manager password to 'RedH@T11!'\\
Run the following command in the IDM Server :
```bash
# ipa-server-install --realm EXAMPLE.LOCAL --ds-password 'RedH@t11!' --admin-password 'RedH@t11!' --unattended --setup-dns --forwarder 192.168.200.2 --no-reverse
```

Now we need to make sure the ACME is enabled :
```bash
#  ipa-acme-manage enable
```

Set ACME to automatically remove expired certificates from the CA: 
```bash
# ipa-acme-manage pruning --enable --cron "0 0 1 * *"
```

To check if the ACME service is installed and enabled, use the ipa-acme-manage status command: 
```bash
# ipa-acme-manage status
```

Add an A-record for the new site we want to enable SSL :
```bash
# kinit admin@EXAMPLE.LOCAL
# ipa dnsrecord-add example.local acme-test --a-rec 192.168.200.11
```

Now let's move back to servera :
```bash
# exit
$ exit
$ ssh ec2-user@servera
```
On servera switch to root
```bash
$ sudo su -
```

stop the httpd and run the following command :
```bash
# systemctl stop httpd
# certbot -vvv certonly -d acme-test.example.local --key-type rsa --standalone --server https://idm-server.example.local/acme/directory
```

Now create a new acme-test.conf in the /opt/conf directory with reference to the new certificates.

**NOTE**
Make sure you extract the CA and update the system with the IPA CA

Go back to the workstation and test the website:
```bash
# exit
$ exit
```

For testing the web Virtual host :
```bash
$ curl https://acme-test.example.local/
```

That's IT 
You are all Done !!!