if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Admin_Company_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Admin_Company_Add]
GO

 
CREATE Procedure dbo.Concierge_Admin_Company_Add  
 (  
  @CompanyName nvarchar(255),  
  @CompanyEmail nvarchar(255),  
  @Address1 nvarchar(255),  
  @Address2 nvarchar(255),  
  @City nvarchar(255),  
  @StateID nvarchar(255),  
  @PostalCode nvarchar(255),  
  @HoodCity int,  
  @CompanyType int,  
  @CompanyGroup int,  
  @Notes nvarchar(999),  
  @Phone nvarchar(24),  
  @FaxPhone nvarchar(24),  
  @logo nvarchar(999),  
  @AcceptsPoints int,    
  @OffProperty int,  
  @CountryID char(2) = 'US'  
  ,@retval int output  
 )  
As  

SET TRAN ISOLATION LEVEL SERIALIZABLE  
BEGIN TRAN  

-- set output parmeter default to 0
set @retval = 0

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
		INSERT INTO Company  
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
		  Country    
		 )  
		 VALUES   
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
		  @CountryID    
		 ) 		
 
	end   	

set @retval = @@identity

  
if (@@ERROR <> 0) goto general_error  

COMMIT TRAN  
RETURN(0)  
  
dup_company:  
 ROLLBACK TRAN  
 RAISERROR('The Company you entered already exists.',17,1)
 RETURN(1)  



general_error:  
 ROLLBACK TRANSACTION  
 Return(2)  

  
GO


GRANT EXECUTE ON [Concierge_Admin_Company_Add] TO ExecuteOnlyRole
GO


