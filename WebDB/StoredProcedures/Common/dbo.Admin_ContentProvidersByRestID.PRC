if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ContentProvidersByRestID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ContentProvidersByRestID]
GO




CREATE PROCEDURE dbo.Admin_ContentProvidersByRestID
(
  @RestaurantID int=0
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
if (@RestaurantID > 0)
	Begin
	Select Distinct Provider.ProviderName as Name
	From Provider Right Outer Join Content On Provider.ProviderID = Content.ProviderID
	Where Content.RID = @RestaurantID
	Order By Provider.ProviderName
	End
if (@RestaurantID = 0)
	Begin
	Select ProviderName as Name,ProviderID
	From Provider
	--Order By Provider.ProviderName
	End

GO

GRANT EXECUTE ON [Admin_ContentProvidersByRestID] TO ExecuteOnlyRole

GO
