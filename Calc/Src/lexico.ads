-------------------------------------------------------------------------------
--  Lexico : spécification du paquetage
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

--|  Interface de l'analyseur lexical

with Syntax_Tokens;    --| produit à partir de syntax.y :
use  Syntax_Tokens;    --| définition du type Token et de la variable YYLval

package Lexico is

   function YYLex return Token;
   -- lit et retourne une unité lexicale ;
   -- affecte à la variable YYLVal la valeur de la constante si
   -- l'unité lexicale reconnue est CST.

   function Ligne_Cour return Positive;
   -- retourne le numéro de la ligne courante

   Erreur_Lexicale : exception;
   -- levée en cas de caractère illégal dans le flot d'entrée

   Erreur_Debordement : exception;
   -- levée en cas de débordement arithmétique

end Lexico;
