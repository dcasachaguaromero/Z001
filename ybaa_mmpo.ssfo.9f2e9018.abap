*select single * from a003
*  into gs_a003
*  where mwskz = <fs>-mwskz
*  and aland = is_ekko-stceg_l and kappl = 'TX'.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * from a003
*into table gt_a003
*where mwskz = <fs>-mwskz
*and aland = is_ekko-stceg_l and kappl = 'TX'.
*
* NEW CODE
SELECT *
 from a003
into table gt_a003
where mwskz = <fs>-mwskz
and aland = is_ekko-stceg_l and kappl = 'TX' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03




















