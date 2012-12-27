-------------------------------------------------------------------------------
--  syntaxe.y : analyseur syntaxique Ayacc -> corps du paquetage Syntaxe
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

-- syntaxe.y : définition de la syntaxe hors contexte du langage Deca

-- Définition des lexèmes
%token Idf_Lex Entier_Lex Flottant_Lex Chaine_Lex Null_Lex

%token Cast_Lex Classe_Lex Extends_Lex Else_Lex Elsif_Lex False_Lex If_Lex
%token Instanceof_Lex New_Lex Null_Lex ReadInt_Lex ReadFloat_Lex Print_Lex
%token Println_Lex Protected_Lex Return_Lex This_Lex True_Lex While_Lex

%token And_Lex Or_Lex
%token Egal_Egal_Lex Diff_Lex Inf_Egal_Lex Sup_Egal_Lex

-- Définition des associativités et priorités des opérateurs
-- Le opérateurs sont dans l'ordre de priorité croissante
%right '='
%left Or_Lex
%left And_Lex
%nonassoc Egal_Egal_Lex Diff_Lex
%nonassoc '<' '>' Inf_Egal_Lex Sup_Egal_Lex Instanceof_Lex
%left '+' '-'
%left '*' '/' '%'
%nonassoc '!' moins_unaire
%left '.'

%with Attributs
%use Attributs

{
   subtype YYStype is Attribut;
}


-- Axiome de la grammaire
%start program

%%

program             : liste_classes principal
{
   Mettre_Au_Point (1, "program             : liste_classes principal");
   $$ := Creation_NT_Arbre (Creation_Programme (Acces_Liste ($1),
                                                Acces_Arbre ($2)));
}
                    ;

liste_classes       : -- epsilon
{
   Mettre_Au_Point (1, "liste_classes       : -- epsilon");
   $$ := Creation_NT_Liste (Creation);
}
                    | liste_classes classe
{
   Mettre_Au_Point (1, "liste_classes       : liste_classes classe");
   Ajouter (Acces_Liste ($1), Acces_Arbre ($2));
   $$ := $1;
}
                    ;

classe              : Classe_Lex ident ext_classe '{' liste_constituants '}'
{
   Mettre_Au_Point (1, "classe              : Classe_Lex ident ext_classe " &
                                              "'{' liste_constituants '}'");
   $$ := Creation_NT_Arbre (Creation_Classe (Acces_Arbre ($2),
                                             Acces_Arbre ($3),
                                             Acces_Liste ($5),
                                             Acces_Num_Ligne ($1)));
}
                    ;

ident               : Idf_Lex
{
   Mettre_Au_Point (1, "ident               : Idf_Lex");
   $$ := Creation_NT_Arbre (Creation_Ident (Acces_Ident ($1),
                                            Acces_Num_Ligne ($1)));
}
                    ;

ext_classe          : -- epsilon
{
   Mettre_Au_Point (1, "ext_classe          : -- epsilon");
   $$ := Creation_NT_Arbre (Creation_Vide);
}
                    | Extends_Lex ident
{
   Mettre_Au_Point (1, "ext_classe          : Extends_Lex ident");
   $$ := $2;
}
                    ;

liste_constituants  : -- epsilon
{
   Mettre_Au_Point (1, "liste_constituants  : -- epsilon");
   $$ := Creation_NT_Liste (Creation);
}
                    | liste_constituants constituant
{
   Mettre_Au_Point (1, "liste_constituants  : liste_constituants constituant");
   Ajouter (Acces_Liste ($1), Acces_Arbre ($2));
   $$ := $1;
}
                    ;

constituant         : champ
{
   Mettre_Au_Point (1, "constituant         : champ");
   $$ := $1;
}
                    | methode
{
   Mettre_Au_Point (1, "constituant         : methode");
   $$ := $1;
}
                    ;

champ               : type suite_decl_champ ';'
{
   Mettre_Au_Point (1, "champ               : type suite_decl_champ ';'");
   $$ := Creation_NT_Arbre (Creation_Champ (Creation_Vide,
                                            Acces_Arbre ($1),
                                            Acces_Liste ($2),
                                            Acces_Num_Ligne
                                              (Acces_Arbre ($1))));
}
                    | Protected_Lex type suite_decl_champ ';'
{
   Mettre_Au_Point (1, "champ               : Protected_Lex type " &
                                              "suite_decl_champ ';'");
   $$ := Creation_NT_Arbre (Creation_Champ (Creation_Protege (
                                            Acces_Num_Ligne ($1)),
                                            Acces_Arbre ($2),
                                            Acces_Liste ($3),
                                            Acces_Num_Ligne ($1)));
}
                    ;

type                : ident
{
   Mettre_Au_Point (1, "type                : ident");
   $$ := $1;
}
                    ;

suite_decl_champ    : decl_champ
{
   Mettre_Au_Point (1, "suite_decl_champ    : decl_champ");
   $$ := Creation_NT_Liste (Creation (Acces_Arbre ($1)));
}
                    | suite_decl_champ ',' decl_champ
{
   Mettre_Au_Point (1, "suite_decl_champ    : suite_decl_champ ',' decl_champ");
   Ajouter (Acces_Liste ($1), Acces_Arbre ($3));
   $$ := $1;
}
                    ;

decl_champ          : ident initialisation
{
   Mettre_Au_Point (1, "decl_champ          : ident initialisation");
   $$ := Creation_NT_Arbre (Creation_Decl_Champ (Acces_Arbre ($1),
                                                 Acces_Arbre ($2),
                                                 Acces_Num_Ligne
                                                   (Acces_Arbre ($1))));
}
                    ;

initialisation      : -- epsilon
{
   Mettre_Au_Point (1, "initialisation      : -- epsilon");
   $$ := Creation_NT_Arbre (Creation_Vide);
}
                    | '=' exp
{
   Mettre_Au_Point (1, "initialisation      : '=' exp");
   $$ := $2;
}
                    ;

methode             : type ident '(' liste_param ')' liste_declarations bloc
{
   Mettre_Au_Point (1, "methode             : type ident '(' liste_param ')' " &
                                              "liste_declarations bloc");
   $$ := Creation_NT_Arbre (Creation_Methode (Acces_Arbre ($1),
                                              Acces_Arbre ($2),
                                              Acces_Liste ($4),
                                              Acces_Liste ($6),
                                              Acces_Liste ($7),
                                              Acces_Num_Ligne
                                                (Acces_Arbre ($1))));
}
                    ;

liste_param         : -- epsilon
{
   Mettre_Au_Point (1, "liste_param         : -- epsilon");
   $$ := Creation_NT_Liste (Creation);
}
                    | suite_param
{
   Mettre_Au_Point (1, "liste_param         : suite_param");
   $$ := $1;
}
                    ;

suite_param         : parametre
{
   Mettre_Au_Point (1, "suite_param         : parametre");
   $$ := Creation_NT_Liste (Creation (Acces_Arbre ($1)));
}
                    | suite_param ',' parametre
{
   Mettre_Au_Point (1, "suite_param         : suite_param ',' parametre");
   Ajouter (Acces_Liste ($1), Acces_Arbre ($3));
   $$ := $1;
}
                    ;

parametre           : type ident
{
   Mettre_Au_Point (1, "parametre           : type ident");
   $$ := Creation_NT_Arbre (Creation_Parametre (Acces_Arbre ($1),
                                                Acces_Arbre ($2),
                                                Acces_Num_Ligne
                                                  (Acces_Arbre ($1))));
}
                    ;

liste_declarations  : -- epsilon
{
   Mettre_Au_Point (1, "liste_declarations  : -- epsilon");
   $$ := Creation_NT_Liste (Creation);
}
                    | liste_declarations decl_variable
{
   Mettre_Au_Point (1, "liste_declarations  : liste_declarations " &
                                              "decl_variable");
   Ajouter (Acces_Liste ($1), Acces_Arbre ($2));
   $$ := $1;
}
                    ;

decl_variable       : type suite_decl_var ';'
{
   Mettre_Au_Point (1, "decl_variable       : type suite_decl_var ';'");
   $$ := Creation_NT_Arbre (Creation_Decl_Variable (Acces_Arbre ($1),
                                                    Acces_Liste ($2),
                                                    Acces_Num_Ligne
                                                      (Acces_Arbre ($1))));
}
                    ;

suite_decl_var      : decl_var
{
   Mettre_Au_Point (1, "suite_decl_var      : decl_var");
   $$ := Creation_NT_Liste (Creation(Acces_Arbre($1)));
}
                    | suite_decl_var ',' decl_var
{
   Mettre_Au_Point (1, "suite_decl_var      : suite_decl_var ',' decl_var");
   Ajouter (Acces_Liste ($1), Acces_Arbre ($3));
   $$ := $1;
}
                    ;

decl_var            : ident initialisation
{
   Mettre_Au_Point (1, "decl_var            : ident initialisation");
   $$ := Creation_NT_Arbre (Creation_Decl_Var (Acces_Arbre ($1), 
                                               Acces_Arbre ($2), 
                                               Acces_Num_Ligne
                                                 (Acces_Arbre ($1))));
}
                    ;

bloc                : '{' liste_inst '}'
{
   Mettre_Au_Point (1, "bloc                : '{' liste_inst '}'");
   $$ := Creation_NT_Liste (Acces_Liste ($2));
}
                    ;

liste_inst          : -- epsilon
{
   Mettre_Au_Point (1, "liste_inst          : -- epsilon");
   $$ := Creation_NT_Liste (Creation);
}
                    | liste_inst inst
{
   Mettre_Au_Point (1, "liste_inst          : liste_inst inst");
   Ajouter (Acces_Liste ($1), Acces_Arbre ($2));
   $$ := $1;
}
                    ;

inst                : ';'   -- Instruction vide
{
   Mettre_Au_Point (1, "inst                : ';'   -- Instruction vide");
   $$ := Creation_NT_Arbre (Creation_Nop (Acces_Num_Ligne ($1)));
}
                    | Return_Lex exp ';'
{
   Mettre_Au_Point (1, "inst                : Return_Lex exp ';'");
   $$ := Creation_NT_Arbre (Creation_Retour (Acces_Arbre ($2), 
                                             Acces_Num_Ligne ($1)));
}
                    | suite_cond sinon
{
   Mettre_Au_Point (1, "inst                : suite_cond sinon");
   $$ := Creation_NT_Arbre (Creation_Si (Acces_Liste ($1),
                                         Acces_Liste ($2),
                                         Acces_Num_Ligne
                                           (Premier (Acces_Liste ($1)))));
}
                    | While_Lex '(' exp ')' bloc
{
   Mettre_Au_Point (1, "inst                : While_Lex '(' exp ')' bloc");
   $$ := Creation_NT_Arbre (Creation_Tantque (Acces_Arbre ($3),
                                              Acces_Liste ($5), 
                                              Acces_Num_Ligne ($1)));
}
                    | Print_Lex '(' liste_exp ')' ';'
{
   Mettre_Au_Point (1, "inst                : Print_Lex " &
                                              "'(' liste_exp ')' ';'");
   $$ := Creation_NT_Arbre (Creation_Ecriture (Acces_Liste ($3),
                                               Acces_Num_Ligne ($1)));
}
                    | Println_Lex '(' liste_exp ')' ';'
{
   Mettre_Au_Point (1, "inst                : Println_Lex " &
                                              "'(' liste_exp ')' ';'");
   $$ := Creation_NT_Arbre (Creation_Ecriture_Ligne (Acces_Liste ($3),
                                                     Acces_Num_Ligne ($1)));
}
                    | exp ';'
{
   Mettre_Au_Point (1, "inst                : exp ';'");
   $$ := $1;
}
                    ;

suite_cond          : If_Lex '(' exp ')' bloc
{
   Mettre_Au_Point (1, "suite_cond          : If_Lex '(' exp ')' bloc") ;
   $$ := Creation_NT_Liste (Creation (Creation_Cond (Acces_Arbre ($3), 
                                                     Acces_Liste ($5), 
                                                     Acces_Num_Ligne ($1))));
}
                    | suite_cond Elsif_Lex '(' exp ')' bloc
{
   Mettre_Au_Point (1, "suite_cond          : suite_cond Elsif_Lex " &
                                              "'(' exp ')' bloc") ;
   Ajouter (Acces_Liste ($1), Creation_Cond (Acces_Arbre ($4),
                                             Acces_Liste ($6),
                                             Acces_Num_Ligne ($2)));
   $$ := $1;
}
                    ;

sinon               : -- epsilon
{
   Mettre_Au_Point (1, "sinon               : -- epsilon") ;
   $$ := Creation_NT_Liste (Creation);
}
                    | Else_Lex bloc
{
   Mettre_Au_Point (1, "sinon               : Else_Lex bloc") ;
   $$ := $2;
}
                    ;

liste_exp           : -- epsilon
{
   Mettre_Au_Point (1, "liste_exp           : -- epsilon");
   $$ := Creation_NT_Liste (Creation);
}
                    | suite_exp
{
   Mettre_Au_Point (1, "liste_exp           : -- suite_exp");
   $$ := $1;   
}
                    ;

suite_exp           : exp
{
   Mettre_Au_Point (1, "suite_exp           : exp");
   $$ := Creation_NT_Liste (Creation (Acces_Arbre ($1)));
}
                    | suite_exp ',' exp
{
   Mettre_Au_Point (1, "suite_exp           : suite_exp ',' exp");
   Ajouter (Acces_Liste ($1), Acces_Arbre ($3));
   $$ := $1;
}
                    ;

exp                 : place '=' exp
{
   Mettre_Au_Point (1, "exp                 : place '=' exp");
   $$ := Creation_NT_Arbre (Creation_Affect (Acces_Arbre ($1), 
                                             Acces_Arbre ($3),
                                             Acces_Num_Ligne ($2))); 
}
                    | exp Or_Lex exp
{
   Mettre_Au_Point (1, "exp                 : exp Or_Lex exp");
   $$ := Creation_NT_Arbre (Creation_Ou (Acces_Arbre ($1), 
                                         Acces_Arbre ($3),
                                         Acces_Num_Ligne ($2)));
}
                    | exp And_Lex exp
{
   Mettre_Au_Point (1, "exp                 : exp And_Lex exp");
   $$ := Creation_NT_Arbre (Creation_Et (Acces_Arbre ($1), 
                                         Acces_Arbre ($3),
                                         Acces_Num_Ligne ($2))); 
}
                    | exp Egal_Egal_Lex exp
{
   Mettre_Au_Point (1, "exp                 : exp Egal_Egal_Lex exp");
   $$ := Creation_NT_Arbre (Creation_Egal_Egal (Acces_Arbre ($1), 
                                                Acces_Arbre ($3),
                                                Acces_Num_Ligne ($2))); 
}
                    | exp Diff_Lex exp
{
   Mettre_Au_Point (1, "exp                 : exp Diff_Lex exp");
   $$ := Creation_NT_Arbre (Creation_Diff (Acces_Arbre ($1), 
                                           Acces_Arbre ($3),
                                           Acces_Num_Ligne ($2))); 
}
                    | exp '<' exp
{
   Mettre_Au_Point (1, "exp                 : exp '<' exp");
   $$ := Creation_NT_Arbre (Creation_Inf (Acces_Arbre ($1), 
                                          Acces_Arbre ($3),
                                          Acces_Num_Ligne ($2))); 
}
                    | exp '>' exp
{
   Mettre_Au_Point (1, "exp                 : exp '>' exp");
   $$ := Creation_NT_Arbre (Creation_Sup (Acces_Arbre ($1), 
                                          Acces_Arbre ($3),
                                          Acces_Num_Ligne ($2))); 
}
                    | exp Inf_Egal_Lex exp
{
   Mettre_Au_Point (1, "exp                 : exp Inf_Egal_Lex exp");
   $$ := Creation_NT_Arbre (Creation_Inf_Egal (Acces_Arbre ($1), 
                                               Acces_Arbre ($3),
                                               Acces_Num_Ligne ($2))); 
}
                    | exp Sup_Egal_Lex exp
{
   Mettre_Au_Point (1, "exp                 : exp Sup_Egal_Lex exp");
   $$ := Creation_NT_Arbre (Creation_Sup_Egal (Acces_Arbre ($1), 
                                               Acces_Arbre ($3),
                                               Acces_Num_Ligne ($2))); 
}
                    | exp Instanceof_Lex type
{
   Mettre_Au_Point (1, "exp                 : exp Instanceof_Lex type");
   $$ := Creation_NT_Arbre (Creation_Instanceof (Acces_Arbre ($1), 
                                                 Acces_Arbre ($3),
                                                 Acces_Num_Ligne ($2))); 
}
                    | exp '+' exp
{
   Mettre_Au_Point (1, "exp                 : exp '+' exp");
   $$ := Creation_NT_Arbre (Creation_Plus (Acces_Arbre ($1), 
                                           Acces_Arbre ($3),
                                           Acces_Num_Ligne ($2))); 
}
                    | exp '-' exp
{
   Mettre_Au_Point (1, "exp                 : exp '-' exp");
   $$ := Creation_NT_Arbre (Creation_Moins (Acces_Arbre ($1), 
                                            Acces_Arbre ($3),
                                            Acces_Num_Ligne ($2))); 
}
                    | exp '*' exp
{
   Mettre_Au_Point (1, "exp                 : exp '*' exp");
   $$ := Creation_NT_Arbre (Creation_Mult (Acces_Arbre ($1), 
                                           Acces_Arbre ($3),
                                           Acces_Num_Ligne ($2))); 
}
                    | exp '/' exp
{
   Mettre_Au_Point (1, "exp                 : exp '/' exp");
   $$ := Creation_NT_Arbre (Creation_Div (Acces_Arbre ($1), 
                                          Acces_Arbre ($3),
                                          Acces_Num_Ligne ($2))); 
}
                    | exp '%' exp
{
   Mettre_Au_Point (1, "exp                 : exp '%' exp");
   $$ := Creation_NT_Arbre (Creation_Reste (Acces_Arbre ($1), 
                                            Acces_Arbre ($3),
                                            Acces_Num_Ligne ($2))); 
}
                    | '-' exp                %prec moins_unaire
{
   Mettre_Au_Point (1, "exp                 : '-' exp");
   $$ := Creation_NT_Arbre (Creation_Moins_Unaire (Acces_Arbre ($2), 
                                                   Acces_Num_Ligne ($1))); 
}
                    | '!' exp
{
   Mettre_Au_Point (1, "exp                 : '!' exp");
   $$ := Creation_NT_Arbre (Creation_Non (Acces_Arbre ($2), 
                                          Acces_Num_Ligne ($1)));
}
                    | Cast_Lex '<' type '>' '(' exp ')'
{
   Mettre_Au_Point (1, "exp                 : Cast_Lex '<' type '>' " &
                                              "'(' exp ')'");
   $$ := Creation_NT_Arbre (Creation_Conversion (Acces_Arbre ($3), 
                                                 Acces_Arbre ($6),
                                                 Acces_Num_Ligne ($1)));
}
                    | Entier_Lex
{
   Mettre_Au_Point (1, "exp                 : Entier_Lex");
   $$ := Creation_NT_Arbre (Creation_Entier (Acces_Entier ($1), 
                                             Acces_Num_Ligne ($1)));
}
                    | Flottant_Lex
{
   Mettre_Au_Point (1, "exp                 : Flottant_Lex");
   $$ := Creation_NT_Arbre (Creation_Flottant (Acces_Flottant ($1), 
                                               Acces_Num_Ligne ($1)));
}
                    | Chaine_Lex
{
   Mettre_Au_Point (1, "exp                 : Chaine_Lex");
   $$ := Creation_NT_Arbre (Creation_Chaine (Acces_Chaine ($1), 
                                             Acces_Num_Ligne ($1)));
}
                    | True_Lex
{
   Mettre_Au_Point (1, "exp                 : True_Lex");
   $$ := Creation_NT_Arbre (Creation_Vrai (Acces_Num_Ligne ($1)));
}
                    | False_Lex
{
   Mettre_Au_Point (1, "exp                 : False_Lex");
   $$ := Creation_NT_Arbre (Creation_Faux (Acces_Num_Ligne ($1)));
}
                    | Null_Lex
{
   Mettre_Au_Point (1, "exp                 : Null_Lex");
   $$ := Creation_NT_Arbre (Creation_Null (Acces_Num_Ligne ($1)));
}
                    | This_Lex
{
   Mettre_Au_Point (1, "exp                 : This_Lex");
   $$ := Creation_NT_Arbre (Creation_This (Acces_Num_Ligne ($1)));
}
                    | ReadInt_Lex '(' ')'
{
   Mettre_Au_Point (1, "exp                 : ReadInt_Lex '(' ')'");
   $$ := Creation_NT_Arbre (Creation_Lecture_Entier (Acces_Num_Ligne ($1)));
}
                    | ReadFloat_Lex '(' ')'
{
   Mettre_Au_Point (1, "exp                 : ReadFloat_Lex '(' ')'");
   $$ := Creation_NT_Arbre (Creation_Lecture_Flottant (Acces_Num_Ligne ($1)));
}

                    | New_Lex ident '(' ')'
{
   Mettre_Au_Point (1, "exp                 : New_Lex ident '(' ')'");
   $$ := Creation_NT_Arbre (Creation_Creation (Acces_Arbre ($2), 
                                               Acces_Num_Ligne ($1)));
}
                    | place '(' liste_exp ')'
{
   Mettre_Au_Point (1, "exp                 : place '(' liste_exp ')'");
   $$ := Creation_NT_Arbre (Creation_Appel (Acces_Arbre ($1),
                                            Acces_Liste ($3),
                                            Acces_Num_Ligne
                                              (Acces_Arbre ($1))));
}
                    | place
{
   Mettre_Au_Point (1, "exp                 : place");
   $$ := $1;
}
                    | '(' exp ')'
{
   Mettre_Au_Point (1, "exp                 : '(' exp ')'");
   $$ := $2;
}
                    ;

place               : ident
{
   Mettre_Au_Point (1, "place               : ident");
   $$ := $1;
}
                    | exp '.' ident
{
   Mettre_Au_Point (1, "place               : exp '.' ident");
   $$ := Creation_NT_Arbre (Creation_Selection (Acces_Arbre ($1),
                                                Acces_Arbre ($3),
                                                Acces_Num_Ligne ($2)));
}
                    ;

principal           : -- epsilon
{
   Mettre_Au_Point (1, "principal           : -- epsilon");
   $$ := Creation_NT_Arbre (Creation_Vide);
}
                    | liste_declarations bloc
{
   Mettre_Au_Point (1, "principal           : liste_declarations bloc");
   $$:= Creation_NT_Arbre (Creation_Principal (Acces_Liste ($1),
                                               Acces_Liste ($2)));
}
                    ;

%%

-- Corps du paquetage Syntaxe
-- Analyseur syntaxique

with Ada.Text_IO;
use  Ada.Text_IO;

with Types_Base, Attributs, Arbres, Lexical;
use  Types_Base, Attributs, Arbres, Lexical;

with Syntaxe_Tokens, Syntaxe_Shift_Reduce, Syntaxe_Goto;
use  Syntaxe_Tokens, Syntaxe_Shift_Reduce, Syntaxe_Goto;

with Lexical_DFA;
use  Lexical_DFA;

package body Syntaxe is

   procedure Mettre_Au_Point (Niveau : in Positive; S : in String) is
      -- ATTENTION : La constante Niveau_Max doit être mise à 0 quand
      -- l'analyse syntaxique est au point.
      Niveau_Max : constant := 0;
   begin
      if Niveau <= Niveau_Max then
         Put_Line ("Syntaxe : " & S);
      end if;
   end Mettre_Au_Point;

   -- Affiche un message d'erreur et lève l'exception Erreur_Syntaxe
   procedure YYError (S : in String) is
   begin
      Put_Line("Ligne" & Integer'Image(Num_Ligne) &
               " : Erreur de syntaxe aux alentours de '" & YYText & "'") ;
      raise Erreur_Syntaxe;
   end YYError;

   use Listes_Arbres; -- pour pouvoir l'abréger dans les actions

-- Emplacement de YYParse
##

   procedure Analyser (A : out Arbre) is
   begin
      YYParse;
      A := Acces_Arbre (YYVal);
   exception
      when Syntax_Error =>
         Put_Line ("Erreur de limitation syntaxique " &
                   "(trop de niveaux d'imbriquation ?)");
         raise Erreur_Syntaxe;
   end Analyser;

end Syntaxe;
