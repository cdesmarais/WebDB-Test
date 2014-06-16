if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobFinanceExtractAsia]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobFinanceExtractAsia]
GO


create  Procedure [dbo].[JobFinanceExtractAsia]

AS

--*************************************************
--This is obsolete.
--The last data insert with this proc was in Dec 2008
--*************************************************

set nocount on
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

Declare @dateoffset int
Declare @ReportDT datetime
	   ,@LastDayOfLastMonth smalldatetime

Select @dateoffset = Day(getdate())
select @ReportDT = getdate()

Declare @Rmonth varchar(2)
      , @RYear varchar(4)
Select  @RMonth = Convert(varchar(2),Month(getdate()-@dateoffset))
Select  @RYear  = Convert(varchar(4),Year(getdate()-@dateoffset))

Select @ReportDT = (CAST(STR(MONTH(@ReportDT ))+'/'+STR(01)+'/'+STR(YEAR(@ReportDT )) AS DateTime))
 --Get first day of the month
select @ReportDT = Dateadd(m, -1,@ReportDT)
select @LastDayOfLastMonth = dateadd(d, -1, DateAdd(m, 1, @ReportDT))

truncate table FinanceExtract



Insert into FinanceExtract(resid
                          , rid
                          , rname
                          , address1
                          , address2
                          , city
                          , state
                          , zip
                          , restaurantphone
                          , custid
                          , fname
                          , lname
                          , cfname
                          , clname
                          , CallerID
                          , seatedsize
                          , points
                          , incentive
                          , shiftdate
                          , restime
                          , datemade
                          , partnername
                          , partnerid
                          , hotelname
                          , referrername, referrerid
                          , resotype
                          , reportdate
                          , MetroAreaID
                          , MetroAreaName
                          , RStateID
                          ,referral
		,firstTime
		,DisputeFlag
		,PrimarySourceID
		,PrimarySourceType
		,country
		,SFname
		,SLname
)

select   distinct OTRes.ResID
, OTRaunts.RID
, OTRaunts.Rname
, OTRaunts.address1
, OTRaunts.address2
, OTRaunts.city
, OTRaunts.state
, OTRaunts.zip
, OTRaunts.phone
, OTRes.CustID
, (Case when(OTRes.CallerID is null) 
          Then OTReal.FName 
        Else OTCallCust.FName 
   End) 
   as FirstName
, (Case when(OTRes.CallerID is null) Then replace(OTReal.LName, '	','') 
        Else replace(OTCallCust.LName, '	','') 
   End) as LastName

, (Case when(OTRes.CallerID is not null) Then OTCall.FName 
        Else 'none' 
   End) as Cfirst
, (Case when(OTRes.CallerID is not null) Then OTCall.LName 
        Else 'none' 
   End) as Clast
, (Case when(OTRes.CallerID is not null) Then OTCall.CallerID 
        Else Null 
   End) as CallerID
, (Case when(coalesce(OTRes.seatedsize,0) < 1) Then OTRes.partysize 
        Else OTRes.seatedsize 
   End) as ResoSize
, (Case when(OTCall.positionID = 2) Then '100' 
        Else OTRes.respoints 
   End) as points
, (Case when(Len(OTRes.incentiveID) > 0) Then 'Y' 
        Else 'N' 
   End) as incentive
, OTRes.shiftDate
, OTRes.restime
, OTRes.dateMade
, OTPart.PartnerName as PartnerName
, OTPart.partnerID
, OTComp.CompanyName as Hotel
, (Case when(Len(OTRef.referrerid) > 0) Then OTRef.ReferrerName 
        Else 'none' 
   End) as RefName
, (Case when(Len(OTRef.referrerid) > 0) Then Cast(OTRef.referrerid as varchar(6)) 
        Else 'none' 
   End) as referrer_id
, (Case when(OTCall.PositionID = 2) Then 'Concierge'
	when(OTCall.PositionID = 3) Then 'Admin Assitant'
	when(OTCall.PositionID = 4) Then 'Travel' 
        Else 'OT_Customer' 
   End) as Reso_Type
, Convert(varchar,(@RMonth+'/'+@RYear)) as report_date
,OTArea.MetroAreaID
,OTArea.MetroAreaName
,OTRes.RStateID
,case 
   when 
	/*NEW Added to determine true restaurant referral reservations-- Jon H---*/
	(OTRes.PartnerID in (1,21,26,27) ) and
    (otRef.referrerid is null or otRef.referrerid = 639) and
	OTRes.ResID = rrr.ResID and OTRes.RID = rrr.RID
     then 1
     else 0
   end as Referral
,OTRes.FirstTime as firstTime
,(Case when (OTRes.RStateID=6 or OTRes.RStateID=7  ) Then 1
        Else 0
   End) as DisputeFlag
/*NEW Added to track true source of referral-- Jon H---*/
,(Case when (OTRes.partnerID >1) Then OTRes.PartnerID
	   when (OTRes.partnerID <2 and otRef.referrerid is not null and otRef.referrerid <> 639) Then otRef.referrerid
	   when (OTRes.partnerID <2 and (otRef.referrerid is null or otRef.referrerid = 639) and
		OTRes.ResID = rrr.ResID and OTRes.RID = rrr.RID) Then OTRes.RID
       Else 0
   End) as PrimarySourceID
,(Case when (OTRes.partnerID >1) Then 'PartnerID'
	   when (OTRes.partnerID <2 and otRef.referrerid is not null and otRef.referrerid <> 639) Then 'RefID'
	   when (OTRes.partnerID <2 and (otRef.referrerid is null or otRef.referrerid = 639)and
		OTRes.ResID = rrr.ResID and OTRes.RID = rrr.RID) Then 'RestRef'
      Else 'None'
   End) as PrimarySourceType
, OTRaunts.Country
, (Case when(OTRes.CallerID is null) 
          Then OTReal.SFName 
        Else OTCallCust.SFName 
   End) 
   as SFirstName
, (Case when(OTRes.CallerID is null) Then replace(OTReal.SLName, '	','') 
        Else replace(OTCallCust.SLName, '	','') 
   End) as SLastName


from       reservation OTRes
inner join restaurantVW OTRaunts 
on         OTRes.RID      = OTRaunts.RID
inner join neighborhoodAVW OTHood 
on         OTRaunts.neighborhoodid = OTHood.neighborhoodid
and		   OTRaunts.LanguageID = OTHood.LanguageID
inner join MetroAreaAVW OTArea 
on         OTHood.MetroAreaID     = OTArea.MetroAreaID
and		   OTHood.LanguageID = OTArea.LanguageID
inner join partner OTPart 
on         OTRes.partnerid         = OTPart.partnerid 
left join  customer OTReal 
on         OTRes.CustID        = OTReal.CustID
left join  callercustomer OTCallCust 
on         OTRes.CustID        = OTCallCust.CustID
left join  caller OTCall 
on         OTRes.CallerID          = OTCall.CallerID
left join  company OTComp 
on         OTCall.companyid        = OTComp.companyid
left join  ReferrerReservationVW OTRefRes 
on         OTRes.ResID     = OTRefRes.ResID
left join  referrer OTRef 
on         OTRefRes.referrerID     = OTRef.referrerID
left join  ReferrerRestaurantReservationVW rrr
on         OTRes.ResID     = rrr.ResID 
and        OTRes.RID      = rrr.RID
where      datediff(m,ShiftDate,getdate() - @dateoffset) =  0
and OTRes.RStateID in(1,2,5,6,7)
and OTArea.MetroAreaID <> 1

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
Select 	
FE.rid 'RestID'
,@LastDayOfLastMonth 'Month'
,Day(@LastDayOfLastMonth) 'Day'
,rname 'RestName'
,address1 'Address1'
,case 
 when address2 ='' then '   '
 else coalesce(address2,'   ') end  'Address2'
,city 'City'
,state 'State'
,zip 'Postal Code'
,restaurantphone 'Phone'
,custid 'Customer ID'
,fname 'FirstName'
,lname 'Last Name'
,seatedsize 'Party Size'
,points 'Points for Reso'
,incentive 'IsIncentive'
,datemade 'Date Made'
,shiftdate 'Shift Date'
,restime 'Reservation Time'
,partnerid 'Partner ID'
,partnername 'Partner Name'
,referrerid 'Referrer_ID'
,referrername 'Referrer'
,hotelname 'Hotel'
,(Case When(cFName = 'none') then 'none' else cFName+' ' +cLName end) 'Concierge Name',
/*****************************************************************************************
These 2 fields need to be added in the text file that is created
*****************************************************************************************/
	(Case When(cFName = 'none') then 0 else CallerID end)  'Caller_ID',
	(Case When(cFName = 'none') then 'none' else ResoType end)  'Caller Type'
/*****************************************************************************************/
,ReportDate     'Report Date'
,metroAreaID   'Metro Area ID'
,metroAreaName 'Metro Area Name'
,cast(Referral as int) 'Referral'
	--,(Case When(resState = 6) then 'Disputed' else 'Resolved Disputed' end) as ResState
,firstTime 'First Time'
,DisputeFlag 'DisputeFlag'
,PrimarySourceID 'PrimarySourceID'
,PrimarySourceType 'PrimarySourceType'
,cast(x.FirstBookedDate as varchar(12)) 'FirstBookedDate'
,Country
,SFname
,SLname
From     FinanceExtract FE
/****************************************************************************************
Added Join to Reservation table to determin FirstBookedDate per each Restaurant
*****************************************************************************************/
inner join 
(select rid, min(datemade) as FirstBookedDate from reservation 
group by rid) x
on FE.rid = x.rid
order by Points



GO



GRANT EXECUTE ON [JobFinanceExtractAsia] TO ExecuteOnlyRole

GO
