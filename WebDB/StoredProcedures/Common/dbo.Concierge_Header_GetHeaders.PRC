if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Header_GetHeaders]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Header_GetHeaders]
GO



CREATE PROCEDURE dbo.Concierge_Header_GetHeaders
 (
  @User_ID int
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION
if exists(select CallerID from CallertoHeader where CallerID = @User_ID)
BEGIN
select CallerHeaders.HeaderID as Header_ID,CallerHeaders.HeaderName as name,CallerHeaders.Custom
from CallerHeaders
inner join CallertoHeader on CallerHeaders.HeaderID = CallertoHeader.HeaderID
where CallertoHeader.CallerID = @User_ID
order by CallerHeaders.HeaderName
END

else
BEGIN
select CallerHeaders.HeaderID as Header_ID,CallerHeaders.HeaderName as name,CallerHeaders.Custom
from CallerHeaders
inner join Caller on CallerHeaders.GeoID = Caller.metroareaid and CallerHeaders.Custom = 0
where Caller.CallerID = @User_ID
order by CallerHeaders.HeaderName
END

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Header_GetHeaders] TO ExecuteOnlyRole

GO
