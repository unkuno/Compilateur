-------------------------------------------------------------------------------
--  Calc : corps de procédure
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

--|  Programme principal de la calculette

with Lexico, Syntax, Ada.Text_IO;
use  Lexico, Syntax, Ada.Text_IO;

procedure Calc is
begin
   YYParse;
exception
   when Erreur_Syntaxe | Erreur_Lexicale | Erreur_Debordement =>
      -- On s'arrête à la première erreur dans le flot d'entrée
      null;
   when others =>
      Put_Line ("*** Erreur interne. Contacter votre vendeur");
      raise ; -- On relève l'exception
end Calc;
