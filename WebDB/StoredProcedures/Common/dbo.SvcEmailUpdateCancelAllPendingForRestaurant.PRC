if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcEmailUpdateCancelAllPendingForRestaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcEmailUpdateCancelAllPendingForRestaurant]
GO


CREATE PROCEDURE dbo.SvcEmailUpdateCancelAllPendingForRestaurant
(
	@ResIDList varchar(8000) -- List of ResIDs ('|' separator)
)
AS
	SET NOCOUNT ON

	--Batch insert
	INSERT INTO CancellationSentLog (ResID)
		SELECT		DISTINCT ID 
		FROM		dbo.fIDStrToTab(@ResIDList, '|') i
		LEFT JOIN	CancellationSentLog c with (nolock)
		ON			c.ResID = i.ID
		WHERE		c.resID IS NULL -- Do not include ID that have already been marked as sent
GO


GRANT EXECUTE ON SvcEmailUpdateCancelAllPendingForRestaurant TO ExecuteOnlyRole
GO
