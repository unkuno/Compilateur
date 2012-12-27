-------------------------------------------------------------------------------
--  Corps du paquetage Symbole
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Ada.Text_IO, Defns, Types_Base, Exp_Types, Verif_commun;
use  Ada.Text_IO, Defns, Types_Base, Exp_Types, Verif_commun, Defns.Signatures;

package body Symboles is

   Defensif : constant Boolean := True;

   procedure Mettre_Au_Point (Niveau : in Positive; S : in String) is
      -- plus Niveau_Max est eleve, plus il y a d'affichage
      Niveau_Max : constant := 0;
   begin
      if Niveau <= Niveau_Max then
         Put_Line ("Symboles : " & S);
      end if;
   end Mettre_Au_Point;
   
   Env_Types      : Environ;
   Env_Exp_Object : Environ;

   ----------------------
   -- Initialiser_Symb --
   ----------------------

   procedure Initialiser_Symb is
      Table_Env_Types      : Table_Defn := Creation;
      Table_Env_Exp_Object : Table_Defn := Creation;
      Classe_Object        : Defn       := Creation_Classe (Nom_Object);
      Methode_Equals       : Defn       := Creation_Methode
	(Creation (Acces_Type (Classe_Object)), Le_Type_Boolean);
      Present              : Boolean;
   begin
      Mettre_Au_Point (3, "entree de Initialiser_Symb");
      
      -- Mise à jour du numéro de "equals"
      Changer_Numero (Methode_Equals, 1);
      
      -- Initialisation de Env_Exp_Object
      Ajouter (Table_Env_Exp_Object,
	       Creation ("equals"),
	       Methode_Equals,
	       Present);
      
      Env_Exp_Object := Creation (Table_Env_Exp_Object, null);
      
      -- Paramètrage de Classe_Object
      Changer_Extension       (Classe_Object, null);
      Changer_Environ         (Classe_Object, Env_Exp_Object);
      Changer_Nombre_Champs   (Classe_Object, 0);
      Changer_Nombre_Methodes (Classe_Object, 1);
      
      -- Initialisation de Env_Types
      Ajouter (Table_Env_Types,
	       Nom_Object,
	       Classe_Object,
	       Present);
      
      Ajouter (Table_Env_Types,
	       Creation ("int"),
	       Creation_Type (Le_Type_Int),
	       Present);
      
      Ajouter (Table_Env_Types,
	       Creation ("float"),
	       Creation_Type (Le_Type_Float),
	       Present);
      
      Ajouter (Table_Env_Types,
	       Creation ("boolean"),
	       Creation_Type (Le_Type_Boolean),
	       Present);
      
      Ajouter (Table_Env_Types,
	       Creation ("void"),
	       Creation_Type (Le_Type_Void),
	       Present);
      
      Env_Types := Creation (Table_Env_Types, null);
      
      Mettre_Au_Point (3, "sortie de Initialiser_Symb");
   end Initialiser_Symb;

   ---------------------
   -- Acces_Env_Types --
   ---------------------

   function Acces_Env_Types return Environ is
   begin
      return Env_Types;
   end Acces_Env_Types;

   --------------------------
   -- Acces_Env_Exp_Object --
   --------------------------

   function Acces_Env_Exp_Object return Environ is
   begin
      return Env_Exp_Object;
   end Acces_Env_Exp_Object;

   -------------
   -- Ajouter --
   -------------

   procedure Ajouter (Env     : in  Environ;
		      Nom     : in  Chaine;
		      Def     : in  Defn;
		      Present : out Boolean)
   is
   begin
      Mettre_Au_Point (3, "entree de Ajouter");
      
      if Env = null then raise Erreur_Symboles; end if;
      Ajouter (Acces_Premier (Env), Nom, Def, Present);
	
      Mettre_Au_Point (3, "sortie de Ajouter");
   end Ajouter;

   ----------------
   -- Acces_Defn --
   ----------------

   function Acces_Defn (Env : Environ; Nom : Chaine) return Defn is
      Cour : Environ := Env;
      Def  : Defn    := null;
   begin
      Mettre_Au_Point (3, "entree de Acces_Defn");
      
      while Def = null and then Cour /= null loop
	 Def  := Acces_Defn (Acces_Premier (Cour), Nom);
	 Cour := Acces_Reste (Cour);
      end loop;
      
      Mettre_Au_Point (3, "sortie de Acces_Defn");
      return Def;
   end Acces_Defn;

end Symboles;
