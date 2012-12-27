-------------------------------------------------------------------------------
--  Procédure de test de l'analyseur syntaxique
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

--| Test de l'étape d'analyse syntaxique du compilateur
--| Usage : test_synt nom_fichier

with Ada.Text_IO, Ada.Exceptions, Ada.Command_Line;
use  Ada.Text_IO, Ada.Exceptions, Ada.Command_Line;

with Arbres, Syntaxe, Fichier;
use  Arbres, Syntaxe, Fichier;

procedure Test_Synt is

   -- ATTENTION : La constante Affichage doit être mise à False quand
   -- l'analyse syntaxique est au point.
   Affichage : constant Boolean := True;

   -- Modifier la constante Niveau pour le niveau de détail de l'arbre
   Niveau : constant := 0;

   A : Arbre;
   Fichier_In : File_Type;
   Fichier_Out : File_Type;
begin
   --Put_Line(Argument(1));
   --Put_Line(Argument(2));
   --Put_Line(Argument(3));
   --Put_Line(Argument(4));

   Open (Fichier_In, In_File, Argument (1));
   Set_Input (Fichier_In);

   Create (Fichier_Out, Out_File, Argument (2));
   Set_Output (Fichier_Out);

   Analyser (A);


   Put_Line ("/* Programme syntaxiquement correct */");
   if Affichage then
      Close(Fichier_Out);
      Create (Fichier_Out, Out_File, Argument (3));
      Set_Output (Fichier_Out);

      Afficher (A, Niveau);
   end if;

   Close(Fichier_Out);
   Create (Fichier_Out, Out_File, Argument (4));
   Set_Output (Fichier_Out);
   Decompiler (A, Niveau);
   Close(Fichier_Out);

   Close(Fichier_In);

exception
   when Erreur : Erreur_Fichier |
                 Erreur_Lexical | Limitation_Lexical |
                 Erreur_Syntaxe =>
      Put_Line ("Exception " & Exception_Name (Erreur) & " levee");
      Set_Exit_Status (Failure);
end Test_Synt;
