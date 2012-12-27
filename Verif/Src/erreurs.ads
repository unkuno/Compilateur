-------------------------------------------------------------------------------
--  Spécification des erreurs pour la verification contextuelle
--
--  Auteur : Groupe 16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     09/01/2012
--        - version initiale
-------------------------------------------------------------------------------

package Erreurs is

   -----------------------------------------------------------------
   -- Types d'erreurs (selon le nombre de paramètres nécessaires) --
   -----------------------------------------------------------------

   type Erreur_0_Param is (Erreur_Interne,
                           Ident_Classe_Attendu,
                           Champ_Void,
                           Param_Void,
                           Var_Void,
                           Retour_Void,
                           Expr_Bool_Attendue,
                           Type_Base_Attendu,
                           This_Principal,
                           Objet_Attendu,
                           Non_Visible,
                           Ident_Place_Attendu,
                           Ident_Champ_Attendu,
                           Ident_Methode_Attendu,
                           Doublon_Param,
                           Nbr_Param);


   type Erreur_1_Param is (Ident_Non_Decl,       -- Ident
                           Ident_Deja_Decl,      -- Ident
                           Doublon_Ident_Classe, -- Classe
                           Doublon_Champ_Classe, -- Classe
                           Deja_Champ_Super,     -- Champ
                           Deja_Methode_Super,   -- Methode
                           Sig_Diff_Super);      -- Methode

   type Erreur_2_Param is (Sous_Type_Retour, -- Type, Super_Type
                           Types_Affect,     -- Type_Place, Type_Val
                           Types_Op_Unaire,  -- Type, Op
                           Types_Instanceof, -- Type_Gauche, Type_Droit
                           Types_Conv);      -- Type_Src, Type_Dst

   type Erreur_3_Param is (Types_Op_Binaire); -- Type_Gauche, Type_Droit, Op


   --------------------------------------------------------------
   -- Procédures d'affichage des erreurs (lèvent Erreur_Verif) --
   --------------------------------------------------------------

   procedure Afficher_Erreur (E         : in Erreur_0_Param;
                              Num_Ligne : in Natural;
                              Regle     : in String := "");

   procedure Afficher_Erreur (E         : in Erreur_1_Param;
                              Num_Ligne : in Natural;
                              Param_1   : in String;
                              Regle     : in String := "");

   procedure Afficher_Erreur (E         : in Erreur_2_Param;
                              Num_Ligne : in Natural;
                              Param_1   : in String;
                              Param_2   : in String;
                              Regle     : in String := "");

   procedure Afficher_Erreur (E         : in Erreur_3_Param;
                              Num_Ligne : in Natural;
                              Param_1   : in String;
                              Param_2   : in String;
                              Param_3   : in String;
                              Regle     : in String := "");

end Erreurs;
