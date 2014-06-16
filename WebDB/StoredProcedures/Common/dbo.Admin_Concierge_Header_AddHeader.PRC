if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Concierge_Header_AddHeader]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Concierge_Header_AddHeader]
GO





CREATE Procedure dbo.Admin_Concierge_Header_AddHeader
 (
  @Headername nvarchar(255),
  @linkname nvarchar(255),
  @link nvarchar(255),
  @Geo_ID int

 )
As
SET NOCOUNT ON
BEGIN TRANSACTION
Declare @retval int

INSERT INTO CallerHeaders
 (
  HeaderName,GeoID,Custom
 )
VALUES
 (
  @Headername,@Geo_ID,0
 )

Set @retval = scope_identity()
if (@@ERROR <> 0)
	goto general_error

INSERT INTO CallerHeaderLinks
 (
  LinkName,
  Link,
  HeaderID
 )
VALUES
 (
  @linkname,
  @link,
  @retval 
)

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON [Admin_Concierge_Header_AddHeader] TO ExecuteOnlyRole

GO
