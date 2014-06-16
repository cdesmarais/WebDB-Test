if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobUKCacheServerERBGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobUKCacheServerERBGroup]
GO

--
-- This proc will ensure that UK ERBs created in NA WebDB are assigned to the correct CS group.
-- The job will be run as a scheduled SQL task,
-- daily or more frequently,
-- until the UK top table migration is complete.
--

CREATE procedure dbo.JobUKCacheServerERBGroup
as

set transaction isolation level read uncommitted

BEGIN

declare @CacheServerERBGroupID int
set		@CacheServerERBGroupID = 999

-- update ERBRestaurant; 
-- trigger on table will populate work queue for CS to send setval messages to ERBs
update			ERBRestaurant 
set				CacheServerERBGroupID		= @CacheServerERBGroupID
from			ERBRestaurant				erb
inner join		Restaurant					r
on				r.RID						= erb.RID
where			r.Country					in ('IE', 'UK')
and				CacheServerERBGroupID		!= @CacheServerERBGroupID
and				r.RestStateID				!= 4
and				r.RestaurantType			= 'E'

END
GO


GRANT  EXECUTE  ON [dbo].[JobUKCacheServerERBGroup]  TO [ExecuteOnlyRole]
GO

