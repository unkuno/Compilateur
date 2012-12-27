-------------------------------------------------------------------------------
--  Programme principal du compilateur Deca
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

-- Programme principal du compilateur Deca

-- Usage : decac [[options] [repertoire/]nom_fichier_source.deca | -b]

-- Compile le fichier source nom_fichier_source.deca en respectant les options
-- définies dans Global/Doc/Decac.txt
-- S'arrête à la première erreur détectée.


with Ada.Command_Line, Ada.Text_IO;
use  Ada.Command_Line, Ada.Text_IO;

with Arbres, Syntaxe, Verif, Gencode, Types_Base;
use  Arbres, Syntaxe, Verif, Gencode, Types_Base;



procedure Decac is
   Erreur_Fichier, Erreur_Argument : exception;

   A        : Arbre;
   Banniere : Boolean;
   Parse    : Boolean;
   Verif    : Boolean;
   No_Check : Boolean;
   Warnings : Boolean;
   Nb_Reg   : Entier;



   -- procedure Init_Argument
   -- Permet d'initialiser les arguments suivants les paramètres.
   procedure Init_Arg (Banniere, Parse, Verif, No_Check, Warnings : out boolean;
                       Nb_Reg : out Entier) is
   begin

      -- Initialisation par défaut des variables

      Nb_Reg   := 16;
      Banniere := False;
      Parse    := False;
      Verif    := False;
      No_Check := False;
      Warnings := False;

      -- lecture des arguments

      for I in 1 .. Argument_Count loop
         if (Argument (I) = "-b") then
            Banniere := true;
         elsif (Argument (I) = "-p") then
            Parse := true;
         elsif (Argument (I) = "-v") then
            Verif := true;
         elsif (Argument (I) = "-n") then
            No_Check := true;
         elsif (Argument (I) = "-r") then
            Nb_Reg := Entier'Value (Argument (I+1));
            if (Nb_Reg < 4) then
               Put_Line("Nombre de registre minimum : 4. Cette valeur minimum sera utilisé pour la suite.");
               Nb_Reg := 4;
            elsif (Nb_Reg > 16) then
               Put_Line("Nombre de registre maximum : 16. Cette valeur maximum sera utilisé pour la suite.");
               Nb_Reg := 16;
            end if;
         elsif (Argument (I) = "-w") then
            Warnings := true;
         end if;
      end loop;

      -- verification

      if (Verif AND Parse) then
         Put_Line ("Warning : Options -p et -v incompatibles. Seul l'option -p sera prise en compte !");
         Verif := false;
      end if;


                exception
      when CONSTRAINT_ERROR => Put_Line
         ("Erreur : l'argument qui suit -r n'est pas un entier correct");
         raise Erreur_Argument;

   end Init_Arg;



   -- procedure Ouvrir_Fichier
   -- Permet d'ouvrir un fichier .ass final
   procedure Ouvrir_Fichier is
      Fichier : File_Type;
   begin

      Open (Fichier, In_File, Argument (Argument_Count));
      Set_Input (Fichier);

   exception
      when Name_Error =>
         Put_Line ("Fichier " & Argument (Argument_Count) & " inexistant");
         raise Erreur_Fichier;
      when Use_Error =>
         Put_Line ("Fichier " & Argument (Argument_Count) & " impossible a ouvrir");
         raise Erreur_Fichier;

   end Ouvrir_Fichier;




begin


   if (Argument_Count = 0) then
      Put_Line ("decac [[-p | -v] [-n] [-r X] [repertoire/]nom_fichier_source.deca | -b]");
   else
      Init_Arg (Banniere, Parse, Verif, No_Check, Warnings, Nb_Reg);

      if Banniere then


         New_Line;
         Put_Line("          oooooooooo.   oooooooooooo   .oooooo.         .o.       ");
         Put_Line("          `888'   `Y8b  `888'     `8  d8P'  `Y8b       .888.      ");
         Put_Line("           888      888  888         888              .8""888.     ");
         Put_Line("           888      888  888oooo8    888             .8' `888.    ");
         Put_Line("           888      888  888    ""    888            .88ooo8888.   ");
         Put_Line("           888     d88'  888       o `88b    ooo   .8'     `888.  ");
         Put_Line("          o888bood8P'   o888ooooood8  `Y8bood8P'  o88o     o8888o ");
         Put_Line("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$                               $$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$           EQUIPE 16           $$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$                               $$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$        BOUSSON Valentin       $$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$         CONNES Cédric         $$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$        LENTINI Sébastien      $$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$           NGUY Thomas         $$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$                               $$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$          ENSIMAG 2012         $$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$                               $$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
         Put_Line("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
         New_Line;

      else

         Ouvrir_Fichier;
         Analyser (A);
         if Parse then
            Decompiler (A);
         else
            Verifier_Decorer (A);
            if Verif then
               Afficher(A);
            else
               Generer_Code (A, Argument (Argument_Count), Nb_Reg, No_Check);
            end if;
         end if;
      end if;
   end if;

exception
   when Erreur_Lexical | Limitation_Lexical |
     Erreur_Syntaxe | Erreur_Argument |
     Erreur_Verif   | Limitation_Verif   |
     Limitation_Gencode | Erreur_Fichier =>
      Set_Exit_Status (Failure);

end Decac;
