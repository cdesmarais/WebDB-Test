

 




if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminJustAddedRemoval]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminJustAddedRemoval]
GO

 

CREATE PROCEDURE dbo.AdminJustAddedRemoval


AS 












declare deleteja_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select restcount, metroareaid, minnumrests, deletedcount, restsleft
	from
	(
		select count(rja.rid) as restcount,  m.metroareaid, minnumrests, deletedcount,(count(rja.rid)-deletedcount) as restsleft
		from restaurantjustadded rja
		inner join restaurant r on rja.rid = r.rid
		inner join neighborhood n on r.neighborhoodid = n.neighborhoodid
		inner join metroarea m on n.metroareaid = m.metroareaid
		inner join (select m.metroareaid, count(rja.rid) as deletedcount
				from restaurantjustadded rja
				inner join restaurant r on rja.rid = r.rid
				inner join neighborhood n on r.neighborhoodid = n.neighborhoodid
				inner join metroarea m on n.metroareaid = m.metroareaid
				where justadded = 1 and
					datediff(day,isnull(overridedate, dateremoved),getdate()) >= 0 and
					m.active = 1 and
					r.reststateid in (1,5,6,7,13,16)	
				group by minnumrests, m.metroareaid
		) deletedlist on m.metroareaid = deletedlist.metroareaid
		where justadded = 1 and
			m.active = 1 and
			r.reststateid in (1,5,6,7,13,16)	
		group by m.metroareaid, minnumrests, deletedcount
		--having (count(rja.rid)-deletedcount) <> 0
	) as tempTab
	order by metroareaid


--cursor
	Declare @restcount int
	Declare @metroareaid int
	Declare @minnumrests int
	Declare @deletedcount int
	Declare @restsleft int
	Declare @i int
	Declare @rid int
	Declare @removeDate datetime
	set @i = 0
	
	OPEN deleteja_cur
	FETCH NEXT FROM deleteja_cur 
	INTO @restcount,@metroareaid,@minnumrests,@deletedcount,@restsleft

	update restaurantjustadded set justadded = 0
	from restaurantjustadded ja
	inner join restaurant r on r.rid = ja.rid
	where justadded = 1 and
		 reststateid = 4

	WHILE @@FETCH_STATUS = 0
	BEGIN
		WHILE @restcount > @restsleft and @restcount > @minnumrests
		BEGIN

		
		update restaurantjustadded set justadded = 0, dateremoved = getdate()
		where rid = (
			select top 1 rja.rid 
	 		from restaurantjustadded rja 
			inner join restaurant r on rja.rid = r.rid
			inner join neighborhood n on r.neighborhoodid = n.neighborhoodid
			inner join metroarea m on n.metroareaid = m.metroareaid
			where m.metroareaid = @metroareaid and justadded = 1 and 
				datediff(day,isnull(overridedate, dateremoved),getdate()) >= 0 and
				reststateid in (1,5,6,7,13,16)
			order by isnull(overridedate, dateremoved) asc, r.rid
		)	
		
		set @restcount = @restcount -1
		END

		

/*		set @i = @i + 1
		set @strReport = @Advancedays + ' : ' + @ResoPercent + ' (' + @ResoCount + ')' + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		
*/
		FETCH NEXT FROM deleteja_cur 
		INTO @restcount,@metroareaid,@minnumrests,@deletedcount,@restsleft	
	END
	CLOSE deleteja_cur

GO


 

GRANT EXECUTE ON [AdminJustAddedRemoval] TO ExecuteOnlyRole

 

GO
