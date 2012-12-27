-------------------------------------------------------------------------------
--  Syntax : spécification Ayacc -> corps du paquetage
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

--|  Syntaxe de la calculette

%token CST EGAL

{
   type Nature_Valeur is (Int, Autre);
   -- A chaque symbole de la grammaire est associée une valeur
   -- qui peut être un entier (Nature = Int) ou rien (Nature = Autre)

   type YYSType (Nature : Nature_Valeur := Autre) is
   -- Type des valeurs associées à chaque symbole de la grammaire
      record
         case Nature is
            when Int =>
               Valeur : Integer;
            when Autre =>
               null;
         end case;
      end record;
}

-- On définit l'associativité et la priorité des opérateurs
%left '+' '-'
%left '*'

-- On déclare l'axiome de la grammaire
%start program

%%

program :
   -- empty
      |
   program command
      ;


command :
   exp EGAL
      {
      Put_Line ("-> " & Integer'Image ($1.Valeur));
      };


exp :
   CST
      {
      $$ := $1;
      }|
   '(' exp ')'
      {
      $$ := $2;
      }|
   exp '+' exp
      {
      $$ := (Int, Eval (Add, $1.Valeur, $3.Valeur));
      }|
   exp '-' exp
      {
      $$ := (Int, Eval (Sub, $1.Valeur, $3.Valeur));
      }|
   exp '*' exp
      {
      $$ := (Int, Eval (Mult, $1.Valeur, $3.Valeur));
      };

%%

--|  Corps du paquetage d'analyse syntaxique

with Lexico, Syntax_Tokens, Syntax_Shift_Reduce, Syntax_Goto, Ada.Text_IO;
use  Lexico, Syntax_Tokens, Syntax_Shift_Reduce, Syntax_Goto, Ada.Text_IO;

package body Syntax is

   -- Les opérateurs sont '+' (Add), '-' (Sub) et '*' (Mult)
   type Op_Type is (Add, Sub, Mult);

   -- affiche un message d'erreur
   procedure YYError (Text : in String) is
   begin
      Put_Line ("***** ligne" & Positive'Image (Ligne_Cour) & " : " & Text);
   end YYError;

   -- évalue une expression
   function Eval (Op : Op_Type; V1, V2 : Integer) return Integer is
   begin
      case Op is
         when Add => return (V1 + V2);
         when Sub => return (V1 - V2);
         when Mult => return (V1 * V2);
      end case;
   exception
      when Constraint_Error =>
         YYError ("Erreur numerique");
         raise Erreur_Debordement;
   end Eval;

   -- Ici va YYParse
   ##

end Syntax;
