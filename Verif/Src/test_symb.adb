-------------------------------------------------------------------------------
--  Procédure de test du paquetage Symboles
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

-- activer les assertions
pragma Assertion_Policy(Check);

with Ada.Text_IO, Defns, Types_Base, Verif_Commun;
use  Ada.Text_IO, Defns, Types_Base, Verif_Commun;

with Symboles;
use  Symboles;

procedure Test_Symb is
   Env_Test : Environ;
   Nom : Chaine := Creation ("equals");
   Present : Boolean;
begin
   Initialiser_Symb;

   -- Assert(Check, Message) est équivalent à :
   --
   -- if Check = false then
   --    raise Ada.Assertions.Assertion_Error with Message;
   -- end if;
   pragma Assert(Acces_Defn(Acces_Env_Exp_Object,
                            Creation("equals")) /= null,
                 "equals n'est pas défini dans env_exp_object");
   
   -- Affichage des environnements prédéfinis
   Put_Line ("Env_Types :");
   Afficher (Acces_Env_Types);
   New_Line;
   Put_Line ("Env_Exp_Object :"); 
   Afficher (Acces_Env_Exp_Object);
   New_Line;
   
   -- Création d'un environnement de test
   Put_Line ("Création d'un evironnement vide");
   Env_Test := Creation (Creation, null);
   Put ("Ajout d'une classe nommée ""equals""");
   Ajouter (Env_Test, Nom, Creation_Classe (Nom), Present);
   Put_Line (" => Present = " & Boolean'Image (Present));
   Put ("Ajout d'une autre classe nommée ""equals""");
   Ajouter (Env_Test, Nom, Creation_Classe (Nom), Present);
   Put_Line (" => Present = " & Boolean'Image (Present));
   Put_Line ("Env_Test :");
   Afficher (Env_Test);
   New_Line;
   
   -- Utilisation des opérations
   Put_Line ("Acces à ""equals"" dans ""Env_Exp_Object"" :");
   Afficher (Acces_Defn (Acces_Env_Exp_Object, Nom));
   New_Line;
   
   Put_Line ("Epilement de ""Env_Test"" sur ""Env_Exp_Object"" :");
   Changer_Reste (Env_Test, Acces_Env_Exp_Object);
   Afficher (Env_Test);
   New_Line;
   
   Put_Line ("Acces à ""equals"" dans le nouvel environnement ""Env_Test"" :");
   Afficher (Acces_Defn (Env_Test, Nom));
   New_Line;
end Test_Symb;
