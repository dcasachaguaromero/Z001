CLEAR gs_sadr.

IF <fs>-adrnr EQ space AND
<fs>-adrn2 EQ space.
* Lesen Kundenanschrift pro Position ----------------------------------*
IF <fs>-kunnr NE space.
PERFORM get_customer_address
USING    <fs>-kunnr
CHANGING <fs>-adrnr.

* Lesen Lieferantenanschrift pro Position -----------------------------*
ELSEIF <fs>-emlif NE space.
PERFORM get_vendor_address
USING    <fs>-emlif
CHANGING <fs>-adrnr.

* Lesen Werksanschrift pro Position -----------------------------------*
ELSEIF <fs>-werks NE space.
PERFORM get_plant_address
USING    <fs>-werks
CHANGING <fs>-adrnr
gs_sadr.
ENDIF.

ENDIF.


























