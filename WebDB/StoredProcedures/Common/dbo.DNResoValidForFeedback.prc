if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNResoValidForFeedback]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNResoValidForFeedback]
GO


-- Check if reservation is valid to submit feedback 
-- Reso cannot be for an admin user and should not have submitted feedback already
-- AND must be seated or assumed seated or seated disputed (2,5,7)
CREATE PROCEDURE dbo.DNResoValidForFeedback
(
     @theResID int	
)

AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- check if reservation object follows rules..
if exists(select resid from reservation r where r.resid=@theResID and rstateid in (2,5,7) and callerid is null and 
resid not in (select resid from DiningFormResponses dfr where resid=@theResID))
BEGIN
    select 1 as ResoIsValid,
		resid,
		re.rname,
		shiftdate,
		re.country,
		-1 as Callerid,
		r.rstateid,
		r.rid
    from reservation r 
	inner join	RestaurantAVW re 
	ON			re.rid			= r.rid
	AND			re.LanguageID	= r.LanguageID
	where r.resid=@theResID;
	
    return;
END


select 0 as ResoIsValid,
	r.resid,
	'Bogus' as RName,
	getdate() as ShiftDate,
	'US' as Country,
	coalesce(dfr.ResID,-1) as theFBResID,
	r.rstateid,
	r.callerid,
	r.rid
from Reservation r 
left join DiningFormResponses dfr on dfr.resid = r.resid 
where r.resid=@theResID

GO

GRANT EXECUTE ON [DNResoValidForFeedback] TO ExecuteOnlyRole

GO
