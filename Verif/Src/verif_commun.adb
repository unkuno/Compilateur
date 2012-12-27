------------------------------------------------------------------------------
--  Spécification des procédures et fonctions communes aux trois passes de la
--  vérification contextuelle.
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     11/01/2012
--        - version initiale
------------------------------------------------------------------------------

with Ada.Text_IO, Types_Base, Defns;
use  Ada.Text_IO, Types_Base, Defns, Defns.Tables_Defn;

with Symboles, Decors, Erreurs;
use  Symboles, Decors, Erreurs;

package body Verif_Commun is

   Defensif : constant Boolean := True;

   procedure Mettre_Au_Point (Niveau : in Positive; S : in String) is
      -- plus Niveau_Max est eleve, plus il y a d'affichage
      Niveau_Max : constant := 0;
   begin
      if Niveau <= Niveau_Max then
         Put_Line ("Verif_Commun : " & S);
      end if;
   end Mettre_Au_Point;
   
   
   -------------
   -- Ajouter --
   -------------

   function Ajouter (Table1 : in Table_Defn;
                     Table2 : in Table_Defn) return Boolean
   is
      -- Erreur levée par les 3 procédures suivantes si les domaines de Env1 et
      -- de Env2 ne sont pas disjoints.
      Non_Disjoint : exception;

      -- Ajoute un couple à Table_Res, lève Non_Disjoint en cas d'erreur.
      procedure Ajouter_Couple (Nom : not null access St_Chaine;
                                Def : in Defn) is
         Present : Boolean;
         Def2    : Defn;
      begin
         Chercher_Inserer (Table1, Nom, Def, Present, Def2);
         if Present then raise Non_Disjoint; end if;
      end Ajouter_Couple;

      -- Ajoute une table à Table_Res, lève Non_Disjoint en cas d'erreur.
      procedure Ajouter_Table is new Parcourir (Ajouter_Couple);

   begin

      Mettre_Au_Point (3, "entree de Union_Disjointe");

      -- Ajout des deux environnements
      Ajouter_Table (Table2);

      Mettre_Au_Point (3, "sortie de Union_Disjointe");

      return False;
   exception
      when Non_Disjoint => return True;
   end Ajouter;


   -------------
   -- Compare --
   -------------
   
   function Compare (Sig1 : in Signature;
                     Sig2 : in Signature) return Boolean
   is
      Iter1 : constant Defns.Signatures.Iterateur :=
	Defns.Signatures.Creation (Sig1);
      Iter2 : constant Defns.Signatures.Iterateur :=
	Defns.Signatures.Creation (Sig2);
   begin
      if Defns.Signatures.Longueur (Sig1)
	/= Defns.Signatures.Longueur (Sig2) then
         return false;
      else
         while not Defns.Signatures.Fini (Iter1) loop
            if Acces_Nature(Defns.Signatures.Suivant (Iter1))
	      /= Acces_Nature(Defns.Signatures.Suivant (Iter2)) then
               return false;
            end if;
         end loop;

         return true;

      end if;
   end Compare;


   ---------------
   -- Sous_Type --
   ---------------

   function Sous_Type (Env  : in Environ;
                       Typ1 : in Exp_Type;
                       Typ2 : in Exp_Type) return Boolean
   is
      Extension : Chaine;
   begin
      Mettre_Au_Point (3, "entree de Sous_Type");

      -- Un type est un sous-type de lui-même
      if Typ1 = Typ2 then return True; end if;

      -- Le_Type_Null est un sous-type de tous les Type_Classe
      if Typ1 = Le_Type_Null then
         return Acces_Nature (Typ2) = Type_Classe;
      end if;

      -- Seuls Le_Type_Null et les Type_Classe peuvent être des sous-types
      if Acces_Nature (Typ1) /= Type_Classe then return False; end if;

      -- Ici, Typ1 est forcément un Type_Classe

      -- Seul un Type_Classe peut avoir des sous-types Type_Classe
      if Acces_Nature (Typ2) /= Type_Classe then return False; end if;

      -- Tous les Type_Classe sont des sous-type du Type_Classe Object
      if Acces_String (Acces_Nom (Typ2)) = "Object" then return True; end if;

      -- Récupération de l'extension de Typ1
      Extension := Acces_Extension (Acces_Defn (Env, Acces_Nom (Typ1)));

      -- Pour les possibilités restantes, il faut que Typ1 ait une extension
      if Extension = null then return False; end if;

      -- Une sous-classe est un sous-type
      if Acces_String (Extension) = Acces_String (Acces_Nom (Typ2)) then
         return True;
      end if;

      Mettre_Au_Point (3, "sortie de Sous_Type");

      -- Le sous-typage est transitif
      return Sous_Type (Env, Creation_Type_Classe (Extension), Typ2);
   end Sous_Type;


   -----------------------
   -- Affect_Compatible --
   -----------------------

   function Affect_Compatible (Env  : in Environ;
                               Typ1 : in Exp_Type;
                               Typ2 : in Exp_Type) return Boolean
   is
   begin
      Mettre_Au_Point (3, "entree de Affect_Compatible");

      Mettre_Au_Point (3, "sortie de Affect_Compatible");

      return (Typ1 = Le_Type_Float and then Typ2 = Le_Type_Int)
        or else Sous_Type (Env, Typ2, Typ1);
   end Affect_Compatible;


   ---------------------------
   -- Conversion_Compatible --
   ---------------------------

   function Conversion_Compatible (Env  : in Environ;
                                   Typ1 : in Exp_Type;
                                   Typ2 : in Exp_Type) return Boolean
   is
   begin
      Mettre_Au_Point (3, "entree de Conversion_Compatible");

      Mettre_Au_Point (3, "sortie de Conversion_Compatible");

      return Affect_Compatible (Env, Typ1, Typ2)
        or else Affect_Compatible (Env, Typ2, Typ1);
   end Conversion_Compatible;


   --------------------
   -- Type_Op_Unaire --
   --------------------

   function Type_Op_Unaire (Op  : in Op_Unaire;
                            Typ : in Exp_Type) return Exp_Type
   is
   begin
      Mettre_Au_Point (3, "entree de Type_Op_Unaire");

      Mettre_Au_Point (3, "sortie de Type_Op_Unaire");

      case Op is
         when Moins =>
            if Typ = Le_Type_Int or else Typ = Le_Type_Float then return Typ;
            else return null;
            end if;
         when Non =>
            if Typ = Le_Type_Boolean then return Typ;
            else return null;
            end if;
      end case;

   end Type_Op_Unaire;


   ---------------------
   -- Type_Op_Binaire --
   ---------------------

   -- Retourne le type du résultat de l'opération arithmétique Op appliquée à
   -- une valeur de type Typ, ou null si c'est impossible.
   function Type_Op_Arithmetique (Typ1 : in Exp_Type;
                                  Typ2 : in Exp_Type) return Exp_Type
   is
   begin
      Mettre_Au_Point (3, "entree de Type_Op_Arithmetique");

      Mettre_Au_Point (3, "sortie de Type_Op_Arithmetique");

      case Acces_Nature (Typ1) is
         when Type_Int =>
            case Acces_Nature (Typ2) is
               when Type_Int => return Le_Type_Int;
               when Type_Float => return Le_Type_Float;
               when others => return null;
            end case;
         when Type_Float =>
            case Acces_Nature (Typ2) is
               when Type_Int | Type_Float => return Le_Type_Float;
               when others => return null;
            end case;
         when others => return null;
      end case;

   end Type_Op_Arithmetique;


   function Type_Op_Binaire (Op   : in Op_Binaire;
                             Typ1 : in Exp_Type;
                             Typ2 : in Exp_Type) return Exp_Type
   is
   begin
      Mettre_Au_Point (3, "entree de Type_Op_Binaire");

      Mettre_Au_Point (3, "sortie de Type_Op_Binaire");

      case Op is
         when Plus | Moins | Mult | Div =>
            return Type_Op_Arithmetique (Typ1, Typ2);

         when Reste =>
            if Typ1 = Le_Type_Int and then Typ2 = Le_Type_Int then
               return Le_Type_Int;
            else
               return null;
            end if;

         when Egal_Egal | Diff =>
            if Type_Op_Arithmetique (Typ1, Typ2) /= null
              or else ((Acces_Nature (Typ1) = Type_Classe or else
                          Typ1 = Le_Type_Null) and then
                         (Acces_Nature (Typ2) = Type_Classe or else
                            Typ2 = Le_Type_Null))
              or else (Typ1 = Le_Type_Boolean and then
                         Typ2 = Le_Type_Boolean) then
               return Le_Type_Boolean;
            else
               return null;
            end if;

         when Inf | Inf_Egal | Sup | Sup_Egal =>
            if Type_Op_Arithmetique (Typ1, Typ2) = null and then
	      (Typ1 /= Le_Type_Boolean or else Typ2 /= Le_Type_Boolean) then
	       return null;
            else return Le_Type_Boolean;
            end if;

         when Et | Ou =>
            if Typ1 = Le_Type_Boolean and then Typ2 = Le_Type_Boolean then
               return Le_Type_Boolean;
            else
               return null;
            end if;

      end case;

   end Type_Op_Binaire;


   ------------------------
   -- Type_Op_Instanceof --
   ------------------------

   function Type_Op_Instanceof (Typ1 : in Exp_Type;
                                Typ2 : in Exp_Type) return Exp_Type
   is
   begin
      Mettre_Au_Point (3, "entree de Type_Op_Instanceof");

      Mettre_Au_Point (3, "sortie de Type_Op_Instanceof");

      if (Acces_Nature (Typ1) = Type_Classe or else Typ1 = Le_Type_Null)
        and then Acces_Nature (Typ2) = Type_Classe then
         return Le_Type_Boolean;
      else
         return null;
      end if;

   end Type_Op_Instanceof;


   ----------------
   -- Verif_Type --
   ----------------

   procedure Verif_Type (A         : in     Arbre;
                         Env_Types : in     Environ;
                         Typ       :    out Exp_Type;
                         Decor     : in     Boolean) is
      Def : Defn;
   begin
      Mettre_Au_Point (3, "entree de Verif_Type");
      Verif_Ident(A, Env_Types, Def, Decor);

      if Acces_Nature(Def) /= Defn_Type
        and then Acces_Nature(Def) /= Defn_Classe then
         Afficher_Erreur (Erreur_Interne, Acces_Num_Ligne (A), "0.1 / 0.2");
      end if;

      Typ := Acces_Type (Def);

   end Verif_Type;


   -----------------
   -- Verif_Ident --
   -----------------

   procedure Verif_Ident (A    : in     Arbre;
			  Env  : in     Environ;
			  Def  :    out Defn;
			  Decor: in     Boolean) is
      Nom : Chaine;
   begin
      Mettre_Au_Point (3, "entree de Verif_Ident");
      Nom := Acces_Nom(A);
      Def := Acces_Defn(Env,Nom);
      if Def = null then
         Afficher_Erreur (Ident_Non_Decl,
                          Acces_Num_Ligne (A),
                          Acces_String(Nom),
                          "0.3");
      end if;

      -- Decoration du noeud Ident (cas occurence d'utilisation)
      if Decor then
         Changer_Decor (A, Creation (Def,Acces_Type (Def)));
      end if;

   end Verif_Ident;

end Verif_Commun;
