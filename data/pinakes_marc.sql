BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "MARC_XML_TABLE" (
	"identificador"	INTEGER,
	"marc005"	TEXT,
	"marc022a"	TEXT,
	"marc040e"	TEXT,
	"marc041a"	TEXT,
	"marc044a"	TEXT,
	"marc044c"	TEXT,
	"marc245a"	TEXT,
	"marc264a"	TEXT,
	"marc264b"	TEXT,
	"marc264c"	INTEGER,
	"marc310a"	TEXT,
	"marc362a"	TEXT,
	"marc500a"	TEXT,
	"marc650a"	TEXT
);
INSERT INTO "MARC_XML_TABLE" VALUES (1,'2025-05-20T06:26:21Z','1808-8392','rda','por','bl','br','Inclusao Social','Brasilia','Instituto Brasileiro de Informacao em Ciencia e Tecnologia',2005,'Semestral','Vol. 1 No. 1','A Revista Inclusao Social e um periodico eletronico semestral de trabalhos ineditos','Sociedade da informacao');
CREATE VIEW v_publicacao AS 
SELECT identificador, marc245a FROM MARC_XML_TABLE;
COMMIT;
