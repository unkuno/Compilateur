-------------------------------------------------------------------------------
--  Spécification du paquetage Gencode de génération de code
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------


with Arbres, Types_Base;
use  Arbres, Types_Base;

package Gencode is

   -- Exception levée en cas d'erreur due à une limitation de
   -- la génération de code
   Limitation_Gencode : exception;

   -- Procédure de génération de code pour un arbre abstrait décoré
   procedure Generer_Code (A        : in Arbre;
			   Nom      : in String;
			   Nb_Reg   : in Entier;
			   No_Check : in Boolean);


end Gencode;
