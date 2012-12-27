-------------------------------------------------------------------------------
--  Spécification du paquetage Lexical
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

-- Analyseur lexical

with Syntaxe_Tokens;
use  Syntaxe_Tokens;

package Lexical is

   -- Exception levée en cas d'erreur lexicale
   Erreur_Lexical : exception;

   -- Exception levée en cas de débordement au cours de l'analyse lexicale
   Limitation_Lexical : exception;

   -- Le numéro de ligne courant
   function Num_Ligne return Positive;

   -- Lit une unité lexicale sur l'entrée standard, puis modifie
   -- YYLVal en conséquence et retourne le token correspondant.
   -- Lève l'exception Erreur_Lexical si aucune unité lexicale
   -- n'est reconnue.
   -- Lève l'exception Limitation_Lexical en cas de débordement.
   function YYLex return Token;

end Lexical;
