# TD Kubernetes - Premiers pas avec Kubernetes

Ce TD vous permet de vous familiariser avec Kubernetes en utilisant les deux modes principaux :
- Le mode **déclaratif** qui déclare dans des fichiers *manifest.yaml* les éléments de configurations
- Le mode **impératif** où l'on donne des ordres via ligne de commande

## Prérequis

- Docker installé et fonctionnel
- kubectl installé
- kind installé
- Avoir suivi le TD de création de cluster

## Création du cluster pour ce TD

### 1. Créer le cluster spécifique
```bash
chmod +x create-cluster.sh
sudo ./create-cluster.sh
```

### 2. Configurer kubectl pour ce cluster
```bash
export KUBECONFIG=$(pwd)/kubeconfig-premiers-pas-k8s
```

### 3. Vérifier que le cluster fonctionne
```bash
kubectl cluster-info
kubectl get nodes
```

## Mode impératif - Commandes de base

### Créer un pod simple
```bash
kubectl run nginx-pod --image nginx
```

### Vérifier le pod créé
```bash
kubectl get pods
kubectl describe pod nginx-pod
```

### Se connecter au pod
```bash
kubectl exec -it nginx-pod -- sh
# Une fois dans le pod, vous pouvez explorer :
# ls /usr/share/nginx/html
# exit pour sortir
```

### Créer un déploiement
```bash
kubectl create deployment hello-nginx --image nginx
```

### Scaler le déploiement
```bash
kubectl scale deployment hello-nginx --replicas 2
```

### Vérifier les pods du déploiement
```bash
kubectl get pods -l app=hello-nginx
kubectl get deployment hello-nginx
```

### Exposer le déploiement
```bash
kubectl expose deployment hello-nginx --type=LoadBalancer --port 80 --target-port 80
```

### Vérifier le service créé
```bash
kubectl get services
kubectl describe service hello-nginx
```

### Accéder au service
Avec kind, les services LoadBalancer nécessitent une configuration spéciale. Utilisez port-forward :

⚠️ **Note importante** : Le port 8080 est déjà utilisé par le cluster kind. Utilisez un port différent !

```bash
# Vérifier les ports utilisés
sudo ss -tlnp | grep :8080

# Utiliser un port libre (ex: 9080)
kubectl port-forward service/hello-nginx 9080:80 &

# Tester l'accès
curl http://localhost:9080

# Arrêter le port-forward
kill %1
```

## Commandes utiles pour l'exploration

### Voir tous les objets créés
```bash
kubectl get all
```

### Obtenir des informations détaillées
```bash
kubectl describe pod nginx-pod
kubectl describe deployment hello-nginx
kubectl describe service hello-nginx
```

### Voir les logs d'un pod
```bash
kubectl logs nginx-pod
kubectl logs -l app=hello-nginx
```

### Supprimer les objets créés
```bash
kubectl delete pod nginx-pod
kubectl delete deployment hello-nginx
kubectl delete service hello-nginx
```

### Tester l'accès au service
```bash
# Méthode 1 : Port forwarding (utiliser un port libre !)
# Vérifier d'abord les ports occupés
sudo ss -tlnp | grep :8080

# Utiliser un port différent si 8080 est occupé
kubectl port-forward service/hello-nginx 9080:80 &
curl http://localhost:9080
# Arrêter le port-forward avec : kill %1

# Méthode 2 : NodePort (ne fonctionne pas toujours avec kind)
kubectl get service hello-nginx
# Le port 30xxx affiché peut ne pas être accessible directement

# Méthode 3 : Accès direct via l'IP du pod (pour tests)
kubectl get pods -o wide
# Utiliser l'IP du pod directement (ex: curl http://10.244.x.x)
```

### Examiner les fichiers dans les pods
```bash
kubectl exec nginx-pod -- ls /usr/share/nginx/html
kubectl exec nginx-pod -- cat /usr/share/nginx/html/index.html
```

## Nettoyage

### Supprimer tous les objets créés
```bash
kubectl delete pod nginx-pod
kubectl delete deployment hello-nginx  
kubectl delete service hello-nginx
```

### Ou supprimer tout d'un coup
```bash
kubectl delete all --all
```

### Supprimer le cluster à la fin du TD
```bash
sudo kind delete cluster --name premiers-pas-k8s
```

## Mode déclaratif

Vous pouvez également créer les mêmes objets en utilisant des fichiers YAML.

### Utiliser le manifest.yaml
```bash
# Appliquer tous les objets définis dans le fichier
kubectl apply -f manifest.yaml

# Vérifier les objets créés
kubectl get all -l app=nginx
kubectl get all -l app=hello-nginx-declaratif

# Modifier le fichier et ré-appliquer
kubectl apply -f manifest.yaml

# Supprimer les objets définis dans le fichier
kubectl delete -f manifest.yaml
```

### Avantages du mode déclaratif
- **Versionning** : Les fichiers YAML peuvent être versionnés avec Git
- **Reproductibilité** : Même configuration sur tous les environnements
- **Automation** : Facile à intégrer dans des pipelines CI/CD
- **Rollback** : Possibilité de revenir à une version précédente

## Résumé des concepts

- **Pod** : La plus petite unité déployable, contient un ou plusieurs conteneurs
- **Deployment** : Gère les pods et assure leur disponibilité
- **Service** : Expose les pods en réseau et fait du load balancing
- **ReplicaSet** : Créé automatiquement par le Deployment pour gérer les réplicas

## Commandes de débug utiles

```bash
# Voir les events du cluster
kubectl get events

# Décrire un objet pour plus d'infos
kubectl describe pod nginx-pod
kubectl describe deployment hello-nginx

# Voir les logs
kubectl logs nginx-pod
kubectl logs -l app=hello-nginx

# Obtenir des informations au format YAML
kubectl get pod nginx-pod -o yaml
kubectl get deployment hello-nginx -o yaml
```

## Troubleshooting

### Erreur "address already in use" avec port-forward
Si vous obtenez cette erreur :
```
Error listen tcp4 127.0.0.1:8080: bind: address already in use
```

**Solutions :**
```bash
# 1. Vérifier quel processus utilise le port
sudo ss -tlnp | grep :8080
sudo netstat -tlnp | grep :8080  # alternative

# 2. Utiliser un port différent
kubectl port-forward service/hello-nginx 9080:80

# 3. Tuer le processus qui utilise le port (attention !)
# sudo kill <PID_du_processus>

# 4. Trouver un port libre automatiquement
kubectl port-forward service/hello-nginx :80
# Kubectl choisira un port libre automatiquement
```

### Service LoadBalancer reste en "pending"
Avec kind, c'est normal. Les solutions :
```bash
# 1. Utiliser port-forward (recommandé)
kubectl port-forward service/hello-nginx 9080:80

# 2. Changer le type de service en NodePort
kubectl patch service hello-nginx -p '{"spec":{"type":"NodePort"}}'
kubectl get service hello-nginx  # Noter le port 30xxx

# 3. Utiliser un ingress controller (avancé)
```

### Pod en état "Pending" ou "ImagePullBackOff"
```bash
# Voir les détails du problème
kubectl describe pod <nom-du-pod>

# Vérifier les events
kubectl get events --sort-by='.lastTimestamp'

# Si c'est un problème d'image, vérifier qu'elle existe
docker pull nginx
kind load docker-image nginx --name premiers-pas-k8s
```

