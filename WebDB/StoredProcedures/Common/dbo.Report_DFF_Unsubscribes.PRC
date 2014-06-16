if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_DFF_Unsubscribes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_DFF_Unsubscribes]
GO

CREATE PROCEDURE dbo.Report_DFF_Unsubscribes
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

select		count(*) as Unsubscribes
from		Customer
where		DiningFormEmailOptIn = 0

GO

GRANT EXECUTE ON [Report_DFF_Unsubscribes] TO ExecuteOnlyRole

GO
