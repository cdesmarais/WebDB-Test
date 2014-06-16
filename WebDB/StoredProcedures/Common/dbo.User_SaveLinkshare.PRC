if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_SaveLinkshare]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_SaveLinkshare]
GO

CREATE Procedure dbo.User_SaveLinkshare
(
@SiteID nvarchar(255),
@CustomerID int,
@DateEntered datetime,
@retval int OUTPUT
)
AS
SET NOCOUNT ON
Insert into Linkshare_Registration (SiteID,CustID,Date_entered)
values (@SiteID,@CustomerID,@DateEntered)

if (@@error <> 0) goto nogood
SELECT @retval= 1
RETURN(1)
nogood:
RETURN(0)
GO

GRANT EXECUTE ON [User_SaveLinkshare] TO ExecuteOnlyRole

GO
