if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Insert_StateAreaListing]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Insert_StateAreaListing]
GO

CREATE Procedure dbo.Admin_Insert_StateAreaListing
(	@StateID AS NCHAR(2)
	,@MacroID as int
	,@MetroAreaID as int
	,@AreaSection as NVARCHAR(50)
	,@IsFeatured AS BIT
	,@ShortName AS NVARCHAR(50)	
	,@DomainID AS int
	,@CountryID as nchar(2)
)

AS
SET NOCOUNT ON
SET TRAN ISOLATION LEVEL SERIALIZABLE


BEGIN TRAN

	INSERT INTO dbo.StateAreaListing (
		StateID,
		MacroID,
		MetroAreaID,
		AreaSection,
		IsFeatured,
		ShortName,
		Active,
		CountryID,
		DomainID
	) VALUES ( 
		/* StateID - char(2) */ @StateID,
		/* MacroID - int */ @MacroID,
		/* MetroAreaID - int */ @MetroAreaID,
		/* AreaSection - nvarchar(50) */ @AreaSection,
		/* IsFeatured - bit */ @IsFeatured,
		/* ShortName - nvarchar(50) */ @ShortName,
		/* Active - bit */ 1,
		/* CountryID - char(2) */ @CountryID,
		/* DomainID - int */ @DomainID) 
		
	
	if (@@ERROR <> 0)
		goto general_error

COMMIT TRAN
RETURN(0)

general_error:
ROLLBACK TRANSACTION
RETURN(1)
GO

GRANT EXECUTE ON [Admin_Insert_StateAreaListing] TO ExecuteOnlyRole
GO


