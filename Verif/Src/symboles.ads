-------------------------------------------------------------------------------
--  Spécification du paquetage Symbole
--
--  Auteur : un enseignant du projet GL
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     01/01/2012
--        - version initiale
-------------------------------------------------------------------------------

-- Ce paquetage gère une table des symboles, qui consiste en deux
-- environnements, Env_Types et Env_Exp.

with Types_Base, Defns;
use  Types_Base, Defns;

package Symboles is

   -- Initialise l'environnement (avec l'environnement prédéfini)
   procedure Initialiser_Symb;

   -- Accès à l'environnement des types
   function Acces_Env_Types return Environ;

   -- Accès à l'environnement des expressions de la classe Object
   function Acces_Env_Exp_Object return Environ;

   -- Ajoute l'association (Nom -> Def) dans l'environnement Env
   -- Précondition : Env /= null
   procedure Ajouter (Env : in Environ; Nom : in Chaine; Def : in Defn;
                      Present : out Boolean);

   -- Renvoie la définition associée à nom, null si aucune définition
   -- associée à nom n'est présente dans l'environnement Env
   function Acces_Defn(Env : Environ; Nom : Chaine) return Defn;

   -- Exception levée si une précondition n'est pas vérifiée
   Erreur_Symboles : exception;

end Symboles;
