if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcGetDailyUserFeedChanges]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcGetDailyUserFeedChanges]
GO


CREATE PROCEDURE dbo.SvcGetDailyUserFeedChanges
(
	@StartDateUTC datetime,
	@EndDateUTC	datetime
)
as

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @startday datetime, @endday datetime, @StartTimeUTC datetime, @EndTimeUTC datetime, @UTCMIDiff int

--Get the offset for the UTC comparisons
select			top 1 @UTCMIDiff = (ServerOffsetMI * -1)
from			TimezoneVW

set @startday = dbo.fGetDatePart(@StartDateUTC)
set @endday = dbo.fGetDatePart(@EndDateUTC)
set @StartTimeUTC = dateadd(MI,@UTCMIDiff,@StartDateUTC)
set @EndTimeUTC = dateadd(MI,@UTCMIDiff,@EndDateUTC)


select	
		c.CustID UserID,
		c.Email  Email,
		c.FName FirstName,
		c.LName LastName,
		c.Points  Points,
		c.ConsumerType UserType,
		substring(cp.Phone,1,3) AreaCode,
		convert(nvarchar(10),isnull(CDate.ConvertDate,c.CreateDate),101) RegistrationDate,			
		convert
		(
			nvarchar(10),
			(	case when isnull(CDate.ConvertDate,c.CreateDate) > epwmc.StartDate 
				then isnull(CDate.ConvertDate,c.CreateDate) 
				else null end) ,
			101
		) WelcomeEmailDate,
		(case when c.Active = 1 then '1' else '0' end) Status						
		from Customer c
		INNER JOIN dbo.UserOptIn uoi
		ON c.custid = uoi.custid
		left join CustomerPhone cp
		on c.CustID = cp.CustID
		and cp.IsPrimary = 1		
		left join	(	select		min(ctcl.ConvertDate) ConvertDate, ctcl.CustID 
						from		ConsumerTypeConvertLog ctcl
						inner join	Customer tcr
						on			ctcl.CustID = tcr.CustID
						where		ctcl.NewConsumerTypeID = 1
						and			ctcl.OriginalConsumerTypeID = 8
						and			ctcl.CallerID is null
						group by ctcl.CustID
		) CDate
		on c.CustID = CDate.CustID
		left join EmailProviderWelcomeMailConfig epwmc
		on c.MetroAreaID = epwmc.MetroAreaID		
		where	c.ConsumerType in (1,4,5,8)
		and		(
					c.UpdatedUTC between @StartTimeUTC and @EndTimeUTC
					or
					cp.UpdatedUTC between @StartTimeUTC and @EndTimeUTC
				)
		and		len(ltrim(rtrim(c.Email))) > 0
union all
select
		c.CallerID * -1 UserID,
		c.Email Email,
		c.FName FirstName,
		c.LName LastName,
		c.Points,
		c.ConsumerType UserType,
		substring(cp.Phone,1,3) AreaCode,
		convert(nvarchar(10),isnull(CDate.ConvertDate,c.CreateDate),101) RegistrationDate,
		convert
		(
			nvarchar(10),	
			(case when isnull(CDate.ConvertDate,c.CreateDate) > epwmc.StartDate then isnull(CDate.ConvertDate,c.CreateDate) else null end),
			101
		) WelcomeEmailDate,
		(case when c.CallerStatusID = 1 then '1' else '0' end) Status			
		from Caller c	
		left join CallerPhone cp
		on c.CallerID = cp.CallerID
		and cp.IsPrimary = 1
		left join	(	select		min(ctcl.ConvertDate) ConvertDate, ctcl.CallerID 
						from		ConsumerTypeConvertLog ctcl
						inner join	Caller tcx
						on			ctcl.CallerID = tcx.CallerID
						where		ctcl.NewConsumerTypeID = 1
						and			ctcl.OriginalConsumerTypeID = 8
						and			ctcl.CallerID is null
						group by	ctcl.CallerID
		) CDate
		on c.CallerID = CDate.CallerID						
		left join EmailProviderWelcomeMailConfig epwmc
		on c.MetroAreaID = epwmc.MetroAreaID
		where	c.ConsumerType in (1,4,5)
		and		c.PositionID != 2 --Exclude concierge users
		and		(
					c.UpdatedUTC between @StartTimeUTC and @EndTimeUTC
					or
					cp.UpdatedUTC between @StartTimeUTC and @EndTimeUTC
				)
		and		len(ltrim(rtrim(c.Email))) > 0
GO			
		

GRANT EXECUTE ON [SvcGetDailyUserFeedChanges] TO ExecuteOnlyRole
GO
