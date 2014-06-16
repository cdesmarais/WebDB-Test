if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNConciergePointRemoval]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNConciergePointRemoval]
GO


CREATE PROCEDURE dbo.DNConciergePointRemoval
   (
      @HotelID int,
      @Restaurants varchar(8000)
   )
As

SET NOCOUNT ON

drop table BKConciergesUpdated

set transaction isolation level read uncommitted

select 	ca.callerID, 
	fname, 
	Lname, 
	Points, 
	sum(respoints) as restpoints, 
	(case 
		when 	Points > sum(respoints) 
		then 	-sum(respoints) 
		else 	-Points 
		end) as AdjustmentAmount,
	Points + (case 
			when Points > sum(respoints) 
			then -sum(respoints) 
			else -Points 
			end) as FinalPoints
into 	BKConciergesUpdated
from 	fIDStrToTab(@Restaurants, ',') rlist
inner	join reservation r
on	rlist.id = r.rid
inner 	join caller ca 
on 	r.callerID = ca.callerID
where 	r.companyID = @HotelID -- Change HotelID
and 	points > 0
and 	rstateID in (2,5,6,7)
group by 	ca.callerID, 
		fname, 
		Lname, 
		Points
		

insert into PointsAdjustment 
	(CallerID,
	AdjustmentAmount,
	AdjReasonID,	
	AdjustmentDate)
Select 	callerID, 
	(case 
		when Points > restpoints 
		then -restpoints 
		else -Points 
		end) as AdjustmentAmount, 
	15 as AdjReasonID, 
	getdate() as AdjustmentDate
from BKConciergesUpdated

Update caller 
set 	points = FinalPoints
from 	caller 
inner 	join BKConciergesUpdated 
on 	caller.callerID = BKConciergesUpdated.callerID

GO

GRANT EXECUTE ON [DNConciergePointRemoval] TO ExecuteOnlyRole

GO
