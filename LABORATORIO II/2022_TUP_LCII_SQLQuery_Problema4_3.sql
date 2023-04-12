/**
Problema 4.3
1. Programar procedimientos almacenados que permitan realizar las siguientes tareas:

a. Mostrar los artículos cuyo precio sea mayor o igual que un valor que se
envía por parámetro.
**/
create proc pa_43_1a
@precio money
as 
select *--listar columnas
from articulos
where pre_unitario>=@precio

/**
b. Ingresar un artículo nuevo, verificando que la cantidad de stock que se pasa
por parámetro sea un valor mayor a 30 unidades y menor que 100. Informar
un error caso contrario.
**/
create proc pa_23_1b
@stock int=null,
@descripcion varchar(100)=null,
@precio money=null
--crear un parámetro por cada campo de articulos
as
 if @stock>30 and @stock<100
	begin
		insert into articulos (descripcion,pre_unitario,stock)--todos los campos de articulos
			values(@descripcion,@precio,@stock)--valores por parámetro
		print 'registro insertado' --se puede hacer con select
	end
 else
	select 'No cumple con las especificaciones de stock'--se puede hacer con print

exec pa_23_1b 'Aaaaaa',100,500

select * from articulos

--c. Mostrar un mensaje informativo acerca de si hay que reponer o no stock de
--un artículo cuyo código sea enviado por parámetro
create proc pa_23_1c
@cod int
as
declare @difstk int
select @difstk=stock-stock_minimo --se puede guardar descripcion para mostrar
from articulos
where cod_articulo=@cod
if @difstk<=0
	select @cod as codigo,'reponer stock' as mensaje --se puede mostrar la descripcion
else
	select @cod as codigo,'stock ok' as mensaje --se puede mostrar la descripcion
	
exec  pa_23_1c 1


--d. Actualizar el precio de los productos que tengan un precio menor a uno
--ingresado por parámetro en un porcentaje que también se envíe por
--parámetro. Si no se modifica ningún elemento informar dicha situación
create proc pa_23_1d
@prec money=null,
@porc decimal(4,2)=null
as
if @prec is null or @porc is null
	select 'Se debe ingresar un valor' as '¡ATENCIÓN!'
else
  begin
	update articulos
		set pre_unitario=pre_unitario*(1+@porc/100)
		where pre_unitario<@prec
	select 'Se actualizaron registros' as 'Mensaje'
  end

exec pa_23_1d 100,10

--e. Mostrar el nombre del cliente al que se le realizó la primer venta en un
--parámetro de salida.
create proc pa_23_1e
@cod int output  --considerar la posibilidad de mostrar apellido y nombre
as 
select top 1 @cod=cod_cliente
from facturas
order by fecha

declare @c int
exec pa_23_1e @c output
select @c as '1er cliente' --considerar la posibilidad de mostrar apellido y nombre

create proc pa_23_1e_bis
@cod int output, 
@ape varchar(100) output,
@nom varchar(100) output
as 
select top 1 @cod=c.cod_cliente, @ape=ape_cliente, @nom=nom_cliente
from facturas f join clientes c on f.cod_cliente=c.cod_cliente
order by fecha

declare @c int, @a varchar(100),@n varchar(100)
exec pa_23_1e @c output,@a output,@n output
select @c as 'codigo 1er cliente', @a+' '+@n '1er cliente'

--f. Realizar un select que busque el artículo cuyo nombre empiece con un valor
--enviado por parámetro y almacenar su nombre en un parámetro de salida.
--En caso que haya varios artículos ocurrirá una excepción que deberá ser
--manejada con try catch.
alter proc pa_23_1f
@nom_ent varchar(10)='%',
@nom_sal varchar(150) output  
as 
begin try
	set @nom_sal=(select descripcion
	from articulos
	where descripcion like @nom_ent )
end try
begin catch
	select ERROR_NUMBER() as 'Nro. error', ERROR_MESSAGE() as Error
end catch

declare @n_sal varchar(150)
exec pa_23_1f 'l%', @n_sal output
select @n_sal as 'articulo'



--2. Programar funciones que permitan realizar las siguientes tareas:
--a. Devolver una cadena de caracteres compuesto por los siguientes datos:
--Apellido, Nombre, Telefono, Calle, Altura y Nombre del Barrio, de un
--determinado cliente, que se puede informar por codigo de cliente o email.

create function f_23_2a
(@cod int=null,@mail varchar(100)=null)
returns varchar(250)
as
begin
	declare @cadena varchar(250)
	if @cod is null and @mail is not null
		set @cadena= (select ape_cliente+' '+nom_cliente+' Tel. '+' calle '+calle+' '+trim(str(altura))+' B° '+barrio
		from clientes c join barrios b on b.cod_barrio=c.cod_barrio
		where [e-mail] like @mail)
	else
		if @cod is not null and @mail is null
			select @cadena=ape_cliente+' '+nom_cliente+' Tel. '+' calle '+calle+' '+trim(str(altura))+' B° '+barrio
			from clientes c join barrios b on b.cod_barrio=c.cod_barrio
			where cod_cliente=@cod
		else
			if @cod is not null and @mail is not null
				select @cadena=ape_cliente+' '+nom_cliente+' Tel. '+' calle '+calle+' '+trim(str(altura))+' B° '+barrio
				from clientes c join barrios b on b.cod_barrio=c.cod_barrio
				where [e-mail] like @mail and cod_cliente = @cod
			else
				set @cadena= 'debe proporcionar el código o la dirección de correo'
	return @cadena
end

select dbo.f_23_2a(1,default)
		

--b. Devolver todos los artículos, se envía un parámetro que permite ordenar el
--resultado por el campo precio de manera ascendente (‘A’), o descendente
--(‘D’).
/******************************************************
create function f_23_2b  --no lo ordena HAY QUE USAR UN SP
(@orden varchar(1)='A')
returns @art table
(cod int, descrip varchar(100),pre money)
as 
begin
	if @orden='A'
		insert @art select cod_articulo,descripcion,pre_unitario from articulos
		order by pre_unitario
	else
		insert @art select cod_articulo,descripcion,pre_unitario from articulos
		order by pre_unitario desc
	return
end

select *
from dbo.f_23_2b('A')
***************************************************/
create proc pa_23_2b  
@orden varchar(1)='A'
as 
	if @orden='A'
		select cod_articulo,descripcion,pre_unitario from articulos
		order by pre_unitario
	else
		select cod_articulo,descripcion,pre_unitario from articulos
		order by pre_unitario desc

exec pa_23_2b 'D'

--c. Crear una función que devuelva el precio al que quedaría un artículo en
--caso de aplicar un porcentaje de aumento pasado por parámetro.
create function f_23_2c
(@cod int,@por decimal(3,1))
returns @pre_art table
(cod int, descrip varchar(100),pre money)
as 
begin
	insert @pre_art select cod_articulo,descripcion,pre_unitario*(1+@por/100) from articulos
		where cod_articulo=@cod
	return
end

select *
from dbo.f_23_2c(1,10)