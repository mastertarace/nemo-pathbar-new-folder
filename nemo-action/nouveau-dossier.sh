#!/bin/bash
# Crée un sous-dossier dans le dossier cliqué (bouton de la barre de chemin ou dossier sélectionné).
parent="$1"
[ -d "$parent" ] || exit 1
name=$(zenity --entry --title="Nouveau dossier" \
  --text="Nom du nouveau dossier dans :\n$parent" --entry-text="Nouveau dossier") || exit 0
[ -n "$name" ] || exit 0
target="$parent/$name"
if [ -e "$target" ]; then
  zenity --error --text="« $name » existe déjà dans $parent"
  exit 1
fi
mkdir -- "$target" || zenity --error --text="Impossible de créer $target"
