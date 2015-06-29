/*****************************************************************************
* Note: You must change the substring in both places for the sequence number
* specific to your sequence counter number
* This is not a long term fix
******************************************************************************/

DECLARE @MaxSOH NVARCHAR(40)
CREATE TABLE #wrkTbl 
(
	ROWID_SORDERP	INT,
	SOHNUM_0		NVARCHAR(40),
	SOHSeqNumber	NUMERIC(21,1),
	ATTVal			NUMERIC(21,1),
	CommandToExecute	VARCHAR(MAX)
)

INSERT INTO #wrkTbl
SELECT 
	p.ROWID, 
	p.SOHNUM_0, 
	CONVERT(NUMERIC(21,1),
	SUBSTRING(p.SOHNUM_0,4,5)), 
	at.VALEUR_0,
	'DELETE DEMO.AVALATT WHERE CODNUM_0 = ''SON'' AND VALEUR_0 = ' + SUBSTRING(p.SOHNUM_0,6,7) ExecuteMe	
FROM DEMO.SORDERP p 
	LEFT JOIN DEMO.SORDER o 
		ON p.SOHNUM_0 = o.SOHNUM_0
	INNER JOIN DEMO.AVALATT at 
		ON CONVERT(NUMERIC(21,1),SUBSTRING(p.SOHNUM_0,6,7)) = at.VALEUR_0 
		AND at.CODNUM_0 = 'SON'
WHERE o.SOHNUM_0 IS NULL

/***********************************************************************************/
/* Spot check these delete statements created above.								*
** Ensure that the correct match for sequence numbers are being found in the join.	*
** Once you are confident that these are											*
** are correct, you can enable the delete statement below, and the script can		*
** automatically purge the sequence numbers from AVALATT for you, until Sage		*
** can remedy the problem correctly.											

BEGIN TRAN 

BEGIN TRY
	DELETE at
	FROM DEMO.AVALATT at
		INNER JOIN #wrkTbl w
			ON w.SOHSeqNumber = at.VALEUR_0
	
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE() ErrorMsg, ERROR_SEVERITY() ErrSeverity, ERROR_STATE() ErrState
	PRINT 'Rolling back transaction'
	ROLLBACK 
END CATCH

IF @@TRANCOUNT > 0
BEGIN
	COMMIT TRAN
END		

***********************************************************************************/
SELECT * FROM DEMO.#wrkTbl
SELECT * FROM DEMO.AVALATT
DROP TABLE #wrkTbl 



