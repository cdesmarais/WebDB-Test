IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoadRestaurantOfferBlacklist]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LoadRestaurantOfferBlacklist]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LoadRestaurantOfferBlacklist]
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	--Check to make sure currentdb is webdb.  Proc is NA only.
	IF DB_NAME() <> 'WebDB'
	BEGIN
		RAISERROR('This proc is currently only supported for NA.',16,1)
	END
	begin tran
		delete from ValueLookupIDList where LookupID = 74
		INSERT INTO ValueLookupIDList (LookUpID,
									ValueID)
		SELECT 74, vv.RID FROM daybehind.OTReports.dbo.VVRIDMap vv
		LEFT JOIN RestaurantOffer ro
		ON vv.rid = RO.rid and ro.offerclassid=3 and OfferStatusID=1
		WHERE ro.RID is null
	commit tran
END

GO
GRANT EXECUTE ON [LoadRestaurantOfferBlacklist] to ExecuteOnlyRole
GO

