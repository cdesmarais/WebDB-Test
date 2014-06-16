if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_GetRestaurantProductInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_GetRestaurantProductInfo]
GO

CREATE PROCEDURE dbo.Daily_GetRestaurantProductInfo
@rptID int
as

set transaction isolation level read uncommitted
SET NOCOUNT ON

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select RestaurantProduct.ProductDesc
		,count(ERBRestaurant.RID) as RestCount 
	from erbrestaurant
	inner join RestaurantProduct 
	on RestaurantProduct.ProductID = ERBRestaurant.ProductID 
	inner join Restaurant r
	on ERBRestaurant.RID = r.RID
	inner join Neighborhood n 
	on r.neighborhoodid = n.neighborhoodid
	where r.RestStateID = 1
	and n.metroareaid <> 1
	group by RestaurantProduct.ProductDesc
	order by RestCount desc

--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Active Restaurant Product Information: ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)

--cursor
	Declare @ProductDesc nvarchar(255)
	Declare @RestCount nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @ProductDesc, @RestCount

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @ProductDesc + ': ' + @RestCount + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @ProductDesc, @RestCount
	END
	CLOSE rpt_cur

GO


GRANT EXECUTE ON [Daily_GetRestaurantProductInfo] TO ExecuteOnlyRole

GO
