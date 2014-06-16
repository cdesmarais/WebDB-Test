if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetTimeByConfirmation_Number]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetTimeByConfirmation_Number]
GO




CREATE Procedure dbo.Reservation_GetTimeByConfirmation_Number
(
@Restaurant_ID		int,
@Confirmation_Number 		int
)

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

SELECT ResID as Reservation_ID,ConfNumber as Confirmation_Number,
	/*This ugly thing just concatenates the ShiftDate & ResTime into one datetime value*/
	CAST(
		CAST(MONTH(ShiftDate) AS nvarchar(10)) + '/' + 
		CAST(Day(ShiftDate) AS nvarchar(10)) + '/' + 
		CAST(Year(ShiftDate) AS nvarchar(10)) + ' ' + 
		CAST(DATEPART(hh,ResTime) AS nvarchar(10)) + ':' + 
		CAST(DATEPART(mi,ResTime) AS nvarchar(10)
	) AS datetime) AS Reservation_DateTime
FROM Reservation
WHERE RID = @Restaurant_ID AND
	ConfNumber = @Confirmation_Number



RETURN
GO

GRANT EXECUTE ON [Reservation_GetTimeByConfirmation_Number] TO ExecuteOnlyRole

GO
