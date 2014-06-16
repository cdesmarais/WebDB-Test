--OTGetRestStatus <rid-list>
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTGetRestStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTGetRestStatus]
GO


-- Updates elements of the alert. All elements except the alertid can be null..
CREATE PROCEDURE dbo.OTGetRestStatus
(
	@ridList varchar(8000)  --[EV: List of Int IDs]
)
AS

select rid,reststateid from restaurant where CHARINDEX(',' + CAST(RID AS varchar) + ',', ',' + @ridList + ',') > 0
order by rid asc


GO


GRANT EXECUTE ON [OTGetRestStatus] TO ExecuteOnlyRole

GO
