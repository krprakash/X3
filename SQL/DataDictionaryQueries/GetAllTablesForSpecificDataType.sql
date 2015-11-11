
-- Find all X3 tables that have a column with a specific data type
-- I've used this in the past to determine a wide variety of issues. One 
-- use might be to find any import object that imports a certain kind of data, 
-- such as a clob file
SELECT 
	tz.CODFIC_0 TableName, 
	txt2.TEXTE_0 TableDesc, 
	tz.CODZONE_0 ColumnName, 
	txt3.TEXTE_0 ColumnDesc,
	t.CODTYP_0 DataType, 
	t.TYPTYP_0 InternalType, 
	txt.TEXTE_0 DataTypeDesc
FROM DEMO.ATABZON tz
	INNER JOIN DEMO.ATABLE tbl
		ON tbl.CODFIC_0 = tz.CODFIC_0
	INNER JOIN DEMO.ATYPE t
		ON tz.CODTYP_0 = t.CODTYP_0
	INNER JOIN DEMO.ATEXTE txt
		ON t.INTITTYP_0 = txt.NUMERO_0
		AND LAN_0 = 'ENG'
	INNER JOIN DEMO.ATEXTE txt2
		ON tbl.INTITFIC_0 = txt2.NUMERO_0
		AND txt2.LAN_0 = 'ENG'
	INNER JOIN DEMO.ATEXTE txt3
		ON tz.NOCOURT_0 = txt3.NUMERO_0
		AND txt3.LAN_0 = 'ENG'
WHERE 
	--t.CODTYP_0 in ('CLC', 'AC0', 'CLE', 'CLT', 'CLX', 'HD8') -- optional: If you know data type
	LOWER(txt.TEXTE_0) LIKE '%clob%'
ORDER BY tz.CODFIC_0, tz.CODZONE_0
