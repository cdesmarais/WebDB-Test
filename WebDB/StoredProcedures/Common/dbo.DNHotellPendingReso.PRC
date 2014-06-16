if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNHotellPendingReso]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNHotellPendingReso]
GO

CREATE PROCEDURE dbo.DNHotellPendingReso
(
    @CompanyID int
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @TodayDate datetime 
declare @YesterdayShiftDate datetime

set @TodayDate = GetDate()
set @YesterdayShiftDate =  DateAdd(d, -1, dbo.fGetDatePart(@TodayDate))


--*****************************
--** Retrireves history using RestaurantVW
--** Histroy will only include restaurants in a language supported by the domain / website of the caller
--*****************************

	select ShiftDate + 2 + ResTime as ResoDate,
		r.RName as RName,
		r.RSName as RSName,
		isnull(CallerCustomer.LName,'') + ', ' + isnull(CallerCustomer.FName, '') GuestFullName,
		isnull(c.Fname,'') + ' ' + isnull(c.Lname, '') ConciergeFullName,
		r.RID as RID,
		res.ResID as ResID,
		l.LanguageCode as Language,
		CallerCustomer.LName as GuestLastName,
		CallerCustomer.FName as GuestFirstName,
		CallerCustomer.SLName as GuestSLastName,
		CallerCustomer.SFName as GuestSFirstName,
		c.Fname as ConciergeFname,
		c.Lname as ConciergeLname,
		c.SFname as ConciergeSFname,
		c.SLname as ConciergeSLname
	from Reservation res 
	INNER JOIN	RestaurantAVW r
	ON			r.RID = res.RID
	AND			r.LanguageID = res.LanguageID
	inner join 	timezoneVW tz 
			on	tz.tzid	= r.tzid
	inner join	CallerCustomer
			on	CallerCustomer.CustID = res.CustID
	inner join	Caller c
			on	c.callerid = res.callerid
	inner join Language l
			on l.LanguageID = res.LanguageID
	where c.CompanyID = @CompanyID
		and RStateID = 1
		and Res.CompanyID is not NULL
		and Res.ShiftDate >= @YesterdayShiftDate 
		and Dateadd(mi, LocalToServerOffsetMi, (ShiftDate + 2 + ResTime)) > @TodayDate -- Pending resos must be in the future
	order by ResoDate 

GO


GRANT EXECUTE ON [DNHotellPendingReso] TO ExecuteOnlyRole

GO
