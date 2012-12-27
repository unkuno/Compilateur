--------------------------------------------------------------------------------
--  Spécification du paquetage de primitives communes pour la génération de code
--  (passe 2)
--
--  Auteur : GL16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     10/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Pseudo_Code, Types_Base;
use  Pseudo_Code, Types_Base;

pragma Elaborate_All (Pseudo_Code);

package Gencode_Commun is
   -- Constante "this"
   This : constant Operande := Creation_Op_Indirect (-2, LB);

   -- Compteur global pour numéroter les étiquettes (et éviter la répétition)
   N : Natural := 0;
   
   -- Procédure d'affichage des informations de mise au pointx
   procedure Mettre_Au_Point (Niveau : in Positive; S : in String);
   
   -- Ecrit le code de la méthode Object.equals
   procedure Ecrit_Code_Object_Equals;
   
   -- Ecrit le code de gestion des erreurs
   procedure Ecrire_Code_Erreur;

   -- Permet de s'assurer que l'opérande utilisé est un registre.
   -- Si l'opérande Op utilise un registre non-scratch, alors celui-ci est
   -- simplement retourné, sinon un nouveau registre contenant la valeur de Op
   -- est retourné.
   -- Si Scratch vaut True, alors le comportement est le même mais autorise
   -- l'utilisation de registres scratchs.
   -- Remarque : lors de l'allocation d'un registre scratch, R1 est retourné.
   function Assure_Registre (Op      : in Operande;
                             Scratch : in Boolean := False) return Operande;
end Gencode_Commun;
