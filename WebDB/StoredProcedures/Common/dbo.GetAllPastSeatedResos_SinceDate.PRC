if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetAllPastSeatedResos_SinceDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetAllPastSeatedResos_SinceDate]
GO

---Gets all past seated resos from a given @SinceDate and @PartnerID
CREATE PROCEDURE dbo.GetAllPastSeatedResos_SinceDate
(
	@SinceDate	datetime,
	@PartnerID	int
)
AS

--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--**	proc_getAllPastSeatedResos_Customers_SinceDate
--**	proc_getAllPastSeatedResos_Callers_SinceDate
--**
--** These procs are part of a pair. 
--** They are split to make it easier to diff (for logical symmetry)
--** and for performance reasons
--*************************************************************

BEGIN	
	exec proc_getAllPastSeatedResos_Customers_SinceDate @SinceDate, @PartnerID
	
	exec proc_getAllPastSeatedResos_Callers_SinceDate @SinceDate, @PartnerID
END
GO


GRANT EXECUTE ON [GetAllPastSeatedResos_SinceDate] TO ExecuteOnlyRole

go
