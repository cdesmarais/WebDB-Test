if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromoPageImagesGetByName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromoPageImagesGetByName]
GO


CREATE PROCEDURE dbo.AdminPromoPageImagesGetByName
(
  @ImageName nvarchar(100)
)
As

set nocount on
set transaction isolation level read uncommitted

	select	PromoPageImageID,
			Imagename 
	from   	PromoPageImage
	where	Imagename = @ImageName

go

grant execute on [AdminPromoPageImagesGetByName] TO ExecuteOnlyRole

GO