-- Copyright 2004-2018 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (http://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--
CREATE TABLE PARENT(ID INT, NAME VARCHAR, PRIMARY KEY(ID) );
> ok

MERGE INTO PARENT AS P
    USING (SELECT X AS ID, 'Coco'||X AS NAME FROM SYSTEM_RANGE(1,2) ) AS S
    ON (P.ID = S.ID AND 1=1 AND S.ID = P.ID)
    WHEN MATCHED THEN
        UPDATE SET P.NAME = S.NAME WHERE 2 = 2 WHEN NOT
    MATCHED THEN
        INSERT (ID, NAME) VALUES (S.ID, S.NAME);
> update count: 2

SELECT * FROM PARENT;
> ID NAME
> -- -----
> 1  Coco1
> 2  Coco2

EXPLAIN PLAN
    MERGE INTO PARENT AS P
        USING (SELECT X AS ID, 'Coco'||X AS NAME FROM SYSTEM_RANGE(1,2) ) AS S
        ON (P.ID = S.ID AND 1=1 AND S.ID = P.ID)
        WHEN MATCHED THEN
            UPDATE SET P.NAME = S.NAME WHERE 2 = 2 WHEN NOT
        MATCHED THEN
            INSERT (ID, NAME) VALUES (S.ID, S.NAME);
> PLAN
> ---------------------------------------------------------------------------------------------------------------------------------
> MERGE INTO PUBLIC.PARENT(ID, NAME) KEY(ID) SELECT X AS ID, ('Coco' || X) AS NAME FROM SYSTEM_RANGE(1, 2) /* PUBLIC.RANGE_INDEX */

DROP TABLE PARENT;
> ok

CREATE SCHEMA SOURCESCHEMA;
> ok

CREATE TABLE SOURCESCHEMA.SOURCE(ID INT PRIMARY KEY, VALUE INT);
> ok

INSERT INTO SOURCESCHEMA.SOURCE VALUES (1, 10), (3, 30), (5, 50);
> update count: 3

CREATE SCHEMA DESTSCHEMA;
> ok

CREATE TABLE DESTSCHEMA.DESTINATION(ID INT PRIMARY KEY, VALUE INT);
> ok

INSERT INTO DESTSCHEMA.DESTINATION VALUES (3, 300), (6, 600);
> update count: 2

MERGE INTO DESTSCHEMA.DESTINATION USING SOURCESCHEMA.SOURCE ON (DESTSCHEMA.DESTINATION.ID = SOURCESCHEMA.SOURCE.ID)
    WHEN MATCHED THEN UPDATE SET VALUE = SOURCESCHEMA.SOURCE.VALUE
    WHEN NOT MATCHED THEN INSERT (ID, VALUE) VALUES (SOURCESCHEMA.SOURCE.ID, SOURCESCHEMA.SOURCE.VALUE);
> update count: 3

SELECT * FROM DESTSCHEMA.DESTINATION;
> ID VALUE
> -- -----
> 1  10
> 3  30
> 5  50
> 6  600
> rows: 4

DROP SCHEMA SOURCESCHEMA CASCADE;
> ok

DROP SCHEMA DESTSCHEMA CASCADE;
> ok

CREATE TABLE SOURCE_TABLE(ID BIGINT PRIMARY KEY, C1 INT NOT NULL);
> ok

INSERT INTO SOURCE_TABLE VALUES (1, 10), (2, 20), (3, 30);
> update count: 3

CREATE TABLE DEST_TABLE(ID BIGINT PRIMARY KEY, C1 INT NOT NULL, C2 INT NOT NULL);
> ok

INSERT INTO DEST_TABLE VALUES (2, 200, 2000), (4, 400, 4000);
> update count: 2

MERGE INTO DEST_TABLE USING SOURCE_TABLE ON (DEST_TABLE.ID = SOURCE_TABLE.ID)
    WHEN MATCHED THEN UPDATE SET DEST_TABLE.C1 = SOURCE_TABLE.C1, DEST_TABLE.C2 = 100;
> update count: 1

SELECT * FROM DEST_TABLE;
> ID C1  C2
> -- --- ----
> 2  20  100
> 4  400 4000
> rows: 2

MERGE INTO DEST_TABLE D USING SOURCE_TABLE S ON (D.ID = S.ID)
    WHEN MATCHED THEN UPDATE SET D.C1 = S.C1, D.C2 = 100
    WHEN NOT MATCHED THEN INSERT (ID, C1, C2) VALUES (S.ID, S.C1, 1000);
> update count: 3

SELECT * FROM DEST_TABLE;
> ID C1  C2
> -- --- ----
> 1  10  1000
> 2  20  100
> 3  30  1000
> 4  400 4000
> rows: 4

DROP TABLE SOURCE_TABLE;
> ok

DROP TABLE DEST_TABLE;
> ok
