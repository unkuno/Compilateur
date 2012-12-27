--------------------------------------------------------------------------------
--  Spécification du paquetage de génération de code spécialisé dans la gestion
--  du programme principal et du corps des méthodes (passe 2)
--
--  Auteur : GL16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     10/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Types_Base, Pseudo_Code, Arbres, Defns, Decors, Exp_Types;
use  Types_Base, Pseudo_Code, Arbres, Defns, Decors, Exp_Types;

with Outils_Instructions, Gestion_Registres, Compteur_PUSH;
use  Outils_Instructions, Gestion_Registres, Compteur_PUSH;

with Gencode_Commun, Gencode_Expressions, Gencode_Impression;
use  Gencode_Commun, Gencode_Expressions, Gencode_Impression;

use Arbres.Listes_Arbres;

pragma Elaborate_All (Types_Base);

-- Les procédures de ce paquetage produisent le code nécessaire à l'évaluation
-- des arbres qui leur sont donnés en paramètre.
package body Gencode_Programme is
   
   -- Compteur de sommet de pile potentiel
   -- (lors de l'empilement des variables globales)
   Decalage : Entier := 0;
   
   -- Variables globales
   Nom_Classe_Courante  : Chaine := Creation (""); -- classe courante
   Nom_Methode_Courante : Chaine := Creation (""); -- méthode courante
   
   Erreur_Interne  : exception;
   
   -- Point d'entrée des blocs
   procedure Ecrire_Bloc (L : in Liste_Arbres);
   
   
   -----------------------
   -- Ecrire_Liste_Cond --
   -----------------------
   
   procedure Ecrire_Cond (Etiq_Else : in Etiq; A : in Arbre) is
      Place : Operande;
   begin
      Place := Assure_Registre (Place_Computation_Exp (Acces_Fils_1 (A)));
      
      -- CMP #0, Place
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_CMP,
						   Creation_Op_Entier (0),
						   Place)));
      Liberer (Place);
      -- BEQ Etiq_Else
      Insere_Ligne (Creation (I => Creation_Inst1 (Code_BEQ,
						   Creation_Op_Etiq
						     (Etiq_Else))));
      Ecrire_Bloc (Acces_Fille_2 (A));
   end Ecrire_Cond;
   
   
   -----------------------
   -- Ecrire_Liste_Cond --
   -----------------------
   
   procedure Ecrire_Liste_Cond (Indice : in Natural; L : in Liste_Arbres) is
      Iter : constant Iterateur := Creation (L);
      I : Natural := 0;
      Suiv : Arbre;
   begin
      Mettre_Au_Point (3, "entree de Ecrire_Liste_Cond");

      while not Fini (Iter) loop
         -- if.Indice.I
         Insere_Ligne (Creation (E => L_Etiq_Num ("if." & Nat_Image (Indice),
						  I)));
         I := I + 1;
         Suiv := Suivant (Iter);
         if not Fini (Iter) then
            -- if.Indice.I
            Ecrire_Cond (L_Etiq_Num ("if." & Nat_Image (Indice), I), Suiv);
         else
            -- else.Indice
            Ecrire_Cond (L_Etiq_Num ("else", Indice), Suiv);
         end if;
         --BRA fin.Indice
         Insere_Ligne (Creation
			 (I => Creation_Inst1 (Code_BRA,
					       Creation_Op_Etiq
						 (L_Etiq_Num ("fin",
							      Indice)))));
      end loop;
   end Ecrire_Liste_Cond;
   
   
   -----------------
   -- Ecrire_Inst --
   -----------------
   
   procedure Ecrire_Inst (A : in Arbre) is
   begin
      Mettre_Au_Point (3, "entree de Ecrire_Inst");
      case Acces_Noeud_INST (A) is
         when Noeud_Retour =>
            declare
               Fin : Etiq := L_Etiq("fin."
                                      & Acces_String (Nom_Classe_Courante)
                                      & "."
                                      & Acces_String (Nom_Methode_Courante));
               Place : Operande := Place_Computation_Exp (Acces_Fils_1 (A));
            begin
               -- LOAD exp R0
               Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
							    Place,
							    Le_Registre (R0))));
               Liberer (Place);

               -- BRA fin.Nom_Methode
               Insere_Ligne (Creation
			       (I => Creation_Inst1 (Code_BRA,
						     Creation_Op_Etiq (Fin))));
            end;

         when Noeud_Si =>
            declare
               Indice : Natural := N;
            begin
               N := N + 1;
               Ecrire_Liste_Cond (Indice, Acces_Fille_1 (A));
               -- else.Indice
               Insere_Ligne (Creation (E => L_Etiq_Num ("else", Indice)));
               Ecrire_Bloc (Acces_Fille_2 (A));
               -- fin.Indice
               Insere_Ligne (Creation (E => L_Etiq_Num ("fin", Indice)));
            end;

         when Noeud_Tantque =>
            declare
               Indice : Natural := N;
               Place  : Operande;
            begin
               N := N + 1;
               -- WHILE.Indice
               Insere_Ligne (Creation (E => L_Etiq_Num ("while", Indice)));

               Place := Place_Computation_Exp (Acces_Fils_1 (A));
               -- LOAD Place, R1
               Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
							    Place,
							    Le_Registre (R1))));
               Liberer (Place);

               -- CMP #0, R1
               Insere_Ligne (Creation
			       (I => Creation_Inst2 (Code_CMP,
						     Creation_Op_Entier (0),
						     Le_Registre (R1))));
               -- BEQ FIN.Indice
               Insere_Ligne (Creation
			       (I => Creation_Inst1 (Code_BEQ,
						     Creation_Op_Etiq
						       (L_Etiq_Num ("fin",
								    Indice)))));
               Ecrire_Bloc (Acces_Fille_2 (A));

               -- BRA while.Indice
               Insere_Ligne (Creation
			       (I => Creation_Inst1 (Code_BRA,
						     Creation_Op_Etiq
						       (L_Etiq_Num
							  ("while", Indice)))));
               -- fin.Indice
               Insere_Ligne (Creation (E => L_Etiq_Num ("fin", Indice)));
            end;

         when Noeud_Ecriture =>
            Ecriture_Liste_Exp_Print (Acces_Fille_1 (A));
         when Noeud_Ecriture_Ligne =>
            Ecriture_Liste_Exp_Print (Acces_Fille_1 (A));
            Insere_Ligne (Creation (I => Creation_Inst0 (Code_WNL)));

         When Noeud_Nop => null;

         when others => -- Expression
            Liberer (Place_Computation_Exp (A));
      end case;
   end Ecrire_Inst;
   
   
   -----------------
   -- Ecrire_Bloc --
   -----------------
   
   procedure Ecrire_Bloc (L : in Liste_Arbres) is
      Iter : constant Iterateur := Creation (L);
      Cour : Arbre;
   begin
      Mettre_Au_Point (3, "entree de Ecrire_Bloc");

      while not Fini (Iter) loop
         Cour := Suivant (Iter);
         Ligne_Vide;
         Insere_Ligne (Creation (Com => "Instruction ligne n°"
                                   & Natural'Image (Acces_Num_Ligne (Cour))
                                   & "."));
         Ecrire_Inst (Cour);
      end loop;

   end Ecrire_Bloc;


   ---------------------
   -- Ecrire_Decl_Var --
   ---------------------
   
   procedure Ecrire_Decl_Var (A : in Arbre) is
      Place : Operande := Creation_Op_Indirect (Decalage + 1, LB);
   begin
      Mettre_Au_Point (3, "entree de Ecrire_Decl_Var");

      -- Placement dans l'arbre de la place qui est réservée
      Changer_Operande (Acces_Defn (Acces_Decor (Acces_Fils_1 (A))), Place);

      case Acces_Noeud_INITIALISATION (Acces_Fils_2 (A)) is
         when Noeud_Vide => null;
         when others =>
            declare
               Reg_Init : Operande := Assure_Registre (Place_Computation_Exp
							 (Acces_Fils_2(A)),
						       True);
            begin
               -- STORE "Reg_Init" "Place"
               Insere_Ligne (Creation (I => Creation_Inst2 (Code_STORE,
							    Reg_Init,
							    Place)));
               Liberer (Reg_Init);
            end;
      end case;
      Decalage := Decalage + 1;
   end Ecrire_Decl_Var;
   
   
   ---------------------------
   -- Ecrire_Liste_Decl_Var --
   ---------------------------
   
   procedure Ecrire_Liste_Decl_Var (L : in Liste_Arbres) is
      Iter : constant Iterateur := Creation (L);
      Cour : Arbre;
   begin
      Mettre_Au_Point (3, "entree de Ecrire_Liste_Decl_Var");

      while not Fini (Iter) loop
         Cour := Suivant (Iter);
         Insere_Ligne (Creation (Com => "Declarations ligne n°"
                                   & Natural'Image (Acces_Num_Ligne (Cour))
                                   & "."));
         Ecrire_Decl_Var (Cour);
         Ligne_Vide;
      end loop;
   end Ecrire_Liste_Decl_Var;
   
   
   -------------------------
   -- Ecrire_Decl_Variable --
   -------------------------
   
   procedure Ecrire_Decl_Variable (A : in Arbre) is
   begin
      Mettre_Au_Point (3, "entree de Ecrire_Decl_Variable");
      Ecrire_Liste_Decl_Var (Acces_Fille_2 (A));
   end Ecrire_Decl_Variable;
   
   
   --------------------------------
   -- Ecrire_Liste_Decl_Variable --
   --------------------------------
   
   procedure Ecrire_Liste_Decl_Variable (L : in Liste_Arbres) is
      Iter : constant Iterateur := Creation (L);
   begin
      Mettre_Au_Point (3, "entree de Ecrire_Liste_Decl_Variable");
      while not Fini (Iter) loop
         Ecrire_Decl_Variable (Suivant (Iter));
      end loop;
   end Ecrire_Liste_Decl_Variable;
   
   
   ----------------------
   -- Ecrire_Principal --
   ----------------------
   
   procedure Ecrire_Principal (A : in Arbre) is
   begin
      Mettre_Au_Point (3, "entree de Ecrire_Principal");
      case Acces_Noeud_PRINCIPAL (A) is
         when Noeud_Vide => null;
         when Noeud_Principal =>
            Ligne_Vide;
            Ecrire_Cadre ("Programme principal");
            Ligne_Vide;

            Ecrire_Liste_Decl_Variable (Acces_Fille_1 (A));
            -- Nom_Methode_Courant := Creation ("Principal");
            -- Inutile puisque pas de retour dans principal
            Ecrire_Bloc (Acces_Fille_2 (A));
            -- fin.Nom_Methode :
      end case;
      Finalise_Bloc (Decalage, Get_Nb_PUSH_Max, False);

      Ligne_Vide;
      Insere_Ligne (Creation (Com => "Fin du programme principal"));
      -- HALT
      Insere_Ligne (Creation (I => Creation_Inst0 (Code_HALT)));
      Ligne_Vide;
   end Ecrire_Principal;


   -----------------------
   -- Ecrire_Decl_Champ --
   -----------------------
   
   procedure Ecrire_Decl_Champ (A : in Arbre) is
      Def : Defn := Acces_Defn (Acces_Decor (Acces_Fils_1 (A)));
      Depl : Deplacement := Deplacement (Acces_Numero (Def));
      Reg : Operande;
   begin
      case Acces_Noeud_INITIALISATION (Acces_Fils_2 (A)) is
         when Noeud_Vide =>
            case Acces_Nature (Acces_Type (Def)) is
               when Type_Int | Type_Boolean =>
                  -- LOAD #0, R1
                  Insere_Ligne (Creation
				  (I => Creation_Inst2 (Code_LOAD,
							Creation_Op_Entier (0),
							Le_Registre (R1))));
               when Type_Float =>
                  -- LOAD #0.0, R1
                  Insere_Ligne (Creation
				  (I => Creation_Inst2
				     (Code_LOAD,
				      Creation_Op_Flottant (0.0),
				      Le_Registre (R1))));
               when Type_Classe =>
                  -- LOAD #null, R1
                  Insere_Ligne (Creation
				  (I => Creation_Inst2(Code_LOAD,
						       L_Op_Null,
						       Le_Registre (R1))));
               when others =>
                  raise Erreur_Interne;
            end case;
            Reg := Le_Registre (R1);
         when others =>
            Reg := Assure_Registre
              (Place_Computation_Exp (Acces_Fils_2 (A)), True);
      end case;
      -- LOAD This, R0
      Insere_Ligne (Creation
                     (I => Creation_Inst2 (Code_LOAD,
					   This,
					   Le_Registre (R0))));

      -- STORE Reg, Depl(R0)
      Insere_Ligne (Creation
                     (I => Creation_Inst2 (Code_STORE,
					   Reg,
					   Creation_Op_Indirect (Depl, R0))));
      Liberer (Reg);
   end Ecrire_Decl_Champ;
   
   
   ---------------------
   -- Ecrire_Champ(s) --
   ---------------------
   
   procedure Ecrire_Champ (A : in Arbre) is
   begin
      case Acces_Noeud_CONSTITUANT (A) is
         when Noeud_Methode => null;
         when Noeud_Champ =>
            declare
               Iter : constant Iterateur := Creation (Acces_Fille_3 (A));
            begin
               while not Fini (Iter) loop
                  Ecrire_Decl_Champ (Suivant (Iter));
               end loop;
            end;
      end case;
   end Ecrire_Champ;

   procedure Ecrire_Champs
   is new Parcourir (Ecrire_Champ);


   ----------------------------------
   -- Remplis_Operandes_Prametres --
   ----------------------------------
   
   procedure Remplis_Operandes_Parametres (L : in Liste_Arbres) is
      Iter : constant Iterateur := Creation (L);
      Compteur : Entier := 1;
      D : Defn;
   begin
      while not Fini (Iter) loop
         D := Acces_Defn (Acces_Decor (Acces_Fils_2 (Suivant (Iter))));
         Changer_Operande (D, Creation_Op_Indirect (-2 - Compteur, LB));
         Compteur := Compteur + 1;
      end loop;
   end Remplis_Operandes_Parametres;


   -----------------------
   -- Ecrire_Methode(s) --
   -----------------------
   
   procedure Ecrire_Methode (A : in Arbre) is
   begin
      case Acces_Noeud_CONSTITUANT(A) is
         when Noeud_Champ => null;
         when Noeud_Methode =>
            Nom_Methode_Courante := Acces_Nom (Acces_Fils_2 (A));
            declare
               Nom : String := Acces_String (Nom_Classe_Courante) & "." &
                 Acces_String (Nom_Methode_Courante);
               Erreur_Return : Operande := Creation_Op_Chaine
                 (Creation ("Erreur : sortie de la méthode " &
                              Nom & " sans return"));
               Nb_Sauvegardes : Entier;
            begin
               Reinitialiser_Registres;
               Initialise_Compteur_PUSH;
               Decalage := 0;

               Ligne_Vide;
               Insere_Ligne (Creation (Com => "Méthode " & Nom));

               -- Etiquette correspondante au début de la méthode
               -- code.Nom_Classe.Nom_Methode :
               Insere_Ligne (Creation (E => L_Etiq ("code." & Nom)));

               Initialise_Bloc;

               -- Parametres : remplissage des operandes
               Remplis_Operandes_Parametres (Acces_Fille_3 (A));

               -- Declarations :
               Ecrire_Liste_Decl_Variable (Acces_Fille_4 (A));

               -- Bloc
               Ecrire_Bloc (Acces_Fille_5 (A));


               -- BRA erreur de sortie sans "return" si besoin
               if Acces_Type (Acces_Decor (Acces_Fils_1 (A)))
		 /= Le_Type_Void then
                  -- WSTR message_erreur pas de return
                  Insere_Ligne (Creation (I => Creation_Inst1 (Code_WSTR,
							       Erreur_Return)));
                  -- WNL
                  Insere_Ligne (Creation (I => Creation_Inst0 (Code_WNL)));
                  -- ERROR
                  Insere_Ligne (Creation (I => Creation_Inst0 (Code_ERROR)));
               end if;

               -- Etiquette de fin
               -- fin.Nom_Methode :
               Insere_Ligne (Creation (E => L_Etiq ("fin." & Nom)));

               Purger;
               Nb_Sauvegardes := Sauvegarder_Registres;
               Finalise_Bloc(Decalage + Nb_Sauvegardes, Get_Nb_PUSH_Max);

               -- Retour d'appel
               -- RTS
               Insere_Ligne (Creation (I => Creation_Inst0 (Code_RTS)));
            end;
      end case;
   end Ecrire_Methode;

   procedure Ecrire_Methodes
   is new Parcourir (Ecrire_Methode);
   
   
   -------------------
   -- Ecrire_Classe --
   -------------------
   
   procedure Ecrire_Classe (A : in Arbre) is
      Nb_Sauvegardes : Entier;
   begin
      Nom_Classe_Courante := Acces_Nom (Acces_Fils_1 (A));

      Ligne_Vide;
      Ecrire_Cadre ("Code de la classe " &
                      Acces_String (Nom_Classe_Courante));

      -- Ecriture du code de toutes les méthodes.
      Ecrire_Methodes (Acces_Fille_3 (A));

      -- Ecriture du constructeur init
      Reinitialiser_Registres;
      Initialise_Compteur_PUSH;

      Ligne_Vide;
      Insere_Ligne (Creation (Com => "Initialisation des champs de la classe " &
                                Acces_String (Nom_Classe_Courante)));
      -- Init Nom_Classe
      Insere_Ligne(Creation
                     (E => L_Etiq("init."
                                    & Acces_String(Nom_Classe_Courante))));

      Initialise_Bloc;

      Ecrire_Champs (Acces_Fille_3 (A));

      Purger;
      Nb_Sauvegardes := Sauvegarder_Registres;

      Finalise_Bloc (Nb_Sauvegardes, Get_Nb_PUSH_Max);

      -- Retour d'appel
      -- RTS
      Insere_Ligne (Creation (I => Creation_Inst0 (Code_RTS)));
   end Ecrire_Classe;
   
   
   --------------------
   -- Ecrire_Classes --
   --------------------
   
   procedure Ecrire_Classes (L : in Liste_Arbres) is
      Iter : constant Iterateur := Creation (L);
   begin
      while not Fini (Iter) loop
         Ecrire_Classe (Suivant (Iter));
      end loop;
   end Ecrire_Classes;


   ---------------------------
   -- Ecrire_Code_Programme --
   ---------------------------
   
   procedure Ecrire_Code_Programme (A : in Arbre; Compteur_Pile : in Entier) is
   begin
      Decalage := Compteur_Pile;
      Ecrire_Principal (Acces_Fils_2 (A));
      Ecrire_Code_Erreur;
      Ecrit_Code_Object_Equals;
      Ecrire_Classes (Acces_Fille_1 (A));
   end Ecrire_Code_Programme;
end Gencode_Programme;
