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