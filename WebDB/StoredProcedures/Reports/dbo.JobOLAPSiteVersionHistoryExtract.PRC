
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobOLAPSiteVersionHistoryExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobOLAPSiteVersionHistoryExtract]
GO


CREATE PROCEDURE [dbo].[JobOLAPSiteVersionHistoryExtract]
AS

--This Proc reterieves the VersionID for Web side of applications

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--Find Region
DECLARE		@RegionID INT
SELECT		@RegionID = dbo.[fGetRegionID]()


--Get Versions
SELECT 		@RegionID AS RegionID,
			*
FROM		SiteVersionHistory
GO


GRANT  EXECUTE  ON [dbo].[JobOLAPSiteVersionHistoryExtract]  TO [ExecuteOnlyRole]
GO


