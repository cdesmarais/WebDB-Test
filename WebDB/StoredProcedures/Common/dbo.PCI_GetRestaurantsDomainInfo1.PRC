if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PCI_GetRestaurantsDomainInfo1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PCI_GetRestaurantsDomainInfo1]
go

create procedure dbo.PCI_GetRestaurantsDomainInfo1
as  
	/* 
	Stored procedure to get Restaurants Domain afrom regional WebDBs.
	Used in OTR project to determine regional WebDB/WeblogDB database to which restaurant belongs.
	Content owned by India team, please notify asaxena@opentable.com if changing.
	*/
	select	 
			RID as WebID
			,RName collate sql_latin1_general_cp1_cs_as as RName  
			,case 
				when db_name() like 'WebDB' then 'WebDB'
				when db_name() like 'WebDB_EU' then 'WebDB_EU'
				when db_name() like 'WebDB_Asia' then 'WebdB_Asia'
			 end as DatabaseName
			,restvw.DomainID
			,cvw.CurrencySymbol collate sql_latin1_general_cp1_cs_as as Currency
			,cvw.CountryID collate sql_latin1_general_cp1_cs_as as CountryID
			,dl.Domain collate sql_latin1_general_cp1_cs_as as Domain   
			,l.LanguageCode collate sql_latin1_general_cp1_cs_as as LanguageCode
			,dl.SecureSite collate sql_latin1_general_cp1_cs_as as SecureSite
	from	
			RestaurantVW restvw
	inner join 
			CountryVW cvw  /* To get Currency */  
			on restvw.Country = cvw.CountryID
  
  	/* Note: Two joins are added on Domain table bacause of incorrect domain of UK Restaurants. */  
	inner join 
			Domain dl /* To get Domain based on DomainId */  
			on restvw.DomainID = dl.DomainId  
  
	left join 
			Domain dm /* To get language Code based on Country */  
			on cvw.CountryID = dm.PrimaryCountryID  
  
	left join 
			Language l   
			on coalesce(dm.PrimaryLanguageId,dl.PrimaryLanguageId) = l.LanguageId
go

GRANT EXECUTE ON [PCI_GetRestaurantsDomainInfo1] TO ExecuteOnlyRole
go



