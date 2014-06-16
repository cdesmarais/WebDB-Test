if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_GetEmailPreferences]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_GetEmailPreferences]
GO

CREATE Procedure dbo.User_GetEmailPreferences
 (
  @UserID int,    
  @isCallerorAdmin bit  
 )
As

SET NOCOUNT ON

IF (@isCallerorAdmin = 0)	-- customer
begin
	SELECT	CustID
			,CallerID
			,MetroAreaID
			,MacroID
			,NeighborhoodID			
			,Spotlight
			,Insider
			,DinersChoice
			,NewHot
			,RestaurantWeek
			,Promotional
			,isnull(Product,0) as Product
			,UpdatedDtUTC 
	FROM	UserOptIn 
	WHERE	CustID = @UserID
end
ELSE IF (@isCallerorAdmin = 1)	-- admin/caller
begin
	SELECT	CustID
			,CallerID
			,MetroAreaID
			,MacroID
			,NeighborhoodID		
			,Spotlight
			,Insider
			,DinersChoice
			,NewHot
			,RestaurantWeek
			,Promotional
			,isnull(Product,0) as Product
			,UpdatedDtUTC 
	FROM	UserOptIn 
	WHERE	CallerID = @UserID	
END

GO


GRANT EXECUTE ON [User_GetEmailPreferences] TO ExecuteOnlyRole
GO
