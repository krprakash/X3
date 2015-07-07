/**************************** Variable Declartion ****************************/
DECLARE @NMM_MAX	INT,
		@NMMF_MAX	INT,
		@NMMO_MAX	INT,
				
		@NMI_MAX	INT,
		@NMIF_MAX	INT,
		@NMIO_MAX	INT,
		
		@NMW_MAX	INT,
		@NMWO_MAX	INT,

		@ONA_MAX	INT,		
		@MAT_MAX	INT,
		@LAB_MAX	INT,
		@MAC_MAX	INT,
		
		@NMMF_FormulaResult	INT,	-- Number of lines groups
		@NMMO_FormulaResult	INT,	-- No. OH lines Materials
		@NMIF_FormulaResult	INT,	-- Number of lines groups
		@NMIO_FormulaResult	INT		-- No. OH lines Products

/**************************** Variable Assignment ****************************/

SET @NMM_MAX=	(SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMM')
SET @NMMF_MAX = (SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMMF') -- NMM*max(1,MAT,MAC,LAB)
SET @NMMO_MAX = (SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMMO') -- NMM*ONA*2

SET @NMI_MAX =	(SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMI')
SET @NMIF_MAX = (SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMIF') -- NMI*max(1,MAT,MAC,LAB)
SET @NMIO_MAX = (SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMIO') -- NMI*ONA

SET @NMW_MAX  =	(SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMW')  
SET @NMMO_MAX = (SELECT @NMW_MAX * @ONA_MAX)

SET @ONA_MAX =	(SELECT DIME_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'ONA')
SET @MAT_MAX =	(SELECT DIME_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'MAT')
SET @LAB_MAX =	(SELECT DIME_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'LAB')
SET @MAC_MAX =	(SELECT DIME_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'MAC')

SET @NMMF_FormulaResult = 
(	
	SELECT MAX(myMax)
	FROM 
		(VALUES
			(1),
			(@MAT_MAX), 
			(@MAC_MAX), 
			(@LAB_MAX)
		) AS MaxNumber(myMax)
	
)* @NMM_MAX

SET @NMMO_FormulaResult = 
(
	SELECT (@NMM_MAX * @ONA_MAX * 2)
)

SET @NMIF_FormulaResult = 
(
	SELECT MAX(myMax)
	FROM 
		(VALUES
			(1), 
			(@MAT_MAX),
			(@MAC_MAX),
			(@LAB_MAX)
		) AS MaxNumber(myMax)
) * @NMI_MAX


SET @NMIO_FormulaResult = 
(
	SELECT (@NMI_MAX * @ONA_MAX)
)


/******************************* Table Creation  *****************************/
IF OBJECT_ID('tempdb..#MaxListings', 'U') IS NOT NULL
BEGIN
	DROP TABLE #MaxListings
END
--SELECT 
--	@NMM_MAX NMM_MAX,
--	@NMMF_MAX NMMF_MAX, 
--	@NMMO_MAX NMMO_MAX, 
--	@NMI_MAX NMI_MAX, 
--	@NMIF_MAX NMIF_MAX, 
--	@NMIO_MAX NNIO_MAX, 
--	@ONA_MAX ONA_MAX, 
--	@MAT_MAX MAT_MAX, 
--	@LAB_MAX LAB_MAX, 
--	@MAC_MAX MAC_MAX,
--	@NMMF_FormulaResult NMMF_FormulaResult,
--	@NMMO_FormulaResult NMMO_FormulaResult,
--	@NMIF_FormulaResult NMIF_FormulaResult,
--	@NMIO_FormulaResult NMIO_FormulaResult
--INTO #MaxListings
CREATE TABLE #MaxListings
(	
	ID					INT	PRIMARY KEY IDENTITY(1,1),
	ActivityCode		VARCHAR(MAX) NOT NULL,
	ActivityCodeValue	INT
)
INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)

SELECT 'NMM', @NMM_MAX								-- No. material lines					Table: MFGMATRK -- easy
UNION
SELECT 'NMI', @NMI_MAX								-- No. product lines					Table: MFGITMTRK --  easy
UNION
SELECT 'NMMF', @NMMF_MAX							-- Number of lines groups				Screen: CLCCST block 4 only How do I know what my min value can be?
UNION
SELECT 'NMMO', @NMMO_MAX							-- No. OH lines Materials				Screen: CLCCST How do I know what my min value can be?
UNION
SELECT 'NMW', @NMW_MAX								-- No. operation lines					Table: MFGOPETRK -- easy
UNION
SELECT 'NMWO', @NMWO_MAX							-- No. OH lines Operations				How do I know what my minimum value can be?
UNION
SELECT 'ONA', @ONA_MAX								-- Number of general cost natures		How do I know what my minimum value can be? GESONA (count the number of records)
UNION
SELECT 'MAT', @MAT_MAX								-- No. material groups					Screen: ITM2 BRDCOD (Costing Family) -- Local 325 compare it with ITMMASTER BRDCOD field usage
UNION
SELECT 'LAB', @LAB_MAX								-- No. labour groups					Screen: MWC1 BRDCOD (Cost Group) ---- NOTE: Check local menu 316 against WORKCOST to find which cost family is not in use for labor type
UNION
SELECT 'MAC', @MAC_MAX								-- No. machine groups					Screen: MWC1 BRDCOD (Cost Group) ---- NOTE: Check local menu 316 against WORKCOST to find which cost family is not in use for machine type
UNION
SELECT 'NMMF_FormulaResult', @NMMF_FormulaResult	
UNION
SELECT 'NMMO_FormulaResult', @NMMO_FormulaResult	
UNION
SELECT 'NMIF_FormulaResult', @NMIF_FormulaResult	
UNION
SELECT 'NMIO_FormulaResult', @NMIO_FormulaResult	

/********************************* Output ************************************/
SELECT * FROM #MaxListings



SELECT TOP 100
	MFGNUM_0, 
	COUNT(MFGTRKNUM_0) CntMfgTrkNum, 
	'These Work Orders cannot be costed' CannotBeCosted
FROM ECCPROD2.MFGMATTRK mt
GROUP BY mt.MFGNUM_0
--HAVING COUNT(MFGTRKNUM_0) > @NMM_MAX
ORDER BY COUNT(MFGTRKNUM_0) DESC

SELECT TOP 1
	MFGNUM_0, 
	COUNT(MFGTRKNUM_0) CntMfgTrkNum, 
	'These Work Orders cannot be costed' CannotBeCosted
FROM ECCPROD2.MFGITMTRK it
GROUP BY it.MFGNUM_0
--HAVING COUNT(MFGTRKNUM_0) > @NMI_MAX
ORDER BY COUNT(MFGTRKNUM_0) DESC


select VLTCCE_0, BRDCOD_0
from ECCPROD2.WORKCOST


select *
from ECCPROD2.APLSTD

select * from ECCPROD2.ACTIV where ACTFOR_0 <> ''


select TCLCOD_0, VLTCOD_0, STOMGTCOD_0  from ECCPROD2.ITMCATEG where VLTCOD_0 <> 'STD'

select ITMREF_0, STOFCY_0, VLTCOD_0
from ECCPROD2.ITMFACILIT
where VLTCOD_0 <> 'STD'
