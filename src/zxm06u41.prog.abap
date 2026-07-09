*&---------------------------------------------------------------------*
*&  Include           ZXM06U41
*&---------------------------------------------------------------------*
*
* ini Waldo Alarcón - Visionone - 14-06-2021
 IF ( sy-tcode EQ 'ME21N' OR sy-tcode EQ 'ME22N' ) AND
    ( i_ekpo-matnr IS NOT INITIAL AND i_ekpo-werks IS NOT INITIAL ).
*------------- Verificacion de Material Pendiente en otras OC
   IF i_ekpo-knttp NE 'A'.
     SELECT ebeln, ebelp INTO @DATA(lw_ekpo) UP TO 1 ROWS
            FROM ekpo WHERE matnr EQ @i_ekpo-matnr
                       AND  werks EQ @i_ekpo-werks
                       AND  loekz EQ @space
                       AND  elikz NE 'X'
                       AND  knttp NE 'A'
                       ORDER BY ebeln DESCENDING.
     ENDSELECT.
     IF sy-subrc EQ 0.
       DATA(lv_msj1) = 'Para la posición' && | { i_ekpo-ebelp ALPHA = OUT } |.
       DATA(lv_msj2) = 'existe otra OC:'  && | { lw_ekpo-ebeln ALPHA = OUT } | && '/' && |{ lw_ekpo-ebelp ALPHA = OUT }|.
       DATA(lv_msj3) = 'por entregar para el mismo material y centro'.
       MESSAGE w899(mm) WITH lv_msj1 lv_msj2 lv_msj3.
       mmpur_message 'S' 'MM' '899' lv_msj1 lv_msj2 lv_msj3 ''.
     ENDIF.
   ENDIF.
*------------- Verificacion de Precio
   IF  ( i_ekko-bedat IS NOT INITIAL AND i_ekko-lifnr IS NOT INITIAL AND
         i_ekko-ekorg IS NOT INITIAL AND i_ekko-waers IS NOT INITIAL ) AND
       ( i_ekpo-netpr IS NOT INITIAL AND i_ekpo-meins IS NOT INITIAL ).
     DATA(lv_sem) = 'X'.
     SELECT SINGLE knumh, lifnr INTO @DATA(lw_knumh)
            FROM a018 WHERE kappl EQ 'M'
                       AND  kschl EQ 'PB00'
                       AND  esokz EQ '0'
                       AND  lifnr EQ @i_ekko-lifnr
                       AND  ekorg EQ @i_ekko-ekorg
                       AND  matnr EQ @i_ekpo-matnr
                       AND  datbi GE @i_ekko-bedat
                       AND  datab LE @i_ekko-bedat.
     IF sy-subrc NE 0.
       CLEAR lv_sem.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*       SELECT SINGLE knumh lifnr INTO lw_knumh
*              FROM a018 WHERE kappl EQ 'M'
*                         AND  kschl EQ 'PB00'
*                         AND  esokz EQ '0'
*                         AND  ekorg EQ i_ekko-ekorg
*                         AND  matnr EQ i_ekpo-matnr
*                         AND  datbi GE i_ekko-bedat
*                         AND  datab LE i_ekko-bedat.
*
* NEW CODE
       SELECT knumh lifnr
       UP TO 1 ROWS  INTO lw_knumh
              FROM a018 WHERE kappl EQ 'M'
                         AND  kschl EQ 'PB00'
                         AND  esokz EQ '0'
                         AND  ekorg EQ i_ekko-ekorg
                         AND  matnr EQ i_ekpo-matnr
                         AND  datbi GE i_ekko-bedat
                         AND  datab LE i_ekko-bedat ORDER BY PRIMARY KEY.

       ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
     ENDIF.
     IF sy-subrc EQ 0.
       SELECT SINGLE kbetr INTO @DATA(lv_kbetr)
              FROM konp WHERE knumh EQ @lw_knumh-knumh
                         AND  kappl EQ 'M'
                         AND  kschl EQ 'PB00'
                         AND  konwa EQ @i_ekko-waers
                         AND  kmein EQ @i_ekpo-meins
                         AND  kbetr NE @space.
       IF sy-subrc EQ 0.
         IF lv_kbetr NE i_ekpo-netpr AND lv_sem EQ 'X'.
           lv_msj1 = 'Para la posición' && | { i_ekpo-ebelp ALPHA = OUT } |.
           lv_msj2 = 'es diferente al acuerdo de precio creado en'.
           WRITE lv_kbetr CURRENCY i_ekko-waers TO lv_msj3.
           CONDENSE lv_msj3 NO-GAPS.
           lv_msj3 = 'transacción MEK3, valor' && | { lv_msj3 } |.
           MESSAGE w899(mm) WITH lv_msj1 lv_msj2 lv_msj3.
           mmpur_message 'S' 'MM' '899' lv_msj1 lv_msj2 lv_msj3 ''.
         ELSEIF lv_sem IS INITIAL.
           lv_msj1 = 'Para la posición' && | { i_ekpo-ebelp ALPHA = OUT } |.
           lv_msj2 = 'tiene un acuerdo de precio creado en'.
           WRITE lv_kbetr CURRENCY i_ekko-waers TO lv_msj3.
           CONDENSE lv_msj3 NO-GAPS.
           lv_msj3 = |{ lw_knumh-lifnr ALPHA = OUT }| && | { lv_msj3 } |.
           lv_msj3 = 'transacción MEK3, con el proveedor' && | { lv_msj3 } |.
           MESSAGE w899(mm) WITH lv_msj1 lv_msj2 lv_msj3.
           mmpur_message 'S' 'MM' '899' lv_msj1 lv_msj2 lv_msj3 ''.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.

 ENDIF.
* fin Waldo Alarcón - Visionone - 14-06-2021
