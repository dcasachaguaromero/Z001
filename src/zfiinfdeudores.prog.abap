*&---------------------------------------------------------------------*
*& Report  ZFIINFDEUDORES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFIINFDEUDORES no standard page heading.

type-pools: slis.


*=======================================================================
* Tablas
*=======================================================================

    TABLES: KNB1 , KNA1 , BKPF .
*=======================================================================
* Variables
*=======================================================================

constants: top_of_page  type slis_formname  value 'TOP_OF_PAGE',
           top_of_list  type slis_formname  value 'TOP_OF_LIST'.
constants: end_of_list  type slis_formname  value 'END_OF_LIST',
           user_command type slis_formname  value 'ALV_USER_COMMAND' .
******************************************************************'

DATA: k_status       TYPE slis_formname VALUE 'STANDARD_KR01',
      k_user_command TYPE slis_formname VALUE 'USER_COMMAND',
      pos type i.

"Una variable a modo de contador
DATA: CONTADOR TYPE I.

DATA:       r_grid      TYPE REF TO cl_gui_alv_grid,
            s2_BUKRS LIKE LFB1-BUKRS.

DATA:      alv_fieldcat    TYPE slis_t_fieldcat_alv,
           wa_alv_fieldcat TYPE slis_fieldcat_alv,
           alv_layout      TYPE slis_layout_alv,
           gd_repid        LIKE sy-repid.


    DATA: BEGIN OF T_DATOS OCCURS 0,
          BUKRS LIKE LFB1-BUKRS,
          KUNNR LIKE LFB1-LIFNR,
          AKONT LIKE LFB1-AKONT,
          NAME1 LIKE LFA1-NAME1,
          STCD1 LIKE LFA1-STCD1,
    END OF T_DATOS.

DATA: BEGIN OF SPL OCCURS 0,
        VAL(1023),
      END OF SPL,
      sindx TYPE I.

tables: sscrfields.
"Estos son los parámetros de selección de programa

initialization.

    SELECTION-SCREEN BEGIN OF BLOCK DATA WITH FRAME TITLE TEXT-T01.
    "Podemos elegir un rango de valores
    SELECT-OPTIONS:
          S_BUKRS FOR  KNB1-BUKRS  NO-EXTENSION
                                   NO INTERVALS,
          S_LIFNR FOR  KNB1-KUNNR ,
          S_SORTL FOR KNA1-SORTL .

    SELECTION-SCREEN END OF BLOCK DATA.

    START-OF-SELECTION.
      PERFORM alv_setup.
      PERFORM OBTENER_DATOS.
    end-of-selection.

    PERFORM display_alv.



FORM OBTENER_DATOS.
  LOOP AT s_sortl.
    pos = strlen( s_sortl-low ).
    pos = pos - 1.
    IF s_sortl-low+pos(1) <> '+' and s_sortl-low+pos(1) <> '*'.
      CONCATENATE s_sortl-low '+' into s_sortl-low.
      s_sortl-option = 'CP'.
    ENDIF.
    modify s_sortl.
  ENDLOOP.


  SELECT b~BUKRS b~KUNNR b~AKONT
  INTO   T_DATOS
  from knb1 as b inner join kna1 as a
                on b~KUNNR eq a~KUNNR
  where b~bukrs in s_bukrs
          and b~KUNNR in s_lifnr
          and a~sortl in s_sortl.
      APPEND T_DATOS.
  ENDSELECT.

"Hacemos un LOOP para recorrer todos los registros de nuestra
"tabla interna

LOOP AT T_DATOS.
"El SY-TABIX es una variable del sistema que nos indica el número
"de vueltas que ha dado un LOOP.

    CONTADOR = SY-TABIX.

    s2_BUKRS = T_DATOS-BUKRS.
"Seleccionamos un dato y lo almacenamos en uno de los campos
"de nuestra tabla interna. El SINGLE indica que solo queremos un
"valor

* NOMBRE DEUDOR

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE NAME1
*    INTO  T_DATOS-NAME1
*    FROM  KNA1
*    WHERE KUNNR EQ T_DATOS-KUNNR.
*
* NEW CODE
    SELECT NAME1
    UP TO 1 ROWS 
    INTO  T_DATOS-NAME1
    FROM  KNA1
    WHERE KUNNR EQ T_DATOS-KUNNR ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* NOMBRE RUT

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE STCD1
*    INTO  T_DATOS-STCD1
*    FROM KNA1
*    WHERE KUNNR EQ T_DATOS-KUNNR.
*
* NEW CODE
    SELECT STCD1
    UP TO 1 ROWS 
    INTO  T_DATOS-STCD1
    FROM KNA1
    WHERE KUNNR EQ T_DATOS-KUNNR ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


"El MODIFY modifica la tabla interna, para agregar el valor
"que hemos obtenido en el query anterior, utilizando como
"indice, el número de vuelta del LOOP

    MODIFY T_DATOS INDEX CONTADOR.

ENDLOOP.

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
  wa_alv_fieldcat-seltext_s = 'SOCIEDAD'.  "Short column heading
  wa_alv_fieldcat-seltext_m = 'SOCIEDAD'.  "Medium column heading
  wa_alv_fieldcat-seltext_l = 'SOCIEDAD'.  "Long column heading
  APPEND wa_alv_fieldcat TO alv_fieldcat.

  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = 'X'.                  "This is a key column
  wa_alv_fieldcat-fieldname = 'KUNNR'.        "Name of the table field
  wa_alv_fieldcat-seltext_s = 'IDDEUDOR'.  "Short column heading
  wa_alv_fieldcat-seltext_m = 'IDDEUDOR'.  "Medium column heading
  wa_alv_fieldcat-seltext_l = 'IDDEUDOR'.  "Long column heading
  APPEND wa_alv_fieldcat TO alv_fieldcat.

* Mat text field
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'AKONT'.
  wa_alv_fieldcat-seltext_s = 'CTAASOCIADA'.
  wa_alv_fieldcat-seltext_m = 'CTAASOCIADA'.
  wa_alv_fieldcat-seltext_l = 'CTAASOCIADA'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.

* Mat text field
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'NAME1'.
  wa_alv_fieldcat-seltext_s = 'NOMBRE'.
  wa_alv_fieldcat-seltext_m = 'NOMBRE'.
  wa_alv_fieldcat-seltext_l = 'NOMBRE'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.

* Mat text field
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'STCD1'.
  wa_alv_fieldcat-seltext_s = 'RUT'.
  wa_alv_fieldcat-seltext_m = 'RUT'.
  wa_alv_fieldcat-seltext_l = 'RUT'.
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
  wa_header-info = 'LISTADO DE DEUDORES'.
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
*BREAK-POINT.
*write: / rs_selfield-value.

* MESSAGE ID 'AT' TYPE 'E' NUMBER S_BUKRS WITH
*              rs_selfield-value.
if rs_SELFIELD-fieldname = 'KUNNR'.
        SET PARAMETER ID 'KUN' FIELD rs_selfield-value.
        SET PARAMETER ID 'BUK' FIELD s2_BUKRS.
        SET PARAMETER ID 'KDY' FIELD '210/220/610'.
        CALL TRANSACTION 'FD03' AND SKIP FIRST SCREEN.
endif.

if rs_SELFIELD-fieldname = 'AKONT'.
        SET PARAMETER ID 'SAK' FIELD rs_selfield-value.
        SET PARAMETER ID 'BUK' FIELD s2_BUKRS.
        CALL TRANSACTION 'FSS0' AND SKIP FIRST SCREEN.
endif.


ENDFORM. "user_command
