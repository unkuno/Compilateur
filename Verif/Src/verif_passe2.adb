-------------------------------------------------------------------------------
--  Specification de la passe 2 de la verification contextuelle
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

package body Verif_Passe2 is

   Defensif : constant Boolean := True;

   procedure Mettre_Au_Point (Niveau : in Positive; S : in String) is
      -- plus Niveau_Max est eleve, plus il y a d'affichage
      Niveau_Max : constant := 0;
   begin
      if Niveau <= Niveau_Max then
         Put_Line ("Verif_passe2 : " & S);
      end if;
   end Mettre_Au_Point;


   -----------------------
   -- Verif_Parametre --
   -----------------------

   procedure Verif_Parametre   (A         : in Arbre; 
				Env_Types : in Environ; 
				Typ       : out Exp_Type) 
				is
   begin
      Mettre_Au_Point (3, "entree de Verif_Parametre");
      Verif_Type(Acces_Fils_1(A), Env_Types, Typ, true);
      if Acces_Nature(Typ) = Type_Void then
	 Afficher_Erreur(Param_Void, Acces_Num_Ligne(A), "2.22");
      end if;
	
   end Verif_Parametre;

   -----------------------------
   -- Verif_Liste_Param_Form-----
   ------------------------------
 
    procedure Verif_Liste_Param_Form (L   :       in Liste_Arbres; 
				      Env_Types : in Environ;
				      Sig :       out Signature) 
				      is
      Iter : constant Iterateur := Creation (L);   
      Typ : Exp_Type;
   begin
      Mettre_Au_Point (3, "entree de Verif_Liste_Param_Form");
      
      --Creation de la signature--
      Sig := Defns.Signatures.Creation;      
      while not Fini (Iter) loop
	 Verif_Parametre(Suivant (Iter), Env_Types, Typ);
	 Defns.Signatures.Ajouter(Sig, Typ);				  
      end loop;     
   end Verif_Liste_Param_Form;

   ----------------------
   -- Verif_Methode --
   ----------------------

   procedure Verif_Methode  (A :          in Arbre; 
			     Env_Types :  in Environ; 
			     Super :      in Chaine; 
			     Table:       in Table_Defn;
			     NMethodes:   in out Integer) 
			     is

      Typ : Exp_Type;
      Nom : Chaine;
      Sig : Signature;
      Env_Sup : Environ;
      DefSup : Defn;
      Present : Boolean;
      Def: Defn;	
      NMethodes2: Integer;
   begin
      Mettre_Au_Point (3, "entree de Verif_Methode ");
      
      Verif_Type(Acces_Fils_1(A), Env_Types, Typ, true);
      Nom := Acces_Nom(Acces_Fils_2(A));
      Verif_Liste_Param_Form(Acces_Fille_3(A), Env_Types, Sig);
            
      if Acces_Nature(Acces_Defn(Env_Types,Super)) = Defn_Classe then
	 Env_Sup := Acces_Environ(Acces_Defn(Env_Types,Super));
	 DefSup := Acces_Defn(Env_Sup,Nom);
	    if DefSup /= null then	       
	       if Acces_Nature(DefSup) /= Defn_Methode then
		  Afficher_Erreur( Deja_Champ_Super, 
				   Acces_Num_Ligne(A), 
				   Acces_String(Nom), 
				   "2.17");
	       elsif Compare(Sig, Acces_Signature(DefSup)) = false then
		  Afficher_Erreur( Sig_Diff_Super, 
				   Acces_Num_Ligne(A), 
				   Acces_String(Nom), 
				   "2.17");
	       elsif Sous_Type(Env_Types, Typ, Acces_Type(DefSup)) = false then
		  Afficher_Erreur( Sous_Type_Retour, 
				   Acces_Num_Ligne(A), 
				   Acces_String(Nom),
				   Exp_Type_Image(Acces_Type(DefSup)),
				   "2.17");
	       end if;	    
	       NMethodes2 := Acces_Numero(DefSup); 

	     else
	       NMethodes := NMethodes+1;
	       NMethodes2 := NMethodes;	       
	    end if;
      else
	Afficher_Erreur(Erreur_Interne, 
			Acces_Num_Ligne(A),  
			"2.17");	 
      end if;
		  
      --On crée la définition de la methode--
      Def := Creation_Methode(Sig, Typ);
      Changer_Numero(Def, NMethodes2);
      Ajouter(Table, Nom, Def, Present);
      if Present = true then 
	  Afficher_Erreur( Erreur_Interne, Acces_Num_Ligne(A), "2.17"); 
      end if;   
   
      --Ajout de la decoration au niveau de la méthode--
      Changer_Decor(Acces_Fils_2(A),Creation(Def));
   
   end Verif_Methode ;

    ---------------------
   -- Verif_Decl_Champ --
   ---------------------

   procedure Verif_Decl_Champ  (A :          in Arbre; 
			        Env_Types :  in  Environ; 
				Typ :        in Exp_Type;
				Protect :    in Boolean;
				Super :      in Chaine; 
				Classe :     in Chaine; 
				Nom :        out Chaine;
				Def :        out Defn) 
			        is
      Env_Sup : Environ;
      DefSup : Defn;
   begin
      Mettre_Au_Point (3, "entree de Verif_Decl_Champ ");
      
      Nom := Acces_Nom(Acces_Fils_1(A));
      
      --On verifie si le nom du champs est déja défini dans la super classe
      Env_Sup := Acces_Environ(Acces_Defn(Env_Types,Super));
      DefSup := Acces_Defn(Env_Sup,Nom);
      if DefSup /= null then
	 if  Acces_Nature(Acces_Defn(Env_Types,Super)) = Defn_Classe and then
	       Acces_Nature(DefSup) /= Defn_Champ then
	         Afficher_Erreur( Deja_Methode_Super, Acces_Num_Ligne(A), Acces_String(Nom), "2.16");
	 end if;
      end if;     
      
      --On crée la définition du champ-- 
      Def := Creation_Champ(Protect, Typ);
      Changer_Classe(Def, Classe);
      --Ajout de la décoration au niveau du champ--
      Changer_Decor (Acces_Fils_1(A), Creation (Def));
   
   end Verif_Decl_Champ ;
   
   -----------------------------
   -- Verif_Liste_Decl_Champ --
   ------------------------------
 
    procedure Verif_Liste_Decl_Champ (L :          in Liste_Arbres; 
				      Env_Types :  in Environ; 
				      Typ :        in Exp_Type; 
				      Protect :    in Boolean; 
				      Super :      in Chaine;
				      Classe :     in Chaine;
				      Table :      in Table_Defn;
				      NChamps:     in out Integer) 
				      is
      Iter : constant Iterateur := Creation (L);   
      Nom : Chaine;
      Def : Defn;
      Present : Boolean;
      Courant: Arbre;
   begin
      Mettre_Au_Point (3, "entree de Verif_Liste_Decl_Champ");
            
      while not Fini (Iter) loop
	 Courant := Suivant (Iter);
	 --Pour chaque champs, on recupere son nom et sa définition
	 --On attribue un numéro à sa définition et on l'ajoute dans
	 --l'environnement Env_Exp (Table)
	 Verif_Decl_Champ(Courant, Env_Types, Typ, Protect, Super, Classe, Nom, Def);
	 NChamps:= NChamps+1;
	 Changer_Numero(Def,NChamps);
	 Ajouter(Table, Nom, Def, Present);
	 if Present = true then 
	    Afficher_Erreur( Doublon_Champ_Classe, Acces_Num_Ligne(Courant), Acces_String(Classe), "2.14");
	 end if;                                       
      end loop;
             
   end Verif_Liste_Decl_Champ;
 
   -----------------
   -- Verif_Champ --
   -----------------

   procedure Verif_Champ (A :         in Arbre; 
			  Env_Types : in  Environ; 
			  Super :     in Chaine; 
			  Classe :    in Chaine; 
			  Table :     in Table_Defn;
			  NChamps:    in out Integer) 
			  is
   Typ : Exp_Type;
   begin
      Mettre_Au_Point (3, "entree de Verif_Champ");
      
      Verif_Type(Acces_Fils_2(A) , Env_Types, Typ, true);
      
      if Acces_Nature(Typ) = Type_Void then
	    Afficher_Erreur( Champ_Void, Acces_Num_Ligne(Acces_Fils_2(A)), "2.12 / 2.13");  
      end if; 
        
      case Acces_Noeud_VISIBILITE (Acces_Fils_1(A)) is
	 when Noeud_Protege =>
	    Verif_Liste_Decl_Champ(Acces_Fille_3(A), Env_Types, Typ, true, Super, Classe, Table, NChamps);
	 when Noeud_Vide =>	
	    Verif_Liste_Decl_Champ(Acces_Fille_3(A), Env_Types, Typ, false, Super, Classe, Table, NChamps);
      end case;
      
   end Verif_Champ;
  
  -----------------------
   -- Verif_Constituant --
   -----------------------

   procedure Verif_Constituant (A :         in Arbre; 
				Env_Types : in Environ; 
				Super :     in Chaine; 
				Classe :    in Chaine; 
				Table :     out Table_Defn;
				NChamps:    in out Integer;
				NMethodes:  in out Integer) 
				is
   begin
      Mettre_Au_Point (3, "entree de Verif_Constituant");
      
      Table := Creation;     
      
      case Acces_Noeud_CONSTITUANT (A) is 
	 when Noeud_Champ =>
	    Verif_Champ(A, Env_Types, Super, Classe, Table, NChamps);	    
	 when Noeud_Methode =>	    
	    Verif_Methode(A, Env_Types, Super, Table, NMethodes);  
      end case;
 
   end Verif_Constituant;
   
   -----------------------------
   -- Verif_Liste_Constituants --
   ------------------------------

   procedure Verif_Liste_Constituants (L :         in Liste_Arbres; 
				       Env_Types : in Environ; 
				       Super :     in Chaine; 
				       Classe :    in Chaine; 
				       Env_Exp :   out Environ;
				       NChamps:    in out Integer;
				       NMethodes:   in out Integer) 
				       is
      Iter : constant Iterateur := Creation (L);   
      Table : Table_Defn := Creation;
      Table2 : Table_Defn;
      Courant: Arbre;
   begin
      Mettre_Au_Point (3, "entree de Verif_Liste_Constituants");
            
      while not Fini (Iter) loop

         Courant := Suivant (Iter);
         Verif_Constituant(Courant,
                             Env_Types,
                             Super,
                             Classe,
                             Table2,
                             NChamps,
                             NMethodes);                
         
        --Ajout du constituant dans la table--
         if Ajouter(Table,Table2) then
	    Afficher_Erreur( Doublon_Ident_Classe, Acces_Num_Ligne(Courant), Acces_String(Classe), "2.9");  
	 end if;                  
      end loop;
      --Creation de Env_Exp à partir de la table--
      Env_Exp := Creation (Table, null);
         
   end Verif_Liste_Constituants;
   
   ----------------------
   -- Verif_Ext_Classe --
   ----------------------

   procedure Verif_Ext_Classe (A : in Arbre; Super : out Chaine) is
   begin
      Mettre_Au_Point (3, "entree de Verif_Ext_Classe");
      
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

   procedure Verif_Classe (A : in Arbre; Env_Types : in Environ) is
      Nom : Chaine;
      Super : Chaine;
      Classe : Defn;
      Env_Exp: Environ;    
      Env_Exp_Sup: Environ;
      DefSuper : Defn;
      NChamps : Integer;
      NMethodes : Integer;
   begin
      Mettre_Au_Point (3, "entree de Verif_Classe");
      
      Nom := Acces_Nom(Acces_Fils_1(A));     
      
      --On recupere EnvSuper, la definition de la super classe dans envType
      Verif_Ext_Classe(Acces_Fils_2(A), Super);      
      DefSuper := Acces_Defn(Env_Types, Super);
	 
      if DefSuper = null then
	 Afficher_Erreur( Erreur_Interne, Acces_Num_Ligne(A), "2.4");
      elsif Acces_Nature(DefSuper) /= Defn_Classe then
	 Afficher_Erreur( Erreur_Interne, Acces_Num_Ligne(A), "2.4");
      end if;

      --On recupere le nombre de champs et de méthodes dans la super classe
      NChamps := Acces_Nombre_Champs(DefSuper);
      NMethodes := Acces_Nombre_Methodes(DefSuper);
      
      --On verifie les constituants de la classe
      --et on construit son environnement Env_Exp
      Verif_Liste_Constituants(Acces_Fille_3(A),
      			       Env_Types, 
      			       Super, 
      			       Nom, 
      			       Env_Exp,
      			       NChamps,
      			       NMethodes);

      
      --On recupère l'environnement de la super classe, Env_Exp_Sup
      --que l'on empile sur l'environnement Env_Exp
      Env_Exp_Sup := Acces_Environ(DefSuper);
      --Empilement(Env_Exp, Env_Exp_Sup);
      Changer_Reste(Env_Exp, Env_Exp_Sup);
      
      --On actualise la definition de la classe définie en passe1--
      Classe := Acces_Defn( Env_Types, Nom);
      Changer_Nombre_Champs(Classe, NChamps);
      Changer_Nombre_Methodes(Classe, NMethodes);
      Changer_Environ(Classe, Env_Exp);
      
   end Verif_Classe;

   ------------------------
   -- Verif_Liste_Classe --
   ------------------------

   procedure Verif_Liste_Classe (L : in Liste_Arbres; 
				 Env_Types : in Environ)
      
   is
      Iter : constant Iterateur := Creation (L);
   begin
      Mettre_Au_Point (3, "entree de Verif_Liste_Classe");
      
      while not Fini (Iter) loop
         Verif_Classe(Suivant (Iter),
                             Env_Types);
      end loop;

   end Verif_Liste_Classe;   
   
   -------------------
   -- Verif_Program --
   -------------------

   procedure Verif_Program (A : in Arbre; Env_Types : in Environ) is
   begin
      Mettre_Au_Point (3, "entree de Verif_Program");
      
      Verif_Liste_Classe (Acces_Fille_1 (A),Env_Types);

   end Verif_Program;

   
   ------------------------
   -- Verifier_Decorer_2 --
   ------------------------

   procedure Verifier_Decorer_2 (A : in Arbre; Env_Types : in Environ) is
   begin
      Mettre_Au_Point (3, "entree de Verifier_Decorer_2");
           
      Verif_Program (A, Env_Types);

   end Verifier_Decorer_2;
   
end Verif_Passe2;
