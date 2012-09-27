/***********************************************/
CREATE SEQUENCE Seq_Client START WITH 1;
INSERT INTO mhocini_a.client(idc,nom,age) VALUES (mhocini_a.SEQ_CLIENT.NEXTVAL,'ali',25);

/***********************************************/
CREATE SEQUENCE seq_id_village;
INSERT INTO village(idv,destination,activite,prix,capacite) values (seq_id_village.nextval,'Baccaro','parapente',2000,20);

/***********************************************/
select * from mhocini_a.vue_client;

/***********************************************/
grant select on vue_age_client to mhocini_a;

/**********************************************/
/****  Requetes utiles ****/

select table_name from user_tables;

select * from user_tab_privs; /* privilèges de l'utilisateur */

select * from user_tab_privs;

select table_name from all_tables;

select table_name,OWNER  from all_tables; /* toutes les tables de la base de données */ 

select table_name from dict; /* tables système */

select view_name from user_views; /* vues de l'utilisateur */

select view_name from all_views; /* toutes les vues */

select sequence_name from user_sequences; /* sequences de l'utilisateur */

select constraint_type, constraint_name, status, table_name 
from user_constraints
where table_name = 'village'; /* Affiche les contraintes de la table village */


