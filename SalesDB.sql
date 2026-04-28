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

go
create function fn_GetCustomers()
returns table
as
return (select Customers.CustomerID, Customers.FullName, Customers.Email, Customers.RegistrationDate from Customers)
go

go
create function fn_GetOrdersByStatus(@status nvarchar(20))
returns table
as
return (select Orders.OrderID, Customers.FullName, Customers.Email, Orders.OrderTotal, Orders.OrderDate, Orders.[Status] from Orders
		join Customers on Orders.CustomerID = Customers.CustomerID
		where Orders.[Status] = @status)
go

create trigger trg_AddToShipments
on Orders
after insert, update
as 
begin
	begin transaction
		begin try
			insert into LogisticsDB.dbo.Shipments(WareHouseID, OrderID, TrackingCode, DispatchDate, [Weight], [Status])
				select 1, OrderID, 'TRK_' + convert(nvarchar(46), newid()), null, 1, 'Ожидает отправки' from inserted
				where inserted.[Status] = 'Подтвержден'
			commit transaction
		end try
		begin catch
			rollback transaction
			throw
		end catch
end