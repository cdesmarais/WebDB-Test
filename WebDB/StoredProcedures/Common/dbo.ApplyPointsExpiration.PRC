if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ApplyPointsExpiration]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ApplyPointsExpiration]
GO

create procedure dbo.ApplyPointsExpiration

as

--***********************************************
--** Expire Points for Inactive Users
--** This script must run after user point totals have been recalculated to ensure things balance out correctly
--** Can only expire positive point balnaces; Expiring a negative balance will erroneously set teh LastPointsGainDt
--***********************************************

Set Transaction isolation level read uncommitted

Declare @InactiveMonths int, @GracePeriodDays int, @expireDate datetime, @AdjReasonID int, @transacTime datetime
/*Set Maximum Inactive Months, GracePeriod Days and Calculate actual Expire Date*/ 
set @InactiveMonths = 12
set @GracePeriodDays = 14
set @expireDate = DateAdd(mm, -@InactiveMonths, getdate()) - @GracePeriodDays
select @AdjReasonID = AdjReasonID from pointsadjustmentreason where explanation = 'Points Expiration'
set @transacTime = getdate()

-- Point Expire ID not found
if (@AdjReasonID is null) 
begin
	exec DNErrorAdd 10003, 'ApplyPointsExpiration', 'Failed To Expire Points -- no adjustment id', 1
	RETURN 
end

IF	OBJECT_ID('TempDB..#tmpCustomerPoints') > 0
	DROP TABLE #tmpCustomerPoints


SELECT		C.custID, -(C.points) AS AdjPoints
INTO		#tmpCustomerPoints
FROM		Customer C WITH (READUNCOMMITTED)
WHERE		Points > 0 -- Only Expire Positive Point Balances
			AND c.consumertype <> 8
			AND C.LastPointsGainDate < @expireDate 
			AND LastPointsGainDate IS NOT NULL 

--Expire Customer Points one by one to avoid locking on Customer Table
--which results in failed Reso Make/update Operations. 

DECLARE @cUserID			INT
DECLARE @cAdjPoints			INT
DECLARE @Errors				INT
DECLARE @Rows				INT
DECLARE @TranName			VARCHAR(50)
	
DECLARE	Cursor_Customers CURSOR FOR
 SELECT	CustID, AdjPoints FROM #tmpCustomerPoints

OPEN Cursor_Customers

FETCH NEXT FROM Cursor_Customers INTO @cUserID, @cAdjPoints

SET	@TranName='TranCustomerPoints'

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRAN @TranName
				--Update Points for the Customer		
		UPDATE		Customer 
		SET			Points = 0
		WHERE		CustID = @cUserID
		AND			CallerID IS NULL
		AND			LastPointsGainDate < @expireDate 
		AND			LastPointsGainDate IS NOT NULL 

		SELECT	@Rows=@@RowCount, @Errors=@@Error
		
		--Add Entry to PointsAdjustment Table
		IF (@Rows>0 AND @Errors=0)--If the Customer Ends up gaining points at the very moment we would skip the customer
		 BEGIN
			INSERT INTO	 PointsAdjustment (CustID, AdjustmentAmount, AdjReasonID, AdjustmentDate)
			VALUES		(@cUserID, @cAdjPoints, @AdjReasonID, @transacTime)
		 END
		
		IF (@Errors <> 0 OR @@Error<>0) GOTO ErrBlock	

	COMMIT TRAN @TranName

	IF @@Error <> 0 GOTO ErrBlock
	SELECT @Rows=0, @Errors=1
	FETCH NEXT FROM Cursor_Customers INTO @cUserID, @cAdjPoints
END

CLOSE 		Cursor_Customers
DEALLOCATE 	Cursor_Customers
SET			@cUserID = NULL
SET			@cAdjPoints = NULL

--Callers
IF	OBJECT_ID('TempDB..#tmpCallerPoints')>0
	DROP TABLE #tmpCallerPoints

SELECT		C.CallerID, -(C.Points) AS AdjPoints
INTO		#tmpCallerPoints
FROM		Caller C WITH (READUNCOMMITTED)
WHERE		Points > 0 -- Only Expire Positive Point Balances
			AND c.consumertype <> 8
			AND C.LastPointsGainDate < @expireDate 
			AND LastPointsGainDate IS NOT NULL 


--Expire Caller Points one by one to avoid locking on Caller Table
--which results in failed Reso Make/update Operations. 
	
DECLARE	Cursor_Callers CURSOR FOR
 SELECT	CallerID, AdjPoints	FROM #tmpCallerPoints

OPEN Cursor_Callers

FETCH NEXT FROM Cursor_Callers INTO @cUserID, @cAdjPoints

SET	@TranName='TranCallerPoints'

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRAN @TranName
		--Update Points for the Customer		
		UPDATE		Caller 
		SET			Points = 0
		WHERE		CallerID = @cUserID
		AND			CallerID IS NOT NULL
		AND			LastPointsGainDate < @expireDate 
		AND			LastPointsGainDate IS NOT NULL 

		SELECT	@Rows=@@RowCount, @Errors=@@Error

		--Add Entry to PointsAdjustment Table
		IF (@Rows>0 AND @Errors=0)--If the Caller Ends up gaining points at the very moment we would skip the caller
		 BEGIN 		
			INSERT INTO	 PointsAdjustment (CallerID, AdjustmentAmount, AdjReasonID, AdjustmentDate)
			VALUES		(@cUserID, @cAdjPoints, @AdjReasonID, @transacTime)
		 END
		
		IF (@Errors <> 0 OR @@Error<>0) GOTO ErrBlock	
		
	COMMIT TRAN @TranName

	IF @@Error <> 0 GOTO ErrBlock
	SELECT @Rows=0, @Errors=1
	FETCH NEXT FROM Cursor_Callers INTO @cUserID, @cAdjPoints
END

CLOSE 		Cursor_Callers
DEALLOCATE 	Cursor_Callers


RETURN

ErrBlock:
ROLLBACK TRAN @TranName
SET @TranName = 'Failed To Expire Points [' + @TranName + ']'
exec DNErrorAdd 10002, 'ApplyPointsExpiration', @TranName, 1
RETURN 



GO

GRANT EXECUTE ON [ApplyPointsExpiration] TO ExecuteOnlyRole

GO
