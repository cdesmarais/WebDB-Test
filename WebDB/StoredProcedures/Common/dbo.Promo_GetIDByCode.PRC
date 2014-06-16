if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_GetIDByCode]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_GetIDByCode]
GO


CREATE PROCEDURE dbo.Promo_GetIDByCode

@PromoCode nvarchar(255)

AS

set nocount on
set transaction isolation level read uncommitted

select PromoID as Promo_ID
,points
,Startdate as start_date
,Enddate as end_Date
,reusable
,coalesce(EmailMessage,'') as Email_Message 
from Promos 
where active = 1 
and code = @PromoCode
GO

GRANT EXECUTE ON [Promo_GetIDByCode] TO ExecuteOnlyRole

GO
