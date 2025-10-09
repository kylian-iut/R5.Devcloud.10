# Sécurité des images docker
## docker history
```bash
docker history @image_name
```
Permet de voir les différentes couches qui sont créées, leur taille et les commandes qui sont générées.

## Hadolint
Logiciel permettant de tester un Dockerfile
```bash
git clone https://github.com/hadolint/hadolint \
  && cd hadolint \
  && cabal configure \
  && cabal build \
  && cabal install

sudo ./hadolint.sh Dockerfile
```

## Trivy
```bash
docker run -it aquasec/trivy image python:3.12-alpine
```
Cette commande permet de voir les vulnéarbilité de l'image python:3.12-alpine

## Dive
### Installation
```bash
DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -fOL "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.deb"
sudo apt install ./dive_${DIVE_VERSION}_linux_amd64.deb
```

### Utilisation
```bash
sudo dive python:3.12-alpine
#OU
sudo dive build -t some-tag .
```
