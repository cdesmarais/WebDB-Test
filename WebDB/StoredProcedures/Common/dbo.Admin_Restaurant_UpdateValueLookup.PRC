if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateValueLookup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateValueLookup]
go

create procedure [dbo].[Admin_Restaurant_UpdateValueLookup]
(
    @LookupID INT,
    @RID INT,
    @AddValue BIT    
)
AS



BEGIN TRANSACTION MyTran
	IF (@AddValue = 1)	
		begin	
		IF not exists (SELECT ValueID FROM dbo.ValueLookupIDList WHERE LookupID = @LookupID AND ValueID = @RID)		
			insert into dbo.ValueLookupIDList (LookupID,ValueID) VALUES (@LookupID, @RID) 	
		END 		  
	ELSE IF(@AddValue = 0) 	
		begin
			DELETE ValueLookupIDList WHERE LookupID = @LookupID AND ValueID = @RID	
		END 
			
	IF (@@ERROR <> 0) Goto general_error
	COMMIT TRAN
	RETURN(0)    	


general_error:
ROLLBACK TRANSACTION MyTran
RAISERROR('general error',17,1)
RETURN(1)
GO


GRANT EXECUTE ON [Admin_Restaurant_UpdateValueLookup] TO ExecuteOnlyRole
GO

