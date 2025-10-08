# TD3 - Déploiement d'une application avec Vagrant et Docker

## Prérequis

- [Vagrant](https://www.vagrantup.com/)

## Instructions

1. **Démarrer la machine virtuelle :**
    ```bash
    vagrant up
    ```
    > À exécuter dans ce dossier.

2. **Déployer la stack Docker :**
    ```bash
    vagrant ssh vm1 -c "cd /vagrant; sudo docker stack deploy -c docker-compose.yml monapp"
    ```
3. **Vérifier la stack Docker :**
    ```bash
    vagrant ssh vm1 -c "sudo docker stack ps monapp"
    ```

## Se connecter à l'application

Par défaut, les machines ont les adresses suivantes :
```
192.168.56.11 (vm1)
192.168.56.12 (vm2)
```

L'application **bonjour** est sur le port **8000** de ces machines

L'application **aurevoir** est sur le port **8001** de ces machines

Vous pouvez changer ces adresses IP et les ports dans le **Vagrantfile**

### URL complète (remplacez le x, voir au-dessus)

```
http://192.168.56.1x:800x/[str:ton nom]
```

## Commandes de débogage

En cas de problème avec les services (erreur "task: non-zero exit"), utilisez ces commandes :

```bash
# Vérifier les logs des services
vagrant ssh vm1 -c "sudo docker service logs monapp_api1"

# Vérifier l'état des tâches
vagrant ssh vm1 -c "sudo docker stack ps monapp"

# Vérifier les ressources système
vagrant ssh vm1 -c "free -h"

# Vérifier les limites de mémoire des conteneurs
vagrant ssh vm1 -c "sudo docker stats"
```

## Notes

- Le fichier `docker-compose.yml` doit être présent dans ce dossier.
- La stack sera déployée sous le nom `monapp`.

---

Bon déploiement !