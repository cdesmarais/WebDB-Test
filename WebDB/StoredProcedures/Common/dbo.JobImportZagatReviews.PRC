--
--  JobImportZagatReviews.PRC
--  Replaces current Zagat reviews with those from the ZagatStaging table.
--  Runs monthly via OTService
--  mmc 9/12/08

-- Drop the earlier version if necessary
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobImportZagatReviews]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobImportZagatReviews]
GO

-- Create the proc
CREATE PROCEDURE dbo.JobImportZagatReviews

AS

SET NOCOUNT ON

BEGIN TRANSACTION

	DECLARE @ProviderID INT
	DECLARE @ContentTypeID INT
	
	-- get the proper ProviderID
	SELECT @ProviderID = ProviderID FROM Provider WHERE ProviderName LIKE '%Zagat%'
	IF @ProviderID IS NULL
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR('Can''t find ProviderID FOR ''Zagat''',16,1)
		RETURN -1
	END

	-- get the proper ContentTypeID	
	SELECT @ContentTypeID = ContentTypeID FROM ContentType WHERE ContentTypeName = 'link'
	IF @ContentTypeID IS NULL
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR('Can''t find ContentTypeID FOR ''link''',16,1)
		RETURN 
	END
	
	--
	-- The ZagatStaging table has all of the data to import
	--

	-- first, clear out all existing Zagat review data
	DELETE 
	FROM	[Content] 
	WHERE ProviderID = @ProviderID AND
		  ContentTypeID = @ContentTypeID
	
	-- import the staging data.  Note that the staging table's "restaurant ID is not the RID"
	
	INSERT INTO Content (ProviderID, ContentTypeID, RID, [Enabled], [Content], ShortValue)
		SELECT	@ProviderID AS ProviderID, 
				@ContentTypeID AS ContentTypeID,
				rd.RID AS RID,
				1 AS [Enabled],
				NULL AS [Content],
				zs.link AS ShortValue
		FROM	 ZagatStaging zs
			INNER JOIN RestaurantDetailVW rd ON rd.ReserveCode = zs.RestaurantID
	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR('Error Inserting Zagat Review data', 16, 1)
			RETURN 
		END
		
	-- We're good
	DELETE FROM ZagatStaging
	COMMIT TRANSACTION
	RETURN 
GO

-- Ensure proper permissions
GRANT EXECUTE ON [JobImportZagatReviews] TO ExecuteOnlyRole

GO

