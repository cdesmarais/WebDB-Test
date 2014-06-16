if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procOTConGetReservationByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procOTConGetReservationByID]
GO

--
-- Gets the specfic reservation 
-- 

CREATE Procedure dbo.procOTConGetReservationByID

@RID			INT, -- not strictly necessary (ResIDs are unique) but included for extra security
@ReservationID	INT
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	RID,
		ReservationID,
		ReservationStateID,
		ReservationDate,
		ReservationTime,
		PartySize,
		FirstName,
		LastName,
		Email,
		PhoneType,
		ContactPhone,
		Notes,
		DateMade,
		ConfNumber,
		ServerTimeToLocalTimeOffsetMinutes,
		FirstName_Phonetic,
		LastName_Phonetic,
		OfferDescription,
		RedemptionDescription,
		RedemptionCover
FROM	OTConReservationDetailVW r
WHERE	r.RID = @RID
 AND r.ReservationID = @ReservationID

GO

GRANT EXECUTE ON [procOTConGetReservationByID] TO ConsoleExecuteRole

GO

