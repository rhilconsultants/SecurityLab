# Using SSL/TLS with IPsec VPN

Today the very basic of securing your application is running it with a TLS encryption, the new ones.
Unfortunately , there are still a lot of old application in the organization that are running over clear text such as old Java application for API and in some cases even telnet in some FSI organization.

Luckily there is a very nice and easy fix which is to configure a VPN tunnel between the 2 server which enable the data to go through an encrypted tunnel.

## What do we need ?

In RHEL 9 there is a package called libreswan which we can use for the P2P VPN configuration.

**NOTE**
In some cases we can use the 2 servers as routers and then we can add a static route between 2 networks.

## Install libreswan

Before you can set a VPN through the Libreswan IPsec/IKE implementation, you must install the corresponding packages, start the ipsec service, and allow the service in your firewall. 

##### Prerequisites
- The AppStream repository is enabled. 

##### Procedure

1. Install the **libreswan** packages: 
```bash
$ sudo dnf install -y libreswan
```

2. Now that the application is installed we can use "openssl" to create a certificate for it and we\\
   will start by creating a private key : 
```bash
$ openssl genrsa -out Keys/ca-key.pem 4096
```
3. Now that we have a key we can create the CA and use the variables from the answer file to a single line :
```bash
$ openssl req -new -x509 -key Keys/ca-key.pem  \
  -days 730 -out CA/ca-crt.pem \
  -subj "/CN=IPSEC VPN/O=MY-COMP/C=IL/ST=Center/L=TLV" \
  -addext "keyUsage=digitalSignature" \
  -addext "basicConstraints=CA:TRUE"
```

4. Once we have a CA we can move to the server by creating a key to the server :
```bash
$ openssl genrsa -out Keys/server-key.pem 4096
```

5. And in the same way let's create the certificate for server which will also act as ac client certificate 
   First we will set the IP_ADDR variable again:
```bash
$ export IP_ADDR=$(ip addr show | grep 'inet ' | grep eth0 | awk '{print $2}' | awk -F \/ '{print $1}')
```
   And generate the CSR
```bash
$ openssl req -new -key Keys/server-key.pem -out CSR/server-csr.pem \
  -subj "/CN=servera.example.com/O=MY-COMP/C=IL/ST=Center/L=TLV" \
  -addext "keyUsage=digitalSignature" \
  -addext "nsCertType = server,client" \
  -addext "nsComment=The wildcard certificate for IPSEC VPN" \
  -addext "extendedKeyUsage=serverAuth,clientAuth" \
  -addext "basicConstraints=CA:FALSE" \
  -addext "subjectKeyIdentifier=hash" \
  -addext "subjectAltName = IP:${IP_ADDR}"
```

6. Before we continue , let's have a good look at our newly created CSR and specifically at our SSLv3 extensions :
```bash
$ openssl req -in CSR/server-csr.pem -text -noout | less
```

7. Now we can sign the CSR wit the CA and generate the server certificate :
```bash
$ openssl x509 -req -in CSR/server-csr.pem -CA CA/ca-crt.pem \
  -CAkey Keys/ca-key.pem -CAcreateserial -out Certs/servera.crt \
  -days 1825 -copy_extensions copyall
```
   Once the command is complete we can go over our new server certificate and make sure all the SSLv3 extensions are there :
```bash
$ openssl x509 -in Certs/servera.crt -text -noout | less
```


You have completed your Exercise !!!