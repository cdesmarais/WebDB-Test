if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobRevokeVIPStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobRevokeVIPStatus]
GO

CREATE Procedure [dbo].[JobRevokeVIPStatus]
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--*****************************************************************************************
--This proc runs once every year on the first of January to revoke VIP Status of all the Users 
--who haven't made more than 12 reservations in the previous calendar year.
--The Manual Gold VIP Status is not revoked by this job and is controlled through CHARM.
--This proc should always be executed as a pre step to "Set VIP Status " Job step.
--*****************************************************************************************

--This step ensures that this proc would only run on Jan 1st of every year
IF (DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) <> DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0))
	RETURN

-- Set Beginning of previous Year
DECLARE @PreviousYearBegin	DATETIME
DECLARE @PreviousYearEnd	DATETIME
DECLARE	@RunDT				DATETIME

SET		@RunDT = GETDATE()
SET		@PreviousYearBegin	= DATEADD(yy,DATEDIFF(yy,0,@RunDT)-1,0)
SET		@PreviousYearEnd	= DATEADD(yy,DATEDIFF(yy,0,@RunDT)-1,'12/31/1900')


--*************************
--** Temp storage for new VIPs
--*************************
DECLARE @CustomerVIP	TABLE 
		(
		CustID			INT PRIMARY KEY,
		ConsumerType	INT
		) 

DECLARE @CallerVIP		TABLE 
		(
		CallerID		INT PRIMARY KEY,
		ConsumerType	INT
		) 

--***************************************
--** Identify Expired VIPs
--***************************************
--Customers
INSERT INTO		@CustomerVIP
SELECT			c.custid, 
				c.ConsumerType 
FROM			(
				SELECT	CustID, 
						ConsumerType
				FROM	Customer
				WHERE	ConsumerType=4 --Get VIP Customers Only
				) c
LEFT JOIN								
				(---- Identify Set of current VIPs
				SELECT	CustID
				FROM	Reservation WITH (READUNCOMMITTED)
				WHERE	ShiftDate BETWEEN @PreviousYearBegin AND @PreviousYearEnd
				AND 	RStateID NOT IN (1,3,4) 
				AND 	ResPoints > 0
				AND 	callerid IS NULL
				GROUP BY CustID
				HAVING 	COUNT(ResID) >= 12 
				) r
ON 				c.CustID = r.custid
WHERE			r.CustID IS NULL  -- Only consider Customers who were not in the VIP set



--Callers
INSERT INTO		@CallerVIP
SELECT			c.CallerID, 
				c.ConsumerType 
FROM			(
				SELECT	CallerID, 
						ConsumerType
				FROM	Caller
				WHERE	ConsumerType=4 --Get VIP Customers Only
				) c
LEFT JOIN								
				(---- Identify Set of current VIPs
				SELECT	CallerID
				FROM	Reservation WITH (READUNCOMMITTED)
				WHERE	ShiftDate BETWEEN @PreviousYearBegin AND @PreviousYearEnd
				AND 	RStateID NOT IN (1,3,4) 
				AND 	ResPoints > 0
				GROUP BY CallerID
				HAVING 	COUNT(ResID) >= 12 
				) r
ON 				c.CallerID = r.CallerID
WHERE			r.CallerID IS NULL-- Only consider Callers who were not in the VIP set



	
--***********************************************
--** Revoke VIP Status
--***********************************************
UPDATE			Customer 
SET				ConsumerType = 1
FROM			customer
INNER JOIN		@CustomerVIP cv
ON				Customer.custid = cv.custID

UPDATE			Caller set ConsumerType = 1
FROM			Caller
INNER JOIN		@CallerVIP cv
ON				Caller.CallerID = cv.CallerID


--***********************************************
--** Track Changes
--***********************************************
INSERT INTO ConsumerTypeConvertLog 	
			(	
			CustID,
			CallerID,
			OriginalConsumerTypeID,
			NewConsumerTypeID,
			ConvertDate
			)
SELECT		custID,
			NULL,
			ConsumerType,
			1,
			@RunDT
from		@CustomerVIP
			

INSERT INTO ConsumerTypeConvertLog 	
			(	
			CustID,
			CallerID,
			OriginalConsumerTypeID,
			NewConsumerTypeID,
			ConvertDate
			)
SELECT		NULL,
			CallerID,
			ConsumerType,
			1,
			@RunDT
FROM		@CallerVIP


--*****************************************
--** Update the last run date
--*****************************************
UPDATE	ValueLookUP 
SET		ValueDT = @RunDT
WHERE	LType = 'DATABASE'
AND		lKey =	'JobRevokeVIPStatus_Run'	

IF (@@ROWCOUNT=0)
 BEGIN
	INSERT	INTO ValueLookUP
				(
				LType,
				LKey,
				ValueDT
				)
	VALUES		(
				'DATABASE',
				'JobRevokeVIPStatus_Run',
				@RunDT
				)
 END
GO

GRANT EXECUTE ON JobRevokeVIPStatus TO ExecuteOnlyRole
GO
