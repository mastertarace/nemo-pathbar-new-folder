# nemo-pathbar-new-folder

[English](README.md) · **Français**

Patch pour [Nemo](https://github.com/linuxmint/nemo) (le gestionnaire de fichiers de Linux Mint / Cinnamon) qui ajoute **« Créer un nouveau dossier »** au menu clic droit des boutons de la barre de chemin.

```
 ┌──────┬────────────┬──────────────┐
 │ oem  │ Documents  │ Android_apps │   ← clic droit
 └──────┴────────────┴──────────────┘
          │
          ├─ Ouvrir dans un nouvel onglet
          ├─ Ouvrir dans une nouvelle fenêtre
          ├─────────────
          ├─ Créer un nouveau dossier   ← nouveau
          ├─────────────
          ├─ Couper / Copier / Coller dans le dossier
          └─ …
```

## Pourquoi un patch ?

Le menu clic droit de la barre de chemin de Nemo est défini en dur dans le code (`gresources/nemo-directory-view-ui.xml`, popup `location`). Contrairement aux autres menus, il n'a **aucun emplacement pour les actions Nemo** (`.nemo_action`) ni pour les extensions Python. Une action personnalisée apparaît donc dans la liste de fichiers et l'arborescence de gauche, mais **jamais** dans la barre de chemin. La seule solution est de modifier Nemo et de le recompiler.

## Fonctionnement

Le patch (`patches/nemo-6.6.3-pathbar-new-folder.patch`, ~70 lignes) modifie 3 fichiers :

| Fichier | Modification |
|---|---|
| `src/nemo-actions.h` | nouvelle constante `NEMO_ACTION_LOCATION_NEW_FOLDER` |
| `gresources/nemo-directory-view-ui.xml` | ajout de l'entrée dans le popup `location` |
| `src/nemo-view.c` | callback + déclaration de l'action + état grisé/visible |

Au clic sur l'entrée :
1. une fenêtre demande le nom (proposé : « Nouveau dossier ») ;
2. le dossier est créé **dans le dossier du bouton cliqué** (pas forcément le dossier affiché) ;
3. en cas d'erreur (nom déjà pris, droits…), un message s'affiche.

L'entrée est **grisée** si le dossier n'est pas accessible en écriture, et **masquée** dans « Récents ». Les textes réutilisent des chaînes déjà traduites par Nemo : l'entrée s'affiche donc dans la langue du système.

Les ressources de l'interface sont compilées dans le binaire `nemo` : seul `/usr/bin/nemo` est remplacé. Le binaire d'origine est conservé grâce à `dpkg-divert`.

## Installation

### Option A — binaire précompilé (Linux Mint 22.x, Nemo 6.6.3 uniquement)

Vérifier la version : `nemo --version` doit afficher `nemo 6.6.3`.

```bash
git clone https://github.com/mastertarace/nemo-pathbar-new-folder.git
cd nemo-pathbar-new-folder
wget https://github.com/mastertarace/nemo-pathbar-new-folder/releases/download/v6.6.3-1/nemo
chmod +x nemo
sudo scripts/install.sh ./nemo
nemo -q && nemo &
```

### Option B — compiler depuis les sources (recommandé)

```bash
git clone https://github.com/mastertarace/nemo-pathbar-new-folder.git
cd nemo-pathbar-new-folder
scripts/build.sh --deps     # installe les dépendances (sudo), clone Nemo, applique le patch, compile
sudo scripts/install.sh     # remplace /usr/bin/nemo, garde l'original
nemo -q && nemo &           # redémarre Nemo
```

`build.sh` compile la version de Nemo installée sur la machine (ou celle passée en argument : `scripts/build.sh 6.6.3`). Si le patch ne s'applique pas sur cette version, le script s'arrête avec un message.

## Utilisation

Clic droit sur un bouton de la barre de chemin (ex. `Documents`) → **Créer un nouveau dossier** → taper le nom → Entrée.

## Désinstallation

```bash
sudo scripts/uninstall.sh
nemo -q && nemo &
```

## Mises à jour de Nemo

Grâce à `dpkg-divert`, une mise à jour `apt` de Nemo installe le nouveau binaire sous `/usr/bin/nemo.distrib` et **n'écrase pas** la version patchée. Mais elle ne reçoit plus les correctifs : après une mise à jour de Nemo, relancer `scripts/build.sh` puis `sudo scripts/install.sh`.

## Bonus : action Nemo sans compilation

Le dossier `nemo-action/` contient une action Nemo classique (« Nouveau dossier ici… ») qui ne demande **ni compilation ni sudo**. Elle apparaît au clic droit sur un dossier dans la liste de fichiers et dans l'arborescence de gauche, **pas** dans la barre de chemin. Dépend de `zenity`.

```bash
scripts/install-action.sh
```

Pour la retirer : `rm ~/.local/share/nemo/actions/nouveau-dossier.*`

## Contenu du dépôt

```
patches/nemo-6.6.3-pathbar-new-folder.patch   patch sur le tag 6.6.3 de linuxmint/nemo
scripts/build.sh                              clone + patch + compilation
scripts/install.sh                            installation avec dpkg-divert (sudo)
scripts/uninstall.sh                          restauration du Nemo d'origine (sudo)
scripts/install-action.sh                     installation de l'action Nemo bonus
nemo-action/                                  action Nemo bonus (.nemo_action + script)
```

Testé sur : Linux Mint 22.3, Nemo 6.6.3+zena.

## Licence

GPL-2.0 ou ultérieure, comme Nemo.
