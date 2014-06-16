if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobCommitNonWFBCheckExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobCommitNonWFBCheckExtract]
GO

CREATE Procedure dbo.JobCommitNonWFBCheckExtract
as
--******************************************************************************
--Procedure commit all Non US exported checks on Gift redemption source table
--******************************************************************************

SET NOCOUNT ON
declare @ErrorMsg as nvarchar(1000)

set @ErrorMsg = 'Failed to commit Non WFB check data'

Begin Transaction

	update GiftRedemption
	set extracted = 1
	from GiftRedemption G
	inner join CheckRedemptionVW CR
	on G.GiftRedemptionID = CR.GiftRedemptionID
	where CR.country<>'US' And CR.country<>'CA'  and CR.extracted =0

if @@ERROR <> 0
	goto error

Commit Transaction
--If all is well...
Return(0)

error:
	ROLLBACK
	exec DNErrorAdd 888, 'JobCommitNonUSCheckExtract', @ErrorMsg, 1	
	raisError ('throw error',15, 1)
GO

GRANT EXECUTE ON [JobCommitNonWFBCheckExtract] TO ExecuteOnlyRole

GO





