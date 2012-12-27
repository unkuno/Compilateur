-------------------------------------------------------------------------------
--  Spécification du paquetage de gestion des classes (passe 1)
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     16/01/12
--        - version initiale
-------------------------------------------------------------------------------


with Types_Base, Arbres;
use  Types_Base, Arbres;

package Gencode_Classes is

   -- Ecrit le code chargé de construire les tables des méthodes.
   -- Met également à jour les opérandes attachées aux Defn de classes.
   -- Retourne la place occupée par les tables des méthodes sur la pile.
   function Ecrire_Liste_Classes (L : in Liste_Arbres) return Entier;

end Gencode_Classes;

