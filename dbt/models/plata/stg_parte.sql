-- PLATA · el parte diario limpio: la limpieza que hiciste en la J3, ahora como modelo dbt.
-- Cada entrega del parte es una carpeta fecha_carga=… en bronce: aquí se leen todas juntas.
with bruto as (
    select *, parse_filename(filename) as archivo
    from {{ source('bronce', 'parte') }}
),
sin_dup as (
    -- una fila por pedido
    select * from bruto
    qualify row_number() over (partition by pedido order by fecha_carga desc) = 1
),
mediana_tipo_pieza as (
    select tipo_pieza, median(minutos::integer) as minutos_mediana
    from sin_dup
    where minutos::integer between 1 and 2880
    group by tipo_pieza
)
select
    s.pedido,
    s.fecha::date                                              as fecha,
    upper(trim(s.operario))                                         as operario,
    s.impresora,
    s.tipo_pieza,
    case when s.minutos::integer between 1 and 2880 then s.minutos::integer
         else round(m.minutos_mediana)::integer end               as minutos,
    not (s.minutos::integer between 1 and 2880)                   as minutos_corregido,
    s.gramos_filamento::double                                              as gramos_filamento,
    s.importe_eur::double                                      as importe_eur,
    s.incidencia,
    s.archivo,
    s.fecha_carga
from sin_dup s
join mediana_tipo_pieza m using (tipo_pieza)
