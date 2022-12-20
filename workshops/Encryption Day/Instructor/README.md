# Lab Configuration

The Following Page is for the Instractor to set up the Lab

**Logging to the Lab and switch to root**

## Install The Following Packages

### EPEL Packages
```bash
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
```

Now Install the relevant packages:
```bash
dnf install -y jq openssl podman p7zip httpd-tools curl wget rlwrap nmap telnet ftp tftp\
 openldap-clients tcpdump wireshark-cli buildah xorg-x11-xauth tmux net-tools nfs-utils skopeo make 
```

### Users Management

Create a user for the Manager

```bash
export ADMIN_USER="" #set the admin username
```

Create a group for the admins users if you need more then one :
```bash
groupadd admins
useradd -g admins -G wireshark,disk,wheel ${ADMIN_USER}
```

Add the group to the soduers file
```bash
echo '%admins         ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers
```

Copy the kubeconfig from root to the user manager
```bash
cp -R /root/.kube/ /home/${ADMIN_USER}/
chown ${ADMIN_USER}:admins -R /home/${ADMIN_USER}/.kube/
```

Create a tmux file for each of the users :

```bash
for num in {1..20};do
useradd user${num}
echo 'openshift' | passwd --stdin user${num} 
cat > /home/user${num}/.tmux.conf << EOF
unbind C-b
set -g prefix C-a
bind -n C-Left select-pane -L
bind -n C-Right select-pane -R
bind -n C-Up select-pane -U
bind -n C-Down select-pane -D
bind C-Y set-window-option synchronize-panes
EOF
chown user${num}:user${num} /home/user${num}/.tmux.conf
done
```

Now make sure the users are admin on thier namespace :
```bash
for num in {1..20};do
oc new-project user${num}-project
oc adm policy add-role-to-user admin user${num} -n user${num}-project
done
```

Create a new cluster rule :
```bash
cat > csr-clusterrole.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: csr-creator
rules:
- apiGroups:
  - certificates.k8s.io
  resources:
  - certificatesigningrequests
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
- apiGroups:
  - certificates.k8s.io
  resources:
  - certificatesigningrequests/approval
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
- apiGroups:
  - certificates.k8s.io
  resources:
  - certificatesigningrequests/status
  verbs:
  - update
- apiGroups:
  - certificates.k8s.io
  resources:
  - signers
  resourceNames:
  - kubernetes.io/kube-apiserver-client
  verbs:
  - sign
  - approve
EOF
```
and Approve it :
```bash
$ oc apply -f csr-clusterrole.yaml
```

update all the users:
```bash
for num in {1..20};do
oc adm policy add-cluster-role-to-user csr-creator user${num}
done
```

Update the /etc/hosts file :
```bash
export UUID="" #set the admin username
export SANDBOX="" #set the admin username
export IPADDR=`nslookup -q=a nana.apps.cluster-${UUID}.${UUID}.${SANDBOX} | grep Address | awk '{print $2}' | awk -F'#' '{print $1}'`

for num in {1..20};do
echo "${IPADDR}     tls-test-user${num}.example.local" >> /etc/hosts
done
```
Extact the CA from OpenShift to files :

```bash
oc -n openshift-authentication  \
rsh `oc get pods -n openshift-authentication -o name | head -1 `  cat /run/secrets/kubernetes.io/serviceaccount/ca.crt > \
/etc/pki/ca-trust/source/anchors/opentls.crt

update-ca-trust extract
```

Export the OpenShift CA signer 
```bash
mkdir /usr/share/ca-certs/

oc get secret csr-signer -n openshift-kube-controller-manager-operator -o template='{{ index .data "tls.crt"}}' | base64 -d > /usr/share/ca-certs/ocp-ca.crt

cp /etc/pki/ca-trust/source/anchors/opentls.crt /usr/share/ca-certs/ocp-api.crt

```

