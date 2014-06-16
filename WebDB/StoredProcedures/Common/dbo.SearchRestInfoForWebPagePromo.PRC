

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SearchRestInfoForWebPagePromo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SearchRestInfoForWebPagePromo]
GO

create procedure dbo.SearchRestInfoForWebPagePromo
(
	@RID int = 0
	,@RName nvarchar(255) = null
	,@RCleanName nvarchar(255) = null
	,@MetroAreaName nvarchar(255) = null
	,@City nvarchar(40)= null
	,@State nvarchar(40) = null
	,@Zip nvarchar(20)=null
	,@WebSite nvarchar(128) = null
	,@ReservationPhone varchar(20)= null
	,@ExcelRowID int = 0
)
as
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


/* This Proc is used to get Restaurant Information depend on given parameter.
   If RID is not Zero then first search restaurant information for given RID and store results in temporary table @tmpRestaurantInfo , 
   If Record not found then start search with strict filter ( With "AND" condtion of all parameter).
   If Record not found for strict filter then relax filter ( Remove one parameter condition) until we can not get data. 
   relax filter until mandatory columns remains in condition (Restaurnat Name , Metro)
*/

	declare @PreviousIdentity int 
	declare @RecentIdentity int
	declare @RestaurantName nvarchar(255)
	declare @InactiveRestState int
	set @RestaurantName = rtrim(ltrim(@RName))
	set @PreviousIdentity = coalesce(scope_identity(),0)

	-- exclude inactive restaurnt for matching - RestStateID = 4 means Inactive state 
	set @InactiveRestState = 4

    -- declare tmpRestaurantInfo  table to store temporary data
    declare @tmpRestaurantInfo table
    (
	    RName nvarchar(255) not null
	    ,RID int
	    ,MetroAreaName nvarchar(255) not null
	    ,SrNo int identity(1,1)
	    primary key 
	    (
		    RID
	    )
    )
	
	if len(rtrim(@RName)) > 0
		set @RName = '%' + rtrim(ltrim(@RName)) + '%'
	else
		set @RName = null

	-- RestaurantName without I18N Symbol
	if len(rtrim(@RCleanName)) > 0
		set @RCleanName = '%' + rtrim(ltrim(@RCleanName)) + '%'
	else
		set @RCleanName = null

	if len(rtrim(@MetroAreaName)) > 0
		set @MetroAreaName = '%' + rtrim(ltrim(@MetroAreaName)) + '%'
	else
		set @MetroAreaName = null

	if len(rtrim(@City)) > 0
		set @City = '%' + rtrim(ltrim(@City)) + '%'
	else
		set @City = null

	if len(rtrim(@State)) > 0
		set @State = '%' + rtrim(ltrim(@State)) + '%'
	else
		set @State = null

	if len(rtrim(@Zip)) > 0
		set @Zip = '%' + rtrim(ltrim(@Zip)) + '%'
	else
		set @Zip = null

	if len(rtrim(@WebSite)) > 0
		set @WebSite = '%' + rtrim(ltrim(@WebSite)) + '%'
	else
		set @WebSite = null

	if len(rtrim(@ReservationPhone)) > 0
	--Our requirement is compare only first 10 digit for ReservationPhone
		set @ReservationPhone = '%' + substring(rtrim(ltrim(@ReservationPhone)),1,10) + '%'
	else
		set @ReservationPhone = null


	-- If RID is given by the user then search on RID only
	if (@RID !=0)
	begin
		insert into
			@tmpRestaurantInfo 
			(
				RName
				,RID
				,MetroAreaName
            )
		select top 1 
			 Rest.RName
			,Rest.RID
			,Rest.MetroAreaName
		from 
			##tempRestaurantDetails Rest  
		where 
			Rest.RID = @RID
	end

	-- store scope_identity
	set @RecentIdentity = coalesce(scope_identity(),0)

	-- If data found for previous condition in that case we will get RecentIdentity
	-- do not need to search data if RecentIdentity is greater then  PreviousIdentity and return data 
	if (@RecentIdentity >@PreviousIdentity)
	begin
		goto quit
	end

	/* For reservation phone remove ['x','.','-'] characters form the string and compare only first 10 digits 
       requirement is compare only first 10 digit for ReservationPhone
	   If Parameter found null for City , State .... in that case we will relax fileter by 
	   coalesce(Rest.City, '-99') like coalesce(@City,Rest.City, '-99')
    */
	insert into 
		@tmpRestaurantInfo 
		(
			RName
			,RID
			,MetroAreaName
		)
	select  
		Rest.RName
		,Rest.RID
		,Rest.MetroAreaName
	from 
		##tempRestaurantDetails Rest
	where
		(
			Rest.RName like @RName or
			Rest.RName like @RCleanName
		)and
		Rest.MetroAreaName like @MetroAreaName and
		coalesce(Rest.City, '-99') like coalesce(@City,Rest.City, '-99') and
		coalesce(Rest.State, '-99') like coalesce(@State,Rest.State, '-99')	and
		coalesce(Rest.Zip, '-99') like coalesce(@Zip,Rest.Zip, '-99') and
		coalesce(Rest.ExternalURL, '-99') like coalesce(@WebSite,Rest.ExternalURL, '-99') and
		coalesce(substring(replace(replace(replace(Rest.ReservationPhone,'x',''),'.',''),'-','') ,1,10), '-99') like coalesce(@ReservationPhone,substring(replace(replace(replace(Rest.ReservationPhone,'x',''),'.',''),'-','') ,1,10), '-99')
		escape '\'

	-- store scope_identity
	set @RecentIdentity = coalesce(scope_identity(),0)

	-- If data found for previous condition in that case we will get RecentIdentity
	-- do not need to search data if RecentIdentity is greater then  PreviousIdentity and return data 
	if (@RecentIdentity >@PreviousIdentity)
	begin
		goto quit
	end
	
	-- If no data found then relax filter from Reservation Phone 
	insert into
		@tmpRestaurantInfo
		(
			RName
			,RID
			,MetroAreaName
		)
	select  
		Rest.RName
		,Rest.RID
		,Rest.MetroAreaName
	from 
		##tempRestaurantDetails Rest
	where 
		(
			Rest.RName like @RName or
			Rest.RName like @RCleanName
		)and
		Rest.MetroAreaName like @MetroAreaName and
		coalesce(Rest.City, '-99') like coalesce(@City,Rest.City, '-99') and
		coalesce(Rest.State, '-99') like coalesce(@State,Rest.State, '-99')	and
		coalesce(Rest.Zip, '-99') like coalesce(@Zip,Rest.Zip, '-99') and
		coalesce(Rest.ExternalURL, '-99') like coalesce(@WebSite,Rest.ExternalURL, '-99')
		escape '\'

	-- store scope_identity
	set @RecentIdentity = coalesce(scope_identity(),0)

	-- If data found for previous condition in that case we will get RecentIdentity
	-- do not need to search data if RecentIdentity is greater then  PreviousIdentity and return data 
	if (@RecentIdentity >@PreviousIdentity)
	begin
		goto quit
	end
	
	-- If no data found then relax filter from ExternalURL
	insert into
		@tmpRestaurantInfo
		(
			RName
			,RID
			,MetroAreaName
		)
	select  
		Rest.RName
		,Rest.RID
		,Rest.MetroAreaName
	from 
		##tempRestaurantDetails Rest
	where
		(
			Rest.RName like @RName or
			Rest.RName like @RCleanName
		)and
		Rest.MetroAreaName like @MetroAreaName and
		coalesce(Rest.City, '-99') like coalesce(@City,Rest.City, '-99') and
		coalesce(Rest.State, '-99') like coalesce(@State,Rest.State, '-99')	and
		coalesce(Rest.Zip, '-99') like coalesce(@Zip,Rest.Zip, '-99')
		escape '\'

	-- store scope_identity
	set @RecentIdentity = coalesce(scope_identity(),0)

	-- If data found for previous condition in that case we will get RecentIdentity
	-- do not need to search data if RecentIdentity is greater then  PreviousIdentity and return data 
	if (@RecentIdentity >@PreviousIdentity)
	begin
		goto quit
	end

	-- If no data found then relax filter from Zip
	insert into
		@tmpRestaurantInfo
		(
			RName
			,RID
			,MetroAreaName
		)
	select  
		Rest.RName
		,Rest.RID
		,Rest.MetroAreaName
	from 
		##tempRestaurantDetails Rest
	where 
		(
			Rest.RName like @RName or
			Rest.RName like @RCleanName
		)and
		Rest.MetroAreaName like @MetroAreaName and
		coalesce(Rest.City, '-99') like coalesce(@City,Rest.City, '-99') and
		coalesce(Rest.State, '-99') like coalesce(@State,Rest.State, '-99')	
		escape '\'

	-- store scope_identity
	set @RecentIdentity = coalesce(scope_identity(),0)

	-- If data found for previous condition in that case we will get RecentIdentity
	-- do not need to search data if RecentIdentity is greater then  PreviousIdentity and return data 
	if (@RecentIdentity >@PreviousIdentity)
	begin
		goto quit
	end

	-- If no data found then relax filter from State
	insert into
		@tmpRestaurantInfo
		(
			RName
			,RID
			,MetroAreaName
		)
	select  
		Rest.RName
		,Rest.RID
		,Rest.MetroAreaName
	from 
		##tempRestaurantDetails Rest
	where 
		(
			Rest.RName like @RName or
			Rest.RName like @RCleanName
		)and
		Rest.MetroAreaName like @MetroAreaName and
		coalesce(Rest.City, '-99') like coalesce(@City,Rest.City, '-99')
		escape '\'

	-- store scope_identity
	set @RecentIdentity = coalesce(scope_identity(),0)

	-- If data found for previous condition in that case we will get RecentIdentity
	-- do not need to search data if RecentIdentity is greater then  PreviousIdentity and return data 
	if (@RecentIdentity >@PreviousIdentity)
	begin
		goto quit
	end

	-- If no data found then relax filter from City
	insert into
	@tmpRestaurantInfo
	(
		RName
		,RID
		,MetroAreaName
	)
	select  
		Rest.RName
		,Rest.RID
		,Rest.MetroAreaName
	from 
		##tempRestaurantDetails Rest
	where 
		(
			Rest.RName like @RName or
			Rest.RName like @RCleanName
		)and
		Rest.MetroAreaName like @MetroAreaName 
		escape '\'

	-- store scope_identity
	set @RecentIdentity = coalesce(scope_identity(),0)

	-- If data found for previous condition in that case we will get RecentIdentity
	-- do not need to search data if RecentIdentity is greater then  PreviousIdentity and return data 
	if (@RecentIdentity >@PreviousIdentity)
	begin
		goto quit
	end

	
	-- If no data found then strip one word from the end and tries to match again – repeats till only one word is left 
	while (CharIndex(' ', @RestaurantName) <> 0)
	begin
		
		set @RestaurantName = substring(@RestaurantName,0,(Len(@RestaurantName) - CharIndex(' ', Reverse(@RestaurantName)))+1)

		insert into
		@tmpRestaurantInfo
		(
			RName
			,RID
			,MetroAreaName
		)
		select  
			Rest.RName
			,Rest.RID
			,Rest.MetroAreaName
		from 
			##tempRestaurantDetails Rest
		where 
			Rest.RName like '%' + rtrim(ltrim(@RestaurantName)) + '%' and
			Rest.MetroAreaName like @MetroAreaName
		escape '\'

		-- store scope_identity
		set @RecentIdentity = coalesce(scope_identity(),0)

		-- If data found for previous condition in that case we will get RecentIdentity
		-- do not need to search data if RecentIdentity is greater then  PreviousIdentity and return data 
		if (@RecentIdentity >@PreviousIdentity)
		begin
			goto quit
		end

	end

	-- When we found data for any condition that quit from the proc. Do not need to search data again
	quit:
		select
			RID
			,RName
			,MetroAreaName 
			,RName +' - '+ cast(RID as varchar)+' - '+MetroAreaName as PossibleMatch ,
			@ExcelRowID as ExcelRowID
		from 
			@tmpRestaurantInfo	 
		order by 
			RName

GO

grant execute on [SearchRestInfoForWebPagePromo] to ExecuteOnlyRole

GO


