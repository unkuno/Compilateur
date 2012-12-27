-------------------------------------------------------------------------------
--  Programme de test de la phase gencode
--
--  Auteur : GL16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     16/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Ada.Command_Line, Ada.Text_IO;
use  Ada.Command_Line, Ada.Text_IO;

with Arbres, Syntaxe, Verif, Gencode;
use  Arbres, Syntaxe, Verif, Gencode;

procedure Test_Gencode is
   A : Arbre;
   FichierIn : File_Type;
begin
   Open (FichierIn, In_File, Argument (1));
   Set_Input (FichierIn);

   Analyser (A);
   Verifier_Decorer (A);
   Generer_Code (A, Argument (1), 16, False);

   Close(FichierIn);
exception
   when others =>
      Set_Exit_Status (Failure);

end Test_GenCode;
