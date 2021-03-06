/****************************************************************************/
/* Author:			Bob Delamater											*/
/* Date:			10/14/2014												*/
/* Description:		This routine does the following:						*/
/*					1. Looks for a condition where the packing list is		*/
/*						not correct											*/
/*					2. Logs results to a table								*/
/*					3. Sends email via sp_send_dbmail						*/
/*																			*/
/* Parameters:		@fullEmailList VARCHAR(MAX):							*/
/*						Semicolon seperated value list						*/
/*						Put one or many email addresses inside it			*/
/*						Whoever exists within this string will be emailed	*/
/*						along with a file attachment with the results		*/
/*																			*/
/* Exepectations:															*/
/*					1. Database mail must be set up.						*/
/*					2. The executing user must have access					*/
/*						to the ECCPROD schema		  						*/
/****************************************************************************/


DECLARE @myRowCount		INT,
		@fullEmailList	VARCHAR(MAX),
		@myNewID		UNIQUEIDENTIFIER,
		@err			VARCHAR(255)
		
SET @fullEmailList = 'bob.delamater@sage.com;pam.nightingale@sage.com;'
SET @myNewID = NEWID()

/****************************  Sanity checks ********************************/
USE x3v6
--drop table ECCPROD.ZMalformedPickLog

-- If the log table does not exist, create it
IF OBJECT_ID('ECCPROD.ZMalformedPickLog', 'U') IS NULL
BEGIN
	PRINT 'Creating log table'
	CREATE TABLE ECCPROD.ZMalformedPickLog
	(
		ID							INT IDENTITY(1,1) PRIMARY KEY,
		ItemReference				NVARCHAR(40) NULL,
		PickTicket					NVARCHAR(40) NULL,
		SalesOrderNumber			NVARCHAR(40) NULL,
		QTYSTU						NUMERIC(28, 13) NULL,
		ALLQTY						NUMERIC(28, 13) NULL,
		DeliveryFlag				VARCHAR(20) NULL,

		StockSTOFCY					NVARCHAR(10) NULL,
		StockSTOCOU					NUMERIC(11,1) NULL,
		StockLot					NVARCHAR(34) NULL,
		StockLoc					NVARCHAR(20) NULL,
		StockLOCTYP					NVARCHAR(10) NULL,
		StockQTYPCU					NUMERIC(28, 13) NULL,
		StockQTYSTU					NUMERIC(28, 13) NULL,
		StockQTYSTUACT				NUMERIC(28, 13) NULL,
		StockCUMALLQTY				NUMERIC(28, 13) NULL,
		StockCUMWIPQTY				NUMERIC(28, 13) NULL,
		StockCUMWIPQTA				NUMERIC(28, 13) NULL,
		StockLASRCPDAT				DATETIME NULL,

		StowipWIPQTY				NUMERIC(28, 13) NULL,
		StowipWIPQTA				NUMERIC(28, 13) NULL,
		StowipCREDAT				DATETIME NULL,
		StowipCREUSR				NVARCHAR(10) NULL,
		StoallCreateUser			NVARCHAR(10) NULL,
		StoallCreateDate			DATETIME NULL,
		StoallUpdateUser			NVARCHAR(10) NULL,
		StoallUpdateDate			DATETIME NULL,
		StoallLocationShortage		NVARCHAR(50) NULL,
		StoallStockQuantity			NUMERIC(28, 13) NULL,
		StoallActiveStockQuantity	NUMERIC(28, 13) NULL,
		StoallSequence				INT NULL,
		StoallShortageStatus		NVARCHAR(6) NULL,
		StoallEntryType				TINYINT NULL, -- Local menu 701
 
		HeaderCreateDate			DATETIME NULL, 
		HeaderCreateUser			NVARCHAR(10) NULL,
		HeaderUpdateDate			DATETIME NULL,  
		HeaderUpdateUser			NVARCHAR(10) NULL,
		DetailCreateDate			DATETIME NULL, 
		DetailCreateUser			NVARCHAR(10) NULL, 
		DetailUpdateDate			DATETIME NULL, 
		DetailUpdateUser			NVARCHAR(10) NULL, 
		HeaderRowID					INT NULL, 
		DetailRowID					INT NULL,
		YDOCK_0						NVARCHAR(40) NULL,
		InsertGUID					UNIQUEIDENTIFIER NULL,
		LogDate						DATETIME NULL
		
	)
END



-- Insert a list of pick tickets that are a known problem into the log table
INSERT INTO ECCPROD.ZMalformedPickLog(
		ItemReference,
		PickTicket,	SalesOrderNumber, QTYSTU, ALLQTY,
		DeliveryFlag, 
		
		StockSTOFCY,StockSTOCOU, StockLot,
		StockLoc, StockLOCTYP, StockQTYPCU, StockQTYSTU, 
		StockQTYSTUACT, StockCUMALLQTY, StockCUMWIPQTY, 
		StockCUMWIPQTA,	StockLASRCPDAT, 
		
		StowipWIPQTY, StowipWIPQTA, StowipCREDAT, StowipCREUSR, 
		
		StoallCreateUser, StoallCreateDate, StoallUpdateUser, 
		StoallUpdateDate, StoallLocationShortage, StoallStockQuantity, 
		StoallActiveStockQuantity, StoallSequence, StoallShortageStatus, 
		StoallEntryType,

		HeaderCreateDate, HeaderCreateUser, HeaderUpdateDate, 
		HeaderUpdateUser, DetailCreateDate,	DetailCreateUser, DetailUpdateDate, 
		DetailUpdateUser, HeaderRowID, DetailRowID,	YDOCK_0,
		InsertGUID, LogDate)			
SELECT 
		i.ITMREF_0,
		ph.PRHNUM_0, 
		pd.ORINUM_0, 
		pd.QTYSTU_0, 
		pd.ALLQTY_0, 
		CASE ph.DLVFLG_0
			WHEN 1 THEN 'In Process'
			WHEN 2 THEN 'Deliverable'
			WHEN 3 THEN 'Delivered'
			WHEN 4 THEN 'Cancelled'
			ELSE 'Unknown'
		End,
		s.STOFCY_0 StockSTOFCY,
		s.STOCOU_0 StockSTOCOU,
		s.LOT_0	StockLot,
		s.LOC_0 StockLoc,
		s.LOCTYP_0 StockLOCTYP,
		s.QTYPCU_0 StockQTYPCU,
		s.QTYSTU_0 StockQTYSTU,
		s.QTYSTUACT_0 StockQTYSTUACT,
		s.CUMALLQTA_0 StockCUMALLQTY,
		s.CUMWIPQTY_0 StockCUMWIPQTY,
		s.CUMWIPQTA_0 StockCUMWIPQTA,
		s.LASRCPDAT_0 StockLASRCPDAT,
		sw.WIPQTY_0 StowipWIPQTY,
		sw.WIPQTA_0 StowipWIPQTA,
		sw.CREDAT_0 StowipCREDAT,
		sw.CREUSR_0 StowipCREUSR,
		sa.CREUSR_0 StoallCreateUser,
		sa.CREDAT_0 StoallCreateDate,
		sa.UPDUSR_0 StoallUpdateUser,
		sa.UPDDAT_0 StoallUpdateDate,
		sa.LOC_0 StoallLocationShortage,
		sa.QTYSTU_0 StoallStockQuantity,
		sa.QTYSTUACT_0 StoallActiveStockQuantity,
		sa.SEQ_0 StoallSequence,
		sa.STA_0 StoallShortageStatus,
		sa.VCRTYP_0 StoallEntryType, -- Local menu 701
		ph.CREDAT_0 HeaderCreateDate, 
		ph.CREUSR_0 HeaderCreateUser,
		ph.UPDDAT_0 HeaderUpdateDate, 
		ph.UPDUSR_0 HeaderUpdateUser,
		pd.CREDAT_0 DetailCreateDate, 
		pd.CREUSR_0 DetailCreateUser, 
		pd.UPDDAT_0 DetailUpdateDate, 
		pd.UPDUSR_0 DetailUpdateUser, 
		ph.ROWID HeaderRowID, 
		pd.ROWID DetailRowID,
		ph.YDOCK_0,
		@myNewID,
		GETDATE() InsertDate
FROM ECCPROD.STOPREH ph
	INNER JOIN ECCPROD.STOPRED pd
		on pd.PRHNUM_0 = ph.PRHNUM_0
	INNER JOIN ECCPROD.ITMMASTER i
		ON i.ITMREF_0 = pd.ITMREF_0
	INNER JOIN ECCPROD.STOCK s
		ON pd.ITMREF_0 = s.ITMREF_0
	LEFT JOIN ECCPROD.STOWIPW sw
		ON s.STOCOU_0 = sw.STOCOU_0
	LEFT JOIN ECCPROD.STOALL sa
		ON s.STOFCY_0 = sa.STOFCY_0
		AND s.ITMREF_0 = sa.ITMREF_0
		AND s.STOCOU_0 = sa.STOCOU_0
WHERE 
	pd.QTYSTU_0 <> pd.ALLQTY_0		-- Original condition, replaced by the next line
	--(pd.ALLQTY_0 + SHTQTY_0) <> pd.QTYSTU_0 -- Potential revised logic, not in production yet
	AND ph.DLVFLG_0 IN(1,2)  -- In Process or Deliverable status
	AND ph.PRHNUM_0 <> 'P0508-E0000557' -- Malformed prep (customer not interested in this prep, discarded results)
ORDER BY ph.ROWID DESC

SET @myRowCount = @@ROWCOUNT

IF @myRowCount > 0 
BEGIN
	DECLARE @execSQL VARCHAR(MAX)
	SET @execSQL = 'SELECT * FROM ECCPROD.ZMalformedPickLog WHERE InsertGUID =''' + CONVERT(VARCHAR(36), @myNewID) + ''''
	
	USE msdb
	PRINT 'Sending results via DB Mail'
	EXEC msdb.dbo.sp_send_dbmail 
		@profile_name = 'Sage ECC',
		@recipients = @fullEmailList, 
		@body = 'Please see the attached results for case #8003970274 - Picking Ticket Allocated Quantity (ALLQTY) does not match Quantity Prepared (QTYSTU)', 
		@body_format = 'HTML',
		@subject = 'Case #8003970274 - Picking Early Warning Detection System',
		@from_address = 'bob.delamater@Sage.com',
		@query = @execSQL,
		@execute_query_database = 'x3v6',
		@attach_query_result_as_file = 1,
		@query_result_width  = 32767
	
END

