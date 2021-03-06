---
apiVersion: v1
kind: Service
metadata:
  name: vip-control-dns
  labels:
    app: control-dns
  annotations:
    metallb.universe.tf/allow-shared-ip: host
spec:
  selector:
    app: control-dns
  ports:
    - port: 53
      targetPort: 53
      protocol: UDP
  type: LoadBalancer
---
apiVersion: v1
kind: Service
metadata:
  name: vip-control-dns-rndc
  labels:
    app: control-dns
  annotations:
    metallb.universe.tf/allow-shared-ip: host
spec:
  selector:
    app: control-dns
  ports:
    - port: 953
      targetPort: 953
      protocol: TCP
  type: LoadBalancer
---
apiVersion: v1
kind: Pod
metadata:
  name: control-dns
  labels:
    app: control-dns
spec:
  hostNetwork: false
  volumes:
    - name: dns-conf
      configMap:
        defaultMode: 0777
        name: map-dns-conf
    - name: dns-start
      configMap:
        defaultMode: 0777
        name: map-dns-start
  containers:
  - name: control-dns
    image: apnex/terraform-dns
    volumeMounts:
      - mountPath: /etc/bind/named.conf
        name: dns-conf
        subPath: named.conf
      - mountPath: /etc/bind/rndc.conf
        name: dns-conf
        subPath: rndc.conf
      - mountPath: /bin/dns-start.sh
        name: dns-start
        subPath: dns-start.sh
    command: ["/bin/dns-start.sh"]
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: map-dns-start
data:
  dns-start.sh: |
    #!/bin/sh
    echo "Starting BIND on node... "
    /usr/sbin/named
    sleep 5
    echo "Initialising DNS configuration..."
%{ for zone in zones ~}
    #### ZONE
    if [ ! -f /var/bind/${zone.file} ]; then
    echo "[INFO] fwd zone file missing - creating file...."
    cat <<'EOF' >/var/bind/${zone.file}
    $TTL 86400		; 1 day
    @	IN	SOA ns1.${zone.domain}. mail.${zone.domain}. (
    		100	; serial
    		3600	; refresh
    		1800	; retry
    		604800	; expire
    		86400	; minimum
    	)
    	IN	NS	ns1.${zone.domain}.
    ns1	IN	A	127.0.0.1
    EOF
    fi
    cat /var/bind/${zone.file}
    rndc addzone "${zone.name}" '{ type master; file "/var/bind/${zone.file}"; allow-update { 0.0.0.0/0; }; };'
%{ endfor ~}
    ####
    sleep 5
    tail -f /var/log/named.log
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: map-dns-conf
data:
  named.conf: |
    options {
    	directory "/var/bind";
    	allow-query	{ 0.0.0.0/0; };
    	allow-transfer	{ 0.0.0.0/0; };
    	allow-update	{ 0.0.0.0/0; };
    	allow-new-zones yes;
    	recursion yes;
    	forwarders {
    		8.8.8.4;
    		8.8.8.8;
    	};
    	dnssec-enable yes;
    	dnssec-validation yes;
    };
    logging {
    	channel "default_syslog" {
    		file "/var/log/named.log" versions 3 size 5m;
    		print-time yes;
    		print-category yes;
    		print-severity yes;
    		severity debug;
    	};
    	channel "black" {
    		file "/var/log/named.black" versions 3 size 5m;
    		print-time yes;
    		print-category yes;
    		print-severity yes;
    		severity debug;
    	};
    	category default { default_syslog; };
    	category general { black; };
    	category config { default_syslog; };
    	category security { default_syslog; };
    	category resolver { default_syslog; };
    	category xfer-in { default_syslog; };
    	category xfer-out { default_syslog; };
    	category notify { default_syslog; };
    	category client { default_syslog; };
    	category network { default_syslog; };
    	category update { default_syslog; };
    	category queries { default_syslog; };
    	category lame-servers { default_syslog; };
    };
    controls {   
    	inet * port 953
    	allow { 0.0.0.0/0; } 
    	keys { dnsctl; };
    };
    key "dnsctl" {   
    	algorithm hmac-md5;   
    	secret "Vk13YXJlMSE="; # echo -n 'VMware1!' | base64
    };
  rndc.conf: |
    options {   
    	default-server  localhost;   
    	default-key     "dnsctl"; 
    };
    key "dnsctl" {
    	algorithm hmac-md5;
    	secret "Vk13YXJlMSE=";
    };
