drop table client CASCADE CONSTRAINTS;
drop table compte CASCADE CONSTRAINTS;
drop table compte_epargne CASCADE CONSTRAINTS;
drop table compte_courant CASCADE CONSTRAINTS;
drop table transaction CASCADE CONSTRAINTS;
drop table creance_en_cours CASCADE CONSTRAINTS;
drop table decouvert_en_cours CASCADE CONSTRAINTS;
drop table ct_deja_concours CASCADE CONSTRAINTS;
drop table ct_deja_bloque CASCADE CONSTRAINTS;
drop table suivi_solde_compte CASCADE CONSTRAINTS;
drop table compte_web_client CASCADE CONSTRAINTS;
-------------------------------------------------
drop SEQUENCE seq_id_compte;
drop SEQUENCE seq_id_transac;
drop SEQUENCE seq_id_client;
-------------------------------------------------
/* Creation de la table "client" */
/* Pour garantir qu'un client s'inscrive qu'une seule fois l'id retenu est le login Oracle*/
create table Client(id_client varchar2(10) PRIMARY KEY, nom_client varchar2(20),date_inscription date,activite varchar2(10));

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table compte */
/* id_client : Client proprietaire du compte */
/* etat_compte, 0 : Compte bloque; 1 : Compte actif */
/* councours_autorise decouvert max possible pour un compte */
/* solde_compte : Une somme d'argent est un nombre reel positif, le solde peut etre negatif */
/* code_secret : Le code secret est un nombre a 4 chiffres, hache en md5 */
create table Compte(id_compte number(5) PRIMARY KEY,
id_client varchar2(12) REFERENCES Client(id_client),
etat_compte number(1),
concours_autorise number(7,2),
solde_compte number(7,2),code_secret varchar2(50),
date_creation date,
constraint ch_sc check (solde_compte>=-1.0*concours_autorise));					

/* Creation de la sequence qui definira les id_compte */
create SEQUENCE seq_id_compte;

/* Creation de la table compte courant */
create table Compte_courant(id_client varchar2(12) UNIQUE,id_compte number(5) REFERENCES Compte(id_compte));  
		    

/* Creation de la table compte epargne */ 
/* Pourcentage a reverser a la prochaine echeance à diviser par 100*/
create table Compte_epargne(id_compte number(5) REFERENCES Compte(id_compte),taux_d_epargne int,prochaine_echeance date);

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "transaction" */
/* Le nom de la banque du compte debiteur. NB : Il existe 2 banques dans l'environnement, leurs noms sont uniques */
/* Le nom de la banque du compte crediteur. NB : Il existe 2 banques dans l'environnement, leurs noms sont uniques */ 
/* montant de la transaction */
/* vaut 1 si la transation a reussi, 0 sinon */
create table Transaction(id_transaction int PRIMARY KEY,id_compte_debiteur int,banque_compte_debiteur varchar(10),id_compte_crediteur int,banque_compte_crediteur varchar(10),montant number(7,2),status number(1));
			 
/* Creation de la sequence qui definira les id_transac */
create SEQUENCE seq_id_transac;

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "creance_en_cours" */
/* Taux d'interet sur la creance octroyee */
/* Prochaine echeance pour le prochain prelevement sur le compte courant */
/* Montant de du restant */
create table creance_en_cours(id_creance_en_cours number(5) PRIMARY KEY,taux_interet int,prochaine_echeance date,creance_restante number(7,2));   


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "decouvert_en_cours" */
/* Penalites journaliere sur le decouvert */
/* Prochaine echeance pour le bloquage du compte courant */
create table decouvert_en_cours(id_decouvert_en_cours number(5) PRIMARY KEY,penalites_journalieres int,date_butoire date);              


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "ct_deja_concours" */
/* On garde les comptes ayant deja eu recourt au decouvert */
create table ct_deja_concours(id_compte number(5) REFERENCES compte(id_compte),date_dernier_concours date);

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "ct_deja_bloque" */
/* On garde les ctes ayant deja ete bloques */
create table ct_deja_bloque(id_compte number(5) REFERENCES compte(id_compte),date_dernier_bloquage date);


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "suivi_solde_compte" */
/* Permet de dresser un historique des soldes d'un compte */
/* Le solde du compte */
/* Pour savoir a quel moment le nouveau solde a eu lieu */
create table suivi_solde_compte(id_compte number(5) REFERENCES compte(id_compte),nouveau_solde number(7,2),moment_solde date); 

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "compte_web_client" */
/* Permettra au client de gerer ses comptes via la plateforme web */
create table compte_web_client(id_compte number PRIMARY KEY, id_client varchar2(10) REFERENCES client(id_client), mail_client varchar2(50), mot_de_passe varchar);

