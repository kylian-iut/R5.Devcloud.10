# TD Orchestrateur - Docker Swarm
### Démarrez les machines avec votre hyperviseur, configurez deux cartes :
1. Host-Only IP:192.168.56.1/24 avec DHCP lowerIP:192.168.56.101
2. NAT Network:192.168.0.0/24 DHCP: auto

### Configurez les différents éléments sur les machines de sorte a avoir un Master et plusieurs VMs
1. su
2. apt install sudo
3. nano /etc/sudoers
4. exit
5. sudo hostname <nom> 
6. sudo nano /etc/network/interfaces

### Connectez vous en ssh sur les machines
```bash
ssh toto@192.168.56.101
ssh toto@192.168.56.102
ssh toto@192.168.56.103
```

### Executez l'installation de docker
```bash
sudo apt install docker.io
```

### Initialisez le cluster sur le Master
```bash
sudo docker swarm init --advertise-addr=192.168.56.101
```

### Rejoignez le cluster sur les autres VMs
```bash
sudo docker join --token <token fourni> 192.168.56.101
sudo docker node ls
```

### Création du service
```bash
sudo docker service create --replicas=3 --name nginx-service nginx
sudo docker service ps nginx-service
```

### Gestion du service
```bash
sudo docker service scale nginx-service=4
sudo docker service inspect nginx-service
sudo docker service update --image nginx nginx-service
sudo docker service rm nginx-service
```

### Création du réseau overlay
```bash
sudo docker network create --driver overlay firstnetwork
sudo docker network create --driver overlay secondnetwork
sudo docker service update --network-add firstnetwork nginx-service
sudo docker service create --replicas=3 --network secondnetwork --name alpine-service alpine tail -f /dev/null
```
On remarque que les machines de services différents de peuvent pas communiquer entre eux, c'est normal.

### Utiliser secret afin de transmettre certificat et mots de passes
```bash
ssh-keygen -t rsa -b 4096 -f ./id_rsa
sudo docker secret create id_rsa ./id_rsa

sudo docker service create --name redis --secret id_rsa redis:3.0.6
# Ou bien
sudo docker service create --name redis --secret source=id_rsa,target=app,uid=1000,gid=1001,mode=0400 redis:3.0.6
```

### Utiliser config afin de transmettre un fichier de configuration
```bash
sudo docker config create site-ssl ./site-ssl.conf
sudo docker service create --name apache --config soucre=site-ssl,target=/etc/apache2/sites-available,mode=0400 apache2
```

# Exercie final : 4 applications de différents concepts
### Créer le service utilisant un bind volume puis un volume monté

### Créer un service utilisant un secret
```bash
ssh-keygen -t rsa -b 4096 -f ./id_rsa
sudo docker secret create id_rsa ./id_rsa
sudo docker service create --name alpine-ssh --secret source=id_rsa,target=~/.ssh/id_rsa,uid=1000,gid=1001,mode=0400 alpine
```

### Créer un service utilisant une config
```bash
```

### Créer un service utilisant un réseau dédié
```bash
sudo docker network create --driver overlay dedicated
sudo docker service create --replicas=3 --network dedicated --name dedicated-service nginx
```

