if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobSyncROMSToWebDB_PCIData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobSyncROMSToWebDB_PCIData]
GO

CREATE PROCEDURE dbo.JobSyncROMSToWebDB_PCIData
AS
	-- This stored procedure synchronizes PCI-related data from ROMS to WebDB.
	-- It should be run in all regions.  The data is stored in ROMS because 
	-- ROMS and OTR manipulate it frequently - the Website needs it updated
	-- to change the reso path when accounts are active to go through the
	-- PCI-compliant path (details_pci.aspx).

	-- The current schedule for this job is every 15 minutes.  If performance
	-- is an issue this will be decreased - but there are many delays in 
	-- getting the data propagated through the system, so this must be
	-- coordinated to ensure everything works smoothly.

	-- Synchronization tasks and current values:
	-- 1. Synchronize BrainTree status updates (via OTService): 15 minutes
	-- 2. Synchronize ROMS data to WebDB (via WebDB job and this SP): 15 minutes
	-- 3. Website cache of WebDB values (in CacheMgr): Medium frequency (60 minutes)
	
	-- Create temp table for GOD data to sync
	declare @SyncData table 
	( 
		 RID				int -- (aka: GOD.WebID)
		,CCAccountStatusId	int
		,CCMerchantId		varchar(50)
		,CCUserID			varchar(50)
		,ROMSModifiedDTUTC	datetime
		primary key (RID)
	)

	-- Get sync data from GOD
	-- This transaction is being carried out in Default isolation level ReadCommited to avoid Dirty reads
	insert into	@SyncData
	select		 cast(WebID as integer)
				,CCAccountStatusId
				,CCMerchantId
				,CCUserID
				,ModifiedDTUTC
	from		YELLOWSTONE.GOD.dbo.Restaurants
	where		isnumeric(WebID) = 1 -- filter out non-numeric ids
	
	-- This is being done in a separate step to avoid join over the linked server
	delete		@SyncData
	from		@SyncData t
	inner join	Restaurant r with (readuncommitted)
	on			r.RID = t.RID
	where       isnull(t.ROMSModifiedDTUTC,'1/1/2000') = isnull(r.ROMSModifiedDTUTC,'1/1/2000')


	-- Update WebDB with data from temp table
	-- Note: No need for a transaction here; there is just a single statement
	update		Restaurant with (rowlock)
	set			 CCAccountStatusID	= t.CCAccountStatusId
				,CCMerchantID		= t.CCMerchantId
				,CCUserID			= t.CCUserID
				,ROMSModifiedDTUTC	= t.ROMSModifiedDTUTC
	from		@SyncData t
	inner join	Restaurant r
	on			r.RID = t.RID

GO

GRANT EXECUTE ON [JobSyncROMSToWebDB_PCIData] TO ExecuteOnlyRole

GO
