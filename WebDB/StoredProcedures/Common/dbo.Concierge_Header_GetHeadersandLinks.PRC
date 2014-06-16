if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Header_GetHeadersandLinks]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Header_GetHeadersandLinks]
GO



CREATE PROCEDURE dbo.Concierge_Header_GetHeadersandLinks
 (
  @User_ID int
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

if exists(select CallerID from CallertoHeader where CallerID = @User_ID)
BEGIN
select CallerHeaders.HeaderID as Header_ID,CallerHeaders.HeaderName as name,CallerHeaderLinks.LinkName as link_name,CallerHeaderLinks.Link,CallerHeaders.Custom
from CallerHeaderLinks
inner join CallerHeaders on CallerHeaderLinks.HeaderID = CallerHeaders.HeaderID
inner join CallertoHeader on CallerHeaders.HeaderID = CallertoHeader.HeaderID
where CallertoHeader.CallerID = @User_ID
order by CallerHeaders.HeaderName,CallerHeaderLinks.LinkName
END

else
BEGIN
select CallerHeaders.HeaderID as Header_ID,CallerHeaders.HeaderName as name,CallerHeaderLinks.LinkName as link_name,CallerHeaderLinks.Link,CallerHeaders.Custom
from CallerHeaderLinks
inner join CallerHeaders on CallerHeaderLinks.HeaderID = CallerHeaders.HeaderID
inner join Caller on CallerHeaders.GeoID = Caller.metroareaid
where Caller.CallerID = @User_ID and CallerHeaders.Custom=0
order by CallerHeaders.HeaderName,CallerHeaderLinks.LinkName
END

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Header_GetHeadersandLinks] TO ExecuteOnlyRole

GO
