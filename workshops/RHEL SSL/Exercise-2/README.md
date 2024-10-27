# SSLv3 Extensions

In This exercise we will use the SSLv3 extensions to create an MTLS Certificate.

In Order to create MTLS we will need 2 certificates , one for the Server (which we have created in our previews exercise) and one for the client which we will create now

If you not there , switch to our base directory 
```bash
$ cd $TLS_BASE/
```

## DNS Alter Name

From the previous exercise we create a TLS certificate for our HTTPD VirtualHost configuration and made sure the FQDN is not bigger then 64 bits.
with DNS alter name we don't have that problem so we will create a new certificate with the full FQDN of the long-cert (the default)

First let's generate a new answer file for our VirtulaHost:
```bash
$ export DOMAIN="${UUID}-very-long.apps.my-httpd-${UUID}.${UUID}.somedomain.letmethink.about.it"
$ export SHORT_NAME="tls-test"
```

Here is how the Answer file should look like :
```bash
$ cat > Afile/long-cert_csr.txt << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = req_ext
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=IL
ST=Center
L=TLV
O=BNHP
OU=IT
emailAddress=${USER}@localhost
CN = ${SHORT_NAME}

[ req_ext ]
nsCertType = server
nsComment="The long-cert certificate for VirtualHost"
subjectAltName = @alt_names
keyUsage=digitalSignature
extendedKeyUsage=serverAuth
basicConstraints=CA:FALSE
subjectKeyIdentifier=hash

[ alt_names ]
DNS.1 = ${SHORT_NAME}
DNS.2 = ${SHORT_NAME}.${DOMAIN}
EOF
```

Now Let's create the CSR :
```bash
$ openssl req -new -key Keys/tls-test.key -out CSR/long-cert.csr -config <( cat Afile/long-cert_csr.txt )
```

Now let's look at the request and find the Alter DNS names we configured :
```bash
$ openssl req -in CSR/long-cert.csr -noout -text | grep DNS
```

Now go ahead and sign the certificate :
```bash
$ openssl x509 -req -in CSR/long-cert.csr -CA CA/ca.crt -CAkey Keys/ca.key \
  -CAcreateserial -out Certs/long-cert.crt -days 730 -extensions 'req_ext' \
  -extfile <(cat Afile/long-cert_csr.txt)
```

And look at the new certificate for the DNS alter names :
```bash
$ openssl x509 -in Certs/long-cert.crt -text -noout | grep DNS
```
And Go over the full SSLv3 extensions :
```bash
$ openssl x509 -in Certs/long-cert.crt -text -noout | less
```

In both test cases you should see the 2 DNS alter names.

Copy the new Certificate to servera
```bash
$ scp Certs/long-cert.crt  ec2-user@servera:/opt/website1/ssl/
```

Now let's login back to servera and setup a new virtual domain 

```bash
$ ssh ec2-user@servera
```

Export the Domain variables once again :
```bash
$ export DOMAIN="${UUID}-very-long.apps.my-httpd-${UUID}.${UUID}.somedomain.letmethink.about.it"
$ export SHORT_NAME="tls-test"
```

Now Let's create a new VirtualHost with out new certificate :
```bash
$ echo "<VirtualHost ${SHORT_NAME}.${DOMAIN}:443>
    SSLEngine on
    SSLCertificateFile /opt/website1/ssl/long-cert.crt
    SSLCertificateKeyFile /opt/website1/ssl/tls-test.key
    SSLCACertificateFile /opt/website1/ssl/ca.crt
    ServerName ${SHORT_NAME}.${DOMAIN}
    DocumentRoot /opt/website1/html/
    <Directory /opt/website1/html/>
       DirectoryIndex index.html
       Require all granted
       Options Indexes   
    </Directory>
    ErrorLog /opt/website1/logs/error.log
    CustomLog /opt/website1/logs/access.log combined
</VirtualHost>" > /opt/conf/tls-long.conf
```

As before , we need to update our /etc/hosts file with the FQDN (Fully qualified Domain Name)
```bash
$ export IP_ADDR=$(ip addr show | grep 'inet ' | grep eth0 | awk '{print $2}' | awk -F \/ '{print $1}')
$ echo "${IP_ADDR}     ${SHORT_NAME}.${DOMAIN} ${SHORT_NAME}" | sudo tee -a /etc/hosts
```

Restart the httpd service with the added configuration : 
```bash
$ sudo systemctl reload httpd
```

Go back to your workstation
```bash
$ exit
```

**NOTE**
Make sure you have a name resolution for the FQDN !!!

Now let's run the curl just like in the previous exercise :
```bash
$ curl https://${SHORT_NAME}.${DOMAIN} ; echo
```

Great Job So far !!!

### Testing with openssl
If we want to see the server certificate (and CA in some cases) we can use openssl as a client.  
Run the following command :

```bash
$  echo quit | openssl s_client -showcerts -servername ${SHORT_NAME}.${DOMAIN} -connect ${SHORT_NAME}.${DOMAIN}:443 | less
```

As you can see we have obtain (In clear text) both the Sever and the CA certificates.

## Client Certificate (For MTLS)

### MTLS 

Mutual TLS, or mTLS for short, is a method for mutual authentication. mTLS ensures that the parties at each end of a network connection are who they claim to be by verifying that they both have the correct private key. The information within their respective TLS certificates provides additional verification.

mTLS is often used in a Zero Trust security framework* to verify users, devices, and servers within an organization. It can also help keep APIs secure.

- Zero Trust means that no user, device, or network traffic is trusted by default, an approach that helps eliminate many security vulnerabilities.

### Client CSR

We are going create the client certificate request using the SSLv3 extension option and we are going to create a new answer file for the client 

Create the Answer file with the following command :
```bash
$ cat > Afile/client_csr.txt << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = req_ext
req_extensions = req_ext
distinguished_name = dn

[ dn ]
O=clients
CN=${USER}.example.local

[ req_ext ]
nsCertType = client
basicConstraints=CA:FALSE
subjectKeyIdentifier=hash
extendedKeyUsage=clientAuth
EOF
```

First we will create a key for the client
```bash
$ openssl genrsa -out Keys/client.key 4096
```

Now let's create the CSR.
```bash
$  openssl req -new -key Keys/client.key -out CSR/client.csr -config <( cat Afile/client_csr.txt )
```
Let's make sure the SSLv3 extensions are in the request :
```bash
$ openssl req -in CSR/client.csr -noout -text | less
```

Use our CA to sign the client certificate as well.
```bash
$ openssl x509 -req -in CSR/client.csr -CA CA/ca.crt \
  -CAkey Keys/ca.key -CAcreateserial -out Certs/client.crt \
  -days 730 -extensions 'req_ext' -extfile <(cat Afile/client_csr.txt)
```

Now that we have everything in place we can Set up our website to enable MTLS.

### Server Side MTLS

We will update our website from Exercise 1 So it will only expect request which are using the Client Certificate.\\
\\
Login to servera
```bash
$ ssh ec2-user@servera
```

Before we change the configuration file we need to set the ALLOWED_USER variable
Base on the Client Certificate set the variable:
```bash
$ export ALLOWED_USER="<your answer>"
```
After the variable placement, we will update the website configuration file with the following content :

```bash
$ echo "<VirtualHost tls-test-${UUID}.example.local:443>
    SSLEngine on
    SSLCertificateFile /opt/website1/ssl/tls-test.crt
    SSLCertificateKeyFile /opt/website1/ssl/tls-test.key
    SSLCACertificateFile /opt/website1/ssl/ca.crt
    ServerName tls-test-${UUID}.example.local
    DocumentRoot /opt/website1/html/
    <Directory /opt/website1/html/>
       DirectoryIndex index.html
       Require all granted
       Options Indexes   
    </Directory>
    ErrorLog /opt/website1/logs/error.log
    CustomLog /opt/website1/logs/access.log combined   
    <Location />
       SSLVerifyClient require
       SSLVerifyDepth 1
       SSLOptions +StdEnvVars
       <RequireAny>
          Require expr %{SSL_CLIENT_S_DN_CN} == \"${ALLOWED_USER}\"
       </RequireAny>
    </Location>
</VirtualHost>" > /opt/conf/tls-test.conf
```
And restart the httpd service :
```bash
$ sudo systemctl reload httpd
``` 

Now exit and go back to the workstation :
```bash
$ exit
```

### Test the MTLS

export the following variables:
```bash
$ export DOMAIN="example.local"
$ export SHORT_NAME="tls-test-${UUID}"
```

We will use curl to run a test on our MTLS configuration

First run the curl without the client certificate
```bash
$ curl --cacert CA/ca.crt https://${SHORT_NAME}.${DOMAIN}
curl: (56) OpenSSL SSL_read: error:1409445C:SSL routines:ssl3_read_bytes:tlsv13 alert certificate required, errno 0
```

This error message is actually Good for us as it indicates that the client needs a certificate to identify itself

Now Let's run it with the client certificate 
```bash
$ curl --cacert CA/ca.crt --cert Certs/client.crt --key Keys/client.key https://${SHORT_NAME}.${DOMAIN}
```

If you see your index.html file that you are good to go !!!
```
<html>
<head>
<title>This is a simple SSL Test</title>
</head>
<body>
<p1>Simple SSL Test</p1>
</body>
</html>
```
If you want to go in to details about the MTLS negotiation you can add "vvv" arguments to the command :
```bash
$ curl -vvv --cacert CA/ca.crt --cert Certs/client.crt --key Keys/client.key https://${SHORT_NAME}.${DOMAIN}
```


## Testing our Certificate.
As noted before We can use openssl as our TLS client and retrieve the public certificate from the server with s_client option:

and run the following command :
```bash
$  echo quit | openssl s_client -showcerts -servername ${SHORT_NAME}.${DOMAIN} -connect ${SHORT_NAME}.${DOMAIN}:443 | less
```

Now That we have MTLS set up and running we have successfully completed The Exercise 

#### Good work !!!\\
You can now continue to configure MTLS