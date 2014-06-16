--
-- QA_SetBrand.PRC
-- Sets the BrandID for a given RID

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[QA_SetBrand]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[QA_SetBrand]
GO

CREATE PROCEDURE dbo.[QA_SetBrand]

@RID		INT,
@BrandID	INT   -- needs to exist in the Brand table

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- valid BrandID?
IF NOT EXISTS (SELECT 1 FROM Brand WHERE BrandID = @BrandID)
BEGIN
	DECLARE @ERR NVARCHAR(256)
	SET @ERR = 'Invalid BrandID: ' + CAST(@BrandID AS NVARCHAR(3))
	RAISERROR (@ERR, 16, 1)
	RETURN
END

-- We're a go
UPDATE	Restaurant
SET		BrandID = @BrandID
WHERE	RID = @RID

GO

GRANT EXECUTE ON [QA_SetBrand] TO ExecuteOnlyRole
GO