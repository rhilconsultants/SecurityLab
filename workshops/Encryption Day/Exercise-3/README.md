# Openshift as a CA

Today the very basic of securing your application is running it with a TLS encryption. When running the application on top of OpenShift we can utilized the Kubernetes Abilities and sign the application certificate when the CA is already part of OpenShift.

In OpenShift the CA certificate are being recycled as well so we do need to make sure that all the certificates are up 2 date.

## What do we need ?

Openshift, That is it…. well almost we do need to create the CSR and the KEY. For that we need to create an answer file and use openssl to generate the 2 files.

## Generate the request

```bash
$ openssl genrsa -out Keys/ocp-ca.key 2048
```

let's create a new answer file for our future route:
```bash
$ export DOMAIN="apps.cluster-${UUID}.${UUID}.${SANDBOX}"
$ export SHORT_NAME="monkey-app-${USER}-project"
```
Here is how the Answer file should look like :
```bash
$ cat > Afile/ocp-ca_csr.txt << EOF
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
nsComment="The wildcard certificate for OpenShift CA"
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${SHORT_NAME}
DNS.2 = ${SHORT_NAME}.${DOMAIN}
EOF
```

Now Let's create the CSR :
```bash
$ openssl req -new -key Keys/ocp-ca.key -out CSR/ocp-ca.csr -config <( cat Afile/ocp-ca_csr.txt )
```

We can even create the CSR without the answerfile in a one linner :
```bash
$ openssl req -new -key Keys/ocp-ca.key -out CSR/ocp-ca.csr -subj "/CN=${SHORT_NAME}/O=BNHP/C=IL/ST=Center/L=TLV"  -addext "subjectAltName = DNS:${SHORT_NAME},DNS:${SHORT_NAME}.${DOMAIN}" -addext "keyUsage=digitalSignature" -addext "basicConstraints=CA:FALSE" 
```

## Signing the CSR

(From the Official Kubernetes page) : “The CertificateSigningRequest resource type allows a client to ask for an X.509 certificate be issued, based on a signing request. The CertificateSigningRequest object includes a PEM-encoded PKCS#10 signing request in the spec.request field. The CertificateSigningRequest denotes the signer (the recipient that the request is being made to) using the spec.signerName field. Note that spec.signerName is a required key after API version certificates.k8s.io/v1. In Kubernetes v1.22 and later, clients may optionally set the spec.expirationSeconds field to request a particular lifetime for the issued certificate. The minimum valid value for this field is 600, i.e. ten minutes.”

In order to sign our certificate we first need to generate a base64 string from it and add it to the CertificateSigningRequest CR.

```bash
$ CERT_BASE64=$(cat CSR/ocp-ca.csr | base64 -w0)
```

Now let’s create the CR :

```bash
$ cat > tls-csr.yaml << EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${SHORT_NAME}
spec:
  request: ${CERT_BASE64}
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 7776000 # three months
  usages:
  - client auth
EOF
```

Some points to note:

  - usages has to be 'client auth'
  - expirationSeconds could be made longer (i.e. 15552000 for half a year ) or shorter (i.e. 3600 for one hour)
  - request is the base64 encoded value of the CSR file content.

And Apply it :
```bash
$ oc apply -f tls-csr.yaml
```

we can now view the certificate request (if we have the right permissions by running the “oc get csr” command :

```bash
$ oc get csr
NAME      AGE   SIGNERNAME                            REQUESTOR      CONDITION
my-cert   17s   kubernetes.io/kube-apiserver-client   system:admin   Pending
```

As we can see the certificate status is “Pending” which is waiting for the admin (or user with the right permission) to approve the certificate.

Let’s go ahead and approve the certificate :

```bash
$ oc adm certificate approve ${SHORT_NAME}
certificatesigningrequest.certificates.k8s.io/my-cert approved
```

Now, if we look at the CSR request we are going to see the certificates again but the state has changed :

```bash
$ oc get csr
NAME      AGE     SIGNERNAME                            REQUESTOR      CONDITION
my-cert   2m51s   kubernetes.io/kube-apiserver-client   system:admin   Approved,Issued
```

Now that our certificate has been generated we can go ahead and extract it. sense the certificate is been saved as base64 we will need to decode the output

```bash
$ oc get csr ${SHORT_NAME} -o jsonpath='{.status.certificate}' | base64 -d > Certs/ocp-ca.crt
```

use cat to view the certificate :
```bash
$ cat Certs/ocp-ca.crt
```
The output should look as such :
```
-----BEGIN CERTIFICATE-----
.....
-----END CERTIFICATE-----
```

If you are getting the same results we are good to go.

## The CA certificate

For the last part we need to extract our CA certificate which OpenShift had used to sign the certificate. On Openshift there is a simple config map which contains all of the necessary CAs :

**NOTE**
Copy the Openshift CA from the shared directory :
```bash
$ cp /usr/share/ca-certs/ocp-ca.crt CA/ocp-ca.crt
```

Now we have everything we need in place and we go ahead and use the certificate.

First Let's delete our monkey-app route
```bash
$ oc delete route monkey-app
```

and recreate it with our new certificate :
```bash
$ oc create route edge monkey-app --service=monkey-app \
  --cert=Certs/ocp-ca.crt --key=Keys/ocp-ca.key \
  --ca-cert=CA/ocp-ca.crt --insecure-policy=Redirect \
  --port=8080
```

Let's look at the route ...
```bash
$ oc get route monkey-app

```

This looks like something is not right , Let's look at the certificate and figure out why.
```bash
$ openssl x509 -in Certs/ocp-ca.crt -text -noout
```
**HINT**  
It looks like the vaules of SSLv3 do not line up with the certificate needed for the route  
Can you guess which value is the problametic one?

## Restoring the Old certificate

Delete the new one
```bash
$ oc delete route monkey-app
```

Now let's recreate the old one

```bash
$ oc create route edge monkey-app --service=monkey-app \
  --cert=Certs/wildcard.crt --key=Keys/tls-test.key \
  --ca-cert=CA/ca.crt --insecure-policy=Redirect \
  --port=8080 
```

## Testing our Certificate.

set a varible with your route
```bash
$ export ROUTE=$(oc get route monkey-app -o jsonpath='{.spec.host}')
```

Now run a test with curl which points to the url :
```bash
$ curl -vvv --cacert CA/ca.crt -H "Content-Type: application/json" https://${ROUTE}/api/?says=banana
```

The output should be :
```bash
{
  "result": "Success",
  "message": "Monkey says: banana"
}
```

Can you tell which certificate is being used and why ?  
Can you change it ?  


You have completed your Exercise !!!