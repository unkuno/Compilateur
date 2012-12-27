with Ada.Text_IO, Ada.Command_Line;
use  Ada.Text_IO, Ada.Command_Line;

procedure Demande is
   Saisie  : String (1 .. 4);
   Dernier : Natural;
   
   function Est_Oui (S : String) return Boolean is
   begin
      return
	S = "o"   or else S = "O"   or else S = "y"   or else S = "Y" or else
	S = "oui" or else S = "Oui" or else S = "OUI" or else
	S = "yes" or else S = "Yes" or else S = "YES" or else
	S = "ok"  or else S = "Ok"  or else S = "OK"  or else
	S = "da"  or else S = "Da"  or else S = "DA"  or else
	S = "1";
   end Est_Oui;
   
   function Est_Non (S : String) return Boolean is
   begin
      return
	S = "n"    or else S = "N"    or else 
	S = "non"  or else S = "Non"  or else S = "NON"  or else
	S = "no"   or else S = "No"   or else S = "NO"   or else
	S = "ko"   or else S = "Ko"   or else S = "KO"   or else
	S = "niet" or else S = "Niet" or else S = "NIET" or else
	S = "0"    or else S = "-1";
   end Est_Non;
   
begin
   loop
      Get_Line (Saisie, Dernier);
      if Dernier = Saisie'Last then Skip_Line; end if;
      
      if Est_Oui (Saisie (1 .. Dernier)) then
	 Set_Exit_Status (Success);
	 exit;
      elsif Est_Non (Saisie (1 .. Dernier)) then
	 Set_Exit_Status (Failure);
	 exit;
      else
	 Put ("Veuillez saisir [o|n] : ");
      end if;
   end loop;
   
end Demande;
