if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateNewStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateNewStatus]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_UpdateNewStatus
(
  @RestID nvarchar(255),
  @MetroID int
)
AS

-- unset the newflag set on any restaurant in this metro
update restaurant set newflag=0 from 
Restaurant R
inner join neighborhood n on (n.neighborhoodid=r.neighborhoodid and n.metroareaid=@MetroID)
where newflag != 0 and CHARINDEX(',' + CAST(RID AS nvarchar(500)) + ',',',' + @RestID + ',') = 0


-- set the newflag on the new set of restaurants..
update restaurant set newflag=1 from 
Restaurant R
inner join neighborhood n on (n.neighborhoodid=r.neighborhoodid and n.metroareaid=@MetroID)
where CHARINDEX(',' + CAST(RID AS nvarchar(500)) + ',',',' + @RestID + ',') > 0
AND NewFlag != 1

GO

GRANT EXECUTE ON [Admin_Restaurant_UpdateNewStatus] TO ExecuteOnlyRole

GO
