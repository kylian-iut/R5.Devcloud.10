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

## Notes

- Le fichier `docker-compose.yml` doit être présent dans ce dossier.
- La stack sera déployée sous le nom `monapp`.

---

Bon déploiement !