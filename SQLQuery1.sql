create database SalesDB
use SalesDB

create table Customers(
	CustomerID int identity(1, 1) primary key,
	FullName nvarchar(100) not null,
	Email nvarchar(100) unique not null,
	RegistrationDate datetime not null default GETDATE(),
)
create table Orders(
	OrderID int identity(1, 1) primary key,
	CustomerID int not null foreign key references Customers(CustomerID),
	OrderTotal float not null check(OrderTotal > 0),
	OrderDate datetime not null default GETDATE(),
	[Status] nvarchar(20) not null default 'Новый',
)

create database Warehouses
use Warehouses

create table Warehouses(
	WarehouseID int identity(1, 1) primary key,
	[Location] nvarchar(100) unique not null,
	Capacity float not null,
	ManagerContact nvarchar(50) not null default 'Не назначен',
	CreatedDate datetime not null default GETDATE(),
)
create table Shipments(
	ShipmentID int identity(1, 1) primary key,
	WarehouseID int not null foreign key references Warehouses(WarehouseID),
	OrderID int not null,
	TrackingCode nvarchar(50) unique not null,
	[Weight] float not null,
	DispatchDate datetime,
	[Status] nvarchar(20) not null default 'Ожидает отправки',
)