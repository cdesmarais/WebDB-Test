if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminUpdateJustAdded]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminUpdateJustAdded]
GO

 

CREATE PROCEDURE dbo.AdminUpdateJustAdded 
(
  @RID int,
  @New bit,
  @override datetime
)

AS 

if (@override = '')
	set @override = null
 
update restaurantjustadded set justadded = @New, overridedate = @override
where RID = @RID

    
update restaurantjustadded set dateadded = getdate(), dateremoved = getdate() + displaydays
from restaurantjustadded rja
inner join restaurant r on rja.rid = r.rid
inner join neighborhood n on r.neighborhoodid = n.neighborhoodid
inner join metroarea m on n.metroareaid = m.metroareaid
where (datediff(day,getdate(),dateadded)>0 or dateadded is null) and
	  @New = 1 and
          rja.RID = @RID


update restaurantjustadded set dateremoved = getdate()
where @New = 0 and
            RID = @RID

 

 

 

 

GO

 

GRANT EXECUTE ON [AdminUpdateJustAdded ] TO ExecuteOnlyRole

 

GO
