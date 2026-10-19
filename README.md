# nemo-pathbar-new-folder

**[Français](#français) · [English](#english)**

Patch for [Nemo](https://github.com/linuxmint/nemo) (the Linux Mint / Cinnamon file manager) that adds **"Create New Folder"** to the right-click menu of the path bar buttons.

Patch pour [Nemo](https://github.com/linuxmint/nemo) (le gestionnaire de fichiers de Linux Mint / Cinnamon) qui ajoute **« Créer un nouveau dossier »** au menu clic droit des boutons de la barre de chemin.

```
 ┌──────┬────────────┬──────────────┐
 │ oem  │ Documents  │ Android_apps │   ← right-click / clic droit
 └──────┴────────────┴──────────────┘
          │
          ├─ Ouvrir dans un nouvel onglet
          ├─ Ouvrir dans une nouvelle fenêtre
          ├─────────────
          ├─ Créer un nouveau dossier   ← new / nouveau
          ├─────────────
          ├─ Couper / Copier / Coller dans le dossier
          └─ …
```

---

## Français

### Pourquoi un patch ?

Le menu clic droit de la barre de chemin de Nemo est défini en dur dans le code (`gresources/nemo-directory-view-ui.xml`, popup `location`). Contrairement aux autres menus, il n'a **aucun emplacement pour les actions Nemo** (`.nemo_action`) ni pour les extensions Python. Une action personnalisée apparaît donc dans la liste de fichiers et l'arborescence de gauche, mais **jamais** dans la barre de chemin. La seule solution est de modifier Nemo et de le recompiler.

### Fonctionnement

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

### Installation

#### Option A — binaire précompilé (Linux Mint 22.x, Nemo 6.6.3 uniquement)

Vérifier la version : `nemo --version` doit afficher `nemo 6.6.3`.

```bash
git clone https://github.com/mastertarace/nemo-pathbar-new-folder.git
cd nemo-pathbar-new-folder
wget https://github.com/mastertarace/nemo-pathbar-new-folder/releases/download/v6.6.3-1/nemo
chmod +x nemo
sudo scripts/install.sh ./nemo
nemo -q && nemo &
```

#### Option B — compiler depuis les sources (recommandé)

```bash
git clone https://github.com/mastertarace/nemo-pathbar-new-folder.git
cd nemo-pathbar-new-folder
scripts/build.sh --deps     # installe les dépendances (sudo), clone Nemo, applique le patch, compile
sudo scripts/install.sh     # remplace /usr/bin/nemo, garde l'original
nemo -q && nemo &           # redémarre Nemo
```

`build.sh` compile la version de Nemo installée sur la machine (ou celle passée en argument : `scripts/build.sh 6.6.3`). Si le patch ne s'applique pas sur cette version, le script s'arrête avec un message.

### Utilisation

Clic droit sur un bouton de la barre de chemin (ex. `Documents`) → **Créer un nouveau dossier** → taper le nom → Entrée.

### Désinstallation

```bash
sudo scripts/uninstall.sh
nemo -q && nemo &
```

### Mises à jour de Nemo

Grâce à `dpkg-divert`, une mise à jour `apt` de Nemo installe le nouveau binaire sous `/usr/bin/nemo.distrib` et **n'écrase pas** la version patchée. Mais elle ne reçoit plus les correctifs : après une mise à jour de Nemo, relancer `scripts/build.sh` puis `sudo scripts/install.sh`.

### Bonus : action Nemo sans compilation

Le dossier `nemo-action/` contient une action Nemo classique (« Nouveau dossier ici… ») qui ne demande **ni compilation ni sudo**. Elle apparaît au clic droit sur un dossier dans la liste de fichiers et dans l'arborescence de gauche, **pas** dans la barre de chemin. Dépend de `zenity`.

```bash
scripts/install-action.sh
```

Pour la retirer : `rm ~/.local/share/nemo/actions/nouveau-dossier.*`

---

## English

### Why a patch?

Nemo's path bar context menu is hard-coded (`gresources/nemo-directory-view-ui.xml`, `location` popup). Unlike the other menus, it has **no placeholder for Nemo actions** (`.nemo_action`) or Python extensions. A custom action therefore shows up in the file list and the sidebar tree, but **never** in the path bar. The only way is to modify and rebuild Nemo.

### How it works

The patch (`patches/nemo-6.6.3-pathbar-new-folder.patch`, ~70 lines) touches 3 files:

| File | Change |
|---|---|
| `src/nemo-actions.h` | new constant `NEMO_ACTION_LOCATION_NEW_FOLDER` |
| `gresources/nemo-directory-view-ui.xml` | menu item added to the `location` popup |
| `src/nemo-view.c` | callback + action entry + sensitive/visible state |

When the item is clicked:
1. a dialog asks for the name (default: "Untitled Folder");
2. the folder is created **inside the folder of the clicked button** (not necessarily the one being displayed);
3. on error (name taken, permissions…), an error dialog is shown.

The item is **greyed out** when the folder is not writable and **hidden** in "Recent". Labels reuse strings Nemo already translates, so the item shows in the system language.

UI resources are compiled into the `nemo` binary: only `/usr/bin/nemo` is replaced. The original binary is kept with `dpkg-divert`.

### Installation

#### Option A — prebuilt binary (Linux Mint 22.x, Nemo 6.6.3 only)

Check the version: `nemo --version` must print `nemo 6.6.3`.

```bash
git clone https://github.com/mastertarace/nemo-pathbar-new-folder.git
cd nemo-pathbar-new-folder
wget https://github.com/mastertarace/nemo-pathbar-new-folder/releases/download/v6.6.3-1/nemo
chmod +x nemo
sudo scripts/install.sh ./nemo
nemo -q && nemo &
```

#### Option B — build from source (recommended)

```bash
git clone https://github.com/mastertarace/nemo-pathbar-new-folder.git
cd nemo-pathbar-new-folder
scripts/build.sh --deps     # installs build deps (sudo), clones Nemo, applies the patch, builds
sudo scripts/install.sh     # replaces /usr/bin/nemo, keeps the original
nemo -q && nemo &           # restart Nemo
```

`build.sh` builds the Nemo version installed on the machine (or the one given as argument: `scripts/build.sh 6.6.3`). If the patch does not apply to that version, the script stops with a message.

### Usage

Right-click a path bar button (e.g. `Documents`) → **Create New Folder** → type the name → Enter.

### Uninstall

```bash
sudo scripts/uninstall.sh
nemo -q && nemo &
```

### Nemo updates

Thanks to `dpkg-divert`, an `apt` upgrade of Nemo installs the new binary as `/usr/bin/nemo.distrib` and **does not overwrite** the patched one. But the patched binary no longer gets the fixes: after a Nemo upgrade, run `scripts/build.sh` then `sudo scripts/install.sh` again.

### Bonus: Nemo action, no build needed

The `nemo-action/` folder contains a regular Nemo action ("Nouveau dossier ici…", French labels) that needs **no build and no sudo**. It shows when right-clicking a folder in the file list and in the sidebar tree, **not** in the path bar. Requires `zenity`.

```bash
scripts/install-action.sh
```

To remove it: `rm ~/.local/share/nemo/actions/nouveau-dossier.*`

---

## Repository layout / Contenu du dépôt

```
patches/nemo-6.6.3-pathbar-new-folder.patch   patch against linuxmint/nemo tag 6.6.3
scripts/build.sh                              clone + patch + build
scripts/install.sh                            install with dpkg-divert (sudo)
scripts/uninstall.sh                          restore original Nemo (sudo)
scripts/install-action.sh                     install the bonus Nemo action
nemo-action/                                  bonus Nemo action (.nemo_action + script)
```

Tested on / Testé sur : Linux Mint 22.3, Nemo 6.6.3+zena.

## License / Licence

GPL-2.0-or-later, like Nemo. / GPL-2.0 ou ultérieure, comme Nemo.
