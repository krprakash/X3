-- Find Statistical Parameters Related to a Specific Table
SELECT RLG_0 TriggerCode, COD_0 StatisticalParameter, ENAFLG_0 IsEnabled, t.TEXTE_0
FROM PILOT1.PARSTA2 p
	INNER JOIN PILOT1.ATEXTRA t
		ON p.COD_0 = t.IDENT1_0
		AND t.LANGUE_0 = 'ENG'
		AND t.ZONE_0 = 'INTIT'
WHERE RLG_0 IN 
(
	SELECT COD_0
	FROM PILOT1.PARSTA1
	WHERE 
		RLGTBL_0 LIKE 'SORDER%'
		OR (
				TBL_0 LIKE '%<Table Name, SYSNAME, SORDER>%'
				OR TBL_1 LIKE '%<Table Name, SYSNAME, SORDER>%'
				OR TBL_2 LIKE '%<Table Name, SYSNAME, SORDER>%'
				OR TBL_3 LIKE '%<Table Name, SYSNAME, SORDER>%'
				OR TBL_4 LIKE '%<Table Name, SYSNAME, SORDER>%'
				OR TBL_5 LIKE '%<Table Name, SYSNAME, SORDER>%'
				OR TBL_6 LIKE '%<Table Name, SYSNAME, SORDER>%'
				OR TBL_7 LIKE '%<Table Name, SYSNAME, SORDER>%'
				OR TBL_8 LIKE '%<Table Name, SYSNAME, SORDER>%'
				OR TBL_9 LIKE '%<Table Name, SYSNAME, SORDER>%'
			)
)
