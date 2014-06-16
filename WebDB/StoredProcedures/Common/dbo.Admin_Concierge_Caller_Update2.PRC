

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Concierge_Caller_Update2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Concierge_Caller_Update2]
go

/*
	Update Concierge Information.
*/  
create procedure dbo.Admin_Concierge_Caller_Update2  
(  
  @UserID int  
  ,@FirstName nvarchar(255)  
  ,@LastName nvarchar(255)  
  ,@SFirstName nvarchar(255)
  ,@SLastName nvarchar(255)  
  ,@login nvarchar(255)
  ,@Email nvarchar(255)  
  ,@DefaultGeoID int  
  ,@HotelID int  
  ,@PositionID int = 2  
  ,@PartnerID int
  ,@CompanyMetroID int
  ,@CallerStatus int
  ,@Phone nvarchar(24)
  ,@Country nvarchar(2)
 )  
  
as  
set NOCOUNT on  
  
BEGIN TRANSACTION  

	/* Update concierge information.*/
	update Caller 
	set
		FName = @FirstName
		,LName = @LastName  
		,SFName = @SFirstName  
		,SLName = @SLastName  
		,EMail = @Email  
		,MetroAreaID = @DefaultGeoID  
		,CompanyID = @HotelID  
		,PositionID = @PositionID  
		,LoginName = @login  
		,PartnerID = @PartnerID
		,CompanyMetroID =  @CompanyMetroID
		,CallerStatusID = @CallerStatus
	where 
		CallerID = @UserID  
		
	if (@@ERROR <> 0)  
		goto general_error  
		
	/* Update caller phone information.*/	
	update CallerPhone  
	set	
		Phone = @Phone
		,PhoneCountryID = @Country
	where
		PhoneTypeID = 6
		and CallerID = @UserID
		and IsPrimary = 1
		
if (@@ERROR <> 0)  
 goto general_error  
  
COMMIT TRANSACTION  
Return(0)  
  
general_error:  
 ROLLBACK TRANSACTION  
 Return(0)  
  
go

GRANT EXECUTE ON [Admin_Concierge_Caller_Update2] TO ExecuteOnlyRole

go  