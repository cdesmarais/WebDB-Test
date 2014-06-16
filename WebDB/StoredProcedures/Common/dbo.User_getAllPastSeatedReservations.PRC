if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_getAllPastSeatedReservations]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_getAllPastSeatedReservations]
GO

CREATE PROCEDURE dbo.User_getAllPastSeatedReservations
(
    @UserID int,
    @IsCaller bit
)
AS

--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--**	proc_User_getAllPastSeatedReservations_Caller
--**	proc_User_getAllPastSeatedReservations_Customer
--**
--** These procs are part of a pair. 
--** They are split to make it easier to diff (for logical symmetry)
--** and for performance reasons
--*************************************************************

declare @PartnerID as int
declare @CreateDate as datetime

if @IsCaller = 1
BEGIN

	--**********************************
	--** Pull the Conversion date of the user. We will use this to ensure that we don't
	--** show reservation before the person registered. Or converted from Anonymous
	--**********************************
	Select 	@PartnerID = PartnerID, 
			@CreateDate = coalesce(ConvertDate,CreateDate)
	from 	Caller c
	left 	outer join consumertypeConvertlog ctcl 
	on 	 	c.callerid = ctcl.callerID
	and 	OriginalConsumerTypeID = 8
	and 	ConvertDate > CreateDate
	where 	c.CallerID = @UserID
	
	exec proc_User_getAllPastSeatedReservations_Caller @UserID, @CreateDate, @PartnerID WITH RECOMPILE 
END
else
BEGIN

	--**********************************
	--** Pull the Conversion date of the user. We will use this to ensure that we don't
	--** show reservation before the person registered. Or converted from Anonymous
	--**********************************
	Select 	@PartnerID = PartnerID,
			@CreateDate = coalesce(ConvertDate,CreateDate)
	from 	customer c
	left 	outer join consumertypeConvertlog ctcl 
	on 	 	c.custid = ctcl.custid
	and 	OriginalConsumerTypeID = 8
	and 	ConvertDate > CreateDate
	where 	c.custid = @UserID
	
	exec proc_User_getAllPastSeatedReservations_Customer @UserID, @CreateDate, @PartnerID WITH RECOMPILE 
END

GO


GRANT EXECUTE ON [User_getAllPastSeatedReservations] TO ExecuteOnlyRole

go
