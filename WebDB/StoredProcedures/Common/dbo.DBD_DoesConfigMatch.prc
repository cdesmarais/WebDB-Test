if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_DoesConfigMatch]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_DoesConfigMatch]
GO


CREATE PROCEDURE dbo.DBD_DoesConfigMatch
(
		@theServiceID int,		
		@theRuntimeConfig ntext
)
  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @theRet int 
set @theRet = -1

-- check if we are updating or inserting a record..
if exists(select * from serviceconfig where serviceconfig like @theRuntimeCOnfig and serviceid=@theServiceID)
		BEGIN
			-- 1 indicates match..
			set @theRet = 1
			select @theRet
		END 
ELSE		
		BEGIN
			-- 2 indicates mismatch..
			set @theRet = 2
			select @theRet
		END


GO


GRANT EXECUTE ON [DBD_DoesConfigMatch] TO ExecuteOnlyRole

GO
