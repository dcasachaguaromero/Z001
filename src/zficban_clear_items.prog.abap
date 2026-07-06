*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFICBAN_CLEAR_ITEMS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFICBAN_CLEAR_ITEMS.
TYPE-POOLS : SLIS.
TABLES: bsis, payr.

SELECT-OPTIONS : s_bukrs for bsis-bukrs OBLIGATORY ,
                 s_hbkid for payr-hbkid.

PARAMETERS: p_test type XTEST DEFAULT 'X'.
data: ti_cheques type STANDARD TABLE OF bsis WITH HEADER LINE.
data wa_cheque type bsis.
data: ti_cuentas type STANDARD TABLE OF T012K WITH HEADER LINE.
data: ti_pago type STANDARD TABLE OF payr WITH HEADER LINE.
data: ti_clear type STANDARD TABLE OF payr WITH HEADER LINE.
data: wa_ok type c LENGTH 2 .
data: ti_febko type STANDARD TABLE OF febko WITH HEADER LINE.
data: ti_febep type STANDARD TABLE OF febep WITH HEADER LINE.



DATA: BEGIN OF BDCDATA OCCURS 100.
INCLUDE STRUCTURE BDCDATA.
DATA: END OF BDCDATA.
DATA: BEGIN OF MESSTAB OCCURS 10.
INCLUDE STRUCTURE BDCMSGCOLL.
DATA: END OF MESSTAB.
data subrc like SYST-SUBRC.
data gt_fieldcat            type slis_t_fieldcat_alv.
data: ls_fieldcat type slis_fieldcat_alv.

clear ls_fieldcat.
  ls_fieldcat-fieldname = 'ZBUKR'.
  ls_fieldcat-seltext_m = 'Sociedad'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  append ls_fieldcat to gt_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'HBKID'.
  ls_fieldcat-seltext_m = 'Banco Propio'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  append ls_fieldcat to gt_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'CHECT'.
  ls_fieldcat-seltext_m = 'Numero de Cheque'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 20.
  append ls_fieldcat to gt_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'LIFNR'.
  ls_fieldcat-seltext_m = 'Acreedor'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  append ls_fieldcat to gt_fieldcat.

  clear ls_fieldcat.
  ls_fieldcat-fieldname = 'RWBTR'.
  ls_fieldcat-seltext_m = 'Monto'.
  ls_fieldcat-currency = 'CLP'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.

  append ls_fieldcat to gt_fieldcat.

select * from febko into CORRESPONDING FIELDS OF TABLE ti_febko
  where bukrs in s_bukrs
        and HBKID in s_hbkid.

  LOOP AT ti_febko.
    SELECT * from febep into CORRESPONDING FIELDS OF TABLE ti_febep
      where kukey = ti_febko-kukey
            and VGINT = 'ZZ02'
            and BELNR < 1.
      LOOP AT ti_febep.
          select * from payr into table ti_pago
            where zbukr = ti_febko-bukrs
                and HBKID = ti_febko-hbkid
                and HKTID = ti_febko-HKTID
                and CHECT = ti_febep-chect.
            CLEAR wa_ok.
            LOOP AT ti_pago.
              IF ti_pago-xbanc eq 'X'.
                  wa_ok = 'N'.
                 append ti_pago to ti_clear.
              else.
                  wa_ok = 'S'.
              ENDIF.
            ENDLOOP.
      ENDLOOP.
  ENDLOOP.

select * from t012k into CORRESPONDING FIELDS OF TABLE ti_cuentas
  where bukrs in s_bukrs
        and HBKID in s_hbkid.

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES04 ECDK917080 *
SORT TI_CUENTAS .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES04 ECDK917080 *
delete ADJACENT DUPLICATES FROM ti_cuentas.

LOOP AT ti_cuentas.
  TI_CUENTAS-HKONT+9 = 2.
  "Se obtienen las partidas abiertas de la cuenta
  select * from bsis
    into  wa_cheque
    where bukrs = ti_cuentas-bukrs
    and hkont = ti_cuentas-hkont.
      select * from payr into table ti_pago
        where zbukr = ti_cuentas-bukrs
            and HBKID = ti_cuentas-hbkid
            and HKTID = ti_cuentas-HKTID
            and VBLNR = wa_cheque-belnr
            and gjahr = wa_cheque-gjahr.
        CLEAR wa_ok.
        LOOP AT ti_pago.
          IF ti_pago-xbanc eq 'X'.
              wa_ok = 'N'.
             append ti_pago to ti_clear.
          else.
              wa_ok = 'S'.
          ENDIF.
        ENDLOOP.
  ENDSELECT.
ENDLOOP.

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES04 ECDK917080 *
SORT TI_CLEAR .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES04 ECDK917080 *
DELETE ADJACENT DUPLICATES FROM ti_clear.

IF p_test <> 'X'.

  LOOP AT ti_clear.
*      WRITE : TI_CLEAR-ZBUKR,
*                        TI_CLEAR-HBKID,
*                        TI_CLEAR-HKTID,
*                        TI_CLEAR-CHECT,
*                        /.
      CALL FUNCTION 'Z_BAIN_FCHG'
       EXPORTING
         CTU                = 'X'
         MODE               = 'N'
         UPDATE             = 'L'
*         GROUP              =
*         USER               =
*         KEEP               =
*         HOLDDATE           =
         NODATA             = '/'
         PAR_ZBUK_001       = ti_clear-zbukr
         PAR_HBKI_002       = ti_clear-hbkid
         PAR_HKTI_003       = ti_clear-hktid
         PAR_CHKF_004       = ti_clear-chect
         PAR_CHKT_005       = ti_clear-chect
         PAR_XEIN_006       = 'X'
       IMPORTING
         SUBRC              = subrc
*       TABLES
*         MESSTAB            =
                .
  ENDLOOP.
ENDIF.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
     EXPORTING
*       I_INTERFACE_CHECK                 = ' '
*       I_BYPASSING_BUFFER                = ' '
       I_BUFFER_ACTIVE                   = 'X'
*       I_CALLBACK_PROGRAM                = ' '
*       I_CALLBACK_PF_STATUS_SET          = ' '
*       I_CALLBACK_USER_COMMAND           = ' '
*       I_CALLBACK_TOP_OF_PAGE            = ' '
*       I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*       I_CALLBACK_HTML_END_OF_LIST       = ' '
*       I_STRUCTURE_NAME                  =
*       I_BACKGROUND_ID                   = ' '
*       I_GRID_TITLE                      =
*       I_GRID_SETTINGS                   =
*       IS_LAYOUT                         =
       IT_FIELDCAT                       = gt_fieldcat
*       IT_EXCLUDING                      =
*       IT_SPECIAL_GROUPS                 =
*       IT_SORT                           =
*       IT_FILTER                         =
*       IS_SEL_HIDE                       =
*       I_DEFAULT                         = 'X'
*       I_SAVE                            = ' '
*       IS_VARIANT                        =
*       IT_EVENTS                         =
*       IT_EVENT_EXIT                     =
*       IS_PRINT                          =
*       IS_REPREP_ID                      =
*       I_SCREEN_START_COLUMN             = 0
*       I_SCREEN_START_LINE               = 0
*       I_SCREEN_END_COLUMN               = 0
*       I_SCREEN_END_LINE                 = 0
*       I_HTML_HEIGHT_TOP                 = 0
*       I_HTML_HEIGHT_END                 = 0
*       IT_ALV_GRAPHICS                   =
*       IT_HYPERLINK                      =
*       IT_ADD_FIELDCAT                   =
*       IT_EXCEPT_QINFO                   =
*       IR_SALV_FULLSCREEN_ADAPTER        =
*     IMPORTING
*       E_EXIT_CAUSED_BY_CALLER           =
*       ES_EXIT_CAUSED_BY_USER            =
      TABLES
        T_OUTTAB                          = ti_clear
*     EXCEPTIONS
*       PROGRAM_ERROR                     = 1
*       OTHERS                            = 2
              .
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
