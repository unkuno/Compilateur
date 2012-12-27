-------------------------------------------------------------------------------
--  Lexico : spécification Aflex -> corps du paquetage
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

--|  Lexicographie de la calculette

SEPAR   [ \t]
CHIFFRE [0-9]

%%

{SEPAR}+   {
   null;
           }

\n         {
   Ligne_Courante := Ligne_Courante + 1;
           }

{CHIFFRE}+ {
   YYLVal := (Nature => Int, Valeur => Conversion (YYText));
   return CST;
           }

"+"        {
   YYLVal := (Nature => Autre);
   return '+';
           }

"-"        {
   YYLVal := (Nature => Autre);
   return '-';
           }

"*"        {
   YYLVal := (Nature => Autre);
   return '*';
           }

"="        {
   YYLVal := (Nature => Autre);
   return EGAL;
           }

"("        {
   YYLVal := (Nature => Autre);
   return '(';
           }

")"        {
   YYLVal := (Nature => Autre);
   return ')';
           }

.          {
   Put_Line ("Caractere illegal : " & YYText (1));
   raise Erreur_Lexicale;
           }
%%

package body Lexico is

   Ligne_Courante : Positive := 1;     -- numéro de ligne courante

   -------- ========== ---------------
   function Ligne_Cour return Positive is
   -- retourne le numéro de ligne courante
   begin
      return Ligne_Courante;
   end Ligne_Cour;

   -------- ========== ---------------------------
   function Conversion (S : String) return Integer is
   -- convertit une chaîne de chiffres en sa valeur numérique
   begin
      return Integer'Value (S);
   exception
      when Constraint_Error =>
         Put_Line ("Debordement d'entier");
         raise Erreur_Debordement;
   end Conversion;

-- YYLex va ici
##

end Lexico;
