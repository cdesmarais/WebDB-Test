IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoadRestaurantOfferEnable]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LoadRestaurantOfferEnable]
GO

CREATE PROCEDURE [dbo].[LoadRestaurantOfferEnable] 
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	--Check to make sure currentdb is webdb.  Proc is NA only.
	IF DB_NAME() <> 'WebDB'
	BEGIN
		RAISERROR('This proc is currently only supported for NA.',16,1)
	END
	UPDATE dbo.RestaurantOffer SET OfferStatusID=1, EndDate= ISNULL(vv.EndDate,'12/31/9999')
	FROM dbo.RestaurantOffer ro
	INNER join daybehind.OTReports.dbo.vvstage vv
	ON vv.rid = RO.rid and vv.DealID=ro.ThirdPartyOfferID
	where Ro.offerclassid=3
END

GO

GRANT EXECUTE ON [dbo].[LoadRestaurantOfferEnable] TO [ExecuteOnlyRole] AS [dbo]
GO


