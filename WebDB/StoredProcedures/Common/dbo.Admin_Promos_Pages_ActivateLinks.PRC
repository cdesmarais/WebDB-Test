if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_ActivateLinks]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Pages_ActivateLinks]
GO


CREATE PROCEDURE dbo.Admin_Promos_Pages_ActivateLinks
(
  @PromoID int,
  @OnStartPage NVARCHAR(4000),
  @OnContent NVARCHAR(4000),
  @NoFollows NVARCHAR(4000)
)
AS
SET NOCOUNT ON



BEGIN TRANSACTION
DECLARE @tMetrosIDsOnStartPage TABLE(Id int)
DECLARE @tMetrosIDsOnContent TABLE(Id int)
DECLARE @tMetrosIDsNoFollow TABLE(Id int)
DECLARE @ValueLookupIDForDIPWings int

INSERT INTO @tMetrosIDsOnStartPage SELECT Id FROM fIDStrToTab(@OnStartPage, ',')
INSERT INTO @tMetrosIDsOnContent SELECT Id FROM fIDStrToTab(@OnContent, ',')
INSERT INTO @tMetrosIDsNoFollow SELECT Id FROM fIDStrToTab(@NoFollows, ',')

IF @@ERROR <> 0
	goto error

DELETE FROM PromoPagesToMetro WHERE PromoID = @PromoID

IF @@ERROR <> 0
	goto error

UPDATE PromoPagesToMetro
SET OnContent = 0, NoFollow = 0
WHERE PromoID IN (
	SELECT PromoID 
	FROM dbo.PromoPages
	WHERE ChildPromoID = @PromoID )
AND MetroID NOT IN (
	SELECT Id 
	FROM @tMetrosIDsOnStartPage)

IF @@ERROR <> 0
	goto error

DELETE FROM PromoPagesToMetro WHERE OnStartPage = 0 AND OnContent = 0

IF @@ERROR <> 0
	goto error

IF (@PromoID IN (SELECT PromoID FROM dbo.PromoPages WHERE PromoPageCode LIKE '1kdays'))
	Exec Admin_TurnOffDIPWingsForAllMetros

IF @@ERROR <> 0
	goto error

INSERT INTO PromoPagesToMetro
	(
	PromoID,
	MetroID,
	OnStartPage,
	OnContent,
	NoFollow
	)
SELECT @promoID
	,maStart.MetroAreaID
	,CASE WHEN (s.Id IS NULL) THEN 0 ELSE 1 END AS OnStartPage
	,CASE WHEN (c.Id IS NULL) THEN 0 ELSE 1 END AS OnContent
	,CASE WHEN (nf.Id IS NULL) THEN 0 ELSE 1 END AS NoFollow
FROM metroAreaVW maStart
left OUTER JOIN @tMetrosIDsOnStartPage s
ON maStart.MetroAreaID = s.Id
INNER JOIN dbo.MetroAreaVW maContent
ON maContent.MetroAreaID = maStart.MetroAreaID
left OUTER JOIN @tMetrosIDsOnContent c
ON maContent.MetroAreaID = c.Id
INNER JOIN dbo.MetroAreaVW maNoFollow
ON maNoFollow.MetroAreaID = maStart.MetroAreaID
LEFT OUTER JOIN @tMetrosIDsNoFollow nf
ON maNoFollow.MetroAreaID = nf.Id
where s.Id IS NOT NULL OR c.Id IS NOT NULL

IF @@ERROR <> 0
	goto error

IF (@PromoID IN (SELECT PromoID FROM dbo.PromoPages WHERE PromoPageCode LIKE '1kdays'))
BEGIN
	-- Get the proper LookupID
	SELECT	@ValueLookupIDForDIPWings = LookupID
	FROM	ValueLookupMaster
	WHERE	[Key] = 'DIP_WINGS_METRO'
	
	INSERT INTO ValueLookupIDList (LookupID, ValueID)
		SELECT @ValueLookupIDForDIPWings, Id FROM @tMetrosIDsOnStartPage
END

IF @@ERROR <> 0
	goto error

COMMIT TRANSACTION
Return(0)
 
error:
ROLLBACK TRANSACTION
Return(0)
GO


GRANT  EXECUTE  ON [dbo].[Admin_Promos_Pages_ActivateLinks]  TO [ExecuteOnlyRole]
GO

