-------------------------------------------------------------------------------
--  Procédure de test de la vérification contextuelle
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

--| Effectue les étapes d'analyse syntaxique et de vérifications contextuelles
--| du compilateur
--| Usage : test_verif nom_fichier

with Ada.Text_IO, Ada.Exceptions, Ada.Command_Line;
use  Ada.Text_IO, Ada.Exceptions, Ada.Command_Line;

with Arbres, Syntaxe, Fichier;
use  Arbres, Syntaxe, Fichier;

with Verif;
use  Verif;

procedure Test_Verif is

   -- 0 : Ni décompilation ni affichage
   -- 1 : Décompilation après l'étape de vérifications contextuelles
   -- 2 ou plus : Affichage de l'arbre après les vérifications contextuelles
   -- 3 ou plus : Affichage de l'arbre après l'analyse syntaxique
   Niveau_Aff_Decomp : constant := 2;

   -- Modifier la constante Niveau pour le niveau de détail de l'arbre
   Niveau : constant := 1;

   A : Arbre;

begin
   Ouvrir_Fichier;
   Analyser (A);
   Put_Line ("/* Programme syntaxiquement correct */");
   if Niveau_Aff_Decomp >= 3 then
      Afficher (A);
   end if;
   Verifier_Decorer (A);
   Put_Line ("/* Programme contextuellement correct */");
   if Niveau_Aff_Decomp = 1 then
      Decompiler (A, Niveau);
   elsif Niveau_Aff_Decomp >= 2 then
      Afficher (A, Niveau);
   end if;
exception
   when Erreur : Erreur_Fichier |
                 Erreur_Lexical | Limitation_Lexical |
                 Erreur_Syntaxe |
                 Erreur_Verif   | Limitation_Verif =>
      Put_Line ("Exception " & Exception_Name (Erreur) & " levee");
      Set_Exit_Status (Failure);
end Test_Verif;
