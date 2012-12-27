--------------------------------------------------------------------------------
--  Corps du paquetage de génération de code responsable d'imprimer des
--  données à l'écran (passe 2)
--
--  Auteur : GL16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     10/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Types_Base, Pseudo_Code, Exp_Types, Defns, Decors, Arbres;
use  Types_Base, Pseudo_Code, Exp_Types, Defns, Decors, Arbres;

with Gencode_Commun, Gencode_Expressions;
use  Gencode_Commun, Gencode_Expressions;

with Outils_Instructions, Gestion_Registres;
use  Outils_Instructions, Gestion_Registres;

use  Arbres.Listes_Arbres;

-- Le procédures de ce groupe utilisent le paquetage Gencode_Expressions pour
-- évaluer leurs opérandes. Ensuite, elles impriment le résultat et libèrent
-- les ressources utilisées pour le calcul.
package body Gencode_Impression is
   Erreur_Interne : exception;
   
   -----------------------
   -- Ecriture_Flottant --
   -----------------------
   
   procedure Ecriture_Flottant (A : in Arbre) is
      Valeur : Flottant := Acces_Val_Flottant (A);
   begin
      Mettre_Au_Point (3, "entree de Ecriture_Flottant");

      -- LOAD #VALEUR, R1
      Insere_Ligne (Creation
		      (I => Creation_Inst2 (Code_LOAD,
					    Creation_Op_Flottant (Valeur),
					    Le_Registre (R1))));
      
      -- WFLOAT
      Insere_Ligne (Creation (I => Creation_Inst0 (Code_WFLOAT)));
   end Ecriture_Flottant;

   
   ---------------------
   -- Ecriture_Entier --
   ---------------------
   
   procedure Ecriture_Entier (A : in Arbre) is
      Valeur : Entier := Acces_Val_Entier (A);
   begin
      Mettre_Au_Point (3, "entree de Ecriture_Entier");

      -- LOAD #VALEUR, R1
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
						   Creation_Op_Entier (Valeur),
						   Le_Registre (R1))));
      -- WINT
      Insere_Ligne (Creation (I => Creation_Inst0 (Code_WINT)));
   end Ecriture_Entier;


   ---------------------
   -- Ecriture_Chaine --
   ---------------------
   
   procedure Ecriture_Chaine (A : in Arbre) is
      C : Chaine := Acces_Val_Chaine(A);
   begin
      Mettre_Au_Point (3, "entree de Ecriture_Chaine");
      -- WSTR "CHAINE"
      Insere_Ligne (Creation (I => Creation_Inst1 (Code_WSTR,
						   Creation_Op_Chaine (C))));
   end Ecriture_Chaine;
   
   
   -------------------------
   -- Ecriture_Expression --
   -------------------------
   
   procedure Ecriture_Expression (A : in Arbre) is
   begin
      Mettre_Au_Point (3, "entree de Ecriture_Expression");
      case Acces_Noeud_EXP (A) is
         when Noeud_Conversion =>
            case Acces_Nature (Acces_Type (Acces_Decor (A))) is
               when Type_Int | Type_Float =>
                  declare
                     Place : Operande := Place_Computation_Exp (A);
                  begin
                     -- LOAD Place, R1
                     Insere_Ligne (Creation
				     (I => Creation_Inst2 (Code_LOAD,
							   Place,
							   Le_Registre (R1))));
                     Liberer (Place);
                     if (Acces_Type (Acces_Decor (A)) = Le_Type_Float) then
                        -- WFLOAT
                        Insere_Ligne (Creation
					(I => Creation_Inst0 (Code_WFLOAT)));
                     else
                        -- WINT
                        Insere_Ligne (Creation
					(I => Creation_Inst0 (Code_WINT)));
                     end if;
                  end ;
               when others => raise Erreur_Interne;
            end case;
         when Noeud_Instanceof => raise Erreur_Interne;

         when Noeud_Null => raise Erreur_Interne;
         when Noeud_This => raise Erreur_Interne;
         when Noeud_Creation => raise Erreur_Interne;

         when Noeud_Chaine => Ecriture_Chaine(A);
         when Noeud_Entier => Ecriture_Entier(A);
         when Noeud_Flottant => Ecriture_Flottant(A);

         when
           Noeud_Appel
           | Noeud_Selection
           | Noeud_Div
           | Noeud_Moins
           | Noeud_Moins_Unaire
           | Noeud_Mult
           | Noeud_Plus
           | Noeud_Reste
           | Noeud_Ident
           | Noeud_Affect =>
            declare
               Place : Operande := Place_Computation_Exp (A);
            begin
               -- LOAD Place, R1
               Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
							    place,
							    Le_Registre (R1))));
               Liberer (Place);
               if (Acces_Type(Acces_Decor (A)) = Le_Type_Float) then
                  -- WFLOAT
                  Insere_Ligne (Creation (I => Creation_Inst0 (Code_WFLOAT)));
               else
                  -- WINT
                  Insere_Ligne (Creation (I => Creation_Inst0 (Code_WINT)));
               end if;
            end ;

         when Noeud_Lecture_Entier =>
            declare
               Place : Operande := Place_Computation_Exp (A);
            begin
               -- LOAD Place, R1
               Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
							    Place,
							    Le_Registre (R1))));
               Liberer (Place);
               -- WINT
               Insere_Ligne (Creation (I => Creation_Inst0 (Code_WINT)));
            end;

         when Noeud_Lecture_Flottant =>
            declare
               Place : Operande := Place_Computation_Exp (A);
            begin
               -- LOAD Place, R1
               Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
							    Place,
							    Le_Registre (R1))));
               Liberer (Place);
               -- WFLOAT
               Insere_Ligne (Creation (I => Creation_Inst0 (Code_WFLOAT)));
            end;

         when  -- cas impossible puisqu'ajouté par les vérifs contextuelles
           Noeud_Conv_Flottant => raise Erreur_Interne;
	    
         when -- On ne peut pas imprimer de booleen
           Noeud_Vrai
           | Noeud_Faux
           | Noeud_Egal_Egal
           | Noeud_Diff
           | Noeud_Inf
           | Noeud_Inf_Egal
           | Noeud_Sup
           | Noeud_Sup_Egal
           | Noeud_Ou
           | Noeud_Et
           | Noeud_Non => raise Erreur_Interne;
      end case;
   end Ecriture_Expression;
   
   
   ------------------------
   -- Ecriture_Exp_Print --
   ------------------------
   
   procedure Ecriture_Exp_Print (A : in Arbre) is
   begin
      Mettre_Au_Point (3, "entree de Ecriture_Exp_Print");
      Ecriture_Expression (A);
   end Ecriture_Exp_Print;


   ------------------------------
   -- Ecriture_Liste_Exp_Print --
   ------------------------------
   
   procedure Ecriture_Liste_Exp_Print (L : in Liste_Arbres) is
      Iter : constant Iterateur := Creation (L);
   begin
      Mettre_Au_Point (3, "entree de Ecriture_Liste_Exp_Print");
      while not Fini (Iter) loop
         Ecriture_Exp_Print (Suivant (Iter));
      end loop;
   end Ecriture_Liste_Exp_Print;

end Gencode_Impression;
