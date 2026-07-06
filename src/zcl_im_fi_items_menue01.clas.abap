*----------------------------------------------------------------------*
*       CLASS ZCL_IM_FI_ITEMS_MENUE01  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ZCL_IM_FI_ITEMS_MENUE01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

*"* public components of class ZCL_IM_FI_ITEMS_MENUE01
*"* do not include other source files here!!!
  PUBLIC SECTION.

    INTERFACES IF_EX_FI_ITEMS_MENUE01 .

    TYPES:
      BEGIN OF TY_OUT,
             BUKRS TYPE BKPF-BUKRS,
             BELNR TYPE BKPF-BELNR,
             BUDAT TYPE BKPF-BUDAT,
             VERTN TYPE BSEG-VERTN,
             END   OF TY_OUT .

    DATA L_BLART TYPE BKPF-BLART .
    DATA L_BUDAT TYPE BKPF-BUDAT .
    DATA T_OUT TYPE STANDARD TABLE OF TY_OUT .
    DATA WA_OUT TYPE TY_OUT.
    DATA O_ALV TYPE REF TO CL_SALV_TABLE .
protected section.
*"* protected components of class ZCL_IM_FI_ITEMS_MENUE01
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_FI_ITEMS_MENUE01
*"* do not include other source files here!!!

  methods SET_PF_STATUS
    changing
      !CO_ALV type ref to CL_SALV_TABLE .
ENDCLASS.



CLASS ZCL_IM_FI_ITEMS_MENUE01 IMPLEMENTATION.


METHOD if_ex_fi_items_menue01~list_items01.

  DATA l_ucomm  TYPE sy-ucomm.
  DATA bdcdata TYPE STANDARD TABLE OF bdcdata.
  DATA ls_bdc  LIKE LINE OF bdcdata.
  DATA ctumode TYPE ctu_mode   VALUE 'E'.
  DATA cupdate TYPE ctu_update VALUE 'L'.
  DATA messtab TYPE STANDARD TABLE OF bdcmsgcoll.
  DATA ls_mess LIKE LINE OF messtab.
  DATA l_vertn TYPE bseg-vertn.
  DATA: lx_msg TYPE REF TO cx_salv_msg.
  DATA l_ctu_mode TYPE ctu_mode.

  FIELD-SYMBOLS <ls_items> TYPE any.
  FIELD-SYMBOLS <fval>     TYPE any.

  READ TABLE it_items ASSIGNING <ls_items> WITH KEY xselp = 'X'.
  CHECK sy-subrc = 0.
  CALL FUNCTION 'ZSCR_POPUP_FIELD_INPUT01'
    CHANGING
      e_blart    = l_blart
      e_budat    = l_budat
      e_ucomm    = l_ucomm
      e_ctu_mode = l_ctu_mode.

  CHECK l_ucomm EQ 'ENTR' AND ( NOT l_blart IS INITIAL AND NOT l_budat IS INITIAL ).
  IF l_ctu_mode IS NOT INITIAL.
    ctumode = l_ctu_mode.
  ENDIF.
*V1 02-03-2017
*  LOOP AT IT_ITEMS ASSIGNING <LS_ITEMS> WHERE XSELP = 'X'.
  LOOP AT it_items ASSIGNING <ls_items> WHERE xselp = 'X' AND
                                              shkzg = 'S'.

    ASSIGN COMPONENT 'VERTN' OF STRUCTURE <ls_items> TO <fval>.
    CLEAR ls_bdc.
    ls_bdc-program  = 'SAPMF05A'.
    ls_bdc-dynpro   = '0122'.
    ls_bdc-dynbegin = 'X'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BDC_OKCODE'.
    ls_bdc-fval = '=SL'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BKPF-BLDAT'.
    WRITE l_budat TO ls_bdc-fval.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BKPF-BLART'.
    ls_bdc-fval = l_blart.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BKPF-BUKRS'.
    ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <ls_items> TO <fval>.
    ls_bdc-fval = <fval>.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BKPF-BUDAT'.
    WRITE l_budat TO ls_bdc-fval.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BKPF-WAERS'.
    ls_bdc-fval = 'CLP'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'RF05A-AUGTX'.
    ls_bdc-fval = 'CASTIGO'(001).
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'FS006-DOCID'.
    ls_bdc-fval = '*'.
    APPEND ls_bdc TO bdcdata.

**-------------------------------------

    CLEAR ls_bdc.
    ls_bdc-program  = 'SAPMF05A'.
    ls_bdc-dynpro   = '0710'.
    ls_bdc-dynbegin = 'X'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BDC_OKCODE'.
    ls_bdc-fval = '=PA'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'RF05A-AGBUK'.
    ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <ls_items> TO <fval>.
    ls_bdc-fval = <fval>.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'RF05A-AGKON'.
    ASSIGN COMPONENT 'KONTO' OF STRUCTURE <ls_items> TO <fval>.
    ls_bdc-fval = <fval>.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
*V1 02-03-2017
*    LS_BDC-FNAM = 'RF05A-XPOS1(04)'.
    ls_bdc-fnam = 'RF05A-XPOS1(16)'.

    ls_bdc-fval = 'X'.
    APPEND ls_bdc TO bdcdata.

**------------------------------------------------------------
    CLEAR ls_bdc.
    ls_bdc-program  = 'SAPMF05A'.
    ls_bdc-dynpro   = '0731'.
    ls_bdc-dynbegin = 'X'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BDC_OKCODE'.
    ls_bdc-fval = '/00'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'RF05A-SEL01(01)'.
*V1 02.03.2017
*    ASSIGN COMPONENT 'BELNR' OF STRUCTURE <LS_ITEMS> TO <FVAL>.
    ASSIGN COMPONENT 'VBELN' OF STRUCTURE <ls_items> TO <fval>.
    ls_bdc-fval = <fval>.
    APPEND ls_bdc TO bdcdata.

**------------------------------------------------------------------
    CLEAR ls_bdc.
    ls_bdc-program  = 'SAPMF05A'.
    ls_bdc-dynpro   = '0731'.
    ls_bdc-dynbegin = 'X'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BDC_OKCODE'.
    ls_bdc-fval = '=PA'.
    APPEND ls_bdc TO bdcdata.

**-------------------------------------------------------------------
    CLEAR ls_bdc.
    ls_bdc-program  = 'SAPDF05X'.
    ls_bdc-dynpro   = '3100'.
    ls_bdc-dynbegin = 'X'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BDC_OKCODE'.
    ls_bdc-fval = 'KMD'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'DF05B-PSSKT(01)'.
    ls_bdc-fval = space.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'RF05A-ABPOS'.
    ls_bdc-fval = '1'.
    APPEND ls_bdc TO bdcdata.
**------------------------------------------------------------------
    CLEAR ls_bdc.
    ls_bdc-program  = 'SAPMF05A'.
    ls_bdc-dynpro   = '0700'.
    ls_bdc-dynbegin = 'X'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BDC_OKCODE'.
    ls_bdc-fval = '/00'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BKPF-XBLNR'.
    ASSIGN COMPONENT 'VERTN' OF STRUCTURE <ls_items> TO <fval>.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BKPF-BKTXT'.
    ls_bdc-fval = 'Texto Cab.Doc'(002).
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'RF05A-NEWBS'.
    ls_bdc-fval = '09'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'RF05A-NEWKO'.
    ASSIGN COMPONENT 'KONTO' OF STRUCTURE <ls_items> TO <fval>.
    ls_bdc-fval = <fval>.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'RF05A-NEWUM'.
    ls_bdc-fval = '1'.
    APPEND ls_bdc TO bdcdata.

**---------------------------------------------------------------------
    CLEAR ls_bdc.
    ls_bdc-program  = 'SAPMF05A'.
    ls_bdc-dynpro   = '0303'.
    ls_bdc-dynbegin = 'X'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BDC_OKCODE'.
    ls_bdc-fval = '=BU'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BSEG-WRBTR'.
    ls_bdc-fval = '*'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BSEG-WRBTR'.
    ls_bdc-fval = '*'.
    APPEND ls_bdc TO bdcdata.


    CLEAR ls_bdc.
    ls_bdc-fnam = 'BSEG-ZFBDT'.
    WRITE l_budat TO ls_bdc-fval.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BSEG-VERTT'.
    ls_bdc-fval = 'A'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BSEG-VERTN'.
    ASSIGN COMPONENT 'VERTN' OF STRUCTURE <ls_items> TO <fval>..
    ls_bdc-fval = <fval>.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam = 'BSEG-SGTXT'.
    ls_bdc-fval = 'CASTIGO'(101).
    APPEND ls_bdc TO bdcdata.

* ini - Waldo Alarcón - Visionone - 09-03-2020 -
* Ajuste Pantalla nueva para confirmar el tipo de cambio
**---------------------------------------------------------------------
    CLEAR ls_bdc.
    ls_bdc-program  = 'SAPMF05A'.
    ls_bdc-dynpro   = '0331'.
    ls_bdc-dynbegin = 'X'.
    APPEND ls_bdc TO bdcdata.

    CLEAR ls_bdc.
    ls_bdc-fnam     = 'BDC_OKCODE'.
    ls_bdc-fval     = '=BU'.
    APPEND ls_bdc TO bdcdata.
* fin - Waldo Alarcón - Visionone - 09-03-2020 -

    CALL TRANSACTION 'F-30' USING bdcdata
                     MODE   ctumode
                     UPDATE cupdate
                     MESSAGES INTO messtab.
    IF sy-subrc EQ 0 .
      READ TABLE messtab INTO ls_mess WITH  KEY dynumb = '0700'
                                                msgtyp = 'S'
                                                msgid = 'F5'
                                                msgnr = '312'.
      IF sy-subrc EQ 0.
        MOVE ls_mess-msgv1 TO wa_out-belnr.
      ENDIF.
      ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <ls_items> TO <fval>.    wa_out-bukrs = <fval>.
      ASSIGN COMPONENT 'VERTN' OF STRUCTURE <ls_items> TO <fval>.     wa_out-vertn = <fval>.
*      T_OUT-BELNR,
      MOVE l_budat TO wa_out-budat.
      APPEND wa_out TO t_out.
    ENDIF.

    FREE messtab.
    FREE bdcdata.
  ENDLOOP.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = o_alv
        CHANGING
          t_table      = t_out ).
    CATCH cx_salv_msg INTO lx_msg.
  ENDTRY.

  CALL METHOD set_pf_status
    CHANGING
      co_alv = o_alv.
  o_alv->display( ).
  SET SCREEN 0.
  LEAVE SCREEN.

*
ENDMETHOD.


method IF_EX_FI_ITEMS_MENUE01~LIST_ITEMS02.
endmethod.


method IF_EX_FI_ITEMS_MENUE01~LIST_ITEMS03.
endmethod.


method IF_EX_FI_ITEMS_MENUE01~LIST_ITEMS04.
endmethod.


METHOD IF_EX_FI_ITEMS_MENUE01~SHOW_BUTTONS.
  DATA WA_EXTAB TYPE SLIS_EXTAB.

  IF SY-TCODE NE 'ZFIGL004'.
    CLEAR WA_EXTAB.
    WA_EXTAB-FCODE = '+CUS01'.
    APPEND WA_EXTAB TO EXTAB.
  ENDIF.
ENDMETHOD.


METHOD SET_PF_STATUS.
  DATA: LO_FUNCTIONS TYPE REF TO CL_SALV_FUNCTIONS_LIST.
*
      co_alv->set_screen_status(
      pfstatus      =  'SALV_LOG'
      report        =  'ZFI_CONTAB_CASTIGOS'
      set_functions = co_alv->c_functions_all ).
ENDMETHOD.
ENDCLASS.
