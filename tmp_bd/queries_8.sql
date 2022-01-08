set search_path to proj; 
-- RICHIDEDONO RITOCCHI VARI





/* 1 carico lavoro*/
select id_gioco
from dado natural join gioco
where maxsquadre <=4
group by id_gioco
having count(*) = 2;

/* 2 carico lavoro*/
select id_sfida
from sfida
where id_gioco = 'qualcosa'
and
(
	data_ora_inizio::text like '2021-01%' and ""stessa cosa per fine"" and DATE_PART('hour', ""la differenza"") >=2
)
or
(
	""stessa cosa""
);

/* 3 carico lavoro*/
select *
from sfida
where 	date_part('hour', (data_ora_fine - data_ora_inizio)) >2
	and
		id_gioco IN (
			select id_gioco
			from dado
			group by id_gioco
			having count(*) =2
		);



/*NON WORKLOAD*/

1//work in progress

 SELECT sfida.id_gioco,
    count(*) AS count,
    avg(sfida.data_ora_fine - sfida.data_ora_inizio) AS avg
   FROM proj.sfida
  GROUP BY sfida.id_gioco;


/*testa con questa*/

select *, (data_ora_fine-data_ora_inizio)
from sfida
order by id_gioco;



-- 2 --
-- A/
select distinct id_gioco
from casella
where tipo = 'task'
order by id_gioco;



-- B/
select id_gioco
from casella
where id_gioco NOT IN (select distinct id_gioco
						from casella
						where tipo = 'task'
						order by id_gioco
					  );


-- C/
select *
from sfida s
where (data_ora_fine - data_ora_inizio) > (
	select avg(data_ora_fine - data_ora_inizio)
	from sfida
	where s.id_gioco = id_gioco
)

