if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_CollectConsensusData]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_CollectConsensusData]
GO

CREATE PROCEDURE dbo.DBD_CollectConsensusData
  
As




DECLARE @VersionNumberConsensus nvarchar(50)
SET @VersionNumberConsensus = 
(
	select 		top 1 substring(VersionnumberLive, 0, charindex('.',VersionnumberLive))
	from 		ServerSite ss 
	inner join 	Server  
	on 			ss.ServerID = Server.ServerID  
	where		Server.Active = 1  -- Only consider Active Servers for consensus 
	group by 	substring(VersionnumberLive, 0, charindex('.',VersionnumberLive))
	order by 	count(1) desc, substring(VersionnumberLive, 0, charindex('.',VersionnumberLive)) 
)

declare @DynamicCSumConsensus table 
(
	rank int identity(1,1),
	SiteTypeID int not null,
	Value nvarchar(100) COLLATE DATABASE_DEFAULT
)

--**********
--** Create a rank ordered list of all Dynamic Checksums
--**********
insert into @DynamicCSumConsensus (SiteTypeID, Value)
select		SiteTypeID, 
			DynamicChecksumLive
from		serversite ss
inner join 	Server  
on 			ss.ServerID = Server.ServerID  
where		Server.Active = 1  -- Only consider Active Servers for consensus 
and			datediff(hour, ss.UpdateDT, getdate()) < 24 -- only consider data that is less than 24 hours old in the serversite table
group by	SiteTypeID, 
			DynamicChecksumLive
order by	count(1) desc, DynamicChecksumLive


declare @StaticCSumConsensus table 
(
	rank int identity(1,1),
	SiteTypeID int not null,
	Value nvarchar(100) COLLATE DATABASE_DEFAULT
)


--**********
--** Create a rank ordered list of all Static Checksums
--**********
insert into @StaticCSumConsensus (SiteTypeID, Value)
select		SiteTypeID, 
			StaticChecksumLive
from		serversite ss
inner join 	Server  
on 			ss.ServerID = Server.ServerID  
where		Server.Active = 1  -- Only consider Active Servers for consensus 
and			datediff(hour, ss.UpdateDT, getdate()) < 24 -- only consider data that is less than 24 hours old in the serversite table
group by	SiteTypeID, 
			StaticChecksumLive
order by	count(1) desc, StaticChecksumLive
		


select		VersionnumberLive,
			ss.StaticChecksumExpected, 
			ss.StaticChecksumLive, 
			ss.DynamicChecksumLive, 
			SiteType.Service, 
			Server.ServerName, 
			SiteType.SiteName,
			@VersionNumberConsensus as VersionNumberConsensus, 
			StaticConsensus.Value as StaticChecksumConsensus, 
			DynamicConsensus.Value as DynamicChecksumConsensus,
			(case when @VersionNumberConsensus = substring(VersionnumberLive, 0, charindex('.',VersionnumberLive))
				then 1
				else 0
			end) VersionNumberMatch,
			(case when StaticConsensus.Value = ss.StaticChecksumLive 
				then 1
				else 0
			end) StaticChecksumMatch,
			(case when DynamicConsensus.Value = ss.DynamicChecksumLive
				then 1
				else 0
			end) DynamicChecksumMatch			
from		ServerSite ss
inner join	SiteType 
on 			SiteType.SiteTypeID = ss.SiteTypeID 
inner join	Server 
on			Server.ServerId = ss.ServerID
inner join  (
			--*** Retrieve the Dynamic Checksum consensus
			--*** Based on the ServerID and best Rank (most frequenetly encountered)
			select t.SiteTypeID, t.Value
			from @DynamicCSumConsensus t
			inner join
			(
				select SiteTypeID, min(rank) rank
				from @DynamicCSumConsensus
				group by SiteTypeID
			) p
			on t.SiteTypeID = p.SiteTypeID
			and t.rank = p.rank
			) DynamicConsensus
on			DynamicConsensus.SiteTypeID = ss.SiteTypeID
inner join  (
			--*** Retrieve the Static Checksum consensus
			--*** Based on the ServerID and best Rank (most frequenetly encountered)
			select t.SiteTypeID, t.Value
			from @StaticCSumConsensus t
			inner join
			(
				select SiteTypeID, min(rank) rank
				from @StaticCSumConsensus
				group by SiteTypeID
			) p
			on t.SiteTypeID = p.SiteTypeID
			and t.rank = p.rank
			) StaticConsensus
on			StaticConsensus.SiteTypeID = ss.SiteTypeID
where		Server.Active = 1  -- Only consider Active Servers for consensus 
and			datediff(hour, ss.UpdateDT, getdate()) < 24 -- only consider data that is less than 24 hours old in the serversite table
order by	SiteType.SiteName, Server.ServerName

GO

GRANT EXECUTE ON [DBD_CollectConsensusData] TO ExecuteOnlyRole

GO
