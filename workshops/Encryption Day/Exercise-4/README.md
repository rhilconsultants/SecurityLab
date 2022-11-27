# Kubeconfig & SSL Troubleshooting

This part is one of the must interesting and annoying thinks about SSL/TLS.  
The Art of troubleshooting SSL certificates.

In This Exercise we will look at the certificates and how resolve SSL issues.

## Prerequisites

Create a directory of named Issues under our bash directory
```bash
$ mkdir $TLS_BASE/Issues && cd $TLS_BASE/Issues 
```

## CURL certificate

First Let's try get curl to work without providing the "--cacert" argument.  
Sense there are multiple answers to this question please choose one of them and show it to one of the instructors.

## lost in time

Copy the following certificate content to a new file named "cert1.crt" under out Issues directory
```
-----BEGIN CERTIFICATE-----
MIIGDDCCA/SgAwIBAgIUPLBmNtmQQvoSn4nFR0lZKfn1WDEwDQYJKoZIhvcNAQEL
BQAwgY4xCzAJBgNVBAYTAklMMRAwDgYDVQQIDAdSYWFuYW5hMRAwDgYDVQQHDAdS
YWFuYW5hMQ8wDQYDVQQKDAZSZWRIYXQxCzAJBgNVBAsMAlBTMSIwIAYJKoZIhvcN
AQkBFhNvb2ljaG1hbkByZWRoYXQuY29tMRkwFwYDVQQDDBBjYS5pbC5yZWRoYXQu
Y29tMB4XDTIyMTEyNjEwMTkzMFoXDTIyMTEyNzEwMTkzMFowgYUxCzAJBgNVBAYT
AlVTMREwDwYDVQQIDAhOZXcgWW9yazERMA8GA1UEBwwITmV3IFlvcmsxDjAMBgNV
BAoMBU15T3JnMRIwEAYDVQQLDAlNeU9yZ1VuaXQxHDAaBgkqhkiG9w0BCQEWDW1l
QHdvcmtpbmcubWUxDjAMBgNVBAMMBWNlcnQxMIICIjANBgkqhkiG9w0BAQEFAAOC
Ag8AMIICCgKCAgEAvG7NDYbdgizhyJBJx9jAFN4ySYXe2d4YvPtA6Y+VKHNo1ZhG
xDSygFYA/A2Zk/WhI47tWH5K4nBihjsA2rBly+MkfMcHaSZ+FyQRiU8Ue5/9BXHi
Mxe3FcMy7xgiJCoi0jjjuEgO+wLLpw1OmL6DYAzoDgAd7FyhP86OamCD/CErVSwp
bgEgg8ALZcLlecMzcr1jRxUAv9t4Wzm18L4OgsB6W4tB99NfkXdPoHVcXntX7+Q5
0HIcMGRK1wwgR9ro76ZPBXTFeslb8igPwDBBm7lVrQyILV35jxjrm2/1BcWZ7X+S
qy/pDraopWCd0nCfzCJQzYxqAGeKY5h3ZxAUpZFPa+RsNuHTag6Aiq1+a8gmCOV4
bOsPW4TUMk/tLwNDjcBhnYdy0JoQGad3BT1edANOQup5kVZTv6r30jSB7dmzJyPU
69zPfzNomNZh5cDYQaH398E0aY4ryeaIyHGXJSsbrqd9YWqFXLXYavApcE4QumyF
6T0jlCERYiBzzTMupw7S9z1oaouOMqbRcREAotOGdZnJQpDmM9ngLaQcwQo7zu82
Vnt3YXmSb1JokZrnsYTVrt75QEUAKo7Priqrvs0GMfnv2vrsHnqeUVNGKQA255/y
LkHf/U7UrsPmreq5VwDCbJXMJBNX9JYUJsptEyx13j3HqWxZubPpmY2AofcCAwEA
AaNpMGcwJQYDVR0RBB4wHIIFY2VydDGCE2NlcnQxLmV4YW1wbGUubG9jYWwwHQYD
VR0OBBYEFFcu9o39VzrwqP+aiQVZ9mlmd8IqMB8GA1UdIwQYMBaAFAWejEk0mmdc
0z6I9TeWrag2APGOMA0GCSqGSIb3DQEBCwUAA4ICAQA6mHM8mWtxroIEKUHiDdmE
R4DTjyTduUMwByxYoMHEIipene/VSVLudZphEtq+WdlYkYiicuQgeCJ1Jf/XJydt
kXMvl694NG8bfZSdAFWAKpuOBNHKTFwapDmvS6yNYUXdnuTSdlqvA0hbzEXreRgi
WLEeISuq0qxqUHOX7GSAIPc5bJMm1basTp/1zV7xFKlU+lKnHTvPa5/RuWS57Y1F
D56BH1ePD8KgwVl1Sz8cvl/S0FGYi4WNw5xBO/AK4uP6yMTF7HlfcX30ntAF+pWs
CBuuccV5ch9D5hni+m0xxfDlWgD4B/qY6bcixwMpDiCtlbKuDYORFTvIz09FsEKo
KCtRowz80UE0ex4kLITObWKekksnq1YW7zNRGI5WtDx90GhTW7vMpGqrASdtY6yQ
hd4RH3oCkomOf7VRBq0rZXcpqERG4KSH27lN9cUa33LA1lX4cVEnvb+wTNmNaDHp
wBlRJLncQ5vsgfkGaTgdMnZ2Z8kYw0pKf6FbwfCO9BhVnVH2h/uVcJpFybtqwZYt
y+N5ETVOxvKW5NyyrLTWxcGTWlwOjuL1L+W5UVAfilT6ffUjPcw0mDxpZXQgtBMK
C6WHPvuftXPZFCUTuwkm4/z1OhxBK+Ub4ZBvSyrpln9pQSwIYn1cTumyLD2G26zn
a+KpAk162umFRFdWZLyxUA==
-----END CERTIFICATE-----
```

Now run the inspection command to see what is wrong with the certificate :
```bash
$ openssl x509 -in cert1.crt -noout -text
```

## Mix and Match

Create the following certificate as cert2.crt
```
-----BEGIN CERTIFICATE-----
MIIGDDCCA/SgAwIBAgIUI3WDZ7Xl/dRfTT8Bi0sSZUm3y/kwDQYJKoZIhvcNAQEL
BQAwgY4xCzAJBgNVBAYTAklMMRAwDgYDVQQIDAdSYWFuYW5hMRAwDgYDVQQHDAdS
YWFuYW5hMQ8wDQYDVQQKDAZSZWRIYXQxCzAJBgNVBAsMAlBTMSIwIAYJKoZIhvcN
AQkBFhNvb2ljaG1hbkByZWRoYXQuY29tMRkwFwYDVQQDDBBjYS5pbC5yZWRoYXQu
Y29tMB4XDTIyMTEyNjEwMjIyM1oXDTI0MTEyNTEwMjIyM1owgYUxCzAJBgNVBAYT
AlVTMREwDwYDVQQIDAhOZXcgWW9yazERMA8GA1UEBwwITmV3IFlvcmsxDjAMBgNV
BAoMBU15T3JnMRIwEAYDVQQLDAlNeU9yZ1VuaXQxHDAaBgkqhkiG9w0BCQEWDW1l
QHdvcmtpbmcubWUxDjAMBgNVBAMMBWNlcnQyMIICIjANBgkqhkiG9w0BAQEFAAOC
Ag8AMIICCgKCAgEAqQesxt1/HFKHSCEZskSFf1llUbHrzLj+l+w3h+xvgDrXECpT
isZiONq0yvYN4zC8nF6sYrWKrqLlz8ZmXLAuoW/jczcRhNZwMphFK1+1aCsBH9xh
M29QlZY31aylRnQRda3l+E5aqUgVGB2hPSV9yHolkjL/208771Is93ETjildsS80
xmWpfFY0uxl0t+evfkDAwdoAUHUiURS5Xn1EZcx1Fly48IVbKIiZbrNZ+7tO4MiY
l/hSbwEEmtReTtQoW5vVK35t1KactPYIGJLePCmfoCvj+3EU/XFsaHAjibKf/GZQ
z/4O8SWy26xAXHk6MJd/RYe8dh3DFre28iiFutBQZ+9qYGD8Xf3nUnqVf0aaCNkH
+j1D7oU5TFFiC1RJh3CJS13MeIYrTLR0oSlOjkYap4QaUzZ10svdEgRNCO9k2Ah7
aut9/SM3CTI+8PUKR570VWN1fmF11Cvmju0/PNSbOxBC22iMMjauK4oZTynPWy0j
pxhYZdxA5pkIRDii3qg4uVkVLeIlTV8bDXWfiDqu9F7WXN0vTpGCmpfC1j5F7fUI
SEhX4uhBOanOgXuHyIg3dCw2wd3N0yncR5GmoGBfSfSEmrUoLQOjHIvjBoLfmnRe
OjBL42W9W7iz41PPwyt65UF+0XYXxr1OgzFcZNzFYyNWBa+Zgm9DBohJ+tUCAwEA
AaNpMGcwJQYDVR0RBB4wHIIFY2VydDKCE2NlcnQyLmV4YW1wbGUubG9jYWwwHQYD
VR0OBBYEFIf8qyjhpwAw94hARg+wIt68DHY2MB8GA1UdIwQYMBaAFAWejEk0mmdc
0z6I9TeWrag2APGOMA0GCSqGSIb3DQEBCwUAA4ICAQBAGot6dG/8BYqyCpIZTVhi
itmK+NM4svoJ/VXwHKjIelSvdy/Q5Dtj6KM2uG6tZ1dwDzggvh+s2cFig2q7de/1
f/X3BMWLlhxF0ogPqbzKmD4gSqpwIkYjNq/N+7+n4j7bG85+MpTlxKzWFtSRa3IM
H3C4RzYXMFmmrKG4lliPJ9VNcQJhFLn+2STip6yHnF6opuG4NiWVotH8SFp+JFO/
GeG9XFCRMfkcrMbe7+32EkeyAQ68F2tinC2ei9o62lVCkUwTHucPpv70tJwUx+Kv
2q2qrylHUKO2pdWQ+pqDR6OdilKPGLD6XYhamNOe/0tUN0/401Tzj7t9qa+k1QRS
VIYh+1wcC03QAByQ6x5RQYPc25gkHjDY3JqQIdbnV49dwsKiJKyNepMnPEHHVTv3
lLDxiAFnBX4qlu5H7930N2+Bh9jcq4cUNxj0hoQx5/ymXai6u+vBnbZK9UKAE2Dr
6/6iMM92mG1vu0imuz90668vK0D09YqOgpZAmENHHsQMJgg7EM0IKB6nu87ykJg9
dwI5ya/TMYPvQBYo+Vs5GM4WcaJs4+pdDqZTpY7Qv1HEMhlRoh6qBFtNTj4Y2E4n
edJ0SAv+1p/c0vwNCF32yDnjW3ARNUg1xup/iZGfy9v/pbfoB9lFXfP31BM5Khok
AnPWFG/Ja8wFAPjsibwSDg==
-----END CERTIFICATE-----
```

And the following key file named cert2.key :
```
-----BEGIN PRIVATE KEY-----
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
D1k0NISE4yXndVrwbaaxHM44yop9+w==
-----END PRIVATE KEY-----
```

with the following CA name cert2-ca.crt :
```
-----BEGIN CERTIFICATE-----
MIIF/DCCA+SgAwIBAgIUFZy2Ieu28UoPfL4y1i5XY1GZB7EwDQYJKoZIhvcNAQEL
BQAwgY4xCzAJBgNVBAYTAklMMRAwDgYDVQQIDAdSYWFuYW5hMRAwDgYDVQQHDAdS
YWFuYW5hMQ8wDQYDVQQKDAZSZWRIYXQxCzAJBgNVBAsMAlBTMSIwIAYJKoZIhvcN
AQkBFhNvb2ljaG1hbkByZWRoYXQuY29tMRkwFwYDVQQDDBBjYS5pbC5yZWRoYXQu
Y29tMB4XDTIxMDEwNzA5MTUwM1oXDTIzMDEwNzA5MTUwM1owgY4xCzAJBgNVBAYT
AklMMRAwDgYDVQQIDAdSYWFuYW5hMRAwDgYDVQQHDAdSYWFuYW5hMQ8wDQYDVQQK
DAZSZWRIYXQxCzAJBgNVBAsMAlBTMSIwIAYJKoZIhvcNAQkBFhNvb2ljaG1hbkBy
ZWRoYXQuY29tMRkwFwYDVQQDDBBjYS5pbC5yZWRoYXQuY29tMIICIjANBgkqhkiG
9w0BAQEFAAOCAg8AMIICCgKCAgEAyy0Uqwi3xmPBC1HkKHHWdoLjxSq+keOSRzBX
MEWtw7VqCOuOheBxMtN2OMjbnd1f53fkZVSC0I2MzuXFE1xS0LSurtz60ogVII58
MvgEsJvWCVT6eSpMSgVg/GFSHzgDTS+jSu/c8DzRuL1oYIDJ9NBzy+8HjLWOrF+H
bFVUpFT5rkA5Fo7SbcypUwFTAyXHKg8Li4w0FggMSWHLTBqvXYvlstF/t9QOkivs
a0+eW2pZYtgSEtz+uGkUgyAF9uvQrenw/M/vrkiM/H3ZFIHPQfu25nhIrUvYYlSC
XEyRZsqo9fsntkyT+7r+oSz09B5MF2VotCuM8FKZPboRL16KLZ8UeRg1HvZtVgqS
4fTt89GNrI+rVUgvLfWv2eAekHmUrKgvSpF8EtNdz9LvmZ/eNBMInUAdduL0FMJw
tmXgzqN6P6HOCo6ehgr8bvWKR9Rvyd/Czow4Dk8gth3Mk8RiiZWIhr4jD0VG/Puc
0RDlpIRUzQyrsE9E1yvJEqq+1pDSaQcMaTI/aQDZvxVzm+9xMbPYRNFNxuBkc/bx
GmRt8/RsKrJRG5LyMa63tlnVn9CKfjWPuG86bjRS2bFvr0m8VU4OAnDt18TVuldA
/Ua+MOOzWmZtn5uhzSgmiPKTQiNe1i7deC24OCUZFz3/lVuDCxkfOSymYaeeJIIx
OJLf+dMCAwEAAaNQME4wDAYDVR0TBAUwAwEB/zAdBgNVHQ4EFgQUBZ6MSTSaZ1zT
Poj1N5atqDYA8Y4wHwYDVR0jBBgwFoAUBZ6MSTSaZ1zTPoj1N5atqDYA8Y4wDQYJ
KoZIhvcNAQELBQADggIBALjrJV9MStlMx4ikkJFst5F75L3US5KZRz5Knjjfn7Yw
RtCV032NzK6ocpRK1WOynzLf2JvdT3X4VKnc5weqt+VYZ9dUpU4CNl5ASHKbaigw
qjthW25K8rBvh7GlRM7VURsh1bz/KKvkLEpGr2C6Z9Hvknb0Rd0lObASkV1ucpFx
uweCa7VX3b0U8CBXIo9ZYSzpy6PW6BMHTbJq9oTLTVZuxZCCW9gxPYy4iAMYkAej
hsQzH7uAhAX8EfvKmXIrmdAxujE5IYP7B3gSueENWwb0moRiDriNQoPBfdmep2ob
IroQ+YKj7JFhPMYrx3vh7fKiObt+qdjKyXO54eEz8uwUrZmOwHzNcg2xqaWWJYZh
r24haOeCitiDmrxeQYV/T+huwEfWzFU0a8nNgqy1O1Vl7d5egqEUQGbs0ZQoc6cw
VNVZ64jkUYH7ZlJUH9zLHcafUOKX7L2DWFl/012HcezSckZsq919ZTThHpLUo0TW
jPbpoWDXczYqQNF/EeXMPTcL16Cvrp84Yec4m3gTmot9ZzA51kiq3ATm/uPyG6Se
wBa16LgMLIjHfaXi2+X/SqzOAkpOAgg39uba5+F338n+ssinojVM6lMlLnkVtRnP
Io9tCCfumDBvpto3uohtYvcDk+Y4z4DLOQyyK06B94TB9zzsD7xfzuFesnph+FZE
-----END CERTIFICATE-----
```

Now delete and recreate the "monkey-app" route with those files:
```
$ oc delete route monkey-app
$ oc create route edge monkey-app --service=monkey-app \
  --cert=cert2.crt --key=cert2.key \
  --ca-cert=cert2-ca.crt --insecure-policy=Redirect \
  --port=8080 
```

Let's look at the route to see what wrong :
```bash
$ oc describe route monkey-app
```

**HINT**
You can make sure the cert comes from the key with the following command :
```
$ openssl x509 -noout -modulus -in cert2.crt | openssl md5
$ openssl rsa -noout -modulus -in cert2.key | openssl md5
```

If the certificate came from the key it should match  

**Open Task**
Fix the certificate for the Monkey-app

## Generate Kubeconfig

when logging to OpenShift we can run the authentication is several ways.
1. (As you know) SSO with your AD account
2. X509 certificate authentication


In this part we will create a "Web Client Certificate" for our user

First Let's create a key :
```bash
$ openssl genrsa -out kube.key 4096
```

Now let's one line the CSR request :
```bash
$ openssl req -new -key kube.key -out kube.csr -subj "/CN=${USER}/O=Authenticated Users" -addext "keyUsage=digitalSignature" -addext "basicConstraints=CA:FALSE" -addext "extendedKeyUsage=clientAuth"  -addext "subjectKeyIdentifier=hash"
```

Now we will ask OpenShift to sign it :
```bash
$ CERT_BASE64=$(cat kube.csr | base64 -w0)
```

Now let’s create the CR :

```bash
$ cat > kube-csr.yaml << EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${USER}-crt
spec:
  request: ${CERT_BASE64}
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 7776000 # three months
  usages:
  - client auth
EOF
```

Apply the CR :
```bash
$ oc apply -f kube-csr.yaml
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
$ oc adm certificate approve ${USER}-crt
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
$ oc get csr ${USER}-crt -o jsonpath='{.status.certificate}' | base64 -d > kube.crt
```

you can copy the OpenShift CA from /usr/share/ca-certs/
```bash
$ cp /usr/share/ca-certs/ocp-api.crt .
```

Now use the following skeleton to build your kubeconfig file (create a file named kubeconfig.${USER}:
```YAML
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: <Base 64 CA>
    server: <The Server API>
  name: OpenShift
contexts:
- context:
    cluster: OpenShift
    namespace: $USER-project
    user: ${USER}/OpenShift
  name: $USER-project/OpenShift/${USER}
current-context: $USER-project/OpenShift/${USER}
kind: Config
preferences: {}
users:
- name: ${USER}
  user:
    client-certificate-data: < BASE64 Client CA>
    client-key-data: < BASE64 Client Key>
```

log out from OpenShift
```
$ oc logout
```

Now Set the environment variable KUBECONFIG to point to it :
```bash
$ export KUBECONFIG="$(pwd)/kubeconfig.${USER}"
```

Run the oc command to see you are connected but with X509 instead of user/pass method :
```bash
$ oc whoami
```

That Is it 
(you have completed the exercise!!!)
