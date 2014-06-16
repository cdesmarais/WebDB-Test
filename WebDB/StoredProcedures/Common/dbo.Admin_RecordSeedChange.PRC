
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_RecordSeedChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_RecordSeedChange]
GO




CREATE PROCEDURE dbo.Admin_RecordSeedChange
@username nvarchar(100),
@restaurantName nvarchar(100),
@restaurantIP nvarchar(100),
@oldSeed int,
@newSeed int,
@RID int
AS

SET NOCOUNT ON
declare @dtToday datetime

set @dtToday = getdate();

insert into SeedChangeLog(UserName,ChangeTS,RestaurantName,RestaurantIP,OldSeed,NewSeed,RID)
VALUES(@username,@dtToday,@restaurantName,@restaurantIP,@oldSeed,@newSeed,@RID);



GO


GRANT EXECUTE ON [Admin_RecordSeedChange] TO ExecuteOnlyRole

GO
