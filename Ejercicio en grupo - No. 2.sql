/*Trabajo en Grupo # 1*/

--04/11/2021

CREATE DATABASE Equipo_No_1
GO

USE Equipo_No_1
GO

CREATE TABLE Clientes 
(codCliente int primary key,
nombreCliente varchar (50) not null
)
GO

insert into Clientes values
(1, 'Paula'),
(2, 'Mahely'),
(3, 'Juan')
GO

CREATE TABLE Cuentas
(numCuenta int primary key,
saldoCuenta money not null,
codigoCliente int foreign key references Clientes(codCliente)
)
GO

insert into Cuentas values
(4010,500,2),
(4011,1000,1),
(4012,1500,3)
GO


CREATE TABLE Depositos
(
numDeposito int primary key,
fechaDeposito date not null,
montoDeposito money not null,
numeroCuenta int foreign key references Cuentas(numCuenta)
)
GO

CREATE TABLE Retiros
(numRetiro int primary key,
fechaRetido date not null,
montoRetiro money not null,
numeroCuenta int foreign key references Cuentas(numCuenta)
)
GO

CREATE TABLE Bitacora
(numEvento int identity primary key,
numeroCuenta int foreign key references Cuentas(numCuenta),
fechaEvento date not null,
descripcion varchar(60) not null,
valorAnterior money not null,
valorActual money not null,
idUsuario varchar(30) not null,
nombreComputador varchar(30) not null
)
GO

--------------------------------------------------------------------------

--TRIGGERS
--TRIGER INSERT DEPOSITO
create trigger tr_actualizarCuenta
on Depositos for insert
as
set nocount on
begin
update Cuentas set Cuentas.saldoCuenta = C.saldoCuenta + i.montoDeposito
from inserted i
inner join Cuentas C
on C.numCuenta = i.numeroCuenta
end
GO

--TRIGGER INSERT RETIRO
create trigger tr_actualizaRetiro
on Retiros for insert
as
set nocount on
begin
update Cuentas set Cuentas.saldoCuenta = C.saldoCuenta - i.montoRetiro
from inserted i
inner join Cuentas C
on C.numCuenta = i.numeroCuenta
end
GO

--TRIGGER ACTUALIZAR BITACORA DEPOSITO
create trigger tr_actualizarBitacoraDeposito
on Depositos for insert
as
set nocount on
begin
declare @numCuent intdeclare @valorAnterior moneydeclare @valorActual money
-- 4000 - 500
select @numCuent = C.numCuenta,@valorAnterior = C.saldoCuenta - i.montoDeposito,@valorActual = C.saldoCuenta
from Cuentas C
inner join inserted i 
on C.numCuenta = i.numeroCuenta
insert into Bitacora values
(
	@numCuent,
	GETDATE(),
	'Deposito Realizado',
	@valorAnterior,
	@valorActual,
	USER_ID(),
	HOST_NAME()
)
end
GO

--TRIGGER ACTUALIZAR BITACORA RETIRO
create trigger tr_actualizarBitacoraRetiro
on Retiros for insert
as
set nocount on
begin
declare @numCuent intdeclare @valorAnterior moneydeclare @valorActual money
select @numCuent = C.numCuenta,@valorAnterior = C.saldoCuenta + i.montoRetiro,@valorActual = C.saldoCuenta
from Cuentas C
inner join inserted i
on C.numCuenta = i.numeroCuenta
insert into Bitacora values
(
	@numCuent,
	GETDATE(),
	'Retiro Realizado',
	@valorAnterior,
	@valorActual,
	USER_ID(),
	HOST_NAME()
)
end
GO

--------------------------------------------------------------------------

--PROCEDIMIENTOS ALMACENADOS
--DEPOSITOS
CREATE PROC pa_IngresarDeposito
@numeroDeposito int,
@fechaDeposito date,
@montoDeposito money,
@numeroCuenta int
AS
BEGIN
insert into Depositos values
(@numeroDeposito, @fechaDeposito, @montoDeposito, @numeroCuenta)
END


-- Ejecusión (Ingresar Deposito)
declare @numDeposito int
declare @fecDeposito date
declare @montDeposito money
declare @numeCuenta int
set @numDeposito = 4
set @fecDeposito = GETDATE()
set @montDeposito = 150
set @numeCuenta = 4010

exec pa_IngresarDeposito @numDeposito, @fecDeposito, 
@montDeposito, @numeCuenta

--------------------------------------------------------------------------

CREATE PROC pa_ActualizarDeposito
@numeroDeposito int,
@fechaDeposito date,
@montoDeposito money,
@numeroCuenta int
AS
BEGIN
update Depositos
set fechaDeposito=@fechaDeposito, montoDeposito=@montoDeposito
where numDeposito = @numeroDeposito and numeroCuenta = @numeroCuenta
END


-- Ejecusión (Actualizar Deposito)
declare @numDeposito int
declare @fecDeposito date
declare @montDeposito money
declare @numeCuenta int
set @numDeposito = 1
set @fecDeposito = GETDATE()
set @montDeposito = 500
set @numeCuenta = 4010

exec pa_ActualizarDeposito @numDeposito, @fecDeposito, 
@montDeposito, @numeCuenta

--------------------------------------------------------------------------

CREATE PROC pa_EliminarDeposito
@numeroDeposito int
AS
BEGIN
delete from Depositos
where numDeposito = @numeroDeposito
END

-- Ejecusión (Eliminar Deposito)
declare @numDeposito int
set @numDeposito = 1

exec pa_EliminarDeposito @numDeposito

--------------------------------------------------------------------------
-- RETIROS
CREATE PROC pa_IngresarRetiro
@numeroRetiro int,
@fechaRetiro date,
@montoRetiro money,
@numeroCuenta int
AS
BEGIN
insert into Retiros values
(@numeroRetiro, @fechaRetiro, @montoRetiro, @numeroCuenta)
END

-- Ejecusión (Ingresar Retiro)
declare @numRetiro int
declare @fecRetiro date
declare @montRetiro money
declare @numeCuenta int
set @numRetiro = 2
set @fecRetiro = GETDATE()
set @montRetiro = 10
set @numeCuenta = 4011

exec pa_IngresarRetiro @numRetiro, @fecRetiro, 
@montRetiro, @numeCuenta

--------------------------------------------------------------------------

CREATE PROC pa_ActualizarRetiro
@numeroRetiro int,
@fechaRetiro date,
@montoRetiro money,
@numeroCuenta int
AS
BEGIN
update Depositos
set fechaDeposito=@fechaRetiro, montoDeposito=@montoRetiro
where numDeposito = @numeroRetiro and numeroCuenta = @numeroCuenta
END

-- Ejecusión (Actualizar Retiro)
declare @numRetiro int
declare @fecRetiro date
declare @montRetiro money
declare @numeCuenta int
set @numRetiro = 1
set @fecRetiro = GETDATE()
set @montRetiro = 7000
set @numeCuenta = 4010

exec pa_ActualizarRetiro @numRetiro, @fecRetiro, 
@montRetiro, @numeCuenta

--------------------------------------------------------------------------

CREATE PROC pa_EliminarRetiro
@numeroRetiro int
AS
BEGIN
delete from Retiros
where numRetiro = @numeroRetiro
END

-- Ejecusión (Eliminar Retiro)
declare @numRetiro int
set @numRetiro = 1

exec pa_EliminarRetiro @numRetiro

--------------------------------------------------------------------------

select * from Bitacora
select * from Clientes
select * from Cuentas
select * from Depositos
select * from Retiros

