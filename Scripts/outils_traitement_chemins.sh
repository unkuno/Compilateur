#! /bin/bash

# Un nom de fichier envoyé à ses procédure doit être relatif au dossier principal $GL

get_NOM() {
    echo $1 | sed 's/.*\/\([^/]*\)/\1/'
}

get_ID() {
    get_NOM $1 | sed 's/\(.*\)\.[^.]*/\1/'
}

get_EXTENSION() {
    get_NOM $1 | sed 's/.*\(\.[^.]*\)/\1/'
}

get_ATTENDU() {
    echo $1 | sed 's/.*\/\(\(Inv\|V\)alide\)\/.*/\1/'
}

get_ETAPE() {
    echo $1 | sed 's/\([^/]*\).*/\1/'
}

relativise() {
    local OPT="$GL/"
    OPT=$(echo $OPT | sed 's/\//\\\//g')
    echo $1 | sed "s/$OPT//"
}


###########################################
## DEFINITIONS OUTILS
###########################################
trace(){
    # fonction de trace a modifier / commenter si besoin
    # echo "$@"
    true
}

trace_bool(){
    # $1 Condition, $2 Texte contenant "VERBE"
    # $3 VERBE à l'affirmatif, $4 VERBE au négatif 
    if $1 
    then
	trace $2 | sed "s/VERBE/$3/"
    else
	trace $2 | sed "s/VERBE/$4/"
    fi
}

erreur(){
    echo "Erreur : $@"
    exit 1
}
avertissement(){
    echo "Warning : $@"
}


demande_old(){
    if [ $(exec $GL/Exec/demande | tail -n 1) == 1 ]
    then
	return 0
    else
	return 1
    fi
}

print_correct() {
    printf "\033[00;36m"
    echo -n "Correct"
    printf '\033[0m'
}

print_incorrect() {
    printf "\033[00;31m"
    echo -n "Incorrect"
    printf '\033[0m'
}

print_inverifie() {
    printf "\033[00;35m"
    echo -n "Non vérifié"
    printf '\033[0m'
}
