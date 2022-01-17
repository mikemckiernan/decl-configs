frr_mount_path="etc/frr"
config_file="frr.conf"


docker network create --driver=bridge kind --ipv6 --subnet=10.0.1.0/24 --gateway=10.0.1.1 --subnet=fd00:1::/64 --gateway=fd00:1::1 --opt com.docker.network.bridge.enable_ip_masquerade=true
kind create cluster --name kind --config cluster.yaml

echo "Creating second docker network kind2" 
docker network create --driver=bridge kind2 --ipv6 --subnet=10.0.2.0/24 --gateway=10.0.2.1 --subnet=fd00:2::/64 --gateway=fd00:2::1 --opt com.docker.network.bridge.enable_ip_masquerade=true

echo "Creating frr containers"
docker run --network kind2 -d -it --rm --name next-hop-router  alpine
docker network connect kind next-hop-router 

docker run --network kind2 -d --rm --name frr1 --privileged -v "$(pwd)/frr1":/etc/frr frrouting/frr
docker run --network kind2 -d --rm --name frr2 --privileged -v "$(pwd)/frr2":/etc/frr frrouting/frr

frr1_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' frr1)
frr2_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' frr2)
node1_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-worker)
node2_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-worker2)
nh_kind_ip=$(docker inspect -f '{{.NetworkSettings.Networks.kind.IPAddress}}'  next-hop-router)
nh_kind2_ip=$(docker inspect -f '{{.NetworkSettings.Networks.kind2.IPAddress}}'  next-hop-router)

echo "Editing configurations files"
cp frr.conf.tmpl frr.conf
cp frr.conf configmap/
sed -i 's/IP_A/'"$node1_ip"'/g' frr.conf
sed -i 's/IP_B/'"$node2_ip"'/g' frr.conf
cp frr.conf frr1/
sed -i 's/LOCAL_IP/'"$frr1_ip"'/g' frr1/frr.conf
cp frr.conf frr2/
sed -i 's/LOCAL_IP/'"$frr2_ip"'/g' frr2/frr.conf
sed -i 's/IP_A/'"$frr1_ip"'/g' configmap/frr.conf
sed -i 's/IP_B/'"$frr2_ip"'/g' configmap/frr.conf

#kubectl create configmap frr-config --from-file=./configmap/
#kubectl apply -f daemonset.yaml
docker exec -it frr1 sh -c "python3 /usr/lib/frr/frr-reload.py --reload ${frr_mount_path}/${config_file}"
docker exec -it frr2 sh -c "python3 /usr/lib/frr/frr-reload.py --reload ${frr_mount_path}/${config_file}"

echo "Configuring static routes"

docker exec  frr1 sh -c "ip route add 10.0.1.0/24 via ${nh_kind2_ip} dev eth0"
docker exec  frr2 sh -c "ip route add 10.0.1.0/24 via ${nh_kind2_ip} dev eth0"
docker exec kind-worker sh -c "ip route add 10.0.2.0/24 via ${nh_kind_ip} dev eth0"
docker exec kind-worker2 sh -c "ip route add 10.0.2.0/24 via ${nh_kind_ip} dev eth0"
