-------------------------------------------------------------------------------
--  Procédure de test du paquetage Erreurs
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     11/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Ada.Text_IO, Ada.Exceptions;
use  Ada.Text_IO, Ada.Exceptions;

with Erreurs, Verif;
use  Erreurs, Verif;

procedure Test_Erreurs is
begin
   for E in Erreur_0_Param loop
      begin
	 Afficher_Erreur (E, Erreur_0_Param'Pos (E), "?.?");
	 Put_Line ("Erreur_Verif non levée !");
	 exit;
      exception
	 when Erreur_Verif => null;
	 when Erreur : others =>
	    Put_Line ("Exception " & Exception_Name (Erreur) & " imprévue !");
	    exit;
      end;
   end loop;
   
   for E in Erreur_1_Param loop
      begin
	 Afficher_Erreur (E, Erreur_1_Param'Pos (E), "Param_1", "?.?");
	 Put_Line ("Erreur_Verif non levée !");
	 exit;
      exception
	 when Erreur_Verif => null;
	 when Erreur : others =>
	    Put_Line ("Exception " & Exception_Name (Erreur) & " imprévue !");
	    exit;
      end;
   end loop;
   
   for E in Erreur_2_Param loop
      begin
	 Afficher_Erreur (E, Erreur_2_Param'Pos (E), "Param_1", "Param_2", "?.?");
	 Put_Line ("Erreur_Verif non levée !");
	 exit;
      exception
	 when Erreur_Verif => null;
	 when Erreur : others =>
	    Put_Line ("Exception " & Exception_Name (Erreur) & " imprévue !");
	    exit;
      end;
   end loop;
   
   for E in Erreur_3_Param loop
      begin
	 Afficher_Erreur (E, Erreur_3_Param'Pos (E),
			  "Param_1", "Param_2", "Param_3", "?.?");
	 Put_Line ("Erreur_Verif non levée !");
	 exit;
      exception
	 when Erreur_Verif => null;
	 when Erreur : others =>
	    Put_Line ("Exception " & Exception_Name (Erreur) & " imprévue !");
	    exit;
      end;
   end loop;
end;
