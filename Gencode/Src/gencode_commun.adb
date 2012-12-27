--------------------------------------------------------------------------------
--  Corps du paquetage de primitives communes pour la génération de code
--  (passe 2)
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     10/01/2012
--        - version initiale
-------------------------------------------------------------------------------

with Ada.Text_IO;
use  Ada.Text_IO;

with Outils_Instructions, Gestion_Registres;
use  Outils_Instructions, Gestion_Registres;

package body Gencode_Commun is

   procedure Mettre_Au_Point (Niveau : in Positive; S : in String) is
      -- plus Niveau_Max est eleve, plus il y a d'affichage
      Niveau_Max : constant := 0;
   begin
      if Niveau <= Niveau_Max then
         Put_Line (Standard_Error, "Gencode (passe 2) : " & S);
      end if;
   end Mettre_Au_Point;


   -----------------------------
   -- Ecrit_Code_Object_Equals --
   -----------------------------

   procedure Ecrit_Code_Object_Equals is
   begin
      Ligne_Vide;
      Ecrire_Cadre ("Code de la classe Object");

      Ligne_Vide;
      Insere_Ligne (Creation (Com => "Méthode Object.equals"));
      -- code.Object.equals :
      Insere_Ligne (Creation (E => L_Etiq ("code.Object.equals")));
      -- LOAD This, R0
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
                                                   This,
                                                   Le_Registre (R0))));
      -- CMP -3(LB), R0);
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_CMP,
                                                   Creation_Op_Indirect (-3,LB),
                                                   Le_Registre (R0))));
      -- SEQ R0
      Insere_Ligne (Creation (I => Creation_Inst1 (Code_SEQ,
                                                   Le_Registre (R0))));
      -- RTS
      Insere_Ligne (Creation (I => Creation_Inst0 (Code_RTS)));
   end Ecrit_Code_Object_Equals;


   ------------------------
   -- Ecrire_Code_Erreur --
   ------------------------

   procedure Ecrire_Code_Erreur is
   begin
      if Check then
         Ligne_Vide;
         Ecrire_Cadre ("Gestion des erreurs");

         -- debordement
         Ligne_Vide;
         Insere_Ligne (Creation (E => L_Etiq ("debordement")));
         -- WSTR "Erreur : dépassement de capacité"
         Insere_Ligne (Creation
                         (I => Creation_Inst1
                            (Code_WSTR,
                             Creation_Op_Chaine
                               (Creation
                                  ("Erreur : dépassement de capacité ligne n°")))));

         -- WINT;
         Insere_Ligne (Creation
                         (I => Creation_Inst0(Code_WINT)));

         -- WNL
         Insere_Ligne (Creation (I => Creation_Inst0 (Code_WNL)));
         -- ERROR
         Insere_Ligne (Creation (I => Creation_Inst0 (Code_ERROR)));

         -- tas_plein
         Ligne_Vide;
         Insere_Ligne (Creation (E => L_Etiq ("tas_plein")));
         -- WSTR "Erreur : tas plein"
         Insere_Ligne (Creation
                         (I => Creation_Inst1
                            (Code_WSTR,
                             Creation_Op_Chaine
                               (Creation ("Erreur : tas plein")))));
         -- WNL
         Insere_Ligne (Creation (I => Creation_Inst0 (Code_WNL)));
         -- ERROR
         Insere_Ligne (Creation (I => Creation_Inst0 (Code_ERROR)));

         -- pile_pleine
         Ligne_Vide;
         Insere_Ligne (Creation (E => L_Etiq ("pile_pleine")));
         -- WSTR "Erreur : pile_pleine"
         Insere_Ligne (Creation
                         (I => Creation_Inst1
                            (Code_WSTR,
                             Creation_Op_Chaine
                               (Creation ("Erreur : pile pleine")))));
         -- WNL
         Insere_Ligne (Creation (I => Creation_Inst0 (Code_WNL)));
         -- ERROR
         Insere_Ligne (Creation (I => Creation_Inst0 (Code_ERROR)));

         -- dereferencement_null
         Ligne_Vide;
         Insere_Ligne (Creation (E => L_Etiq ("dereferencement_null")));
         -- WSTR "Erreur : dereferencemen de .null"
         Insere_Ligne (Creation
                         (I => Creation_Inst1
                            (Code_WSTR,
                             Creation_Op_Chaine
                               (Creation
                                  ("Erreur : dereferencement de null")))));
         -- WNL
         Insere_Ligne (Creation (I => Creation_Inst0 (Code_WNL)));
         -- ERROR
         Insere_Ligne (Creation (I => Creation_Inst0 (Code_ERROR)));
      end if;

      -- conversion_impossible
      Ligne_Vide;
      Insere_Ligne (Creation (E => L_Etiq ("conversion_impossible")));
      -- WSTR "Erreur : conversion impossible"
      Insere_Ligne (Creation
                      (I => Creation_Inst1
                         (Code_WSTR,
                          Creation_Op_Chaine
                            (Creation ("Erreur : conversion impossible")))));
      -- WNL
      Insere_Ligne (Creation (I => Creation_Inst0 (Code_WNL)));
      -- ERROR
      Insere_Ligne (Creation (I => Creation_Inst0 (Code_ERROR)));

   end Ecrire_Code_Erreur;


   ---------------------
   -- Assure_Registre --
   ---------------------

   function Assure_Registre (Op      : in Operande;
                             Scratch : in Boolean := False) return Operande is
      Res   : Operande;
   begin
      case Acces_Nature (Op) is
         when Op_Direct => return Op;
         when Op_Indirect =>
            declare
               Reg : Registre := Acces_Base (Op);
            begin
               case Reg is
                  when Utilisable =>
                     Res := Le_Registre (Reg);
                  when R0 | R1 =>
                     if Scratch then
                        Res := Le_Registre (Reg);
                     else
                        Res := Le_Registre (Allouer);
                     end if;
                  when others =>
                     if Scratch then
                        Res := Le_Registre (R1);
                     else
                        Res := Le_Registre (Allouer);
                     end if;
               end case;
            end;
         when others =>
            if Scratch then
               Res := Le_Registre (R1);
            else
               Res := Le_Registre (Allouer);
            end if;
      end case;

      -- LOAD "Place", "Reg"
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD, Op, Res)));
      return Res;
   end Assure_Registre;
end Gencode_Commun;
