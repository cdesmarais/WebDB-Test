if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Add]
GO


CREATE Procedure dbo.Admin_Promos_Add
 (
  @code nvarchar(300),
  @points int,
  @description nvarchar(4000),
  @popup_text nvarchar(4000),
  @start_date smalldatetime,
  @end_date smalldatetime,
  @active bit,
  @EmailMessage nvarchar(500),
  @reusable bit,
  @diningincentives bit = 0,
   @retval int OUTPUT

 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

Declare @PromoID as Int,@promo_type as int

Set @promo_type = 1
if @reusable = 1
BEGIN
	Set @promo_type = 2
END

INSERT INTO Promos
 (
  code,
  points,
  PromosDesc,
  popuptext,
  Startdate,
  Enddate,
  active,
  EmailMessage,
  reusable,
  PromoTypeID,
  DiningIncentive
 )
VALUES
 (
  @code,
  @points,
  @description,
  @popup_text,
  @start_date,
  @end_date,
  @active,
  @EmailMessage,
  @reusable,
  @promo_type,
  @diningincentives
)

Select @PromoID = scope_identity()

if @@ERROR <> 0
		goto error

COMMIT TRANSACTION

select @retval = @PromoID
Return(0)

error:
	ROLLBACK TRANSACTION
	RETURN(0)
GO

GRANT EXECUTE ON [Admin_Promos_Add] TO ExecuteOnlyRole

GO
