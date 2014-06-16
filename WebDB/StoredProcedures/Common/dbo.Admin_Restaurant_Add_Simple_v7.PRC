if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_Add_Simple_v7]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_Add_Simple_v7]
GO

CREATE Procedure dbo.Admin_Restaurant_Add_Simple_v7
(
    /*Restaurant*/
    @RestaurantName nvarchar(255),
    @NeighborhoodID int,
    @DomainID int,
    @Allotment bit,
    @RestaurantType char(1),
    @BrandID INT,
    @IsConnectFieldTest bit,
    @retval int OUTPUT,
    @ShowThirdPartyMenu bit
)

As
-- 
-- This v3 version initializes the new MinCCOnlineOption column (WR2009R4 TT 25524)
-- It continues to set the soon-to-be-depracated MaxOnlineOptionID
-- 
SET NOCOUNT ON

Declare @RestaurantID INT
Declare @TZID INT, @CountryID AS CHAR(2)

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int

set @ProcName = 'Admin_Restaurant_Add_Simple'

--*******************************
--** Get Language, Domain, Country and Time Zone
--*******************************
set @Action = 'Retrieve LanguageID'

declare @LanguageID int

Select		@TZID = [TZID],
		@CountryID = [CountryID]
FROM 		[MetroArea] m
INNER JOIN 	[Neighborhood] n 
ON 		m.[MetroAreaID] = n.[MetroAreaID]
WHERE 		n.[NeighborhoodID] = @NeighborhoodID

if @DomainID = 0
BEGIN
	SELECT TOP 1 @DomainID = d.DomainID
	FROM [Domain] d
	INNER JOIN DBUser u
	ON u.DBUSer = User  
	AND   IsNull(u.DomainID, d.DomainID) = d.DomainID  
	WHERE active = 1 AND d.DomainID <> 0
	-- When there is more than 1 domain give the lower DomainID priority (special case for US)
	ORDER BY d.domainid asc
END

SELECT @LanguageID = PrimaryLanguageID
FROM [Domain]
WHERE DomainID = @DomainID


--*******************************
--** Get Temporary ReserveCode
--*******************************
declare @RandomString as varchar(8)
SELECT @RandomString = UPPER(LEFT(NEWID(),8))


SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION




--**************************************
--** Insert Record in Restaurant 
--**************************************
set @Action = 'Insert Record in Restaurant Table'
INSERT INTO Restaurant
(
	DomainID,
	r.RestaurantType,
	r.MinOnlineOptionID,
	r.ParkingID,
	r.SmokingID,
	DressCodeID,
	r.PriceQuartileID,
	r.WOID,
	r.TZID,
	r.neighborhoodid,
	r.MaxOnlineOptionID,
	r.MinTipSizeOptionID,
	r.MaxAdvanceOptionID,
	r.RestStateID,
	DiningStyleID,
	r.Country,
	r.ReserveCode,
	r.HasBanquet,
	r.HasCatering,
	r.HasPrivateParty,
	r.HasGiftCertificate,
	r.Allotment,
	r.MaxLargePartyID,
	r.Ping,
	r.MinCCOptionID,
	r.CCAccountStatusID,
	r.RomsModifiedDTUTC,
	r.BrandID,
	r.IsConnectFieldTest,
	r.ShowThirdPartyMenu
)
VALUES
(
	@DomainID,		--DomainID,	 
	@RestaurantType,	--r.RestaurantType,  /*Set the RestaurantType to ERB, Allotment, or Guestbridge */
	1,			--r.MinOnlineOptionID,
	1,			--r.ParkingID,
	2,			--r.SmokingID,
	3,			--DressCodeID,
	2,			--r.PriceQuartileID,
	1,			--r.WOID,
	@TZID,		--r.TZID,
	@NeighborhoodID,	--r.neighborhoodid,
	20,			--r.MaxOnlineOptionID,
	1,			--r.MinTipSizeOptionID,
	33,			--r.MaxAdvanceOptionID,
	2,			--r.RestStateID,
	2,			--DiningStyleID,
	@CountryID,		--r.Country,
	@RandomString,		--r.ReserveCode,
	0,			--r.HasBanquet,
	0,			--r.HasCatering,
	0,			--r.HasPrivateParty,
	0,			--r.HasGiftCertificate,
	@Allotment,		--r.Allotment,
	20,			--r.MaxLargePartyID,
	0,			--r.Ping
	20,			--r.MinCCOptionID,
	case WHEN @DomainID = 2 THEN 2 /*Opted Out*/ ELSE 1 /*default=No BT Action Taken*/ END,
    case WHEN @DomainID = 2 THEN GETUTCDATE() END,
    @BrandID,
    case WHEN @RestaurantType = 'A' THEN @IsConnectFieldTest ELSE 0 END, -- FT is always 0 for non-Connect RIDs
    @ShowThirdPartyMenu
)set @DBError = @@error
if @DBError <> 0
		goto error

SELECT @RestaurantID = scope_identity()
set @DBError = @@error
if @DBError <> 0
		goto error

if @RestaurantType = 'C'
	update 
		Restaurant 
	set 
		IsOptOutForFRNandBackSoon = 1
		,IsOptOutEmailForFRNandBackSoon = 1
	where 
		RID = @RestaurantID

--**************************************
--** Insert Record into RestaurantJustAdded
--**************************************
INSERT INTO RestaurantJustAdded (RID,JustAdded)  
values (@RestaurantID,'0')  

--**************************************
--** Insert Record into RestaurantLocal
--**************************************
set @Action = 'Insert RestaurantLocal'
insert into RestaurantLocal (
	RID,
	LanguageID,
	RName,
	RSName
	)
values (
	@RestaurantID,
	@LanguageID,
	@RestaurantName,
	''
)
set @DBError = @@error
if @DBError <> 0
		goto error


--**************************************
--** Log Name change
--**************************************
set @Action = 'Log Restaurant name change'
insert into RestNameChange
(RID, LanguageID, ResoRname, EffectiveDT)
values (@RestaurantID, @LanguageID, @RestaurantName, '01-01-1900') --default expireDT 01-01-9999
set @DBError = @@error
if @DBError <> 0
		goto error

--**************************************
--** Add ERB to ERB Restaurant Table
--**************************************		
set @Action = 'Admin_ERBRestaurant_Add_v2'
Exec dbo.Admin_ERBRestaurant_Add_v2 
	@RestaurantID = @RestaurantID,
	@ServerIP = 'bogus:2368',
	@ServerPassword = @RandomString,
	@ServerKey = 'DUMMY',
	@ProductType = 14, 
	@StaticIPAddress = 0,
	@Allotment = @Allotment

set @DBError = @@error
if @DBError <> 0
	goto error

--**************************************
--** Add Description Place Holder
--**************************************		

INSERT INTO [RestaurantCustomMessage] (
	[RID],
	[MessageTypeID],
	[Message],
	[LanguageID]
) VALUES ( 
	/* RID - int */ @RestaurantID,
	/* MessageTypeID - int */ 51,
	/* Message - nvarchar(999) */ N'Coming Soon!',
	/* LanguageID - int */ @LanguageID ) 


set @DBError = @@error
if @DBError <> 0
	goto error

--**************************************
--** Add Reservation Confirmation Message
--**************************************		

INSERT INTO [RestaurantCustomMessage] (
	[RID],
	[MessageTypeID],
	[Message],
	[LanguageID]
) 
Select 	@RestaurantID as RID,
	10 as MessageTypeID, -- Confirmation Message is Message ID 10
	REPLACE(Message,'[RestaurantName]',@RestaurantName) AS Message,
	LanguageID
FROM 	[DefaultMessage] 
WHERE 	[MessageTypeID] = 16 -- Default Confirmation Message is Message ID 16
AND 	[LanguageID] = @LanguageID


set @DBError = @@error
if @DBError <> 0
	goto error


--****************************************************************
--** Add ValueLookupIDList for Marketing Email Opt In ReftRef path
--****************************************************************
INSERT INTO [ValueLookupIDList] (
	[LookupID],
	[ValueID]
) 
VALUES ('3', @RestaurantID)

-- For restaurants added to other domains than opentable.com, opt out from showing POP Offer on rest_profile
if @DomainID = 6
Begin
INSERT INTO [ValueLookupIDList] ([LookupID], [ValueID]) VALUES (51, @RestaurantID)
End

COMMIT TRANSACTION
--*************************************
--** SetValQueue for BT opted out
--*************************************
if @DomainID = 2
Begin
exec SvcSetValEnqueue @RestaurantID, 'PCI_Enabled', '0', 'AUTO - Opted out of Credit card Reservations.'
End


select @retval = @RestaurantID
Return(0)

error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(1)

dupCode:
	RAISERROR ('The Reservation code you have selected is already in use',16,1)
 	goto error
GO

GRANT EXECUTE ON [Admin_Restaurant_Add_Simple_v7] TO ExecuteOnlyRole

GO
