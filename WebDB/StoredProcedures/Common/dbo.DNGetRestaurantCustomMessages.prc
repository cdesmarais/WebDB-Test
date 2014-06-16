if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetRestaurantCustomMessages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetRestaurantCustomMessages]
GO

CREATE PROCEDURE dbo.DNGetRestaurantCustomMessages
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


-- just return the contents of the custom restaurant messages..
select  
		 (cast (rcm.RID as varchar(20)) + '|' + cast (rcm.MessageTypeID as varchar(20)) + '|' + cast (rcm.LanguageID as varchar(20))) as PrimaryKey
		,rcm.RID
		,rcm.MessageTypeID
		,rcm.LanguageID
		,rcm.Message 
from     RestaurantCustomMessageAVW rcm
INNER JOIN	Restaurant r
on			r.RID=rcm.rid
and			r.RestStateID != 4 --** Do not include inactive restaurnts
where	MessageTypeID not between 50 and 58  -- Exlude messages that are already included in teh restaurant message vw
and rcm.LanguageID in (
	-- For standard user (WebUserUS) returns only one language (en-US) and for regional users (WebUserRegion) returns all the languages
	select isnull(db.DB_LanguageID , rcm.LanguageID) from dbo.DBUserDistinctLanguageVW db 
)

GO

GRANT EXECUTE ON [DNGetRestaurantCustomMessages] TO ExecuteOnlyRole

GO