if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_SaveLinkshare]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_SaveLinkshare]
GO



CREATE Procedure dbo.Reservation_SaveLinkshare
(
@SiteID nvarchar(255),
@ResID int,
@retval int OUTPUT
)
AS
SET NOCOUNT ON
Insert into Linkshare_Reservation (SiteID,ResID)
values (@SiteID,@ResID)if (@@error <> 0) goto nogood
SELECT @retval= 1
RETURN(1)
nogood:
RETURN(0)



GO

GRANT EXECUTE ON [Reservation_SaveLinkshare] TO ExecuteOnlyRole

GO
