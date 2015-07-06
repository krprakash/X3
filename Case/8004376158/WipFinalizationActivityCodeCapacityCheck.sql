/**************************** Variable Declartion ****************************/
DECLARE @NMM_MAX	INT,
		@NMMF_MAX	INT,
		@NMMO_MAX	INT,
				
		@NMI_MAX	INT,
		@NMIF_MAX	INT,
		@NMIO_MAX	INT,

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

SET @ONA_MAX =	(SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'ONA')
SET @MAT_MAX =	(SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'MAT')
SET @LAB_MAX =	(SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'LAB')
SET @MAC_MAX =	(SELECT DIMMAX_0 FROM ECCPROD2.ACTIV WHERE CODACT_0 = 'MAC')

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
)

SET @NMMO_FormulaResult = 
(
	SELECT (NMM_MAX * ONA_MAX * 2) FROM #MaxListings
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
)


SET @NMIO_FormulaResult = 
(
	SELECT NMI_MAX * ONA_MAX FROM #MaxListings
)

IF OBJECT_ID('tempdb..#MaxListings', 'U') IS NOT NULL
BEGIN
	DROP TABLE #MaxListings
END
SELECT 
	@NMM_MAX NMM_MAX,
	@NMMF_MAX NMMF_MAX, 
	@NMMO_MAX NMMO_MAX, 
	@NMI_MAX NMI_MAX, 
	@NMIF_MAX NMIF_MAX, 
	@NMIO_MAX NNIO_MAX, 
	@ONA_MAX ONA_MAX, 
	@MAT_MAX MAT_MAX, 
	@LAB_MAX LAB_MAX, 
	@MAC_MAX MAC_MAX,
	@NMMF_FormulaResult NMMF_FormulaResult,
	@NMMO_FormulaResult NMMO_FormulaResult,
	@NMIF_FormulaResult NMIF_FormulaResult,
	@NMIO_FormulaResult NMIO_FormulaResult
INTO #MaxListings


/**************************************** Output *****************************/
SELECT * FROM #MaxListings



SELECT MFGNUM_0, COUNT(MFGTRKNUM_0) CntMfgTrkNum, 32000 * (SELECT FROM (VALUES (1, @MAT_MAX, @MAC_MAX, @LAB_MAX)))
FROM ECCPROD2.MFGMATTRK mt
GROUP BY mt.MFGNUM_0
ORDER BY COUNT(MFGTRKNUM_0) DESC
