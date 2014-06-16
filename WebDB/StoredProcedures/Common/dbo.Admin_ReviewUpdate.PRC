if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ReviewUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ReviewUpdate]
GO
  
CREATE PROCEDURE dbo.Admin_ReviewUpdate(
	@content text,  
	@ShortContent nvarchar (4000),  
	@RestaurantID int, 
	@ContentID int, 
	@ProviderID int,  
	@enabled bit
)  
  
AS  
SET NOCOUNT ON  

-- This procedure is use to update exsiting reviews for a particular restuarant. 
-- ContentID added as new input parameter to uniquely identify the review in content
-- table for updation. 
Update Content   
set enabled = @enabled
	,Content = @Content
	,ShortValue = @ShortContent    
	where RID = @RestaurantID
		  and ContentID = @ContentID   
		  and ProviderID = @ProviderID  
  
GO

GRANT EXECUTE ON [Admin_ReviewUpdate] TO ExecuteOnlyRole

GO

