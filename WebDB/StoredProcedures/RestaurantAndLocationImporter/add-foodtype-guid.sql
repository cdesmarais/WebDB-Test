if not exists(select * from sys.columns 
            where Name = N'GUID' and Object_ID = Object_ID(N'FoodType'))
	alter table dbo.FoodType add
		GUID uniqueidentifier null
	go

if exists(select * from dbo.FoodType where [GUID] is null)
	update dbo.FoodType set [GUID] = (select newid())
	go

if not exists(select * from sys.default_constraints where name = N'DF_FoodType_GUID')
	alter table dbo.FoodType
	    add constraint DF_FoodType_GUID default newid() for GUID
	go

alter table dbo.FoodType    
    alter column [GUID] uniqueidentifier not null
go
