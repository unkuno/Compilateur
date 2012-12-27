-------------------------------------------------------------------------------
--  Spécification du paquetage de gestion des classes (passe 1)
--
--  Auteur : gl16
--  Affiliation : Grenoble INP (Ensimag)
--
--  Historique :
--     16/01/12
--        - version initiale
-------------------------------------------------------------------------------


with Ada.Text_IO, Defns, Types_Base, Outils_Instructions, Pseudo_Code;
use  Ada.Text_IO, Defns, Types_Base, Outils_Instructions, Pseudo_Code;

with Decors, Verif_Commun, Symboles, Arbres, Tables;
use  Decors, Verif_Commun, Symboles, Arbres, Arbres.Listes_Arbres;

pragma Elaborate_All (Tables);

package body Gencode_Classes is
   
   -- Types pour définir le tableau des étiquettes
   type St_Tableau_Etiq is array (Positive range <>) of Etiq;
   type A_Tableau_Etiq is access St_Tableau_Etiq;

   -- Type pour définir le contenu du tableau
   type Tableau_Etiq is record
      Tableau       : A_Tableau_Etiq; -- Tableau des étiquettes
      Addr_Decalage : Operande;       -- Adresse de la table des méthodes
   end record;

   -- Type destiné à associer un Tableau_Etiq à chaque nom de classe
   package Tables_Tableau_Etiq is new Tables (Tableau_Etiq);
   use Tables_Tableau_Etiq;

   -- Variables globales
   Table_Tableaux_Etiq : Table := Creation (20); -- à revoir éventuellement
   Decalage   : Deplacement := 1; -- Déplacement actuel dans la pile
   Place_Pile : Entier := 0;      -- Taille totale occupée dans la pile


   ---------------------
   -- Mettre_Au_Point --
   ---------------------

   procedure Mettre_Au_Point (Niveau : in Positive; S : in String) is
      -- plus Niveau_Max est eleve, plus il y a d'affichage
      Niveau_Max : constant := 0;
   begin
      if Niveau <= Niveau_Max then
         Put_Line (Standard_Error, "Gencode (passe 1) : " & S);
      end if;
   end Mettre_Au_Point;


   --------------------------
   -- Ecrire_Classe_Object --
   --------------------------
   
   procedure Ecrire_Classe_Object is
      Info : Tableau_Etiq;
   begin
      Mettre_Au_Point (3, "entree de Ecrire_Classe_Object");

      -- Création du Tableau_Etiq
      Info.Addr_Decalage := Creation_Op_Indirect (Decalage, GB);

      Changer_Operande (Acces_Defn (Acces_Env_Types, Nom_Object),
			Info.Addr_Decalage);

      Decalage := Decalage + 2;
      Info.Tableau := new St_Tableau_Etiq (1 .. 1);
      Info.Tableau (1) := L_Etiq ("code.Object.equals");
      Inserer (Table_Tableaux_Etiq, Creation ("Object"), Info);

      Place_Pile := Place_Pile + 2;

      Ligne_Vide;
      Insere_Ligne (Creation (Com => "Table des méthodes de la classe Object"));

      -- LOAD #null, R0
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
                                                   L_Op_Null,
                                                   Le_Registre (R0))));
      -- STORE R0, 1(GB)
      Insere_Ligne (Creation
		      (I => Creation_Inst2 (Code_STORE,
					    Le_Registre (R0),
					    Creation_Op_Indirect (1, GB))));
      -- LOAD code.Object.equals, R0
      Insere_Ligne (Creation
		      (I => Creation_Inst2 (Code_LOAD,
					    Creation_Op_Etiq
					      (L_Etiq ("code.Object.equals")),
					    Le_Registre (R0))));
      -- STORE R0, 2(GB)
      Insere_Ligne (Creation
		      (I => Creation_Inst2 (Code_STORE,
					    Le_Registre (R0),
					    Creation_Op_Indirect (2, GB))));

   end Ecrire_Classe_Object;


   -----------------------
   -- Decorer_Parametre --
   -----------------------
   
   procedure Decorer_Parametre (A : in Arbre; Decalage : in Entier ) is
      Definition : Defn;
   begin
      Mettre_Au_Point (3, "entree de Decorer_Parametre");

      Definition := Acces_Defn (Acces_Decor (Acces_Fils_2 (A)));
      Changer_Operande (Definition, Creation_Op_Indirect (Decalage, LB));
      
      Mettre_Au_Point (3, "sortie de Decorer_Parametre");
   end Decorer_Parametre;
   
   
   --------------------------------
   -- Decorer_Parametres_Methode --
   --------------------------------
   
   procedure Decorer_Parametres_Methode (L : in Liste_Arbres) is
      Iter : constant Iterateur := Creation (L);
      Decalage_parametre : Deplacement := -3;
   begin
      Mettre_Au_Point (3, "entree de Decorer_Parametres_Methode");

      while not Fini (Iter) loop
         Decorer_Parametre(Suivant (Iter), Decalage_parametre);
         Decalage_parametre := Decalage_parametre - 1;
      end loop;
      
      Mettre_Au_Point (3, "sortie de Decorer_Parametres_Methode");
   end Decorer_Parametres_Methode;


   ----------------------
   -- Inserer_Methodes --
   ----------------------
   
   procedure Inserer_Methodes (Tab_Info   : in out A_Tableau_Etiq;
                               L          : in     Liste_Arbres;
			       Nom_Classe : in     Chaine) is
      Iter : constant Iterateur := Creation (L);
      Definition : Defn;
      Noeud_Courant : Arbre;
   begin

      Mettre_Au_Point (3, "entree de Inserer_Methodes");

      -- Parcours de tous les noeuds
      while not Fini (Iter) loop
         Noeud_Courant := (Suivant (Iter));
         if (Acces_Noeud (Noeud_Courant) = Noeud_Methode) then
            Definition := Acces_Defn (Acces_Decor (Acces_Fils_2
						     (Noeud_Courant)));
            Tab_Info (Acces_Numero (Definition)) :=
              L_Etiq("code." & Acces_String (Nom_Classe) & "."
                       & Acces_String (Acces_nom (Acces_Fils_2
						    (Noeud_Courant))));
            -- Ajout du décor sur le décalage de la méthode
            Decorer_Parametres_Methode (Acces_Fille_3 (Noeud_Courant));
         end if;
      end loop;

   end Inserer_Methodes;


   ---------------------
   -- Copier_Methodes --
   ---------------------
   
   -- Copie toutes les méthodes de Info_Extends vers Info
   procedure Copier_Methodes (Tab_Info    : in out A_Tableau_Etiq;
			      Tab_Extends : in     A_Tableau_Etiq) is
   begin
      Mettre_Au_Point (3, "entree de Copier_Methodes");

      for I in Tab_Extends'First .. Tab_Extends'Last loop
         Tab_Info (I) := Tab_Extends (I);
      end loop;

      Mettre_Au_Point (3, "sortie de Copier_Methodes");
   end Copier_Methodes;


   ------------------------
   -- Creer_Tableau_Etiq --
   ------------------------
   
   procedure Creer_Tableau_Etiq (A            : in     Arbre;
                                 Nom          :    out Chaine;
                                 S_Tab        :    out Tableau_Etiq;
                                 Addr_Extends :    out Operande) is

      Info, Info_Extends : Tableau_Etiq;
      Definition : Defn;
      Present : Boolean;

   begin
      Mettre_Au_Point (3, "entree de Creer_Tableau_Etiq");

      -- Par défaut, chaque classe extends Object (d'adresse 1(GB))
      Addr_Extends := Creation_Op_Indirect (1, GB);
      
      -- Création du tableau_Etiq
      Info.Addr_Decalage := Creation_Op_Indirect (Decalage, GB);

      Nom := Acces_Nom (Acces_Fils_1 (A));

      Definition := Acces_Defn (Acces_Decor (Acces_Fils_1 (A)));
      -- Décoration de la classe sur l'opérande de l'adresse de décalage
      Changer_Operande (Definition, Info.Addr_Decalage);
      Info.Tableau := new St_Tableau_Etiq (1 .. Acces_Nombre_Methodes
					     (Definition));

      Place_Pile :=
	Place_Pile + Entier (Acces_Nombre_Methodes (Definition)) + 1;

      -- Mise à jour du décalage pour la prochaine classe
      Decalage :=
	Decalage + Deplacement(Acces_Nombre_Methodes (Definition) + 1);
      
      -- Ajout des méthodes de la super classe
      Chercher (Table_Tableaux_Etiq, Acces_Extension (Definition),
		Present, Info_Extends);
      if (Present) then
         Addr_Extends := Info_Extends.Addr_Decalage;
         Copier_Methodes (Info.Tableau, Info_Extends.Tableau);
      end if;

      -- Ajout des méthodes de la classe courante
      Inserer_Methodes (Info.Tableau, Acces_Fille_3 (A),
			Acces_Nom (Acces_Fils_1 (A)));

      Inserer (Table_Tableaux_Etiq, Acces_Nom (Acces_Fils_1 (A)), Info);

      -- Affectation du pointeur sur le tableau des etiquettes
      S_Tab := Info;
      
      Mettre_Au_Point (3, "sortie de Creer_Tableau_Etiq");
   end Creer_Tableau_Etiq;


   -------------------------
   -- Creer_Table_Methode --
   -------------------------
   
   procedure Creer_Table_Methode (Nom          : in Chaine;
                                  S_Tab        : in Tableau_Etiq;
                                  Addr_Extends : in Operande) is
      
      Decalage : Deplacement := Acces_Deplacement (S_Tab.Addr_Decalage);
   begin
      Mettre_Au_Point (3, "entree de Creer_Table_Methode");

      Ligne_Vide;
      Insere_Ligne (Creation (Com => "Table des méthode de la classe "
                                & Acces_String (Nom)));
      -- LOAD Addr_Extends, R0
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_LEA,
                                                   Addr_Extends,
                                                   Le_Registre (R0))));
      -- STORE R0, Decalage.(GB)
      Insere_Ligne (Creation (I => Creation_Inst2 (Code_STORE,
						   Le_Registre (R0),
						   Creation_Op_Indirect
						     (Decalage, GB))));

      for I in S_Tab.Tableau'First .. S_Tab.Tableau'Last loop
         -- LOAD code.classe.methode, R0
         Insere_Ligne (Creation (I => Creation_Inst2 (Code_LOAD,
                                                      Creation_Op_Etiq
							(S_Tab.Tableau (I)),
                                                      Le_Registre (R0))));
         -- STORE R0, I+Decalage(GB)
         Insere_Ligne (Creation
			 (I => Creation_Inst2 (Code_STORE,
					       Le_Registre (R0),
					       Creation_Op_Indirect
						 (Deplacement (I) + Decalage,
						  GB))));
      end loop;

      Mettre_Au_Point (3, "sortie de Creer_Table_Methode");
   end Creer_Table_Methode;


   -------------------
   -- Ecrire_Classe --
   -------------------
   
   procedure Ecrire_Classe (A : in Arbre) is
      Nom : Chaine;
      S_Tab : Tableau_Etiq;
      Addr_Extends : Operande;
   begin
      Mettre_Au_Point (3, "entree de Ecrire_Classe");
      Creer_Tableau_Etiq (A, Nom, S_Tab, Addr_Extends);
      Creer_Table_Methode (Nom, S_Tab, Addr_Extends);
      Mettre_Au_Point (3, "sortie de Ecrire_Classe");
   end Ecrire_Classe;


   --------------------------
   -- Ecrire_Liste_Classes --
   --------------------------
   
   function Ecrire_Liste_Classes (L : in Liste_Arbres) return Entier is
      Iter : constant Iterateur := Creation (L);
   begin
      Mettre_Au_Point (3, "entree de Ecrire_Liste_Classes");

      -- Création de la table des méthodes
      Ligne_Vide;
      Ecrire_Cadre ("Creation des tables des methodes");

      Ecrire_Classe_Object;
      while not Fini (Iter) loop
         Ecrire_Classe (Suivant (Iter));
      end loop;

      return Place_Pile;
   end Ecrire_Liste_Classes;

end Gencode_Classes;
