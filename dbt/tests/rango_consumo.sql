-- gramos_filamento tiene que estar en un rango creíble para este negocio (13.55 a 506.6).
select pedido, gramos_filamento from {{ ref('stg_parte') }}
where gramos_filamento not between 13.55 and 506.6
