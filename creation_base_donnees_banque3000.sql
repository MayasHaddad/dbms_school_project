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
drop table login_cci CASCADE CONSTRAINTS;
drop table my_siret CASCADE CONSTRAINTS;
-------------------------------------------------
drop SEQUENCE seq_id_compte;
drop SEQUENCE seq_id_transac;
-------------------------------------------------
drop function getCurrentLogin;
drop function getSirLogin;
drop function getLoginSiret;
drop function isAuth;
drop function getLoginCci;
drop function getTimestamp;
drop function getSiretBanque;
drop function consultationSolde
consultationCompte;
drop procedure vire;
drop procedure paie;
drop procedure ouvertureCompte;
drop procedure inscriptionCci;


-------------------------------------------------------------------------------------------------------------------------------
-- Creation des tables
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "client" */
/* Pour garantir qu'un client s'inscrive qu'une seule fois l'id retenu est le login Oracle*/
create table Client(id_client varchar2(10) PRIMARY KEY,date_inscription timestamp);

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table compte */
/* id_client : Client proprietaire du compte */
/* solde_compte : Une somme d'argent est un nombre reel positif, le solde peut etre negatif */
create table Compte(id_client varchar2(10) REFERENCES Client(id_client) ON DELETE CASCADE,
solde_compte float,
date_creation timestamp);

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/* Creation de la table "transaction" */
/* Le siret compte debiteur (Vendeur). */
/* Le nom de la banque du compte crediteur(Acheteur). */ 
/* montant de la transaction */
create table Transaction(id_transaction int PRIMARY KEY,idCci_debiteur number, idCci_crediteur number,montant float,moment timestamp);
			 
/* Creation de la table qui permettra de relier le siret d'un client a son login oracle */
create table id_cci_login_oracle(login_oracle varchar2(10) REFERENCES client(id_client) ON DELETE CASCADE, id_client_cci number UNIQUE);

/* Creation de la table qui abritera notre siret */
create table my_siret(mon_siret number UNIQUE);

/* Creation de la table qui abritera le login de la cci */
create table login_cci(login varchar2(10) UNIQUE);


/* Creation de la sequence qui definira les id_transac */
create SEQUENCE seq_id_transac;

-------------------------------------------------------------------------------------------------------------------------------
-- Creation des vues 
-------------------------------------------------------------------------------------------------------------------------------

/* Par convention tous les noms de vues ont le prefixe "vue_" */

/* Creation de la vue client */
create view vue_client 
as
select * from client; 

create view vue_compte 
as
select id_client i, solde_compte s from compte;
 
/*************************************** COUCHE APPLICATION ***************************************/
------------------------------------------------------------
-- Procedures et fonctions accessibles qu'a nous
------------------------------------------------------------

-- Recupere le login de l'utilisateur courant
create or replace function getCurrentLogin return client.id_client%type is
currentLogin client.id_client%type;
begin
	select user into currentLogin from dual;
	return currentLogin;
end;
/

-- Retourne le login correspondant au siret 
create or replace function getSirLogin(idCci in id_cci_login_oracle.id_client_cci%type) return client.id_client%type is
login client.id_client%type;
begin 
	select login_oracle into login from id_cci_login_oracle where id_client_cci=idCci;
	return login; 
end;
/

-- Retourne le siret correspondant au login
create or replace function getLoginSiret(login in client.id_client%type) return id_cci_login_oracle.id_client_cci%type is
siret id_cci_login_oracle.id_client_cci%type;
begin 
	select id_client_cci into siret from id_cci_login_oracle where login_oracle = login;
	return siret;
end;
/

-- Rend vrai si le siret fourni est bien celui du login courant
create or replace function isAuth(idCci in id_cci_login_oracle.id_client_cci%type) return boolean is 
usrLogin id_cci_login_oracle.login_oracle%type;
b boolean;
cursor c is select login_oracle from id_cci_login_oracle where id_client_cci = idCci;
begin
	b:=false;
	usrLogin:=getCurrentLogin;
	for x in c loop
		if x.login_oracle = usrLogin then 
   			b:=true;
   			exit when c%notfound;
  		end if;
 	end loop;
	return b;
end;
/

-- Inscris ma banque a la cci
create or replace procedure inscriptionCci(loginCci in client.id_client%type,nomBanque in varchar2, myLogin varchar) is
siret id_cci_login_oracle.id_client_cci%type;
text varchar2(250);
begin
	text :='call '||loginCci||'.inscriptionBanqueCci(:1,:2,:3)';
	execute immediate text using in nomBanque, in myLogin, out siret;
	insert into my_siret(mon_siret) values (siret);
	insert into login_cci(login) values (loginCci);
end;
/


-- Fonction qui retourne le login de la cci 
create or replace function getLoginCci return client.id_client%type is
loginCci client.id_client%type;
begin
	select login into loginCci from login_cci;
	return loginCCi;
end;
/

create or replace function getTimestamp return timestamp is
t timestamp;
begin
	Select LOCALTIMESTAMP into t from dual;
	return t;
end;
/
-------------------------------------------------------------------
-- Procedures et fonctions accessibles a tous les users
-------------------------------------------------------------------

-- A appeler pour ouvrir un compte chez nous
create or replace procedure ouvertureCompte(idCci in id_cci_login_oracle.id_client_cci%type) is 
usrLogin varchar2(20);
e exception;
pragma exception_init(e,-01749);
begin
	usrLogin:=getCurrentLogin;
	if isAuth(idCci)=false then
		insert into client(id_client,date_inscription) values (usrLogin,getTimestamp);
		insert into id_cci_login_oracle(login_oracle,id_client_cci) values (usrLogin,idCci);
		insert into compte(id_client,solde_compte,date_creation) values (usrLogin,1000,getTimestamp);
		execute immediate 'grant execute on consultationCompte to '||usrLogin;
		execute immediate 'grant execute on consultationSolde to '|| usrLogin;
		execute immediate 'grant execute on paie to '|| usrLogin;
	end if;
	exception -- Lorsqu'on s'inscris chez nous, le grant génère une exception, on l'a rattrape pour po faire de grimace :)
		when e then NULL;
		when others then NULL;
end;
/

-- Retourne le siret de ma banque 
create or replace function getSiretBanque return id_cci_login_oracle.id_client_cci%type is
SiretBanque id_cci_login_oracle.id_client_cci%type;
begin
	select mon_siret into siretBanque from my_siret;
	return siretBanque;
end;
/

-- Grant a tout le monde le droit d'executer
grant execute on ouvertureCompte to public;
grant execute on getSiretBanque to public;

-----------------------------------------------------------------
-- Procedures et fonctions accessibles qu'aux clients
-----------------------------------------------------------------
/* En tete du package clients */
--Corps procedure consultationCompte
create or replace procedure consultationCompte(idCci in id_cci_login_oracle.id_client_cci%type) is
cursor c is select idCci_debiteur,idCci_crediteur,montant,moment from transaction where idCci_debiteur = idCci OR idCci_crediteur = idCci;
begin
	if isAuth(idCci) then
		dbms_output.put_line('Debiteur|Crediteur|Montant|Date');
		for x in c loop
			dbms_output.put_line(x.idCci_debiteur||' '||x.idCci_crediteur||' '||x.montant||' '||x.moment);
		end loop;
	end if;
end;
/

--Corps function consultation solde
create or replace function consultationSolde(idCci in id_cci_login_oracle.id_client_cci%type) return float is 
s compte.solde_compte%type;
begin
	if isAuth(idCci) then
		select solde_compte into s from compte where id_client=getSirLogin(idCci);
	else 
		RAISE_APPLICATION_ERROR('-20003','Ce n est pas ton compte !');
	end if;
	return s;
end;
/

-- Procedure qui debite un compte
create or replace procedure vire(siretCrediteur in id_cci_login_oracle.id_client_cci%type,somme in number) is
begin
	update compte set solde_compte = solde_compte-somme where id_client= getSirLogin(siretCrediteur);
end;
/


-- Procedure pour crediter un compte
create or replace procedure paie(siretCrediteur in id_cci_login_oracle.id_client_cci%type,siretBnqCrediteuse in id_cci_login_oracle.id_client_cci%type,siretVendeur in id_cci_login_oracle.id_client_cci%type,somme in float) is
loginBanqueCrediteuse client.id_client%type;
begin 
	if siretBnqCrediteuse=getSiretBanque then -- Le crediteur (acheteur) est aussi notre client
		vire(siretCrediteur,somme);
		insert into transaction(id_transaction,idCci_debiteur,idCci_crediteur,montant,moment) values (seq_id_transac.nextval,getLoginSiret(getCurrentLogin),siretCrediteur,somme,getTimestamp);
	else -- Le crediteur (acheteur) n'est pas notre client
		execute immediate loginBanqueCrediteuse||'.vire('||siretCrediteur||','||somme||')';
	end if;
	update compte set solde_compte=solde_compte+somme where id_client=getSirLogin(siretVendeur);
end;
/
/*
-- Trigger pour le prelevement des frais d'inscription a la cci
create or replace trigger prelevementFraisCci after insert on client 
begin
	if :new.id_client<>getLoginCci then -- On ne preleve pas les frais sur la cci
		paie(getLoginSiret(:new.id_client),getSiretBanque,getLoginSiret(getLoginCci),100);
end;
/

-- Trigger pour le prelevement de la taxe de la cci
create or replace trigger prelevementTaxeCci after update on compte 
begin
	if (:new.id_client<>getLoginCci and :new.solde_compte>:old.solde_compte) then -- On ne preleve pas de taxe sur la cci et on preleve sur le 											      -- debiteur 
		paie(getLoginSiret(:new.id_client),getSiretBanque,getLoginSiret(getLoginCci),(:new.solde_compte>:old.solde_compte)*0.1);
end;
/

-- Trigger pour le prelevement des frais banquaires 
create or replace trigger prelevementFraisBanquaire after update on compte 
begin
	if (:new.id_client<>getSiretBanque and :new.solde_compte>:old.solde_compte) then -- On ne preleve pas de taxe sur la cci et on preleve sur le 											      -- debiteur 
		paie(getLoginSiret(:new.id_client),getSiretBanque,getLoginSiret(getLoginCci),(:new.solde_compte>:old.solde_compte)*0.05);
end;
/*/
