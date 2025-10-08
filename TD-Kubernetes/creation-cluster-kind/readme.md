# TD Kubernetes - Création et gestion d'un cluster avec Kind

Ce guide vous accompagne dans l'installation et la configuration d'un cluster Kubernetes local en utilisant Kind (Kubernetes in Docker).

## Prérequis

- Système Linux (Ubuntu/Debian)
- Droits sudo
- Connexion Internet

## Installer kubectl
### Télécharger la dernière release
```bash
curl -LO https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
```

### Rendre le binaire kubectl exécutable
```bash
chmod +x ./kubectl
```

### Déplacez le binaire dans votre PATH
```bash
sudo mv ./kubectl /usr/local/bin/kubectl
```

### Tester la commande
```bash
kubectl version --client
```

## Installer kind
### Télécharger la dernière release AMD64
```bash
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-$(uname)-amd64
```
ou sinon, voir [le dépôt de kind sur github](https://github.com/kubernetes-sigs/kind)

### Rendre le binaire kind exécutable
```bash
chmod +x ./kind
```

### Déplacez le binaire dans votre PATH
```bash
sudo mv ./kind /usr/local/bin/kind
```

## Installer docker et créer le cluster
### MàJ de apt et installation de docker
```bash
sudo apt update && sudo apt install -y docker.io
```

### Ajouter l'utilisateur au groupe docker (optionnel)
```bash
sudo usermod -aG docker $USER
# Redémarrer la session ou exécuter : newgrp docker
```

### Création du cluster kind
Se déplacer vers le dossier de création :
```bash
cd /path/to/TD-Kubernetes/creation-cluster-kind
```

Exécuter le script de création (avec sudo si nécessaire) :
```bash
sudo ./creation-kind-cluster-with-ec.sh
```

## Configuration de kubectl

### Configurer la variable d'environnement KUBECONFIG
```bash
export KUBECONFIG=$(pwd)/kindkubeconfig
```

### Vérifier la connexion au cluster
```bash
kubectl cluster-info
```

### Vérifier les nœuds du cluster
```bash
kubectl get nodes
```

### Configuration de l'alias et autocomplétion kubectl
Pour faciliter l'utilisation de kubectl, configurez un alias et l'autocomplétion :

```bash
# Installer l'autocomplétion système (nécessite sudo)
sudo kubectl completion bash > /tmp/kubectl_completion
sudo mv /tmp/kubectl_completion /etc/bash_completion.d/kubectl

# Ajouter l'alias et l'autocomplétion au .bashrc
cat >> ~/.bashrc << 'EOF'

# Kubectl configuration
alias k=kubectl
source <(kubectl completion bash)
complete -F __start_kubectl k
EOF

# Recharger la configuration
source ~/.bashrc
```

Maintenant vous pouvez utiliser `k` au lieu de `kubectl` :
```bash
k get nodes
k get pods --all-namespaces
```

## Commandes utiles

### Lister les clusters kind
```bash
kind get clusters
```

### Obtenir les informations des nœuds avec leurs capacités
```bash
kubectl get nodes -o json | jq ".items[] | {name:.metadata.name} + .status.capacity"
```

### Afficher tous les pods dans tous les namespaces
```bash
kubectl get pods --all-namespaces
```

### Obtenir des informations détaillées sur un nœud
```bash
kubectl describe node <nom-du-nœud>
```

### Gestion des images Docker dans le cluster kind

#### Télécharger une image depuis un registry externe
```bash
sudo docker pull registry.iutbeziers.fr/pythonapp:latest
```

#### Charger une image dans le cluster kind
```bash
sudo kind --name tp1k8s load docker-image registry.iutbeziers.fr/pythonapp:latest
```

#### Vérifier les images disponibles dans un nœud du cluster
```bash
sudo docker exec -it tp1k8s-control-plane crictl images
```

#### Charger une image locale (construite localement)
```bash
# Construire l'image localement
sudo docker build -t mon-app:latest .

# Charger dans le cluster kind
sudo kind --name tp1k8s load docker-image mon-app:latest
```

### Supprimer le cluster
```bash
sudo kind delete cluster --name tp1k8s
```

## Dépannage

### Erreur "connection refused localhost:8080"
Si vous obtenez cette erreur, vérifiez que :
1. Le cluster est bien créé : `kind get clusters`
2. La variable KUBECONFIG est configurée : `echo $KUBECONFIG`
3. Le fichier kubeconfig existe et n'est pas vide : `ls -la kindkubeconfig`

### Port 80 déjà utilisé
Si Apache ou un autre service utilise le port 80, le script a été modifié pour utiliser les ports 8080 et 8443 à la place.

### Permissions Docker
Si vous obtenez des erreurs de permissions Docker, utilisez `sudo` devant les commandes kind et docker, ou ajoutez votre utilisateur au groupe docker.

### Erreur "Permission denied" pour l'autocomplétion kubectl
Si vous obtenez cette erreur lors de la configuration de l'autocomplétion :
```
bash: /etc/bash_completion.d/kubectl: Permission non accordée
```

Utilisez cette méthode alternative :
```bash
# Créer le fichier avec les bonnes permissions
sudo kubectl completion bash > /tmp/kubectl_completion
sudo mv /tmp/kubectl_completion /etc/bash_completion.d/kubectl

# Ou alternative sans sudo (autocomplétion personnelle uniquement)
kubectl completion bash > ~/.kubectl_completion
echo "source ~/.kubectl_completion" >> ~/.bashrc
```

### Erreur "image not present locally" avec kind
Si vous obtenez cette erreur lors du chargement d'une image :
```
ERROR: image: "registry.example.com/app:latest" not present locally
```

**Cause :** L'image a été téléchargée avec `sudo docker pull` mais `kind` s'exécute sans sudo et ne voit pas l'image.

**Solutions :**
```bash
# Solution 1: Utiliser sudo pour kind également
sudo kind --name tp1k8s load docker-image registry.iutbeziers.fr/pythonapp:latest

# Solution 2: Ajouter l'utilisateur au groupe docker (nécessite une reconnexion)
sudo usermod -aG docker $USER
newgrp docker  # ou se reconnecter

# Télécharger l'image sans sudo après avoir rejoint le groupe docker
docker pull registry.iutbeziers.fr/pythonapp:latest
kind --name tp1k8s load docker-image registry.iutbeziers.fr/pythonapp:latest
```

## Architecture du cluster

Le cluster créé contient :
- 1 nœud control-plane (tp1k8s-control-plane)
- 3 nœuds worker (tp1k8s-worker, tp1k8s-worker2, tp1k8s-worker3)
- Un registry local sur le port 5000
- Metrics server installé
- Nerdctl installé sur tous les nœuds

## Ressources et liens utiles

- [Documentation officielle de Kind](https://kind.sigs.k8s.io/)
- [Documentation officielle de Kubernetes](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Repository GitHub de Kind](https://github.com/kubernetes-sigs/kind)

## Notes importantes

- Le cluster est temporaire et sera supprimé au redémarrage de la machine
- Pour un usage permanent, pensez à sauvegarder vos manifests YAML
- Les ports 8080 et 8443 sont utilisés à la place de 80 et 443 pour éviter les conflits
- Le registry local permet de pousser des images personnalisées

---

**Auteur :** [Kylian ADAM](kylian.adam@uha.fr)  
**Date :** Octobre 2025  
**Version :** 1.0

