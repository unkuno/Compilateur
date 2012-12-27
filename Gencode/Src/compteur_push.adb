-------------------------------------------------------------------------------
--  Corps du paquetage de paquetage de comptage des données sur la pile
--
--  Auteur : GL16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     17/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Outils_Instructions;
use  Outils_Instructions;

package body Compteur_PUSH is
   Nb_Push     : Entier := 0; -- Nombre courant de PUSH
   Nb_Push_Max : Entier := 0; -- Nombre maximal de PUSH depuis la dernière init
   Defensif : constant Boolean := True;

   procedure Initialise_Compteur_PUSH is
   begin
      Nb_Push     := 0;
      Nb_Push_Max := 0;
   end Initialise_Compteur_PUSH;

   procedure Compte_PUSH (N : Entier := 1) is
   begin
      Nb_Push := Nb_Push + N;
      if Nb_Push > Nb_Push_Max then
         Nb_Push_Max := Nb_Push;
      end if;
   end Compte_Push;

   procedure Compte_POP (N : Entier := 1) is
   begin
      Nb_Push := Nb_Push - N;
      if Defensif and Nb_Push < 0 then
         raise Erreur_Interne;
      end if;
   end Compte_POP;

   function Get_Nb_PUSH_Max return Entier is
   begin
      if Defensif and Nb_Push > 0 then
         raise Erreur_Interne;
      end if;
      return Nb_Push_Max;
   end Get_Nb_PUSH_Max;

end Compteur_PUSH;
