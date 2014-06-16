if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGiftGetGifts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGiftGetGifts]
GO

CREATE PROCEDURE dbo.DNGiftGetGifts
 (
  @points int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT distinct g.GiftName as [Name]
,g.GiftID as Gift_ID
,g.GiftDesc as description
,case
When g.GiftID IN (select GiftID from GiftAttributes Group By GiftID Having Count(GiftID)>1) then 1
Else 0
End AS AttFlag
			,GiftAttributes.Points as [Points]
FROM GiftVW g
inner JOIN GiftAttributes 
on g.GiftID = GiftAttributes.GiftID
and GiftAttributes.Points <= @points
WHERE g.Active = 1
ORDER BY	[Name]
			,[Points] ASC

GO

GRANT EXECUTE ON [DNGiftGetGifts] TO ExecuteOnlyRole

GO
