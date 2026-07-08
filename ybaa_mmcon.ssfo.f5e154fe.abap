CLEAR GS_SADR.

* Plant Address         -----------------------------------------------*
IF is_pekko-werks NE space.
PERFORM get_plant_address USING    is_pekko-werks
CHANGING is_pekko-adrnr gs_sadr.
ENDIF.

* Vendor Address        -----------------------------------------------*
IF is_pekko-emlif NE space.
PERFORM get_vendor_address USING     is_pekko-emlif
CHANGING  is_pekko-adrnr.
ENDIF.

* Customer Address      -----------------------------------------------*
IF  is_pekko-kunnr NE space.
PERFORM get_customer_address USING     is_pekko-kunnr
CHANGING  is_pekko-adrnr.
ENDIF.


























