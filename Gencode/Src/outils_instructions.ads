-------------------------------------------------------------------------------
--  Spécification du paquetage de gestion des instructions
--
--  Auteur : GL16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     10/01/12
--        - version initiale
-------------------------------------------------------------------------------


with Pseudo_Code, Types_Base;
use  Pseudo_Code, Types_Base;

package Outils_Instructions is

   -- Permet d'obtenir le paramètre global "Check"
   function Check return Boolean;

   -- Renvoie la chaine de caractères correspondant à un entier non signé en
   -- retirant l'espace du début
   function Nat_Image (I : in Natural) return String;

   -- Insere une instruction à la fin du programme
   procedure Insere_Ligne (L : in not null Ligne);
   
   -- Insere une ligne vide à la fin du programme
   procedure Ligne_Vide;

   -- Insère un cadre contenant le texte "Texte" à la fin du programme
   procedure Ecrire_Cadre (Texte : in String);

   -- Initialise le programme et précise le paramètre "Check"
   procedure Initialise_Programme (No_Check : in Boolean);

   -- Affiche le programme complet
   procedure Afficher_Programme;

   -- Initialise un bloc en insérant les instruction TSTO et ADDSP.
   -- Les paramètres de ces deux instructions sont encore inconnus et seront
   -- mis à jour lors de la finalisation du bloc.
   procedure Initialise_Bloc;

   -- Ecrit une ligne au début du bloc (pour la sauvegarde des registres)
   procedure Insere_Sauvegarde_Registre (L : in not null Ligne);

   -- Met à jour les deux paramètres de début de bloc.
   --  => "Reservés" : taille des données fixes du contexte de pile
   --                  (variables locales et sauvegarde des registres)
   --  => "Supplément" : place nécessaire pour l'évaluation du bloc
   --                    (données temporaires et paramètres lors de appels)
   --  => "Liberation" : indique s'il faut libérer l'espace utilisé dans la pile
   --                    avec un SUBSP (False uniquement pour le prog principal)
   procedure Finalise_Bloc (Reserves   : in Entier;
			    Supplement : in Entier;
                            Liberation : in Boolean := True);

end Outils_Instructions;

