



/*Procedure to create the records for Concierge*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Concierge_Caller_Create2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[Admin_Concierge_Caller_Create2]
go

  
create procedure dbo.Admin_Concierge_Caller_Create2
(  
	@FirstName			nvarchar(255)
	,@LastName			nvarchar(255)
	,@SFirstName		nvarchar(255)
	,@SLastName			nvarchar(255)
	,@login 			nvarchar(255)
	,@Email 			nvarchar(255) = null
	,@Country			nvarchar(2) = null
	,@Phone				nvarchar(24)
	,@DefaultGeoID		int
	,@HotelID			int
	,@PartnerID			int
	,@CompanyMetroID	int
	,@CreatedByUser		varchar(50)
	,@retval			int output
)  

as  

	set nocount on  

	declare @UserID int,@n int  

	set dateformat mdy  

	set tran isolation level serializable  

	begin tran  
  
	-- Check that the email address is not already in use.  
	if exists( select LoginName from caller where LoginName=@login ) 
		goto dup_email  
  
	-- Check that the email address is not already in use.if exists(select LoginName from Caller where LoginName=@login) goto dup_email  
	if @Email is null and exists ( Select Email from Company where CompanyID = @HotelID )  
	begin  
		select 
			@Email = Email 
		from 
			Company 
		where 
			CompanyID = @HotelID  
	end  
  
	-- if country is null, set it to the country of the company  
	if (@Country is null)  
	begin  
		select 
			@Country = Country 
		from 
			Company 
		where 
			CompanyID = @HotelID  
	end  
  
	--Create the Caller row.  
	insert into Caller  
	(
		FName
		,LName
		,SFName
		,SLName
		,EMail
		,metroareaid
		,CompanyID
		,PositionID
		,LoginName
		,PwdQuestionID
		,PartnerID
		,Points
		,CompanyMetroID
	)  
	values 
	(
		@FirstName
		,@LastName
		,@SFirstName
		,@SLastName
		,@Email
		,@DefaultGeoID
		,@HotelID
		,2
		,@login
		,99
		,@PartnerID
		,0
		,@CompanyMetroID
	)  
	  
	if (@@ERROR <> 0)  
		goto dup_email  
  
	select @UserID = scope_identity()  
  
	insert into CallerPhone  
	(
		PhoneTypeID
		,CallerID
		,Phone
		,PhoneCountryID
		,IsPrimary
	)  
	values 
	(
		6
		,@UserID
		,@Phone
		,@Country
		,1
	)  
  
	if @@Error <> 0  
		goto general_error  
	
	/*TT44757 : Insert the Record for Tracking the "CreatedBy" user for the Concierge*/
	insert into ConciergeChangeLog  
	(
		CallerID
		,CreatedBy
	)  
	values 
	(
		@UserID
		,@CreatedByUser
	)  
  
	if @@Error <> 0  
		goto general_error  
		
	
	commit tran  
	
	select @retval = @UserID  
	return(0)  
  
	dup_email:  
	rollback tran  
	raiserror('116' ,16,2) --'That email address is already in use.'  
	return(1)  
  
	general_error:  
	rollback tran  
	raiserror('6' ,16,2) --'Error adding new Customer.'  
	return(2)  
  
go

grant execute on [Admin_Concierge_Caller_Create2] to ExecuteOnlyRole

go



