if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ReservationAnomalies]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ReservationAnomalies]
go

create proc [dbo].[Admin_ReservationAnomalies]
(	
	@RESID			INT
	,@RID			INT
	,@CONFNUMBER    INT
	,@CUSTID		INT
	,@CALLERID		INT
	,@EMAIL			NVARCHAR(50)	
	,@STARTDATE    	DATETIME
	,@ENDDATE    	DATETIME
)
as

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON	

IF (@RESID IS NULL AND @RID IS NULL AND @CONFNUMBER IS NULL AND @CUSTID IS NULL 
	AND @CALLERID IS NULL AND @EMAIL IS NULL AND @STARTDATE IS NOT NULL AND @ENDDATE IS NOT NULL)
	
	BEGIN		
	--Print 'All is null except @StartDate and @EndDate'
	select 		ResID     
				,BillingType    
				,RID   
				,ConfNumber  
				,BillableSize  
				,ResPoints  
				,ShiftDateTime  
				,RStateID  
				,CallerID  
				,CustID  
				,PartnerID
				,RestaurantType  
				,IsRestWeek  
				,ZeroReason  
				,Anomalies       
	from 		dbo.ReservationAnalysisVW       
	where 		ShiftDate between @STARTDATE and @ENDDATE	-- Use the Reservation Partition Key	
	ORDER BY 	ResID		
	END	
	
ELSE	
	BEGIN
	
		--If @Email is not null then set @CustID / @CallerID
		if (@Email IS not null) 		
		BEGIN			
			
			SELECT @CustID = coalesce(CustID, null) from Customer where Email = @Email						
			SELECT @CallerID = coalesce(CallerID, null) from Caller where LoginName = @Email				
		end 
		
		If (@CallerID is null) 		
			BEGIN
			--PRINT '@CallerID is null'	
			select 	ResID     
					,BillingType    
					,RID   
					,ConfNumber  
					,BillableSize  
					,ResPoints  
					,ShiftDateTime  
					,RStateID  
					,CallerID  
					,CustID
					,PartnerID
					,RestaurantType  
					,IsRestWeek  
					,ZeroReason  
					,Anomalies       
			from 	dbo.ReservationAnalysisVW       
			where 	ShiftDate between @STARTDATE and @ENDDATE 	-- Use the Reservation Partition Key
			and 	ResID = IsNull(@RESID, ResID)
			and		RID = IsNull(@RID, RID)
			and		ConfNumber = IsNull(@CONFNUMBER, ConfNumber)	
			and		CustID  = IsNull(@CUSTID, CustID)		
			ORDER BY ResID	
			END	
		else	
			BEGIN
			--PRINT ('@CallerID is not null')
			select 	ResID     
					,BillingType    
					,RID   
					,ConfNumber  
					,BillableSize  
					,ResPoints  
					,ShiftDateTime  
					,RStateID  
					,CallerID  
					,CustID  
					,PartnerID
					,RestaurantType  
					,IsRestWeek  
					,ZeroReason  
					,Anomalies       
			from 	dbo.ReservationAnalysisVW       
			where 	ShiftDate between @STARTDATE and @ENDDATE 	-- Use the Reservation Partition Key
			and 	ResID = IsNull(@RESID, ResID)
			and		RID = IsNull(@RID, RID)
			and		ConfNumber = IsNull(@CONFNUMBER, ConfNumber)	
			and		CustID  = IsNull(@CUSTID, CustID)
			and   	CallerID = @CallerID
			ORDER BY ResID			
			END 
		
	END

go
	
GRANT EXECUTE ON [Admin_ReservationAnomalies] TO ExecuteOnlyRole

--this proc is used in automation tests so adding permission for DBUser to call this proc.
GRANT EXECUTE ON [Admin_ReservationAnomalies] TO DBAutomation

GO
