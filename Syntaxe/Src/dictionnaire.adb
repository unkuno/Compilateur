-------------------------------------------------------------------------------
-- dictionnaire.adb : corps du paquetage Dictionnaire
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Ada.Text_IO, Ada.Characters.Handling, Tables;
use  Ada.Text_IO, Ada.Characters.Handling;

pragma Elaborate_All (Tables);

package body Dictionnaire is

   package Ma_Table is new Tables (Token);
   use Ma_Table;

   Dictio : Table := Creation (100);

   procedure Mettre_A_Jour (S    : in     String;
                            Code : in out Token;
                            C    :    out Chaine)      is
      Info_Trouvee : Token;
      Present: Boolean;
   begin
      Chercher_Inserer (Dictio, S, Code, C, Present, Info_Trouvee);
      if Present then 
         Code := Info_Trouvee;
      end if;
   end;

   procedure Traiter (C : not null access St_Chaine; Tok : in Token) is
   begin
      Put_Line ("A la chaine : " & Acces_String (C) &
                " est associe le code : " & Token'Image (Tok));
   end Traiter;

   procedure Mon_Parcours is new Parcourir (Traiter);

   procedure Imprimer is
   begin
      Mon_Parcours(Dictio);
   end Imprimer;

end Dictionnaire;
