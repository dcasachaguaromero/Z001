*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFICONBSIS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFICONBSIS.


type-pools: slis.
*=======================================================================
* Tablas
*=======================================================================

    TABLES: BSIS , PAYR , BSEG.
*=======================================================================
* Variables
*=======================================================================

constants: top_of_page  type slis_formname  value 'TOP_OF_PAGE',
           top_of_list  type slis_formname  value 'TOP_OF_LIST'.
constants: end_of_list  type slis_formname  value 'END_OF_LIST',
           user_command type slis_formname  value 'ALV_USER_COMMAND' .


DATA: k_status       TYPE slis_formname VALUE 'STANDARD_KR01',
      k_user_command TYPE slis_formname VALUE 'USER_COMMAND',
      pos type i.
DATA: f_inicio type REGUH-FECHA_ENVIO.
DATA: f_fin type REGUH-FECHA_ENVIO.
DATA: fecha(10) type c.
DATA: periodo(4).

"Una variable a modo de contador
DATA: CONTADOR TYPE I.
DATA:      alv_fieldcat    TYPE slis_t_fieldcat_alv,
           wa_alv_fieldcat TYPE slis_fieldcat_alv,
           alv_layout      TYPE slis_layout_alv,
           gd_repid        LIKE sy-repid.
data mydate like sy-datum.

    DATA: BEGIN OF T_DATOS OCCURS 0,
 bukrs like bsis-bukrs,
 hkont like bsis-hkont,
zuonr like bsis-zuonr,
gjahr like bsis-gjahr,
budat like bsis-budat,
bldat like bsis-bldat,
blart like bsis-blart,
dmbtr like bsis-dmbtr,
lifnr like payr-lifnr,
chect like payr-chect,
rwbtr like payr-rwbtr,
znme1 like payr-znme1,
voidd like payr-voidd,
voidu like payr-voidu,
BELNR like bsis-BELNR,
BUZEI like bsis-BUZEI,
zzmot_emis like bseg-zzmot_emis,
    END OF T_DATOS.
DATA: BEGIN OF SPL OCCURS 0,
        VAL(1023),
      END OF SPL,
      sindx TYPE I.

tables: sscrfields.
"Estos son los parámetros de selección de programa

initialization.


    SELECTION-SCREEN BEGIN OF BLOCK DATA WITH FRAME TITLE TEXT-T01.
 "     PARAMETER: S_GJAHR(4) .
    "Podemos elegir un rango de valores
    SELECT-OPTIONS:
          S_BUKRS FOR  BSIS-bukrs ,
          S_hkont FOR   bsis-hkont  .
*          S_ZALDT FOR   REGUH-ZALDT.
    SELECTION-SCREEN END OF BLOCK DATA.

    START-OF-SELECTION.
      PERFORM alv_setup.
      PERFORM OBTENER_DATOS.
    end-of-selection.

    PERFORM display_alv.




FORM OBTENER_DATOS.


"SELECT t1~bukrs
"       t1~hkont
"       t1~zuonr
"       t1~gjahr
"       t1~budat
"       t1~bldat
"       t1~blart
"       t1~dmbtr
"       t2~lifnr
"t2~chect
"t2~rwbtr
"t2~znme1
"t2~voidd
"t2~voidu
"t1~BELNR
"t1~BUZEI
 "   from bsis as t1 inner join PAYR as t2
 "        on t1~bukrs eq t2~zbukr AND
"            t1~gjahr eq t2~gjahr AND
"            t1~zuonr eq t2~chect
"  INTO CORRESPONDING FIELDS OF T_DATOS
"     where  t1~bukrs IN S_BUKRS  AND
"            t1~hkont in S_hkont
".

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT t1~bukrs
*       t1~hkont
*       t1~zuonr
*       t1~gjahr
*       t1~budat
*       t1~bldat
*       t1~blart
*       t1~dmbtr
*       t1~BELNR
*       t1~BUZEI
*    from bsis as t1
*    INTO CORRESPONDING FIELDS OF T_DATOS
*     where  t1~bukrs IN S_BUKRS  AND
*            t1~hkont in S_hkont.
*
* NEW CODE
  SELECT t1~bukrs
       t1~hkont
       t1~zuonr
       t1~gjahr
       t1~budat
       t1~bldat
       t1~blart
       t1~dmbtr
       t1~BELNR
       t1~BUZEI

    from bsis as t1
    INTO CORRESPONDING FIELDS OF T_DATOS
     where  t1~bukrs IN S_BUKRS  AND
            t1~hkont in S_hkont ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

      APPEND T_DATOS.
  ENDSELECT.



  LOOP AT T_DATOS.
"El SY-TABIX es una variable del sistema que nos indica el número
"de vueltas que ha dado un LOOP.

    CONTADOR = SY-TABIX.
"Seleccionamos un dato y lo almacenamos en uno de los campos
"de nuestra tabla interna. El SINGLE indica que solo queremos un
"valor


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
* SELECT SINGLE
*       lifnr
*       chect
*       rwbtr
*       znme1
*       voidd
*       voidd
*   INTO
*   (T_DATOS-lifnr, T_DATOS-chect, T_DATOS-rwbtr,  T_DATOS-znme1,T_DATOS-voidd ,  T_DATOS-voidd)
*    from PAYR
*         WHERE zbukr    eq T_DATOS-bukrs AND
*               gjahr    eq T_DATOS-gjahr AND
*               chect    eq T_DATOS-zuonr.
*
* NEW CODE
 SELECT lifnr
       chect
       rwbtr
       znme1
       voidd
       voidd
 UP TO 1 ROWS 
   INTO
   (T_DATOS-lifnr, T_DATOS-chect, T_DATOS-rwbtr,  T_DATOS-znme1,T_DATOS-voidd ,  T_DATOS-voidd)
    from PAYR
         WHERE zbukr    eq T_DATOS-bukrs AND
               gjahr    eq T_DATOS-gjahr AND
               chect    eq T_DATOS-zuonr ORDER BY PRIMARY KEY.

 ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* motivo emision
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE zzmot_emis
*     INTO T_DATOS-zzmot_emis
*from bseg
*where
*  BUKRS eq T_DATOS-BUKRS AND
*  BELNR eq T_DATOS-BELNR AND
*  GJAHR eq T_DATOS-GJAHR AND
*  BUZEI eq T_DATOS-BUZEI.
*
* NEW CODE
SELECT zzmot_emis
UP TO 1 ROWS 
     INTO T_DATOS-zzmot_emis
from bseg
where
  BUKRS eq T_DATOS-BUKRS AND
  BELNR eq T_DATOS-BELNR AND
  GJAHR eq T_DATOS-GJAHR AND
  BUZEI eq T_DATOS-BUZEI ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

         T_DATOS-rwbtr = ABS( T_DATOS-rwbtr ) * 100.
         T_DATOS-dmbtr = ABS( T_DATOS-dmbtr ) * 100.


"El MODIFY modifica la tabla interna, para agregar el valor
"que hemos obtenido en el query anterior, utilizando como
"indice, el número de vuelta del LOOP

    MODIFY T_DATOS INDEX CONTADOR.

ENDLOOP.


"Hacemos un LOOP para recorrer todos los registros de nuestra
"tabla interna

"LOOP AT T_DATOS.
""El SY-TABIX es una variable del sistema que nos indica el número
""de vueltas que ha dado un LOOP.

"    CONTADOR = SY-TABIX.

"    s_BUKRS = T_DATOS-BUKRS.
""Seleccionamos un dato y lo almacenamos en uno de los campos
""de nuestra tabla interna. El SINGLE indica que solo queremos un
""valor

"* NOMBRE DEUDOR

"    SELECT SINGLE NAME1
"    INTO  T_DATOS-NAME1
"    FROM  KNA1
"    WHERE KUNNR EQ T_DATOS-KUNNR.

"* NOMBRE RUT

"    SELECT SINGLE STCD1
"    INTO  T_DATOS-STCD1
"    FROM KNA1
"    WHERE KUNNR EQ T_DATOS-KUNNR.


""El MODIFY modifica la tabla interna, para agregar el valor
""que hemos obtenido en el query anterior, utilizando como
""indice, el número de vuelta del LOOP

"    MODIFY T_DATOS INDEX CONTADOR.

"ENDLOOP.

* LOOP AT T_DATOS.
* WRITE:  AT (20) T_DATOS-STCD1,
*          AT (100) T_DATOS-name1,
*          AT (20) T_DATOS-LIFNR,
*          AT (20) T_DATOS-AKONT.
*  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  alv_setup
*&---------------------------------------------------------------------*
*
*  Setup of the columns in the ALV grid
*
*----------------------------------------------------------------------*
FORM alv_setup.

 CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = 'X'.                  "This is a key column
  wa_alv_fieldcat-fieldname = 'BUKRS'.        "Name of the table field
  wa_alv_fieldcat-seltext_s = 'bukrs'.  "Short column heading
  wa_alv_fieldcat-seltext_m = 'bukrs'.  "Medium column heading
  wa_alv_fieldcat-seltext_l = 'bukrs'.  "Long column heading
  APPEND wa_alv_fieldcat TO alv_fieldcat.




  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = 'X'.                  "This is a key column
  wa_alv_fieldcat-fieldname = 'HKONT'.        "Name of the table field
  wa_alv_fieldcat-seltext_s = 'hkont'.  "Short column heading
  wa_alv_fieldcat-seltext_m = 'hkont'.  "Medium column heading
  wa_alv_fieldcat-seltext_l = 'hkont'.  "Long column heading
  APPEND wa_alv_fieldcat TO alv_fieldcat.

* Mat text field
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'ZUONR'.
  wa_alv_fieldcat-seltext_s = 'zuonr'.
  wa_alv_fieldcat-seltext_m = 'zuonr'.
  wa_alv_fieldcat-seltext_l = 'zuonr'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.

* Mat text field
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'GJAHR'.
  wa_alv_fieldcat-seltext_s = 'gjahr'.
  wa_alv_fieldcat-seltext_m = 'gjahr'.
  wa_alv_fieldcat-seltext_l = 'gjahr'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.


  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'BUDAT'.
  wa_alv_fieldcat-seltext_s = 'budat'.
  wa_alv_fieldcat-seltext_m = 'budat'.
  wa_alv_fieldcat-seltext_l = 'budat'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.

  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'BLDAT'.
  wa_alv_fieldcat-seltext_s = 'bldat'.
  wa_alv_fieldcat-seltext_m = 'bldat'.
  wa_alv_fieldcat-seltext_l = 'bldat'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.
   CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'BLART'.
  wa_alv_fieldcat-seltext_s = 'blart'.
  wa_alv_fieldcat-seltext_m = 'blart'.
  wa_alv_fieldcat-seltext_l = 'blart'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.
   CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-DATATYPE = 'CURR'.
  wa_alv_fieldcat-fieldname = 'DMBTR'.
  wa_alv_fieldcat-seltext_s = 'dmbtr'.
  wa_alv_fieldcat-seltext_m = 'dmbtr'.
  wa_alv_fieldcat-seltext_l = 'dmbtr'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.

     CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'LIFNR'.
  wa_alv_fieldcat-seltext_s = 'lifnr'.
  wa_alv_fieldcat-seltext_m = 'lifnr'.
  wa_alv_fieldcat-seltext_l = 'lifnr'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.

   CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'CHECT'.
  wa_alv_fieldcat-seltext_s = 'chect'.
  wa_alv_fieldcat-seltext_m = 'chect'.
  wa_alv_fieldcat-seltext_l = 'chect'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.

  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-DATATYPE = 'CURR'.
  wa_alv_fieldcat-fieldname = 'RWBTR'.
  wa_alv_fieldcat-seltext_s = 'rwbtr'.
  wa_alv_fieldcat-seltext_m = 'rwbtr'.
  wa_alv_fieldcat-seltext_l = 'rwbtr'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'ZNME1'.
  wa_alv_fieldcat-seltext_s = 'znme1'.
  wa_alv_fieldcat-seltext_m = 'znme1'.
  wa_alv_fieldcat-seltext_l = 'znme1'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.
    CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'VOIDD'.
  wa_alv_fieldcat-seltext_s = 'voidd'.
  wa_alv_fieldcat-seltext_m = 'voidd'.
  wa_alv_fieldcat-seltext_l = 'voidd'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'VOIDU'.
  wa_alv_fieldcat-seltext_s = 'voidu'.
  wa_alv_fieldcat-seltext_m = 'voidu'.
  wa_alv_fieldcat-seltext_l = 'voidu'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.


* Mat text field
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'ZZMOT_EMIS'.
  wa_alv_fieldcat-seltext_s = 'zzmot_emis'.
  wa_alv_fieldcat-seltext_m = 'zzmot_emis'.
  wa_alv_fieldcat-seltext_l = 'zzmot_emis'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.


ENDFORM.                    " alv_setup

*&---------------------------------------------------------------------*
*&      Form  display_alv
*&---------------------------------------------------------------------*
*  Display data in the ALV grid
*
*----------------------------------------------------------------------*
FORM display_alv.

  gd_repid = sy-repid.

* Configure layout of screen
  alv_layout-colwidth_optimize = 'X'.
  alv_layout-zebra             = 'X'.
  alv_layout-no_min_linesize   = 'X'.

* Now call display function
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
           i_callback_program       = gd_repid
           i_callback_top_of_page   = 'TOP_OF_PAGE_SETUP' "Ref to form
           is_layout                = alv_layout
           it_fieldcat              = alv_fieldcat
           i_callback_user_command  = user_command
           i_save = 'X'
      TABLES
            t_outtab                = T_DATOS
       EXCEPTIONS
         program_error            = 1
         OTHERS                   = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " display_alv

*&---------------------------------------------------------------------*
*&      Form  top_of_page_setup
*&---------------------------------------------------------------------*
*
*  Set-up what to display at the top of the ALV pages
*  Note that the link to this form is in the
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY' parameter
*  i_callback_top_of_page   = 'TOP_OF_PAGE' in form display_alv
*----------------------------------------------------------------------*
FORM top_of_page_setup.

  DATA: t_header TYPE slis_t_listheader,
        wa_header TYPE slis_listheader.


  wa_header-typ  = 'H'.
  wa_header-info = 'INFORME CADUCOS'.
  APPEND wa_header TO t_header.

  CLEAR wa_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
       EXPORTING
            it_list_commentary = t_header.
ENDFORM.

*---------------------------------------------------------------------*
* FORM user_command
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
* --> R_UCOMM
* --> RS_SELFIELD
*---------------------------------------------------------------------*
FORM alv_user_command  USING r_ucomm LIKE sy-ucomm
rs_selfield TYPE slis_selfield.
**BREAK-POINT.
write: / rs_selfield-value.
*
** MESSAGE ID 'AT' TYPE 'E' NUMBER S_BUKRS WITH
**              rs_selfield-value.
*if rs_SELFIELD-fieldname = 'KUNNR'.
*        SET PARAMETER ID 'KUN' FIELD rs_selfield-value.
*        SET PARAMETER ID 'BUK' FIELD s2_BUKRS.
*        SET PARAMETER ID 'KDY' FIELD '210/220/610'.
*        CALL TRANSACTION 'FD03' AND SKIP FIRST SCREEN.
*endif.
*
*if rs_SELFIELD-fieldname = 'AKONT'.
*        SET PARAMETER ID 'SAK' FIELD rs_selfield-value.
*        SET PARAMETER ID 'BUK' FIELD s2_BUKRS.
*        CALL TRANSACTION 'FSS0' AND SKIP FIRST SCREEN.
*endif.
ENDFORM.
