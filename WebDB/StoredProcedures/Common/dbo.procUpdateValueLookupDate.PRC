--$add procUpdateValueLookupDate
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procUpdateValueLookupDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procUpdateValueLookupDate]
GO

CREATE Procedure dbo.procUpdateValueLookupDate
(
	 @Type		nvarchar(25)
	,@Key		nvarchar(25)
	,@Date		datetime
)
as

	set nocount on

	if exists
		(
			select 		ValueDt
			from		ValueLookup
			where		LType	= @Type
			and			LKey	= @Key
		)
	begin
		update		ValueLookup
		set			ValueDt	= @Date
		where		LType	= @Type
		and			LKey	= @Key
	end
	else
	begin
		insert		ValueLookup
					(LType,	LKey,	ValueDt)
		values		(@Type,	@Key,	@Date)
	end

GO

GRANT EXECUTE ON [procUpdateValueLookupDate] TO ExecuteOnlyRole

GO
