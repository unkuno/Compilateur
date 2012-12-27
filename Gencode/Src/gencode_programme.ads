--------------------------------------------------------------------------------
--  Spécification du paquetage de génération de code spécialisé dans la gestion
--  du programme principal et du corps des méthodes (passe 2)
--
--  Auteur : GL16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     10/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Arbres, Types_Base;
use  Arbres, Types_Base;

package Gencode_Programme is
   -- Ecrit le code complet du programme
   --  => A : arbre abstrait décoré
   --  => Compteur_Pile : place occupée dans la pile par les tables des méthodes
   procedure Ecrire_Code_Programme (A : in Arbre; Compteur_Pile : in Entier);
end Gencode_Programme;
