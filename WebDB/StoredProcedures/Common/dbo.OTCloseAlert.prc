--OTCloseAlert <alertid>,<notification-sent-time>
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTCloseAlert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTCloseAlert]
GO


-- Updates elements of the alert. All elements except the alertid can be null..
CREATE PROCEDURE dbo.OTCloseAlert
(
	@closeRIDList varchar(8000)  --[EV: List of Int IDs]
)
AS

-- update alerts table..
update otalerts set status = 2,alertclosedatets=getdate() where CHARINDEX(',' + CAST(RID AS varchar) + ',', ',' + @closeRIDList + ',') > 0
and status =1

GO
GRANT EXECUTE ON [OTCloseAlert] TO ExecuteOnlyRole

GO
