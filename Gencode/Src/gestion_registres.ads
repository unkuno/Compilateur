-------------------------------------------------------------------------------
--  Spécification du paquetage de gestion des registres non-scratch.
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     12/01/12
--        - version initiale
-------------------------------------------------------------------------------


with Pseudo_Code, Types_Base;
use  Pseudo_Code, Types_Base;

-- Ce paquetage permet d'allouer et de libérer des registres sans se préoccuper
-- du nombre de registres réellement disponibles. Lorsque tous les registres
-- sont utilisés, le gestionnaire peut sauvegarder d'anciennes valeurs pour
-- en libérer un. Il est également responsable de la restauration de ces valeurs
-- lorsque cela est nécessaire.
-- Pour des questions d'optimisation, les valeurs sauvegardées ne sont pas
-- immédiatement restaurées lorsqu'un registre est libéré.
-- Lorsqu'il est nécessaire d'effectuer d'autres opérations sur la pile, il est
-- possible de forcer le gestionnaire à restaurer ces valeurs pour "nettoyer" la
-- pile.
package Gestion_Registres is

   -- Types des registres non-scratch.
   subtype Utilisable is Banalise range R2 .. R15;

   -- Initialise l'utilisation des registres.
   -- "Nb_Total_Reg" correspond au nombre total de registres utilisables par le
   -- gestionnaire.
   -- Précondition : Nb_Total_Reg >= 4.
   -- Remarque : le gestionnaire ne travaille qu'avec les registres non-scratch,
   -- soit ("Nb_Total_Reg" - 2) registres.
   procedure Initialiser_Registres (Nb_Total_Reg : in Entier);

   -- Récupère un registre utilisable (en sauvegardant éventuellement un autre
   -- registre dans la pile).
   -- Seul le registre retourné et le dernier registre alloué peuvent être
   -- utilisés jusqu'au prochain appel à "Liberer".
   function Allouer return Utilisable;

   -- Rend le registre "Reg" au gestionnaire et restaure éventuellement une
   -- valeur stockée dans la pile.
   -- Ce registre doit être le plus récent des registres actuellement alloués
   -- (et non libérés).
   procedure Liberer (Reg : in Utilisable);

   -- Si "Op" est un registre utilisable (ou une opérande utilisant un registre
   -- utilisable), rend "Op" au gestionnaire et restaure éventuellement une
   -- valeur stockée dans la pile.
   -- Sinon, ne fait rien.
   procedure Liberer (Op : in Operande);

   -- Supprimer les données "sales" stockées dans la pile.
   procedure Purger;

   -- Réinitialise le gestionnaire de registres.
   procedure Reinitialiser_Registres;

   -- Ecrit le code responsable de sauvegarder et de restaurer l'ensemble des
   -- registres utilisés depuis la dernière initialisation du gestionnaire.
   function Sauvegarder_Registres return Entier;

end Gestion_Registres;

