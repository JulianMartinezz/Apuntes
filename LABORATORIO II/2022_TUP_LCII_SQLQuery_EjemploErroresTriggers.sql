begin try
  select 15/0 as error;
end try
begin catch
  select 'Se produjo el siguiente error',
    error_number() as Número,
    error_state() as Estado,
    error_severity() as Gravedad,
    error_procedure() as Procedimiento,
    error_line() as Linea,
    error_message() as Menesaje;
end catch;


select *,len(description) from master.dbo.sysmessages

select * from barrios
Create table #errores
(id int identity (1,1),
nro_err int,
mensaje varchar(500),
fecha_err datetime
constraint pk_errores primary key (id)
)

begin try
	insert into barrios values (1,'hola')
end try
begin catch
	Print trim(str(ERROR_NUMBER())) + '-'+'El código de barrio ya existe'
	insert into #errores values (error_number(),left(ERROR_MESSAGE(),100),getdate())
end catch
select * from #errores

--si se quiere controlar que en una venta la cantidad vendida sea menor 
--o igual al stock disponible y a la vez actualizar el stock, 
--se puede crear un trigger sobre la tabla detalles_facturas para el 
--evento de inserción:
 create trigger dis_ventas_insertar
  on detalle_facturas
  for insert
  as
   declare @stock int
   select @stock= stock from articulos
		 join inserted
		 on inserted.cod_articulo=articulos.cod_articulo
  if (@stock>=(select cantidad from inserted))
    update articulos set stock=stock-inserted.cantidad
     from articulos
     join inserted
     on inserted.cod_articulo=articulos.cod_articulo
  else
  begin
    raiserror ('El stock en articulos es menor que la cantidad
               solicitada', 16, 1)
    rollback transaction
  end

--crea para que cada vez que se elimine un registro de detalles_facturas, se actualice el campo "stock" de la tabla artículos:
create trigger dis_ventas_borrar
  on detalle_facturas
  for delete 
 as
   update articulos set stock = a.stock + deleted.cantidad
   from articulos a
   join deleted on deleted.cod_articulo = a.cod_articulo;


--se quiere evitar que se modifiquen los datos de la tabla artículos y para ello se crea el siguiente disparador:
 create trigger dis_articulos_actualizar
  on articulos
  for update
  as
    raiserror('No se pueden modificar los datos de los
               articulos', 10, 1)
    rollback transaction

--Si se quisiera evitar que se actualice el campo "pre_unitario" de la tabla articulos:
 create trigger dis_articulos_actualizar_precio
  on articulos
  for update
  as
   if update(pre_unitario)
   begin
    raiserror('No se puede modificar el precio de un
               artículo', 10, 1)
    rollback transaction
   end;

--Si se quieren modificar los datos de los clientes excepto el cod_cliente
create trigger dis_clie_actualizar
  on clientes
  instead of update
  as
   if update(cod_cliente)
   begin
     raiserror('Los códigos no pueden modificarse', 10, 1)
     rollback transaction
   end
   else
   begin
     update clientes 
        set clientes.nom_cliente=inserted.nom_cliente,
            clientes.ape_cliente=inserted.ape_cliente
       from clientes join inserted
         on clientes.cod_cliente =inserted.cod_cliente
   end


  --Ejemplo de INSTED OF
alter trigger dis_prueba1
on articulos
instead of update
as
	if UPDATE(pre_unitario)
	  begin
		print 'no se puede modificar el código de articulo'
		--rollback transaction
	  end
	else
	  begin
		select * ,'deleted' from deleted
		select *, 'inserted' from inserted
		update articulos
		set descripcion=(select descripcion from inserted),
			stock=(select stock from inserted),
			stock_minimo=(select stock_minimo from inserted),
			observaciones=(select observaciones from inserted)
		where cod_articulo =(select cod_articulo from inserted)
		print 'Ha modificado la tabla articulos'
		--select * from deleted
		--select * from inserted
	  end



Select * from articulos

update articulos
set observaciones='aaaaaa'
where cod_articulo=1

update articulos
set pre_unitario=15
where cod_articulo=1

