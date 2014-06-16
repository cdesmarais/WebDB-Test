if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheBrainTreeRestaurantInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheBrainTreeRestaurantInfo]
GO

CREATE PROCEDURE dbo.DNCacheBrainTreeRestaurantInfo
AS

set transaction isolation level read uncommitted
SET NOCOUNT ON

select		 r.RID
			,r.CCAccountStatusID
			,r.CCMerchantID
			,cc.CCAccountStatus
from		dbo.Restaurant r -- Note: no need for RestaurantVW; there is nothing localized returned
inner join	dbo.CCAccountStatusTypes cc
on			cc.CCAccountStatusID = r.CCAccountStatusID
where		r.RestStateID != 4 -- Inactive
GO

GRANT EXECUTE ON [DNCacheBrainTreeRestaurantInfo] TO ExecuteOnlyRole
GO
