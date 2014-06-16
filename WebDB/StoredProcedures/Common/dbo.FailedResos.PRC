if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FailedResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FailedResos]
GO

 CREATE PROCEDURE dbo.FailedResos  
 AS 
 
 select		r.rname  
			,r.rid  
			,e.listenerversion  
			,z.tzname  
			,count(*) as theFailures   
 from		logfailedresos l  
 inner join restaurantVW r  
 on			l.rid=r.rid   
 inner join erbrestaurant e  
 on			e.rid=r.rid   
 inner join timezone z   
 on			r.tzid=z.tzid   
 where		l.errdescription like '%66:%'  
 group by	r.rname  
			,r.rid  
			,e.listenerversion  
			,z.tzname  
order by	theFailures desc  
GO

GRANT EXECUTE ON [FailedResos] TO ExecuteOnlyRole

GO
