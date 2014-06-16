if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Header_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Header_Add]
GO



CREATE PROCEDURE dbo.Concierge_Header_Add
 (
  @HeaderName nvarchar(255),
  @Custom bit,
  @GeoID int,
  @userid int = 0,
  @Old_HeaderID int = 0
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

INSERT INTO CallerHeaders
 (
  HeaderName,Custom,GeoID
 )
VALUES
 (
  @HeaderName,@Custom,@GeoID
 )

if (@@ERROR <> 0)
	goto general_error
if @userid <> 0
BEGIN
	INSERT INTO CallertoHeader
	 (
	  CallerID,
	  HeaderID
	 )
	VALUES
	 (
	  @userid,
	  scope_identity()
	)
END
if @Old_HeaderID <> 0
BEGIN
	Delete From CallertoHeader where HeaderID = @Old_HeaderID
END
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Header_Add] TO ExecuteOnlyRole

GO
