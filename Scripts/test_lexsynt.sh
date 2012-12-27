ENTREE=$1

ATTENDU=$(echo $ENTREE | sed 's/.*\/\(\(Inv\|V\)alide\)\/.*/\1/')
NOM=$(echo $ENTREE | sed 's/.*\/\([^/]*\)/\1/')
ID=$(echo $NOM | sed 's/\(.*\)\.[^.]*/\1/')
EXTENSION=$(echo $NOM | sed 's/.*\(\.[^.]*\)/\1/')

DOSSIER_SORTIES=$GL/Syntaxe/Test/Sortie

mkdir -p $DOSSIER_SORTIES/Lexical/Valide
mkdir -p $DOSSIER_SORTIES/Syntaxique/Valide
mkdir -p $DOSSIER_SORTIES/Arbre/Valide
mkdir -p $DOSSIER_SORTIES/Decompilation/Valide

mkdir -p $DOSSIER_SORTIES/Lexical/Invalide
mkdir -p $DOSSIER_SORTIES/Syntaxique/Invalide
mkdir -p $DOSSIER_SORTIES/Arbre/Invalide
mkdir -p $DOSSIER_SORTIES/Decompilation/Invalide
 

S1=$DOSSIER_SORTIES/Lexical/$ATTENDU/$ID.lex
Serr=$DOSSIER_SORTIES/Lexical/$ATTENDU/$ID.errlex

touch $S1
touch $Serr

$GL/Exec/test_lex $GL/$ENTREE $S1 2> $Serr


S1=$DOSSIER_SORTIES/Syntaxique/$ATTENDU/$ID.synt
S2=$DOSSIER_SORTIES/Arbre/$ATTENDU/$ID.arbre
S3=$DOSSIER_SORTIES/Decompilation/$ATTENDU/$ID.decompil
Serr=$DOSSIER_SORTIES/Syntaxique/$ATTENDU/$ID.errsynt

touch $S1
touch $S2
touch $S3
touch $Serr

$GL/Exec/test_synt $GL/$ENTREE $S1 $S2 $S3 2> $Serr