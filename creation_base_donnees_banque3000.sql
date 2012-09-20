
/* Creation de la table "client" */
create table Client(id_Client int(3) PRIMARY KEY,
		    nom_client varchar2(20),
		    date_inscription datetime,
		    activite varchar2(10));

/* Creation de la sequence qui definira les id_client */
create SEQUENCE seq_id_client;

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table compte */
create table Compte(id_compte int(5) PRIMARY KEY,
		    id_client int(3) REFERENCES Client(id_client), 		/* Client proprietaire du compte */
		    etat_compte int(1),				 		/* 0 : Compte bloque; 1 : Compte actif */ 
	            councours_autorise real,					/* decouvert max possible pour un compte */
		    solde_compte real check >=-1.0*concours_autorise);		/* Une somme d'argent est un nombre reel positif, le solde peut etre negatif */    
		    code_secret varchar2);					/* Le code secret est un nombre a 4 chiffres, hache en md5 */

/* Creation de la sequence qui definira les id_compte */
create SEQUENCE seq_id_compte;

/* Creation de la table compte courant */
create table Compte_courant(id_compte int(5) REFERENCES Compte(id_compte));  
		    

/* Creation de la table compte epargne */ 
create table Compte_epargne(id_compte int(5) REFERENCES Compte(id_compte),
			    taux_d_epargne decimal(2,2),                                /* Pourcentage a reverser a la prochaine echeance */
		            prochaine_echeance datetime());

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "transaction" */
create table Transaction(id_transaction int PRIMARY KEY,
			 id_compte_debiteur int, 
			 banque_compte_debiteur varchar(10), /* Le nom de la banque du compte debiteur. NB : Il existe 2 banques dans l'environnement, leurs noms sont uniques */ 
			 id_compte_crediteur int,
			 banque_compte_crediteur, varchar(10), /* Le nom de la banque du compte crediteur. NB : Il existe 2 banques dans l'environnement, leurs noms sont uniques */ 
                         montant real, /* montant de la transaction */
			 status int(1)); /* vaut 1 si la transation a reussi, 0 sinon */
			 
/* Creation de la sequence qui definira les id_transac */
create SEQUENCE seq_id_transac;

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "creance_en_cours" */

create table creance_en_cours(id_creance_en_cours int(5) PRIMARY KEY,
			      taux_interet decimal(0,2),     /* Taux d'interet sur la creance octroyee */
			      prochaine_echeance datetime,   /* Prochaine echeance pour le prochain prelevement sur le compte courant */
			      creance_restante real);        /* Montant de du restant */        


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "decouvert_en_cours" */

create table decouvert_en_cours(id_decouvert_en_cours int(5) PRIMARY KEY,
			      penalites_journalieres decimal(0,2),     /* Penalites journaliere sur le decouvert */
			      date_butoire datetime);                  /* Prochaine echeance pour le bloquage du compte courant */        


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "ct_deja_concours" */
/* On garde les comptes ayant deja eu recourt au decouvert */
create table ct_deja_concours(id_compte int(5) REFERENCES compte_courant(id_compte),
				date_dernier_concours datetime);

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "ct_deja_bloque" */
/* On garde les ctes ayant deja ete bloques */
create table ct_deja_bloque(id_compte int(5) REFERENCES compte(id_compte),
				date_dernier_bloquage datetime);


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "suivi_solde_compte" */
/* Permet de dresser un historique des soldes d'un compte */

create table suivi_solde_compte(id_compte int(5) REFERENCES compte_courant(id_compte),
		                nouveau_solde real, /* Le solde du compte */ 
				moment_solde datetime); /* Pour savoir a quel moment le nouveau solde a eu lieu */


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "compte_web_client" */
/* Permettra au client de gerer ses comptes via la plateforme web */

create table compte_web_client();

