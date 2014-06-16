if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procChecksumForCacheSet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procChecksumForCacheSet]
GO


create procedure [dbo].[procChecksumForCacheSet]
(
	@cachetablekey			nvarchar(50),
	@checksum				int output,
	@printonly				bit --only print the statement do not execute
)

as

set nocount on
set transaction isolation level read uncommitted

declare @sqlstmt nvarchar(4000)
declare @beginstmt nvarchar(50)
declare @parmdefinition nvarchar(500)

-- set the parameter def for the dynamic statement
set @parmdefinition = N'@checksumout int output'

--start off the dynamic stmt
set @beginstmt		= 'select @checksumout = checksum_agg(ck) from ('

--Now join together the rest of the statements with a 'union all'
select	@sqlstmt	=		coalesce(@sqlstmt + ' union all ', '') + 
							'select checksum_agg(checksum(' + CheckSumExpression + 
							')) ck from ' + PhysicalTableOrView + ' ' + 
							coalesce(CheckSumExpressionFilter,'')
from	CacheTableDependancy
where	CacheSet =			@cachetablekey

--End the dynamic stmt with closing paren and alias
set @sqlstmt = @beginstmt + @sqlstmt + ') a'

if (@printonly = 1)
begin
	print @sqlstmt
end
else
begin
	exec sp_executesql @sqlstmt, @parmdefinition, @checksumout=@checksum output	
end


go

grant execute on [dbo].[procChecksumForCacheSet] to executeonlyrole

go
