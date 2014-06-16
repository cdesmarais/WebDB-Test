if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetCSRestaurantUpdates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetCSRestaurantUpdates]
GO



-- Given a list of RID's delete their records from the csrestupdates Table..
CREATE PROCEDURE dbo.DNGetCSRestaurantUpdates
AS

set transaction ISOLATION LEVEL read UNCOMMITTED

declare @theCSStartCode nvarchar(20)
declare @theCSStartTime datetime
declare @MaxCSUpdateID int

set @MaxCSUpdateID = -1


-- if its started then first delete all records before the CS started
-- delete from csrestupdates where UpdateDateTS < @theCSStartTime // REPLACED BY BATCHING
DECLARE @x INT
SET @x = 1

SET ROWCOUNT 1000

WHILE @x > 0
	BEGIN
		BEGIN TRAN
			delete from csrestupdates 
				where UpdateDateTS < (select valueDT from ValueLookup
										where LType = 'CACHESERVER' 
										and LKey = 'UP_DATE')
			SET @x = @@rowcount
		COMMIT TRAN
	END 

SET ROWCOUNT 0

-- get max updateid, this will be used to pull out data
select @MaxCSUpdateID=max(CSUpdateID)  from csrestupdates

-- if you are still here then pull your data and send it back..
-- RestaurantID,Track,ServerIP,StaticIPAddress,RestStateID
select	@MaxCSUpdateID as theMaxID,
	e.RID,
	e.Track,
	(case when e.ServerIP not like '%[0-9].%[0-9].%[0-9].%[0-9]:[0-9]%' then '0.0.0.0:2368'  -- If the IP address is not in a valid form 'x.x.x.x:y' then force it to default value
		else IsNull(e.ServerIP, '0.0.0.0:2368') end)				ServerIP,
	e.StaticIPAddress,
	r.RestStateID,
	coalesce(e.NetworkAddress,'') AS NetworkAddress,
	coalesce(e.NewNetworkAddress,'') AS NewNetworkAddress
		from Restaurant r 
	INNER JOIN	ERBRestaurant e 
	on			r.rid=e.rid 
	where 		r.rid IN (
							select distinct(rid) 
				from csrestupdates 
				where CSUpdateID <= @MaxCSUpdateID)
	and			r.Allotment = 0 -- Always exlcude allotment restaurants

GO
GRANT EXECUTE ON [DNGetCSRestaurantUpdates] TO ExecuteOnlyRole

GO
