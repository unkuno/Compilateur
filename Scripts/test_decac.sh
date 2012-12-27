ENTREE=$1

ATTENDU=$(echo $ENTREE | sed 's/.*\/\(\(Inv\|V\)alide\)\/.*/\1/')
NOM=$(echo $ENTREE | sed 's/.*\/\([^/]*\)/\1/')
ID=$(echo $NOM | sed 's/\(.*\)\.[^.]*/\1/')
EXTENSION=$(echo $NOM | sed 's/.*\(\.[^.]*\)/\1/')

mkdir -p $GL/Decac/Test/Sortie/{Inv,V}alide

S1=$GL/Decac/Test/Sortie/$ATTENDU/$ID.lis
S2=$GL/Decac/Test/Sortie/$ATTENDU/$ID.ass
touch $S1

(
    cd $GL/Decac/Test/
    OPTIONS=$(cat $GL/$ENTREE | grep -v //)
    $GL/Exec/decac $OPTIONS > $S1
    if [ $(find . -maxdepth 1 -name '*.ass' | wc -l) -eq 0 ] 
    then
	#echo coucou
	touch $ID.ass
    fi
    #echo $(pwd)
    #ls
    #echo $(find . -maxdepth 1 -name '*.ass' | head -n 1)
    #echo $S2
    mv $(find . -maxdepth 1 -name '*.ass' | head -n 1) $S2
)