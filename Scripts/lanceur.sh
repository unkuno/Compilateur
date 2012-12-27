#! /bin/bash

###########################################
## DEFINITIONS CONSTANTES
###########################################

LISTE_ETAPES="Syntaxe Verif Gencode Decac"
NOM_FICHIER_CONFIG=.conf


GL=$(while ! test -d $(pwd)/Exec ; do cd .. ; done; pwd -P)
source $GL/Scripts/outils_traitement_chemins.sh


FICHIER_MAN="$GL/Docs/Man-Lanceur.txt"






verifie_test_commente() {
    COMMENTS=$(cat $1 | grep //)
    if [ $(echo $COMMENTS | wc -c) -le 15 ]
    then 
	avertissement "Le test $ENTREE ne semble pas bien commenté !"
    fi
}


###########################################
## PARSING DES OPTIONS : 
###########################################
COMPILATION=true
VALIDATION=true
HERITAGE=true
#-c desactiver compilation
#-v desactiver validation
EDITEUR=emacs

MODE_QUANTITE=ndef
LISTE=
#-f fournir une liste de fichiers a tester
#-e fournir une liste d'étape a tester
#-t tout tester
#-f -e -a incompatibles
NIVEAU=0
COMMENTAIRES=false

verifie_mode_quantite() {
    # Verification : $1 qu'on ne choisit pas 2 fois un modif de quantite
    if [ $MODE_QUANTITE != ndef ]
    then
	erreur "$1 impossible : Une liste de test a déjà été déterminée. [-f|-e|-a]"
    fi
}

verifie_etape_valide() {
    # Verification : $1 est une étape définie, avec un dossier et un fichier .conf valides
    NOM=$1
    TROUVE=false
    for i in $LISTE_ETAPES
    do
	if [ $i == $NOM ]
	then 
	    TROUVE=true
	fi
    done
    if ! $TROUVE
    then
	erreur "$NOM n'est pas une étape valide."
    fi
    if ! test -d $GL/$NOM
    then
	erreur "ERREUR INTERNE : $NOM n'a pas de dossier."
    fi
    if ! test -f $GL/$NOM/Test/$NOM_FICHIER_CONFIG
    then
	erreur "$NOM n'a pas de fichier de config."
    fi
}

verifie_fichier_valide() {
    # Verification : $1 est un fichier de l'extension définie dans le .conf
    CHEMIN=$1
    EXTENSION=$(echo $CHEMIN | sed 's/.*\(\..*\)/\1/')
    ETAPE=$(echo $CHEMIN | sed 's/\([^/]*\).*/\1/')

    verifie_etape_valide $ETAPE

    if ! test -f $GL/$CHEMIN
    then 
	erreur "$CHEMIN n'est pas un fichier valide."
    fi

    EXTENSION_ATTENDUE=$(. $GL/$ETAPE/Test/$NOM_FICHIER_CONFIG ; echo $ENTREE)
    if [ $EXTENSION != $EXTENSION_ATTENDUE ]
    then 
	erreur "$CHEMIN n'a pas l'extension attendue ($EXTENSION_ATTENDUE)"
    fi
    trace "CHEMIN    = $CHEMIN"
    trace "EXTENSION = $EXTENSION"
    trace "EXT_ATT   = $EXTENSION_ATTENDUE"
    trace "ETAPE     = $ETAPE"
}



ATTENTE_LISTE=false
while [ 1 -le $# ]
do
    #printf "\"$1\"\n"
    case "$1" in
	-c | --no-compilation ) 
	    COMPILATION=false
	    ATTENTE_LISTE=false;;
	-v | --no-validation ) 
	    VALIDATION=false
	    ATTENTE_LISTE=false;;
	-x | --no-exhaustive ) 
	    HERITAGE=false
	    ATTENTE_LISTE=false;;

	#-f | --fichiers)
	#    verifie_mode_quantite $1
	#    MODE_QUANTITE=fichiers
	#    ATTENTE_LISTE=true;;
	-e | --etapes)
	    verifie_mode_quantite $1
	    MODE_QUANTITE=etapes
	    ATTENTE_LISTE=true;;
	-t | --tout)
	    verifie_mode_quantite $1
	    MODE_QUANTITE=tout
	    ATTENTE_LISTE=true;;
	
	-n[0-9]  | -n[0-9]c)
	    if echo "$1" | grep "c" > /dev/null
	    then 
		COMMENTAIRES=true
	    fi
	    NIVEAU=$(echo $1 | sed 's/[^0-9]//g')
	    ATTENTE_LISTE=false
	    ;;
	
	-h | --help | ? | man | --man )
	    less $FICHIER_MAN
	    exit 0;;
	
	* ) 
	    if ! $ATTENTE_LISTE
	    then
		erreur "Option \"$1\" invalide"
	    else
		if [ $MODE_QUANTITE == fichiers ]
		then 
		    #verifie_fichier_valide $1
		    true
		elif [ $MODE_QUANTITE == etapes ]
		then 
		    verifie_etape_valide $1
		else
		    erreur "ERREUR DU SCRIPT : ON attend une liste alors que ni fichiers ni etapes"
		fi
		LISTE="$LISTE $1"
	    fi;;
    esac
    shift
done


if [ $MODE_QUANTITE == ndef ]
then
    MODE_QUANTITE=tout
fi


###########################################
## TRACE RAPPORT SUR LES OPTIONS
###########################################
trace "Rapport sur les options :"
trace "*************************"
trace_bool $COMPILATION "Compilation : VERBE" "Oui" "Non"
trace_bool $VALIDATION  "Validation  : VERBE" "Oui" "Non"
trace

trace "Quantite a tester : $MODE_QUANTITE"
if [ $MODE_QUANTITE != tout ]
then
    trace "Liste : $LISTE"
fi

trace_bool $COMMENTAIRES "Niveau de détail des traces : $NIVEAU VERBE affichages des commentaires." "avec" "sans"
trace;trace


















teste_fichier() {
# $1 Contient le chemin relatif à $GL du fichier a tester

    local ETAPE=$(get_ETAPE $1)
    local ATTENDU=$(get_ATTENDU $1)
    local DOSSIER_TESTS=$GL/$ETAPE/Test 

    local FICHIER_ENTREE=$1
    local NOM_ENTREE=$(get_NOM $1)
    local EXTENSION_ENTREE=$(get_EXTENSION $1)

    local ID=$(get_ID $1)


    source $GL/$ETAPE/Test/$NOM_FICHIER_CONFIG


# Compilation :
    if $COMPILATION 
    then
	source $GL/$EXE $FICHIER_ENTREE
    fi
    
# Validation
    if [ $ATTENDU == "Valide" ]
    then
	local SORTIES=$SORTIES_VALIDE
    else
	local SORTIES=$SORTIES_INVALIDE
    fi
    
    
    local LISTE_A_AFFICHER="$GL/$FICHIER_ENTREE"

    
    NOMBRE_SORTIES=0
    NOMBRE_SUCCES=0
    
    if [ $NIVEAU -gt 2 ]
    then
	echo " - $NOM_ENTREE : "
    fi
    if $COMMENTAIRES && [ $NIVEAU -gt 2 ]
    then
	verifie_test_commente "$GL/$1"
	printf "\033[02m"
	cat "$GL/$1" | grep -e "^// *[a-zA-Z]" | sed 's/^\/\//\t\/\//' | grep //
	printf '\033[0m'
    fi
    
    for SORTIE in $SORTIES
    do
	NOMBRE_SORTIES=$(($NOMBRE_SORTIES+1))
	local SORTIE_EXT=$(echo $SORTIE     | sed 's/\([^:]*\):\([^:]*\):\([^:]*\)/\1/')
	local SORTIE_DOSSIER=$(echo $SORTIE | sed 's/\([^:]*\):\([^:]*\):\([^:]*\)/\2/')
	local SORTIE_VERIF=$(echo $SORTIE    | sed 's/\([^:]*\):\([^:]*\):\([^:]*\)/\3/')


	local NOM_SORTIE=$ID$SORTIE_EXT
	local FICHIER_SORTIE=$DOSSIER_TESTS/$SORTIE_DOSSIER/$NOM_SORTIE


	local LISTE_A_AFFICHER="$FICHIER_SORTIE $LISTE_A_AFFICHER"
	
	local FICHIER_ATTENDU="$FICHIER_SORTIE.attendu" 
	if test -f $FICHIER_ATTENDU 
	then
	    local FICHIER_ATTENDU_EXISTANT=true
	    local LISTE_A_AFFICHER="$FICHIER_ATTENDU $LISTE_A_AFFICHER"
	else
	    local FICHIER_ATTENDU_EXISTANT=false
	fi

	local FICHIER_VALIDE="$FICHIER_SORTIE.valide"
	if test -f $FICHIER_VALIDE 
	then
	    local FICHIER_VALIDE_EXISTANT=true
	    local LISTE_A_AFFICHER="$FICHIER_VALIDE $LISTE_A_AFFICHER"
	else
	    local FICHIER_VALIDE_EXISTANT=false
	fi

	local CORRECT=false



 # Verification par rapport a l'attendu :
	if  ! $CORRECT && $FICHIER_ATTENDU_EXISTANT && [ $(diff $FICHIER_ATTENDU $FICHIER_SORTIE | wc -c) -eq 0 ]
	then 
	    if [ $NIVEAU -gt 3 ]
	    then
		echo -n "            - $NOM_SORTIE : "
		print_correct
	    fi
	    

	    CORRECT=true
	    RAISON="(Egalite parfaite avec l'attendu)"
	fi
	
# Verification par rapport au dernier validé :
	if ! $CORRECT && $FICHIER_VALIDE_EXISTANT && [ $(diff $FICHIER_VALIDE $FICHIER_SORTIE | wc -c) -eq 0 ]
	then 
	    if [ $NIVEAU -gt 3 ]
	    then
		echo -n "            - $NOM_SORTIE : "
		print_correct
	    fi
	    
	    CORRECT=true
	    RAISON="(Egalite parfaite avec l'ancien validé)"
	fi

# Vérification par demande ou par la commande choisie
	if ! $CORRECT
	then
	    if [ $SORTIE_VERIF == "AUTO" ]
	    then
		#if [ $NIVEAU -gt 0 ] && [ $NIVEAU -lt 3 ]
		#then
		#    echo
		#fi
		if [ $NIVEAU -gt 2 ]
		then
		    echo -n "            - $NOM_SORTIE : "
		fi
		if $VALIDATION
		then
		    $EDITEUR $LISTE_A_AFFICHER 2> /dev/null &
		    echo
		    echo -n "Validation manuelle de la sortie $NOM_SORTIE. Votre avis ? "
		    if $GL/Exec/demande
		    then
			CORRECT=true 
			if [ $NIVEAU -gt 3 ]
			then
			    echo -n "            - $NOM_SORTIE : "
			    print_correct
			fi
			cp $FICHIER_SORTIE $FICHIER_VALIDE
		    else
			if [ $NIVEAU -gt 2 ]
			then
			    echo -n "            - $NOM_SORTIE : "
			    print_incorrect
			fi
		    fi
		else
		    if [ $NIVEAU -gt 2 ]
		    then
			print_inverifie
		    fi
		fi
		RAISON="(Validation manuelle)"
	    else
		eval $SORTIE_VERIF $FICHIER_ENTREE $FICHIER_SORTIE
		case $? in
		    0)
			CORRECT=true
			if [ $NIVEAU -gt 3 ]
			then
			    echo -n "            - $NOM_SORTIE : "
			    print_correct
			fi
			RAISON="(Validation automatique : $SORTIE_VERIF)"
			;;
		    1)
			if [ $NIVEAU -gt 2 ]
			then
			    echo -n "            - $NOM_SORTIE : "
			    print_incorrect
			fi
			RAISON="(Validation automatique : $SORTIE_VERIF)"
			;;
		    2)
			if [ $NIVEAU -gt 2 ]
			then
			    echo -n "            - $NOM_SORTIE : "
			fi
			if $VALIDATION
			then
			    echo
			    $EDITEUR $LISTE_A_AFFICHER 2> /dev/null &
			    echo -n "Validation automatique de $NOM_SORTIE par $SORTIE_VERIF non concluante. Votre avis ? "
			    if $GL/Exec/demande
			    then
				CORRECT=true
				if [ $NIVEAU -gt 3 ]
				then
				    echo -n "            - $NOM_SORTIE : "
				    print_correct
				fi
				cp $FICHIER_SORTIE $FICHIER_VALIDE
			    else
				if [ $NIVEAU -gt 2 ]
				then
				    echo -n "            - $NOM_SORTIE : "
				    print_incorrect
				fi
			    fi
			else
			    if [ $NIVEAU -gt 2 ]
			    then
				print_inverifie
			    fi
			fi
			RAISON="(Confirmation manuelle car $SORTIE_VERIF indécis)"
			;;
		    *)
			erreur "ERREUR_INTERNE A LA TEST-SUITE"
			;;
		esac
	    fi
	fi
	
	if ( $CORRECT && [ $NIVEAU -gt 3 ] ) || ( ! $CORRECT && [ $NIVEAU -gt 2 ] )
	then
	    echo " $RAISON"
	fi

	if $CORRECT
	then
	    NOMBRE_SUCCES=$(($NOMBRE_SUCCES + 1))
	fi
	
    done
    test $NOMBRE_SUCCES -eq $NOMBRE_SORTIES
}




rapport_fichier() {
    if teste_fichier $1
    then
	SUCCES=true
	NOMBRE_CORRECTS=$(($NOMBRE_CORRECTS+1))
    else
	SUCCES=false
	LISTE_ECHOUES="$LISTE_ECHOUES $1"
    fi
    NOMBRE_TESTES=$(($NOMBRE_TESTES+1))

    if [ $NIVEAU -gt 2 ]
    then
	if ! $SUCCES
	then
#	    echo -n " - $1 : "
#	    print_incorrect
#	    echo " $RAISON"
	    true
	fi
    fi
}


rapport_final() {
    if [ $NIVEAU -gt 0 ]
    then
	local POURCENTAGE=$(($NOMBRE_CORRECTS * 100 / $NOMBRE_TESTES))
	local COULEUR
	if [ $NOMBRE_TESTES -eq $NOMBRE_CORRECTS ]
	then
	    COULEUR="\033[00;36m"
	else
	    COULEUR="\033[00;31m"
	fi
	echo
	printf "\033[01m"
	echo -n "Rapport final : "
	printf '\033[0m'
	printf "$COULEUR"
	echo -n "$NOMBRE_CORRECTS / $NOMBRE_TESTES" 
	printf '\033[0m'
	echo -n " tests réussis "
	printf "$COULEUR"
	echo -n "($POURCENTAGE%)"
	printf '\033[0m'
	echo
    fi
    if [ $NIVEAU -gt 1 ]
    then
	if [ $NOMBRE_TESTES -ne $NOMBRE_CORRECTS ]
	then
	    echo "Fichiers non conformes :"
	    for FICHIER_ECHOUE in $LISTE_ECHOUES
	    do
		echo -n " - "
		printf "\033[00;31m"
		FICHIER_ECHOUE_RENOME=$(echo $FICHIER_ECHOUE | sed 's/.*Test\///')
		echo "$FICHIER_ECHOUE_RENOME"
		printf '\033[0m'
	    done
	fi
    fi
}














###########################################
## EXECUTION
###########################################
if [ $MODE_QUANTITE == etapes ] || [ $MODE_QUANTITE == tout ] 
then
    if [ $MODE_QUANTITE == etapes ]
    then
	LISTE_ETAPES_A_TESTER=$LISTE
    else
	LISTE_ETAPES_A_TESTER=$LISTE_ETAPES
    fi


    # MODE Etape par etape
    TOUTES_ETAPES_SUCCES=true
    for ETAPE in $LISTE_ETAPES_A_TESTER
    do 
	
	NOMBRE_TESTES=0
	NOMBRE_CORRECTS=0
	LISTE_ECHOUES=""
	
	if [ $NIVEAU -gt 0 ] 
	then
	printf "\033[01m"
	    echo "#############################"
	    echo "# Tests sur l'étape $ETAPE : "
	    echo "#############################"
	printf '\033[0m'
	fi
	verifie_etape_valide $ETAPE

	DOSSIER_TESTS=$GL/$ETAPE/Test 

	source $DOSSIER_TESTS/$NOM_FICHIER_CONFIG
	EXTENSION_RECHERCHEE=$ENTREE

	if [ $NIVEAU -ge 1 ] && [ $NIVEAU -le 2 ]
	then
	    echo -n "Traitement en cours "
	fi
	for VALIDITE in Valide Invalide
	do
	    if [ $NIVEAU -gt 2 ]
	    then
		printf "\033[00;35m"
		echo "# $VALIDITE ->"
		printf '\033[0m'
	    fi
	    if $HERITAGE
	    then
		LISTE_FICHIERS=$(find -L $DOSSIER_TESTS/$VALIDITE -name "*$EXTENSION_RECHERCHEE")
	    else
		LISTE_FICHIERS=$(find $DOSSIER_TESTS/$VALIDITE -name "*$EXTENSION_RECHERCHEE")
	    fi
	    #echo "***************************"
	    #echo "Fichiers ($VALIDITE) trouvés"
	    #echo $LISTE_FICHIERS | tr " " "\n"
	    #echo "***************************"
	    #echo; echo
	    
	    for FICHIER_A_TESTER in $LISTE_FICHIERS
	    do	
		rapport_fichier $(relativise $FICHIER_A_TESTER)
		if [ $NIVEAU -ge 1 ] && [ $NIVEAU -le 2 ]
		then
		    echo -n "."
		fi
	    done
	done
	if [ $NIVEAU -ge 1 ] && [ $NIVEAU -le 2 ]
	then
	    echo
	fi
	rapport_final
	if [ $NIVEAU -gt 0 ] 
	then
	    echo
	fi
	if $TOUTES_ETAPES_SUCCES && [ $NOMBRE_TESTES -ne $NOMBRE_CORRECTS ]
	then
	    TOUTES_ETAPES_SUCCES=false
	fi
    done
    test $TOUTES_ETAPES_SUCCES == true
else
    erreur "Not Implemented"
    LISTE_FICHIERS_A_TESTER=$LISTE
    for FICHIER_A_TESTER in $LISTE_FICHIERS_A_TESTER
    do
	FICHIER_A_TESTER=$(relativise $FICHIER_A_TESTER)
	echo "- $FICHIER_A_TESTER :"
	rapport_fichier $FICHIER_A_TESTER
    done
fi










