docker run -ti --rm \
    -v /etc/kubernetes/pki:/certs \
    -p 2379:2379
    -p 2380:2380
    public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.16-eks-1-21-8 etcd -config-file /data/etcd.config.yml

docker run -d \
    -v /etc/kubernetes/pki:/certs \
    -p 6443:6443 \
    --restart always \
    --name kube-apiserver \
    public.ecr.aws/eks-distro/kubernetes/kube-apiserver:v1.21.5-eks-1-21-8 \
    kube-apiserver \
    --tls-cert-file /certs/kube-apiserver.bundle \
    --tls-private-key-file /certs/kube-apiserver.key \
    --etcd-cafile /certs/ca.crt \
    --etcd-certfile /certs/kube-apiserver-etcd-client.crt \
    --etcd-keyfile /certs/kube-apiserver-etcd-client.key \
    --service-account-signing-key-file /certs/sa.key \
    --service-account-key-file /certs/sa.key \
    --service-account-issuer kubernetes-ca \
    --service-cluster-ip-range "172.16.0.0/24" \
    --etcd-servers "https://10.131.0.2:2379" \
    --client-ca-file /certs/ca.crt




etcdctl --cacert /certs/ca.crt --cert /certs/kube-etcd.crt --key /certs/kube-etcd.key member list
etcdctl --cacert /certs/ca.crt --cert /certs/kube-etcd.crt --key /certs/kube-etcd.key get / --prefix --keys-only
ansible-playbook provision.yml --extra-vars="node_name=kubemaster01" 
curl --cert /etc/kubernetes/pki/kube-apiserver.crt --key /etc/kubernetes/pki/kube-apiserver.key --cacert /etc/kubernetes/pki/ca.crt https://localhost:6443/healthz

kubectl config set-cluster default-cluster --server=https://10.131.0.2:6443 --certificate-authority /etc/kubernetes/pki/ca.crt --embed-certs

kubectl config set-credentials default-controller-manager --client-key /etc/kubernetes/pki/kube-controller-manager.key --client-certificate /etc/kubernetes/pki/kube-controller-manager.crt --embed-certs

kubectl config set-context default-system --cluster default-cluster --user default-controller-manager

docker run -d --name kube-controller-manager --restart always -p 10252:10252 -v /etc/kubernetes/controller-manager.conf:/controller-manager.conf      -v /etc/kubernetes/pki:/certs     public.ecr.aws/eks-distro/kubernetes/kube-controller-manager:v1.21.5-eks-1-21-8 /usr/local/bin/kube-controller-manager --kubeconfig /controller-manager.conf     --client-ca-file  /certs/ca.crt --authentication-kubeconfig /controller-manager.conf --tls-cert-file /certs/kube-controller-manager.bundle --tls-private-key-file /certs/kube-controller-manager.key