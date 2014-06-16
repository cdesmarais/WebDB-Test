
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetRegPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetRegPoints]
GO


CREATE PROCEDURE dbo.DNGetRegPoints(@RegPromoId integer out, @Points integer out)
 AS

	-- Registration Promo Id
	set @RegPromoId = 1
	
	select @Points = ValueInt
	from valuelookup 
	where	LType = 'WEBSERVER'
		and Lkey = 'RegistrationPoints'	

--*******************************
--** TODO: May consieder adding Metro Configuration of points
--** CODE belongs here
--**
--** NOTE: This code does not appear to be called in the 4.0 site
--*******************************

 
GO


GRANT EXECUTE ON [DNGetRegPoints] TO ExecuteOnlyRole

GO
