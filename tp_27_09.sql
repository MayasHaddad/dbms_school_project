create sequence seq_sejour;

create or replace PROCEDURE TR2(  c client.idc%type,  D village.destination%type, j sejour.jour%type)
  is u village%rowtype;
begin 
  select * into u from(
    select * from village v where 
      v.destination = d and v.capacite >
      (select count (*) from sejour s
	where s.idv=v.idv and s.jour = j
      )
    order by prix desc)
  where rownum=1;
update client set avoir = avoir-u.prix where idc = c;
insert into sejour values (seq_sejour.nextval,c,u.idv,j);
end;
/

exec tr2(2,'Rio',20);