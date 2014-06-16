if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateGroupReportInterimHistorical]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateGroupReportInterimHistorical]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE Procedure [dbo].[UpdateGroupReportInterimHistorical]

AS


/*The procedure updates previous month's total reso and cover amount per restaurant into
table - GroupReportInterimHistorical. This procedure needs to be run after current month's 
financeExtract is completed*/

set transaction isolation level read uncommitted


Declare @PreMonth datetime
Declare @CurReportYear nvarchar(4)
Declare @CurReportDate nvarchar(7)

select @PreMonth = DATEADD(month, -1, getdate())

select @CurReportDate =cast(month(@PreMonth ) as nvarchar(2))+ '/' + cast(Year(@PreMonth) as nvarchar(4)) 
select @CurReportYear= cast(year(@PreMonth) as nvarchar(4))

Insert into GroupReportInterimHistorical 
select FE.ReportDate, FE.RID , FE.RName ,FE.City, FE.State, 
count(FE.SeatedSize) as TotalReservations,
Sum(FE.SeatedSize) as TotalGuests,
Sum(COALESCE(FE.FirstTime,0)) AS TotalFirstTimeBookers,
Sum(FE.SeatedSize*Cast(FE.FirstTime as int)) as CoverFromFirstTimeBookers,
Sum(COALESCE(FE.StandardType, 0)) As TotalOTReservation,
Sum(FE.SeatedSize*Cast(FE.StandardType as int)) As TotalOTGuest,
Sum(COALESCE(FE.WebType, 0)) As TotalRestaurantReservation,
Sum(FE.SeatedSize*Cast(FE.WebType as int)) As TotalRestaurantGuest,
Sum(COALESCE(FE.PromoType, 0)) As TotalPromoReservation,
Sum(FE.SeatedSize*Cast(FE.PromoType as int)) As TotalPromoGuest,
Sum(COALESCE(FE.FirstTimeStandardBooker, 0)) As FirstTimeOTBooker,
Sum(COALESCE(FE.FirstTimeWebBooker, 0)) As FirstTimeRestaurantBooker,
Sum(COALESCE(FE.FirstTimePromoBooker, 0)) As FirstTimePromoBooker,
	Sum(FE.SeatedSize*Cast(FE.DisputeFlag as int)) As DisputedCovers,
COALESCE(x.cancel,0)as cancel, COALESCE(x.noshow,0) as noshow
from (select ReportDate, RID, RName, City, State, SeatedSize, 
		Case When Incentive = 'Y' then 1
			 Else 0
		End as PromoType, 
		Case When Incentive = 'N' and Referral = 0 then 1
			 Else 0
		End as StandardType,
		Case When Incentive = 'N' and Referral = 1 then 1
			 Else 0
		End as WebType,
		Case When Incentive = 'Y' and FirstTime = 1 then 1
			 Else 0
		End as FirstTimePromoBooker, 
		Case When Incentive = 'N' and Referral = 0 and FirstTime = 1 then 1
			 Else 0
		End as FirstTimeStandardBooker,
		Case When Incentive = 'N' and Referral = 1 and FirstTime =1 then 1
			 Else 0
		End as FirstTimeWebBooker,
		FirstTime, DisputeFlag
		from financeExtract)FE
left join (
select R.RID as RID, 
Sum(case when (rstateID=4 or rstateID= 10 )  then 1
else 0 end) as noshow,
Sum(case when (rstateID=3 or rstateID= 8 or rstateID= 9 ) then 1
else 0 end) as cancel
from 
reservation R
where rstateID in (3,4,8,9,10) and month(R.shiftdate)=month(@PreMonth) and year(R.shiftdate)= year(@PreMonth)
group by R.RID)x
on FE.RID = x.RID
GROUP BY FE.ReportDate,FE.RID, FE.RName,FE.City, FE.State,x.noshow, x.cancel


go


GRANT EXECUTE ON [UpdateGroupReportInterimHistorical] TO ExecuteOnlyRole

GO

