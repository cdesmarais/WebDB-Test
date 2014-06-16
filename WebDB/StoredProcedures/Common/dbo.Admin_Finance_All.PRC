if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_finance_all]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_finance_all]
GO


CREATE PROCEDURE dbo.Admin_finance_all
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

select 
			r.RID 'Restaurant_ID'
			,r.RName 'Restaurant_Name'
			,r.Address1
			,r.Address2
			,r.City
			,r.State
			,r.Zip
			,r.Phone 'Restaurant_Phone'
			,rs.CustID 'customer_id'
			,c.FName 'first_name'
			,c.LName 'last_name'
			,(Case when(coalesce(rs.SeatedSize,0) < 1) Then rs.PartySize Else rs.SeatedSize End) 'seated_size'
			,(Case when(ca.PositionID = 2) Then '100' Else rs.ResPoints End) 'Points'
			,(Case when(Len(rs.IncentiveID) > 0) Then 'Y' Else 'N' End) 'Incentive'
			,DateMade 'date_made'
			,rs.ShiftDate 'shift_date'
			,rs.ResTime 'reservation_time'
			,rs.DateMade 'date_made'
			,p.PartnerID 'partner_ID'
			,p.PartnerName 'Partner_Name'
			,re.ReferrerID 'referrer_id'
			,re.ReferrerName 'referrer_name'
			,CompanyName 'hotel_name'
			,(Case When(ca.FName is null) then 'none' else ca.FName+' ' +ca.LName end) as CallerName
			,coalesce(ca.CallerID,0) 'CallerID'
			,(Case when(ca.CallerID is null) Then 'none'
				   when(ca.PositionID = 2) Then 'Concierge'
				   when(ca.PositionID = 3) Then 'Admin Assitant'
				   when(ca.PositionID = 4) Then 'Travel' 
				   Else 'OT_Customer' End) 'CallerType'
			,Convert(nvarchar,(@RMonth+'/'+@RYear)) 'report_date'
			,n.MetroAreaID 'metro_area_id'
			,ma.MetroAreaName 'metro_area_name'
from         Reservation rs
inner join   RestaurantAVW r
on           rs.RID = r.RID
and			 rs.LanguageID = r.LanguageID
inner join   NeighborhoodAVW n 
on           r.NeighborhoodID = n.NeighborhoodID
and			 rs.LanguageID = n.LanguageID
and          n.MetroAreaID <> 1
inner join   MetroAreaLocal ma 
on           n.MetroAreaID = ma.MetroAreaID
and			 rs.LanguageID = ma.LanguageID
inner join   Partner p 
on           rs.PartnerID = p.PartnerID
left join    Customer c 
on           rs.CustID = c.CustID
left join    CallerCustomer cc 
on           rs.CustID = cc.CustID
left join    Caller ca 
on           rs.CallerID = ca.CallerID
left join    Company co 
on           ca.CompanyID = co.CompanyID
left join    ReferrerReservationVW rr 
on           rs.ResID = rr.ResID
left join    Referrer re 
on           rr.ReferrerID = re.ReferrerID
where        datediff(m,ShiftDate,getdate() - @dateoffset) =  0
and          rs.RStateID not in (3,4,8,9,10)

GO


GRANT EXECUTE ON [Admin_Finance_All] TO ExecuteOnlyRole

GO
