if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Update]
GO


CREATE Procedure dbo.Admin_Promos_Update
 (
  @code nvarchar(300),
  @points int,
  @description nvarchar(4000),
  @popup_text nvarchar(4000),
  @start_date smalldatetime,
  @end_date smalldatetime,
  @active bit,
  @EmailMessage nvarchar(500),
  @Promo_ID int,
  @reusable int,
  @diningincentives bit = 0
 )
As
SET NOCOUNT ON

Declare @promo_type as int

Set @promo_type = 1
if @reusable = 1
BEGIN
	Set @promo_type = 2
END

UPDATE Promos
SET
  code  = @code,
  points = @points,
  PromosDesc = @description,
  popuptext = @popup_text,
  Startdate = @start_date,
  Enddate = @end_date,
  EmailMessage = @EmailMessage,
  active = @active,
  reusable = @reusable,
  PromoTypeID = @promo_type,
  DiningIncentive = @diningincentives
WHERE PromoID =  @Promo_ID
GO

GRANT EXECUTE ON [Admin_Promos_Update] TO ExecuteOnlyRole

GO
