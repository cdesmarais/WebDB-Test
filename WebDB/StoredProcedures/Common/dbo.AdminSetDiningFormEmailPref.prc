if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminSetDiningFormEmailPref]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminSetDiningFormEmailPref]
GO


-- Save dining form email opt in settings
CREATE PROCEDURE dbo.AdminSetDiningFormEmailPref
(
     @theCustID int,
     @theOptOutFlag bit     
)

AS

-- Dining form is ONLY sent to registered and anon customers ( no callers/concierges)
update customer set DiningFormEmailOptIn=@theOptOutFlag
where custid = @theCustID

GO

GRANT EXECUTE ON [AdminSetDiningFormEmailPref] TO ExecuteOnlyRole

GO
