-------------------------------------------------------------------------------
--  Corps du paquetage de gestion des instructions
--
--  Auteur : GL16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     10/01/12
--        - version initiale
-------------------------------------------------------------------------------

with Ada.Text_IO, Arbres, Pseudo_Code;
use  Ada.Text_IO, Arbres, Pseudo_Code;

package body Outils_Instructions is
   Var_Check : Boolean; -- Paramètre global "Check"
   
   -- Pointeurs de début et de fin du programme
   Programme : Ligne;
   Derniere_Ligne : Ligne;
   
   -- Pointeurs spécifiques aux blocs
   Debut_Bloc : Ligne;            -- début du bloc
   Sentinelle_Sauvegarde : Ligne; -- zone de sauvegarde des registres
   
   
   function Check return Boolean is
   begin
      return Var_Check;
   end Check;
   
   
   function Nat_Image (I : in Natural) return String is
      S : String := Natural'Image (I);
   begin
      return S (S'First + 1 .. S'Last);
   end;
   
   
   procedure Insere_Ligne (L : in not null Ligne) is
   begin
      Changer_Suivant (Derniere_Ligne, L);
      Derniere_Ligne := L;
   end Insere_Ligne;
   
   
   procedure Ligne_Vide is
   begin
      Insere_Ligne (Creation (Com => ""));
   end Ligne_Vide;


   procedure Initialise_Programme (No_Check : in Boolean) is
   begin
      Programme := Creation (Com => "Initialisation du programme");
      Derniere_Ligne := Programme;
      Var_Check := not No_Check;

      Initialise_Bloc;
   end Initialise_Programme;


   procedure Afficher_Programme is
   begin
      Afficher_Programme (Programme);
   end Afficher_Programme;


   procedure Initialise_Bloc is
      Pile_Pleine : Operande := Creation_Op_Etiq (L_Etiq ("pile_pleine"));
   begin
      Debut_Bloc := Derniere_Ligne;
      if Check then
         -- TSTO (?)
         Insere_Ligne (Creation (I => Creation_Inst1 (Code_TSTO,
                                                      Creation_Op_Entier (0))));
         -- BOV pile_pleine
         Insere_Ligne (Creation (I => Creation_Inst1 (Code_BOV,
                                                      Pile_Pleine)));
      end if;
      -- ADDSP (?)
      Insere_Ligne (Creation (I => Creation_Inst1 (Code_ADDSP,
                                                   Creation_Op_Entier (0))));
      Sentinelle_Sauvegarde := Derniere_Ligne;
   end Initialise_Bloc;


   procedure Insere_Sauvegarde_Registre (L : in not null Ligne) is
      Tmp : Ligne := Acces_Suivant (Sentinelle_Sauvegarde);
   begin
      Changer_Suivant (Sentinelle_Sauvegarde, L);
      Changer_Suivant (L, Tmp);
   end Insere_Sauvegarde_Registre;


   procedure Finalise_Bloc (Reserves   : in Entier;
			    Supplement : in Entier;
                            Liberation : in Boolean := True) is
      Cour : Ligne;
   begin
      if Check then
         if Reserves = 0 then
            -- Pas de ADDSP à ecrire

            if Supplement = 0 then
               -- Pas de TSTO non plus
               -- On court-circuite les 3 instructions
               Changer_Suivant (Debut_Bloc,
				Acces_Suivant (Sentinelle_Sauvegarde));
               if Derniere_Ligne = Sentinelle_Sauvegarde then
                  Derniere_Ligne := Debut_Bloc;
               end if;
            else
               -- On court-circuite uniquement le ADDSP
               Changer_Suivant (Acces_Suivant (Acces_Suivant (Debut_Bloc)),
                                Acces_Suivant (Sentinelle_Sauvegarde));
	       Changer_Entier (Acces_Op1
				 (Acces_Inst (Acces_Suivant (Debut_Bloc))),
			       Supplement);
               if Derniere_Ligne = Sentinelle_Sauvegarde then
                  Derniere_Ligne := Acces_Suivant (Acces_Suivant (Debut_Bloc));
               end if;
            end if;

         else
            -- TSTO, BOV et ADDSP sont nécessaires : on les réécrit
            Cour := Acces_Suivant (Debut_Bloc);
            Changer_Entier (Acces_Op1 (Acces_Inst (Cour)),
			    Reserves + Supplement);
            Cour := Acces_Suivant (Acces_Suivant (Cour));
            -- Cour pointe sur le ADDSP
            Changer_Entier (Acces_Op1 (Acces_Inst (Cour)), Reserves);
         end if;

      else
         if Reserves = 0 then
            -- Pas de ADDSP à ecrire
            -- On court-circuite tout car il n'y a ni TSTO, ni BOV
            Changer_Suivant (Debut_Bloc, Acces_Suivant (Sentinelle_Sauvegarde));
            if Derniere_Ligne = Sentinelle_Sauvegarde then
	       Derniere_Ligne := Debut_Bloc;
            end if;
         else
            -- ADDSP nécessaire
            Changer_Entier (Acces_Op1 (Acces_Inst (Acces_Suivant (Debut_Bloc))),
			    Reserves);
         end if;
      end if;

      if Liberation and Reserves > 0 then
         -- SUBSP  Reserves
         Insere_Ligne (Creation
			 (I => Creation_Inst1 (Code_SUBSP,
					       Creation_Op_Entier (Reserves))));
      end if;
   end Finalise_Bloc;


   procedure Ecrire_Cadre (Texte : in String) is
      Milieu : String := "# " & Texte & " #";
      Bord   : String (Milieu'Range) := (others => '#');
   begin
      Insere_Ligne (Creation (Com => Bord));
      Insere_Ligne (Creation (Com => Milieu));
      Insere_Ligne (Creation (Com => Bord));
   end Ecrire_Cadre;

end Outils_Instructions;

