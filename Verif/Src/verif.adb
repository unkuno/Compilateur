-------------------------------------------------------------------------------
--  Corps du paquetage de vérifications contextuelles
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Ada.Text_IO, Verif_Passe1, Verif_Passe2, Verif_Passe3, Symboles, Defns;
use  Ada.Text_IO, Verif_Passe1, Verif_Passe2, Verif_Passe3, Symboles, Defns;

package body Verif is

   ----------------------
   -- Verifier_Decorer --
   ----------------------

   procedure Verifier_Decorer (A : in Arbre) is
      Env_Types: Environ;
   begin
      Verifier_Decorer_1 (A, Env_Types);
      Verifier_Decorer_2 (A, Env_Types);
      Verifier_Decorer_3 (A, Env_Types);
   end Verifier_Decorer;

end Verif;
