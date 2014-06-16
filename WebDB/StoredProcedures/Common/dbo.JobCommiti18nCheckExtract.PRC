if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobCommiti18nCheckExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobCommiti18nCheckExtract]
GO

CREATE Procedure dbo.JobCommiti18nCheckExtract
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
	inner join CheckRedemption_i18n_VW CR
	on G.GiftRedemptionID = CR.GiftRedemptionID
	where CR.extracted = 0

if @@ERROR <> 0
	goto error

Commit Transaction
--If all is well...
Return(0)

error:
	ROLLBACK
	exec DNErrorAdd 888, 'JobCommiti18nCheckExtract', @ErrorMsg, 1	
	raisError ('throw error',15, 1)
GO

GRANT EXECUTE ON [JobCommiti18nCheckExtract] TO ExecuteOnlyRole

GO





