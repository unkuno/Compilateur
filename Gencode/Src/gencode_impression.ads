--------------------------------------------------------------------------------
--  Spécification du paquetage de génération de code responsable d'imprimer des
--  données à l'écran (passe 2)
--
--  Auteur : GL16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     10/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Arbres;
use  Arbres;

package Gencode_Impression is
   -- Ecrit le code responsable de l'impression des expressions contenues dans L
   procedure Ecriture_Liste_Exp_Print (L : in Liste_Arbres);
end Gencode_Impression;
