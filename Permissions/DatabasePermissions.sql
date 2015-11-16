/* 11/16/2015: Broken schema ownership chain at the database role level
*  Replacing missing roles												*/

SELECT 'GRANT ALL ON ' + s.name + '.' + t.name + ' TO X3_ADX'
FROM sys.tables t
	INNER JOIN sys.schemas s
		ON t.schema_id = s.schema_id
WHERE s.name = 'CICPROD' 

UNION

SELECT 'GRANT ALL ON ' + s.name + '.' + t.name + ' TO X3_ADX_R'
FROM sys.tables t
	INNER JOIN sys.schemas s
		ON t.schema_id = s.schema_id
WHERE s.name = 'CICPROD' 

UNION

SELECT 'GRANT ALL ON ' + s.name + '.' + t.name + ' TO CICPROD_ADX'
FROM sys.tables t
	INNER JOIN sys.schemas s
		ON t.schema_id = s.schema_id
WHERE s.name = 'CICPROD' 

UNION

SELECT 'GRANT ALL ON ' + s.name + '.' + t.name + ' TO CICPROD_ADX_H'
FROM sys.tables t
	INNER JOIN sys.schemas s
		ON t.schema_id = s.schema_id
WHERE s.name = 'CICPROD' 

UNION

SELECT 'GRANT ALL ON ' + s.name + '.' + t.name + ' TO CICPROD_ADX_R'
FROM sys.tables t
	INNER JOIN sys.schemas s
		ON t.schema_id = s.schema_id
WHERE s.name = 'CICPROD' 

UNION

SELECT 'GRANT ALL ON ' + s.name + '.' + t.name + ' TO CICPROD_ADX_RH'
FROM sys.tables t
	INNER JOIN sys.schemas s
		ON t.schema_id = s.schema_id
WHERE s.name = 'CICPROD' 

UNION
SELECT 'GRANT ALL ON ' + s.name + '.' + t.name + ' TO CICPROD_ADX_RH'
FROM sys.views t
	INNER JOIN sys.schemas s
		ON t.schema_id = s.schema_id
WHERE s.name = 'CICPROD' 


UNION

/*** Handle Sequences ***/
SELECT 'GRANT UPDATE ON ' + s.name + '.' + sq.name + ' TO X3_ADX_SYS'
FROM sys.sequences sq
	INNER JOIN sys.schemas s
		ON sq.schema_id = s.schema_id
WHERE s.name = 'CICPROD' 
