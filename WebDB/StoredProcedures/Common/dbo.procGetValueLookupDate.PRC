--$add procGetValueLookupDate
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procGetValueLookupDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procGetValueLookupDate]
GO

CREATE Procedure dbo.procGetValueLookupDate
(
	 @Type		nvarchar(25)
	,@Key		nvarchar(25)
)
as

	set nocount on
	set transaction isolation level read uncommitted
	
	select			ValueDT
	from			ValueLookup
	Where			LType = @Type
	and				LKey = @Key


GO

GRANT EXECUTE ON [procGetValueLookupDate] TO ExecuteOnlyRole

GO
