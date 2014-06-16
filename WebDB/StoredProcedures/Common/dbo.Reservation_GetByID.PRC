if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetByID]
GO

CREATE Procedure dbo.Reservation_GetByID
 (
  @ReservationID int,
  @IsCaller int=0
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

if (@IsCaller=0)
Begin
SELECT res.ShiftDate + 2 + res.ResTime AS ResDateTime,
    res.PartySize AS PartySize,
    res.ContactPhone AS Phone,
    res.ConfNumber AS Confirmation,
    coalesce(res.CallerID,0) AS CallerID,
    p.Parking AS Parking
    ,coalesce(r.Address1,' ') as Address1
    ,coalesce(r.Address2,' ') as Address2
    ,r.City As City
    ,r.State As State
    ,r.Zip AS ZipCode,
    r.RName AS RestaurantName,coalesce(r.CrossStreet,'') As CrossStreet,
    r.RID AS RestaurantID,
    r.Phone AS RestaurantPhone,
    res.RStateID AS ReservationState,
    res.InviteMessage AS Message,
    res.CustID AS UserID,
    c.FName AS FirstName,
    c.LName AS LastName,
    c.SFName AS FirstName_phonetic,
    c.SLName AS LastName_phonetic,
    c.EMail as EMail,
    ma.metroareaid as Metro_Area_ID,
    res.FirstTime as First_Time,
    res.Business as Business,
    res.UseDiningCheque as Use_Dining_Cheque,
    res.Notes as Notes,
    res.ResPoints as Points
    ,coalesce(rcm.Message,'') 	 AS Rest_Message
	,convert(nvarchar,res.ShiftDate,110) as Shift_Date
    ,coalesce(rm.RMDesc,' ') As Description
    ,coalesce(res.LargeParty,0) As largeparty
    ,coalesce(CreditCardLastFour,0) as Card_Number
    ,ma.MetroAreaName as MetroName
    ,ps.code
    ,ConsumerType as Consumer_Type
    ,'' as Password
	,l.LanguageCode as Culture
	,(case when reservOfferVw.OfferClassID is not null then 'VV' else 'No' end) as VVOffer
FROM		Customer c
INNER JOIN	(SELECT TOP 1 * FROM Reservation WHERE ResID=@ReservationID ) res
ON			c.CustID = res.CustID 
INNER JOIN	RestaurantAVW r
ON			r.RID = res.RID
and			r.LanguageID = res.LanguageID
LEFT JOIN	ParkingLocal p
ON			p.ParkingID = r.ParkingID 
and			p.LanguageID = res.LanguageID
INNER JOIN	NeighborhoodAVW n 
on			n.NeighborhoodID = r.NeighborhoodID
and			n.LanguageID = res.LanguageID
INNER JOIN	MetroAreaAVW ma
on			ma.MetroAreaID = n.MetroAreaID
and			ma.LanguageID = res.LanguageID
inner join	RestaurantMessageAVW rm
on			rm.RID = r.RID
and			rm.LanguageID = res.LanguageID
LEFT JOIN	PromoReservations pr
on			res.ResID = pr.ResID
LEFT JOIN	Promos ps
on			pr.PromoID = ps.PromoID
left join   RestaurantCustomMessage rcm
on          rcm.RID = r.RID
and			rcm.LanguageID = res.LanguageID
and         rcm.MessageTypeID = 10
inner join	language l
on			res.languageID = l.languageID
left join	ReservationOffer reservOffer
on			reservOffer.ResID = @ReservationID
left join	ReservationOfferVW reservOfferVw
on			reservOffer.OfferID = reservOfferVw.OfferID
and			reservOfferVw.OfferClassID = 3


End

if(@IsCaller <> 0)

Begin
SELECT res.ShiftDate + 2 + res.ResTime AS ResDateTime,
    res.PartySize AS PartySize,
    res.ContactPhone AS Phone
    ,res.ConfNumber AS Confirmation
    ,coalesce(res.CallerID,0) AS CallerID
    ,p.Parking AS Parking
    ,coalesce(r.Address1,' ') as Address1
    ,coalesce(r.Address2,' ') as Address2
    ,r.City As City
    ,r.State As State,
    r.Zip AS ZipCode,
    r.RName AS RestaurantName
    ,coalesce(r.CrossStreet,'') As CrossStreet,
    r.RID AS RestaurantID,
    r.Phone AS RestaurantPhone,
    res.RStateID AS ReservationState,
    res.InviteMessage AS Message,
    res.CustID AS UserID,
    cc.FName AS FirstName,
    cc.LName AS LastName,
    cc.SFName AS FirstName_phonetic,
    cc.SLName AS LastName_phonetic,
    cc.EMail as EMail,
    ma.metroareaid as Metro_Area_ID,
    res.FirstTime as First_Time,
    res.Business as Business,
    res.UseDiningCheque as Use_Dining_Cheque,
    res.Notes as Notes,
    res.ResPoints as Points
    ,coalesce(rcm.Message,'') 	 AS Rest_Message
	,convert(nvarchar,res.ShiftDate,110) as Shift_Date
    ,coalesce(rm.RMDesc,' ') As Description
    ,ca.FName As Admin_First
    ,ca.LName As Admin_Last
    ,ca.Email As AdminEmail
    ,res.LargeParty As largeparty
    ,coalesce(CreditCardLastFour,0) as card_number
    ,ma.MetroAreaName as MetroName
    ,ps.code
    ,ConsumerType as Consumer_Type
    ,'' as Password
	,l.LanguageCode as Culture
	,(case when reservOfferVw.OfferClassID is not null then 'VV' else 'No' end) as VVOffer
FROM			CallerCustomer cc
INNER JOIN	(SELECT TOP 1 * FROM Reservation WHERE ResID=@ReservationID) res
ON				cc.CustID = res.CustID 
INNER JOIN		Caller ca
ON				cc.CallerID=ca.CallerID 
INNER JOIN	RestaurantAVW r
ON			r.RID = res.RID
and			r.LanguageID = res.LanguageID
LEFT JOIN	ParkingLocal p
ON			p.ParkingID = r.ParkingID 
and			p.LanguageID = res.LanguageID
INNER JOIN	NeighborhoodAVW n 
on			n.NeighborhoodID = r.NeighborhoodID
and			n.LanguageID = res.LanguageID
INNER JOIN	MetroAreaAVW ma
on			ma.MetroAreaID = n.MetroAreaID
and			ma.LanguageID = res.LanguageID
inner join	RestaurantMessageAVW rm
on			rm.RID = r.RID
and			rm.LanguageID = res.LanguageID
LEFT JOIN	PromoReservations pr
on			res.ResID = pr.ResID
LEFT JOIN	Promos ps
on			pr.PromoID = ps.PromoID
left join   RestaurantCustomMessage rcm
on          rcm.RID = r.RID
and			rcm.LanguageID = res.LanguageID
and         rcm.MessageTypeID = 10
inner join	language l
on			res.languageID = l.languageID
left join	ReservationOffer reservOffer
on			reservOffer.ResID = @ReservationID
left join	ReservationOfferVW reservOfferVw
on			reservOffer.OfferID = reservOfferVw.OfferID
and			reservOfferVw.OfferClassID = 3


End

GO


GRANT EXECUTE ON [Reservation_GetByID] TO ExecuteOnlyRole

GO
