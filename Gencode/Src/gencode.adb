-------------------------------------------------------------------------------
--  Corps du paquetage Gencode de génération de code
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------


with Ada.Text_IO, Fichier_Assembleur, Types_Base;
use  Ada.Text_IO, Fichier_Assembleur, Types_Base;

with Outils_Instructions, Pseudo_Code, Gestion_Registres;
use  Outils_Instructions, Pseudo_Code, Gestion_Registres;

with Gencode_Programme, Gencode_Commun, Gencode_Classes;
use  Gencode_Programme, Gencode_Commun, Gencode_Classes;

package body Gencode is

   Defensif : constant Boolean := True;

   procedure Mettre_Au_Point (Niveau : in Positive; S : in String) is
      -- plus Niveau_Max est eleve, plus il y a d'affichage
      Niveau_Max : constant := 0;
   begin
      if Niveau <= Niveau_Max then
         Put_Line (Standard_Error, "Gencode : " & S);
      end if;
   end Mettre_Au_Point;
   
   
   ----------------------
   -- Ecrire_Programme --
   ----------------------
   
   procedure Ecrire_Programme (A : in Arbre) is
      Compteur_Pile : Entier;
   begin
      Mettre_Au_Point (3, "entree de Ecrire_Programme");

      -- Passe 1
      Compteur_Pile := Ecrire_Liste_Classes (Acces_Fille_1 (A));

      -- Passe 2
      Ecrire_Code_Programme (A, Compteur_Pile);
      
      Mettre_Au_Point (3, "sortie de Ecrire_Programme");
   end Ecrire_Programme;


   ------------------
   -- Generer_Code --
   ------------------
   
   procedure Generer_Code (A        : in Arbre;
                           Nom      : in String;
                           Nb_Reg   : in Entier;
                           No_Check : in Boolean) is
   begin
      Mettre_Au_Point (3, "entree de Generer_Code");
      Creer_Assembleur (Nom);

      Initialiser_Registres (Nb_Reg);
      Initialise_Programme (No_Check);

      Ecrire_Programme (A);

      Afficher_Programme;

      Fermer_Assembleur;
      Mettre_Au_Point (3, "sortie de Generer_Code");
   end Generer_Code;

end Gencode;
