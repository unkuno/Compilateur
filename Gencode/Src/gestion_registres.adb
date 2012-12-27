-------------------------------------------------------------------------------
--  Corps du paquetage de gestion des registres non-scratch.
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     12/01/12
--        - version initiale
-------------------------------------------------------------------------------

with Pseudo_Code, Outils_Instructions, Compteur_Push;
use  Pseudo_Code, Outils_Instructions, Compteur_Push;

with Ada.Text_IO;
use  Ada.Text_IO;

package body Gestion_Registres is

   Defensif : constant Boolean := True;

   procedure Mettre_Au_Point (Niveau : in Positive; S : in String) is
      -- plus Niveau_Max est eleve, plus il y a d'affichage
      Niveau_Max : constant := 0;
   begin
      if Niveau <= Niveau_Max then
         Put_Line (Standard_Error, "Gestion_Registres : " & S);
      end if;
   end Mettre_Au_Point;

   Erreur_Registres : exception;

   -- Nombre de registres utilisables par le gestionnaire
   Nb_Reg  : Entier := 2;

   -- Nombre de registres alloués
   --  => si Nb_Alloc <= Nb_Reg : nombre de registres alloués.
   --  => si Nb_Alloc > Nb_Reg : nombre de registres alloués PLUS
   --        nombre total de registres empilés (y compris données sales)
   Nb_Alloc : Entier := 0;

   -- Nombre total de registres utilisés (0 .. Nb_Reg)
   Nb_Util  : Entier := 0;

   -- Premier et dernier registres gérés par le gestionnaire
   Premier_Reg : Utilisable := Utilisable'First;
   Dernier_Reg : Utilisable := Utilisable'Succ (Premier_Reg);

   -- Etat du gestionnaire
   Dernier_Alloc : Utilisable := Dernier_Reg;
   Dernier_Pile  : Utilisable := Dernier_Reg;


   -----------------
   -- Initialiser --
   -----------------

   procedure Initialiser_Registres (Nb_Total_Reg : in Entier) is
      Pos_Premier : constant Entier := Utilisable'Pos (Premier_Reg);
   begin
      if Defensif and then (Nb_Total_Reg < 4 or else Nb_Total_Reg > 16) then
         raise Erreur_Registres;
      end if;

      Nb_Reg := Nb_Total_Reg - 2;

      Dernier_Reg   := Utilisable'Val (Pos_Premier + Nb_Reg - 1);
      Dernier_Alloc := Dernier_Reg;
      Dernier_Pile  := Dernier_Reg;
   end Initialiser_Registres;


   -------------
   -- Allouer --
   -------------

   function Allouer return Utilisable is
      Prochain : Utilisable;
   begin
      Mettre_Au_Point (1, "Debut Allouer (" &
                         Utilisable'Image (Dernier_Alloc) & ", " &
                         Utilisable'Image (Dernier_Pile)  & ")");

      -- Récupération du registre
      if Dernier_Alloc = Dernier_Reg then
         Prochain := Premier_Reg;
      else
         Prochain := Utilisable'Succ (Dernier_Alloc);
      end if;

      -- Un registre sauvegardé est-il disponible ?
      if Dernier_Pile = Dernier_Alloc then
         Dernier_Pile := Prochain;

         -- Mise à jour du nombre d'allocations
         Nb_Alloc := Nb_Alloc + 1;
         if Nb_Util < Nb_Alloc and then Nb_Alloc <= Nb_Reg then
            Nb_Util := Nb_Alloc;
         end if;

         -- Sauvegarde éventuelle du contenu précédent
         if Nb_Alloc > Nb_Reg then
            -- PUSH Dernier_Alloc
            Insere_Ligne (Creation
                            (I   => Creation_Inst1 (Code_PUSH,
                                                    Le_Registre (Prochain)),
                             Com => "Sauvegarde de " &
                               Utilisable'Image (Prochain)));
            Mettre_Au_Point (2, "Sauvegarde de " & Utilisable'Image (Prochain));
            Compte_PUSH;
         end if;
      end if;

      Dernier_Alloc := Prochain;

      Mettre_Au_Point (1, "Fin Allouer (" &
                         Utilisable'Image (Dernier_Alloc) & ", " &
                         Utilisable'Image (Dernier_Pile)  & ")");

      return Dernier_Alloc;
   end Allouer;


   -------------
   -- Libérer --
   -------------

   procedure Liberer (Reg : in Utilisable) is
      Precedent : Utilisable;
   begin
      if Defensif and then Reg /= Dernier_Alloc then
         Put_Line (Standard_Error, "Erreur interne : tentative de libérer " &
                     Utilisable'Image (Reg) & " (" &
                     Utilisable'Image (Dernier_Alloc) & " était attendu)");
         raise Erreur_Registres;
      end if;

      Mettre_Au_Point (1, "Debut Liberer : (" &
                         Utilisable'Image (Dernier_Alloc) & ", " &
                         Utilisable'Image (Dernier_Pile)  & ")");

      -- Calcul du nouveau Dernier_Alloc
      if Reg = Premier_Reg then
         Dernier_Alloc := Dernier_Reg;
      else
         Dernier_Alloc := Utilisable'Pred (Reg);
      end if;

      -- Calcul du précédent
      if Dernier_Alloc = Premier_Reg then
         Precedent := Dernier_Reg;
      else
         Precedent := Utilisable'Pred (Dernier_Alloc);
      end if;

      if Precedent = Dernier_Pile then
         if Nb_Alloc > Nb_Reg then
            -- Restauration du registre précédemment sauvegardé dans la pile
            -- POP Precedent
            Insere_Ligne (Creation
                            (I   => Creation_Inst1 (Code_POP,
                                                    Le_Registre (Dernier_Pile)),
                             Com => "Restauration de " &
                               Utilisable'Image (Dernier_Pile)));
            Mettre_Au_Point (2, "Restauration de " &
                               Utilisable'Image (Dernier_Pile));
            Compte_POP;
         end if;

         -- Mise à jour de Dernier_Pile
         if Dernier_Pile = Premier_Reg then
            Dernier_Pile := Dernier_Reg;
         else
            Dernier_Pile := Utilisable'Pred (Dernier_Pile);
         end if;

         -- Mise à jour du nombre d'allocations
         Nb_Alloc := Nb_Alloc - 1;
      end if;

      Mettre_Au_Point (1, "Fin Liberer (" &
                         Utilisable'Image (Dernier_Alloc) & ", " &
                         Utilisable'Image (Dernier_Pile)  & ")");
   end Liberer;


   procedure Liberer (Op : in Operande) is
   begin
      if Acces_Nature (Op) = Op_Direct and then
        Acces_Registre (Op) in Premier_Reg .. Dernier_Reg then
         Liberer (Acces_Registre (Op));
      elsif Acces_Nature (Op) = Op_Indirect and then
        Acces_Base (Op) in Premier_Reg .. Dernier_Reg then
         Liberer (Acces_Base (Op));
      end if;
   end Liberer;


   ------------
   -- Purger --
   ------------

   procedure Purger is
   begin
      if Dernier_Pile = Dernier_Alloc then return; end if;

      Mettre_Au_Point (1, "Debut Purger");

      loop
         if Nb_Alloc > Nb_Reg then
            -- POP Dernier_Pile
            Insere_Ligne (Creation
                            (I   => Creation_Inst1 (Code_POP,
                                                    Le_Registre (Dernier_Pile)),
                             Com => "Restauration de " &
                               Utilisable'Image (Dernier_Pile)));
            Mettre_Au_Point (2, "Restauration de " &
                               Utilisable'Image (Dernier_Pile));
            Compte_POP;
         end if;

         -- Passage au précédent
         if Dernier_Pile = Premier_Reg then
            Dernier_Pile := Dernier_Reg;
         else
            Dernier_Pile := Utilisable'Pred (Dernier_Pile);
         end if;

         -- Mise à jour du nombre d'allocations
         Nb_Alloc := Nb_Alloc - 1;

         -- On termine lorsqu'on arrive au dernier alloué
         exit when Dernier_Pile = Dernier_Alloc;
      end loop;

      Mettre_Au_Point (1, "Fin Purger");
   end Purger;


   -----------------------------
   -- Reinitialiser_Registres --
   -----------------------------

   procedure Reinitialiser_Registres is
   begin
      Dernier_Alloc := Dernier_Reg;
      Dernier_Pile  := Dernier_Reg;

      Nb_Alloc := 0;
      Nb_Util  := 0;
   end Reinitialiser_Registres;


   ---------------------------
   -- Sauvegarder_Registres --
   ---------------------------

   function Sauvegarder_Registres return Entier is
      Dernier_Util : Utilisable;
      Depl  : Deplacement := 0;
      Place : Operande;
   begin
      if Nb_Util > 0 then
         Dernier_Util := Utilisable'Val (Utilisable'Pos (Premier_Reg)
                                           + Nb_Util - 1);
         for Reg in Premier_Reg .. Dernier_Util loop
            Place := Creation_Op_Indirect (Depl, SP);
            Insere_Sauvegarde_Registre
              (Creation (I => Creation_Inst2 (Code_STORE,
                                              Le_Registre (Reg),
                                              Place)));
            Insere_Ligne
              (Creation (I => Creation_Inst2 (Code_LOAD,
                                              Place,
                                              Le_Registre (Reg))));
            Depl := Depl - 1;
         end loop;
      end if;

      return Nb_Util;
   end Sauvegarder_Registres;

end Gestion_Registres;
