*select single * from a003
*  into gs_a003
*  where mwskz = <fs>-mwskz
*  and aland = is_ekko-stceg_l and kappl = 'TX'.

SELECT * from a003
into table gt_a003
where mwskz = <fs>-mwskz
and aland = is_ekko-stceg_l and kappl = 'TX'.




















