if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetNoShowDisputeLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetNoShowDisputeLog]
GO


CREATE PROCEDURE dbo.DNGetNoShowDisputeLog
(
	@nResolved bit
)
 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted


SELECT         	ns.ResID as ReservationID,    
              	res.ShiftDate as ReservationDate,
              	ns.DisputeDate,
              	rest.RID as RestaurantID,
              	rest.RName as RestaurantName,
              	res.ResPoints as Points,
              	ns.DisputeStatus,
              	ns.Message,
              	CustomerID,
              	ns.IsCaller,
              	DisputeReason
        
FROM			(
					select				ResID,
              	                        DisputeDate,
              	                        Reason as DisputeStatus,
              	                        Message,
              	                        UserID as CustomerID,
              	                        IsCaller,
              	                        Reason as DisputeReason
              		FROM                LogNoShowDisputes 
              		where               DisputeDate >= '2010-01-01'
              		and                 Resolved = @nResolved
              	)  	ns
              	
inner join		Reservation				as res
on				res.ResID				= ns.ResID
inner join		RestaurantAVW			as rest
on				rest.RID				= res.RID
and				rest.LanguageID			= res.LanguageID
WHERE			res.ShiftDate			>= '2010-01-01'

GO


GRANT EXECUTE ON [DNGetNoShowDisputeLog] TO ExecuteOnlyRole

GO
