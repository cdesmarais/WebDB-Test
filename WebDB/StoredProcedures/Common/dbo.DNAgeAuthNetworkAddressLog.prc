if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAgeAuthNetworkAddressLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAgeAuthNetworkAddressLog]
GO

-- Age the AuthNetworkAddressLog table, this table has a 2 month age policy..
CREATE PROCEDURE dbo.DNAgeAuthNetworkAddressLog
AS

declare @theCutoffDate datetime

-- compute 2 month old date..
set @theCutoffDate = dateadd(m,-2,getdate())

-- delete everything 2 months old
delete 
	from AuthNetworkAddressLog
	where 
	LogDate < @theCutoffDate


GO
GRANT EXECUTE ON [DNAgeAuthNetworkAddressLog] TO ExecuteOnlyRole

GO
