if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Gift_GetGifts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Gift_GetGifts]
GO

CREATE Procedure dbo.Gift_GetGifts
 (
  @points int
 )

As

SET NOCOUNT ON
Set transaction isolation level read uncommitted

SELECT distinct g.GiftName as Name
,g.GiftID as Gift_ID
,g.GiftDesc as description
,case
When g.GiftID IN (select GiftID from GiftAttributes Group By GiftID Having Count(GiftID)>1) then 1
Else 0
End AS AttFlag
--,g.Points as Points
FROM GiftVW g
INNER JOIN GiftAttributes 
on g.GiftID = GiftAttributes.GiftID
WHERE g.Active = 1
and GiftAttributes.Points <= @points
ORDER BY g.GiftName ASC

go


GRANT EXECUTE ON [Gift_GetGifts] TO ExecuteOnlyRole

GO
