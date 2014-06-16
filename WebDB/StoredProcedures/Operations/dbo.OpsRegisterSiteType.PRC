if exists (select * from dbo.sysobjects where id = object_id(N'dbo.OpsRegisterSiteType') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.OpsRegisterSiteType
GO

CREATE PROCEDURE dbo.OpsRegisterSiteType
(
	@SiteTypeID int,
	@SiteName nvarchar(50),
	@Instance nvarchar(100),
	@Service bit,
	@Enabled bit
)
As

--*************************************************************************************************
--** Proc is used to register a SiteType
--** If SiteType as defined by combination of ( SiteName + Instance ) already exists it is updated;
--** otherwise a new SiteType row is added
--*************************************************************************************************
if not exists(select SiteTypeID from SiteType where SiteTypeID = @SiteTypeID)
begin
	-- SiteTypeID does not exist
	insert into	dbo.SiteType
	values (@SiteTypeID, @SiteName, @Instance, @Service, @Enabled)
end
else
begin
	-- SiteType  exists
	update dbo.SiteType
	set [SiteName]=@SiteName, Instance=@Instance, [Service]=@Service, [Enabled]=@Enabled
	where SiteTypeID=@SiteTypeID
end
go

grant execute on [OpsRegisterSiteType] to ExecuteOnlyRole
go

