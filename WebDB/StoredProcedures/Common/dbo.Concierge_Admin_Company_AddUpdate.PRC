
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Admin_Company_AddUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Admin_Company_AddUpdate]
go

--Updates the Company details

create procedure dbo.Concierge_Admin_Company_AddUpdate
 (
	@Company_ID int
	,@CompanyName nvarchar(255)  
	,@CompanyEmail nvarchar(520)  
	,@Address1 nvarchar(255)  
	,@Address2 nvarchar(255)  
	,@City nvarchar(255)  
	,@StateID nvarchar(255)  
	,@PostalCode nvarchar(40)  
	,@HoodCity int  
	,@CompanyType int  
	,@CompanyGroup int  
	,@Notes nvarchar(520)  
	,@Phone varchar(24)  
	,@FaxPhone varchar(24)  
	,@Logo nvarchar(60)  
	,@AcceptsPoints int  
	,@OffProperty int  
	,@CountryID char(2) = 'US'  
	,@Active bit  
	,@retval int output
 )
as
set nocount on

-- set output parmeter default to 0
set @retval = 0

--if company id > 0 then the company needs to be edited with the details
if(@Company_ID > 0)
	begin
		begin transaction

		update 
			company
		set
			companyname = @CompanyName
			,EMail = @CompanyEmail
			,Address1 = @Address1
			,Address2=@Address2
			,City = @City
			,State = @StateID
			,Zip = @PostalCode
			,Notes = @Notes
			,metroareaid = @HoodCity
			,CompanyTypeID = @CompanyType
			,CompanyGroupID = @CompanyGroup
			,Phone = @Phone
			,FaxPhone = @FaxPhone
			,Logo = @Logo
			,acceptspoints = @AcceptsPoints
			,offProperty = @OffProperty	
			,Country = @CountryID
			,IsActive = @Active
		where
			CompanyID =  @Company_ID
			
		if (@@ERROR <> 0)
			goto general_error

		-- Deactivate all the concierges for the company whose status is deactivated	
		if(@Active = 0)
		begin
			update 
				Caller
			set
				callerstatusid = 2  --disabled
			where
				CompanyID = @Company_ID
		end

		if (@@ERROR <> 0)
			goto general_error

		set @retval = 1

		commit transaction
		return(0)
	end
else
	begin
		begin transaction
		
		-- Check that the company is not already in use.  
		if exists ( select CompanyName
					from  Company   
					where  CompanyName = @CompanyName   
					and  Address1 = @Address1   
					and  City = @City  
					and  State = @StateID   
					and  Zip = @PostalCode ) Goto dup_Company
		else
			begin 
				--Create the Company row.  
				insert into Company  
				  (  
					CompanyName,  
					EMail,  
					Address1,   
					Address2,  
					City,  
					State,  
					Zip,  
					metroareaid,  
					CompanyTypeID,  
					CompanyGroupID,  
					Notes,  
					Phone,  
					FaxPhone,  
					logo,  
					acceptspoints,   
					offproperty,   
					Country,
					IsActive    
				 )  
				 values   
				 (  
					@CompanyName,  
					@CompanyEmail,  
					@Address1,  
					@Address2,  
					@City,  
					@StateID,  
					@PostalCode,  
					@HoodCity,  
					@CompanyType,  
					@CompanyGroup,  
					@Notes,  
					@Phone,  
					@FaxPhone,  
					@logo,  
					@AcceptsPoints,   
					@OffProperty,    
					@CountryID,
					@Active    
				 ) 		
		 
			end   	

		set @retval = @@identity
		  
		if (@@ERROR <> 0) goto general_error  

		commit transaction  
		return(0)
	end

general_error:
	rollback transaction
	return(0)

dup_company:  
 rollback transaction  
 raiserror('The Company you entered already exists.',17,1)
 return(1)  


go


grant execute on [Concierge_Admin_Company_AddUpdate] to ExecuteOnlyRole

go
