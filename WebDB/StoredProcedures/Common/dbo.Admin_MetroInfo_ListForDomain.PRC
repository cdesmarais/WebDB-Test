  

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroInfo_ListForDomain]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroInfo_ListForDomain]
GO


CREATE Procedure dbo.Admin_MetroInfo_ListForDomain
 (
  @Domain_ID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	Declare @Languages AS int
	Select @Languages = count(DISTINCT LanguageID) 
	from MetroAreaAVW
	where SupportedDomainID = @Domain_ID

	SELECT 	metroareaid as Metro_Area_ID,
			MetroAreaName as Name,
			Active,
			SearchLevel as Search_Level,
			Message,
			EmailContact as email_contact,
			m.LanguageID,
			@Languages as Languages,
			CASE WHEN (LEN(LTRIM(MetroAreaSName)) = 0) THEN MetroAreaName ELSE MetroAreaSName END SName
	FROM 	MetroAreaAVW m
	WHERE 	SupportedDomainID = 0
	OR		SupportedDomainID = @Domain_ID
	ORDER 	BY SName

Return(0)

GO

GRANT EXECUTE ON [Admin_MetroInfo_ListForDomain] TO ExecuteOnlyRole
GO  

