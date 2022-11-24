# Generating end to end SSL certificates

In thie exercise we will Begin by generating the CA key and certificates files in an *old fasion" way and use those 2  
through the day.
In the next section we will create a certificate key followed by a certificste request. Next we will use our newly created CA  
to sign the request.  
## First Step
For the first step we will create a directory to store all the certificate files we are going to use.
```bash
$ mkdir TLS
$ export TLS_BASE="$HOME/TLS"
$ mkdir ${TLS_BASE}/CA ${TLS_BASE}/Certs ${TLS_BASE}/Keys ${TLS_BASE}/CSR
```
## Interactive
### Generate the CA certificate and Key

First go the TLS directory
```bash
$ cd $TLS_BASE/
```

We will start by creating the files we need for our CA. as a why of work we will always start with generate the RSA key with the length of 4096 (at the very list) .
Generate the Key:

```bash
$ openssl genrsa -out Keys/ca.key 4096
```

Next we will use the CA key we just created and the ca answer file to generate our CA certificate (that will be our public CA we will send to every machine that will want to connect to our registry over SSL.
Generate the CA

```bash
$ openssl req -new -x509 -key Keys/ca.key -days 730 -out CA/ca.crt
```

your command output should look as follow :
```bash 
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:IL
State or Province Name (full name) []:Center
Locality Name (eg, city) [Default City]:TLV
Organization Name (eg, company) [Default Company Ltd]:BNHP
Organizational Unit Name (eg, section) []:IT
Common Name (eg, your name or your server's hostname) []:ca-server
Email Address []: <your username>@localhost
```

Now we have a fully function CA in the certificate if valid for 730 ( 2 Years )

The ca.key is our "private" key and should not go anywhere (we can protect it with gpg encryption) and the ca.crt is our public file which we can use to verify the certificte

Let's go and have a look at our certificate :
```bash
$ openssl x509 -in CA/ca.crt -noout -text | egrep 'Not Before|Not After '
```

Run the same command with less instead of egrep to look at all the values :
```bash
$ openssl x509 -in CA/ca.crt -noout -text | less
```

### Generate a certificate request

To generate a certificate for the Server (of the client) we need to first create a private key for the server and then we will need a certificate request which the CA will generate the certificate based on that request 

Swith to the base directory

first let's generate the key

```bash
$ openssl genrsa -out Keys/tls-test.key 4096
```

**QUESTION**  

Why do we need a new key ?  

Now we will generate the certificate request using our newly created key!  
One step before we do that , let's set our route URL which we will use later on in our exercise
```bash
$ echo tls-test.${USER}-project.apps.cluster-${UUID}.${UUID}.${SANDBOX}
```

Copy the output as we will need it for our next command

```bash
$ openssl req -new -key Keys/tls-test.key -out CSR/tls-test.csr 
```

Your output should be as follow :
```bash
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:IL
State or Province Name (full name) []:Center
Locality Name (eg, city) [Default City]:TLV
Organization Name (eg, company) [Default Company Ltd]:BNHP
Organizational Unit Name (eg, section) []:IT
Common Name (eg, your name or your server's hostname) []:tls-test.ooichman-redhat.com-project.apps.cluster-2mn6p.2mn6p.sandbox2327.opentlc.com
string is too long, it needs to be no more than 64 bytes long
Common Name (eg, your name or your server's hostname) []:
CTRL+C
```

So we are getting an Error stating our common name is to long...  
We can fix that later but for now let's work with a shorter name :
```bash
$ echo "tls-test-${USER}.example.local"
```
**NOTE**  

Don't worry it is already in our /etc/hosts file 

Let's run the CSR command again :
```bash
$ openssl req -new -key Keys/tls-test.key -out CSR/tls-test.csr 
```

Your output should be as follow :
```bash
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:IL
State or Province Name (full name) []:Center
Locality Name (eg, city) [Default City]:TLV
Organization Name (eg, company) [Default Company Ltd]:BNHP
Organizational Unit Name (eg, section) []:IT
Common Name (eg, your name or your server's hostname) []:tls-test-<your user>.example.local
Email Address []:user1@localhost

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

Now Let's look at our newly created CSR
```bash
$ openssl req -in CSR/tls-test.csr -noout -text 
```
**NOTE**  

thre is no time piriod mentioning in the certificate, can you tell why ?

### signing the CSR

The following command is fairly simple , we are going to use our CA to sign the CSR and generate a certifcate from it :
```bash
$ openssl x509 -req -in CSR/tls-test.csr -CA CA/ca.crt -CAkey Keys/ca.key -CAcreateserial -out Certs/tls-test.crt -days 730
```

the output should look like this :
```bash
Signature ok
subject=C = IL, ST = Center, L = TLV, O = BNHP, OU = IT, CN = tls-test-user1.example.local, emailAddress = user1@localhost
Getting CA Private Key
```

Congratulations !!!  
You have justed created your first certificate 

Let's have a look at our new certificate :
```bash
$ openssl x509 -in Certs/tls-test.crt -noout -text | egrep 'Not Before|Not After '
```
Now that we know that it is valid , we can go over it for all the details :
```bash
$ openssl x509 -in Certs/tls-test.crt -noout -text | less
```
**Hint**  

Try to find our CN (Common name)

## noninteractive

Everything we have done so far can be done by using an answer file in order to automate the process if we need to.

First create a directory for the answer files
```bash
$ mkdir $TLS_BASE/AFile
```

### the Answer file
an OpenSSL answer file can provide answers to the generating of the CA , certificate request and the certificate so all the command will run in a noninteractive mode 

### the CA answer file

A CA answer file can look as follow :
```bash
$ cat > Afile/ca_answer.txt << EOF
[req]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn 
x509_extensions = usr_cert
[ dn ]
C=IL
ST=TLV
L=Center
O=BNHP
OU=IT
emailAddress=userX@localhost
CN = ca-server.example.com
[ usr_cert ]
basicConstraints=CA:TRUE
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer 
EOF
```
**NOTE**  

the answers defines a x509 extentions which we will touch late on , for now we are going to just place it here.

### Certificate Answer file 

For the certificate Answer file let's first define our CN 
```bash
$ export CERT_CN="tls-test-${USER}.example.local"
```

Now let's create the Answer File 
```bash
$ cat > Afile/tls_answer.txt << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = req_ext
req_extensions = req_ext
distinguished_name = dn
[ dn ]
C=US
ST=New York
L=New York
O=MyOrg
OU=MyOrgUnit
emailAddress=me@working.me
CN = ${CERT_CN}

[ req_ext ]
basicConstraints=CA:FALSE
subjectKeyIdentifier=hash
keyUsage=serverAuth
EOF
```

Now that we have answer files Let's recreate our certificates :

#### CA certificate :
```bash
$ openssl req -new -x509 -key Keys/ca.key -days 730 -out CA/ca.crt -config <( cat Afile/ca_answer.txt )
```

#### Certificate Request 
```bash
$ openssl req -new -key Keys/tls-test.key -out CSR/tls-test.csr -config <( cat Afile/tls_answer.txt )
```

### Signing the Certificate request
```bash
$ openssl x509 -req -in CSR/tls-test.csr -CA CA/ca.crt -CAkey Keys/ca.key \
  -CAcreateserial -out Certs/tls-test.crt -days 730 -extensions 'req_ext' \
  -extfile <(cat Afile/tls_answer.txt)
```

For the last step go ahaed and verify your certificate 
```bash
$ openssl verify -CAfile CA/ca.crt Certs/tls-test.crt
```
**Question**  

Why do we need to verify the certificate ?


You have completed your first Exercise!