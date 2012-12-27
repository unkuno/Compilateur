-------------------------------------------------------------------------------
--  Specification de la passe 1 de la verification contextuelle
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

package Verif_Passe1 is

   

----------------------------------------------------------------------------------
-- Procédure de vérification (passe 1)-------
----------------------------------------------------------------------------------

   -- Nécessite un arbre abstrait A 
   -- Retourne un Environ qui contient les types prédéfinis ainsi que les noms
   -- des différentes classes du programme.
   procedure Verifier_Decorer_1 (A : in Arbre; Env_Types : out Environ);


end Verif_Passe1;
