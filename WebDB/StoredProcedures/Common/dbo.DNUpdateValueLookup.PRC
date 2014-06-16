if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateValueLookup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateValueLookup]
GO


CREATE Procedure dbo.DNUpdateValueLookup
 (
  @LType nvarchar(25),
  @LKey nvarchar(30),
  @ValueChar nvarchar(500) = null,
  @ValueInt int = null,
  @ValueDT DateTime = null
 )

As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @ValueChar is not null
	update ValueLookup set ValueChar = @ValueChar where LType = @LType and LKey = @LKey

if @ValueInt is not null
	update ValueLookup set ValueInt = @ValueInt where LType = @LType and LKey = @LKey

if @ValueDT is not null
	update ValueLookup set ValueDT = @ValueDT where LType = @LType and LKey = @LKey

GO

GRANT EXECUTE ON [DNUpdateValueLookup] TO ExecuteOnlyRole

GO