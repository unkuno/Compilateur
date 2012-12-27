--------------------------------------------------------------------------------
--  Premiers : corps de procedure
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

--|  Ce programme lit un entier N et affiche les N premiers nombres premiers
--|  impairs

with Ada.Text_IO, Ada.Integer_Text_IO;
use  Ada.Text_IO, Ada.Integer_Text_IO;

procedure Premiers is

   procedure Mettre_Au_Point (Niveau : in Positive; S : in String) is
      -- plus Niveau_Max est eleve, plus il y a d'affichage
      Niveau_Max : constant := 2;
   begin
      if Niveau <= Niveau_Max then
         Put_Line ("Premiers : " & S);
      end if;
   end Mettre_Au_Point;

   Max : constant := 50;                 -- valeur maximum que peut prendre N

   Table : array (1 .. Max) of Positive;  -- nombres premiers

   Ind_Fin : Natural := 0;                -- indice du dernier nombre premier

   -------- =================== ---------------------------------
   function Plus_Petit_Diviseur (X : in Positive) return Positive is
   -- retourne le plus petit diviseur de X autre que l'unite
   -- X impair et 3 <= X < Table (Ind_Fin) ** 2
   begin
      Mettre_Au_Point (3, "entree de Plus_Petit_Diviseur");
      for Cour in Table'First .. Ind_Fin loop
         if X mod Table (Cour) = 0 then
            Mettre_Au_Point (2, "Plus_Petit_Diviseur sur" & Positive'Image (X) &
                       ", trouve" & Positive'Image (Table (Cour)));
            Mettre_Au_Point (3, "sortie de Plus_Petit_Diviseur");
            return Table (Cour);  -- ***** on sort de la fonction *****
         end if;
      end loop;
      -- Ici on n'a pas trouve de diviseur ; le plus petit est donc X
      Mettre_Au_Point (2, "Plus_Petit_Diviseur sur" & Positive'Image (X) &
                 ", trouve" & Positive'Image (X));
      Mettre_Au_Point (3, "sortie de Plus_Petit_Diviseur");
      return X;
   end Plus_Petit_Diviseur;

   -------- =========== --------------------------------
   function Est_Premier (X : in Positive) return Boolean is
   -- teste si X est un nombre premier
   -- X impair et 3 <= X < Table (Ind_Fin) ** 2
   begin
      Mettre_Au_Point (3, "entree de Est_Premier");
      Mettre_Au_Point (3, "sortie de Est_Premier");
      return Plus_Petit_Diviseur (X) = X;
   end Est_Premier;

   --------- ============= -----------------
   procedure Mettre_A_Jour (X : in Positive) is
   -- si X est un nombre premier, met a jour le tableau Table
   -- X impair et 3 <= X < Table (Ind_Fin) ** 2
   begin
      Mettre_Au_Point (3, "entree de Mettre_A_Jour");
      if Est_Premier (X)
      then
         Ind_Fin := Ind_Fin + 1;
         Mettre_Au_Point (1, "Mettre_A_Jour, insertion de" & Positive'Image (X) &
                    " en position" & Natural'Image (Ind_Fin));
         Table (Ind_Fin) := X;
      end if;
      Mettre_Au_Point (3, "sortie de Mettre_A_Jour");
   end Mettre_A_Jour;

   N : Positive;        -- nombre de nombres premiers
   Courant : Positive;  -- nombre a tester

begin -- Premiers

   Put ("Nombre de nombres premiers a afficher : ");
   Get (N);
   -- le test N <= Max est omis pour illustrer les erreurs d'execution

   -- remplissage de la table de nombres premiers
   Courant := 3;
   loop
      Mettre_A_Jour (Courant);
      exit when Ind_Fin = N;
      Courant := Courant + 2;
   end loop;

   -- affichage de la table
   for I in 1 .. N loop
      Put (Table (I), 6);
      if I mod 10 = 0 then
         New_Line;
      end if;
   end loop;
   New_Line;

-- exception
-- 
--    when Constraint_Error =>
--       Skip_Line;
--       Put_Line ("Recommencez avec un nombre positif inferieur a" &
--                 Positive'Image (Max));
--    when Data_Error =>
--       Skip_Line;
--       Put_Line ("Vous devez entrer un nombre entier");

end Premiers;
