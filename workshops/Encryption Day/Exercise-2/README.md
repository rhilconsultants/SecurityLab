# SSL v3 Externtions

In This exercise we will use the SSLv3 extentions to create an MTLS Certificate.

In Order to create MTLS we will need 2 certificates , one for the Server (which we have created in our previus exercise) and one for the client which we will create now

If you not there , switch to our base directory 
```bash
$ cd $TLS_BASE/
```

## DNS Alter Name

From the previus exercise we create a TLS certificte to different route then we are getting from the wildcard due to FQDN bigger then 64 bits.
with DNS alter name we don't have that problem so we will create a new certificate with the full FQDN of the wildcard (the default)

First let's delete the old route
```bash
$ oc delete route monkey-app
```

Now we will generate a new answer file for our new route:
```bash
$ export DOMAIN="apps.cluster-${UUID}.${UUID}.${SANDBOX}"
$ export SHORT_NAME="monkey-app-${USER}-project"
```

Here is how the Answer file should look like :
```bash
$ cat > Afile/wildcard_csr.txt << EOF
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
nsComment="The wildcard certificate for monkey-app"
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
$ openssl req -new -key Keys/tls-test.key -out CSR/wildcard.csr -config <( cat Afile/wildcard_csr.txt )
```

Now let's look at the request and find the Alter DNS names we configured :
```bash
$ openssl req -in CSR/wildcard.csr -noout -text | grep DNS
```

Now go ahead and sign the certificate :
```bash
$ openssl x509 -req -in CSR/wildcard.csr -CA CA/ca.crt -CAkey Keys/ca.key \
  -CAcreateserial -out Certs/wildcard.crt -days 730 -extensions 'req_ext' \
  -extfile <(cat Afile/wildcard_csr.txt)
```

And look at the new certificate for the DNS alter names :
```bash
$ openssl x509 -in Certs/wildcard.crt -text -noout | grep DNS
```
And Go over the full SSLv3 extensions :
```bash
$ openssl x509 -in Certs/wildcard.crt -text -noout | less
```

In both test cases you should see the 2 DNS alter names.

Let's recreate the route with the new wildcard certificate :
```bash
$ oc create route edge monkey-app --service=monkey-app \
  --cert=Certs/wildcard.crt --key=Keys/tls-test.key \
  --ca-cert=CA/ca.crt --insecure-policy=Redirect \
  --port=8080 
```

get the route 
```bash
$ export ROUTE=$(oc get route monkey-app -o jsonpath='{.spec.host}')
```

and run the curl just like in the previus exercise :
```bash
$ curl -H "Content-Type: application/json" --cacert CA/ca.crt https://${ROUTE}/api/?says=banana ; echo
{
  "result": "Success",
  "message": "Monkey says: banana"
}
```

Great Job So far

## Client Certificate (For MTLS)

### Client CSR

We are going create the client certificate request using the SSLv3 extention option and we are going to create a new answer file for the client 

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
$ openssl x509 -req -in CSR/client.csr -CA CA/ca.crt -CAkey Keys/ca.key -CAcreateserial -out Certs/client.crt -days 730 -extensions 'req_ext' -extfile <(cat Afile/client_csr.txt)
```

Now that we have everything in place we can run a few test.

## On OpenShift

In order to test our new configraion we will setup an httpd Container , instruct in to use TLS and create an MTLS configuration to check
the CN of the client certificate :

### Create the Container

Create a new directory :
```bash
$ mkdir $TLS_BASE/Container && cd $TLS_BASE/Container
```

create a file called ssl.conf with the follwoing content :
```bash
$ cat > ssl.conf << EOF
Listen 443 https


SSLPassPhraseDialog exec:/usr/libexec/httpd-ssl-pass-dialog

SSLSessionCache         shmcb:/run/httpd/sslcache(512000)
SSLSessionCacheTimeout  300

SSLRandomSeed startup file:/dev/urandom  256
SSLRandomSeed connect builtin

SSLCryptoDevice builtin
EOF
```

and a simple index.html file
```bash
$ cat > index.html << EOF
<html>
<head>
<title> this is a test </title>
<body>
<p> this is the ${USER} page </p>
</body>
</html>
EOF
```

Create a Dockerfile which the following content :
```bash
$ cat > Dockerfile << EOF
FROM centos:stream8
MAINTAINER ${USER} <apache SSL>
RUN dnf install -y httpd mod_ssl 
COPY run-httpd.sh /usr/sbin/run-httpd.sh
COPY ssl.conf /etc/httpd/conf.d/ssl.conf 

RUN echo "PidFile /tmp/http.pid" >> /etc/httpd/conf/httpd.conf
RUN sed -i "s/Listen\ 80/Listen\ 8080/g"  /etc/httpd/conf/httpd.conf
RUN sed -i "s/Listen\ 443/Listen\ 8443/g" /etc/httpd/conf.d/ssl.conf 
RUN sed -i "s/\"logs\/error_log\"/\/dev\/stderr/g" /etc/httpd/conf/httpd.conf
RUN sed -i "s/CustomLog \"logs\/access_log\"/CustomLog \/dev\/stdout/g" /etc/httpd/conf/httpd.conf

RUN echo 'IncludeOptional /opt/app-root/*.conf' >> /etc/httpd/conf/httpd.conf
RUN mkdir /opt/app-root/ && \
    chown apache:apache /opt/app-root/ && \
    chmod 777 /opt/app-root/ && \
    chmod a+x /usr/sbin/run-httpd.sh

COPY index.html /opt/app-root/

USER apache

EXPOSE 8080 8443
ENTRYPOINT ["/usr/sbin/run-httpd.sh"]
EOF
```

Now we need to create a configuration file which enables the modules we just installed but we need to it when the Service starts.
The best way to do that is to create a startup scripts which generate the configuration file.

Let’s generate the the “run-httpd.sh” script :

```bash
$ echo '#!/bin/bash

if [ -z ${SSL_CERT} ]; then
        echo "Environment variable SSL_CERT undefined"
        exit 1
elif [[ -z ${SSL_KEY} ]]; then
        echo "Environment variable SSL_KEY undefined"
        exit 1
elif [[ -z ${CA_CERT} ]]; then
        echo "Environment variable CA_CERT undefined"
        exit 1
elif [[ -z ${ALLOWED_USER} ]]; then
        echo "Environment variable ALLOWED_USER undefined"
        exit 1
fi

echo "
<VirtualHost *:8443>
        DocumentRoot /opt/app-root
        SSLEngine on
        SSLCertificateFile ${SSL_CERT}
        SSLCertificateKeyFile ${SSL_KEY}
        SSLCACertificateFile ${CA_CERT}
        <Directory "/opt/app-root/">
                AllowOverride All
                Options +Indexes
                DirectoryIndex index.html
        </Directory>        
        <Location />
        SSLVerifyClient require
        SSLVerifyDepth 1
        SSLOptions +StdEnvVars
        <RequireAny>
           Require expr %{SSL_CLIENT_S_DN_CN} == \"${ALLOWED_USER}\"
        </RequireAny>
        </Location>
</VirtualHost>
" > /tmp/reverse.conf
mv /tmp/reverse.conf /opt/app-root/reverse.conf
/usr/sbin/httpd $OPTIONS -DFOREGROUND' > run-httpd.sh
```

Now we can build the image

```bash
$ buildah bud -f Dockerfile -t httpd-mtls
```

Login to OpenShift's internal registry :
```bash
$ export REGISTRY="default-route-openshift-image-registry.apps.cluster-${UUID}.${UUID}.${SANDBOX}"
$ podman login -u $(oc whoami) -p $(oc whoami -t) ${REGISTRY}
```

Now push the image to the registry :
```bash
$ podman tag httpd-mtls ${REGISTRY}/$USER-project/httpd-mtls
$ podman push ${REGISTRY}/$USER-project/httpd-mtls
```

Grep the the internal registry referance from the imagestream:
```bash
$ export IMAGE_REF=$(oc get imagestream httpd-mtls -o jsonpath='{.status.dockerImageRepository}')
```

Now Let's create our CA as a configMap :
```bash
$ cd $TLS_BASE
$ oc create cm ca-cert --from-file=ca.crt=CA/ca.crt 
```

And generate a new certificate for our httpd route (this time the route will be passthrough)

```bash
$ export DOMAIN="apps.cluster-${UUID}.${UUID}.${SANDBOX}"
$ export SHORT_NAME="httpd-mtls-${USER}-project"
```

Here is how the Answer file should look like :
```bash
$ cat > Afile/httpd-mtls_csr.txt << EOF
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
nsComment="The wildcard certificate for monkey-app"
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

Create a new key
```bash
$ openssl genrsa -out Keys/httpd-mtls.key 4096
```

Now Let's create the CSR :
```bash
$ openssl req -new -key Keys/httpd-mtls.key -out CSR/httpd-mtls.csr -config <( cat Afile/httpd-mtls_csr.txt )
```

Now go ahead and sign the certificate :
```bash
$ openssl x509 -req -in CSR/httpd-mtls.csr -CA CA/ca.crt -CAkey Keys/ca.key \
  -CAcreateserial -out Certs/httpd-mtls.crt -days 730 -extensions 'req_ext' \
  -extfile <(cat Afile/httpd-mtls_csr.txt)
```

Create a Secret that will hold both the key and certificate :
```bash
$ oc create secret tls http-mtls-tls --cert=Certs/httpd-mtls.crt --key=Keys/httpd-mtls.key
```

Now for the deployment.

First crate a skeleton :
```bash
$ oc create deployment httpd-mtls --image=${IMAGE_REF} --port=8443 -o yaml --dry-run=client > Container/deployment.yaml
```

in the YAML file remove the "timestamp" lines add the following 
```YAML
spec:
  ...
  template:
  ...
    spec:
      containers:
      - name: httpd-mtls
        ...
        volumeMounts:
          - mountPath: "/opt/app-root/ssl"
            name: mtls-keys
            readOnly: true
          - name: ca-cert
            mountPath: /opt/app-root/CA/ca.crt
            subPath: ca.crt
      volumes:
        - name: mtls-keys
          secret:
            secretName: http-mtls-tls
        - name: ca-cert
          configMap:
            name: ca-cert

```

**Open Task**  

Modify the deployment so the httpd-mtls will not fail upon run.
add the required ENV to the YAML
```yaml
spec:
  template:
    spec:
      containers:
      - name: httpd-mtls
        env:
        - name:
          value:
```
for :
- SSL_CERT
- /opt/app-root/ssl/tls.crt
- SSL_KEY
- /opt/app-root/ssl/tls.key
- CA_CERT
- /opt/app-root/CA/ca.crt
- ALLOWED_USER
- <client certificate CN>

### Deploy the Container service and route

create the service
```bash
$ oc create service clusterip httpd-mtls --tcp=8443 
```

and a route that should be TLS passthrough because we want the httpd to handle the ssl request:
```bash
$ oc create route passthrough httpd-mtls --service=httpd-mtls --insecure-policy=Redirect
```

### test the MTLS

we will use curl to run a test on our MTLS configuration

First greb the route to our MTLS_ROUTE variable:
```bash
$ export ROUTE_MTLS=$(oc get route httpd-mtls -o jsonpath='{.spec.host}')
```

First run the curl without the client certificate
```bash
$curl --cacert CA/ca.crt https://${ROUTE_MTLS}
curl: (56) OpenSSL SSL_read: error:1409445C:SSL routines:ssl3_read_bytes:tlsv13 alert certificate required, errno 0
```

Now Let's run it with the client certificate 
```bash
$ curl --cacert CA/ca.crt --cert Certs/client.crt --key Keys/client.key https://${ROUTE_MTLS}
```

If you see your index.html file that you are good to go !!!

