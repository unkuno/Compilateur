GL=$(while ! [ -f Exec/decac ] ; do cd ../; done; pwd)
(cd $GL/Gencode/Test/Interactif; for i in *.deca; do $GL/Exec/decac $i; done)
$GL/Scripts/lanceur.sh -v -e Gencode -n2