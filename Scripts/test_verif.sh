ENTREE=$1

ATTENDU=$(echo $ENTREE | sed 's/.*\/\(\(Inv\|V\)alide\)\/.*/\1/')
NOM=$(echo $ENTREE | sed 's/.*\/\([^/]*\)/\1/')
ID=$(echo $NOM | sed 's/\(.*\)\.[^.]*/\1/')
EXTENSION=$(echo $NOM | sed 's/.*\(\.[^.]*\)/\1/')

mkdir -p $GL/Verif/Test/Sortie/{Inv,V}alide

S1=$GL/Verif/Test/Sortie/$ATTENDU/$ID.lis

$GL/Exec/test_verif $GL/$ENTREE > $S1
