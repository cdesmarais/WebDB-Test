if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobSetVIPStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobSetVIPStatus]
GO

CREATE Procedure dbo.JobSetVIPStatus
As
SET NOCOUNT ON
SET transaction isolation level read uncommitted

--******
--** Set Current Year
--******
Declare @ThisYear nvarchar(50)
Set @ThisYear = YEAR(getdate())
Set @ThisYear = cast(('1/1/' + @ThisYear) as datetime)

--******
--** Retrieve Last Run Date
--******
Declare @RunDT datetime
set @RunDT = getdate()

Declare @LastRunDT datetime
select	@LastRunDT = ValueDT
from	ValueLookUP
where	LType = 'DATABASE'
and		lKey = 'JobSetVIPStatus_LastRun'	

set @LastRunDT = IsNull(@LastRunDT, getdate() - 1)


--*************************
--** Temp storage for new VIPs
--*************************
declare @CustomerVIP table (
	CustID int primary key,
	ConsumerType int,	
	Resos int
) 

declare @CallerVIP table (
	CallerID int primary key,
	ConsumerType int,
	Resos int
) 

--***************************************
--** Identify New VIPs
--***************************************
insert into @CustomerVIP
	select	r.custid, 
			c.ConsumerType, 
			count(r.resid)
	from Reservation r with (nolock)
	inner join (
		-- Users who are eligible for VIP since teh last run
		select	custID, ConsumerType
		from	Customer
		where	LastPointsGainDate > @LastRunDT -- Reso Seated after last run
		and		ConsumerType not in (4,5,8,9) -- Consumer not already a VIP and not anonymous
	) c
	on 		r.CustID = c.custid
	and 	r.callerid is null
	where 	ShiftDate between @ThisYear and @RunDT + 1
	and 	RStateID not in (1,3,4) 
	and 	ResPoints > 0 
	group by r.CustID, 
			ConsumerType
	having 	count(r.resid) >= 12

insert into @CallerVIP
	select	r.CallerID, 
			c.ConsumerType,
			count(r.resid)
	from Reservation r with (nolock)
	inner join (
		-- Users who are eligible for VIP since teh last run
		select	CallerID, ConsumerType
		from	Caller
		where	LastPointsGainDate > @LastRunDT -- Reso Seated after last run
		and		ConsumerType not in (4,5,8,9) -- Consumer not already a VIP and not anonymous
	) c
	on		 	r.CallerID = c.CallerID
	where 		ShiftDate between @ThisYear and @RunDT + 1
	and 		RStateID not in (1,3,4) 
	and 		ResPoints > 0 
	group by 	r.CallerID,
				ConsumerType
	having 		count(r.resid) >= 12
	
--***********************************************
--** Set VIPs
--***********************************************
update Customer set ConsumerType = 4
from customer
inner join @CustomerVIP cv
on Customer.custid = cv.custID

update Caller set ConsumerType = 4
from Caller
inner join @CallerVIP cv
on Caller.CallerID = cv.CallerID


--***********************************************
--** Track Changes
--***********************************************
INSERT INTO ConsumerTypeConvertLog 	
	(	CustID,
		CallerID,
		OriginalConsumerTypeID,
		NewConsumerTypeID,
		ConvertDate
	)
	select custID,
			null,
			ConsumerType,
			4,
			@RunDT
	from @CustomerVIP
			

INSERT INTO ConsumerTypeConvertLog 	
	(	CustID,
		CallerID,
		OriginalConsumerTypeID,
		NewConsumerTypeID,
		ConvertDate
	)
	select null,
			CallerID,
			ConsumerType,
			4,
			@RunDT
	from @CallerVIP


--*****************************************
--** Update the last run date
--*****************************************
update	ValueLookUP set ValueDT = @RunDT
where	LType = 'DATABASE'
and		lKey = 'JobSetVIPStatus_LastRun'	

GO

GRANT EXECUTE ON [JobSetVIPStatus] TO ExecuteOnlyRole

GO
