if exists (select * from dbo.sysobjects where id = object_id(N'dbo.JobOLAPReservationExtractWebDB') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.JobOLAPReservationExtractWebDB
GO

-- Procedure adds/updates/deletes blocked dates
CREATE PROCEDURE dbo.JobOLAPReservationExtractWebDB
	@MinID int,
	@MaxID int
AS

set transaction isolation level read uncommitted
set nocount on

DECLARE @fmtonlyON BIT
SET @fmtonlyON = 0
IF 0=1

BEGIN
SET @fmtonlyON = 1	
END
SET FMTONLY OFF	

declare @RegionID int
select @RegionID = dbo.fGetRegionID()

declare @MinDate datetime
select	@MinDate = cast(getdate() -30 as date)

CREATE TABLE #Reservationtemp 
(
		ResID int
		,RegionID int
		,RID int
		,ERBVersionID int
		,DateMade datetime
		,Shiftdate datetime
		,UserTypeID int
		,RstateID int
		,PartnerID int
		,BillingTypeID int
		,PartySize int
		,IsCCReso int
		,Confnumber int
        ,UserWebID int
)

create table #ERBversion 
(
                RID int,
                ERBVersionID int,
                ERBVersion varchar (50) COLLATE SQL_Latin1_General_CP1_CI_AS,
                StartDT datetime,
                EndDT datetime,
)



declare @dbname sysname
SET @dbname = db_name()

If @dbname = 'WebDB' 
begin
Insert into #ERBversion
select          Null as RID
               ,ERBVersionID
               ,ErbVersion 
               ,Null as StartDT
               ,Null as EndDT
from [logserver_na].WebLOGDB.dbo.ERBVersion  
end
else if @dbname like 'WebDB_EU%' 
begin
Insert into #ERBversion
select          Null as RID
               ,ERBVersionID
               ,ErbVersion 
               ,Null as StartDT
               ,Null as EndDT
from [logserver_eu].WebLOGDB_EU.dbo.ERBVersion
end
else
begin
Insert into #ERBversion
select          Null as RID
               ,ERBVersionID
               ,ErbVersion 
               ,Null as StartDT
               ,Null as EndDT
from [logserver_asia].WebLOGDB_Asia.dbo.ERBVersion
end

update          e
set             e.RID = ee.RID,
				e.StartDT = ee.StartDate,
	            e.EndDT= ee.EndDate
from            #ERBVersion  e
inner join      ERBVersionHistory   ee
on              e.ERBVersion  COLLATE SQL_Latin1_General_CP1_CI_AS = ee.ERBVersion 



--**********************************
--** Gather unnormalized data and store in temp table
--**********************************



insert into #Reservationtemp 
select	r.ResID,
		@RegionID RegionID,
        r.RID,
		Null as ERBVersionID,
		r.DateMade,
		r.ShiftDate,
		Null as UserTypeID,
		r.RStateID,
		IsNull(r.PartnerID, 0) PartnerID,
		(case
			when BillingType = 'OTReso'	then 1
			when BillingType = 'DIPReso' then 2
			when BillingType = 'RestRefReso' then 3
			when BillingType = 'OfferReso' then 4
		end) as BillingTypeID,
		r.BillableSize PartySize,
		r.IsCCReso,
		r.ConfNumber,
        r.UserWebID
from	ReservationVW r
where	ResID > @MinID -- Only Retrieve data within a batch
and		ResID <= @MaxID -- Only Retrieve data within a batch   
and		ShiftDate >= @MinDate
and		ShiftDate >= '6/1/2010'

                                                                                    
--Get ERBVersionID
update          r
set             r.ErbVersionID=IsNull(e.ERBVersionID, 0)
from	        #Reservationtemp r
left join       #ERBversion e
on              r.rid = e.rid
and	            r.DateMade > e.StartDT 
and		        r.DateMade <= e.EndDT

update          r
set             r.UserTypeID=uw.UserTypeID
from            #Reservationtemp r
inner join      UserWebVW    uw
on              r.UserWebID  = uw.UserWebID 


IF	@fmtonlyON = 1 
BEGIN 
	SET FMTONLY ON 
END

--**********************************
--** Return normalized data
--**********************************

select          r.ResID,
                r.RegionID,
                r.RID,
                r.ERBVersionID,
                r.DateMade,
                r.ShiftDate,
                ISNULL(r.UserTypeID, 0)UserTypeID,
                r.RStateID,
                r.PartnerID,
                r.BillingTypeID,
                r.PartySize,
                r.IsCCReso,
		        r.ConfNumber             
from            #Reservationtemp r
order by		r.ResID

go


GRANT EXECUTE ON JobOLAPReservationExtractWebDB TO ExecuteOnlyRole

GO
