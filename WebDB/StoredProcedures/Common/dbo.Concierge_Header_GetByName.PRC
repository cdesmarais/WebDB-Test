if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Header_GetByName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Header_GetByName]
GO



CREATE PROCEDURE dbo.Concierge_Header_GetByName
 (
  @User_ID int,
  @Header_Name nvarchar(255)
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

select CallerHeaders.HeaderID as Header_ID from Caller_headers
inner join CallertoHeader on CallerHeaders.HeaderID = CallertoHeader.HeaderID
where CallertoHeader.CallerID = @User_ID and CallerHeaders.HeaderName = @Header_Name

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Header_GetByName] TO ExecuteOnlyRole

GO
