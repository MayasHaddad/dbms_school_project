
DROP TABLE Client CASCADE CONSTRAINTS;
DROP TABLE Village CASCADE CONSTRAINTS;
DROP TABLE Sejour CASCADE CONSTRAINTS;

CREATE TABLE Client(idc integer PRIMARY KEY,
		nom varchar2(50) NOT NULL,
		age integer,
		avoir integer);

	
CREATE TABLE Village(idv integer,
		destination varchar2(50),
		activite varchar2(50),
		prix integer,
		capacite integer,
		CONSTRAINT idv_pk PRIMARY KEY(idv));

CREATE TABLE Sejour(ids integer,
		idclient integer REFERENCES Client (idc),
		idv integer REFERENCES Village (idv),
		jour date,
		CONSTRAINT ids_pk PRIMARY KEY (ids)
		);

