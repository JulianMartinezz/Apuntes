--Problema 4.1
--1.Declarar 3 variables 	que se llamen codigo, stock y stockMinimo respectivamente. 
--A la variable codigo setearle un valor. Las variables stock y stockMinimo almacenarán el resultado 
--de las columnas de la tabla artículos stock y stockMinimo respectivamente filtradas por el código 
--que se corresponda con la variable codigo.
declare @codigo int, @stock int, @stockMinimo int
set @codigo=3
select @stock=stock, @stockMinimo=stock_minimo
from articulos
where cod_articulo=@codigo
select @stock 'Stock', @stockMinimo 'Stock mínimo'

--2.Utilizando el punto anterior, verificar si la variable stock o stockMinimo 
--tienen algún valor. Mostrar un mensaje indicando si es necesario realizar 
--reposición de artículos o no.
declare @codigo int, @stock int, @stockMinimo int
set @codigo=2
select @stock=stock, @stockMinimo=stock_minimo
from articulos
where cod_articulo=@codigo
if @stock is null or @stockMinimo is null
	print 'no hay datos suficientes'
else
	if @stock-@stockMinimo<=0
		print 'Es necesario realizar reposición del articulo: ' + trim(str(@codigo))
	else
		print 'Hay stock suficiente del articulo: ' + trim(str(@codigo))

--3.Modificar el ejercicio 1 agregando una variable más donde se almacene 
--el precio del artículo. En caso que el precio sea menor a $500, aplicarle un 
--incremento del 10%. En caso de que el precio sea mayor a $500 notificar dicha 
--situación y mostrar el precio del artículo.
declare @codigo int=1, @precio money
select @precio=pre_unitario
	from articulos
	where cod_articulo=@codigo
if @precio < 500 
   begin
	update articulos
	   set pre_unitario=pre_unitario*1.1
	 where cod_articulo=@codigo
	print 'precio modificado'
   end
else
	select @codigo as codigo, @precio as precio,
		   'No es necesario modificar el precio' as observaciones

/*
4. Declarar dos variables enteras, y mostrar la suma de todos los números
comprendidos entre ellos. En caso de ser ambos números iguales mostrar un
mensaje informando dicha situación
**/
declare @n1 int,@n2 int
set @n1 = 1
set @n2 = 3
if @n1>=@n2
	select 'n1 debe ser mayor que n2'
else
	begin
		declare @suma int=0
		while @n1<=@n2
			begin
				set @suma=@suma+@n1
				set @n1=@n1+1
			end
		select @suma as suma
	end

/**
5. Mostrar nombre y precio de todos los artículos. Mostrar en una tercer columna la
leyenda ‘Muy caro’ para precios mayores a $500, ‘Accesible’ para precios entre $300
y $500, ‘Barato’ para precios entre $100 y $300 y ‘Regalado’ para precios menores a
$100.
**/
select descripcion, pre_unitario, mensaje=
	case
		when pre_unitario>500 then 'Muy caro'
		when pre_unitario>=300 and pre_unitario<=500 then 'Accesible'
		when pre_unitario>=100 and pre_unitario<300 then 'Barato'
		when pre_unitario<100 then 'Regalado'
	end
from articulos
/**
6. Modificar el punto 2 reemplazando el mensaje 
de que es necesario reponer artículos
por una excepción
**/
declare @codigo int=1, @stock int, @stockMinimo int
select @stock=stock ,@stockminimo=stock_minimo
	from articulos
	where cod_articulo=@codigo
if @stock is null or @stockMinimo is null 
	raiserror ('hay valores nulos',11,1)
else
	if @stock<=@stockMinimo
		raiserror ('realizar la reposición del stock',10,1)
	else
		raiserror ('No es necesario realizar la reposición del stock',10,1)

