
CLEAR GS_SADR.

IF <FS>-ADRNR EQ SPACE AND
<FS>-ADRN2 EQ SPACE.
* Lesen Kundenanschrift pro Position ----------------------------------*
IF <FS>-KUNNR NE SPACE.
PERFORM GET_CUSTOMER_ADDRESS
USING    <FS>-KUNNR
CHANGING <FS>-ADRNR.

* Lesen Lieferantenanschrift pro Position -----------------------------*
ELSEIF <FS>-EMLIF NE SPACE.
PERFORM GET_VENDOR_ADDRESS
USING    <FS>-EMLIF
CHANGING <FS>-ADRNR.

* Lesen Werksanschrift pro Position -----------------------------------*
ELSEIF <FS>-WERKS NE SPACE.
PERFORM GET_PLANT_ADDRESS
USING    <FS>-WERKS
CHANGING <FS>-ADRNR
GS_SADR.
ENDIF.

ENDIF.


























