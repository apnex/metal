apiVersion: apps/v1
kind: Deployment
metadata:
  name: control-vpn
spec:
  selector:
    matchLabels:
      name: control-vpn-deploy
  template:
    metadata:
      labels:
        name: control-vpn-deploy
    spec:
      volumes:
        - name: vpn-data
          persistentVolumeClaim:
            claimName: vpn-pv-claim
        - name: vpn-init
          configMap:
            defaultMode: 0777
            name: map-vpn-init
      hostNetwork: true
      containers:
      - name: control-vpn
        image: apnex/control-vpn
        volumeMounts:
          - mountPath: /etc/openvpn
            name: vpn-data
          - mountPath: /bin/vpn-init.sh
            name: vpn-init
            subPath: vpn-init.sh
        securityContext:
          capabilities:
            add: ["NET_ADMIN"]
        command: ["/bin/vpn-init.sh"]
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: map-vpn-init
data:
  vpn-init.sh: |
    #!/bin/sh
    echo "Initialising VPN configuration..."
    ovpn_genconfig -N -d -n ${DNS_ENDPOINT} -u udp://${VPN_ENDPOINT}:1194
    if [[ -d "/etc/openvpn/pki" ]]; then
    	echo "[ /etc/openvpn/pki ] already initialised"
    else
    	echo | ovpn_initpki nopass
    fi
    ovpn_run
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: vpn-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  hostPath:
    path: "/mnt/vpn"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: vpn-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
