-------------------------------------------------------------------------------
--  Spécification du paquetage de vérifications contextuelles
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Arbres;
use  Arbres;

package Verif is

   -- Procédure de vérification et de décoration d'un arbre abstrait
   procedure Verifier_Decorer (A : in Arbre);

   -- Exception levée en cas d'erreur contextuelle
   Erreur_Verif : exception;

   -- Exception levée en cas de limitation du compilateur lors de la
   -- vérification contextuelle
   Limitation_Verif : exception;

end Verif;
