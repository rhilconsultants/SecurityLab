# Using HAproxy with wildcard SSL/TLS

Today the very basic of securing your application is running it with a TLS encryption, the new ones.
Unfortunately , there are still a lot of old application in the organization that are running over clear text such as old Java application for API and in some cases even telnet in some FSI organization.

Luckily there is a very nice and easy fix which is to configure a front end application as a reverse proxy  which enable the data to go through an encrypted tunnel for the end users.

## What do we need ?

In RHEL 9 there is a package called haproxy which we can use as an reverse proxy .

**NOTE**
In some cases we can install the package directly on the server but If it's not possible we can use an haproxy container or install it on another server and us stunnel for secure data transfer.

## What is a wildcard certificate
A wildcard certificate is a catch all certificate per domain which can be use full if we need one certificate for multiple websites

Make sure we are in the right working directory
```bash
$ cd ~/TLS/
```

## Configure SSL/VPN wildcard certificates

1. Now that the application is installed we can use "openssl" to create a certificate for it and we\\
   will start by creating a private key : 
```bash
$ openssl genrsa -out Keys/ca-key.pem 4096
```
2. Now that we have a key we can create the CA and use the variables from the answer file to a single line :
```bash
$ openssl req -new -x509 -key Keys/ca-key.pem  \
  -days 730 -out CA/ca-crt.pem \
  -subj "/CN=HAproxy CA/O=MY-COMP/C=IL/ST=Center/L=TLV" \
  -addext "basicConstraints=CA:TRUE"
```

3. Once we have a CA we can move to the server by creating a key to the server :
```bash
$ openssl genrsa -out Keys/serverb-key.pem 4096
```

4. And in the same way let's create the certificate for server which will also act as ac client certificate 
   First we will set the IP_ADDR variable again:
```bash
$ export IP_ADDR=$(ssh ec2-user@serverb "ip addr show" | grep 'inet ' | grep eth0 | awk '{print $2}' | awk -F \/ '{print $1}') 
```
   And generate the CSR
```bash
$ openssl req -new -key Keys/serverb-key.pem -out CSR/serverb-csr.pem \
  -subj "/CN=*.example.local/O=MY-COMP/C=IL/ST=Center/L=TLV" \
  -addext "keyUsage=digitalSignature" \
  -addext "nsCertType = server" \
  -addext "nsComment=The wildcard certificate for HAproxy" \
  -addext "extendedKeyUsage=serverAuth" \
  -addext "basicConstraints=CA:FALSE" \
  -addext "subjectKeyIdentifier=hash" \
  -addext "subjectAltName = IP:${IP_ADDR},DNS:*.example.local"
```
Not that we have added the FQDN in 2 places , in the Command name (E.G CN ) and in the DNS alter name

5. Before we continue , let's have a good look at our newly created CSR and specifically at our SSLv3 extensions :
```bash
$ openssl req -in CSR/serverb-csr.pem -text -noout | less
```

6. Now we can sign the CSR wit the CA and generate the server certificate :
```bash
$ openssl x509 -req -in CSR/serverb-csr.pem -CA CA/ca-crt.pem \
  -CAkey Keys/ca-key.pem -CAcreateserial -out Certs/serverb.crt \
  -days 1825 -copy_extensions copyall
```
   Once the command is complete we can go over our new server certificate and make sure all the SSLv3 extensions are there :
```bash
$ openssl x509 -in Certs/serverb.crt -text -noout | less
```

7. Copy all the Certificates to serverb
```bash
$ scp CA/ca-crt.pem Certs/serverb.crt Keys/serverb-key.pem ec2-user@serverb:~
```
## Configure insecure VirtualHost

To setup an insecure http web virtual host we need to login back to servera and setup everything

Login to servera
```bash
$ ssh ec2-user@servera
```

Make sure we can resolve the FQDN locally
```bash
$ echo "192.168.200.11  notls-test-${UUID}.example.local notls-test-${UUID}" | sudo tee -a /etc/hosts
```

Making a new directory for the new website
```bash
$ sudo mkdir /opt/website2
$ sudo mkdir /opt/website2/{html,logs}
$ sudo setfacl -R -m user:ec2-user:rwx /opt/website2
```

Now let's create a new Hello file :
```bash
$ echo '<html>
<head>
<title>This is a simple no SSL Test</title>
</head>
<body>
<p1>Simple None SSL Test</p1>
</body>
</html>' > /opt/website2/html/index.html
```

Make sure SElinux is set 
```bash
$ sudo semanage fcontext -a -t httpd_sys_content_t "/opt/website2(/.*)?"
$ sudo semanage fcontext -a -t httpd_log_t "/opt/website2/logs(/.*)?"
$ sudo restorecon -R -v /opt/
```

And add the following configuration to our HTTP server :
```bash
$ echo "<VirtualHost notls-test-${UUID}.example.local:80>
    ServerName notls-test-${UUID}.example.local
    DocumentRoot /opt/website2/html/
    <Directory /opt/website2/html/>
       DirectoryIndex index.html
       Require all granted
       Options Indexes   
    </Directory>
    ErrorLog /opt/website2/logs/error.log
    CustomLog /opt/website2/logs/access.log combined
</VirtualHost>" > /opt/conf/notls-test.conf
```

Restart the HTTPD service 
```bash
$ sudo systemctl restart httpd
```

Logout from servera and update the hosts file
```bash
$ exit
$ echo "192.168.200.11  notls-test-${UUID}.example.local notls-test-${UUID}" | sudo tee -a /etc/hosts
```

Now we need to test the website before we continue :
```bash
$ curl http://notls-test-4qrbh.example.local/
```

Now that we have an insecure website , let's make it secure with HAproxy as a frontend

## Install haproxy

In order to install the haproxy package all we need to do is run the dnf command and then add the relevant ports in firewalld.\
In regards to SElinux we can use the auditd logs to create an SElinux module and then apply it to our system  

##### Prerequisites
- The AppStream repository is enabled. 

### Procedure

1. Login in to serverb
 
```bash
$ ssh ec2-user@serverb
```

And switch to root and set the UUID
```bash
$ sudo su -
# export UUID="< your UUID>"
```

Modify the /etc/hosts file
```bash
# echo "192.168.200.11  notls-test-${UUID}.example.local notls-test-${UUID}" | tee -a /etc/hosts
```

2. Install the **haproxy** packages:
```bash
# dnf install -y haproxy policycoreutils-python-utils
```
Once the package is installed we can start by setting up the HAproxy configuration file 

3. Setting the SElinux to Permissive so we can catch all the ports and files needed 
```bash
# setenforce 0
```

4. Configure the global configuration of the HAproxy. the global configuration tells HAproxy how to address all the front end and the back and what type of protocol to use.\
The following global configuration should be at the top of the file :
```bash
# cat > /etc/haproxy/haproxy.cfg << EOF
# Global settings
#-----------------------------------------------------------------
global
    maxconn     20000
    log         /dev/log local0 info
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    user        haproxy
    group       haproxy
    daemon
    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats
#------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#-------------------------------------------------------------------

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          300s
    timeout server          300s
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 20000

listen stats
    bind :9000
    mode http
    stats enable
    stats uri /
EOF
```


5. FrontEnd with ACL
In our case we are using HAproxy for multiple websites (hence the wildcard certificate) we need to set the HAproxy with an ACL to redirect each website to the right URL.

We first need to create a directory to hold the certificate and then create a certificate which is a combination of the certificate and key
```bash
# mkdir /etc/haproxy/certs.d/
# cat /home/ec2-user/serverb.crt /home/ec2-user/ca-crt.pem /home/ec2-user/serverb-key.pem > /etc/haproxy/certs.d/wildcard.example.com.crt
```

Now with your favorite editor add the following part : \\
Our FrontEnd should look as follow :
```
frontend  tls-frontend
    bind *:443 ssl crt /etc/haproxy/certs.d/wildcard.example.com.crt no-sslv3 
    mode http
    option httplog    
    option http-server-close
    option forwardfor
    use_backend %[req.hdr(Host),lower]
```

6. **BackEnd for our websites**

For our BackEnd we will need to set the BackEnd name as the URL we want to redirect to :
```bash
# cat >> /etc/haproxy/haproxy.cfg << EOF
backend notls-test-${UUID}.example.local
  balance roundrobin
  server servera notls-test-${UUID}.example.local:80 check
EOF
```

7. Start the HAproxy and setup the SElinux

First start the HAproxy
```bash
# systemctl start haproxy
```

Now Let's set the SElinux with audit2allow command :
```bash
# grep haproxy /var/log/audit/audit.log | audit2allow -M my_haproxy
# semodule -i my_haproxy
# setenforce 1
```

**NOTE**
IF there is no putput from the audit2allow command it means there is no need to modify any SElinux rule.

8. Go back to our workstation and modify the IP address of the notls-test website from servera to serverb :
```bash
# exit
$ exit
```

On the workstation , go ahead and change the website IP address to point the serverb:
```bash
$ sudo sed -i  's/11  notls-test/12  notls-test/' /etc/hosts
```

and run the final test :
```bash
$ curl --cacert CA/ca-crt.pem https://notls-test-${UUID}.example.local/
<html>
<head>
<title>This is a simple no SSL Test</title>
</head>
<body>
<p1>Simple None SSL Test</p1>
</body>
</html>
```

## On your own

1. modify the workstation system with the new CA
2. On servera change the index.html file to say "Simple HAproxy SSL test"
3. Modify the haproxy.conf on serverb to redirect to the website on IP address URL request


In a real world scenario we will Install the haproxy on the webserver host to make sure no one could "sniff" the traffic between the 2 servers.

## Good Work
You have completed your Exercise !!!