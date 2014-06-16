if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ReviewAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ReviewAdd]
GO
  
CREATE PROCEDURE dbo.Admin_ReviewAdd(
	@content text,  
	@ShortContent nvarchar(4000),  
	@RestaurantID int,  
	@ProviderID int,  
	@ContentTypeID int,  
	@enabled bit,
	@retval int OUTPUT
)  
  
As  
SET NOCOUNT ON  

/*********************************************************************************************
 Purpose:
 This stored procedure use to insert new review for the perticular Restaurant
 and Provider.Procedure returns -1 in output parameter if user tries to insert new review and 
 review already exist for the same restaurant with same provider.
 
 Approach:
 1. Verify, if review already exist then set output parameter to -1.
 2. If review not exist for the same restaurant with the same provider or exist but suppress 
    then insert new review.
*********************************************************************************************/

-- set OUTPUT parameter default to 0.
set @retval = 0

-- verify, Is there any activated review exists for the requested Restaurant and provider..
if exists(select ContentID 
		  from Content 
		  where ProviderID=@ProviderID 
				AND RID=@RestaurantID 
				AND Enabled = 1)
 begin
   -- set output parameter to -1 if recored exist.
	set @retval=-1
 end
else
 begin
	-- insert new review in content table.
	insert into Content (
			ProviderID,
			ContentTypeID,
			RID,
			Enabled,
			Content,
			ShortValue
		) 
		values
		(
			@ProviderID,
			@ContentTypeID,
			@RestaurantID,
			@enabled,
			@content,
			@ShortContent
		)  
  end
 
GO

GRANT EXECUTE ON [Admin_ReviewAdd] TO ExecuteOnlyRole

GO

