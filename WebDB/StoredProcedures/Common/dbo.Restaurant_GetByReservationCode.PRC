if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetByReservationCode]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetByReservationCode]
GO



CREATE Procedure dbo.Restaurant_GetByReservationCode
 (
  @ReservationCode nvarchar(255)
 )
As
SET NOCOUNT ON
SELECT RID as Restaurant_ID
FROM Restaurant
WHERE (ReserveCode = @ReservationCode)
GO

GRANT EXECUTE ON [Restaurant_GetByReservationCode] TO ExecuteOnlyRole

GO
