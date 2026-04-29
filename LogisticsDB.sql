create database LogisticsDB
use LogisticsDB

create table Warehouses(
	WarehouseID int identity(1, 1) primary key,
	[Location] nvarchar(100) unique not null,
	Capacity float not null,
	ManagerContact nvarchar(50) not null default 'Не назначен',
	CreatedDate datetime not null default GETDATE(),
)
create table Shipments(
	ShipmentID int identity	(1, 1) primary key,
	WarehouseID int not null foreign key references Warehouses(WarehouseID),
	OrderID int not null,
	TrackingCode nvarchar(50) unique not null,
	[Weight] float not null,
	DispatchDate datetime,
	[Status] nvarchar(20) not null default 'Ожидает отправки',
)


go
create function fn_GetShipmentsByWarehouse(@wid int)
returns table
as
return (select Shipments.ShipmentID, Shipments.WarehouseID, Warehouses.[Location], Warehouses.ManagerContact, Shipments.OrderID, Shipments.TrackingCode, Shipments.[Weight],
		Shipments.DispatchDate, Shipments.[Status] from Shipments
		join Warehouses on Shipments.WarehouseID = Warehouses.WarehouseID
		where Shipments.WarehouseID = @wid)
go


go
create function fn_GetShipments()
returns table
as
return (select Shipments.ShipmentID, Shipments.WarehouseID, Warehouses.[Location], Warehouses.ManagerContact, Shipments.OrderID,
		Shipments.TrackingCode, Shipments.[Weight], Shipments.DispatchDate, Shipments.[Status] from Shipments
		join Warehouses on Shipments.WarehouseID = Warehouses.WarehouseID)
go


go
create function fn_GetWarehouse()
returns table
as
return (select Warehouses.WarehouseID, Warehouses.[Location], Warehouses.Capacity, Warehouses.ManagerContact, Warehouses.CreatedDate from Warehouses)
go


go
create procedure ProblemUpdate
as
begin
	begin transaction
		begin try
			update Warehouses set [Location] = (select top 1 [Location] from Warehouses)
			commit transaction
		end try
		begin catch
			rollback transaction
			raiserror('Ошибка обновления', 16, 1)
		end catch
end
go


exec SalesDB.dbo.pr_AddWarehouse 'Молочное', 2
exec Salesdb.dbo.pr_AddWarehouse 'Кефир', 2

select * from fn_GetShipments()
select * from fn_GetWarehouse()

exec ProblemUpdate
exec SalesDB.dbo.pr_AddWarehouse '1', 1

