-------------------------------------------------------------------------------
--  Specification de la passe 2 de la verification contextuelle
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     16/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Arbres, Defns;
use  Arbres, Defns;

package Verif_Passe2 is

   

----------------------------------------------------------------------------------
-- Procédure de vérification (passe 2)-------
----------------------------------------------------------------------------------

   -- Nécessite un arbre abstrait A 
   -- Retourne l'environ complété avec les champs et les signatures 
   -- des méthodes des différentes classes du programme.
   procedure Verifier_Decorer_2 (A : in Arbre; Env_Types : in Environ);


end Verif_Passe2;