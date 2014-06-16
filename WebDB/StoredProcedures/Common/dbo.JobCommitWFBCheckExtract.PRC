if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobCommitWFBCheckExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobCommitWFBCheckExtract]
GO

CREATE Procedure dbo.JobCommitWFBCheckExtract
as
--******************************************************************************
--Procedure commit all exported US checks on Gift redemption source table
--******************************************************************************

SET NOCOUNT ON
declare @ErrorMsg as nvarchar(1000)

set @ErrorMsg = 'Failed to commit US check data'

Begin Transaction

if (select count(*) from DCHK_HRecord where export = 0) <>1 --must only have 1 filecontrol number
	goto error

	Update DCHK_HRecord 
	set Export = 1
	where export = 0 

if @@ERROR <> 0 goto error

	update GiftRedemption
	set extracted = 1
	from GiftRedemption G
	inner join CheckRedemptionVW CR
	on G.GiftRedemptionID = CR.GiftRedemptionID
	where (CR.country='US' and CR.extracted =0) or 
	(CR.country='CA'and CR.extracted =0) 

Commit Transaction
--If all is well...
Return(0)

error:
	ROLLBACK
	exec DNErrorAdd 888, 'JobCommitWFBCheckExtract', @ErrorMsg, 1	
	raisError ('throw error',15, 1)
GO

GRANT EXECUTE ON [JobCommitWFBCheckExtract] TO ExecuteOnlyRole

GO




