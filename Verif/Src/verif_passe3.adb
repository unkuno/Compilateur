-------------------------------------------------------------------------------
--  Specification de la passe 3 de la verification contextuelle
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     09/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Ada.Text_IO, Arbres, Types_Base;
use  Ada.Text_IO, Arbres, Types_Base;

with Erreurs, Exp_Types, Defns, Decors, Symboles, types_base, verif_commun;
use  Erreurs, Exp_Types, Defns, Decors, Symboles, types_base, verif_commun, Arbres.Listes_Arbres;

package body Verif_Passe3 is

   Defensif : constant Boolean := True;

   procedure Mettre_Au_Point (Niveau : in Positive; S : in String) is
      -- plus Niveau_Max est eleve, plus il y a d'affichage
      Niveau_Max : constant := 0;
   begin
      if Niveau <= Niveau_Max then
         Put_Line ("Verif_passe3 : " & S);
      end if;
   end Mettre_Au_Point;
  
 
  -- Prototypes des procédures de vérification-- 
 
   procedure Verif_Expression (A :         in     Arbre;
                               Env_Types : in     Environ;
                               Env_Exp :   in     Environ;
                               Class :     in     Chaine;
                               Typ :          out Exp_Type);

   procedure Verif_Bloc (L :         in Liste_Arbres;
			   Env_Types : in Environ;
			   Env_Exp :   in Environ;
			   Class :     in Chaine;
			   Retour :    in Exp_Type);
   
   
   procedure Verif_Source (A :         in Arbre;
                           Env_Types : in Environ;
                           Env_Exp :   in Environ;
                           Class:      in Chaine;
                           Typ :       in Exp_Type;
                           Conv_Flottant: out Boolean);
                           
  
   
  --Procedure permettant de rajouter un noeud "Conversion flottant" lorsque les 
  --Type 1 et Types 2 sont différents   
   -------------------------------
   -- Verif_Conversion_Flottant --
   -------------------------------
   procedure Conversion_Flottant(A :     in   Arbre;
				 Typ1 :  in   Exp_Type;
				 Typ2 :  in   Exp_Type) 
   is 
   AFils: Arbre;
   begin				    
   if Acces_Nature(Typ1) = Type_Int and then Acces_Nature(Typ2) = Type_Float then
      AFils:= Creation_Conv_Flottant(Acces_Fils_1(A), Acces_Num_Ligne(Acces_Fils_1(A)));
      Changer_Decor (AFils, Creation (Le_Type_Float));
      Changer_Fils_1(A,AFils); 
   elsif Acces_Nature(Typ1) = Type_Float and then Acces_Nature(Typ2) = Type_Int then
      AFils:= Creation_Conv_Flottant(Acces_Fils_2(A), Acces_Num_Ligne(Acces_Fils_2(A)));
      Changer_Decor (AFils, Creation (Le_Type_Float));
      Changer_Fils_2(A,AFils);
   end if;   
   end Conversion_Flottant ;
   
   -----------------------
   -- Verif_Param_Eff --
   -----------------------

   procedure Verif_Param_Eff (A :         in     Arbre;
                              Env_Types:  in     Environ;
                              Env_Exp :   in     Environ;
                              Class:      in     Chaine;
                              Typ :       in     Exp_Type;
                              Conv_Flottant: out Boolean)
   is
   begin
      Mettre_Au_Point (3, "entree de Verif_Param_Eff");
          
      Verif_Source(A, Env_Types, Env_Exp, Class, Typ, Conv_Flottant);

   end Verif_Param_Eff;
  
   ---------------------------
   -- Verif_Liste_Param_Eff --
   ---------------------------

   procedure Verif_Liste_Param_Eff (L :         in Liste_Arbres;
                                    Env_Types : in Environ;
                                    Env_Exp :   in Environ;
                                    Class :     in Chaine;
                                    Sig:        in Signature;
                                    NumLigne:   in Integer)
   is
      Iter : constant Iterateur := Creation (L);
      IterS: constant Defns.Signatures.Iterateur:= Defns.Signatures.Creation (Sig); 
      Conv_Flottant: Boolean;
      Courant: Arbre;
      AFils : Arbre;
   begin
      Mettre_Au_Point (3, "entree de Verif_Liste_Param_Eff");

      if Longueur(L) /= Defns.Signatures.Longueur(Sig) then
	 Afficher_Erreur (Nbr_Param, NumLigne, "3.96");
      else	            
	 --On vérifie chaque paramètre--
	 while not Fini (Iter) loop
	    Courant := Suivant (Iter);
	    Verif_Param_Eff(Courant, 
			    Env_Types, 
			    Env_Exp, 
			    Class, 
			    Defns.Signatures.Suivant (IterS),
			    Conv_Flottant);
	    --Ajout d'un noeud conversion flottant si nécessaire--
	    if Conv_Flottant then
	       AFils:= Creation_Conv_Flottant(Courant, Acces_Num_Ligne(Courant));
	       Changer_Decor (AFils, Creation (Le_Type_Float));
	       Changer_Courant(Iter,AFils);
	    end if;	    			     
	 end loop;
      end if;
      
   end Verif_Liste_Param_Eff;

   -----------------------
   -- Verif_Methode_Ident --
   -----------------------

   procedure Verif_Methode_Ident (A :         in     Arbre;
                                  Env_Exp :   in     Environ;
                                  Sig:        out    Signature;
                                  Typ :       out    Exp_Type)
   is
   Def: Defn;
   begin
      Mettre_Au_Point (3, "entree de Verif_Methode_Ident");
          
      Verif_Ident(A, Env_Exp, Def,true);
      Typ := Acces_Type (Def);
      --On vérifie qu'il s'agit d'une methode de la classe --
      if Acces_Nature (Def) = Defn_Methode  then  
	 Sig := Acces_Signature(Def);
      else
	 Afficher_Erreur (Ident_Methode_Attendu, Acces_Num_Ligne(A), "3.94");	       
      end if;

   end Verif_Methode_Ident;

   -----------------------
   -- Verif_Appelant -----
   -----------------------

   procedure Verif_Appelant (A :         in     Arbre;
                             Env_Types:  in     Environ;   
                             Env_Exp :   in     Environ;
                             Class :     in     Chaine;
                             Sig:        out    Signature;
                             Typ :       out    Exp_Type)
   is
   Typ2 : Exp_Type;
   Class2 : Chaine;
   Def2 : Defn;
   Env_Exp2 : Environ;
   begin
      Mettre_Au_Point (3, "entree de Verif_Appelant");
      case Acces_Noeud_PLACE (A) is
         when Noeud_Ident => 
	    Verif_Methode_Ident(A, 
			        Env_Exp,
			        Sig, 
			        Typ);         
         when Noeud_Selection =>                        
            --On vérifie le noeud expression puis on récupère son type(classe)--
            Verif_Expression (Acces_Fils_1 (A),
                              Env_Types,
                              Env_Exp,
                              Class,
                              Typ2);
            
            if Acces_Nature(Typ2) /= Type_Classe then
	       Afficher_Erreur (Objet_Attendu, Acces_Num_Ligne(Acces_Fils_1 (A)), "3.93");	
	    else
	       Class2 := Acces_Nom(Typ2);
	       Def2 := Acces_Defn( Env_Types, Class2);
	       if Def2 = null then 
		  Afficher_Erreur (Erreur_Interne, Acces_Num_Ligne(Acces_Fils_1 (A)), "3.93");
	       else	  
		  Env_Exp2 := Acces_Environ(Def2);
		  --On vérifie l'existence de la méthode dans l'environnement de la classe--
		  Verif_Methode_Ident(Acces_Fils_2(A),
				    Env_Exp2,
				    Sig,
				    Typ);
	       end if;
	    end if;	       
      end case;      
   
   end Verif_Appelant;

   -----------------------
   -- Verif_Champ_Ident --
   -----------------------

   procedure Verif_Champ_Ident (A :         in     Arbre;
                                Env_Exp :   in     Environ;
                                Valeur:     out    Boolean;
                                Nom :       out    Chaine;
                                Typ :       out Exp_Type)
   is
      Def: Defn;
   begin
      Mettre_Au_Point (3, "entree de Verif_Champ_Ident");
          
      Verif_Ident(A, Env_Exp, Def,true);
      Typ := Acces_Type (Def);
      --On vérifie qu'il s'agit d'un champ de la classe --
      if Acces_Nature (Def) = Defn_Champ  then  
	 Valeur := Acces_Protege(Def);
	 Nom := Acces_Classe(Def);
      else 
	 Afficher_Erreur (Ident_Champ_Attendu, Acces_Num_Ligne(A), "3.91");	       
      end if;

   end Verif_Champ_Ident;
 
 
   -----------------------
   -- Verif_Place_Ident --
   -----------------------

   procedure Verif_Place_Ident (A :         in     Arbre;
                                Env_Exp :   in     Environ;
                                Typ :          out Exp_Type)
   is
      Def: Defn;
      Nature : Nature_Defn;
   begin
      Mettre_Au_Point (3, "entree de Verif_Place_Ident");
          
      Verif_Ident(A, Env_Exp, Def,true);
      Nature := Acces_Nature (Def);
      Typ := Acces_Type (Def);
	 
      if Nature /= Defn_Champ and then Nature /= Defn_Param and then Nature /= Defn_Var  then  
	 Afficher_Erreur (Ident_Place_Attendu, Acces_Num_Ligne(A), "3.88 / 3.89 / 3.90");
      end if;
   
   end Verif_Place_Ident;
 
  
   ----------------------
   -- Verif_Place ------
   ----------------------

   procedure Verif_Place (A :         in     Arbre;
                          Env_Types : in     Environ;
                          Env_Exp :   in     Environ;
                          Class :     in     Chaine;
                          Typ :          out Exp_Type)
   is
      Typ2: Exp_Type;
      Env_Exp2: Environ;
      Def2: Defn;
      Valeur: Boolean;
      Nom: Chaine;
      TypClass, TypNom: Exp_Type;
   begin
      Mettre_Au_Point (3, "entree de Verif_Place");
      
      case Acces_Noeud_PLACE (A) is
         when Noeud_Ident => 
	    Verif_Place_Ident(A, 
			      Env_Exp, 
			      Typ);
         when Noeud_Selection =>                        
            --On vérifie l'expression puis on récupere son type(classe)--
            Verif_Expression (Acces_Fils_1 (A),
                              Env_Types,
                              Env_Exp,
                              Class,
                              Typ2);
            
            if Acces_Nature(Typ2) /= Type_Classe then
	       Afficher_Erreur( Objet_Attendu, Acces_Num_Ligne(A), "3.86 / 3.87");
	    end if;     
	    
	    Def2 := Acces_Defn (Env_Types, Acces_Nom (Typ2));
	    
	    if Def2 = Null then 
	       Afficher_Erreur( Erreur_Interne, Acces_Num_Ligne(A), "3.86 / 3.87");
	    else
	       Env_Exp2 := Acces_Environ(Def2);
	    end if;
	    --On vérifie l'existence du champ dans l'environnement de la classe--
            Verif_Champ_Ident(Acces_Fils_2 (A),
			      Env_Exp2,
			      Valeur,
			      Nom,
			      Typ);

	    --Condition dans le cas d'un champ protégé--
	    if Valeur = true then
	       if Class = null then
		  Afficher_Erreur( Non_Visible, Acces_Num_Ligne(A), "3.87");
	       else
		  TypClass := Acces_Type (Acces_Defn(Env_Types, Class));
		  TypNom := Acces_Type (Acces_Defn(Env_Types, Nom));		  
		  if not(Sous_Type(Env_Types, Typ2, TypClass)) or  
		     not(Sous_Type(Env_Types, TypClass, TypNom)) then
		     Afficher_Erreur( Non_Visible, Acces_Num_Ligne(A), "3.87"); --Acces a une variable protegée--
		  end if;
	       end if;
	    end if;
	   
	    --Decoration du noeud place --	    
	    Changer_Decor (A, Creation (Typ));	  	       
      end case;
   end Verif_Place;

      
   -----------------------------
   -- Verif_Operation_Binaire --
   -----------------------------

   procedure Verif_Operation_Binaire (A :         in     Arbre;
				      Env_Types : in     Environ;
				      Env_Exp :   in     Environ;
				      Class :     in     Chaine;
				      Typ :       out    Exp_Type;
				      Op_Bin   :  in     Op_Binaire;
				      Op   :      in     String;
				      Regle:      in     String)   
   is
      Typ1:Exp_Type;
      Typ2:Exp_Type;
   begin
      Mettre_Au_Point (3, "entree de Verif_Operation_Binaire");
          
      --On vérifie la compatibilité des types des opérandes
      --avec l'opération--
      Verif_Expression(Acces_Fils_1(A), Env_Types, Env_Exp, Class, Typ1);
      Verif_Expression(Acces_Fils_2(A), Env_Types, Env_Exp, Class, Typ2);
      Typ := Type_Op_Binaire(Op_Bin, Typ1, Typ2);
      if Typ = null  then 			      
	 Afficher_Erreur( Types_Op_Binaire, Acces_Num_Ligne(A), Exp_Type_Image(Typ1), 
	 Exp_Type_Image(Typ2),Op, Regle);
      else
	 Conversion_Flottant(A,Typ1,Typ2);			   
      end if;
         
   end Verif_Operation_Binaire;
   
   ----------------------
   -- Verif_Expression --
   ----------------------

   procedure Verif_Expression (A :         in     Arbre;
                               Env_Types : in     Environ;
                               Env_Exp :   in     Environ;
                               Class :     in     Chaine;
                               Typ :          out Exp_Type)
   is
      Typ1:Exp_Type;
      Typ2:Exp_Type;
      Def: Defn:= null;
      Conv_Flottant: Boolean;
      AFils: Arbre;
      Sig: Signature;
      Decor: Boolean := true;
   begin
      Mettre_Au_Point (3, "entree de Verif_Expression");
      
      --On vérifie la nature du noeud expression-
      --puis suivant sa nature, on vérifie ses composantes--
      case Acces_Noeud_EXP (A) is     
         when Noeud_Affect => 
			   Verif_Place(Acces_Fils_1(A), Env_Types, Env_Exp, Class, Typ);
			   Verif_Source(Acces_Fils_2(A), Env_Types, Env_Exp, Class, Typ, Conv_Flottant);
			   --Ajout d'un noeud conversion flottant si necessaire--
			   if Conv_Flottant then
			      AFils:= Creation_Conv_Flottant(Acces_Fils_2(A), Acces_Num_Ligne(Acces_Fils_2(A)));
			      Changer_Decor (AFils, Creation (Le_Type_Float));
			      Changer_Fils_2(A,AFils);
			   end if;   
         when Noeud_Appel => 
			   Verif_Appelant(Acces_Fils_1(A), Env_Types, Env_Exp, Class, Sig, Typ);
			   Verif_Liste_Param_Eff(Acces_Fille_2(A), Env_Types, Env_Exp, Class, Sig,
			      Acces_Num_Ligne(A));
         when Noeud_Chaine => Typ := Le_Type_String; 
         when Noeud_Conv_Flottant => 
			   Afficher_Erreur (Erreur_Interne, Acces_Num_Ligne(A), "3.65");
         when Noeud_Conversion => 
			   Verif_Type(Acces_Fils_1(A), Env_Types, Typ1, true);
			   Verif_Expression(Acces_Fils_2(A), Env_Types, Env_Exp, Class, Typ2);
			   --Verification de la compatibilité des types pour la conversion--
			   if Conversion_Compatible(Env_Types, Typ2, Typ1) = false  then 			      
			      Afficher_Erreur( Types_Conv, Acces_Num_Ligne(A),Exp_Type_Image(Typ2),Exp_Type_Image(Typ1), "3.59");
			   else
			      Typ := Typ1;
			   end if;			   
         when Noeud_Creation => 
			   Verif_Ident (Acces_Fils_1(A), Env_Types, Def, true);			   
			   if Acces_Nature (Def) = Defn_Classe then
			       Typ := Acces_Type (Def);
			   else   
			      Afficher_Erreur ( Ident_Classe_Attendu, Acces_Num_Ligne(A), "3.57");
			   end if; 
         when Noeud_Diff =>
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Diff, "!=", "3.76");
         when Noeud_Div => 
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Div, "/", "3.73");
         when Noeud_Egal_Egal => 
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Egal_Egal, "==", "3.75");
         when Noeud_Entier => 
			   Typ := Le_Type_Int;
         when Noeud_Et => 
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Et, "&&", "3.81");
         when Noeud_Faux => Typ := Le_Type_Boolean;
         when Noeud_Flottant => Typ := Le_Type_Float;
         when Noeud_Ident => Verif_Place_Ident(A, Env_Exp, Typ);
			     Decor := false;
         when Noeud_Inf => 
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Inf, "<", "3.77");        
         when Noeud_Inf_Egal =>
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Inf_Egal, "<=", "3.79");
         when Noeud_Instanceof => 
			   Verif_Expression(Acces_Fils_1(A), Env_Types, Env_Exp, Class, Typ1);
			   Verif_Type(Acces_Fils_2(A), Env_Types, Typ2,true);
			   --Verification de la compatibilité des types pour le instanceof--
			   Typ := Type_Op_Instanceof(Typ1,Typ2);
			   if Typ = null then
			   	Afficher_Erreur( Types_Instanceof, 
			   			Acces_Num_Ligne(A),
			   			Exp_Type_Image(Typ1),
			   			Exp_Type_Image(Typ2),
			   	 		"3.58");
			   end if;
         when Noeud_Lecture_Entier => Typ := Le_Type_Int;
         when Noeud_Lecture_Flottant => Typ := Le_Type_Float;
         when Noeud_Moins => 
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Moins, "-", "3.71");
         when Noeud_Moins_Unaire =>
			   Verif_Expression(Acces_Fils_1(A), Env_Types, Env_Exp, Class, Typ1);
			   Typ := Type_Op_Unaire(Moins, Typ1);
			   if Typ = null then 			      
			      Afficher_Erreur( Types_Op_Unaire, Acces_Num_Ligne(A), Exp_Type_Image(Typ1), "-", "3.83");
			   end if;
         when Noeud_Mult => 
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Mult, "*", "3.72");
         when Noeud_Non =>
			   Verif_Expression(Acces_Fils_1(A), Env_Types, Env_Exp, Class, Typ1);
			   Typ := Type_Op_Unaire(Non, Typ1);
			   if Typ = null  then 			      
			      Afficher_Erreur( Types_Op_Unaire, Acces_Num_Ligne(A), Exp_Type_Image(Typ1),"!", "3.84");
			   end if;
         when Noeud_Null => Typ := Le_Type_Null;
         when Noeud_Ou => 
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Ou, "||", "3.82");
         when Noeud_Plus => 
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Plus, "+", "3.70");
         when Noeud_Reste =>
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Reste, "%", "3.74");
         when Noeud_Selection => 
			   Verif_Place(A, Env_Types, Env_Exp, Class, Typ);
			   --Le decor sera attribué dans Verif_Place--
			   Decor := false;
         when Noeud_Sup =>
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Sup, ">", "3.78");
         when Noeud_Sup_Egal =>
			   Verif_Operation_Binaire(A, Env_Types, Env_Exp, Class, Typ, Sup_Egal, ">=", "3.80");
         when Noeud_This => 
			   if Class /= null then
			      Typ :=  Acces_Type (Acces_Defn(Env_Types, Class));
			   else
			      Afficher_Erreur( This_Principal, Acces_Num_Ligne(A), "3.54");   
			   end if;
         when Noeud_Vrai => Typ := Le_Type_Boolean;
      end case;
      
      --Ajout du décor--    
      if Decor then
	 Changer_Decor (A, Creation (Typ)); 
      end if;
      
   end Verif_Expression;
   
   
   ---------------------
   -- Verif_Exp_Print --
   ---------------------

   procedure Verif_Exp_Print (A :         in Arbre;
                              Env_Types : in Environ;
                              Env_Exp :   in Environ;
                              Class :     in Chaine)
   is
      Typ : Exp_Type;
   begin
      Mettre_Au_Point (3, "entree de Verif_Exp_Print");
      
      Verif_Expression(A, Env_Types, Env_Exp, Class, Typ);
      
      --Verification du type de l'expression contenue dans le print--
      if (Typ /= Le_Type_Int) and then (Typ /= Le_Type_Float)
        and then (Typ /= Le_Type_String) then
         Afficher_Erreur (Type_Base_Attendu, Acces_Num_Ligne(A), "3.50");
      end if;
      
   end Verif_Exp_Print;

   
   ---------------------------
   -- Verif_Liste_Exp_Print --
   ---------------------------

   procedure Verif_Liste_Exp_Print (L :         in Liste_Arbres;
                                    Env_Types : in Environ;
                                    Env_Exp :   in Environ;
                                    Class :     in Chaine)
   is
      Iter : constant Iterateur := Creation (L);
   begin
      Mettre_Au_Point (3, "entree de Verif_Liste_Exp_Print");
      
      while not Fini (Iter) loop
         Verif_Exp_Print (Suivant (Iter), Env_Types, Env_Exp, Class);
      end loop;
      
   end Verif_Liste_Exp_Print;

   ---------------------------
   -- Verif_Condition --------
   ---------------------------

   procedure Verif_Condition (A :         in Arbre;
                             Env_Types : in Environ;
                             Env_Exp :   in Environ;
                             Class:      in Chaine)
   is
   Typ : Exp_Type;
   begin
      Mettre_Au_Point (3, "entree de Verif_Condition");
      
      Verif_Expression (A, Env_Types, Env_Exp, Class, Typ);
	 --L'expression doit être de type boolean--
	 if Acces_Nature (Typ) /= Type_Boolean then 
	    Afficher_Erreur( Expr_Bool_Attendue, Acces_Num_Ligne(A), "3.45");
	 end if;      
   end Verif_Condition;

   
   
   --Verification du noeud "Source"--
   --Le Boolean Conv_Flottant indique si il est nécessaire de rajouter un noeud Conversion Flottant   
   ---------------------------
   -- Verif_Source ----------
   ---------------------------

   procedure Verif_Source (A :         in Arbre;
                           Env_Types : in Environ;
                           Env_Exp :   in Environ;
                           Class:      in Chaine;
                           Typ :       in Exp_Type;
                           Conv_Flottant: out Boolean)
   is
   Typ2 : Exp_Type;
   begin
      Mettre_Au_Point (3, "entree de Verif_Source");
      
      Verif_Expression (A, Env_Types, Env_Exp, Class, Typ2);
      
	 --Verification de la compatibilité des types pour l'affectation--
	 if Affect_Compatible (Env_Types, Typ, Typ2) = false then 
	    Afficher_Erreur( Types_Affect, Acces_Num_Ligne(A), Exp_Type_Image(Typ),
	    Exp_Type_Image(Typ2), "3.44");
	 end if;      
	 
	 --Ajout d'un noeud conversion flottant si nécessaire--
	 if Acces_Nature(Typ)=Type_Float and then Acces_Nature(Typ2)=Type_Int then
	    Conv_Flottant := true;
	 else
	    Conv_Flottant := false;
	 end if;
	       
   end Verif_Source;
   

   ---------------------------
   -- Verif_Suite_Cond -------
   ---------------------------

   procedure Verif_Suite_Cond (L :         in Liste_Arbres;
                               Env_Types : in Environ;
                               Env_Exp :   in Environ;
                               Class :     in Chaine;
                               Retour :    in Exp_Type)
   is
      Iter : constant Iterateur := Creation (L);
      A : Arbre;
   begin
      Mettre_Au_Point (3, "entree de Verif_Suite_Cond");
      
      while not Fini (Iter) loop
         A := Suivant (Iter);
         Verif_Condition (Acces_Fils_1(A), Env_Types, Env_Exp, Class);
         Verif_Bloc (Acces_Fille_2(A), Env_Types, Env_Exp, Class, Retour);
      end loop;
      
   end Verif_Suite_Cond;


   ----------------
   -- Verif_Inst --
   ----------------

   procedure Verif_Inst (A :         in Arbre;
                         Env_Types : in Environ;
                         Env_Exp :   in Environ;
                         Class :     in Chaine;
                         Retour :    in Exp_Type)
   is
      Typ : Exp_Type;
      Conv_flottant : Boolean;
      AFils : Arbre;
   begin
      Mettre_Au_Point (3, "entree de Verif_Inst");
      
      --On vérifie la nature du noeud--
      case Acces_Noeud_INST (A) is     
         when Noeud_Retour => 
	       Verif_Source( Acces_Fils_1(A), Env_Types, Env_Exp, Class, Retour, Conv_Flottant);
	       if Acces_Nature(Retour) = Type_Void then
		  Afficher_Erreur( Retour_Void, Acces_Num_Ligne(A), "3.34");
	       end if;	       
	       --Ajout d'un noeud conversion flottant si nécessaire--
	       if Conv_Flottant then
		  AFils:= Creation_Conv_Flottant(Acces_Fils_1(A), Acces_Num_Ligne(Acces_Fils_1(A)));
		  Changer_Decor (AFils, Creation (Le_Type_Float));
		  Changer_Fils_1(A,AFils);
	       end if;	       		  	       
	       Changer_Decor (A, Creation (Retour));
         when Noeud_Si => 
	       Verif_Suite_Cond( Acces_Fille_1(A), Env_Types, Env_Exp, Class, Retour);
	       Verif_Bloc( Acces_Fille_2(A), Env_Types, Env_Exp, Class, Retour);	       
         when Noeud_Tantque =>
	       Verif_Condition( Acces_Fils_1(A), Env_Types, Env_Exp, Class);
	       Verif_Bloc( Acces_Fille_2(A), Env_Types, Env_Exp, Class, Retour);
         when Noeud_Ecriture | Noeud_Ecriture_Ligne => 
	       Verif_Liste_Exp_Print (Acces_Fille_1 (A),
                                      Env_Types,
                                      Env_Exp,
                                      Class);
         When Noeud_Nop => null;
         when others => Verif_Expression (A, Env_Types, Env_Exp, Class, Typ);
      end case;  
      
   end Verif_Inst;
   

   ----------------
   -- Verif_Bloc --
   ----------------

   procedure Verif_Bloc (L :         in Liste_Arbres;
                         Env_Types : in Environ;
                         Env_Exp :   in Environ;
                         Class :     in Chaine;
                         Retour :    in Exp_Type)
   is
      Iter : constant Iterateur := Creation (L);
   begin
      Mettre_Au_Point (3, "entree de Verif_Bloc");
      
      while not Fini (Iter) loop
         Verif_Inst(Suivant (Iter), Env_Types, Env_Exp, Class, Retour);
      end loop;
      
   end Verif_Bloc;  
   
   
   --Verification du noeud "initialisation"--
   --Le Boolean Conv_Flottant indique si il est nécessaire de rajouter un noeud Conversion Flottant
   ---------------------------
   -- Verif_Initialisation --
   --------------------------

   procedure Verif_Initialisation (A :            in Arbre;
                                   Env_Types :    in Environ;
                                   Env_Exp :      in Environ;
                                   Class :        in Chaine;
                                   Typ:           in Exp_Type;
                                   Conv_Flottant: out boolean)
   is
      N : Noeud_Arbre_INITIALISATION;
   begin
      Mettre_Au_Point (3, "entree de Verif_Initialisation");
      
      Conv_Flottant := false;
      N := Acces_Noeud_INITIALISATION (A);
            
      if N /= Noeud_Vide then
	 Verif_Source( A, Env_Types, Env_Exp, Class, Typ, Conv_Flottant);
      end if;
      
   end Verif_Initialisation;


   -------------------------
   -- Verif_Decl_Var -------
   -------------------------

   procedure Verif_Decl_Var (A :           in     Arbre;
                             Env_Types :   in     Environ;
                             Env_Exp_Sup : in     Environ;
                             Env_Exp :     in     Environ;
                             Class :       in     Chaine;
                             Typ:          in     Exp_Type)
   is  
      Nom: Chaine;
      Present: Boolean;
      Def: Defn;
      AFils: Arbre;
      Conv_Flottant: Boolean;
   begin
      Mettre_Au_Point (3, "entree de Verif_Decl_Var");
      Nom := Acces_Nom (Acces_Fils_1(A));           
      
      if defensif and then Acces_Reste(Env_Exp) /= null then
	 raise Program_Error;
      end if;
      
      Changer_Reste(Env_Exp, Env_Exp_Sup);
      
      Verif_Initialisation (Acces_Fils_2(A), Env_Types, Env_Exp, Class, Typ, Conv_Flottant);
      
      Changer_Reste(Env_Exp, null);
                  
      --Creation de la définition de la variable--
      Def := Creation_Var (Typ); 
      Ajouter (Env_Exp, Nom, Def,Present);
      if Present = true then 
	 Afficher_Erreur( Ident_Deja_Decl, Acces_Num_Ligne(Acces_fils_1(A)), Acces_String( Nom), "3.30");
      end if;
     
      --Decoration du la variable--
      Changer_Decor(Acces_Fils_1(A),Creation(Def));

      --Creation du noeud conv flottant si necessaire--
      if Conv_Flottant then 
	 AFils:= Creation_Conv_Flottant(Acces_Fils_2(A), Acces_Num_Ligne(Acces_Fils_2(A)));
	 Changer_Decor (AFils, Creation (Le_Type_Float));
	 Changer_Fils_2(A,AFils);
      end if;
      
   end Verif_Decl_Var;
      
   ------------------------------
   -- Verif_Liste_Decl_Var -----
   ------------------------------

   procedure Verif_Liste_Decl_Var (L :           in     Liste_Arbres;
                                   Env_Types :   in     Environ;
                                   Env_Exp_Sup : in     Environ;
                                   Env_Exp :     in     Environ;
                                   Class :       in     Chaine;
                                   Typ   :       in Exp_Type)
   is
      Iter : constant Iterateur := Creation (L);
   begin
      Mettre_Au_Point (3, "entree de Verif_Liste_Decl_Var");
      
      while not Fini (Iter) loop
         Verif_Decl_Var(Suivant (Iter),
                             Env_Types,
                             Env_Exp_Sup,
                             Env_Exp,
                             Class,
                             Typ);
      end loop;
      
   end Verif_Liste_Decl_Var; 
  
   -------------------------
   -- Verif_Decl_Variable --
   -------------------------

   procedure Verif_Decl_Variable (A :           in     Arbre;
                                  Env_Types :   in     Environ;
                                  Env_Exp_Sup : in     Environ;
                                  Env_Exp :     in     Environ;
                                  Class :       in     Chaine)
                                  
   is
      Typ : Exp_Type;   
   begin
      Mettre_Au_Point (3, "entree de Verif_Decl_Variable");
      
      Verif_Type (Acces_Fils_1 (A), Env_Types, Typ, true);
      
      if Acces_Nature (Typ) = Type_Void then
         Afficher_Erreur (Var_Void, Acces_Num_Ligne(A), "3.27");
      end if;       
      
      Verif_Liste_Decl_Var (Acces_Fille_2 (A),
                            Env_Types,
                            Env_Exp_Sup,
                            Env_Exp,
                            Class,
			    Typ);      
      
   end Verif_Decl_Variable;  
      

   ------------------------------
   -- Verif_Liste_Declarations --
   ------------------------------

   procedure Verif_Liste_Declarations (L :           in     Liste_Arbres;
                                       Env_Types :   in     Environ;
                                       Env_Exp_Sup : in     Environ;
                                       Env_Exp :     in     Environ;
                                       Class :       in     Chaine)
   is
      Iter : constant Iterateur := Creation (L);
   begin
      Mettre_Au_Point (3, "entree de Verif_Liste_Declarations");
      
      while not Fini (Iter) loop
         Verif_Decl_Variable(Suivant (Iter),
                             Env_Types,
                             Env_Exp_Sup,
                             Env_Exp,
                             Class);
      end loop;
      
   end Verif_Liste_Declarations;
   

   ---------------------
   -- Verif_Principal --
   ---------------------

   procedure Verif_Principal (A : in Arbre; Env_Types : in Environ) is
      Env_Exp : Environ := Creation(Creation,null);
   begin
      Mettre_Au_Point (3, "entree de Verif_Principal");
         
      case Acces_Noeud_PRINCIPAL (A) is
         when Noeud_Vide => null;
         when Noeud_Principal =>
            Verif_Liste_Declarations (Acces_Fille_1 (A),
                                      Env_Types,
                                      null,
                                      Env_Exp,
                                      null);
            Verif_Bloc(Acces_Fille_2 (A),
                       Env_Types,
                       Env_Exp,
                       null,
                       Le_Type_Void); 
      end case;
      
   end Verif_Principal;

   -----------------------
   -- Verif_Parametre --
   -----------------------

   procedure Verif_Parametre   (A         : in  Arbre; 
				Env_Types : in  Environ; 
				Nom       : out Chaine; 
				Def       : out Defn)
				is
   Typ : Exp_Type;
   begin
      Mettre_Au_Point (3, "entree de Verif_Parametre");
      
      --Le décor à déja été attribué, on envoie donc le boolean false--
      Verif_Type(Acces_Fils_1(A), Env_Types, Typ, false);
      Nom := Acces_Nom(Acces_Fils_2(A));    
      Def := Creation_Param(Typ);
      
      --Ajout de la decoration sur les paramètres de la méthode--
      Changer_Decor (Acces_Fils_2(A),Creation(Def));	
   end Verif_Parametre;

   -----------------------------
   -- Verif_Liste_Param_Form-----
   ------------------------------
 
   procedure Verif_Liste_Param_Form (L   :       in  Liste_Arbres; 
				     Env_Types : in  Environ;
				     Env_Exp :   out Environ) 
				      is
      Iter : constant Iterateur := Creation (L);   
      Table : Table_Defn:= Creation;
      Nom : Chaine;
      Def: Defn;
      Present: Boolean;
      Courant: Arbre;
   begin
      Mettre_Au_Point (3, "entree de Verif_Liste_Param_Form");
          
      --Env_Exp est un environ crée à partir de la table-
      Env_Exp := Creation (Table, null);
      
      while not Fini (Iter) loop
	 Courant := Suivant (Iter);
	 Verif_Parametre(Courant, Env_Types, Nom, Def);
	 --On ajoute les définitions dans Env_Exp--
	 Ajouter (Env_Exp, Nom, Def, Present);
	 if Present = true then
	    Afficher_Erreur (Doublon_Param, Acces_Num_Ligne(Courant), "3.23");
	 end if;   
      end loop;
             
   end Verif_Liste_Param_Form;
   
   ----------------------
   -- Verif_Methode --
   ----------------------

   procedure Verif_Methode  (A :          in Arbre; 
			     Env_Types :  in Environ; 
			     Env_Exp :    in Environ; 
			     Classe:      in Chaine) 
			     is

      Retour : Exp_Type;
      Env_Exp_Local : Environ;
   begin
      Mettre_Au_Point (3, "entree de Verif_Methode ");
       --Le décor à déja été attribué, on envoie donc le boolean false--     
      Verif_Type(Acces_Fils_1(A), Env_Types, Retour, false);

      Verif_Liste_Param_Form(Acces_Fille_3(A), Env_Types, Env_Exp_Local);
      
      Verif_Liste_Declarations(Acces_Fille_4(A), Env_Types, Env_Exp, Env_Exp_Local, Classe);
      
      --Empilement( Env_Exp_Local, Env_Exp);
      Changer_Reste(Env_Exp_Local, Env_Exp);
      
      Verif_Bloc(Acces_Fille_5(A), Env_Types, Env_Exp_Local, Classe, Retour);   
   
   end Verif_Methode ;
   
   ---------------------
   -- Verif_Decl_Champ --
   ---------------------

   procedure Verif_Decl_Champ  (A :          in Arbre; 
			        Env_Types :  in Environ; 
				Env_Exp :    in Environ;
				Classe :     in Chaine; 
				Typ :        in Exp_Type)
			        is
   Conv_Flottant: Boolean;
   AFils: Arbre;
   begin
      Mettre_Au_Point (3, "entree de Verif_Decl_Champ ");
      
      Verif_Initialisation(Acces_Fils_2(A),Env_Types, Env_Exp, Classe, Typ, Conv_Flottant);
      
      if Conv_Flottant then 
	 AFils:= Creation_Conv_Flottant(Acces_Fils_2(A), Acces_Num_Ligne(Acces_Fils_2(A)));
	 Changer_Decor (AFils, Creation (Le_Type_Float));
	 Changer_Fils_2(A,AFils);
      end if;  
   
   end Verif_Decl_Champ ;
   
   -----------------------------
   -- Verif_Liste_Decl_Champ --
   ------------------------------
 
    procedure Verif_Liste_Decl_Champ (L :          in Liste_Arbres; 
				      Env_Types :  in Environ; 
				      Env_Exp :    in Environ;  
				      Classe :     in Chaine;
				      Typ :        in Exp_Type) 
				      is
      Iter : constant Iterateur := Creation (L);   
   begin
      Mettre_Au_Point (3, "entree de Verif_Liste_Decl_Champ");
            
      while not Fini (Iter) loop
	 Verif_Decl_Champ(Suivant (Iter), Env_Types, Env_Exp, Classe, Typ);                                      
      end loop;
             
   end Verif_Liste_Decl_Champ;

   -----------------
   -- Verif_Champ --
   -----------------

   procedure Verif_Champ (A :         in Arbre; 
			  Env_Types : in Environ; 
			  Env_Exp :   in Environ; 
			  Classe :    in Chaine) 
			  is
   Typ : Exp_Type;
   begin
      Mettre_Au_Point (3, "entree de Verif_Champ");
      
      Verif_Type(Acces_Fils_2(A) , Env_Types, Typ, false);      
      Verif_Liste_Decl_Champ(Acces_Fille_3(A), Env_Types, Env_Exp, Classe, Typ);
      
   end Verif_Champ;

   -----------------------
   -- Verif_Constituant --
   -----------------------

   procedure Verif_Constituant (A :           in Arbre; 
				Env_Types :   in Environ; 
                                Env_Exp :     in Environ;
                                Classe :      in Chaine)
				is
   begin
      Mettre_Au_Point (3, "entree de Verif_Constituant");   
      case Acces_Noeud_CONSTITUANT (A) is 
	 when Noeud_Champ =>
	    Verif_Champ(A, Env_Types, Env_Exp, Classe);
	 when Noeud_Methode =>
	    Verif_Methode(A, Env_Types, Env_Exp, Classe);
      end case;
   
   end Verif_Constituant;  

   ------------------------------
   -- Verif_Liste_Constituants --
   ------------------------------

   procedure Verif_Liste_Constituants (L :           in     Liste_Arbres;
                                       Env_Types :   in     Environ;
                                       Env_Exp :     in     Environ;
                                       Classe :      in     Chaine)
   is
      Iter : constant Iterateur := Creation (L);
   begin
      Mettre_Au_Point (3, "entree de Verif_Liste_Constituants");
      
      while not Fini (Iter) loop
         Verif_Constituant (Suivant (Iter),
                            Env_Types,
                            Env_Exp,
                            Classe);
      end loop;
      
   end Verif_Liste_Constituants;

   -------------------
   -- Verif_Classe --
   -------------------

   procedure Verif_Classe (A : in Arbre; Env_Types : in Environ) is      
      Nom : Chaine;
      DefNom : Defn;
      Env_Exp: Environ;    	
   begin
      Mettre_Au_Point (3, "entree de Verif_Classe");
      
      Nom := Acces_Nom(Acces_Fils_1(A));     
      DefNom := Acces_Defn(Env_Types,Nom);
      if DefNom = null then 
	Afficher_Erreur(Erreur_Interne, Acces_Num_Ligne(A), "3.6");
      elsif Acces_Nature(DefNom) /= Defn_Classe then
	Afficher_Erreur(Erreur_Interne, Acces_Num_Ligne(A), "3.6");
      else	 	 
	 --On recupere l'environnement de la classe et on 
	 --verifie ses constituants --
	 Env_Exp := Acces_Environ(DefNom);     
	 Verif_Liste_Constituants(Acces_Fille_3(A), 
	 			  Env_Types, 
	 			  Env_Exp,
	 			  Nom);
      end if;      
   
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
      
      Verif_Principal (Acces_Fils_2 (A),Env_Types); 
      Verif_Liste_Classe (Acces_Fille_1 (A),Env_Types);
      
   end Verif_Program;

   
   ------------------------
   -- Verifier_Decorer_3 --
   ------------------------

   procedure Verifier_Decorer_3 (A : in Arbre; Env_Types : in Environ) is
   begin
      Mettre_Au_Point (3, "entree de Verifier_Decorer_3");
      
      Verif_Program (A,Env_Types);
      
   end Verifier_Decorer_3;
   
end Verif_Passe3;
