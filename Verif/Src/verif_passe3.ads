-------------------------------------------------------------------------------
--  Specification de la passe 3 de la verification contextuelle
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     09/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Arbres, Defns;
use  Arbres, Defns;

package Verif_Passe3 is

   

----------------------------------------------------------------------------------
-- Procédure de vérification et de décoration d'un arbre abstrait (passe 3)-------
----------------------------------------------------------------------------------

   -- Verifie l'arbre A passé en paramètre relativement à la passe3
   -- L'environ passé en paramètre contiendra en sorti les champs et méthodes, 
   -- ainsi que les paramètres des méthodes et les variables locales.
   -- Nécessite l'environ généré par les passes 1 et 2.
   procedure Verifier_Decorer_3 (A : in Arbre; Env_Types : in Environ);


end Verif_Passe3;
