if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DFFIsMetroRunning1KPromo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DFFIsMetroRunning1KPromo]
GO

CREATE PROCEDURE dbo.DFFIsMetroRunning1KPromo(
	@parMetroID int
)
As

SET NOCOUNT ON

Select 
	PP.PromoID
	from PromoPages PP
	   -- only return the PromoID for metros that have it turned on.
	  inner join PromoPagesToMetro PPTM on PP.PromoID = PPTM.PromoID and PPTM.MetroID = @parMetroID
	where active = 1
	AND PromoPageCode = '1kdays'
	
GO

GRANT EXECUTE ON [DFFIsMetroRunning1KPromo] TO ExecuteOnlyRole

GO
