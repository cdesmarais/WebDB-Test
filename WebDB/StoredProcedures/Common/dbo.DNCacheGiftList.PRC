if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheGiftList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheGiftList]
GO




CREATE PROCEDURE dbo.DNCacheGiftList
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

Select		AttributeValue, 
			Points, 
			giftAttributes.CountryID, 
			CountryName, 
			Delivery
from		giftAttributes 
inner join	CountryVW c
on			giftAttributes.CountryID = c.CountryID
where		Available=1
order by giftAttributes.CountryID, Points

GO

GRANT EXECUTE ON [DNCacheGiftList] TO ExecuteOnlyRole

GO
