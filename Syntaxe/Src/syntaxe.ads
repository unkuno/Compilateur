-------------------------------------------------------------------------------
--  Spécification du paquetage Syntaxe
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

-- Analyseur syntaxique

with Arbres;
use  Arbres;

with Lexical;
use  Lexical;

package Syntaxe is

   -- Exceptions levées en cas d'erreurs lexicales ou syntaxique
   Erreur_Syntaxe : exception;
   Erreur_Lexical : exception renames Lexical.Erreur_Lexical;
   Limitation_Lexical : exception renames Lexical.Limitation_Lexical;

   -- Réalise l'analyse syntaxique d'un programme.
   -- Lève l'exception Erreur_Syntaxe en cas d'erreur de syntaxe.
   procedure Analyser (A : out Arbre);


end Syntaxe;
