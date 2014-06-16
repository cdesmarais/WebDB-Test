if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroArea_CloneToLanguage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroArea_CloneToLanguage]
GO

CREATE Procedure dbo.Admin_MetroArea_CloneToLanguage
(
    @MetroAreaID int,
	@LanguageID int
)
As
SET NOCOUNT ON

  DECLARE  @ProcName  AS NVARCHAR(1000)
  DECLARE  @Action  AS NVARCHAR(3000)
  DECLARE  @DBError INT
  
  SET @ProcName = 'Admin_MetroArea_CloneToLanguage'
  SET @Action = 'Proc Started'
  
  BEGIN TRANSACTION

--*******************************
--** Discover Language to Copy from
--*******************************

  declare @PrimaryLanguageID int

SELECT 	@PrimaryLanguageID = [PrimaryLanguageID] 
FROM 	[MetroArea]
INNER JOIN 	[Domain] 
ON 		[MetroArea].SupportedDomainID = domain.[DomainID]
WHERE	[MetroArea].MetroAreaID = @MetroAreaID


--*******************************
--** Validate that this metro can be cloned
--*******************************



set @Action = 'Validate local Metro Area info does not exist'
if EXISTS (SELECT MetroAreaID FROM MetroAreaLocal WHERE  MetroAreaID = @MetroAreaID AND languageid = @LanguageID)
	goto error




--*******************************
--** Copy Local Info to New Language
--*******************************


insert into MetroAreaLocal
(
	MetroAreaID,
	LanguageID,
	MetroAreaName,
	Message,
	TitleTag,
	ShortDisplayName
)
SELECT top 1
	MetroAreaID,
 	@LanguageID AS [languageid],
	MetroAreaName,
	Message,
	TitleTag,
	ShortDisplayName
From 	MetroAreaLocal
WHERE  	MetroAreaID = @MetroAreaID
AND	LanguageID = @PrimaryLanguageID


--*******************************
--** Copy Macro Neighborhoods
--*******************************

INSERT INTO [MacroNeighborhoodLocal] (
	[MacroID],
	[LanguageID],
	[MacroName]
) 
SELECT ml.[MacroID],
	@LanguageID AS [LanguageID],
	ml.[MacroName]
FROM 	[MacroNeighborhoodLocal] ml
INNER JOIN [MacroNeighborhood] m 
ON 	ml.[MacroID] = m.[MacroID]
WHERE 	[MetroAreaID] = @MetroAreaID 
AND 	LanguageID = @PrimaryLanguageID



--*******************************
--** Copy Neighborhoods
--*******************************

INSERT INTO [NeighborhoodLocal] (
	[NeighborhoodID],
	[LanguageID],
	[NbhoodName],
	[NbhoodSName]
)
SELECT nl.[NeighborhoodID],
	@LanguageID AS [LanguageID],
	nl.[NbhoodName],
	[NbhoodSName] 
FROM 	[NeighborhoodLocal] nl
INNER JOIN [Neighborhood] n 
ON 	nl.[NeighborhoodID] = n.[NeighborhoodID]
WHERE 	[MetroAreaID] = @MetroAreaID 
AND 	LanguageID = @PrimaryLanguageID



COMMIT TRANSACTION
Return(0)

error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(1)

GO


GRANT EXECUTE ON [Admin_MetroArea_CloneToLanguage] TO ExecuteOnlyRole

GO
