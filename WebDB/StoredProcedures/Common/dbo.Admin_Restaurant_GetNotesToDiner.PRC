if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetNotesToDiner]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetNotesToDiner]
GO

-- Get the NotesToDiner text that was in effect at the time the email was sent to diner.
-- This is the most recent NotesToDiner logged in CancelRestaurantLog at the time that the email is generated,
-- or, if no email has been generated, it is the most recent NotesToDiner for the restaurant.
CREATE PROCEDURE [dbo].[Admin_Restaurant_GetNotesToDiner]
(
      @ResID int,  -- reservation id
      @RID int    -- restaurant id
)
AS
BEGIN
      SET NOCOUNT ON
      SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

      DECLARE @EffectiveDT DATETIME = NULL
      DECLARE @NoteEnteredDT DATETIME = GETDATE()
      DECLARE @NotesToDiner NVARCHAR(999) = ''
      DECLARE @CancelLogFound BIT = 0
      
      -- Get date email notification of cancellation was sent, if any
      SELECT TOP 1 
            @EffectiveDT = CreateDT
      FROM        CancellationSentLog
      WHERE       ResID = @ResID
      ORDER BY    CreateDT DESC
      
      -- Get restaurant-cancelled log entry for RID that was in effect at time of email
      IF @EffectiveDT IS NOT NULL 
      BEGIN
            SELECT TOP 1 
                  @CancelLogFound = 1,
                  @NotesToDiner = NotesToDiner,
                  @NoteEnteredDT = CreateDT
            FROM        CancelRestaurantLog 
            WHERE       CreateDT <= @EffectiveDT
            AND               RID = @RID
            ORDER BY    CreateDT DESC 
      END
      
      -- Otherwise, if log entry not yet found, get latest restaurant-cancelled log entry for RID.
      IF @CancelLogFound = 0
      BEGIN
            SELECT TOP 1 
                  @NotesToDiner = NotesToDiner,
                  @NoteEnteredDT = CreateDT
            FROM        CancelRestaurantLog 
            WHERE       RID = @RID
            ORDER BY    CreateDT DESC 
      END
      
      -- Return row
      SELECT 
            @RID AS 'RID',
            @NotesToDiner AS 'NotesToDiner',
            @NoteEnteredDT AS 'CreateDT'
END
GO

GRANT EXECUTE ON [Admin_Restaurant_GetNotesToDiner] TO ExecuteOnlyRole

GO
