if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConGetReservationByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConGetReservationByID]
GO

--
-- Gets the specfic reservation 
-- 

CREATE Procedure dbo.OTConGetReservationByID

@RID			INT, -- not strictly necessary (ResIDs are unique) but included for extra security
@ReservationID	INT
AS

EXEC procOTConGetReservationByID @RID, @ReservationID

GO

GRANT EXECUTE ON [OTConGetReservationByID] TO ConsoleExecuteRole

GO

