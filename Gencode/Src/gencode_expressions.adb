--------------------------------------------------------------------------------
--  Coprs du paquetage de génération de code pour l'évaluation des
--  expressions (passe 2)
--
--  Auteur : GL16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     10/01/2012
--        - version initiale
--------------------------------------------------------------------------------

with Ada.Text_IO, Decors, Exp_Types, Types_Base, Defns, Arbres, Pseudo_Code;
use  Ada.Text_IO, Decors, Exp_Types, Types_Base, Defns, Arbres, Pseudo_Code;

with Symboles, Gencode_Commun;
use  Symboles, Gencode_Commun;

with Outils_Instructions, Gestion_Registres, Compteur_PUSH;
use  Outils_Instructions, Gestion_Registres, Compteur_PUSH;

use  Arbres.Listes_Arbres;

pragma Elaborate_All (Pseudo_Code);

-- Toutes les fonctions de ce paquetage se chargent de générer le code
-- permettant d'évaluer le sous-arbre qui leur est donné en paramètre et
-- renvoient un operande contenant la localisation du résultat.
-- Seule l'opérande retourné doit être libéré : les autres opérandes utilisé
-- pendant le calcul ont été libéré au fur et à mesure.
-- Remarque : la majorité des ces fonctions se comportent comme l'allocateur de
-- registres.
package body Gencode_Expressions is

   Erreur_Interne : exception;

   ----------------------------------------
   -- Place_Computation_Exp_Arithmetique --
   ----------------------------------------

   function Place_Computation_Exp_Arithmetique (Code : in Code_Operation;
                                                A    : in Arbre)
                                               return Operande
   is
      -- Code : Operation arithmétique considérée
      OpG : Operande :=  Assure_Registre (Place_Computation_Exp
                                            (Acces_Fils_1 (A)));
      OpD : Operande := Place_Computation_Exp (Acces_Fils_2 (A));
      Indice : Natural := N;
   begin
      N := N + 1;

      -- Op "OpG", "OpD"
      Insere_Ligne (Creation (I => Creation_Inst2(Code, OpD, OpG)));

      if Check then
         -- Vérification du débordement
         if (Code = Code_REM or else Code = Code_QUO
               or else Acces_Type(Acces_Decor(A)) /= Le_Type_Int) then


            -- BOV bra_erreur.N
            Insere_Ligne (Creation
                            (I => Creation_Inst1 (Code_BOV,
                                                  Creation_Op_Etiq
                                                    (L_Etiq_Num ("bra_erreur", Indice)))));

            -- BRA fin_bra_erreur
            Insere_Ligne (Creation
                            (I => Creation_Inst1 (Code_BRA,
                                                  Creation_Op_Etiq
                                                    (L_Etiq_Num ("fin_bra_erreur", Indice)))));

            -- bra_erreur.N
            Insere_Ligne (Creation (E => L_Etiq_Num ("bra_erreur", Indice)));


            -- LOAD n°ligne R1
            Insere_Ligne (Creation
                            (I => Creation_Inst2 (Code_LOAD,
                                                  Creation_Op_Entier(Entier(Acces_Num_Ligne (A))),
                                                  (Le_Registre(R1)))));

            -- BRA debordement
            Insere_Ligne (Creation
                            (I => Creation_Inst1 (Code_BRA,
                                                  Creation_Op_Etiq
                                                    (L_Etiq ("debordement")))));

            -- fin_bra_erreur.N
            Insere_Ligne (Creation (E => L_Etiq_Num ("fin_bra_erreur", Indice)));



         end if;
      end if;

      -- On libère l'éventuel registre qu'on n'utilisera plus
      Liberer(OpD);
      return OpG;
   end Place_Computation_Exp_Arithmetique;


   -------------------------------------------
   -- Place_Computation_Exp_Op_Arith_Unaire --
   -------------------------------------------

   function Place_Computation_Exp_Op_Arith_Unaire (Code : in Code_Operation;
                                                   A    : in Arbre)
                                                  return Operande
   is
      Reg : Operande;
      Op  : Operande := Place_Computation_Exp (Acces_Fils_1 (A));
   begin
      if Acces_Nature (Op) = Op_Direct then
         -- Code Op, Op
         Insere_Ligne (Creation (I => Creation_Inst2 (Code, Op, Op)));
         return Op;
      else
         Reg := Le_Registre (Allouer);
         -- Code Op, Reg
         Insere_Ligne (Creation (I => Creation_Inst2 (Code, Op, Reg)));
         return Reg;
      end if;
   end Place_Computation_Exp_Op_Arith_Unaire;


   ---------------------------------------
   -- Place_Computation_Exp_Comparaison --
   ---------------------------------------

   function Place_Computation_Exp_Comparaison (Cc   : in String;
                                               Code : in Code_Operation;
                                               A    : in Arbre)
                                              return Operande
   is
      Fg : Operande := Assure_Registre (Place_Computation_Exp
                                          (Acces_Fils_1 (A)));
      Fd : Operande := Place_Computation_Exp (Acces_Fils_2 (A));
   begin
      Ligne_Vide;
      Insere_Ligne (Creation (Com => "Comparaison " & Cc));
      -- CMP "Fd", "Fg"
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_CMP, Fd, Fg)));

      -- Scc Fg
      Insere_Ligne (Creation (I => Creation_Inst1 (Code, Fg)));
      Liberer (Fd);
      return Fg;
   end Place_Computation_Exp_Comparaison;


   ------------------------------------------
   -- Place_Computation_Expression_Logique --
   ------------------------------------------

   function Place_Computation_Expression_Logique (Nom  : in String;
                                                  Code : in Code_Operation;
                                                  A    : in Arbre)
                                                 return Operande
   is
      F : Operande;
      I : Natural := N;
   begin
      N := N + 1;
      Insere_Ligne (Creation (Com => "Debut d'un calcul "& Nom));
      Insere_Ligne (Creation (Com => "Evaluation première opérande :"));
      F := Assure_Registre (Place_Computation_Exp (Acces_Fils_1 (A)));

      -- CMP #0, "F"
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_CMP,
                                                   Creation_Op_Entier (0),
                                                   F)));
      -- Bcc fin.cc.i
      Insere_Ligne (Creation
                      (I => Creation_Inst1(Code,
                                           Creation_Op_Etiq
                                             (L_Etiq_Num ("fin." & Nom, I)))));
      Liberer(F);

      Insere_Ligne (Creation (Com => "Evaluation seconde opérande :"));
      F := Assure_Registre (Place_Computation_Exp (Acces_Fils_2 (A)));

      -- fin.cc.i :
      Insere_Ligne (Creation (E => L_Etiq_Num ("fin." & Nom, I)));
      Insere_Ligne (Creation (Com => "Fin d'un calcul " & Nom));
      return F;
   end Place_Computation_Expression_Logique;


   -------------------------------
   -- Place_Computation_Demande --
   -------------------------------

   function Place_Computation_Exp_Demande (Code : in Code_Operation;
                                           A    : in Arbre)
                                          return Operande
   is
      Reg : Operande := Le_Registre (Allouer);
   begin
      -- RCode
      Insere_Ligne (Creation (I => Creation_Inst0 (Code)));

      if Check then
         -- BOV debordement
         Insere_Ligne (Creation
                         (I => Creation_Inst1 (Code_BOV,
                                               Creation_Op_Etiq
                                                 (L_Etiq ("debordement")))));
      end if;

      -- LOAD R1, Reg
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
                                                   Le_Registre (R1),
                                                   Reg)));
      return Reg;
   end Place_Computation_Exp_Demande;


   -- Effectue la vérification de déréférencement de #null.
   -- Précondition : Reg_Objet doit être un registre
   procedure Ecrire_Verif_Null (Reg_Objet : Operande) is
   begin
      if Check then
         Insere_Ligne (Creation (I => Creation_Inst2
                                   (Code_CMP, L_Op_Null, Reg_Objet)));
         Insere_Ligne (Creation
                         (I => Creation_Inst1
                            (Code_BEQ,
                             Creation_Op_Etiq
                               (L_Etiq ("dereferencement_null")))));
      end if;
   end Ecrire_Verif_Null;


   -- Retourne l'opérande désignant le champ obtenu par le déplacement "Depl"
   -- dans l'objet "Place_Objet".
   function Construire_Place_Champ (Depl        : in Deplacement;
                                    Place_Objet : in Operande)
                                   return Operande is
      Reg_Objet : Operande := Assure_Registre (Place_Objet);
   begin
      if Place_Objet /= This then
         Ecrire_Verif_Null (Reg_Objet);
      end if;
      return Creation_Op_Indirect (Depl, Acces_Registre (Reg_Objet));
   end Construire_Place_Champ;


   -----------------------------
   -- Place_Computation_Place --
   -----------------------------

   function Place_Computation_Place (A : in Arbre) return Operande is
   begin
      -- Place qui est une expression
      case Acces_Noeud_PLACE (A) is
         when Noeud_Ident =>
            -- Trois possibilités : variable, paramètre, champ
            declare
               Def : Defn := Acces_Defn (Acces_Decor (A));
            begin
               case Acces_Nature (Def) is
                  when Defn_Var | Defn_Param => return Acces_Operande (Def);
                  when Defn_Champ => return Construire_Place_Champ
                     (Deplacement (Acces_Numero (Def)), This);
                  when others => raise Erreur_Interne;
               end case;
            end;
         when Noeud_Selection =>
            -- C'est un champ !
            declare
               Place_Objet : Operande :=
                 Place_Computation_Exp (Acces_Fils_1 (A));
               Def : Defn := Acces_Defn (Acces_Decor (Acces_Fils_2 (A)));
            begin
               case Acces_Nature (Def) is
                  when Defn_Champ => return Construire_Place_Champ
                     (Deplacement (Acces_Numero (Def)), Place_Objet);
                  when others => raise Erreur_Interne;
               end case;
            end;
      end case;
   end Place_Computation_Place;


   ----------------------
   -- Empiler_Appelant --
   ----------------------

   -- Sommet de pile (this lors de l'empilement des paramètres)
   Sp_This : constant Operande := Creation_Op_Indirect (0, SP);

   -- Retourne une opérande contenant l'objet appelant, ainsi qu'un déplacement
   -- indiquant quelle méthode appeler et un boolean indiquant si la méthode
   -- retourne une valeur.
   procedure Empiler_Appelant (A      : in     Arbre;
                               Depl   :    out Deplacement;
                               Retour :    out Boolean) is
      Def : Defn;
      Place_Objet : Operande;
      Est_This : Boolean;
   begin
      -- Place qui est dans un appel : Methode
      case Acces_Noeud_PLACE (A) is
         when Noeud_Ident =>
            -- C'est une methode ! Implicitement this
            Place_Objet := This;
            Def := Acces_Defn (Acces_Decor (A));
         when Noeud_Selection =>
            Place_Objet := Place_Computation_Exp (Acces_Fils_1 (A));
            Def := Acces_Defn (Acces_Decor (Acces_Fils_2(A)));
      end case;
      Est_This := Place_Objet = This;

      Place_Objet := Assure_Registre (Place_Objet, True);
      if not Est_This then
         Ecrire_Verif_Null (Place_Objet);
      end if;

      -- STORE Reg, 0(SP)
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_STORE,
                                                   Place_Objet,
                                                   Sp_This)));

      Liberer (Place_Objet);

      Depl := Deplacement (Acces_Numero (Def));
      Retour := Acces_Type (Def) /= Le_Type_Void;
   end Empiler_Appelant;


   -----------------------------
   -- Place_Computation_Appel --
   -----------------------------

   function Place_Computation_Appel (A : in Arbre) return Operande is
      Num : Entier := 0;
      -- Empile l'opérande Place, et libère le registre éventuel.
      procedure Empiler_Place (Place : in Operande) is
         Reg : Operande := Assure_Registre (Place, True);
      begin
         Num := Num + 1;

         -- STORE Reg, -Nb_Param(SP)
         Insere_Ligne (Creation (I => Creation_Inst2
                                   (Code_STORE,
                                    Reg,
                                    Creation_Op_Indirect (- Num, SP))));

         Liberer (Reg);
      end Empiler_Place;

      -- Calcule le parametre et l'empile
      procedure Empiler_Parametre (A : in Arbre) is
      begin
         Empiler_Place (Place_Computation_Exp (A));
      end Empiler_Parametre;

      -- Calcule et empile l'ensemble des paramètres (sauf this)
      procedure Empiler_Parametres
      is new Parcourir (Empiler_Parametre);

      Depl     : Deplacement;
      Retour   : Boolean;
      Res      : Operande;
      Nb_Param : Entier := Entier (Longueur (Acces_Fille_2 (A)));
   begin
      -- On s'assure qu'il ne reste pas de données sales dans la pile
      Purger;

      -- Réservation de l'espace nécessaire dans la pile
      -- ADDSP Nb_Param + 1
      Insere_Ligne (Creation (I => Creation_Inst1 (Code_ADDSP,
                                                   Creation_Op_Entier
                                                     (Nb_Param + 1))));

      -- On compte le décalage pour les paramètres
      Compte_PUSH (Nb_Param + 1);

      -- Empilement du paramètre implicite
      Empiler_Appelant (Acces_Fils_1 (A), Depl, Retour);
      -- Depl   : le numero de la methode à appeler
      -- Retour : true si la méthode retourne une valeur

      -- Empilement des paramètres explicites
      Empiler_Parametres (Acces_Fille_2 (A));

      -- On s'assure qu'il ne reste pas de données sales dans la pile
      Purger;

      -- Récupération de l'adresse de la méthode
      -- LOAD 0(SP), R0
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
                                                   Sp_This,
                                                   Le_Registre (R0))));

      -- LOAD 0(R0), R0
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
                                                   Creation_Op_Indirect(0,R0),
                                                   Le_Registre (R0))));


      -- Appel de la méthode
      Compte_PUSH (2);
      -- BSR Depl(R1)
      Insere_Ligne(Creation(I => Creation_Inst1
                              (Code_BSR,
                               Creation_Op_Indirect (Depl, R0))));
      Compte_POP (2);

      -- On dépile tous les paramètres en une fois !
      -- SUBSP Nb_Param + 1
      Insere_Ligne (Creation (I => Creation_Inst1
                                (Code_SUBSP,
                                 Creation_Op_Entier(Nb_Param + 1))));
      Compte_POP (Nb_Param + 1);

      -- On récupère éventuellement la valeur de retour
      if Retour then
         Res := Le_Registre (Allouer);
         -- LOAD R0, Res
         Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
                                                      Le_Registre (R0),
                                                      Res)));
      else
         -- Pas de valeur de retour, on retourne un opérande ad-hoc
         Res := Le_Registre (R0);
      end if;

      return Res;
   end;


   --------------------------------
   -- Appelle_Init_Recursivement --
   --------------------------------

   -- Appele l'initialisation de la classe "Nom" ainsi que de ses super-classes
   -- dans l'ordre de leur filiation (descendant).
   procedure Appelle_Init_Recursivement (Nom : in Chaine) is
      Etiq_Init : Etiq := L_Etiq ("init." & Acces_String(Nom));
   begin

      if Acces_String(Nom) /= "Object" then
         Appelle_Init_Recursivement (Acces_Extension
                                       (Acces_Defn (Acces_Env_Types, Nom)));
         Compte_PUSH(2);
         -- BSR init.Nom
         Insere_Ligne (Creation
                         (I => Creation_Inst1 (Code_BSR,
                                               Creation_Op_Etiq (Etiq_Init))));
         Compte_POP(2);
      end if;
   end;


   --------------------------------
   -- Place_Computation_Creation --
   --------------------------------

   function Place_Computation_Creation (A : in Arbre) return Operande is
      Classe : Arbre := Acces_Fils_1(A);
      Tas_Plein : Etiq := L_Etiq ("tas_plein");
      Taille : Entier := Entier (Acces_Nombre_Champs
                                   (Acces_Defn (Acces_Decor (Classe)))) + 1;
      Reg : Operande := Le_Registre (Allouer);

      Nom : Chaine := Acces_Nom(Classe);
      Etiq_Init : Etiq := L_Etiq ("init."&Acces_String(Nom));
   begin
      -- NEW Taille Reg
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_NEW,
                                                   Creation_Op_Entier (Taille),
                                                   Reg)));

      if Check then
         -- BOV tas_plein
         Insere_Ligne (Creation
                         (I => Creation_Inst1 (Code_BOV,
                                               Creation_Op_Etiq (Tas_Plein))));
      end if;

      -- LEA adresse de la classe dans la TM , R0
      Insere_Ligne (Creation
                      (I => Creation_Inst2 (Code_LEA,
                                            Acces_Operande (Acces_Defn
                                                              (Acces_Decor
                                                                 (Classe))),
                                            Le_Registre (R0))));

      -- STORE R0, 0(Reg)
      Insere_Ligne (Creation
                      (I => Creation_Inst2 (Code_STORE,
                                            Le_Registre (R0),
                                            Creation_Op_Indirect
                                              (0, Acces_Registre (Reg)))));

      if Acces_String(Nom) /= "Object" then
         -- PUSH Reg
         Insere_Ligne (Creation (I => Creation_Inst1 (Code_PUSH, Reg)));

         -- Appelle les "init" de toutes les super-classes dans l'ordre
         -- descendant
         Appelle_Init_Recursivement(Nom);

         -- POP Reg
         Insere_Ligne (Creation (I => Creation_Inst1 (Code_POP, Reg)));
      end if;
      return Reg;
   end Place_Computation_Creation;


   ----------------------------------
   -- Place_Computation_InstanceOf --
   ----------------------------------

   function Place_Computation_InstanceOf (Obj    : in Operande;
                                          Classe : in Arbre) return Operande is
      Reg    : Operande := Obj;
      Indice : Natural  := N;
   begin
      N := N + 1;

      -- CMP #null, Reg
      Insere_Ligne (Creation (I => Creation_Inst2(Code_CMP, L_Op_Null, Reg)));
      -- BEQ true_instanceof.Indice
      Insere_Ligne (Creation
                      (I => Creation_Inst1 (Code_BEQ,
                                            Creation_Op_Etiq
                                              (L_Etiq_Num ("true_instanceof",
                                                           Indice)))));

      -- while_instanceof.Indice
      Insere_Ligne (Creation (E => L_Etiq_Num ("while_instanceof", Indice)));


      -- LOAD (Reg), Reg
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
                                                   Creation_Op_Indirect
                                                     (0, Acces_Registre (Reg)),
                                                   Reg)));

      -- CMP #null, Reg
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_CMP, L_Op_Null, Reg)));

      -- BEQ false_instanceof.Indice
      Insere_Ligne (Creation
                      (I => Creation_Inst1 (Code_BEQ,
                                            Creation_Op_Etiq
                                              (L_Etiq_Num("false_instanceof",
                                                          Indice)))));

      -- LEA adresse de la classe dans la TM , R1
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_LEA,
                                                   Acces_Operande
                                                     (Acces_Defn
                                                        (Acces_Decor(Classe))),
                                                   Le_Registre(R1))));

      -- CMP R1, Reg
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_CMP,
                                                   Le_Registre (R1),
                                                   Reg)));

      -- BEQ true_instanceof.Indice
      Insere_Ligne (Creation
                      (I => Creation_Inst1 (Code_BEQ,
                                            Creation_Op_Etiq
                                              (L_Etiq_Num("true_instanceof",
                                                          Indice)))));

      -- BRA while_instanceof.Indice
      Insere_Ligne (Creation
                      (I => Creation_Inst1 (Code_BRA,
                                            Creation_Op_Etiq
                                              (L_Etiq_Num("while_instanceof",
                                                          Indice)))));

      -- true_instanceof.Indice
      Insere_Ligne (Creation (E => L_Etiq_Num ("true_instanceof", Indice)));

      -- LOAD #1, Reg
      Insere_Ligne (Creation (I => Creation_Inst2(Code_LOAD,
                                                  Creation_Op_Entier (1),
                                                  Reg)));

      -- BRA fin_instanceof.Indice
      Insere_Ligne (Creation
                      (I => Creation_Inst1 (Code_BRA,
                                            Creation_Op_Etiq
                                              (L_Etiq_Num("fin_instanceof",
                                                          Indice)))));

      -- false_instanceof.Indice
      Insere_Ligne (Creation (E => L_Etiq_Num ("false_instanceof", Indice)));

      -- LOAD #0, Reg
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
                                                   Creation_Op_Entier (0),
                                                   Reg)));

      -- fin_instanceof.Indice
      Insere_Ligne (Creation (E => L_Etiq_Num ("fin_instanceof", Indice)));

      return Reg;
   end;


   ----------------------------------
   -- Place_ComputationèInstanceof --
   ----------------------------------

   function Place_Computation_Instanceof (A : in Arbre) return Operande is
      Reg : Operande :=
        Assure_Registre (Place_Computation_Exp (Acces_Fils_1 (A)));
   begin
      return Place_Computation_InstanceOf (Reg, Acces_Fils_2(A));
   end Place_Computation_Instanceof;


   --------------------------------------
   -- Place_Computation_Conv_INT_FLOAT --
   --------------------------------------

   -- Evalue une conversion numérique explicite (instruction INT ou FLOAT)
   function Place_Computation_Conv_INT_FLOAT (Place_Objet : Operande;
                                              Code        : Code_Operation)
                                             return Operande
   is
      Res : Operande;
   begin
      -- INT Place_Objet, Place_Objet
      if Acces_Nature (Place_Objet) = Op_Direct then
         Res := Place_Objet;
      elsif Acces_Nature (Place_Objet) = Op_Indirect and then
        Acces_Base (Place_Objet) in Utilisable then
         Res := Le_Registre (Acces_Base (Place_Objet));
      else
         Res := Le_Registre (Allouer);
      end if;

      -- Code Place_Objet Res
      Insere_Ligne (Creation
                      (I => Creation_Inst2 (Code,
                                            Place_Objet,
                                            Res)));

      if Check then
         -- BOV debordement
         Insere_Ligne (Creation
                         (I => Creation_Inst1
                            (Code_BOV,
                             Creation_Op_Etiq (L_Etiq ("debordement")))));
      end if;
      return Res;
   end Place_Computation_Conv_INT_FLOAT;


   ----------------------------------
   -- Place_Computation_Conversion --
   ----------------------------------

   function Place_Computation_Conversion (A : in Arbre) return Operande is
      Typ1 : Nature_Type :=
        Acces_Nature (Acces_Type (Acces_Decor (Acces_Fils_1 (A))));
      Typ2 : Nature_Type :=
        Acces_Nature (Acces_Type (Acces_Decor (Acces_Fils_2 (A))));

      Place_Objet : Operande := Place_Computation_Exp (Acces_Fils_2 (A));
   begin
      if Typ1 = Typ2 and then (Typ1 = Type_Int or else Typ1 = Type_Float
                                 or else Typ1 = Type_Boolean) then
         return Place_Objet;

      elsif Typ1 = Type_Float and then Typ2 = Type_Int then
         return Place_Computation_Conv_INT_FLOAT (Place_Objet, Code_FLOAT);

      elsif Typ1 = Type_Int and then Typ2 = Type_Float then
         return Place_Computation_Conv_INT_FLOAT (Place_Objet, Code_INT);

      elsif Typ1 = Type_Classe and then Typ2 = Type_Classe then
         declare
            Reg_Objet : Operande := Le_Registre (Allouer);
         begin
            -- LOAD Place_Objet, Reg_Objet
            Insere_Ligne (Creation
                            (I => Creation_Inst2 (Code_LOAD,
                                                  Place_Objet,
                                                  Reg_Objet)));

            Reg_Objet := Place_Computation_Instanceof (Reg_Objet,
                                                       Acces_Fils_1 (A));
            -- CMP #0, Reg_Objet
            Insere_Ligne (Creation
                            (I => Creation_Inst2 (Code_CMP,
                                                  Creation_Op_Entier (0),
                                                  Reg_Objet)));

            -- BEQ erreur_conversion
            Insere_Ligne (Creation
                            (I => Creation_Inst1
                               (Code_BEQ, Creation_Op_Etiq
                                  (L_Etiq ("conversion_impossible")))));
            Liberer (Reg_Objet);

            return Place_Objet;
         end;
      else
         Put_Line (Standard_Error, "Erreur : conversion impossible");
         raise Erreur_Interne;
      end if;
   end Place_Computation_Conversion;


   ---------------------------
   -- Place_Computation_Exp --
   ---------------------------

   function Place_Computation_Exp (A : in Arbre) return Operande is
   begin
      case Acces_Noeud_EXP(A) is
         when Noeud_Chaine =>
            Put_Line (Standard_Error, "Erreur : une chaine n'est pas " &
                        "une expression valide");
            raise Erreur_Interne;

            -- Maxi-Deca
         when Noeud_Conversion =>
            return Place_Computation_Conversion (A);
         when Noeud_Instanceof =>
            return Place_Computation_Instanceof (A);

            -- Objets
         when Noeud_Creation =>
            return Place_Computation_Creation (A);
         when Noeud_Null =>
            return L_Op_Null;
         when Noeud_This =>
            return This;
         when Noeud_Appel =>
            return Place_Computation_Appel (A);

            -- Arithmétique
         when Noeud_Entier =>
            return Creation_Op_Entier (Acces_Val_Entier (A));
         when Noeud_Flottant =>
            return Creation_Op_Flottant (Acces_Val_Flottant (A));
         when Noeud_Conv_Flottant =>
            return Place_Computation_Exp_Op_Arith_Unaire (Code_FLOAT, A);

         when Noeud_Plus =>
            return Place_Computation_Exp_Arithmetique (Code_ADD, A);
         when Noeud_Moins =>
            return Place_Computation_Exp_Arithmetique (Code_SUB, A);
         when Noeud_Mult =>
            return Place_Computation_Exp_Arithmetique (Code_MUL, A);
         when Noeud_Div =>
            if (Acces_Type (Acces_Decor (A)) = Le_Type_Float) then
               return Place_Computation_Exp_Arithmetique (Code_DIV, A);
            else
               return Place_Computation_Exp_Arithmetique (Code_QUO, A);
            end if;
         when Noeud_Reste =>
            return Place_Computation_Exp_Arithmetique (Code_REM, A);

         when Noeud_Moins_Unaire =>
            return Place_Computation_Exp_Op_Arith_Unaire (Code_OPP, A);

            -- Comparaisons
         when Noeud_Egal_Egal =>
            return Place_Computation_Exp_Comparaison ("EQ", Code_SEQ, A);
         when Noeud_Diff =>
            return Place_Computation_Exp_Comparaison ("NE", Code_SNE, A);
         when Noeud_Inf =>
            return Place_Computation_Exp_Comparaison ("LT", Code_SLT, A);
         when Noeud_Inf_Egal =>
            return Place_Computation_Exp_Comparaison ("LE", Code_SLE, A);
         when Noeud_Sup =>
            return Place_Computation_Exp_Comparaison ("GT", Code_SGT, A);
         when Noeud_Sup_Egal =>
            return Place_Computation_Exp_Comparaison ("GE", Code_SGE, A);

            -- Logique
         when Noeud_Vrai => return Creation_Op_Entier (1);
         when Noeud_Faux => return Creation_Op_Entier (0);
         when Noeud_Et =>
            return Place_Computation_Expression_Logique ("ET", Code_BEQ,A);
         when Noeud_Ou =>
            return Place_Computation_Expression_Logique ("OU",Code_BNE,A);
         when Noeud_Non =>
            declare
               F : Operande
                 := Assure_Registre (Place_Computation_Exp (Acces_Fils_1 (A)));
            begin
               -- CMP #0, F
               Insere_Ligne (Creation
                               (I => Creation_Inst2 (Code_CMP,
                                                     Creation_Op_Entier (0),
                                                     F)));

               -- SEQ F
               Insere_Ligne (Creation (I => Creation_Inst1 (Code_SEQ, F)));
               return F;
            end;

            -- Entrees
         when Noeud_Lecture_Entier =>
            return Place_Computation_Exp_Demande (Code_RINT, A);
         when Noeud_Lecture_Flottant =>
            return Place_Computation_Exp_Demande (Code_RFLOAT, A);

            -- Variables
         when Noeud_Affect =>
            declare
               Place_Var : Operande :=
                 Place_Computation_Place (Acces_Fils_1 (A));
               Place_Exp : Operande :=
                 Assure_Registre (Place_Computation_Exp (Acces_Fils_2 (A)));
            begin
               -- STORE Place_Exp Place_Var
               Insere_Ligne (Creation (I => Creation_Inst2 (Code_STORE,
                                                            Place_Exp,
                                                            Place_Var)));
               Liberer (Place_Exp);
               return Place_Var;
            end;

         when others =>
            -- C'est un PLACE :
            return Place_Computation_Place (A);
      end case;
   end Place_Computation_Exp;
end Gencode_Expressions;
