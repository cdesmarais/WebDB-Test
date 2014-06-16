if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobSelectDCHKBatch]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobSelectDCHKBatch]
GO

CREATE Procedure dbo.JobSelectDCHKBatch
as
--******************************************************************************
--Procedure select data from giftRedemption and update the value lookup table
--This will be a working giftredmptionID that is used to track export for dinning check redemption
--******************************************************************************

SET NOCOUNT ON

SET TRAN ISOLATION LEVEL READ UNCOMMITTED

select ValueInt from valuelookup
where LKey='DiningCheckExtract'

GO

GRANT EXECUTE ON [JobSelectDCHKBatch] TO ExecuteOnlyRole

GO





