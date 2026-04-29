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


go
create function fn_GetOrders()
returns table
as
return (select Orders.OrderID, Customers.FullName, Customers.Email, Orders.OrderTotal, Orders.OrderDate, Orders.[Status] from Orders
		join Customers on Orders.CustomerID = Customers.CustomerID)
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


go
create procedure pr_AddCustomers @FullName nvarchar(100), @Email nvarchar(100), @RegistrationDate datetime = null
as
begin
	if @RegistrationDate is null
		set @RegistrationDate = getdate()

	if(@Email not like '%@%.%')
	begin
		raiserror('Почему в почте нет @ и чертова домена?', 0, 0)
		return
	end

	if exists (select 1 from Sales.dbo.Customers where Email = @Email)
	begin
		raiserror('Почта должна быть уникальной.', 0, 0)
		return
	end

	insert into Sales.dbo.Customers values(@FullName, @Email, @RegistrationDate)
end
go


go
create procedure pr_AddOrders @CustomersID int, @OrderTotal float, @OrderDate datetime = null, @Status nvarchar(20) = 'Новый'
as
begin
	if @OrderDate is null
		set @OrderDate = getdate()

	if(@OrderTotal <= 0)
	begin
		raiserror('OrderTotal не должен быть меньше 0', 0, 0)
		return
	end

	if not exists (select 1 from Customers where CustomerID = @CustomersID)
	begin
		raiserror('Несуществующий CustomerID', 0, 0)
		return
	end

	insert into SalesDB.dbo.Orders values(@CustomersID, @OrderTotal, @OrderDate, @Status)
end
go


go
create procedure pr_AddWarehouse @Location nvarchar(100), @Capacity float, @ManagerContact nvarchar(50) = 'Не назначен', @CreatedDate datetime = null
as
begin
	if @CreatedDate is null
		set @CreatedDate = getdate()

	if exists (select 1 from LogisticsDB.dbo.Warehouses where [Location] = @Location)
	begin
		raiserror('Location не должны повторяться', 0, 0)
		return
	end

	insert into LogisticsDB.dbo.Warehouses values(@Location, @Capacity, @ManagerContact, @CreatedDate)
end
go


exec pr_AddCustomers 'Nate', 'Higgers'
exec pr_AddCustomers 'Chadolf', 'R1zzler@tuta.com'
exec pr_AddOrders 1, 1
exec pr_AddOrders 1, -1


select * from fn_GetCustomers()
select * from fn_GetOrders()


update Orders set [Status] = 'Подтверждён' where OrderID = 1


