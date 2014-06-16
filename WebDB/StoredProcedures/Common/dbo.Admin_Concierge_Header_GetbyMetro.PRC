if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Concierge_Header_GetbyMetro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Concierge_Header_GetbyMetro]
GO





CREATE Procedure dbo.Admin_Concierge_Header_GetbyMetro
 (
  @Metro_ID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION

select CallerHeaders.HeaderID as Header_ID,CallerHeaders.HeaderName as name,CallerHeaderLinks.LinkName as link_name,CallerHeaderLinks.Link,CallerHeaderLinks.LinkID as Link_ID
from CallerHeaderLinks 
inner join CallerHeaders on CallerHeaderLinks.HeaderID = CallerHeaders.HeaderID 
where CallerHeaders.GeoID = @Metro_ID and CallerHeaders.Custom=0
order by CallerHeaders.HeaderName,CallerHeaderLinks.LinkName

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON [Admin_Concierge_Header_GetbyMetro] TO ExecuteOnlyRole

GO
