-------------------------------------------------------------------------------
--  Spécification du paquetage de comptage des données sur la pile.
--
--  Auteur : GL16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     17/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Types_Base;
use  Types_Base;

-- Gestion d'un compteur comptabilisant la place mémoire nécessaire au stockage 
-- des données temporaires sur la pile. Ce paquetage ne doit pas comptabiliser
-- le contexte de pile (variables et sauvegarde des registres).
package Compteur_PUSH is
   Erreur_Interne : exception;

   -- Remet à zéro les compteurs avant l'écriture du code
   -- du code principal ou du code d'une méthode.
   procedure Initialise_Compteur_PUSH;

   -- Incrémente le compteur
   procedure Compte_PUSH(N : Entier := 1);

   -- Décrémente le compteur
   procedure Compte_POP(N : Entier := 1);

   -- Retourne la valeur maximale du compteur depuis la dernière initialisation.
   -- Précondition défensive : le compteur doit être à zéro
   function Get_Nb_PUSH_Max return Entier;

end Compteur_PUSH;
