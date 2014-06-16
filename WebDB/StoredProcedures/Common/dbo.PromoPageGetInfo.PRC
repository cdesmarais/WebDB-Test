GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromoPageGetInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PromoPageGetInfo]
GO




CREATE PROCEDURE dbo.PromoPageGetInfo
(
  @PromoID int
)
AS

Select 
PromoPages.PromoID,
PromoPages.PromoPageName as PromoName,
PromoPages.PromoPageImage as PromoImage,
PromoPages.PromoPageDesc as PromoDesc,
PromoPages.PromoSearchTypeID
from PromoPages where PromoID = @PromoID


GO


GRANT EXECUTE ON [PromoPageGetInfo] TO ExecuteOnlyRole

GO
