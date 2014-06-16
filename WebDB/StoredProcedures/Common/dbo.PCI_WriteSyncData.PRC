IF NOT EXISTS (SELECT * FROM sys.types WHERE name='PCISyncData' AND is_table_type=1)
	CREATE TYPE dbo.PCISyncData AS TABLE 
	( 
		 RID				int -- (aka: GOD.WebID)
		,CCAccountStatusId	int
		,CCMerchantId		varchar(50)
		,CCUserID			varchar(50)
		,ROMSModifiedDTUTC	datetime
		primary key (RID)
	);
GO

GRANT EXECUTE ON TYPE::dbo.PCISyncData TO ExecuteOnlyRole
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PCI_WriteSyncData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PCI_WriteSyncData]
GO

CREATE Procedure [dbo].[PCI_WriteSyncData]
(
	@PCISyncData PCISyncData READONLY
)
As

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	update		Restaurant with (rowlock)
	set			 CCAccountStatusID	= t.CCAccountStatusId
				,CCMerchantID		= t.CCMerchantId
				,CCUserID			= t.CCUserID
				,ROMSModifiedDTUTC	= t.ROMSModifiedDTUTC
	from		@PCISyncData t
	inner join	Restaurant r
	on			r.RID = t.RID
	and			isnull(t.ROMSModifiedDTUTC,'1/1/2000') <> isnull(r.ROMSModifiedDTUTC,'1/1/2000')

	return 0
GO


GRANT EXECUTE ON [PCI_WriteSyncData] TO ExecuteOnlyRole

GO