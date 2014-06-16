if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcEmailUpdateDiningFeedback]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcEmailUpdateDiningFeedback]
GO


CREATE PROCEDURE dbo.SvcEmailUpdateDiningFeedback
(
	 @ResIDList				varchar(8000) -- List of ResIDs ('|' separator)
	,@EmailProcessed		bit
	,@DidNotMeetCriteria	bit
)
AS
	SET NOCOUNT ON

	insert into	DFBEmailSentLog
	(
		 ResID
		,Sent
		,CriteriaNotMet
	)
	select	 ID
			,@EmailProcessed
			,@DidNotMeetCriteria
	from	fIDStrToTab(@ResIDList, '|')
GO


GRANT EXECUTE ON [SvcEmailUpdateDiningFeedback] TO ExecuteOnlyRole
GO
