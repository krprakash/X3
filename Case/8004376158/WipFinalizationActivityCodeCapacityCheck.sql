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
SET @ONA_MAX =	(SELECT DIME_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'ONA')
SET @MAT_MAX =	(SELECT DIME_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'MAT')
SET @LAB_MAX =	(SELECT DIME_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'LAB')
SET @MAC_MAX =	(SELECT DIME_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'MAC')

SET @NMM_MAX=	(SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMM')
SET @NMMF_MAX = (SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMMF') -- NMM*max(1,MAT,MAC,LAB)
SET @NMMO_MAX = (SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMMO') -- NMM*ONA*2

SET @NMI_MAX =	(SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMI')
SET @NMIF_MAX = (SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMIF') -- NMI*max(1,MAT,MAC,LAB)
SET @NMIO_MAX = (SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMIO') -- NMI*ONA

SET @NMW_MAX  =	(SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'NMW')  
SET @NMWO_MAX = (SELECT @NMW_MAX * @ONA_MAX)

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
CREATE TABLE #MaxListings
(	
	ID					INT	PRIMARY KEY IDENTITY(1,1),
	ActivityCode		VARCHAR(MAX) NOT NULL,
	ActivityCodeValue	INT
)

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('NMM', @NMM_MAX)	

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('NMI', @NMI_MAX)	

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('NMMF', @NMMF_MAX)	

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('NMMO', @NMMO_MAX)	

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('NMW', @NMW_MAX)	

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('NMWO', @NMWO_MAX)	

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('ONA', @ONA_MAX)	

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('MAT', @MAT_MAX)	

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('LAB', @LAB_MAX)	

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('MAC', @MAC_MAX)	


/* Formula Results */
INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('NMMF_FormulaResult', @NMMF_FormulaResult	)	

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('NMMO_FormulaResult', @NMMO_FormulaResult)	

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('NMIF_FormulaResult', @NMIF_FormulaResult)	

INSERT INTO #MaxListings (ActivityCode, ActivityCodeValue)
VALUES('NMIO_FormulaResult', @NMIO_FormulaResult)	



/********************************* Output ************************************/
SELECT ActivityCode, ActivityCodeValue, 
	'IsInvalid' = 
		CASE WHEN ActivityCodeValue > 32000 THEN 'True'
		ELSE 'False'
		END
FROM #MaxListings
ORDER BY IsInvalid DESC


/**************** NMM_MAX check ****************/
-- No. material lines					
--Table: MFGMATRK 
DECLARE @NumMatTrackingsCannotBeCosted INT
SET @NumMatTrackingsCannotBeCosted = 
(
	SELECT COUNT(*)
	FROM ECCPROD2.MFGMATTRK mt
	GROUP BY mt.MFGNUM_0
	HAVING COUNT(MFGTRKNUM_0) > @NMM_MAX
)

IF @NumMatTrackingsCannotBeCosted > 0
BEGIN
	SELECT 
		MFGNUM_0, 
		COUNT(MFGTRKNUM_0) CntMfgTrkNum, 
		'These Work Orders cannot be costed' CannotBeCosted
	FROM ECCPROD2.MFGMATTRK mt
	GROUP BY mt.MFGNUM_0
	HAVING COUNT(MFGTRKNUM_0) > @NMM_MAX
	ORDER BY COUNT(MFGTRKNUM_0) DESC	
END


/**************** NMI_MAX check ****************/
-- No. product lines					
--Table: MFGITMTRK 
DECLARE @NumItmTrackingsCannotBeCosted INT
SET @NumItmTrackingsCannotBeCosted = 
(
	SELECT COUNT(*)
	FROM ECCPROD2.MFGITMTRK it
	GROUP BY it.MFGNUM_0
	HAVING COUNT(MFGTRKNUM_0) > @NMI_MAX
)


IF @NumItmTrackingsCannotBeCosted > 0
BEGIN
	SELECT 
		MFGNUM_0, 
		COUNT(MFGTRKNUM_0) CntMfgTrkNum, 
		'These Work Orders cannot be costed' CannotBeCosted
	FROM ECCPROD2.MFGITMTRK it
	GROUP BY it.MFGNUM_0
	HAVING COUNT(MFGTRKNUM_0) > @NMI_MAX
	ORDER BY COUNT(MFGTRKNUM_0) DESC
END

/**************** NMW_MAX check ****************/
-- No. operation lines					
-- Table: MFGOPETRK 
DECLARE @NumOpeTrackingsCannotBeCosted INT
SET @NumOpeTrackingsCannotBeCosted= 
(
	SELECT COUNT(*)
	FROM ECCPROD2.MFGOPETRK ot
	GROUP BY ot.MFGNUM_0
	HAVING COUNT(ot.MFGTRKNUM_0) > @NMI_MAX
)


IF @NumOpeTrackingsCannotBeCosted > 0
BEGIN
	SELECT 
		ot.MFGNUM_0, 
		COUNT(ot.MFGTRKNUM_0) CntMfgTrkNum, 
		'These Work Orders cannot be costed' CannotBeCosted
	FROM ECCPROD2.MFGOPETRK ot
	GROUP BY ot.MFGNUM_0
	HAVING COUNT(ot.MFGTRKNUM_0) > @NMI_MAX
	ORDER BY COUNT(ot.MFGTRKNUM_0) DESC
END

/**************** NMMF_MAX check ****************/
-- Number of lines groups				
-- Screen: CLCCST block 4 only How do I know what my min value can be?

/**************** NMMO_MAX check ****************/
-- No. OH lines Materials				
-- Screen: CLCCST How do I know what my min value can be?

/**************** NMWO_MAX check ****************/
-- No. OH lines Operations				
-- How do I know what my minimum value can be?

/**************** ONA_MAX check ****************/
-- Number of general cost natures		
-- How do I know what my minimum value can be? GESONA (count the number of records)
IF @ONA_MAX > (SELECT COUNT(*) FROM ECCPROD2.OVENAT)
BEGIN
	SELECT 
		@ONA_MAX CurrentOnaMax, 
		'You can reduce activity code ONA to ' 
		+ CAST((SELECT COUNT(*) FROM ECCPROD2.OVENAT) AS VARCHAR(MAX)) ProposedNewOnaMax
END

/**************** MAT_MAX check ****************/
-- No. material groups					
-- Screen: ITM2 BRDCOD (Costing Family) -- Local 325 compare it with ITMMASTER BRDCOD field usage
SELECT *
FROM ECCPROD2.APLSTD
WHERE 
	LAN_0 = 'ENG'
	AND LANCHP_0 = 325

/**************** LAB_MAX check ****************/
-- No. labour groups					
-- Screen: MWC1 BRDCOD (Cost Group) ---- NOTE: Check local menu 316 against WORKCOST to find which cost family is not in use for labor type

/**************** MAC_MAX check ****************/
-- No. machine groups					
-- Screen: MWC1 BRDCOD (Cost Group) ---- NOTE: Check local menu 316 against WORKCOST to find which cost family is not in use for machine type







--select VLTCCE_0, BRDCOD_0
--from ECCPROD2.WORKCOST


--select *
--from ECCPROD2.APLSTD

--select * from ECCPROD2.ACTIV where ACTFOR_0 <> ''


--select TCLCOD_0, VLTCOD_0, STOMGTCOD_0  from ECCPROD2.ITMCATEG where VLTCOD_0 <> 'STD'

--select ITMREF_0, STOFCY_0, VLTCOD_0
--from ECCPROD2.ITMFACILIT
--where VLTCOD_0 <> 'STD'
