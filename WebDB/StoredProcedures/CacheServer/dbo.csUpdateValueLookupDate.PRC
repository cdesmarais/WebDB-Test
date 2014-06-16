--$ create proc csUpdateValueLookupDate
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csUpdateValueLookupDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].csUpdateValueLookupDate
GO

CREATE Procedure dbo.csUpdateValueLookupDate
(
	 @Type		varchar(25)
	,@Key		varchar(25)
	,@Date		datetime
)
as

	set nocount on
	if (@Type = 'CACHESERVER' and @Key = 'UP_DATE')
	begin
	    -- WMS: Beginning with WR6, 
	    -- the CacheServer will write its ActiveDT to the CacheServer table
	    -- instead of the valuelookup table.
	    -- When the new CacheServer is deployed, 
		-- it will call a different SQL proc (TBD) from the exe, 
	    -- and pass in its identity (as an IP address),
        -- so that the proper row in the CacheServer table is selected for update.
        update  CacheServer
        set     ActiveDT_UTC = GETUTCDATE()
        -- no where clause;  there will only be one CacheServer 
        -- in the transitional deployment period (post WR6, pre new CacheServer)
    end
    else	
    begin
	    exec procUpdateValueLookupDate @Type, @Key, @Date
	end

GO

GRANT EXECUTE ON [csUpdateValueLookupDate] TO ExecuteOnlyRole
GO
