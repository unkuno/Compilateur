-------------------------------------------------------------------------------
--  Programme de test de l'analyseur lexical
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

-- Usage : test_lex nom_fichier

with Ada.Command_Line, Ada.Exceptions, Ada.Text_IO,
     Fichier, Attributs, Syntaxe_Tokens, Lexical;
use  Ada.Command_Line, Ada.Exceptions, Ada.Text_IO,
     Fichier, Attributs, Syntaxe_Tokens, Lexical;

procedure Test_Lex is

   -- Lit la prochaine unité lexicale et retourne le lexème correspondant
   -- Retourne Error en cas d'erreur
   function Prochain_Lexeme return Token is
   begin
      return YYLex;
   exception
      when Erreur : Erreur_Lexical | Limitation_Lexical =>
         Put_Line ("Exception " & Exception_Name (Erreur) & " recuperee");
         return Error;
   end Prochain_Lexeme;

   -- Max des longueurs des images des lexèmes (pour la colonne d'affichage)
   function Longueur_Max_Image_Token return Positive_Count is
      Lmax : Natural := 0;
      Lg : Positive;
   begin
      for T in Token loop
         Lg := Token'Image (T)'Length;
         if Lg > Lmax then
            Lmax := Lg;
         end if;
      end loop;
      return Positive_Count (Lmax);
   end Longueur_Max_Image_Token;

   Col_YYLVal : constant Positive_Count := Longueur_Max_Image_Token + 2;

   -- Procédure de test de l'analyseur lexical
   procedure Tester_Lexical is
      Tok : Token;
   begin
      loop
         Tok := Prochain_Lexeme;
         exit when Tok = End_Of_Input;
         if Tok /= Error then
            Put (Token'Image (Tok));
            Set_Col (Col_YYLVal);
            Afficher (YYLVal);
            New_Line;
         end if;
      end loop;
   end Tester_Lexical;

   Fichier_In : File_Type;
   Fichier_Out : File_Type;
begin

   --Put_Line(Argument(1));
   --Put_Line(Argument(2));

   Open (Fichier_In, In_File, Argument(1));
   Set_Input (Fichier_In);

   Create (Fichier_Out, Out_File, Argument(2));
   Set_Output (Fichier_Out);

   Tester_Lexical;

   Close(Fichier_Out);
   Close(Fichier_In);

exception
   when Erreur : Erreur_Fichier =>
      Put_Line ("Exception " & Exception_Name (Erreur) & " levee");
      Set_Exit_Status (Failure);
end Test_Lex;
