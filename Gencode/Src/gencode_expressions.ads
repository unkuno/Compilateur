--------------------------------------------------------------------------------
--  Spécification du paquetage de génération de code pour l'évaluation des
--  expressions (passe 2)
--
--  Auteur : GL16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     10/01/2012
--        - version initiale
--------------------------------------------------------------------------------

with Arbres, Pseudo_Code;
use  Arbres, Pseudo_Code;

package Gencode_Expressions is
   -- Evalue l'expression contenue dans A et retourne une opérande localisant le
   -- résultat.
   -- Seule l'opérande retournée doit être libéré : les autres opérandes
   -- utilisés lors du calcul ont été libérés
   function Place_Computation_Exp (A : in Arbre) return Operande;
end Gencode_Expressions;
