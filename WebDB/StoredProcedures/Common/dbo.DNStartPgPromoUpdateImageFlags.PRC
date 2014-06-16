if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNStartPgPromoUpdateImageFlags]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNStartPgPromoUpdateImageFlags]
GO


create procedure dbo.DNStartPgPromoUpdateImageFlags
(
  @ImageName nvarchar(100)
)
As

if not exists(select PromoPageImageID from PromoPageImage where ImageName = @ImageName)
Begin
	insert into PromoPageImage (ImageName) values (@ImageName)
end


GO

grant execute on [DNStartPgPromoUpdateImageFlags] TO ExecuteOnlyRole

GO



