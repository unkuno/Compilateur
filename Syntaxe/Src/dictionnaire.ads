-------------------------------------------------------------------------------
-- dictionnaire.ads : spécification du paquetage Dictionnaire
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------
-- Ce module implémente un dictionnaire permettant d'associer des codes
-- (tokens) à des chaines alphanumériques.
-- Initialement ce dictionnaire est vide, c'est-a-dire ne contient aucune
-- association.

with Types_Base, Syntaxe_Tokens;
use  Types_Base, Syntaxe_Tokens;

package Dictionnaire is

   -- Cherche si S est déjà dans le dictionnaire.
   -- . Si oui, en sortie Code contient le token associé à S
   -- . Sinon, S est rentrée dans le dictionnaire avec comme token la valeur
   --   d'entrée de Code.
   -- Dans tous les cas, C est une chaîne telle que Acces_String (C) = S.
   procedure Mettre_A_Jour (S    : in     String;
                            Code : in out Token;
                            C    :    out Chaine);

   -- Imprime le dictionnaire dans un ordre quelconque.
   -- Chaque entrée est affichée sous la forme :
   -- A la chaine : ... est associe le code : ...
   procedure Imprimer;

end Dictionnaire;
