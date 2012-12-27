-------------------------------------------------------------------------------
--  lexical.l : analyseur lexical Aflex -> corps du paquetage Lexical
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

-- Définition des unités lexicales du langage

Lettre          [A-Za-z]
Chiffre         [0-9]
Idf             ({Lettre}|"$"|"_")({Lettre}|"$"|"_"|{Chiffre})*

Chiffre_Non_Nul [1-9]
Entier          0|{Chiffre_Non_Nul}{Chiffre}*

Num             {Chiffre}+
Signe           "+"|"-"|""
Exp             [Ee]{Signe}{Num}
Dec             {Num}"."{Num}
Flottant        {Dec}|{Dec}{Exp}

Chaine_Car      [^\"\\\n]
Chaine          \"({Chaine_Car}|\\\\|\\\")*\"

Commentaire     "//".*
Separateur      " "|\n|\t

%%

-- Règles appliquées lorsqu'une unité lexicale est reconnue

\n {
   Ligne_Courante := Ligne_Courante + 1;
}

{Idf} {
   declare
      Code : Token := Idf_Lex;
      C    : Chaine;
   begin
      Mettre_A_Jour (YYText, Code, C);
      if Code = Idf_Lex then
         YYLVal := Creation_Lex_Ident (C, Ligne_Courante);
      else
         YYLVal := Creation_Lex_Autre (Ligne_Courante);
      end if;
      return Code;
   exception
      when Constraint_Error =>
         Put_Line("Ligne" & Integer'Image (Ligne_Courante) &
                  " : Identifiant trop long : dépassement de capacité");
         raise Limitation_Lexical;
   end;
}

"<" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '<';
}

">" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '>';
}

"=" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '=';
}

"+" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '+';
}

"-" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '-';
}

"*" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '*';
}

"/" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '/';
}

"%" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '%';
}

"." {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '.';
}

"," {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return ',';
}

"(" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '(';
}

")" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return ')';
}

"{" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '{';
}

"}" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '}';
}

"!" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return '!';
}

";" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return ';';
}

"==" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return Egal_Egal_Lex;
}

"!=" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return Diff_Lex;
}

">=" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return Sup_Egal_Lex;
}

"<=" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return Inf_Egal_Lex;
}

"&&" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return And_Lex;
}

"||" {
   YYLVal := Creation_Lex_Autre (Ligne_Courante);
   return Or_Lex;
}

{Entier} {
   begin
      YYLVal := Creation_Lex_Entier (Entier'Value (YYText), Ligne_Courante);
      return Entier_Lex;
   exception
      when Constraint_Error =>
         Put_Line("Ligne" & Integer'Image (Ligne_Courante) &
                  " : Entier trop grand : dépassement de capacité");
         raise Limitation_Lexical;
   end;
}

{Flottant} {
   begin
      YYLVal := Creation_Lex_Flottant (Flottant'Value (YYText), Ligne_Courante);
      return Flottant_Lex;
   exception
      when Constraint_Error =>
         Put_Line("Ligne" & Integer'Image (Ligne_Courante) &
                  " : Flottant trop grand : dépassement de capacité");
         raise Limitation_Lexical;
   end;
}

{Chaine} {
   begin
      YYLVal := Creation_Lex_Chaine (Supprimer_Echappement (YYText),
                                     Ligne_Courante);
      return Chaine_Lex;
   exception
      when Constraint_Error =>
         Put_Line("Ligne" & Integer'Image (Ligne_Courante) &
                  " : Chaine trop longue : dépassement de capacité");
         raise Limitation_Lexical;
   end;
}

{Commentaire}|{Separateur} {
   null;
}

. {
   Put_Line ("Ligne" & Integer'Image (Ligne_Courante) &
             " : Caractere illegal : " & YYText (1));
   raise Erreur_Lexical;
}

%%

-- Corps du paquetage Lexical
-- Analyseur lexical

with Types_Base, Attributs, Dictionnaire;
use  Types_Base, Attributs, Dictionnaire;

pragma Elaborate_All (Dictionnaire);

package body Lexical is

   Ligne_Courante : Positive := 1;


   function Num_Ligne return Positive is
   begin
      return Ligne_Courante;
   end Num_Ligne;

   -- Permet d'enlever les caractères d'échappement
   function Supprimer_Echappement (Ch : in String) return Chaine is  
      Present : Boolean := False;
      Ma_Chaine : String (Ch'First + 1 .. Ch'Last - 1);
      Cpt : Positive := Ch'First + 1;
   begin
      for I in Ch'First + 1 .. Ch'Last - 1 loop

         if Present then
            Ma_Chaine (Cpt) := Ch (I);
            Present := False;
            Cpt := Cpt +1;
         elsif Ch (I) = '\' then
            Present := True;
         else
            Ma_Chaine (Cpt) := Ch (I);
            Cpt := Cpt + 1;
         end if;
      end loop;

      return Creation (Ma_Chaine (Ma_Chaine'First .. Cpt - 1));
   end Supprimer_Echappement;

-- Emplacement de YYLex
##

   Code : Token;
   C    : Chaine;

begin

   -- Ajout des mots réservés dans le dictionnaire
   
   Code := Cast_Lex;
   Mettre_A_Jour ("cast", Code, C);

   Code := Classe_Lex;
   Mettre_A_Jour ("class", Code, C);

   Code := Extends_Lex;
   Mettre_A_Jour ("extends", Code, C);

   Code := Else_Lex;
   Mettre_A_Jour ("else", Code, C);

   Code := Elsif_Lex;
   Mettre_A_Jour ("elsif", Code, C);

   Code := False_Lex;
   Mettre_A_Jour ("false", Code, C);

   Code := If_Lex;
   Mettre_A_Jour ("if", Code, C);

   Code := Instanceof_Lex;
   Mettre_A_Jour ("instanceof", Code, C);

   Code := New_Lex;
   Mettre_A_Jour ("new", Code, C);

   Code := Null_Lex;
   Mettre_A_Jour ("null", Code, C);

   Code := Readint_Lex;
   Mettre_A_Jour ("readInt", Code, C);

   Code := Readfloat_Lex;
   Mettre_A_Jour ("readFloat", Code, C);

   Code := Print_Lex;
   Mettre_A_Jour ("print", Code, C);

   Code := Println_Lex;
   Mettre_A_Jour ("println", Code, C);

   Code := Protected_Lex;
   Mettre_A_Jour ("protected", Code, C);

   Code := Return_Lex;
   Mettre_A_Jour ("return", Code, C);

   Code := This_Lex;
   Mettre_A_Jour ("this", Code, C);

   Code := True_Lex;
   Mettre_A_Jour ("true", Code, C);

   Code := While_Lex;
   Mettre_A_Jour ("while", Code, C);

end Lexical;
