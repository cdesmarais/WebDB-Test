if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNPostResoVendorDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNPostResoVendorDetails]
GO


CREATE PROCEDURE dbo.DNPostResoVendorDetails
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Select 
	VendorID,
	PostResoVendorID,
	VendorName,
	EmailTag,
	coalesce(GreenBoxText,'') as GreenBoxText,
	LanguageID,
	VendorOrder,
	ImagePath,
	ImageLink,
	Title,
	[Text],
	EmailText
from		PostResoVendorDetailVW prvd
ORDER BY VendorOrder, VendorName

GO

GRANT EXECUTE ON [DNPostResoVendorDetails] TO ExecuteOnlyRole

GO
