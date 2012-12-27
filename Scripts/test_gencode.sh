ENTREE=$1

ATTENDU=$(echo $ENTREE | sed 's/.*\/\(\(Inv\|V\)alide\)\/.*/\1/')
NOM=$(echo $ENTREE | sed 's/.*\/\([^/]*\)/\1/')
ID=$(echo $NOM | sed 's/\(.*\)\.[^.]*/\1/')
EXTENSION=$(echo $NOM | sed 's/.*\(\.[^.]*\)/\1/')


mkdir -p $GL/Gencode/Test/Sortie/CodeGen/{Inv,V}alide
mkdir -p $GL/Gencode/Test/Sortie/ExeCodeGen/{Inv,V}alide


S0=$(pwd)/$ID.ass

touch $S0

S1=$GL/Gencode/Test/Sortie/CodeGen/$ATTENDU/$ID.ass
Serr=$GL/Gencode/Test/Sortie/CodeGen/$ATTENDU/$ID.errass
touch $Serr

$GL/Exec/test_gencode $GL/$ENTREE > $Serr
mv $S0 $S1

S2=$GL/Gencode/Test/Sortie/ExeCodeGen/$ATTENDU/$ID.exec
Serr=$GL/Gencode/Test/Sortie/ExeCodeGen/$ATTENDU/$ID.errexec

touch $S2
touch $Serr

ima $S1 > $S2 2> $Serr