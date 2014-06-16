if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Header_GetLinks]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Header_GetLinks]
GO



CREATE PROCEDURE dbo.Concierge_Header_GetLinks
 (
  @User_ID int,
  @Header_ID int
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

select CallerHeaderLinks.LinkName as link_name,CallerHeaderLinks.Link from CallerHeaderLinks
inner join CallerHeaders on CallerHeaderLinks.HeaderID = CallerHeaders.HeaderID
where CallerHeaders.HeaderID = @Header_ID
order by CallerHeaderLinks.LinkName

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Header_GetLinks] TO ExecuteOnlyRole

GO
