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

with Exp_Types, Defns, Arbres, Types_Base;
use  Exp_Types, Defns, Arbres, Types_Base;

pragma Elaborate_All (Types_Base);

package Verif_Commun is
   -- Chaine globale pour la classe Object
   Nom_Object : Chaine := Creation ("Object");
   
   ---------------------
   -- Union disjointe --
   ---------------------
   
   -- Ajoute le contenu de Table2 à Table1 (union disjointe).
   -- En sortie Table1 contient le résultat et Table2 est inchangé.
   -- Retourne True ssi les domaines ne sont pas disjoints. Dans ce cas, le
   -- contenu de Table1 est indéfini.
   function Ajouter (Table1 : in Table_Defn;
		     Table2 : in Table_Defn) return Boolean;
   
   --------------------------------
   -- Comparaison des signatures --
   --------------------------------
   
   -- Teste si Sig1 est identique à Sig2
   -- Retourne true ssi Sig1 = Sig2
   function Compare (Sig1 : in Signature;
                     Sig2 : in Signature) return Boolean;
  
   --------------------------------------
   -- Tests de compatibilité des types --
   --------------------------------------
   
   -- Teste le sous-typage.
   -- Retourne true ssi Typ1 est un sous-type de Typ2.
   function Sous_Type (Env  : in Environ;
                       Typ1 : in Exp_Type;
                       Typ2 : in Exp_Type) return Boolean;
   
   -- Teste la compatibilité des types pour l'affectation.
   -- Retourne true ssi on peut affecter une valeur de type Typ2 à un objet de
   -- type Typ1.
   function Affect_Compatible (Env  : in Environ;
                               Typ1 : in Exp_Type;
                               Typ2 : in Exp_Type) return Boolean;
   
   -- Teste la compatibilité des types pour la conversion.
   -- Retourne true ssi une valeur de type Typ1 peut être convertie en une
   -- valeur de type Typ2.
   function Conversion_Compatible (Env  : in Environ;
                                   Typ1 : in Exp_Type;
                                   Typ2 : in Exp_Type) return Boolean;
   
   
   -------------------------------
   -- Signatures des opérateurs --
   -------------------------------
   
   -- Type représentant un opérateur du langage Deca.
   type Operateur is (Plus, Moins, Mult, Div, Reste, Egal_Egal, Diff,
                      Inf, Sup, Ing_Egal, Sup_Egal, Et, Ou, Non);
   
   -- Type représentant un opérateur unaire du langage Deca.
   type Op_Unaire is (Moins, Non);
   
   -- Type représentant un opérateur binaire du langage Deca.
   type Op_Binaire is (Plus, Moins, Mult, Div, Reste, Egal_Egal, Diff,
                       Inf, Sup, Inf_Egal, Sup_Egal, Et, Ou);
   
   -- Retourne le type du résultat de l'opération unaire Op appliquée à une
   -- valeur de type Typ, ou null si c'est impossible.
   function Type_Op_Unaire (Op  : in Op_Unaire;
                            Typ : in Exp_Type) return Exp_Type;
   
   -- Retourne le type du résultat de l'opération binaire Op appliquée à une
   -- valeur de type Typ, ou null si c'est impossible.
   function Type_Op_Binaire (Op   : in Op_Binaire;
                             Typ1 : in Exp_Type;
                             Typ2 : in Exp_Type) return Exp_Type;
   
   -- Retourne Le_Type_Boolean s'il est possible d'appliquer l'opération
   -- instanceof, ou null sinon.
   function Type_Op_Instanceof (Typ1 : in Exp_Type;
                                Typ2 : in Exp_Type) return Exp_Type;
   
   
   ------------------------------------------------------------------
   -- Règles communes aux 3 passes de la vérification contextuelle --
   ------------------------------------------------------------------
   
   procedure Verif_Type (A         :    in     Arbre;
			 Env_Types :    in     Environ;
			 Typ       :    out    Exp_Type;
			 Decor     :    in     Boolean);
   
   procedure Verif_Ident (A : in Arbre; Env : in Environ; Def : out Defn; Decor: in Boolean);
     
end Verif_Commun;
