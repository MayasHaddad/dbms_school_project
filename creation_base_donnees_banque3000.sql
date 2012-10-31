/* Binome : Haddad Mayas - Hocini Merwan */

/* La base de donnees suivante implemente le cahier des charges partiel suivant :
	-Un client s'inscris chez nous grace à son login oracle, il ne peut s'inscrire qu'une seule fois. 
	-Il ne peut etre proprietaire que d'un seul compte courant (par protocole), mais de plusieurs comptes epargne
	-Les comptes epargne et courants sont des comptes bancaires, mais chacun se specialise. Par exemple : compte epargne doit 
	reverser un interet a son proprietaire, a diverses echeances.
	-Une transaction doit pouvoir etre retracee en cas de litige, celle-ci doit permettre de retrouver les acteur de la transac.
	-La banque peut accorder des credits a ses clients a des taux variables.	
	-On doit savoir qui est a decouvert pour prelever des penalites.
	-Il est tres utile de savoir quels comptes et clients ayant ete a decouvert (afin de definir l'interet sur un pret eventuel),
	pire pour les comptes ayant ete deja bloques.
	-Les differentes valeurs du solde d'un compte a travers le temps doivent etre sauvgardees pour des services stastiques au client.
	-Un client se voit ouvrir un compte web pour la gestion de son compte courant et de son/ses compte(s) epargne.
*/
drop table client CASCADE CONSTRAINTS;
drop table compte CASCADE CONSTRAINTS;
drop table transaction CASCADE CONSTRAINTS;
drop table id_cci_login_oracle CASCADE CONSTRAINTS;
-------------------------------------------------
drop SEQUENCE seq_id_compte;
drop SEQUENCE seq_id_transac;
-------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
-- Creation des tables
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "client" */
/* Pour garantir qu'un client s'inscrive qu'une seule fois l'id retenu est le login Oracle*/
create table Client(id_client varchar2(10) PRIMARY KEY,date_inscription date);

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table compte */
/* id_client : Client proprietaire du compte */
/* etat_compte, 0 : Compte bloque; 1 : Compte actif */
/* councours_autorise decouvert max possible pour un compte */
/* solde_compte : Une somme d'argent est un nombre reel positif, le solde peut etre negatif */
/* code_secret : Le code secret est un nombre a 4 chiffres, hache en md5 */
create table Compte(id_compte number(5) PRIMARY KEY,
id_client varchar2(10) REFERENCES Client(id_client),
solde_compte number(7,2),code_secret varchar2(50),
date_creation date);

/* Creation de la sequence qui definira les id_compte */
create SEQUENCE seq_id_compte;
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "transaction" */
/* Le nom de la banque du compte debiteur. NB : Il existe 2 banques dans l'environnement, leurs noms sont uniques */
/* Le nom de la banque du compte crediteur. NB : Il existe 2 banques dans l'environnement, leurs noms sont uniques */ 
/* montant de la transaction */
/* vaut 1 si la transation a reussi, 0 sinon */
create table Transaction(id_transaction int PRIMARY KEY,idCci_debiteur number, idCci_crediteur number,montant number(7,2),moment date);
			 
/* Creation de la sequence qui definira les id_transac */
create SEQUENCE seq_id_transac;


/* Creation de la table qui permettra de relier le siret d'un client a son login oracle */
create table id_cci_login_oracle(login_oracle varchar2(10) REFERENCES client(id_client), id_client_cci number UNIQUE);

-------------------------------------------------------------------------------------------------------------------------------
-- Creation des vues 
-------------------------------------------------------------------------------------------------------------------------------

/* Par convention tous les noms de vues ont le prefixe "vue_" */

/* Creation de la vue client */
create view vue_client 
as
select * from client; 


/*************************************** COUCHE APPLICATION ***************************************/
------------------------------------------------------------
-- Package des procedures et fonctions accessibles qu'a nous
------------------------------------------------------------
create or replace package private as
function isAuth(idCci in id_cci_login_oracle.id_client_cci%type) return boolean;
function getIdcFrmIdcte(idCompte in compte)
end private;
/

/* Corps du package private */
create or replace package body private as 

--Corps procedure ouvrirCompte(idCci)
function isAuth(idCci in id_cci_login_oracle.id_client_cci%type) return boolean is 
usr_login varchar2(10);
b boolean;
cursor c is select login_oracle from id_cci_login_oracle where id_client_cci = idCci;
begin
 b:=false;
 select user into usr_login from dual;
 for x in c loop
  if x.login_oracle = usr_login then 
   b:=true;
   exit when c%notfound;
  end if;
 end loop;
 return b;
end isAuth;
end private;
/

create or replace function get_login(idCci in id_cci_login_oracle.id_client_cci%type) return client.id_client%type is
login id_cci_login_oracle.login_oracle%type;
begin 
select login_oracle into login from id_cci_login_oracle where id_client_cci=idCci;
return login; 
end;
/



-------------------------------------------------------------------
-- Procedures et fonctions accessibles a tous les users
-------------------------------------------------------------------

create or replace procedure grantAllUsers is
cursor c is select user_name from users_tab;
begin
for x in c loop
execute immediate 'grant execute on ouvertureCompte to '||x.user_name; 
end loop;
end;
/ 

grant execute on ouvertureCompte to sbazin10_a;

create or replace procedure ouvertureCompte(idCci in id_cci_login_oracle.id_client_cci%type) is 
usr_login varchar2(10);
begin
select user into usr_login from dual;
if private.isAuth(idCci)=false then
insert into client(id_client) values (usr_login);
insert into id_cci_login_oracle(login_oracle,id_client_cci) values (usr_login,idCci);
insert into compte(id_compte,id_client,solde_compte) values (seq_id_compte.nextval,usr_login,2000);
execute immediate 'grant execute on consultationCompte to '||usr_login;
execute immediate 'grant execute on consultationSolde to '|| usr_login;
end if;
end;
/

create or replace procedure inscriptionCci(loginCci in client.id_client%type) is
siret id_cci_login_oracle.id_client_cci%type;
text varchar2(250);
nomBanque varchar2(10);
myLogin varchar2(10);
begin
nomBanque:='Banque3000';
myLogin:='mhadda1_a';
text :='call '||loginCci||'.inscriptionBanqueCci(:1,:2,:3)';
execute immediate text using in nomBanque, in myLogin, out siret;
end;
/
execute inscriptionCci('rkeophi_a');
-----------------------------------------------------------------
-- Package des procedures et fonctions accessibles qu'aux clients
-----------------------------------------------------------------
/* En tete du package clients */
--Corps procedure consultationCompte
create or replace procedure consultationCompte(idCci in id_cci_login_oracle.id_client_cci%type) is
begin
if isAuth(idCci) then
select idCci_debiteur,idCci_crediteur,montant,into moment idcc,idcd,m,t from transaction where idCci_debiteur = idCci OR idCci_crediteur = idCci
end;
/

--Corps procedure consultation solde
create or replace procedure consultationSolde(idCci in id_cci_login_oracle.id_client_cci%type) is 
s compte.solde_compte%type;
begin
select solde_compte into s from compte where id_client=get_login(idCci);
dbms_output.put_line('votre solde est de :'||s||' Euros');
end;
/
