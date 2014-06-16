IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[EMH_GetERBInformation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[EMH_GetERBInformation]
GO


CREATE Procedure [dbo].[EMH_GetERBInformation]
@CacheServerGroupName VARCHAR(256)
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT			a.RID,
				SUBSTRING(COALESCE(a.ServerIP,  ''), 0, CHARINDEX(':', COALESCE(a.ServerIP,  '')))as IPAddress,
				e.IPAddress as CSIPAddress

FROM			dbo.ERBRestaurant a
INNER JOIN		dbo.Restaurant b
ON				a.RID = b.RID
INNER JOIN		dbo.CacheServerERBGroup c
ON				a.CacheServerERBGroupID = c.CacheServerERBGroupID
INNER JOIN		dbo.CacheServer d
ON				c.CacheServerID = d.CacheServerID
INNER JOIN		dbo.[Server] e
ON				d.ServerId = e.ServerId 
--WHERE			c.GroupName = --LTRIM(@CacheServerGroupName) --No need to pick just EMH group; pick all
--We are getting all RIDs even OTC to avoid getting errors during RID migration.
GO

        
GRANT EXECUTE ON [EMH_GetERBInformation] TO ExecuteOnlyRole
GO