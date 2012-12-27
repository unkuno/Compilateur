#!/bin/bash
# permet de baisser les droits sur le fichier, de lancer decac dessus et de replacer les droits sur le fichier
echo Suppresion droit lecture sur le fichier deca
chmod u-r fichier_droits_insuffisant.deca
echo Appel de decac
echo ==================================
decac fichier_droits_insuffisant.deca
echo ==================================
echo Rétablissement droit lecture sur le fichier deca
chmod u+r fichier_droits_insuffisant.deca
exit 0
