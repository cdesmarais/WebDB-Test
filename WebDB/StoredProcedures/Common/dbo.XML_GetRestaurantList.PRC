if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_GetRestaurantList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_GetRestaurantList]
GO

CREATE PROCEDURE dbo.XML_GetRestaurantList

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @offer nvarchar(50)
, @Offerstr nvarchar(255)
, @RestaurantID int
, @RestaurantID_comp int
, @payment nvarchar(50)
, @paymentStr nvarchar(255)
, @food nvarchar(50)
, @counter int

-- Create a table to dump the massaged cursor data into here
declare @CursorTable TABLE 
(
	[RID] [int] NOT NULL ,
	[Offers] [nvarchar] (255) NULL ,
	[PaymentType] [nvarchar] (255) NULL,
	[FoodType1] [nvarchar] (30) NULL,
	[FoodType2] [nvarchar] (30) NULL,
	[FoodType3] [nvarchar] (30) NULL
)

--#################### Cursor #1 for the Restaurant offer options ########################################################3
Declare CursorTest CURSOR
GLOBAL
FOR
	Select Offers.RID
			, o.offer
	From		Offers 
	inner join	RestaurantVW r 
	on			Offers.RID = r.RID
	inner join	OfferLocal o 
	on			Offers.OfferID = o.OfferID
	and			o.LanguageID = r.LanguageID
	Where r.RestStateID = 1
	Order By Offers.RID, o.Offer

OPEN CursorTest
FETCH NEXT FROM CursorTest INTO @RestaurantID, @offer
SELECT @RestaurantID_comp = @RestaurantID
SELECT @Offerstr = ''

WHILE (@@FETCH_STATUS = 0)
	BEGIN
	WHILE (@@FETCH_STATUS = 0) AND (@RestaurantID_comp = @RestaurantID)
		BEGIN
		IF (@Offerstr = '')
			BEGIN
			SELECT @Offerstr = @offer
			END
		ELSE
			BEGIN
			SELECT @Offerstr = @Offerstr + ',' + @offer
			END
		FETCH NEXT FROM CursorTest INTO @RestaurantID, @offer
		END
	INSERT INTO @CursorTable(RID, Offers)
	VALUES(@RestaurantID_comp, @Offerstr)
	SELECT @RestaurantID_comp = @RestaurantID
	SELECT @Offerstr = @offer
	FETCH NEXT FROM CursorTest INTO @RestaurantID, @offer
	END

 CLOSE CursorTest
 DEALLOCATE CursorTest

--############################### Cursor #2 for the Restaurant payment types ############################################################
Declare CursorTest CURSOR
GLOBAL
FOR
	Select PaymentTypes.RID, pt.PaymentType
	From		PaymentTypes 
	inner join	RestaurantVW r 
	on			PaymentTypes.RID = r.RID
	inner join	PaymentTypeLocal pt 
	on			PaymentTypes.PaymentTypeID = pt.PaymentTypeID
	and			r.LanguageID = pt.LanguageID
	Where		r.RestStateID = 1
	Order By PaymentTypes.RID, pt.PaymentType

OPEN CursorTest
FETCH NEXT FROM CursorTest INTO @RestaurantID, @payment
SELECT @RestaurantID_comp = @RestaurantID
SELECT @paymentStr = ''

WHILE (@@FETCH_STATUS = 0)
	BEGIN
	WHILE (@@FETCH_STATUS = 0) AND (@RestaurantID_comp = @RestaurantID)
		BEGIN
		IF (@paymentStr = '')
			BEGIN			
			SELECT @paymentStr = @payment
			END
		ELSE
			BEGIN
			SELECT @paymentStr = @paymentStr + ',' + @payment
			END
		FETCH NEXT FROM CursorTest INTO @RestaurantID, @payment
		END
	IF NOT EXISTS(select RID from @CursorTable Where RID = @RestaurantID_comp)
		BEGIN
		INSERT INTO @CursorTable(RID, PaymentType)
		VALUES(@RestaurantID_comp, @paymentStr)
		END
	ELSE
		BEGIN
		UPDATE @CursorTable
		SET PaymentType = @paymentStr
		WHERE RID = @RestaurantID_comp
		END

	SELECT @RestaurantID_comp = @RestaurantID
	SELECT @paymentStr = @payment
	FETCH NEXT FROM CursorTest INTO @RestaurantID, @payment
	END

 CLOSE CursorTest
 DEALLOCATE CursorTest

--################# Cursor #3 for the Restaurant food types ##########################################################
Declare CursorTest CURSOR
GLOBAL
FOR
	Select FoodTypes.RID
       ,ft.FoodType as Value
	From		FoodTypes 
	inner join	RestaurantVW r 
	on			FoodTypes.RID = r.RID
	inner join	FoodType ft
	on			FoodTypes.FoodTypeID = ft.FoodTypeID
	and			r.LanguageID = ft.LanguageID
	Where r.RestStateID = 1
	Order By FoodTypes.RID,FoodTypes.IsPrimary,ft.FoodType

OPEN CursorTest
FETCH NEXT FROM CursorTest INTO @RestaurantID, @food
SELECT @RestaurantID_comp = @RestaurantID

WHILE (@@FETCH_STATUS = 0)
	BEGIN
	SELECT @counter = 1
	WHILE (@@FETCH_STATUS = 0) AND (@RestaurantID_comp = @RestaurantID)
		BEGIN
		IF NOT EXISTS(select RID from @CursorTable Where RID = @RestaurantID_comp)
			BEGIN
			IF (@counter = 1)
				BEGIN
				INSERT INTO @CursorTable(RID, FoodType1)
				VALUES(@RestaurantID_comp, @food)
				END
			IF (@counter = 2)
				BEGIN
				INSERT INTO @CursorTable(RID, FoodType2)
				VALUES(@RestaurantID_comp, @food)
				END
			IF (@counter = 3)
				BEGIN
				INSERT INTO @CursorTable(RID, FoodType3)
				VALUES(@RestaurantID_comp, @food)
				END
			END
		ELSE
			BEGIN
			IF (@counter = 1)
				BEGIN
				UPDATE @CursorTable
				SET FoodType1 = @food
				WHERE RID = @RestaurantID_comp
				END
			IF (@counter = 2)
				BEGIN
				UPDATE @CursorTable
				SET FoodType2 = @food
				WHERE RID = @RestaurantID_comp
				END
			IF (@counter = 3)
				BEGIN
				UPDATE @CursorTable
				SET FoodType3 = @food
				WHERE RID = @RestaurantID_comp
				END
			END
		FETCH NEXT FROM CursorTest INTO @RestaurantID, @food
		SELECT @counter = @counter + 1
		END
	SELECT @RestaurantID_comp = @RestaurantID
	END

 CLOSE CursorTest
 DEALLOCATE CursorTest

declare @Confirmation int
exec DNGetMessageTypeID 'Confirmation',@Confirmation output


Select r.RID as restaurant_ID
, r.RName as RestName
, r.address1
, r.CrossStreet as cross_street
, r.city
, r.state
, r.Zip
, p.parking as parking
, r.phone
,coalesce(rm.PublicTransit, ' ') as PublicTransit
, rm.hours
, ct.FoodType1 as food_type1
, coalesce(ct.FoodType2, ' ') as Food_Type2
, coalesce(ct.FoodType3, ' ') as Food_Type3
,n.NbhoodName as neighName
, m.MetroAreaID
, ct.Offers
,rm.RMDesc as Description
, d.DressCode as dresscode
, pq.PriceQuartile as price
,ct.PaymentType
, Smoking.Smoking as smoking
,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation)) 'ConfirmationMessage'

from		RestaurantVW r
inner join	RestaurantMessageAVW rm
on			r.RID = rm.RID
and			rm.LanguageID = r.LanguageID
inner join	neighborhoodAVW n 
on			r.NeighborhoodID = n.NeighborhoodID
and			r.LanguageID = n.LanguageID
inner join	DressCodeLocal d
on			r.DressCodeID = d.DressCodeID
and			r.LanguageID = d.LanguageID
INNER JOIN	PriceQuartileAVW pq
ON			r.PriceQuartileID=pq.PriceQuartileID 
AND			r.Country = pq.CountryID
and			r.LanguageID = pq.LanguageID
inner join	parkingLocal p
on			r.ParkingID = p.ParkingID
and			r.LanguageID = p.LanguageID
inner join	smoking 
on			r.SmokingID = smoking.SmokingID
inner join	MetroAreaAVW m
on			n.MetroAreaID = m.MetroAreaID
and			r.LanguageId = m.LanguageID
left join	@CursorTable ct
on			r.RID = ct.RID
left join	 RestaurantCustomMessage rcm
on           r.RID = rcm.RID
and          rcm.MessageTypeID = @Confirmation
and			rcm.LanguageID = r.LanguageID
Where r.RestStateID = 1 


GO

GRANT EXECUTE ON [XML_GetRestaurantList] TO ExecuteOnlyRole

GO
