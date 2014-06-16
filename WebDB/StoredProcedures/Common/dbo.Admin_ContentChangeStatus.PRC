if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ContentChangeStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ContentChangeStatus]
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ContentChangeStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ContentChangeStatus]

GO
  
CREATE PROCEDURE dbo.Admin_ContentChangeStatus  
(  
  @RestaurantID int,
  @ContentID int,  
  @ProviderID int,  
  @Enabled int,
  @retval int OUTPUT  
)  
AS 
SET NOCOUNT ON 

/*********************************************************************************************
 Purpose:
 This stored procedure use to activate and suppress the review for the perticular Restaurant
 and Provider.Procedure returns -1 in output parameter if user tries to activate a suppress
 review, if there is already a review is activated for same restaurant and same provider.
 
 Approach:
 1. If @Enabled input parameter is not 0 then verify that,table already contains an active 
	review. if then return -1 in output parameter.
 2. If @Enabled input parameter is 0 then update the recored.
 3. If @Enabled input parameter is not 0 and no review is active for the same restaurant with
	same provider then and activate the reveiw.
****************************************************************************************/
  
BEGIN TRANSACTION  
-- set output parmeter default to 0
set @retval = 0

if  (@Enabled <> 0)
	begin
		-- verify, Is there any activated review exists for the requested Restaurant and provider..
		if exists(select contentID 
				  from Content 
				  where ProviderID=@ProviderID 
						AND RID=@RestaurantID 
						AND Enabled = 1)
			begin
				-- set output parameter to -1 if recored exist.
				set @retval = -1
			end
		else
			begin
				-- Activate review in db for requested restaurant and provider.
				Update Content  
				Set enabled=@Enabled  
				where ContentID=@ContentID 
					  AND ProviderID=@ProviderID 
					  AND RID=@RestaurantID  
			end
	end
else
	begin
		-- suppress review in database for requested restaurant and provider.
		Update Content  
		Set enabled=@Enabled  
		where ContentID=@ContentID 
			  AND ProviderID=@ProviderID 
			  AND RID=@RestaurantID  
	 end

if (@@ERROR <> 0)  
 goto general_error  
				  
COMMIT TRANSACTION  
 Return(0) 
   
general_error:  
 ROLLBACK TRANSACTION  
 Return(0)  
  
GO

GRANT EXECUTE ON [Admin_ContentChangeStatus] TO ExecuteOnlyRole

GO

