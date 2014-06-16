if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_getLatestPartnerTransaction]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_getLatestPartnerTransaction]
GO

CREATE PROCEDURE dbo.XML_getLatestPartnerTransaction
(
@PartnerID int
)
 AS
 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare  @date datetime
		,@head nvarchar(1000)
		,@req nvarchar(1000)
		,@resp nvarchar(1000)
		,@strDate nvarchar(30)
		
set @date = (select top 1 TransactionDate from XMLLogTransaction where RemoteIP in (select IPAddress from PartnerIPs where PartnerID = @PartnerID) order by TransactionDate desc)
set @head = (select top 1 RequestHeader from XMLLogTransaction where RemoteIP in (select IPAddress from PartnerIPs where PartnerID = @PartnerID) order by TransactionDate desc)
set @req = (select top 1 XMLRequest from XMLLogTransaction where RemoteIP in (select IPAddress from PartnerIPs where PartnerID = @PartnerID) order by TransactionDate desc)
set @resp = (select top 1 XMLResponse from XMLLogTransaction where RemoteIP in (select IPAddress from PartnerIPs where PartnerID = @PartnerID) order by TransactionDate desc)
set @strDate =  getDate()

print 'current server time: '  + @strDate
print 'latest Partner transaction information:'
print @date
print @head
print @req   
print @resp
GO

GRANT EXECUTE ON [XML_getLatestPartnerTransaction] TO ExecuteOnlyRole

GO
