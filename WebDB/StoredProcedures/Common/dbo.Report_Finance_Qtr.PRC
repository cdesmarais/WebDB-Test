if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Finance_Qtr]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Finance_Qtr]
GO

CREATE Procedure dbo.Report_Finance_Qtr
(
	@dateoffset int = Null
)
AS

set transaction isolation level read uncommitted


If @dateoffset Is null
	Begin
	Select @dateoffset = Day(getdate())
	End

Declare @Rmonth nvarchar(2), @RYear nvarchar(4)
Select @RMonth = Convert(nvarchar(2),Month(getdate()-@dateoffset))
Select @RYear = Convert(nvarchar(4),Year(getdate()-@dateoffset))

delete from FinanceExtract
Insert into FinanceExtract(  ResID
							,RID
							,RName
							,Address1
							,Address2
							,City
							,State
							,Zip
							,RestaurantPhone
							,CustID
							,FName
							,LName
							,CFName
							,CLName
							,SeatedSize
							,Points
							,Incentive
							,ShiftDate
							,ResTime,DateMade,PartnerName,PartnerID,hotelname,ReferrerName,ReferrerID,Resotype,ReportDate)

select r.ResID, rts.RID, rts.name, rts.Address1, rts.Address2, rts.city, rts.state, rts.Zip, rts.Phone,
	r.CustID,
	(Case when(r.CallerID is null) Then OTReal.FName Else OTCallCust.FName End) as first_name,
	(Case when(r.CallerID is null) Then OTReal.LName Else OTCallCust.LName End) as last_name,
	(Case when(r.CallerID is not null and OTCall.PositionID = 2) Then OTCall.FName Else 'none' End) as Cfirst,
	(Case when(r.CallerID is not null and OTCall.PositionID = 2) Then OTCall.LName Else 'none' End) as Clast,
	(Case when(coalesce(r.SeatedSize,0) < 1) Then r.PartySize Else r.SeatedSize End) as ResoSize,
	(Case when(OTCall.PositionID = 2) Then '100' Else r.ResPoints End) as points,
	(Case when(Len(r.IncentiveID) > 0) Then 'Y' Else 'N' End) as incentive,
	r.ShiftDate,
	r.ResTime,
	r.DateMade,
	OTPart.MetroAreaName as PartnerName,
	OTPart.PartnerID,
	OTComp.name as Hotel,
	(Case when(Len(OTRef.ReferrerID) > 0) Then OTRef.name Else 'none' End) as RefName,
	(Case when(Len(OTRef.ReferrerID) > 0) Then Cast(OTRef.ReferrerID as nvarchar(6)) Else 'none' End) as ReferrerID,
	(Case when(OTCall.PositionID = 2) Then 'Concierge'
	      when(OTCall.PositionID = 3) Then 'Admin Assitant'
	      when(OTCall.PositionID = 4) Then 'Travel' Else 'OT_Customer' End) as ResoType,
	Convert(nvarchar,(@RMonth+'/'+@RYear)) as ReportDate
from Reservation r
	inner join Restaurant rts on r.RID = rts.RID
	inner join Neighborhood n on rts.NeighborhoodID = n.NeighborhoodID
	inner join partner OTPart on r.PartnerID = OTPart.PartnerID
	left join Customer OTReal on r.CustID = OTReal.CustID
	left join CallerCustomer OTCallCust on r.CustID = OTCallCust.CustID
	left join Caller OTCall on r.CallerID = OTCall.CallerID
	left join company OTComp on OTCall.CompanyID = OTComp.CompanyID
	left join referrer_Reservation OTRefRes on r.ResID = OTRefRes.ResID
	left join referrer OTRef on OTRefRes.ReferrerID = OTRef.ReferrerID
where
	datediff(m,ShiftDate,getdate() - @dateoffset) between 0 and 2
	and r.RStateID not in (3,4,8,9,10)
	and n.MetroAreaID <> 1
order by RefName, ResoType, rts.RID

Select 	RID,
	RName,
	Address1,
	Address2,
	city,
	state,
	zip,
	RestaurantPhone,
	CustID,
	FName,
	LName,
	SeatedSize,
	points,
	incentive,
	DateMade,
	ShiftDate,
	ResTime,
	PartnerID,
	PartnerName,
	ReferrerID,
	ReferrerName,
	HotelName,
	(Case When(CFName = 'none') then 'none' else CFName+' ' +CLName end) as ConciergeName
From FinanceExtract

GO


GRANT EXECUTE ON [Report_Finance_Qtr] TO ExecuteOnlyRole

GO
