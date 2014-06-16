if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Add_On_Opportunity_Closed_Won]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Add_On_Opportunity_Closed_Won]
GO

CREATE Procedure dbo.Restaurant_Add_On_Opportunity_Closed_Won
(
	@RestaurantName nvarchar(255),
	@NeighborhoodID int,
	@RestaurantType char(1),
	@Allotment bit,
	@DomainID int,
	@BrandID int,
	@IsConnectFieldTest bit,
	@ShowThirdPartyMenu bit,
	@Email nvarchar(510),
	@ExternalURL nvarchar(256),
	@RestaurantPhone varchar(24),
	@RestaurantFax varchar(20),
	@SFDCID varchar(18),
	@retval int OUTPUT
)

As

-- This Sp creates a restaurant in CHARM

SET NOCOUNT ON

declare @RestaurantID int,
		@RestVal int = -1

declare @DBError int

begin transaction
--**************************************
--** Call the Add restaurant stored proc to add the restaurant
--**************************************
exec Admin_Restaurant_Add_Simple_v7 @RestaurantName, @NeighborhoodID, @DomainID, @Allotment, @RestaurantType, @BrandID, @IsConnectFieldTest, @RestVal OUTPUT, @ShowThirdPartyMenu

set @DBError = @@error
if @DBError <> 0
		goto error

set @RestaurantID = @RestVal

--**************************************
--** Update the Phone, Fax, Email, External URL and SFDCID
--**************************************
update Restaurant
set Phone = @RestaurantPhone,
	Email = @Email,
	ExternalURL = @ExternalURL,
	FaxPhone = @RestaurantFax,
	RestaurantSFDCID = @SFDCID
where RID = @RestaurantID

set @DBError = @@error
if @DBError <> 0
		goto error

Commit transaction
-- Return the newly created restaurant ID
select @retval = @RestaurantID
Return(0)

error:
	ROLLBACK TRANSACTION
	Select @retval = -1 -- Error while creating Charm Account
	Return(1)

GO

GRANT EXECUTE ON [Restaurant_Add_On_Opportunity_Closed_Won] TO ExecuteOnlyRole

GO
