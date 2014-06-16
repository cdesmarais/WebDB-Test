if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantGetDefaultMsg]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantGetDefaultMsg]
GO

--*****************************************************************************
--** EV 8/12/04: Created Proc to cache all Default messages in Web Local Cache
--*****************************************************************************
CREATE PROCEDURE dbo.DNRestaurantGetDefaultMsg
 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

select distinct MessageTypeID, Message, dm.LanguageID
from DefaultMessageAVW dm
inner join	dbo.DBUser db 
-- For standard user (WebUserUS) returns only one language (en-US) and for regional users (WebUserRegion) returns all the languages
on		db.dbuser = user
and		dm.LanguageID = isnull(db.LanguageID , dm.LanguageID) 
order by dm.LanguageID, MessageTypeID

GO

GRANT EXECUTE ON [DNRestaurantGetDefaultMsg] TO ExecuteOnlyRole

GO
