if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_UI_Insert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_UI_Insert]
GO





CREATE Procedure dbo.Reservation_UI_Insert
 (
  @ReservationID int,
  @UserID int,
  @UIType int,
  @isCaller int
 )
As
SET NOCOUNT ON

INSERT INTO ReservationUI
 (
  ResID,userid,UIType,IsCaller
 )
VALUES
 (
  @ReservationID,
  @UserID,
  @UIType,
  @isCaller
 )
GO

GRANT EXECUTE ON [Reservation_UI_Insert] TO ExecuteOnlyRole

GO
