if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCustHitCountUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCustHitCountUpdate]
GO

CREATE PROCEDURE dbo.DNCustHitCountUpdate
(
@IN_Customer_ID int,
@IN_VisitsBeforeRegistration int,
@IN_VisitsBeforeReservation int
)
AS
SET NOCOUNT ON

UPDATE 	Customer 
SET 	VisitsBeforeReservation=@IN_VisitsBeforeReservation 
WHERE 	VisitsBeforeReservation IS NULL
AND	 	@IN_VisitsBeforeReservation > -1
AND 	CustID=@IN_Customer_ID;

UPDATE 	Customer 
SET 	VisitsBeforeRegistration=@IN_VisitsBeforeRegistration 
WHERE 	VisitsBeforeRegistration IS NULL  
AND 	@IN_VisitsBeforeRegistration > -1
AND 	CustID=@IN_Customer_ID;

GO

GRANT EXECUTE ON [DNCustHitCountUpdate] TO ExecuteOnlyRole

GO

