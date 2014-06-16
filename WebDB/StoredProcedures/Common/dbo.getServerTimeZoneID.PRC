if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[getServerTimeZoneID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[getServerTimeZoneID]
GO



CREATE PROCEDURE dbo.getServerTimeZoneID
/*This stored procedure is used to set the SERVER TIME ZONE ID value for many other stored procedures ...
   when changing the location of the servers the server time zone id value only needs to be changed here ....
  to retrieve this value in another stored procedure one would make a call like the following:

declare @ServerTZID as int
exec getServerTimeZoneID @retVal = @ServerTZID OUTPUT

The above lines declare and then set the value of @ServerTZID using this stored procedure!

The time zones are kept in the TimeZone table ... here's a sample:

	TZID		Code 	 Name                 	Offset 	Active 
	------------ -		---- 	-------------------- -		----- 	------ 
	4            		PST   	Pacific Standard Tim 	-8.0   	1
	5            		PNT   	Phoenix Standard Tim 	-8.0   	1
	6            		MST  	 Mountain Standard Ti 	-7.0   	1
	7            		CST   	Central Standard Tim 	-6.0   	1
	8            		EST   	Eastern Standard Tim 	-5.0   	1

so when we move from Texas (CST) to California (PST) we will set the @retVal below equal to 4 



*/

(
@retVal int OUTPUT
)
AS

SET NOCOUNT ON


select @retVal = IsNull(ValueInt, 4)
 from valueLookup where LType = 'DBSERVER' and LKey = 'TimezoneTZID'


GO

GRANT EXECUTE ON [getServerTimeZoneID] TO ExecuteOnlyRole

GO
