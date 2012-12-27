-------------------------------------------------------------------------------
--  Syntax : spécification du paquetage
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

--|  Interface de l'analyseur syntaxique

with Syntax_Tokens;          -- pour l'exception Syntax_Error

package Syntax is

   procedure YYParse;
   -- Analyse une suite d'expressions et imprime au terminal
   -- la valeur de chaque expression.
   -- En cas d'analyse incorrecte, lève l'exception Syntax_Error.
   -- En cas de caractere illégal, lève l'exception Lexical_Error.
   -- En cas de débordement arithmétique, lève l'exception Overflow_Error.
   -- Lexical_Error et Overflow_Error sont définies dans Lexico.ads.

   Erreur_Syntaxe : exception renames Syntax_Tokens.Syntax_Error;
   -- levée en cas d'erreur de syntaxe

end Syntax;
