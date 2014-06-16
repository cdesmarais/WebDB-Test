if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetPublishers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetPublishers]
GO




CREATE PROCEDURE dbo.Admin_GetPublishers

(@active int=0
 )

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @active = 1
BEGIN
SELECT PubID as Pub_ID,MPName as Name,logo,active
FROM MediaPublishers where active = 1
ORDER BY MPName
END

else
BEGIN
SELECT PubID as Pub_ID,MPName as Name,logo,active
FROM MediaPublishers
ORDER BY MPName
END
GO

GRANT EXECUTE ON [Admin_GetPublishers] TO ExecuteOnlyRole

GO
