if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Offers_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Offers_Add]
GO


CREATE Procedure dbo.Admin_Offers_Add
 (
  @RestaurantID int,
  @OfferID nvarchar(255)
 )
As
SET NOCOUNT ON



BEGIN TRANSACTION
declare @variable nvarchar(255)
declare @tempOfferID nvarchar(255)
declare @i bit
set @tempOfferID = @OfferID + ','

 While len(@tempOfferID) > 1
	begin
	    Set @variable = convert(int,left(@tempOfferID,charindex(',',@tempOfferID) -1)) /*gets everything to the left of a comma*/
		
	   INSERT INTO Offers (RID,offerID) VALUES (@RestaurantID,@variable)

	    If @@Error <> 0 
                      goto error

	   set @tempOfferID = right(@tempOfferID,len(@tempOfferID) - charindex(',',@tempOfferID)) --trims off the leftmost comma and everything preceeding it
	end

COMMIT TRANSACTION
Return(0)
 
error:
ROLLBACK TRANSACTION
Return(0)
GO

GRANT EXECUTE ON [Admin_Offers_Add] TO ExecuteOnlyRole

GO
