--Create a table type.
IF NOT EXISTS (SELECT * FROM sys.types WHERE name='UserSvc_SocialIDsToResolve' AND is_table_type=1)
	CREATE TYPE dbo.UserSvc_SocialIDsToResolve AS TABLE 
	( 
		 RowNumber				int				NOT NULL,
		 SiteUserID				NVARCHAR(50)	NOT NULL,
		 SocialTypeID			int				NOT NULL
	);
GO

GRANT EXECUTE ON TYPE::dbo.UserSvc_SocialIDsToResolve TO ExecuteOnlyRole
GO

--Create Stored Proc
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSvc_ResolveSocialIDs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserSvc_ResolveSocialIDs]
GO

CREATE PROCEDURE [dbo].[UserSvc_ResolveSocialIDs]

@SocialIDsToResolve	dbo.UserSvc_SocialIDsToResolve READONLY

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select		 t.RowNumber													RowNumber				
			,t.SiteUserID													SiteUserID					
			,t.SocialTypeID													SocialTypeID					
			,coalesce(gp_cust._GlobalPersonID,gp_caller._GlobalPersonID)	GPID
from (
		select		 s.RowNumber										
					,s.SiteUserID										
					,s.SocialTypeID										
					,soc_cust.CustID									
					,soc_caller.CallerID
		from		@SocialIDsToResolve		s

		LEFT JOIN	SocialCustomer			soc_cust
		on			(
					soc_cust.SiteUserID		= s.SiteUserID
		and			soc_cust.SocialTypeID	= s.SocialTypeID
					)

		LEFT JOIN	SocialCaller			soc_caller
		on			(
					soc_caller.SiteUserID	= s.SiteUserID
		and			soc_caller.SocialTypeID	= s.SocialTypeID
					)
	)	t
left join		GlobalPerson			gp_cust
ON				gp_cust.CustID			= t.CustID

left join		GlobalPerson			gp_caller
ON				gp_caller.CallerID		= t.CallerID

ORDER BY		t.RowNumber asc   -- Give the set sorted back in the same order that it came 
GO

GRANT EXECUTE ON [UserSvc_ResolveSocialIDs] TO ExecuteOnlyRole

GO
