if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantImporter_GetAllRestaurantCustomMessages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantImporter_GetAllRestaurantCustomMessages]
GO

CREATE PROCEDURE dbo.RestaurantImporter_GetAllRestaurantCustomMessages
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select  
		 (cast (rcm.RID as varchar(20)) + '|' + cast (rcm.MessageTypeID as varchar(20)) + '|' + cast (rcm.LanguageID as varchar(20))) as PrimaryKey
		,rcm.RID
		,rcm.MessageTypeID
		,rcm.LanguageID
		,rcm.Message 
from     RestaurantCustomMessageAVW rcm
INNER JOIN	RestaurantAVW r
on			r.RID = rcm.rid
and			r.LanguageID = rcm.LanguageID
where	MessageTypeID not between 50 and 58
GO

GRANT EXECUTE ON [RestaurantImporter_GetAllRestaurantCustomMessages] TO ExecuteOnlyRole

GO