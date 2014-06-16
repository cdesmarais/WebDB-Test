if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConUpdateLargePartySizeForRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConUpdateLargePartySizeForRID]
GO


CREATE PROCEDURE dbo.OTConUpdateLargePartySizeForRID
(
	@RID	INT,
	@NewLargePartySize	INT
)

AS
IF EXISTS 
	( -- Check to make sure it's a valid NewLargePartySize
		SELECT *
		FROM	MaxOnlineOption
		WHERE	MaxValue = @NewLargePartySize
	)
	 BEGIN
		UPDATE	Restaurant
		SET		MaxLargePartyID = @NewLargePartySize
		WHERE	RID = @RID
	 END
ELSE
	BEGIN
		RAISERROR ('dbo.OTConUpdateLargePartySizeForRID: Invalid NewLargePartySize', 17, 1)
	END
GO

GRANT EXECUTE ON [OTConUpdateLargePartySizeForRID] TO ConsoleExecuteRole

GO
