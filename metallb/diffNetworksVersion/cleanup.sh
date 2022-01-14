kind delete cluster --name=kind
docker rm -f frr1 frr2
docker rm -f next-hop-router
rm -f configmap/frr.conf 
rm -f frr.conf
rm -f frr1/frr.conf
rm -f frr2/frr.conf
docker network rm kind2
