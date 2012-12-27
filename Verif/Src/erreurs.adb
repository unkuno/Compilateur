-------------------------------------------------------------------------------
--  Spécification des erreurs pour la verification contextuelle
--
--  Auteur : Groupe 16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     09/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Ada.Text_IO, Verif;
use  Ada.Text_IO, Verif;

package body Erreurs is

   ---------------------
   -- Afficher_Erreur --
   ---------------------
   
   procedure Afficher_Erreur (E         : in Erreur_0_Param;
			      Num_Ligne : in Natural;
			      Regle     : in String := "")
   is
   begin
      -- Affichage du numéro de ligne
      Put ("Ligne" & Natural'Image (Num_Ligne) & " : ");
      
      -- Affichage du message personnalisé
      case (E) is
	 when Erreur_Interne =>
	    Put ("Erreur interne du compilateur");
	 when Ident_Classe_Attendu =>
	    Put ("Identificateur de classe attendu");
	 when Champ_Void =>
	    Put ("Un champ ne peut pas être de type 'void'");
	 when Param_Void =>
	    Put ("Un paramètre ne peut pas être de type 'void'");
	 when Var_Void =>
	    Put ("Une variable ne peut pas être de type 'void'");
	 when Doublon_Param =>
	    Put ("Paramètres de même nom");
	 when Retour_Void =>
	    Put ("Impossible de retourner 'void'");
	 when Expr_Bool_Attendue =>
	    Put ("Expression booléenne attendue");
	 when Type_Base_Attendu =>
	    Put ("Entier, flottant ou chaine de caractère attendu");
	 when This_Principal =>
	    Put ("'this' ne peut pas être utilisé dans le programme principal");
	 when Objet_Attendu =>
	    Put ("Objet attendu à gauche de '.'");
	 when Non_Visible =>
	    Put ("Champ non visible dans ce contexte");
	 when Ident_Place_Attendu =>
	    Put ("Identificateur de champ, de paramètre " &
		   "ou de variable attendu");
	 when Ident_Champ_Attendu =>
	    Put ("Identificateur de champ attendu");
	 when Ident_Methode_Attendu =>
	    Put ("Identificateur de méthode attendu");
	 when Nbr_Param =>
	    Put ("Nombre de paramètres incorrect");
      end case;
      
      -- Affichage (éventuel) de la règle
      if Regle'Length = 0 then New_Line;
      else Put_Line (" (règle " & Regle & ")");
      end if;
      
      -- Levée de l'exception
      raise Erreur_Verif;
   end Afficher_Erreur;
   
   
   ---------------------
   -- Afficher_Erreur --
   ---------------------
   
   procedure Afficher_Erreur (E         : in Erreur_1_Param;
			      Num_Ligne : in Natural;
			      Param_1   : in String;
			      Regle     : in String := "")
   is
   begin
      -- Affichage du numéro de ligne
      Put ("Ligne" & Natural'Image (Num_Ligne) & " : ");
      
      -- Affichage du message personnalisé
      case (E) is
	 when Ident_Non_Decl =>
	    Put ("Identificateur '" & Param_1 & "' non déclaré");
	 when Ident_Deja_Decl =>
	    Put ("Identificateur '" & Param_1 & "' déjà déclaré");
	 when Doublon_Ident_Classe =>
	    Put ("Identificateurs de même nom dans la classe '" &
		   Param_1 & "'");
	 when Doublon_Champ_Classe =>
	    Put ("Champs de même nom dans la classe '" & Param_1 & "'");
	 when Deja_Champ_Super =>
	    Put ("'" & Param_1 & "' est déjà un champ dans une super-classe");
	 when Deja_Methode_Super =>
	    Put ("'" & Param_1 & "' est déjà une méthode dans une " &
			"super-classe");
	 when Sig_Diff_Super =>
	    Put ("La signature de la méthode '" & Param_1 &
			"' diffère dans la super-classe");
      end case;
      
      -- Affichage (éventuel) de la règle
      if Regle'Length = 0 then New_Line;
      else Put_Line (" (règle " & Regle & ")");
      end if;
      
      -- Levée de l'exception
      raise Erreur_Verif;
   end Afficher_Erreur;
   
   
   ---------------------
   -- Afficher_Erreur --
   ---------------------
   
   procedure Afficher_Erreur (E         : in Erreur_2_Param;
			      Num_Ligne : in Natural;
			      Param_1   : in String;
			      Param_2   : in String;
			      Regle     : in String := "")
   is
   begin
      -- Affichage du numéro de ligne
      Put ("Ligne" & Natural'Image (Num_Ligne) & " : ");
      
      -- Affichage du message personnalisé
      case (E) is
	 when Sous_Type_Retour =>
	    Put ("Le type de retour de '" & Param_1 &
			"' doit être une sous-type de '" & Param_2 & "'");
	 when Types_Affect =>
	    Put ("Les types '" & Param_1 & "' et '" & Param_2 &
			"' sont incompatibles pour l'affectation");
	 when Types_Op_Unaire =>
	    Put ("Le type '" & Param_1 & "' est incompatible avec " &
		     " l'opérateur unaire '" & Param_2 & "'");
	 when Types_Instanceof =>
	    Put ("Les types '" & Param_1 & "' et '" & Param_2 &
			"' sont incompatibles avec l'opérateur 'instanceof'");
	 when Types_Conv =>
	    Put ("Conversion de '" & Param_1 & "' en '" & Param_2 &
			"' impossible");
      end case;
      
      -- Affichage (éventuel) de la règle
      if Regle'Length = 0 then New_Line;
      else Put_Line (" (règle " & Regle & ")");
      end if;
      
      -- Levée de l'exception
      raise Erreur_Verif;
   end Afficher_Erreur;
   
   
   ---------------------
   -- Afficher_Erreur --
   ---------------------
   
   procedure Afficher_Erreur (E         : in Erreur_3_Param;
			      Num_Ligne : in Natural;
			      Param_1   : in String;
			      Param_2   : in String;
			      Param_3   : in String;
			      Regle     : in String := "")
   is
   begin
      -- Affichage du numéro de ligne
      Put ("Ligne" & Natural'Image (Num_Ligne) & " : ");
      
      -- Affichage du message personnalisé
      case (E) is
	 when Types_Op_Binaire =>
	    Put ("Les types '" & Param_1 & "' et '" & Param_2 &
		   "' sont incompatibles avec l'opérateur binaire '" &
		   Param_3 & "'");
      end case;
      
      -- Affichage (éventuel) de la règle
      if Regle'Length = 0 then New_Line;
      else Put_Line (" (règle " & Regle & ")");
      end if;
      
      -- Levée de l'exception
      raise Erreur_Verif;
   end Afficher_Erreur;

end Erreurs;
