if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Gift_GetGiftAttributes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Gift_GetGiftAttributes]
GO

CREATE Procedure dbo.Gift_GetGiftAttributes
 (
  @points int,
  @giftinfo int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT GiftAttributes.attributevalue AS Value
,GiftAttributes.points AS points
,GiftAttributes.AttributeName AS name
FROM GiftAttributes
WHERE GiftAttributes.GiftID = @giftinfo 
AND GiftAttributes.available = '1'  and CountryID = 'US'
AND GiftAttributes.points <= @points

GO


GRANT EXECUTE ON [Gift_GetGiftAttributes] TO ExecuteOnlyRole

GO
