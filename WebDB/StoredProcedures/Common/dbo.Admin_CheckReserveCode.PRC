if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CheckReserveCode]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CheckReserveCode]
GO


CREATE PROCEDURE dbo.Admin_CheckReserveCode

@ReserveCode nvarchar(255),
@RID int

As

Select RID from restaurant where reserveCode = @ReserveCode and RID != @RID
GO

GRANT EXECUTE ON [Admin_CheckReserveCode] TO ExecuteOnlyRole

GO
