-------------------------------------------------------------------------------
--  Specification de la passe 1 de la verification contextuelle
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     16/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Ada.Text_IO, Arbres, Types_Base;
use  Ada.Text_IO, Arbres, Types_Base;

with Erreurs, Exp_Types, Defns, Decors, Symboles, types_base, verif_commun;
use  Erreurs, Exp_Types, Defns, Decors, Symboles, types_base, verif_commun, Arbres.Listes_Arbres;

package body Verif_Passe1 is

   Defensif : constant Boolean := True;

   procedure Mettre_Au_Point (Niveau : in Positive; S : in String) is
      -- plus Niveau_Max est eleve, plus il y a d'affichage
      Niveau_Max : constant := 0;
   begin
      if Niveau <= Niveau_Max then
         Put_Line ("Verif_passe1 : " & S);
      end if;
   end Mettre_Au_Point;


   ----------------------
   -- Verif_Ext_Classe --
   ----------------------

   procedure Verif_Ext_Classe (A : in Arbre; Super : out Chaine) is
   begin
      Mettre_Au_Point (3, "entree de Verif_Ext_Classe");
      
      --Vérification de la super classe--
      case Acces_Noeud_EXT_CLASSE (A) is     
         when Noeud_Ident => 
	    Super := Acces_Nom(A);
         when Noeud_Vide =>
	    Super := Nom_Object;
      end case;
   end Verif_Ext_Classe;


   -------------------
   -- Verif_Classe --
   -------------------

   procedure Verif_Classe (A : in Arbre; Env_Types : in out Environ) is
      Nom : Chaine;
      Super : Chaine;
      Classe : Defn;
      EnvSuper: Defn;
      Present : Boolean;      
   begin
      Mettre_Au_Point (3, "entree de Verif_Classe");
      
      Nom := Acces_Nom( Acces_Fils_1(A));     
      Verif_Ext_Classe(Acces_Fils_2(A), Super);      
      
      Classe := Creation_Classe (Nom);     
      EnvSuper := Acces_Defn(Env_Types, Super);
	 
      if EnvSuper = null then
	 Afficher_Erreur( Ident_Non_Decl, Acces_Num_Ligne(A), Acces_String(Super), "1.4");
      elsif Acces_Nature(EnvSuper) /= Defn_Classe then
	 Afficher_Erreur( Ident_Classe_Attendu, Acces_Num_Ligne(A), "1.4");
      end if;
	    
      Changer_Extension (Classe, Super);            
      
      --On ajoute la définition de la classe dans l'environnement Env_Types--
      Ajouter (Env_Types, Nom, Classe, Present);
      if Present = true then
	 Afficher_Erreur( Ident_Deja_Decl, Acces_Num_Ligne(A), Acces_String(Nom), "1.4");
      end if;
      
      --Decoration de la classe --    
      Changer_Decor (Acces_Fils_1(A), Creation(Classe));
   
   end Verif_Classe;

   
   ------------------------
   -- Verif_Liste_Classe --
   ------------------------

   procedure Verif_Liste_Classe (L : in Liste_Arbres; 
				 Env_Types : in out Environ)
      
   is
      Iter : constant Iterateur := Creation (L);
   begin
      Mettre_Au_Point (3, "entree de Verif_Liste_Classe");
      
      --On vérifie chaque classe--
      while not Fini (Iter) loop
         Verif_Classe(Suivant (Iter),
                             Env_Types);
      end loop;
      
   end Verif_Liste_Classe;   
   
  
   -------------------
   -- Verif_Program --
   -------------------

   procedure Verif_Program (A : in Arbre; Env_Types : in out Environ) is
   begin
      Mettre_Au_Point (3, "entree de Verif_Program");
      
      Verif_Liste_Classe (Acces_Fille_1 (A),Env_Types);
      
   end Verif_Program;

   
   ------------------------
   -- Verifier_Decorer_1 --
   ------------------------

   procedure Verifier_Decorer_1 (A : in Arbre; Env_Types : out Environ) is
   begin
      Mettre_Au_Point (3, "entree de Verifier_Decorer_1");
      
     --On initialise l'environnement Env_Types--
      Initialiser_Symb;
      Env_Types := Acces_Env_Types;
      
      Verif_Program (A, Env_Types);
      
   end Verifier_Decorer_1;
   
end Verif_Passe1;
