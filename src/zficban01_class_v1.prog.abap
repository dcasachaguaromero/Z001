*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFITR001_CLASS
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS C_CONTADOR DEFINITION
*----------------------------------------------------------------------*
CLASS multicash DEFINITION.
  PUBLIC SECTION.
*declaracion de variables publicas de los metodos.
    CONSTANTS: w_pcoma(1)  TYPE c VALUE   ';',
               w_slash(1)  TYPE c VALUE   '/',
               w_mas(1)    TYPE c VALUE   '+',
               w_menos(1)  TYPE c VALUE   '-'.
    CONSTANTS: char_f TYPE c VALUE cl_abap_char_utilities=>newline.
    DATA: w_bankl TYPE  bankl.
    DATA: it_data     TYPE STANDARD TABLE OF line,
          ex_data TYPE STANDARD TABLE OF line,
          tmp_data TYPE STANDARD TABLE OF line,
          wa_data     TYPE line,
          wa_d        TYPE line,
          wa_c        TYPE line,
          w_tr001(40) TYPE c,
          w_index TYPE i,
          w_encoding TYPE abap_encod.

    TYPES:
*    IT_DETALLE  TYPE STANDARD TABLE OF TY_BCID,
*           IT_HEADER1  TYPE STANDARD TABLE OF TY_BCIC,
           ito_c       TYPE STANDARD TABLE OF line,
           ito_d       TYPE STANDARD TABLE OF line,

*   BEGIN OF TY_CHLC,
*
*     END OF TY_CHL,

*CABECERA DE FORMATO MULTICASH
    BEGIN OF ty_mcc,
        cod_bank(12)    TYPE    c ,
        ctbkn(24)   TYPE    c ,
        num_ctla(4)   TYPE    c ,
        fec_cont(8)   TYPE    c ,
        moneda(3)   TYPE    c ,
        sal_ini(18)   TYPE    c ,
        tot_c(18)   TYPE    c ,
        tot_a(18)   TYPE    c ,
        sal_fin(18)   TYPE    c ,
        in_cta(35)    TYPE    c ,
        xp_cta(35)    TYPE    c ,
        l_ini(8)    TYPE    c ,
        l_fin(8)    TYPE    c ,
        nu1(1)    TYPE    c ,
        nu2(1)    TYPE    c ,
        nu3(1)    TYPE    c ,
        nu4(1)    TYPE    c ,
        nom_mov(5)    TYPE    c ,
      END OF ty_mcc,

*DETALLE DE FORMATO MULTICASH
    BEGIN OF ty_mcd,
        cod_bank(12)    TYPE    c ,
        ctbkn(24)   TYPE    c ,
        num_ctla(4)   TYPE    c ,
        fec_val(8)    TYPE    c ,
        prnot_num(10)   TYPE    c ,
        not_pay01(27)   TYPE    c ,
        bank_postext(27)    TYPE    c ,
        filler1(1)    TYPE    c ,
        cod_op(4)   TYPE    c ,
        numck(16)   TYPE    c ,
        monto(18)   TYPE    c ,
        descp(1)    TYPE    c ,
        nu1(1)    TYPE    c ,
        p_date(8)   TYPE    c ,
        nu2(1)    TYPE    c ,
        nu3(1)    TYPE    c ,
        not_pay02(27)   TYPE    c ,
        not_pay03(27)   TYPE    c ,
        not_pay04(27)   TYPE    c ,
        not_pay05(27)   TYPE    c ,
        not_pay06(27)   TYPE    c ,
        not_pay07(27)   TYPE    c ,
        not_pay08(27)   TYPE    c ,
        not_pay09(27)   TYPE    c ,
        not_pay10(27)   TYPE    c ,
        not_pay11(27)   TYPE    c ,
        not_pay12(27)   TYPE    c ,
        not_pay13(27)   TYPE    c ,
        not_pay14(27)   TYPE    c ,
        bus_part1(27)   TYPE    c ,
        bus_part2(27)   TYPE    c ,
        bank_part1(12)    TYPE    c ,
        bank_part2(24)    TYPE    c ,
        bus_tcode(3)    TYPE    c ,
        nu4(1)    TYPE    c ,
      END OF ty_mcd,

    BEGIN OF ty_stndc,
          cod_bank(3)   TYPE c,    "Codigo del banco clave 3
          ctbkn(12)     TYPE c,    "Numero de la cuenta BANCARIA 5
          num_ctla(5)   TYPE c,    "Numero de la cartola (n ESTRACTO) 6
          fec_cont(8)   TYPE c,    "Fecha generacion 7 contabilizacion
          moneda(3)     TYPE c,    "tipo Moneda
          sal_ini(12)   TYPE c,    "Saldo Inicial
          tot_c(18)     TYPE c,    "Total Cargos
          tot_a(18)     TYPE c,    "Total Abonos
          sal_fin(18)   TYPE c,    "Saldo Final
          in_cta(35)    TYPE c,    "Indicador Cuenta "bank account holder
          xp_cta(35)    TYPE c,    "X special account name
          nom_mov(18)   TYPE c,    "Numero de movimientos.
  END OF ty_stndc,

       BEGIN OF ty_stndd,
          cod_bank(3)  TYPE c,    "1 Codigo del banco clave 3
          ctbkn(12)    TYPE c,    "2 Numero de la cuenta BANCARIA 5
          num_ctla(5)  TYPE c,    "3 Numero de la cartola (n ESTRACTO) 6
          fec_val(8)  TYPE c,     "4 Fecha generacion  Fecha valor 7 contabilizacion
          prnot_num(10) TYPE c,   "5 primary note number
          not_pay01(27) TYPE c,   "6 note to payee 1
          bank_postext(40) TYPE c, "7 bank posting text
          filler1(1)   TYPE c,                              "8 no usado
          cod_op(5)    TYPE c,    "9 Codigo operacion
          numck(8)     TYPE c,    "10 numero cheque
          monto(17)    TYPE c,                              "11 Monto
          descp(40)    TYPE c,    "12  Info 1 (va la descripción de la operacion )
          fec_cont(8)  TYPE c,    "14 Fecha contabilizacion
          filler2(1)   TYPE c,      "15 no usado
          filler3(1)   TYPE c,      "16 no usado
          not_pay02(40) TYPE c,   "17  note to payee 2 "sucursal
          not_pay03(40)   TYPE c,    "18 note to payee 3
          not_pay04(40)   TYPE c,    "19 nota to payee 4
          not_pay05(40)   TYPE c,    "20 nota to payee 5
          not_pay06(40)   TYPE c,    "21 nota to payee 7
          not_pay07(40)   TYPE c,    "22 nota to payee 8
          not_pay08(40)   TYPE c,    "23 nota to payee 9
          not_pay09(40)   TYPE c,    "24 nota to payee 10
          not_pay010(40)   TYPE c,   "25 nota to payee 11
          not_pay011(40)   TYPE c,   "26 nota to payee 12
          not_pay012(40)   TYPE c,   "27 nota to payee 6
*          TP_OP(1)     TYPE C, "Tipo de operación.
*          sucursal(27) type c, "sucursal
       END OF ty_stndd,


    BEGIN OF ty_bcic,
               cod_bank(3)  TYPE c, "Clave de Banco
               ctbkn(10)    TYPE c, "Cuenta Bancaria
               fol_car(4)   TYPE c, "Número de Extracto
               fec_cont(8)  TYPE c, "Fecha de Contabilización
               mone(4)      TYPE c, "Moneda
               saldo_i(14)  TYPE c, ""Saldo Inicial
               to_carg(18)  TYPE c, "Total Cargos
               to_abon(18)  TYPE c, "Total Abonos
               saldo_f(14)  TYPE c, ""Saldo Final
    END OF ty_bcic,

    BEGIN OF ty_bcid,
               cod_bank(3)  TYPE c, "Clave de Banco.
               ctbkn(10)    TYPE c, "Cuenta Bancaria.
               fol_car(4)   TYPE c, "Número de Extracto.
               nopra(5)     TYPE c, "Número de operacion.
               descp(50)    TYPE c, "Descripción.
               tp_op(1)     TYPE c, "Tipo de operación.
               numck(10)    TYPE c, "Número de Cheque.
               monto(14)    TYPE c, "Monto
               fec_op(8)    TYPE c, "Fecha de operación.
      END OF ty_bcid.



****************Definición de Metodos*******************************************
    METHODS: m_get_data      IMPORTING value(wi_file)      TYPE filename
                                       value(wi_tipo)      TYPE p,

             m_set_data      IMPORTING value(i_itdata)      TYPE ito_c,

             m_procesa_bci   IMPORTING value(wi_bnco)      TYPE ty_banco
                             EXPORTING value(ito_c)        TYPE ito_c
                                       value(ito_d)        TYPE ito_d,

             m_procesa_stndr IMPORTING value(wi_bnco)      TYPE ty_banco
                             EXPORTING value(ito_c)        TYPE ito_c
                                       value(ito_d)        TYPE ito_d,

             m_procesa_chile   IMPORTING value(wi_bnco)    TYPE ty_banco
                             EXPORTING value(ito_c)        TYPE ito_c
                                       value(ito_d)        TYPE ito_d,

             m_procesa_security   IMPORTING value(wi_bnco) TYPE ty_banco
                             EXPORTING value(ito_c)        TYPE ito_c
                                       value(ito_d)        TYPE ito_d,

             m_procesa_bbva       IMPORTING value(wi_bnco) TYPE ty_banco
                             EXPORTING value(ito_c)        TYPE ito_c
                                       value(ito_d)        TYPE ito_d,

             m_procesa_bbva_xls       IMPORTING value(wi_bnco) TYPE ty_banco
                             EXPORTING value(ito_c)        TYPE ito_c
                                       value(ito_d)        TYPE ito_d,

             m_procesa_scotia     IMPORTING value(wi_bnco) TYPE ty_banco
                             EXPORTING value(ito_c)        TYPE ito_c
                                       value(ito_d)        TYPE ito_d,

             m_procesa_corp       IMPORTING value(wi_bnco) TYPE ty_banco
                             EXPORTING value(ito_c)        TYPE ito_c
                                       value(ito_d)        TYPE ito_d,
             m_procesa_corp_xls   IMPORTING value(wi_bnco) TYPE ty_banco
                             EXPORTING value(ito_c)        TYPE ito_c
                                       value(ito_d)        TYPE ito_d,

             m_procesa_estado       IMPORTING value(wi_bnco) TYPE ty_banco
                             EXPORTING value(ito_c)        TYPE ito_c
                                       value(ito_d)        TYPE ito_d,

             m_procesa_bice       IMPORTING value(wi_bnco) TYPE ty_banco
                             EXPORTING value(ito_c)        TYPE ito_c
                                       value(ito_d)        TYPE ito_d,

            m_procesa_bice_htm       IMPORTING value(wi_bnco) TYPE ty_banco
               EXPORTING value(ito_c)        TYPE ito_c
                         value(ito_d)        TYPE ito_d,

             m_procesa_all_xls       IMPORTING value(wi_bnco) TYPE ty_banco
                             EXPORTING value(ito_c)        TYPE ito_c
                                       value(ito_d)        TYPE ito_d,

             m_dwn_file      IMPORTING value(iti_c)        TYPE ito_c
                                       value(iti_d)        TYPE ito_d
                             EXPORTING value(w_flag1)      TYPE c,

             m_find_file     EXPORTING value(p_file1)      TYPE filename,

             m_valida_bco    EXPORTING value(wi_bnco)      TYPE ty_banco.

********************************************************************************

  PRIVATE SECTION.
    DATA cont TYPE i.



ENDCLASS.                    "C_CONTADOR DEFINITION
*----------------------------------------------------------------------*
*       CLASS Multicash
*----------------------------------------------------------------------*
CLASS multicash IMPLEMENTATION.
  METHOD m_get_data.

    DATA: l_filename TYPE string.
    l_filename  = p_file.

    CALL METHOD cl_gui_frontend_services=>gui_upload
       EXPORTING
         filename                =  l_filename
         filetype                = 'ASC'
*        has_field_separator     =
*        header_length           = 0
        read_by_line            = 'x'
*        dat_mode                = space
*        codepage                =
*        ignore_cerr             = abap_true
        replacement             = char_f
*        virus_scan_profile      =
*      IMPORTING
*        filelength              =
*        header                  =
       CHANGING
         data_tab                = it_data
       EXCEPTIONS
         file_open_error         = 1
         file_read_error         = 2
         no_batch                = 3
         gui_refuse_filetransfer = 4
         invalid_type            = 5
         no_authority            = 6
         unknown_error           = 7
         bad_data_format         = 8
         header_not_allowed      = 9
         separator_not_allowed   = 10
         header_too_long         = 11
         unknown_dp_error        = 12
         access_denied           = 13
         dp_out_of_memory        = 14
         disk_full               = 15
         dp_timeout              = 16
         not_supported_by_gui    = 17
         error_no_gui            = 18
         OTHERS                  = 19.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

* ahora se transforma la linea de texto plana a el formato
* del banco BCI

  ENDMETHOD.    "RESCATA DATOS DEL ARCHIVO PLANO.
  METHOD m_set_data.
    it_data = i_itdata.
  ENDMETHOD.    "RESCATA DATOS DEL ARCHIVO PLANO.

* ahora se transforma la linea de texto plana a el formato
* del banco BCI
*  METHOD M_PROCESA_CHL.
*
*
*    ENDMETHOD.
  METHOD m_valida_bco.

    DATA: w_hbkid TYPE  hbkid.
    DATA: w_bankl_ant TYPE t012-bankl.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
SORT IT_DATA .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
    READ TABLE it_data INDEX 1 INTO wa_data.


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT  bankl
*    INTO   w_bankl
*     FROM t012
*       WHERE
*       bukrs = p_bukrs AND
*       hbkid IN s_hbkid .  
*
* NEW CODE
    SELECT bankl

    INTO   w_bankl
     FROM t012
       WHERE
       bukrs = p_bukrs AND
       hbkid IN s_hbkid  ORDER BY PRIMARY KEY.  

* END. 07-07-2026 - ATC - ATC-03" Banmedica WA_DATA+52(3).
      IF NOT w_bankl_ant IS INITIAL AND w_bankl_ant NE w_bankl.

        MESSAGE i398(00) WITH text-003.
        LEAVE TO TRANSACTION 'ZCBAN'.
      ENDIF.
      MOVE w_bankl TO w_bankl_ant.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE i398(00) WITH text-004.
      LEAVE TO TRANSACTION 'ZCBAN'.
    ELSE.
      MOVE w_bankl TO wi_bnco.
    ENDIF.
  ENDMETHOD.                    "M_VALIDA_BCO
  METHOD m_procesa_stndr.
    TYPES: BEGIN OF s_bankn ,
           w_bankn TYPE t012k-bankn,
           END OF s_bankn.
    DATA: w_bankn TYPE s_bankn-w_bankn.
    DATA: t_bankn TYPE TABLE OF s_bankn.
*Modificacion Herman para cheques protestados
*Inicio
    TYPES: BEGIN OF ty_cheque ,
              indice TYPE i,
              ctbkn(12)    TYPE c,    "2 Numero de la cuenta BANCARIA 5
              numck(8)     TYPE c,    "10 numero cheque
              monto(17)    TYPE c,                          "11 Monto
           END OF ty_cheque.

    DATA: w_cheque TYPE ty_cheque,
          t_cheque TYPE STANDARD TABLE OF ty_cheque,
          w_items TYPE i.
*Fin
    DATA: wa_det         TYPE ty_stndd.
    DATA: wa_header      TYPE ty_stndc,
          w_lines(6)     TYPE  c,   "Banmedica se cambio de 2 a 5
          w_carg(18)     TYPE c,"Total Cargos
          w_abon(18)     TYPE c,"Total Abonos
          aux1(18)       TYPE c,
          aux2(18)       TYPE c,
          w_saldof(18)   TYPE c,
          w_ctbkn(12)    TYPE c,
          w_cod_bank(3)  TYPE c,
          w_num_ctla(5)  TYPE c,
          w_agno(4)      TYPE c,
          w_waers(5)     TYPE c ,
          w_incta(35)    TYPE c,
          wa_tmpbco(2) TYPE c VALUE '00',
          it_data2     TYPE STANDARD TABLE OF line,
          wa_ctaban(12) TYPE c
          .  " nombre de la cuenta corriente



* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT bankn INTO TABLE t_bankn FROM t012k
*           WHERE bukrs = p_bukrs AND
*                 hbkid IN s_hbkid AND
*                 hktid IN s_hktid.
*
* NEW CODE
    SELECT bankn
 INTO TABLE t_bankn FROM t012k
           WHERE bukrs = p_bukrs AND
                 hbkid IN s_hbkid AND
                 hktid IN s_hktid ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    it_data2[] = it_data[].
    CLEAR it_data.
    REFRESH it_data.
    LOOP AT it_data2 INTO wa_data.
      READ TABLE t_bankn WITH  KEY w_bankn+0(12) = wa_data+2(12) INTO  w_bankn.
      IF sy-subrc NE 0.
        CONCATENATE wa_tmpbco wa_data+2(10) INTO wa_ctaban.
        READ TABLE t_bankn WITH  KEY w_bankn+0(12) = wa_ctaban INTO w_bankn.
        IF sy-subrc EQ 0.
          MOVE wa_ctaban TO wa_data+2(12) .
          APPEND wa_data TO it_data.
        ENDIF.
      ELSE.
        APPEND wa_data TO it_data.
      ENDIF.
    ENDLOOP.
    CLEAR it_data2.
    REFRESH it_data2.

    CLEAR wa_data.
* el formato del banco SANTANDER se compone de tres tipos de registros
* formato de cabecera(tipo 1 ) , detalle ( tipo 2 )  y resumen ( tipo 3 ) .

    LOOP AT it_data INTO wa_data.
      IF wa_data+0(1) = '1'.  "Registro de cabecera


        w_ctbkn    = wa_data+2(12). "cuenta corriente
        w_cod_bank = w_bankl+0(3). "banmedicaWA_DATA+52(3).
        w_num_ctla = wa_data+72(5). "numero de cartola
        w_agno     = wa_data+68(4). "año de emisión de la cartola
        w_incta    = wa_data+24(35). "nombre de la cuenta corriente
*para el registro de cabecera , tengo en el registro 1 el saldo inicial ( o anterior )
        wa_header-fec_cont  = wa_data+64(8).   "Fecha de Contabilización

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = wa_data+86(16)
          IMPORTING
            output = wa_data+86(16).

        CONCATENATE wa_data+85(1) wa_data+86(16) INTO wa_header-sal_ini. "Saldo Inicial
        CONDENSE wa_header-sal_ini NO-GAPS.
      ENDIF.


* LEEMOS EL DETALLE REGISTRO 2
      IF wa_data+0(1) = '2'.  "Registro de detalle
        CLEAR wa_det.
        wa_det-cod_bank   = w_cod_bank.   "Clave de Banco.
        wa_det-ctbkn      = w_ctbkn.      "Cuenta Bancaria.
        wa_det-num_ctla   = w_num_ctla.   "Número de Extracto.
        wa_det-bank_postext = wa_data+127(5) ."codigo de la operacion.
        CLEAR wa_det-cod_op.              "= WA_DATA+127(5). "Número de operacion.
        CLEAR w_tr001.
        MOVE wa_data+56(40)  TO w_tr001.    "descripcion del movimeinto contable
        CLEAR: wa_det-not_pay01, wa_det-not_pay02, wa_det-not_pay03.

        wa_det-not_pay03    = w_tr001.       "Descripción. leer de la tabla xxx

        IF wa_data+32(8) = 0.   "Número de Cheque o deposito u otro tipo de documento.
          wa_det-numck = w_slash.
        ELSE.
          wa_det-numck    = wa_data+32(8). "Número de Cheque o deposito u otro tipo de documento.
          wa_det-not_pay01 = wa_data+32(8). "Número de Cheque o deposito u otro tipo de documento
        ENDIF.

        IF wa_data+40(1) = '+'.  "abono

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = wa_data+41(15)
            IMPORTING
              output = wa_data+41(15).
          CONCATENATE w_mas wa_data+41(15) INTO wa_det-monto. "ABONO

*Modificacion Herman para cheques protestados
*Inicio
*          TRANSLATE W_TR001 TO UPPER CASE.
*          IF W_TR001 CS 'PROTESTADO'.
*            w_cheque-numck = wa_det-numck.
*            w_cheque-ctbkn = wa_det-ctbkn.
*            w_cheque-monto = wa_det-monto.
*            DESCRIBE TABLE t_cheque LINES w_items.
*            add 1 to w_items.
*            w_cheque-indice = w_items.
*            APPEND w_cheque to t_cheque.
*          ENDIF.
*Fin
        ELSEIF wa_data+40(1) = '-'.  "cargo

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = wa_data+41(15)
            IMPORTING
              output = wa_data+41(15).
          CONCATENATE w_menos wa_data+41(15) INTO wa_det-monto. "Monto CARGO
*Modificacion Herman para cheques protestados
*Inicio
*          IF WA_DET-NUMCK <> w_slash.
*            w_cheque-numck = wa_det-numck.
*            w_cheque-ctbkn = wa_det-ctbkn.
*            w_cheque-monto = wa_det-monto.
*            DESCRIBE TABLE t_cheque LINES w_items.
*            add 1 to w_items.
*            w_cheque-indice = w_items.
*            APPEND w_cheque to t_cheque.
*          ENDIF.
*Fin

        ENDIF.
* movemos el campo sucursal
        MOVE wa_data+124(3) TO wa_det-not_pay02.  "sucursal

        wa_det-fec_cont = wa_data+24(4). "Fecha de operación.
        CONCATENATE wa_det-fec_cont+0(2) '.'
                    wa_det-fec_cont+2(2) '.'
                    w_agno+2(2)
            INTO wa_det-fec_cont.
        MOVE wa_det-fec_cont TO wa_det-fec_val.

        CONCATENATE wa_det-cod_bank "1
                    wa_det-ctbkn
                    wa_det-num_ctla
                    wa_det-fec_val
                    wa_det-prnot_num                        "5va vacio
                    wa_det-not_pay01  "Nro. Documento (nro cheque,deposito,etc)
                    wa_det-bank_postext " codigo de la operacion
                    wa_det-filler1      " no usado
*                    W_PCOMA
                    wa_det-cod_op
*                    WA_DET-TP_OP
                    wa_det-numck "10
                    wa_det-monto
                    wa_det-filler1    "no se usa
                    wa_det-filler2    "no se usa
                    wa_det-fec_cont
                    wa_det-filler2 "15
                    wa_det-filler3
                    wa_det-not_pay02  "Sucursal (Cod. Oficina)
                    wa_det-not_pay03  "Texto (descripcion)
*                   WA_DET-COD_OP
*                   wa_det-sucursal
            INTO wa_d
        SEPARATED BY ';'.
        APPEND wa_d TO ito_d.

      ENDIF.

*CABECERA
      IF wa_data+0(1) = '3'.  " Completar registro de cabecera

        wa_header-cod_bank  = w_cod_bank. "banmedicaWA_DATA+52(3)..    "Clave de Banco
        wa_header-ctbkn     = w_ctbkn .   "Cuenta Bancaria
        wa_header-num_ctla  = w_num_ctla.   "Número de Extracto
        wa_header-in_cta    = w_incta.  "nombre de cuenta corriente
        CONCATENATE wa_header-fec_cont+0(2) '.'
                    wa_header-fec_cont+2(2) '.'
                    wa_header-fec_cont+6(2)
              INTO  wa_header-fec_cont.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE waers
*          INTO w_waers
*          FROM t012k
*          WHERE bankn = wa_header-ctbkn.
*
* NEW CODE
        SELECT waers
        UP TO 1 ROWS 
          INTO w_waers
          FROM t012k
          WHERE bankn = wa_header-ctbkn ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        wa_header-moneda = w_waers.

        MOVE wa_data+115(15) TO w_carg.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = w_carg+0(17)
          IMPORTING
            output = w_carg+0(17).

        CONCATENATE w_menos w_carg+0(17) INTO wa_header-tot_c.
        CONDENSE wa_header-tot_c NO-GAPS.
        MOVE wa_data+100(15) TO w_abon.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = w_abon
          IMPORTING
            output = w_abon.

        CONCATENATE w_mas w_abon   INTO wa_header-tot_a.
        CONDENSE wa_header-tot_a NO-GAPS.

        w_saldof = wa_data+25(15).
        IF wa_data+24(1) = '+'.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = w_saldof
            IMPORTING
              output = w_saldof.

          CONCATENATE w_mas w_saldof INTO wa_header-sal_fin.
          CONDENSE wa_header-sal_fin NO-GAPS.

        ELSE.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = w_saldof
            IMPORTING
              output = w_saldof.

          CONCATENATE w_menos w_saldof INTO wa_header-sal_fin.
          CONDENSE wa_header-sal_fin NO-GAPS.

        ENDIF.
* total movimientos

        MOVE wa_data+130(6) TO  w_lines.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = w_lines
          IMPORTING
            output = w_lines.
        CONCATENATE wa_header-cod_bank
                    wa_header-ctbkn
                    wa_header-num_ctla
                    wa_header-fec_cont
                    wa_header-moneda
                    wa_header-sal_ini
                    wa_header-tot_c
                    wa_header-tot_a
                    wa_header-sal_fin
                    wa_header-in_cta
                    wa_header-xp_cta
                    w_pcoma
                    w_pcoma
                    w_pcoma
*                    W_PCOMA
*                    W_PCOMA
                    w_lines
               INTO wa_c
               SEPARATED BY ';'.
        APPEND wa_c TO ito_c.
        CLEAR wa_header. "limpiamos .
      ENDIF.
    ENDLOOP. "porque hay varias cuentas corrientes.
  ENDMETHOD.                    "M_PROCESA_STNDR

*---------------------------
* PROCESA BANCO BCI
*---------------------------
  METHOD m_procesa_bci.
    TYPES: BEGIN OF bci_type ,
              cod_bank(3)	TYPE c,
              nro_cta(10)	TYPE c,
              fec_ctla(8)	TYPE c,
              fol_ctla(4)	TYPE c,
              nro_doc(8)  TYPE n,
              fec_movto(8)  TYPE c,
              cod_movto(5)  TYPE c,
              tip_movto(1)  TYPE c,
              mto_cargo(14)	TYPE c,
              mto_abno(14)  TYPE c,
              sal_dia(14)	TYPE c,
              cod_ofi(3)  TYPE c,
              filler(13)  TYPE c,
           END OF bci_type.

    DATA: wa_det       TYPE ty_bcid.
    CONSTANTS: w_zeros VALUE '0'.
    DATA: wa_bci TYPE bci_type,
          wa_bci2 TYPE bci_type,
          contador(5) TYPE n,
          it_bci TYPE STANDARD TABLE OF bci_type,
          it_cab TYPE STANDARD TABLE OF ty_mcc,
          it_det TYPE STANDARD TABLE OF ty_mcd,
          sign TYPE vozpm_eb.
    DATA: wa_header    TYPE ty_bcic,
          wa_cabec TYPE ty_mcc,
          wa_detalle TYPE ty_mcd,
*          W_LINES LIKE SY-TABIX ,
          w_carg(14)   TYPE c,"Total Cargos
          w_abon(14)   TYPE c,"Total Abonos
          aux1(14)     TYPE c,
          aux2(14)     TYPE c,
          w_saldof(14) TYPE c,
          tot_c(18) TYPE n,
          tot_a(18) TYPE n,
          sal_fin(17)	TYPE n,
          sal_ini(17)	TYPE n,
          aux_monto(17) TYPE n,
          wa_vgext TYPE vgext_eb,
          wa_butxt TYPE butxt_eb
          .

*    DESCRIBE TABLE IT_DATA LINES W_LINES.

*    W_LINES = W_LINES - 1.

*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        INPUT  = W_LINES
*      IMPORTING
*        OUTPUT = W_LINES.
*Transformamos las lineas en la estructura definida para BCI
    LOOP AT it_data INTO wa_data.
      wa_bci-cod_bank	=	wa_data+0(3).
      wa_bci-nro_cta  = wa_data+3(10).
      SHIFT wa_bci-nro_cta LEFT DELETING LEADING   w_zeros.
      wa_bci-fol_ctla	=	wa_data+21(4).
      wa_bci-fec_ctla	=	wa_data+13(8).
      wa_bci-nro_doc  = wa_data+25(7).
      wa_bci-fec_movto  = wa_data+32(8).
      wa_bci-cod_movto  = wa_data+40(5).
      wa_bci-tip_movto  = wa_data+45(1).
      wa_bci-mto_cargo  = wa_data+46(14).
      wa_bci-mto_abno	=	wa_data+60(14).
      wa_bci-sal_dia  = wa_data+74(14).
      wa_bci-cod_ofi  = wa_data+88(3).
      wa_bci-filler	=	wa_data+91(13).
      APPEND wa_bci TO it_bci.
    ENDLOOP.
*Grabamos los datos en estructura de cabecera
    LOOP AT it_bci INTO wa_bci WHERE mto_cargo EQ '00000000000000' AND mto_abno EQ '00000000000000'.
      contador = 0.
      tot_c  = 0.
      tot_a  = 0.
      sal_fin  = 0.
      CLEAR wa_bci2.
      wa_cabec-cod_bank	=	wa_bci-cod_bank.
      wa_cabec-ctbkn  = wa_bci-nro_cta.
      wa_cabec-num_ctla	=	wa_bci-fol_ctla.
      CONCATENATE
          wa_bci-fec_movto+6(2) '.'
          wa_bci-fec_movto+4(2) '.'
          wa_bci-fec_movto+2(2)
          INTO wa_cabec-fec_cont.
      wa_cabec-moneda	=	'CLP'.
      wa_cabec-sal_ini  = wa_bci-sal_dia.
      LOOP AT it_bci INTO wa_bci2 WHERE nro_cta EQ wa_bci-nro_cta AND NOT mto_cargo EQ '00000000000000' OR nro_cta EQ wa_bci-nro_cta AND NOT mto_abno EQ '00000000000000' .
        tot_c = tot_c + wa_bci2-mto_cargo.
        tot_a = tot_a + wa_bci2-mto_abno.
        wa_detalle-cod_bank	=	wa_bci2-cod_bank.
        wa_detalle-ctbkn  = wa_bci2-nro_cta.
        wa_detalle-num_ctla	=	wa_bci2-fol_ctla.
        CONCATENATE
                wa_bci2-fec_movto+6(2) '.'
                wa_bci2-fec_movto+4(2) '.'
                wa_bci2-fec_movto+2(2)
                INTO wa_detalle-fec_val.
        wa_detalle-prnot_num  = 'CLP'.
        wa_vgext = wa_bci2-cod_movto.
        wa_detalle-filler1  = wa_bci2-filler.
        wa_detalle-numck  = wa_bci2-nro_doc.
        wa_detalle-not_pay01 = wa_bci2-nro_doc.
        CLEAR sign.
        IF wa_bci2-mto_cargo = '00000000000000'.
          sign = '+'.
          aux_monto = wa_bci2-mto_abno / 100.
        ELSE.
          sign = '-'.
          aux_monto = wa_bci2-mto_cargo / 100.
        ENDIF.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = aux_monto
          IMPORTING
            output = aux_monto.
        CONCATENATE sign aux_monto
            INTO wa_detalle-monto.
        aux_monto = 0.
        CALL FUNCTION 'ZFGETDESCCODOPE'
          EXPORTING
            i_vgtyp = 'BANCOBCI'
            i_vozpm = sign
            i_vgext = wa_vgext
          IMPORTING
            e_butxt = wa_butxt.
        wa_detalle-bank_postext	=	wa_vgext.
        wa_detalle-not_pay03 = wa_butxt+0(27).
        wa_detalle-not_pay04 = wa_butxt+27(23).
        CONCATENATE
                wa_bci2-fec_movto+6(2) '.'
                wa_bci2-fec_movto+4(2) '.'
                wa_bci2-fec_movto+2(2)
                INTO wa_detalle-p_date.
        IF wa_bci2-cod_ofi IS INITIAL.
          wa_bci2-cod_ofi = '000'.
        ENDIF.

        wa_detalle-not_pay02 = wa_bci2-cod_ofi.
        APPEND wa_detalle TO it_det.
        contador = contador + 1.
      ENDLOOP.
      IF wa_bci2 IS INITIAL.
        wa_cabec-sal_fin = wa_cabec-sal_ini.
      ELSE.
        wa_cabec-sal_fin = wa_bci2-sal_dia.
      ENDIF.

*Grabamos los datos faltantes en la cabecera del documento
      CLEAR sign.
      REPLACE ALL OCCURRENCES OF '+' IN wa_cabec-sal_ini WITH '0'.
      IF sy-subrc EQ 0.
        sign = '+'.
      ENDIF.
      REPLACE ALL OCCURRENCES OF '-' IN wa_cabec-sal_ini WITH '0'.
      IF sy-subrc EQ 0.
        sign = '-'.
      ENDIF.

      sal_ini = wa_cabec-sal_ini / 100.
      CONCATENATE sign sal_ini INTO wa_cabec-sal_ini.

      CLEAR sign.
      REPLACE ALL OCCURRENCES OF '+' IN wa_cabec-sal_fin WITH '0'.
      IF sy-subrc EQ 0.
        sign = '+'.
      ENDIF.
      REPLACE ALL OCCURRENCES OF '-' IN wa_cabec-sal_fin WITH '0'.
      IF sy-subrc EQ 0.
        sign = '-'.
      ENDIF.

      sal_fin = wa_cabec-sal_fin / 100.
      CONCATENATE sign sal_fin INTO wa_cabec-sal_fin.


      wa_cabec-nom_mov = contador.
      CLEAR contador.

      wa_cabec-tot_c  = tot_c / 100.
      wa_cabec-tot_a  = tot_a / 100.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_cabec-tot_c
        IMPORTING
          output = wa_cabec-tot_c.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_cabec-tot_a
        IMPORTING
          output = wa_cabec-tot_a.

      APPEND wa_cabec TO it_cab.
    ENDLOOP.

*Recorremos y grabamos en las lineas de cabecera y detalle
    LOOP AT it_cab INTO wa_cabec.
      CONCATENATE
                    wa_cabec-cod_bank
                    wa_cabec-ctbkn
                    wa_cabec-num_ctla
                    wa_cabec-fec_cont
                    wa_cabec-moneda
                    wa_cabec-sal_ini
                    wa_cabec-tot_c
                    wa_cabec-tot_a
                    wa_cabec-sal_fin
                    wa_cabec-in_cta
                    wa_cabec-xp_cta
                    wa_cabec-l_ini
                    wa_cabec-l_fin
                    wa_cabec-nu1
                    wa_cabec-nu2
                    wa_cabec-nu3
                    wa_cabec-nu4
                    wa_cabec-nom_mov
       INTO wa_c
       SEPARATED BY ';'.
      APPEND wa_c TO ito_c.
    ENDLOOP.

    LOOP AT it_det INTO wa_detalle.
      CONCATENATE
                    wa_detalle-cod_bank
                    wa_detalle-ctbkn
                    wa_detalle-num_ctla
                    wa_detalle-fec_val
                    wa_detalle-prnot_num
                    wa_detalle-not_pay01
                    wa_detalle-bank_postext
                    wa_detalle-filler1
                    wa_detalle-cod_op
                    wa_detalle-numck
                    wa_detalle-monto
                    wa_detalle-descp
                    wa_detalle-nu1
                    wa_detalle-p_date
                    wa_detalle-nu2
                    wa_detalle-nu3
                    wa_detalle-not_pay02
                    wa_detalle-not_pay03
                    wa_detalle-not_pay04
                    wa_detalle-not_pay05
                    wa_detalle-not_pay06
                    wa_detalle-not_pay07
                    wa_detalle-not_pay08
                    wa_detalle-not_pay09
                    wa_detalle-not_pay10
                    wa_detalle-not_pay11
                    wa_detalle-not_pay12
                    wa_detalle-not_pay13
                    wa_detalle-not_pay14
                    wa_detalle-bus_part1
                    wa_detalle-bus_part2
                    wa_detalle-bank_part1
                    wa_detalle-bank_part2
                    wa_detalle-bus_tcode
                    wa_detalle-nu4
       INTO wa_d
       SEPARATED BY ';'.
      APPEND wa_d TO ito_d.
    ENDLOOP.

  ENDMETHOD.                    "incrementar_contador

  METHOD m_procesa_chile.
    TYPES: BEGIN OF bchi_type ,
              nro_cta(11)	TYPE c,
              fec_ctla(8)	TYPE c,
              cod_movto(9)  TYPE c,
              nro_doc(8)  TYPE c,
              mto_movto(11) TYPE n,
              signo(1)  TYPE c,
              cod_ofi(3)  TYPE c,
              desc_movto(45),
              tip_movto(1)  TYPE c,
              fec_movto(8)  TYPE c,
              fol_ctla(5)  TYPE c,
           END OF bchi_type.

    TYPES: BEGIN OF bchi_tr,
              codigo(9) TYPE c,
              signo(1) TYPE c,
            END OF bchi_tr.

    DATA: it_cab TYPE STANDARD TABLE OF ty_mcc,"Salida
          it_det TYPE STANDARD TABLE OF ty_mcd,"Salida
          wa_cab TYPE ty_mcc,"Salida
          wa_det TYPE ty_mcd,"Salida
          wa_bchi TYPE bchi_type,"Estructura Banco Chile
          wa_bchi2 TYPE bchi_type,"Estructura Banco Chile
          it_bchi TYPE STANDARD TABLE OF bchi_type"Estructura Banco de Chile
*          IT_TR TYPE STANDARD TABLE OF BCHI_TR,
*          WA_TR TYPE BCHI_TR
          .

    DATA: contador(5) TYPE n,
          tot_c(18) TYPE n,
          tot_a(18) TYPE n,
          sal_fin	TYPE p,
          sal_fin_n(17)	TYPE n,
          sal_ini	TYPE p,
          sal_ini_n(17)	TYPE n,
          aux_monto(17) TYPE n,
          aux_header1(11) TYPE c,
          aux_header2(11) TYPE c.

    CONSTANTS: w_zeros VALUE '0'.
*Transformamos las lineas en la estructura definida para BCI
    LOOP AT it_data INTO wa_data.
      CLEAR wa_bchi.
      wa_bchi-nro_cta = wa_data+1(10).
      wa_bchi-fec_ctla = wa_data+11(8).
      wa_bchi-cod_movto = wa_data+19(9).
      SHIFT wa_bchi-cod_movto LEFT DELETING LEADING  w_zeros.
      wa_bchi-nro_doc = wa_data+28(8).
      wa_bchi-mto_movto = wa_data+36(11).
      wa_bchi-signo = wa_data+47(1).
      wa_bchi-cod_ofi = wa_data+48(3).
      wa_bchi-desc_movto = wa_data+51(45).
      wa_bchi-tip_movto = wa_data+96(1).
      wa_bchi-fec_movto = wa_data+97(8).
      wa_bchi-fol_ctla = wa_data+106(4).
      APPEND wa_bchi TO it_bchi.
    ENDLOOP.

    LOOP AT it_bchi INTO wa_bchi WHERE tip_movto EQ 'S' AND cod_movto EQ '990000000'.

* Cabecera
      wa_cab-cod_bank = '001'.
      wa_cab-ctbkn = wa_bchi-nro_cta.
      wa_cab-num_ctla = wa_bchi-fol_ctla.
      CONCATENATE
            wa_bchi-fec_ctla+6(2) '.'
            wa_bchi-fec_ctla+4(2) '.'
            wa_bchi-fec_ctla+2(2)
            INTO wa_cab-fec_cont.
      wa_cab-moneda = 'CLP'.
      sal_fin = wa_bchi-mto_movto.
*      WA_CAB-SAL_FIN = SAL_FIN.
      sal_ini = wa_bchi-mto_movto.
      IF wa_bchi-signo = '-'.
        sal_ini = sal_ini * -1.
        sal_fin = sal_ini.
      ENDIF.
      IF sal_fin < 0.
        sal_fin_n = sal_fin.
        CONCATENATE '-' sal_fin_n INTO wa_cab-sal_fin.
      ELSE.
        sal_fin_n = sal_fin.
        CONCATENATE '+' sal_fin_n INTO wa_cab-sal_fin.
      ENDIF.
*-----Mod
*      SAL_INI = WA_BCHI-MTO_MOVTO.
*      WA_CAB-SAL_INI = SAL_INI.
*      SAL_FIN = WA_BCHI-MTO_MOVTO.
*-----
*
*            WA_CAB-TOT_A
*            WA_CAB-SAL_FIN
*WA_CAB-IN_CTA
*WA_CAB-XP_CTA
*WA_CAB-L_INI
*WA_CAB-L_FIN
*WA_CAB-NU1
*WA_CAB-NU2
*WA_CAB-NU3
*WA_CAB-NU4
      CLEAR contador.
      CLEAR tot_c.
      CLEAR tot_a.
      LOOP AT it_bchi INTO wa_bchi2 WHERE tip_movto NE 'S' AND nro_cta EQ wa_bchi-nro_cta.
        aux_monto = wa_bchi2-mto_movto.
        IF wa_bchi2-tip_movto EQ 'C'.
          CONCATENATE '-' aux_monto INTO wa_det-monto.
          tot_c = tot_c + aux_monto.
*           SAL_FIN = SAL_FIN - AUX_MONTO.
          sal_ini = sal_ini + aux_monto.
        ELSE.
          CONCATENATE '+' aux_monto INTO wa_det-monto.
          tot_a = tot_a + aux_monto.
*           SAL_FIN = SAL_FIN + AUX_MONTO.
          sal_ini = sal_ini - aux_monto.
        ENDIF.
* Detalle
        wa_det-cod_bank = '001'.
        wa_det-ctbkn = wa_bchi2-nro_cta.
        wa_det-num_ctla = wa_bchi2-fol_ctla.
*WA_DET-FEC_VAL = WA_BCHI-FEC_MOVTO.
        CONCATENATE
              wa_bchi2-fec_movto+6(2) '.'
              wa_bchi2-fec_movto+4(2) '.'
              wa_bchi2-fec_movto+2(2)
              INTO wa_det-fec_val.
        wa_det-prnot_num = 'CLP'.
        wa_det-not_pay01 = wa_bchi2-nro_doc.
        wa_det-bank_postext = wa_bchi2-cod_movto.
*WA_DET-FILLER1 =
*WA_DET-COD_OP = WA_BCHI-COD_MOVTO.
*WA_DET-NUMCK
*WA_DET-MONTO
*WA_DET-DESCP
*WA_DET-NU1
*WA_DET-P_DATE
        CONCATENATE
              wa_bchi2-fec_movto+6(2) '.'
              wa_bchi2-fec_movto+4(2) '.'
              wa_bchi2-fec_movto+2(2)
              INTO wa_det-p_date.
*WA_DET-NU2
*WA_DET-NU3
        wa_det-not_pay02 = wa_bchi2-cod_ofi.
        wa_det-not_pay03 = wa_bchi2-desc_movto+0(27).
        wa_det-not_pay04 = wa_bchi2-desc_movto+27(18).
*WA_DET-NOT_PAY05
*WA_DET-NOT_PAY06
*WA_DET-NOT_PAY07
*WA_DET-NOT_PAY08
*WA_DET-NOT_PAY09
*WA_DET-NOT_PAY10
*WA_DET-NOT_PAY11
*WA_DET-NOT_PAY12
*WA_DET-NOT_PAY13
*WA_DET-NOT_PAY14
*WA_DET-BUS_PART1
*WA_DET-BUS_PART2
*WA_DET-BANK_PART1
*WA_DET-BANK_PART2
*WA_DET-BUS_TCODE
*WA_DET-NU4
        contador = contador + 1.
        APPEND wa_det TO it_det.
      ENDLOOP.
      wa_cab-tot_c = tot_c.
      wa_cab-tot_a = tot_a.
      IF sal_ini < 0.
        sal_ini_n = sal_ini.
        CONCATENATE '-' sal_ini_n INTO wa_cab-sal_ini.
      ELSE.
        sal_ini_n = sal_ini.
        CONCATENATE '+' sal_ini_n INTO wa_cab-sal_ini.
      ENDIF.
      wa_cab-nom_mov = contador.
      APPEND wa_cab TO it_cab.
    ENDLOOP.

*   Recorremos y grabamos en las lineas de cabecera y detalle
    LOOP AT it_cab INTO wa_cab.
      CONCATENATE
                    wa_cab-cod_bank
                    wa_cab-ctbkn
                    wa_cab-num_ctla
                    wa_cab-fec_cont
                    wa_cab-moneda
                    wa_cab-sal_ini
                    wa_cab-tot_c
                    wa_cab-tot_a
                    wa_cab-sal_fin
                    wa_cab-in_cta
                    wa_cab-xp_cta
                    wa_cab-l_ini
                    wa_cab-l_fin
                    wa_cab-nu1
                    wa_cab-nu2
                    wa_cab-nu3
                    wa_cab-nu4
                    wa_cab-nom_mov
       INTO wa_c
       SEPARATED BY ';'.
      APPEND wa_c TO ito_c.
    ENDLOOP.

    LOOP AT it_det INTO wa_det.
      CONCATENATE
                    wa_det-cod_bank
                    wa_det-ctbkn
                    wa_det-num_ctla
                    wa_det-fec_val
                    wa_det-prnot_num
                    wa_det-not_pay01
                    wa_det-bank_postext
                    wa_det-filler1
                    wa_det-cod_op
                    wa_det-numck
                    wa_det-monto
                    wa_det-descp
                    wa_det-nu1
                    wa_det-p_date
                    wa_det-nu2
                    wa_det-nu3
                    wa_det-not_pay02
                    wa_det-not_pay03
                    wa_det-not_pay04
                    wa_det-not_pay05
                    wa_det-not_pay06
                    wa_det-not_pay07
                    wa_det-not_pay08
                    wa_det-not_pay09
                    wa_det-not_pay10
                    wa_det-not_pay11
                    wa_det-not_pay12
                    wa_det-not_pay13
                    wa_det-not_pay14
                    wa_det-bus_part1
                    wa_det-bus_part2
                    wa_det-bank_part1
                    wa_det-bank_part2
                    wa_det-bus_tcode
                    wa_det-nu4
       INTO wa_d
       SEPARATED BY ';'.
      APPEND wa_d TO ito_d.
    ENDLOOP.
  ENDMETHOD.                    "M_PROCESA_CHILE

  METHOD m_procesa_security.

    DATA: it_cab TYPE STANDARD TABLE OF ty_mcc,"Salida
          it_det TYPE STANDARD TABLE OF ty_mcd,"Salida
          wa_cab TYPE ty_mcc,"Salida
          wa_det TYPE ty_mcd."Salida

    TYPES: BEGIN OF ty_secc,
             cod_bank(12) TYPE c,
             ctbkn(24)    TYPE c,
             num_ctla(4)  TYPE c,
             fec_cont(10) TYPE c,
             moneda(3)    TYPE c,
             sal_ini(18)  TYPE c,
             tot_c(18)    TYPE c,
             tot_a(18)    TYPE c,
             sal_fin(18)  TYPE c,
             nom_mov(5)   TYPE n,
           END OF ty_secc,

      BEGIN OF ty_secd,
        tipo(1)      TYPE c,
        fecmovto(10) TYPE c,
        cod_op(2)    TYPE c,
        desc_mov(54) TYPE c,
        tmovto(1)    TYPE c,
        monto(18)    TYPE c,
        nro_doc(8)   TYPE n,
      END OF ty_secd.

    DATA: wa_secd       TYPE ty_secd,
          wa_secc       TYPE ty_secc,
          it_secd       TYPE STANDARD TABLE OF ty_secd,
          it_secc       TYPE STANDARD TABLE OF ty_secc,
          n_sum         TYPE i,
          n_coma        TYPE i,
          aux_monto(17) TYPE n,
          result_tab    TYPE match_result_tab,
          line_tab LIKE LINE OF result_tab,
          result_tab2   TYPE match_result_tab,
          w_lineas      TYPE i,
          line_tab2     LIKE LINE OF result_tab,
          moff          TYPE i,
          mlen          TYPE i,
          tot_c(18)     TYPE n,
          tot_a(18)     TYPE n,
*          SAL_FIN TYPE P,
          sal_fin_n(17) TYPE n,
          sal_ini_n(17) TYPE n,
          items(5)      TYPE n,
          n_ctla        TYPE i,
          n_ctla2(4)    TYPE n,
          tamano        TYPE i,
          signo(1)      TYPE c,
          descrip(50)   TYPE c.


    FIELD-SYMBOLS: <fs_linetab> LIKE LINE OF result_tab,
                   <fs_linetab2> LIKE LINE OF result_tab.

    LOOP AT it_data INTO wa_data.

* PYV 09/10/2012
*      CONDENSE wa_data.
* PYV 09/10/2012

      wa_secd-tipo = wa_data+0(1).

      IF wa_secd-tipo = '1'.         "Cabecera

* PYV 09/10/2012
*          WA_SECC-COD_BANK = '049'.
*
*          FIND '-'
*            IN WA_DATA
*             MATCH OFFSET moff
*             MATCH LENGTH mlen.
*           IF SY-SUBRC EQ 0.
*             N_SUM = MOFF.
*             N_SUM = N_SUM + 1.
*           ENDIF.
*
*          FIND 'P'
*            IN WA_DATA
*             MATCH OFFSET moff
*             MATCH LENGTH mlen.
*           IF SY-SUBRC EQ 0.
*             N_COMA = MOFF.
*             N_CTLA = MOFF + 5.
*             N_COMA = N_COMA - N_SUM.
*           ENDIF.
*
*          "Cta Banco
*          WA_SECC-CTBKN = WA_DATA+N_SUM(N_COMA).
*          REPLACE ALL OCCURRENCES OF '-' IN WA_SECC-CTBKN WITH ''.
*           CONDENSE WA_SECC-CTBKN.
*
*          FIND '/'
*            IN WA_DATA
*             MATCH OFFSET moff
*             MATCH LENGTH mlen.
*           IF SY-SUBRC EQ 0.
*             N_SUM = MOFF.
*             N_SUM = N_SUM - 2.
*           ENDIF.
*
*          WA_SECC-FEC_CONT = WA_DATA+N_SUM(10).     "Fecha Contable
*          N_SUM            = N_SUM - N_CTLA.
*          WA_SECC-NUM_CTLA = WA_DATA+N_CTLA(N_SUM). "Cartola
*          WA_SECC-MONEDA   = 'CLP'.
*
**          FIND '+'
**            IN WA_DATA
**             MATCH OFFSET moff
**             MATCH LENGTH mlen.
**           IF SY-SUBRC EQ 0.
**             N_SUM = MOFF.
**             N_SUM = N_SUM + 1.
**           ENDIF.
**           FIND ','
**            IN WA_DATA
**             MATCH OFFSET moff
**             MATCH LENGTH mlen.
**           IF SY-SUBRC EQ 0.
**             N_COMA = MOFF.
**             N_COMA = N_COMA - N_SUM.
**           ENDIF.
**           WA_SECC-SAL_INI = WA_DATA+N_SUM(N_COMA).
**           CONDENSE WA_SECC-SAL_INI.
**           SAL_FIN = WA_SECC-SAL_INI.
**           SAL_FIN_N = SAL_FIN.
**           IF SAL_FIN < 0.
**              CONCATENATE '-' SAL_FIN_N INTO WA_SECC-SAL_INI.
**           ELSE.
**              CONCATENATE '+' SAL_FIN_N INTO WA_SECC-SAL_INI.
**           ENDIF.

* Dado que se utiliza una rutina de Parseo para cada Banco,
* Se cambia forma de separar la información para que sea mas entendible.

        wa_secc-cod_bank = '049'.

        "Cta Banco
        wa_secc-ctbkn = wa_data+3(11).
        REPLACE ALL OCCURRENCES OF '-' IN wa_secc-ctbkn WITH ''.
        CONDENSE wa_secc-ctbkn.

        wa_secc-fec_cont = wa_data+40(10).     "Fecha Contable
        wa_secc-num_ctla = wa_data+36(4).      "Cartola
        wa_secc-moneda   = 'CLP'.

* PYV 09/10/2012
      ELSEIF wa_secd-tipo = '2'.  "Detalle

* PYV 09/10/2012

*        CLEAR WA_SECD.
*        ITEMS            = ITEMS + 1.
*        WA_SECD-FECMOVTO = WA_DATA+1(10).
*        WA_SECD-COD_OP   = WA_DATA+12(2).
*
*        FIND ALL OCCURRENCES OF '+'
*           IN WA_DATA RESULTS result_tab2.
*         IF sy-subrc EQ 0.
*           DESCRIBE TABLE result_tab2 LINES w_lineas.
*           LOOP AT result_tab2 INTO line_tab2.
*             moff = line_tab2-OFFSET - 1.
*             IF wa_data+moff(1) = 'A' OR wa_data+moff(1) = 'C'.
*               moff  = line_tab2-OFFSET.
*               N_SUM = MOFF.
*               N_SUM = N_SUM - 1.
*               exit.
*             ENDIF.
*           ENDLOOP.
*         ENDIF.
*
*        FIND ','
*           IN WA_DATA
*            MATCH OFFSET moff
*            MATCH LENGTH mlen.
*          IF SY-SUBRC EQ 0.
*            N_COMA = MOFF.
*          ENDIF.
*
*        WA_SECD-TMOVTO   = WA_DATA+N_SUM(1).
*        N_SUM            = N_SUM - 15.
*        WA_SECD-DESC_MOV = WA_DATA+15(N_SUM).
*        CONDENSE WA_SECD-DESC_MOV.
*
*        N_SUM         = N_SUM + 18.
*        N_COMA        = N_COMA - N_SUM.
*        WA_SECD-MONTO = WA_DATA+N_SUM(N_COMA).
*        AUX_MONTO     = WA_SECD-MONTO.
*        CONDENSE WA_SECD-MONTO.
*
*        IF WA_SECD-TMOVTO = 'C'.
*          TOT_C = TOT_C + AUX_MONTO.
**          SAL_FIN = SAL_FIN - AUX_MONTO.
*          CONCATENATE '-' AUX_MONTO INTO WA_SECD-MONTO.
*        ELSE.
*          TOT_A = TOT_A + AUX_MONTO.
**          SAL_FIN = SAL_FIN + AUX_MONTO.
*          CONCATENATE '+' AUX_MONTO INTO WA_SECD-MONTO.
*        ENDIF.
*
*        FIND ALL OCCURRENCES OF regex '\d+'
*          IN WA_SECD-DESC_MOV RESULTS result_tab.
*        IF sy-subrc EQ 0.
*          READ TABLE result_tab INDEX 1 ASSIGNING <fs_linetab>.
*          WA_SECD-NRO_DOC = WA_SECD-DESC_MOV+<fs_linetab>-offset(<fs_linetab>-length).
*        ENDIF.
*
*        APPEND WA_SECD TO IT_SECD.

* Dado que se utiliza una rutina de Parseo para cada Banco,
* Se cambia forma de separar la información para que sea mas entendible.

        CLEAR wa_secd.
        items            = items + 1.
        wa_secd-fecmovto = wa_data+1(10).

        descrip = wa_data+11(50).
        CONDENSE descrip.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE codigo INTO wa_secd-cod_op
*          FROM zopebco WHERE cbanco EQ wa_secc-cod_bank
*                       AND   sbusq  EQ descrip.
*
* NEW CODE
        SELECT codigo
        UP TO 1 ROWS  INTO wa_secd-cod_op
          FROM zopebco WHERE cbanco EQ wa_secc-cod_bank
                       AND   sbusq  EQ descrip ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        wa_secd-nro_doc  = wa_data+62(8).
        wa_secd-tmovto   = wa_data+70(1).
        wa_secd-desc_mov = wa_data+11(50).
        CONDENSE wa_secd-desc_mov.
*        wa_secd-desc_mov = wa_secd-desc_mov+3(50).

        wa_secd-monto = wa_data+73(12).
        aux_monto     = wa_secd-monto.
        CONDENSE wa_secd-monto.

        IF wa_secd-tmovto = 'C'.
          tot_c = tot_c + aux_monto.
*          SAL_FIN = SAL_FIN - AUX_MONTO.
          CONCATENATE '-' aux_monto INTO wa_secd-monto.
        ELSE.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
SORT RESULT_TAB .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
          tot_a = tot_a + aux_monto.
*          SAL_FIN = SAL_FIN + AUX_MONTO.
          CONCATENATE '+' aux_monto INTO wa_secd-monto.
        ENDIF.

        APPEND wa_secd TO it_secd.

* PYV 09/10/2012

      ELSEIF wa_secd-tipo = '9'.

        FIND ALL OCCURRENCES OF REGEX '\d+,'
          IN wa_data RESULTS result_tab.

        IF sy-subrc EQ 0.
          READ TABLE result_tab INDEX 1 INTO line_tab.
          moff      = line_tab-offset.
          mlen      = line_tab-length.
          mlen      = mlen - 1.
          sal_ini_n = wa_data+moff(mlen).
          moff      = moff + mlen + 3.
          signo     = wa_data+moff(1).
          CONCATENATE signo sal_ini_n INTO wa_secc-sal_ini.

          CLEAR signo.
          CLEAR line_tab.
          DESCRIBE TABLE result_tab LINES tamano.
*ReSQ: No Need Of Change Internal Table RESULT_TAB Already Sorted
          READ TABLE result_tab INDEX tamano INTO line_tab.
          moff      = line_tab-offset.
          mlen      = line_tab-length.
          mlen      = mlen - 1.
          sal_fin_n = wa_data+moff(mlen).
          moff      = moff + mlen + 3.
          signo     = wa_data+moff(1).
          IF signo NE '-'.
            signo = '+'.
          ENDIF.
          CONCATENATE signo sal_fin_n INTO wa_secc-sal_fin.
        ENDIF.

      ENDIF.

    ENDLOOP.

    wa_secc-tot_c = tot_c.
    wa_secc-tot_a = tot_a.
*    SAL_FIN_N = SAL_FIN.
*    IF SAL_FIN < 0.
*      CONCATENATE '-' SAL_FIN_N INTO WA_SECC-SAL_FIN.
*    ELSE.
*      CONCATENATE '+' SAL_FIN_N INTO WA_SECC-SAL_FIN.
*    ENDIF.
    wa_secc-nom_mov = items.

    wa_cab-cod_bank = '049'.
    wa_cab-ctbkn    = wa_secc-ctbkn.

    CONCATENATE
              wa_secc-fec_cont+0(2) '.'
              wa_secc-fec_cont+3(2) '.'
              wa_secc-fec_cont+8(2)
              INTO wa_cab-fec_cont.

    wa_cab-moneda   = 'CLP'.
    wa_cab-sal_ini  = wa_secc-sal_ini.
    wa_cab-tot_c    = wa_secc-tot_c.
    wa_cab-tot_a    = wa_secc-tot_a.
    wa_cab-sal_fin  = wa_secc-sal_fin.
    wa_cab-nom_mov  = wa_secc-nom_mov.
    n_ctla2         = wa_secc-num_ctla.
    wa_cab-num_ctla = n_ctla2.

    APPEND wa_cab TO it_cab.

    LOOP AT it_secd INTO wa_secd.
      wa_det-cod_bank = '049'.
      wa_det-ctbkn = wa_secc-ctbkn.
*        CONCATENATE WA_CAB-FEC_CONT+3(2) WA_CAB-FEC_CONT+0(2) INTO WA_DET-NUM_CTLA.
      wa_det-num_ctla = wa_cab-num_ctla.
      CONCATENATE
            wa_secd-fecmovto+0(2) '.'
            wa_secd-fecmovto+3(2) '.'
            wa_secd-fecmovto+8(2)
            INTO wa_det-fec_val.
*       MODIFICACION WA_DET-P_DATE = WA_DET-FEC_VAL.
      wa_det-prnot_num    = 'CLP'.
      concatenate '00000' wa_secd-nro_doc into wa_det-numck.
   "   wa_det-not_pay01    = wa_secd-nro_doc.
      wa_det-bank_postext = wa_secd-cod_op.
*       MODIFICACION WA_DET-P_DATE = WA_DET-FEC_VAL.
      wa_det-p_date       = wa_cab-fec_cont.
      wa_det-not_pay02    = '000'.
      wa_det-not_pay03    = wa_secd-desc_mov+0(27).
      wa_det-not_pay04    = wa_secd-desc_mov+27(27).
      wa_det-monto        = wa_secd-monto.
      APPEND wa_det TO it_det.
    ENDLOOP.

*   Recorremos y grabamos en las lineas de cabecera y detalle
    LOOP AT it_cab INTO wa_cab.
      CONCATENATE
                    wa_cab-cod_bank
                    wa_cab-ctbkn
                    wa_cab-num_ctla
                    wa_cab-fec_cont
                    wa_cab-moneda
                    wa_cab-sal_ini
                    wa_cab-tot_c
                    wa_cab-tot_a
                    wa_cab-sal_fin
                    wa_cab-in_cta
                    wa_cab-xp_cta
                    wa_cab-l_ini
                    wa_cab-l_fin
                    wa_cab-nu1
                    wa_cab-nu2
                    wa_cab-nu3
                    wa_cab-nu4
                    wa_cab-nom_mov
       INTO wa_c
       SEPARATED BY ';'.
      APPEND wa_c TO ito_c.
    ENDLOOP.

    LOOP AT it_det INTO wa_det.
      CONCATENATE
                    wa_det-cod_bank
                    wa_det-ctbkn
                    wa_det-num_ctla
                    wa_det-fec_val
                    wa_det-prnot_num
                    wa_det-not_pay01
                    wa_det-bank_postext
                    wa_det-filler1
                    wa_det-cod_op
                    wa_det-numck
                    wa_det-monto
                    wa_det-descp
                    wa_det-nu1
                    wa_det-p_date
                    wa_det-nu2
                    wa_det-nu3
                    wa_det-not_pay02
                    wa_det-not_pay03
                    wa_det-not_pay04
                    wa_det-not_pay05
                    wa_det-not_pay06
                    wa_det-not_pay07
                    wa_det-not_pay08
                    wa_det-not_pay09
                    wa_det-not_pay10
                    wa_det-not_pay11
                    wa_det-not_pay12
                    wa_det-not_pay13
                    wa_det-not_pay14
                    wa_det-bus_part1
                    wa_det-bus_part2
                    wa_det-bank_part1
                    wa_det-bank_part2
                    wa_det-bus_tcode
                    wa_det-nu4
       INTO wa_d
       SEPARATED BY ';'.
      APPEND wa_d TO ito_d.
    ENDLOOP.
  ENDMETHOD.                    "M_PROCESA_SECURITY

  METHOD m_procesa_bbva_xls.
    TYPES: BEGIN OF bbva_type,
            fecha(10) TYPE c,
            nro_mov(10) TYPE c,
            desc(50) TYPE c,
            fec_val(50) TYPE c,
            monto(18) TYPE c,
            saldo(18) TYPE c,
            over_file(100) TYPE c,
            END OF bbva_type.

    DATA: it_bbva TYPE STANDARD TABLE OF bbva_type,
          wa_bbva TYPE bbva_type,
          it_cab TYPE STANDARD TABLE OF ty_mcc,"Salida
          it_det TYPE STANDARD TABLE OF ty_mcd,
          wa_det TYPE ty_mcd,"Salida
          wa_cab TYPE ty_mcc.
    DATA: contador(5) TYPE n,
      tot_c(18) TYPE n,
      tot_a(18) TYPE n,
      sal_fin_p	TYPE p,
      sal_ini_p	TYPE p,
      aux_p1 TYPE p,
      aux_p2 TYPE p,
      sal_fin_n(17)	TYPE n,
      sal_ini_n(17)	TYPE n,
      aux_monto(17) TYPE n,
      aux_header1(11) TYPE c,
      aux_header2(11) TYPE c,
      nro_doc(8) TYPE n,
      aux_i(10) TYPE n,
      moff TYPE i,
      nro_mov TYPE i,
      mov_n(5) TYPE n ,
      signo TYPE sign,
      tbankl TYPE bankl,
      desc TYPE char100,
      result_tab TYPE match_result_tab.
    FIELD-SYMBOLS: <fs_linetab> LIKE LINE OF result_tab.

    LOOP AT it_data INTO wa_data.
      TRANSLATE wa_data TO UPPER CASE.
      SPLIT wa_data AT ';'
       INTO
         wa_bbva-fecha
         wa_bbva-nro_mov
         wa_bbva-desc
         wa_bbva-fec_val
         wa_bbva-monto
         wa_bbva-saldo
         wa_bbva-over_file.
      REPLACE ALL OCCURRENCES OF '.' IN wa_bbva-monto WITH ''.
      REPLACE ALL OCCURRENCES OF '.' IN wa_bbva-saldo WITH ''.
      APPEND wa_bbva TO it_bbva.
    ENDLOOP.

*Begin of change: ReSQ Correction for DELETE on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
SORT IT_BBVA .
*End of change: ReSQ Correction for DELETE on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
    LOOP AT it_bbva INTO wa_bbva WHERE fec_val NS '/'.
      DELETE it_bbva INDEX sy-tabix.
      IF wa_bbva-fec_val CS 'CTA' AND wa_bbva-fec_val CS 'NRO'.
        FIND ALL OCCURRENCES OF '-'
          IN wa_bbva-fec_val RESULTS result_tab.
        IF sy-subrc EQ 0.
*ReSQ: No Need Of Change Internal Table RESULT_TAB Already Sorted
          READ TABLE result_tab INDEX 2 ASSIGNING <fs_linetab>.
          moff = <fs_linetab>-offset + 1.
          aux_i = wa_bbva-fec_val+moff(10).
          wa_cab-ctbkn = aux_i.
          wa_cab-cod_bank = wi_bnco.
          wa_cab-moneda = 'CLP'.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT it_bbva INTO wa_bbva.
      CONDENSE wa_bbva-monto NO-GAPS.
      CONDENSE wa_bbva-saldo NO-GAPS.
      aux_p1 = wa_bbva-monto.
      aux_p2 = wa_bbva-saldo.

      IF sy-tabix EQ 1.
        CONCATENATE wa_bbva-fecha+3(2) wa_bbva+0(2) INTO wa_cab-num_ctla.
        CONCATENATE wa_bbva-fecha+0(2) '.' wa_bbva-fecha+3(2) '.' wa_bbva+8(2) INTO wa_cab-fec_cont.
        sal_ini_p = aux_p2 - aux_p1.
      ENDIF.

      sal_fin_p = aux_p2.
      IF aux_p1 < 0.
        aux_p1 = aux_p1 * -1.
        aux_monto = aux_p1.
        tot_c = tot_c + aux_p1.
        CONCATENATE '-' aux_monto INTO wa_det-monto.
        signo = '-'.
        FIND ALL OCCURRENCES OF REGEX '\d+'
         IN wa_bbva-desc RESULTS result_tab.
        IF sy-subrc EQ 0.
*ReSQ: No Need Of Change Internal Table RESULT_TAB Already Sorted
          READ TABLE result_tab INDEX 1 ASSIGNING <fs_linetab>.
          nro_doc = wa_bbva-desc+<fs_linetab>-offset(<fs_linetab>-length).
          wa_det-not_pay01 = nro_doc.
          CLEAR nro_doc.
        ENDIF.
      ELSE.
        aux_monto = aux_p1.
        CONCATENATE '+' aux_monto INTO wa_det-monto.
        tot_a = tot_a + aux_p1.
        signo = '+'.
      ENDIF.


      wa_det-cod_bank = wa_cab-cod_bank.
      wa_det-ctbkn = wa_cab-ctbkn.
      wa_det-num_ctla = wa_cab-num_ctla.
      CONCATENATE wa_bbva-fecha+0(2) '.' wa_bbva-fecha+3(2) '.' wa_bbva-fecha+8(2) INTO wa_det-fec_val.
      wa_det-prnot_num = wa_cab-moneda.
      wa_det-p_date = wa_det-fec_val.
      desc = wa_bbva-desc.
      CALL FUNCTION 'ZCOD_OPERACION'
        EXPORTING
          i_cbanco = wi_bnco
          i_cbusq  = 'C'
          i_movbco = signo
          i_desc   = desc
        IMPORTING
          e_codigo = tbankl.
      wa_det-bank_postext = tbankl.
      wa_det-not_pay02 = '000'.
      wa_det-not_pay03 = wa_bbva-desc+0(27) .
      wa_det-not_pay04 = wa_bbva-desc+27(23).
      nro_mov = nro_mov + 1.
      APPEND wa_det TO it_det.
    ENDLOOP.
    sal_ini_n = sal_ini_p.
    sal_fin_n = sal_fin_p.
    IF sal_ini_p < 0.
      CONCATENATE '-' sal_ini_n INTO wa_cab-sal_ini.
    ELSE.
      CONCATENATE '+' sal_ini_n INTO wa_cab-sal_ini.
    ENDIF.

    IF sal_fin_p < 0.
      CONCATENATE '-' sal_fin_n INTO wa_cab-sal_fin.
    ELSE.
      CONCATENATE '+' sal_fin_n INTO wa_cab-sal_fin.
    ENDIF.

    wa_cab-tot_c = tot_c.
    wa_cab-tot_a = tot_a.
    mov_n = nro_mov.
    wa_cab-nom_mov = mov_n.
    APPEND wa_cab TO it_cab.
*     BREAK-POINT.
*     EXIT.
*   Recorremos y grabamos en las lineas de cabecera y detalle
    LOOP AT it_cab INTO wa_cab.
      CONCATENATE
                    wa_cab-cod_bank
                    wa_cab-ctbkn
                    wa_cab-num_ctla
                    wa_cab-fec_cont
                    wa_cab-moneda
                    wa_cab-sal_ini
                    wa_cab-tot_c
                    wa_cab-tot_a
                    wa_cab-sal_fin
                    wa_cab-in_cta
                    wa_cab-xp_cta
                    wa_cab-l_ini
                    wa_cab-l_fin
                    wa_cab-nu1
                    wa_cab-nu2
                    wa_cab-nu3
                    wa_cab-nu4
                    wa_cab-nom_mov
       INTO wa_c
       SEPARATED BY ';'.
      APPEND wa_c TO ito_c.
    ENDLOOP.


    LOOP AT it_det INTO wa_det.
      CONCATENATE
                    wa_det-cod_bank
                    wa_det-ctbkn
                    wa_det-num_ctla
                    wa_det-fec_val
                    wa_det-prnot_num
                    wa_det-not_pay01
                    wa_det-bank_postext
                    wa_det-filler1
                    wa_det-cod_op
                    wa_det-numck
                    wa_det-monto
                    wa_det-descp
                    wa_det-nu1
                    wa_det-p_date
                    wa_det-nu2
                    wa_det-nu3
                    wa_det-not_pay02
                    wa_det-not_pay03
                    wa_det-not_pay04
                    wa_det-not_pay05
                    wa_det-not_pay06
                    wa_det-not_pay07
                    wa_det-not_pay08
                    wa_det-not_pay09
                    wa_det-not_pay10
                    wa_det-not_pay11
                    wa_det-not_pay12
                    wa_det-not_pay13
                    wa_det-not_pay14
                    wa_det-bus_part1
                    wa_det-bus_part2
                    wa_det-bank_part1
                    wa_det-bank_part2
                    wa_det-bus_tcode
                    wa_det-nu4
       INTO wa_d
       SEPARATED BY ';'.
      APPEND wa_d TO ito_d.
    ENDLOOP.
  ENDMETHOD.                    "M_PROCESA_BBVA_XLS

  METHOD m_procesa_bbva.
    TYPES: BEGIN OF bbva_type ,
          tip_movto(1) TYPE c,
          fec_movto(10) TYPE c,
          cuenta(10) TYPE c,
          fol_ctla(4) TYPE c,
          sec_num(3) TYPE c,
          nro_doc(27) TYPE c,
          desc_movto(54) TYPE c,
          mto_movtod(17) TYPE c,
          mto_movtoh(18) TYPE c,
          cod_movto(3) TYPE c,
       END OF bbva_type.

    DATA: it_cab TYPE STANDARD TABLE OF ty_mcc,"Salida
          it_det TYPE STANDARD TABLE OF ty_mcd,"Salida
          wa_det TYPE ty_mcd,"Salida
          wa_cab TYPE ty_mcc,"Salida
          wa_bbva TYPE bbva_type,
          wa_bbva2 TYPE bbva_type,
          it_bbva TYPE STANDARD TABLE OF bbva_type.

    DATA: contador(5) TYPE n,
      tot_c(18) TYPE n,
      tot_a(18) TYPE n,
      sal_fin	TYPE p,
      sal_ini	TYPE p,
      sal_fin_n(17)	TYPE n,
      sal_ini_n(17)	TYPE n,
      aux_monto(17) TYPE n,
      aux_header1(11) TYPE c,
      aux_header2(11) TYPE c,
      nro_doc(8) TYPE n.
*Transformamos las lineas en la estructura definida para BCI
    LOOP AT it_data INTO wa_data.
      CLEAR wa_bbva.
      SPLIT wa_data AT ';'
      INTO
        wa_bbva-tip_movto
        wa_bbva-fec_movto
        wa_bbva-cuenta
        wa_bbva-fol_ctla
        wa_bbva-sec_num
        wa_bbva-nro_doc
        wa_bbva-desc_movto
        wa_bbva-mto_movtod
        wa_bbva-mto_movtoh
        wa_bbva-cod_movto.
      APPEND wa_bbva TO it_bbva.
    ENDLOOP.

    CLEAR wa_bbva.
    LOOP AT it_bbva INTO wa_bbva WHERE tip_movto = '1'.

      wa_cab-cod_bank = '504'.
      wa_cab-ctbkn = wa_bbva-mto_movtod.
      wa_cab-num_ctla = wa_bbva-fol_ctla.
      CONCATENATE wa_bbva-fec_movto+0(2) '.'
                    wa_bbva-fec_movto+3(2) '.'
                    wa_bbva-fec_movto+8(2)
        INTO wa_cab-fec_cont.                               "04/01/2010

      wa_cab-moneda = 'CLP'.
      sal_ini = wa_bbva-nro_doc.
      sal_ini_n = sal_ini.
      IF sal_ini < 0.
        CONCATENATE '-' sal_ini_n INTO wa_cab-sal_ini.
      ELSE.
        CONCATENATE '+' sal_ini_n INTO wa_cab-sal_ini.
      ENDIF.

      sal_fin = sal_ini.

      CLEAR wa_bbva2.
      CLEAR tot_a.
      CLEAR tot_c.

      LOOP AT it_bbva INTO wa_bbva2 WHERE tip_movto = '2'.
        wa_det-cod_bank = wa_cab-cod_bank.
        IF wa_bbva2-mto_movtoh = '0'.
          aux_monto = wa_bbva2-mto_movtod.
          CONCATENATE '-' aux_monto INTO wa_det-monto.
          sal_fin = sal_fin - aux_monto.
          tot_c = tot_c + aux_monto.
        ELSE.
          aux_monto = wa_bbva2-mto_movtoh.
          CONCATENATE '+' aux_monto INTO wa_det-monto.
          sal_fin = sal_fin + aux_monto.
          tot_a = tot_a + aux_monto.
        ENDIF.

        wa_det-ctbkn = wa_cab-ctbkn.
        wa_det-num_ctla = wa_cab-num_ctla.                  "04/01/2010
        CONCATENATE wa_bbva2-fec_movto+0(2) '.'
                    wa_bbva2-fec_movto+3(2) '.'
                    wa_bbva2-fec_movto+8(2)
        INTO wa_det-fec_val.                                "04/01/2010
        wa_det-prnot_num = wa_cab-moneda.
        nro_doc = wa_bbva2-nro_doc.
        wa_det-not_pay01 = nro_doc.
        wa_det-bank_postext = wa_bbva2-cod_movto.
        CONCATENATE wa_bbva2-fec_movto+0(2) '.'
                    wa_bbva2-fec_movto+3(2) '.'
                    wa_bbva2-fec_movto+8(2)
        INTO wa_det-p_date.                                 "04/01/2010
        wa_det-not_pay02 = '000'.
        wa_det-not_pay03 = wa_bbva2-desc_movto+0(27).
        wa_det-not_pay04 = wa_bbva2-desc_movto+27(27).
        APPEND wa_det TO it_det.
      ENDLOOP.
      wa_cab-tot_c = tot_c.
      wa_cab-tot_a = tot_a.
      sal_fin_n = sal_fin.
      IF sal_fin < 0.
        CONCATENATE '-' sal_fin_n INTO wa_cab-sal_fin.
      ELSE.
        CONCATENATE '+' sal_fin_n INTO wa_cab-sal_fin.
      ENDIF.
      wa_cab-nom_mov = wa_bbva2-sec_num.
      APPEND wa_cab TO it_cab.
    ENDLOOP.

*   Recorremos y grabamos en las lineas de cabecera y detalle
    LOOP AT it_cab INTO wa_cab.
      CONCATENATE
                    wa_cab-cod_bank
                    wa_cab-ctbkn
                    wa_cab-num_ctla
                    wa_cab-fec_cont
                    wa_cab-moneda
                    wa_cab-sal_ini
                    wa_cab-tot_c
                    wa_cab-tot_a
                    wa_cab-sal_fin
                    wa_cab-in_cta
                    wa_cab-xp_cta
                    wa_cab-l_ini
                    wa_cab-l_fin
                    wa_cab-nu1
                    wa_cab-nu2
                    wa_cab-nu3
                    wa_cab-nu4
                    wa_cab-nom_mov
       INTO wa_c
       SEPARATED BY ';'.
      APPEND wa_c TO ito_c.
    ENDLOOP.


    LOOP AT it_det INTO wa_det.
      CONCATENATE
                    wa_det-cod_bank
                    wa_det-ctbkn
                    wa_det-num_ctla
                    wa_det-fec_val
                    wa_det-prnot_num
                    wa_det-not_pay01
                    wa_det-bank_postext
                    wa_det-filler1
                    wa_det-cod_op
                    wa_det-numck
                    wa_det-monto
                    wa_det-descp
                    wa_det-nu1
                    wa_det-p_date
                    wa_det-nu2
                    wa_det-nu3
                    wa_det-not_pay02
                    wa_det-not_pay03
                    wa_det-not_pay04
                    wa_det-not_pay05
                    wa_det-not_pay06
                    wa_det-not_pay07
                    wa_det-not_pay08
                    wa_det-not_pay09
                    wa_det-not_pay10
                    wa_det-not_pay11
                    wa_det-not_pay12
                    wa_det-not_pay13
                    wa_det-not_pay14
                    wa_det-bus_part1
                    wa_det-bus_part2
                    wa_det-bank_part1
                    wa_det-bank_part2
                    wa_det-bus_tcode
                    wa_det-nu4
       INTO wa_d
       SEPARATED BY ';'.
      APPEND wa_d TO ito_d.
    ENDLOOP.
  ENDMETHOD.                    "M_PROCESA_BBVA

  METHOD m_procesa_corp.
    TYPES : BEGIN OF est_bcorp,
              banco(3) TYPE c,
              sucursal(3) TYPE c,
              moneda(3) TYPE c,
              ctacte(12) TYPE c,
              fechacartola(8) TYPE c,
              nrocartola(7) TYPE c,
              referencia(9) TYPE c,
              fechamov(8) TYPE c,
              codmov(2) TYPE c,
              tipmov(1) TYPE c,
              descrip(30) TYPE c,
              montocargo(15) TYPE c,
              montoabono(15) TYPE c,
              saldo(15) TYPE c,
              signo(1) TYPE c,
            END OF est_bcorp.

    DATA:   it_bcorp TYPE STANDARD TABLE OF est_bcorp,
            it_cab TYPE STANDARD TABLE OF ty_mcc,
            it_det TYPE STANDARD TABLE OF ty_mcd,
            wa_bcorp TYPE est_bcorp,
            wa_cab TYPE ty_mcc,
            wa_det TYPE ty_mcd.

    DATA:   saldo_ini(15) TYPE n,
            saldo_fin(15) TYPE n,
            total_cargo(15) TYPE n,
            total_abono(15) TYPE n.

    CONSTANTS: w_zeros VALUE '0'.

    LOOP AT it_data INTO wa_data.
      wa_bcorp-banco = wa_data+0(3).
      wa_bcorp-sucursal = wa_data+3(3).
      wa_bcorp-moneda = wa_data+6(3).
      wa_bcorp-ctacte = wa_data+9(12).
      SHIFT wa_bcorp-ctacte LEFT DELETING  LEADING w_zeros.
      wa_bcorp-fechacartola = wa_data+21(8).
      wa_bcorp-nrocartola = wa_data+29(7).
      wa_bcorp-referencia = wa_data+36(9).
      wa_bcorp-fechamov = wa_data+45(8).
      wa_bcorp-codmov = wa_data+53(2).
      wa_bcorp-tipmov = wa_data+55(1).
      wa_bcorp-descrip = wa_data+56(30).
      wa_bcorp-montocargo = wa_data+86(15).
      wa_bcorp-montoabono = wa_data+101(15).
      wa_bcorp-saldo = wa_data+116(15).
      wa_bcorp-signo = wa_data+131(1).

      APPEND wa_bcorp TO it_bcorp.
    ENDLOOP.

    CLEAR wa_bcorp.
    CLEAR wa_cab.
    CLEAR wa_det.

    wa_cab-cod_bank = '027'.                "Codigo Banco
    wa_cab-moneda = 'CLP'.                  "Moneda

    LOOP AT it_bcorp INTO wa_bcorp.

      wa_cab-ctbkn = wa_bcorp-ctacte.         "Cta.Cte
      wa_cab-num_ctla = wa_bcorp-nrocartola.  "Nro.Cartola

      wa_det-not_pay01 = wa_bcorp-referencia.  "Referencia
      wa_det-bank_postext = wa_bcorp-codmov.  "Codigo Movimiento

      CONCATENATE wa_bcorp-fechamov+4(4)'.'
                  wa_bcorp-fechamov+2(2)'.'
                  wa_bcorp-fechamov+0(2)
      INTO wa_det-p_date.                    "Fecha Movimiento

    ENDLOOP.

  ENDMETHOD.                    "M_PROCESA_CORP
*---------------------------
* PROCESA BANCO CORP BANCA
*---------------------------
  METHOD m_procesa_corp_xls.

    TYPES:     BEGIN OF ty_corp,
          fecha(50) TYPE c,
          desc(50) TYPE c,
          nro_doc(50) TYPE c,
          ofi(50) TYPE c,
          mto_cgo(50) TYPE c,
          mto_abo(50) TYPE c,
          saldo(50) TYPE c,
          ovr_row(50) TYPE c,
        END OF ty_corp.
    DATA: wa_corp TYPE ty_corp,
          it_corp TYPE STANDARD TABLE OF ty_corp,
          it_cab TYPE STANDARD TABLE OF ty_mcc,
           wa_cab TYPE ty_mcc,
           it_det TYPE STANDARD TABLE OF ty_mcd,
           wa_det TYPE ty_mcd,
           result_tab TYPE match_result_tab,
           wa_result_tab LIKE LINE OF result_tab,
           ndoc_n(8) TYPE n,
           signo TYPE sign,
           tbankl TYPE bankl,
           monto(17) TYPE n,
           suc_n(3) TYPE n,
           sal_fin TYPE p,
           sal_ini TYPE p,
           aux_n(17) TYPE n,
           tot_c(18) TYPE n,
           tot_a(18) TYPE n,
           nom_mov(5) TYPE n,
           desc TYPE char100,
           aux_cta(8) TYPE n,
           stat_sal(1) TYPE c
           .
    DATA : del TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.
    FIELD-SYMBOLS: <fs_linetab> LIKE LINE OF result_tab.

    CLEAR sal_fin.
    LOOP AT it_data INTO wa_data.
      CONDENSE wa_data.
      TRANSLATE wa_data TO UPPER CASE.
      SPLIT wa_data AT del INTO
        wa_corp-fecha
        wa_corp-desc
        wa_corp-nro_doc
        wa_corp-ofi
        wa_corp-mto_cgo
        wa_corp-mto_abo
        wa_corp-saldo
        wa_corp-ovr_row
          .
      CONDENSE wa_corp-mto_cgo NO-GAPS.
      CONDENSE wa_corp-mto_abo NO-GAPS.
      CONDENSE wa_corp-saldo NO-GAPS.
      CONCATENATE wa_corp-mto_cgo '.' INTO wa_corp-mto_cgo.
      CONCATENATE wa_corp-mto_abo '.' INTO wa_corp-mto_abo.
      CONCATENATE wa_corp-saldo '.' INTO wa_corp-saldo.

*        FIND ALL OCCURRENCES OF regex '\d,\d\d\.'
*          IN WA_CORP-MTO_CGO RESULTS result_tab.
*        IF sy-subrc eq 0.
*          CONCATENATE WA_CORP-MTO_CGO '0' INTO WA_CORP-MTO_CGO.
*        ENDIF.
*        FIND ALL OCCURRENCES OF regex '\d,\d\d\.'
*          IN WA_CORP-MTO_ABO RESULTS result_tab.
*        IF sy-subrc eq 0.
*          CONCATENATE WA_CORP-MTO_ABO '0' INTO WA_CORP-MTO_ABO.
*        ENDIF.
*        FIND ALL OCCURRENCES OF regex '\d\.\d\d\.'
*          IN WA_CORP-SALDO RESULTS result_tab.
*        IF sy-subrc eq 0.
*          CONCATENATE WA_CORP-SALDO '0' INTO WA_CORP-SALDO.
*        ENDIF.
*
*        FIND ALL OCCURRENCES OF regex '\d,\d\.'
*          IN WA_CORP-MTO_CGO RESULTS result_tab.
*        IF sy-subrc eq 0.
*          CONCATENATE WA_CORP-MTO_CGO '00' INTO WA_CORP-MTO_CGO.
*        ENDIF.
*        FIND ALL OCCURRENCES OF regex '\d,\d\.'
*          IN WA_CORP-MTO_ABO RESULTS result_tab.
*        IF sy-subrc eq 0.
*          CONCATENATE WA_CORP-MTO_ABO '00' INTO WA_CORP-MTO_ABO.
*        ENDIF.
*        FIND ALL OCCURRENCES OF regex '\d\.\d\.'
*          IN WA_CORP-SALDO RESULTS result_tab.
*        IF sy-subrc eq 0.
*          CONCATENATE WA_CORP-SALDO '00' INTO WA_CORP-SALDO.
*        ENDIF.
*
*        FIND ALL OCCURRENCES OF regex '\d,\.'
*          IN WA_CORP-MTO_CGO RESULTS result_tab.
*        IF sy-subrc eq 0.
*          CONCATENATE WA_CORP-MTO_CGO '000' INTO WA_CORP-MTO_CGO.
*        ENDIF.
*        FIND ALL OCCURRENCES OF regex '\d,\.'
*          IN WA_CORP-MTO_ABO RESULTS result_tab.
*        IF sy-subrc eq 0.
*          CONCATENATE WA_CORP-MTO_ABO '000' INTO WA_CORP-MTO_ABO.
*        ENDIF.
*        FIND ALL OCCURRENCES OF regex '\d\.\.'
*          IN WA_CORP-SALDO RESULTS result_tab.
*        IF sy-subrc eq 0.
*          CONCATENATE WA_CORP-SALDO '000' INTO WA_CORP-SALDO.
*        ENDIF.

      REPLACE ALL OCCURRENCES OF '.' IN wa_corp-mto_cgo WITH ''.
      REPLACE ALL OCCURRENCES OF ',' IN wa_corp-mto_cgo WITH ''.
      REPLACE ALL OCCURRENCES OF '.' IN wa_corp-mto_abo WITH ''.
      REPLACE ALL OCCURRENCES OF ',' IN wa_corp-mto_abo WITH ''.
      REPLACE ALL OCCURRENCES OF '.' IN wa_corp-saldo   WITH ''.
      REPLACE ALL OCCURRENCES OF ',' IN wa_corp-saldo   WITH ''.
      APPEND wa_corp TO it_corp.
    ENDLOOP.
    LOOP AT it_corp INTO wa_corp.
      CLEAR: result_tab.
      IF wa_corp-fecha CS 'CUENTA'.
        FIND ALL OCCURRENCES OF REGEX '\d+'
            IN wa_corp-fecha RESULTS result_tab.
        IF sy-subrc EQ 0.
*ReSQ: No Need Of Change Internal Table RESULT_TAB Already Sorted
          READ TABLE result_tab INDEX 1 ASSIGNING <fs_linetab>.
          aux_cta = wa_corp-fecha+<fs_linetab>-offset(<fs_linetab>-length).
          wa_cab-ctbkn = aux_cta.
          wa_cab-cod_bank = wi_bnco.
          wa_cab-moneda = 'CLP'.
        ENDIF.
      ELSEIF wa_corp-fecha CS '/'.
        ndoc_n = wa_corp-nro_doc.
        wa_det-not_pay01 = ndoc_n.
        wa_det-ctbkn = wa_cab-ctbkn.
        wa_det-cod_bank = wa_cab-cod_bank.
        CONCATENATE wa_corp-fecha+3(2) wa_corp-fecha+0(2) INTO wa_det-num_ctla.
        wa_det-prnot_num = wa_cab-moneda.

        IF wa_corp-mto_cgo IS NOT INITIAL.
          signo = '-'.
          monto = wa_corp-mto_cgo.
          tot_c = tot_c + monto.
        ELSE.
          signo = '+'.
          monto = wa_corp-mto_abo.
          tot_a = tot_a + monto.
        ENDIF.
        IF stat_sal <> 'X'.
          stat_sal = 'X'.
          IF wa_corp-saldo CS '-'.
            REPLACE ALL OCCURRENCES OF '-' IN wa_corp-saldo WITH ''.
            aux_n = wa_corp-saldo.
            CONCATENATE '-' aux_n INTO wa_cab-sal_fin.
            sal_ini = aux_n * -1.
            IF signo = '-'.
              sal_ini = sal_ini + monto.
            ELSE.
              sal_ini = sal_ini - monto.
            ENDIF.
            IF sal_ini < 0.
              sal_ini = sal_ini * -1.
              aux_n = sal_ini.
              CONCATENATE '-' aux_n INTO wa_cab-sal_ini.
            ELSE.
              aux_n = sal_ini.
              CONCATENATE '+' aux_n INTO wa_cab-sal_ini.
            ENDIF.
          ELSE.
            aux_n = wa_corp-saldo.
            CONCATENATE '+' aux_n INTO wa_cab-sal_fin.
            sal_ini = aux_n.
            IF signo = '-'.
              sal_ini = sal_ini + monto.
            ELSE.
              sal_ini = sal_ini - monto.
            ENDIF.
            IF sal_ini < 0.
              sal_ini = sal_ini * -1.
              aux_n = sal_ini.
              CONCATENATE '-' aux_n INTO wa_cab-sal_ini.
            ELSE.
              aux_n = sal_ini.
              CONCATENATE '+' aux_n INTO wa_cab-sal_ini.
            ENDIF.
          ENDIF.

        ELSE.
          IF wa_corp-saldo CS '-'.
            REPLACE ALL OCCURRENCES OF '-' IN wa_corp-saldo WITH ''.
            aux_n = wa_corp-saldo.
            CONCATENATE '-' aux_n INTO wa_cab-sal_fin.
          ELSE.
            aux_n = wa_corp-saldo.
            CONCATENATE '+' aux_n INTO wa_cab-sal_fin.
          ENDIF.
        ENDIF.
        CONCATENATE signo monto INTO wa_det-monto.
        CLEAR desc.
        desc = wa_corp-desc.
        CALL FUNCTION 'ZCOD_OPERACION'
          EXPORTING
            i_cbanco = wi_bnco
            i_cbusq  = 'C'
            i_movbco = signo
            i_desc   = desc
          IMPORTING
            e_codigo = tbankl.
        wa_det-bank_postext = tbankl.
        CONCATENATE wa_corp-fecha+0(2) '.' wa_corp-fecha+3(2) '.' wa_corp-fecha+8(2) INTO wa_det-fec_val.
        wa_det-p_date = wa_det-fec_val.
        suc_n = wa_corp-ofi+0(3).
        wa_det-not_pay02 = suc_n.
        wa_det-not_pay03 = wa_corp-desc+0(27).
        wa_det-not_pay04 = wa_corp-desc+27(23).
        APPEND wa_det TO it_det.
        ADD 1 TO nom_mov.
      ENDIF.
    ENDLOOP.
    wa_cab-num_ctla = wa_det-num_ctla.
    wa_cab-fec_cont = wa_det-fec_val.
    wa_cab-tot_c = tot_c.
    wa_cab-tot_a = tot_a.
    wa_cab-nom_mov = nom_mov.
    APPEND wa_cab TO it_cab.

    LOOP AT it_cab INTO wa_cab.
      CONCATENATE
                    wa_cab-cod_bank
                    wa_cab-ctbkn
                    wa_cab-num_ctla
                    wa_cab-fec_cont
                    wa_cab-moneda
                    wa_cab-sal_ini
                    wa_cab-tot_c
                    wa_cab-tot_a
                    wa_cab-sal_fin
                    wa_cab-in_cta
                    wa_cab-xp_cta
                    wa_cab-l_ini
                    wa_cab-l_fin
                    wa_cab-nu1
                    wa_cab-nu2
                    wa_cab-nu3
                    wa_cab-nu4
                    wa_cab-nom_mov
       INTO wa_c
       SEPARATED BY ';'.
      APPEND wa_c TO ito_c.
    ENDLOOP.

    LOOP AT it_det INTO wa_det.
      CONCATENATE
                    wa_det-cod_bank
                    wa_det-ctbkn
                    wa_det-num_ctla
                    wa_det-fec_val
                    wa_det-prnot_num
                    wa_det-not_pay01
                    wa_det-bank_postext
                    wa_det-filler1
                    wa_det-cod_op
                    wa_det-numck
                    wa_det-monto
                    wa_det-descp
                    wa_det-nu1
                    wa_det-p_date
                    wa_det-nu2
                    wa_det-nu3
                    wa_det-not_pay02
                    wa_det-not_pay03
                    wa_det-not_pay04
                    wa_det-not_pay05
                    wa_det-not_pay06
                    wa_det-not_pay07
                    wa_det-not_pay08
                    wa_det-not_pay09
                    wa_det-not_pay10
                    wa_det-not_pay11
                    wa_det-not_pay12
                    wa_det-not_pay13
                    wa_det-not_pay14
                    wa_det-bus_part1
                    wa_det-bus_part2
                    wa_det-bank_part1
                    wa_det-bank_part2
                    wa_det-bus_tcode
                    wa_det-nu4
       INTO wa_d
       SEPARATED BY ';'.
      APPEND wa_d TO ito_d.
    ENDLOOP.

  ENDMETHOD.                    "M_PROCESA_CORP_XLS

*---------------------------
* PROCESA BANCO ESTADO
*---------------------------
  METHOD m_procesa_estado.
    TYPES:     BEGIN OF ty_est,
        mesdia(100) TYPE c,
        sucur(100) TYPE c,
        nro_ope(100) TYPE c,
        desc(100) TYPE c,
        cargo(100) TYPE c,
        abono(100) TYPE c,
        saldo(100) TYPE c,
        cta_cte(100) TYPE c,
        fec_movto(100) TYPE c,
        sal_ini(100) TYPE c,
        sal_fin(100) TYPE c,
      END OF ty_est.
    DATA: ctacte(20) TYPE c,
      fechamov(12) TYPE c,
      saldoini(18) TYPE c,
      saldofin(18) TYPE c,
      num_ctla_n(7) TYPE n,
      num_ctla_i TYPE i,
      tbankl TYPE bankl,
      lbankn  TYPE  bankn,
      lbankk  TYPE  bankk,
      lchar_40 TYPE char_40,
      signo TYPE sign,
      aux_p TYPE p,
      aux_n(17) TYPE n,
      nom_mov(5) TYPE n,
      zzrefsuc TYPE zrefsuc,
      ctacte_n(6) TYPE n,
      nrodoc(8) TYPE n,
      tot_c(18) TYPE n,
      tot_a(18) TYPE n,
      it_est TYPE STANDARD TABLE OF ty_est,
      wa_est TYPE ty_est,
      it_cab TYPE STANDARD TABLE OF ty_mcc,
      wa_cab TYPE ty_mcc,
      it_det TYPE STANDARD TABLE OF ty_mcd,
      wa_det TYPE ty_mcd.

    LOOP AT it_data INTO wa_data.
      CONDENSE wa_data.
      SPLIT wa_data AT ';' INTO
                        wa_est-mesdia
                        wa_est-sucur
                        wa_est-nro_ope
                        wa_est-desc
                        wa_est-cargo
                        wa_est-abono
                        wa_est-saldo
                        wa_est-cta_cte
                        wa_est-fec_movto
                        wa_est-sal_ini
                        wa_est-sal_fin
                          .
      APPEND wa_est TO it_est.
    ENDLOOP.

*Begin of change: ReSQ Correction for DELETE on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
SORT IT_EST .
*End of change: ReSQ Correction for DELETE on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
    LOOP AT it_est INTO wa_est.
      IF wa_est-sucur EQ ' '.
        DELETE it_est INDEX sy-tabix.
        CONTINUE.
      ENDIF.
      IF wa_est-mesdia CS '/'.
        CONTINUE.
      ENDIF.
      TRANSLATE wa_est-mesdia TO UPPER CASE.
      IF wa_est-mesdia CS '-'.
        ctacte = wa_est-mesdia.
      ELSEIF wa_est-nro_ope CS '/'.
        fechamov = wa_est-nro_ope.
        IF wa_est-mesdia CO '1234567890  '.
          num_ctla_n = wa_est-mesdia.
          num_ctla_i = num_ctla_n.
        ENDIF.
      ELSEIF wa_est-mesdia CS 'ANTERIOR'.
        saldoini = wa_est-sucur.
        REPLACE ALL OCCURRENCES OF '.' IN saldoini WITH ''.
        CONDENSE saldoini NO-GAPS.
        REPLACE ALL OCCURRENCES OF '-' IN saldoini WITH ''.
        IF sy-subrc EQ 0.
          signo = '-'.
        ELSE.
          signo = '+'.
        ENDIF.
        aux_n = saldoini.
        CONCATENATE '+' aux_n INTO wa_cab-sal_ini.
        CLEAR signo.
      ELSEIF wa_est-mesdia CS 'FINAL'.
        saldofin = wa_est-sucur.
        REPLACE ALL OCCURRENCES OF '.' IN saldofin WITH ''.
        CONDENSE saldofin NO-GAPS.
        REPLACE ALL OCCURRENCES OF '-' IN saldofin WITH ''.
        IF sy-subrc EQ 0.
          signo = '-'.
        ELSE.
          signo = '+'.
        ENDIF.
        aux_n = saldofin.
        CONCATENATE signo aux_n INTO wa_cab-sal_fin.
        CLEAR signo.
      ENDIF.
*ReSQ: No Need Of Change Internal Table IT_EST Already Sorted
      DELETE it_est INDEX sy-tabix.
    ENDLOOP.

    wa_cab-cod_bank = wi_bnco.
    ctacte_n = ctacte.
    wa_cab-ctbkn = ctacte_n.
    num_ctla_i = num_ctla_n.
    wa_cab-num_ctla = num_ctla_i.
    CONCATENATE fechamov+0(2) '.' fechamov+3(2) '.' fechamov+8(2) INTO wa_cab-fec_cont.
    wa_cab-moneda = 'CLP'.

    CLEAR nom_mov.
*    DETALLE BANCO ESTADO
*    --------------------------
*    --------------------------
    LOOP AT it_est INTO wa_est.
      ADD 1 TO nom_mov.
      wa_det-cod_bank = wa_cab-cod_bank.
      wa_det-ctbkn = wa_cab-ctbkn.
      wa_det-num_ctla = wa_cab-num_ctla.
      CONCATENATE wa_est-mesdia+0(2) '.' wa_est-mesdia+3(2) '.' fechamov+8(2) INTO wa_det-fec_val.
      wa_det-prnot_num = wa_cab-moneda.
      nrodoc = wa_est-nro_ope.
      wa_det-not_pay01 = nrodoc.
      wa_det-numck = wa_det-not_pay01.
      IF wa_est-cargo NE ' '.
        aux_n = wa_est-cargo.
        signo = '-'.
        tot_c = tot_c + aux_n.
      ELSE.
        aux_n = wa_est-abono.
        signo = '+'.
        tot_a = tot_a + aux_n.
      ENDIF.
      CONCATENATE signo aux_n INTO wa_det-monto.
      CONDENSE wa_est-desc.
      CALL FUNCTION 'ZCOD_OPERACION'
        EXPORTING
          i_cbanco = wi_bnco
          i_cbusq  = 'C'
          i_movbco = signo
          i_desc   = wa_est-desc
        IMPORTING
          e_codigo = tbankl.
      wa_det-bank_postext = tbankl.
      wa_det-p_date = wa_det-fec_val.
      CONDENSE wa_est-sucur.
      lbankn = wa_det-ctbkn.
      lbankk = wa_det-cod_bank.
      lchar_40 = wa_est-sucur.
      CALL FUNCTION 'ZGETSUCUR001'
        EXPORTING
          zzcod_unidad = '0'
          zdesc        = lchar_40
          bankn        = lbankn
          bankk        = lbankk
        IMPORTING
          zzrefsuc     = zzrefsuc.
      wa_det-not_pay02 = zzrefsuc.
      wa_det-not_pay03 = wa_est-desc+0(27).
      wa_det-not_pay04 = wa_est-desc+27(27).
      APPEND wa_det TO it_det.
    ENDLOOP.
    wa_cab-tot_c = tot_c.
    wa_cab-tot_a = tot_a.
    wa_cab-nom_mov = nom_mov.
    APPEND wa_cab TO it_cab.

*BREAK-POINT.
*EXIT.

    LOOP AT it_cab INTO wa_cab.
      CONCATENATE
                    wa_cab-cod_bank
                    wa_cab-ctbkn
                    wa_cab-num_ctla
                    wa_cab-fec_cont
                    wa_cab-moneda
                    wa_cab-sal_ini
                    wa_cab-tot_c
                    wa_cab-tot_a
                    wa_cab-sal_fin
                    wa_cab-in_cta
                    wa_cab-xp_cta
                    wa_cab-l_ini
                    wa_cab-l_fin
                    wa_cab-nu1
                    wa_cab-nu2
                    wa_cab-nu3
                    wa_cab-nu4
                    wa_cab-nom_mov
       INTO wa_c
       SEPARATED BY ';'.
      APPEND wa_c TO ito_c.
    ENDLOOP.

    LOOP AT it_det INTO wa_det.
      CONCATENATE
                    wa_det-cod_bank
                    wa_det-ctbkn
                    wa_det-num_ctla
                    wa_det-fec_val
                    wa_det-prnot_num
                    wa_det-not_pay01
                    wa_det-bank_postext
                    wa_det-filler1
                    wa_det-cod_op
                    wa_det-numck
                    wa_det-monto
                    wa_det-descp
                    wa_det-nu1
                    wa_det-p_date
                    wa_det-nu2
                    wa_det-nu3
                    wa_det-not_pay02
                    wa_det-not_pay03
                    wa_det-not_pay04
                    wa_det-not_pay05
                    wa_det-not_pay06
                    wa_det-not_pay07
                    wa_det-not_pay08
                    wa_det-not_pay09
                    wa_det-not_pay10
                    wa_det-not_pay11
                    wa_det-not_pay12
                    wa_det-not_pay13
                    wa_det-not_pay14
                    wa_det-bus_part1
                    wa_det-bus_part2
                    wa_det-bank_part1
                    wa_det-bank_part2
                    wa_det-bus_tcode
                    wa_det-nu4
       INTO wa_d
       SEPARATED BY ';'.
      APPEND wa_d TO ito_d.
    ENDLOOP.
  ENDMETHOD.                    "M_PROCESA_ESTADO


  METHOD m_procesa_bice.
    TYPES:     BEGIN OF ty_bice,
          fecha(100) TYPE c,
          docto(100) TYPE c,
          desc(200) TYPE c,
          cargo(100) TYPE c,
          abono(100) TYPE c,
          saldo(100) TYPE c,
          sobgiro(100) TYPE c,
          limit(100) TYPE c,
      END OF ty_bice.

    DATA:  it_bice TYPE STANDARD TABLE OF ty_bice,
            wa_bice TYPE ty_bice,
            it_cab TYPE STANDARD TABLE OF ty_mcc,
            wa_cab TYPE ty_mcc,
            it_det TYPE STANDARD TABLE OF ty_mcd,
            wa_det TYPE ty_mcd,
            ctacte_n(8) TYPE n,
            anomov(4) TYPE n,
            fechamov(5) TYPE c,
            tot_c(18) TYPE n,
            tot_a(18) TYPE n,
            aux_monto(17) TYPE n,
            signo TYPE sign,
            tbankl TYPE bankl,
            contador TYPE i,
            nrodoc(8) TYPE n,
            nom_mov(5) TYPE n
                  .

*  BANCO = WI_BNCO.
    LOOP AT it_data INTO wa_data.
      CONDENSE wa_data.
      TRANSLATE wa_data TO UPPER CASE.
      SPLIT wa_data AT ';' INTO
                        wa_bice-fecha
                        wa_bice-docto
                        wa_bice-desc
                        wa_bice-cargo
                        wa_bice-abono
                        wa_bice-saldo
                        wa_bice-sobgiro
                        wa_bice-limit
                        .
      APPEND wa_bice TO it_bice.
    ENDLOOP.
    LOOP AT it_bice INTO wa_bice WHERE fecha NS '-'.
      IF wa_bice-saldo CS '-'.
        REPLACE ALL OCCURRENCES OF '-' IN wa_bice-saldo WITH ''.
        ctacte_n = wa_bice-saldo.
      ENDIF.
    ENDLOOP.
    wa_cab-cod_bank = wi_bnco.
    wa_cab-ctbkn = ctacte_n.
    wa_cab-moneda = 'CLP'.
    CLEAR nom_mov.
    LOOP AT it_bice INTO wa_bice WHERE fecha CO '1234567890.- '.
      CHECK wa_bice-fecha IS NOT INITIAL.
      CHECK wa_bice-desc NS 'SALDO INICIAL'.
      IF wa_bice-cargo IS NOT INITIAL.
        ADD 1 TO nom_mov.
        IF wa_bice-fecha NE '-'.
          fechamov = wa_bice-fecha.
        ENDIF.
        wa_det-cod_bank = wa_cab-cod_bank.
        wa_det-ctbkn = wa_cab-ctbkn.
        CONCATENATE fechamov+0(2) '.' fechamov+3(2) '.' anomov+2(2) INTO wa_det-fec_val.
        CONCATENATE fechamov+3(2) fechamov+0(2) INTO wa_det-num_ctla.
        wa_det-p_date = wa_det-fec_val.
        wa_det-prnot_num = wa_cab-moneda.
        nrodoc = wa_bice-docto.
        wa_det-not_pay01 = nrodoc.
        wa_det-numck = wa_det-not_pay01.

        CLEAR aux_monto.
        IF wa_bice-cargo NE '0'.
          aux_monto = wa_bice-cargo.
          signo = '-'.
          tot_c = tot_c + aux_monto.
        ELSE.
          aux_monto = wa_bice-abono.
          signo = '+'.
          tot_a = tot_a + aux_monto.
        ENDIF.
        CONCATENATE signo aux_monto INTO wa_det-monto.
        CONDENSE wa_bice-desc.

        CALL FUNCTION 'ZCOD_OPERACION'
          EXPORTING
            i_cbanco = wi_bnco
            i_cbusq  = 'C'
            i_movbco = signo
            i_desc   = wa_bice-desc+0(100)
          IMPORTING
            e_codigo = tbankl.
        wa_det-bank_postext = tbankl.
        wa_det-not_pay02 = '000'.
        wa_det-not_pay03 = wa_bice-desc+0(27).
        wa_det-not_pay04 = wa_bice-desc+27(27).
        APPEND wa_det TO it_det.
      ELSE.
        REPLACE ALL OCCURRENCES OF '-' IN wa_bice-fecha WITH ''.
        IF sy-subrc EQ 0.
          aux_monto = wa_bice-fecha.
          CONCATENATE '-' aux_monto INTO wa_cab-sal_ini.
        ELSE.
          aux_monto = wa_bice-fecha.
          CONCATENATE '+' aux_monto INTO wa_cab-sal_ini.
        ENDIF.

        REPLACE ALL OCCURRENCES OF '-' IN wa_bice-desc WITH ''.
        IF sy-subrc EQ 0.
          aux_monto = wa_bice-desc.
          CONCATENATE '-' aux_monto INTO wa_cab-sal_fin.
        ELSE.
          aux_monto = wa_bice-desc.
          CONCATENATE '+' aux_monto INTO wa_cab-sal_fin.
        ENDIF.

        contador = STRLEN( wa_bice-saldo ).
        ADD -4 TO contador.
        anomov = wa_bice-saldo+contador(4).
      ENDIF.
    ENDLOOP.

    CONCATENATE fechamov+3(2) fechamov+0(2) INTO wa_cab-num_ctla.
    CONCATENATE fechamov+0(2) '.' fechamov+3(2) '.' anomov+2(2) INTO wa_cab-fec_cont.
    wa_cab-tot_c = tot_c.
    wa_cab-tot_a = tot_a.
    wa_cab-nom_mov = nom_mov.
    APPEND wa_cab TO it_cab.

    LOOP AT it_cab INTO wa_cab.
      CONCATENATE
                    wa_cab-cod_bank
                    wa_cab-ctbkn
                    wa_cab-num_ctla
                    wa_cab-fec_cont
                    wa_cab-moneda
                    wa_cab-sal_ini
                    wa_cab-tot_c
                    wa_cab-tot_a
                    wa_cab-sal_fin
                    wa_cab-in_cta
                    wa_cab-xp_cta
                    wa_cab-l_ini
                    wa_cab-l_fin
                    wa_cab-nu1
                    wa_cab-nu2
                    wa_cab-nu3
                    wa_cab-nu4
                    wa_cab-nom_mov
       INTO wa_c
       SEPARATED BY ';'.
      APPEND wa_c TO ito_c.
    ENDLOOP.

    LOOP AT it_det INTO wa_det.
      CONCATENATE
                    wa_det-cod_bank
                    wa_det-ctbkn
                    wa_det-num_ctla
                    wa_det-fec_val
                    wa_det-prnot_num
                    wa_det-not_pay01
                    wa_det-bank_postext
                    wa_det-filler1
                    wa_det-cod_op
                    wa_det-numck
                    wa_det-monto
                    wa_det-descp
                    wa_det-nu1
                    wa_det-p_date
                    wa_det-nu2
                    wa_det-nu3
                    wa_det-not_pay02
                    wa_det-not_pay03
                    wa_det-not_pay04
                    wa_det-not_pay05
                    wa_det-not_pay06
                    wa_det-not_pay07
                    wa_det-not_pay08
                    wa_det-not_pay09
                    wa_det-not_pay10
                    wa_det-not_pay11
                    wa_det-not_pay12
                    wa_det-not_pay13
                    wa_det-not_pay14
                    wa_det-bus_part1
                    wa_det-bus_part2
                    wa_det-bank_part1
                    wa_det-bank_part2
                    wa_det-bus_tcode
                    wa_det-nu4
       INTO wa_d
       SEPARATED BY ';'.
      APPEND wa_d TO ito_d.
    ENDLOOP.
  ENDMETHOD.                    "M_PROCESA_BICE

  METHOD m_procesa_bice_htm.
    TYPES:     BEGIN OF ty_bice,
          fecha(100) TYPE c,
          invalid1(100) TYPE c,
          invalid2(100) TYPE c,
          invalid3(100) TYPE c,
          docto(100) TYPE c,
          codigo(50) TYPE c,
          desc(200) TYPE c,
          cargo(100) TYPE c,
          abono(100) TYPE c,
          saldo(100) TYPE c,
          sobgiro(100) TYPE c,
          limit(100) TYPE c,
      END OF ty_bice.

    DATA:  it_bice TYPE STANDARD TABLE OF ty_bice,
            wa_bice TYPE ty_bice,
            it_cab TYPE STANDARD TABLE OF ty_mcc,
            wa_cab TYPE ty_mcc,
            it_det TYPE STANDARD TABLE OF ty_mcd,
            wa_det TYPE ty_mcd,
            ctacte_n(8) TYPE n,
*            ANOMOV(4) TYPE N,
            fechamov(10) TYPE c,
            tot_c(18) TYPE n,
            tot_a(18) TYPE n,
            aux_monto(17) TYPE n,
            signo TYPE sign,
            tbankl TYPE bankl,
            contador TYPE i,
            nrodoc(8) TYPE n,
            nom_mov(5) TYPE n
                  .

*  BANCO = WI_BNCO.
    LOOP AT it_data INTO wa_data.
      CONDENSE wa_data.
      TRANSLATE wa_data TO UPPER CASE.
      SPLIT wa_data AT ';' INTO
                        wa_bice-fecha
                        wa_bice-invalid1
                        wa_bice-invalid2
                        wa_bice-invalid3
                        wa_bice-docto
                        wa_bice-codigo
                        wa_bice-desc
                        wa_bice-cargo
                        wa_bice-abono
                        wa_bice-saldo
                        wa_bice-sobgiro
                        wa_bice-limit
                        .
      APPEND wa_bice TO it_bice.
    ENDLOOP.
    CLEAR nom_mov.
    LOOP AT it_bice INTO wa_bice WHERE fecha IS NOT INITIAL.
      CHECK wa_bice-fecha CO '1234567890.-/  '.
      REPLACE ALL OCCURRENCES OF '.' IN wa_bice-cargo WITH ''.
      REPLACE ALL OCCURRENCES OF ' ' IN wa_bice-cargo WITH ''.
      REPLACE ALL OCCURRENCES OF '.' IN wa_bice-abono WITH ''.
      REPLACE ALL OCCURRENCES OF ' ' IN wa_bice-abono WITH ''.
      IF wa_bice-cargo IS NOT INITIAL OR wa_bice-abono IS NOT INITIAL.
        ADD 1 TO nom_mov.
        IF wa_bice-fecha NE '-'.
          fechamov = wa_bice-fecha.
        ENDIF.
        wa_det-cod_bank = wa_cab-cod_bank.
        wa_det-ctbkn = wa_cab-ctbkn.
        CONCATENATE fechamov+0(2) '.' fechamov+3(2) '.' fechamov+8(2) INTO wa_det-fec_val.
        CONCATENATE fechamov+3(2) fechamov+0(2) INTO wa_det-num_ctla.
        wa_det-p_date = wa_det-fec_val.
        wa_det-prnot_num = wa_cab-moneda.
        nrodoc = wa_bice-docto.
        wa_det-not_pay01 = nrodoc.
        wa_det-numck = wa_det-not_pay01.

        CLEAR aux_monto.
        IF wa_bice-cargo IS NOT INITIAL.
          aux_monto = wa_bice-cargo.
          signo = '-'.
          tot_c = tot_c + aux_monto.
        ELSE.
          aux_monto = wa_bice-abono.
          signo = '+'.
          tot_a = tot_a + aux_monto.
        ENDIF.
        CONCATENATE signo aux_monto INTO wa_det-monto.
        CONDENSE wa_bice-desc.

        CALL FUNCTION 'ZCOD_OPERACION'
          EXPORTING
            i_cbanco = wi_bnco
            i_cbusq  = 'C'
            i_movbco = signo
            i_desc   = wa_bice-desc+0(100)
          IMPORTING
            e_codigo = tbankl.
        wa_det-bank_postext = tbankl.
        wa_det-not_pay02 = '000'.
        wa_det-not_pay03 = wa_bice-desc+0(27).
        wa_det-not_pay04 = wa_bice-desc+27(27).
        APPEND wa_det TO it_det.
      ELSE.
        REPLACE ALL OCCURRENCES OF '.' IN wa_bice-fecha WITH ''.
        IF sy-subrc NE 0.
          IF wa_bice-fecha CS '-' AND wa_bice-invalid2 IS NOT INITIAL.
            REPLACE ALL OCCURRENCES OF '-' IN wa_bice-fecha WITH ''.
            ctacte_n = wa_bice-fecha.
            wa_cab-cod_bank = wi_bnco.
            wa_cab-ctbkn = ctacte_n.
            wa_cab-moneda = 'CLP'.
          ENDIF.
        ELSE.
          REPLACE ALL OCCURRENCES OF '-' IN wa_bice-fecha WITH ''.
          IF sy-subrc EQ 0.
            aux_monto = wa_bice-fecha.
            CONCATENATE '-' aux_monto INTO wa_cab-sal_ini.
          ELSE.
            aux_monto = wa_bice-fecha.
            CONCATENATE '+' aux_monto INTO wa_cab-sal_ini.
          ENDIF.

          REPLACE ALL OCCURRENCES OF '-' IN wa_bice-invalid3 WITH ''.
          IF sy-subrc EQ 0.
            aux_monto = wa_bice-invalid3.
            CONCATENATE '-' aux_monto INTO wa_cab-sal_fin.
          ELSE.
            aux_monto = wa_bice-invalid3.
            CONCATENATE '+' aux_monto INTO wa_cab-sal_fin.
          ENDIF.
        ENDIF.
*        CONTADOR = STRLEN( WA_BICE-SALDO ).
*        ADD -4 TO CONTADOR.
*        ANOMOV = WA_BICE-SALDO+CONTADOR(4).
      ENDIF.
    ENDLOOP.

    CONCATENATE fechamov+3(2) fechamov+0(2) INTO wa_cab-num_ctla.
    CONCATENATE fechamov+0(2) '.' fechamov+3(2) '.' fechamov+8(2) INTO wa_cab-fec_cont.
    wa_cab-tot_c = tot_c.
    wa_cab-tot_a = tot_a.
    wa_cab-nom_mov = nom_mov.
    APPEND wa_cab TO it_cab.
    LOOP AT it_cab INTO wa_cab.
      CONCATENATE
                    wa_cab-cod_bank
                    wa_cab-ctbkn
                    wa_cab-num_ctla
                    wa_cab-fec_cont
                    wa_cab-moneda
                    wa_cab-sal_ini
                    wa_cab-tot_c
                    wa_cab-tot_a
                    wa_cab-sal_fin
                    wa_cab-in_cta
                    wa_cab-xp_cta
                    wa_cab-l_ini
                    wa_cab-l_fin
                    wa_cab-nu1
                    wa_cab-nu2
                    wa_cab-nu3
                    wa_cab-nu4
                    wa_cab-nom_mov
       INTO wa_c
       SEPARATED BY ';'.
      APPEND wa_c TO ito_c.
    ENDLOOP.

    LOOP AT it_det INTO wa_det.
      CONCATENATE
                    wa_det-cod_bank
                    wa_det-ctbkn
                    wa_det-num_ctla
                    wa_det-fec_val
                    wa_det-prnot_num
                    wa_det-not_pay01
                    wa_det-bank_postext
                    wa_det-filler1
                    wa_det-cod_op
                    wa_det-numck
                    wa_det-monto
                    wa_det-descp
                    wa_det-nu1
                    wa_det-p_date
                    wa_det-nu2
                    wa_det-nu3
                    wa_det-not_pay02
                    wa_det-not_pay03
                    wa_det-not_pay04
                    wa_det-not_pay05
                    wa_det-not_pay06
                    wa_det-not_pay07
                    wa_det-not_pay08
                    wa_det-not_pay09
                    wa_det-not_pay10
                    wa_det-not_pay11
                    wa_det-not_pay12
                    wa_det-not_pay13
                    wa_det-not_pay14
                    wa_det-bus_part1
                    wa_det-bus_part2
                    wa_det-bank_part1
                    wa_det-bank_part2
                    wa_det-bus_tcode
                    wa_det-nu4
       INTO wa_d
       SEPARATED BY ';'.
      APPEND wa_d TO ito_d.
    ENDLOOP.
  ENDMETHOD.                    "M_PROCESA_BICE_HTM


*---------------------------
* PROCESA SCOTIA BANK
*---------------------------
  METHOD m_procesa_scotia.
    CONSTANTS: w_zeros VALUE '0'.
    TYPES:     BEGIN OF ty_scoc,
        fecha(100) TYPE c,
        desc(100) TYPE c,
        nrodoc(100) TYPE c,
        cargo(100) TYPE c,
        abono(100) TYPE c,
        saldo(100) TYPE c,
      END OF ty_scoc.
    DATA:
          contador(5) TYPE n,
          desc(100) TYPE c,
          it_cab TYPE STANDARD TABLE OF ty_mcc,
          it_det TYPE STANDARD TABLE OF ty_mcd,
          nrodoc(8) TYPE n.
    DATA: wa_scoc TYPE ty_scoc,
          it_scoc TYPE STANDARD TABLE OF ty_scoc,
          wa_cabec TYPE ty_mcc,
          wa_detalle TYPE ty_mcd,
*          W_LINES LIKE SY-TABIX ,
          tot_c(18) TYPE n,
          tot_a(18) TYPE n,
          sal_fin	TYPE p,
          sal_ini	TYPE p,
          sal_fin_n(17)	TYPE n,
          sal_ini_n(17)	TYPE n,
          aux_monto(17) TYPE n,
          aux_num(100) TYPE n,
          signo(1) TYPE c,
          moff TYPE i,
          mlen TYPE i,
          pos TYPE i,
          tbankl TYPE bankl,
          result_tab TYPE match_result_tab,
          wa_result_tab LIKE LINE OF result_tab
          .
    FIELD-SYMBOLS: <fs_linetab> LIKE LINE OF result_tab.

*ReSQ: No Need Of Change Internal Table IT_DATA Already Sorted
    READ TABLE it_data INDEX 1 INTO wa_data.
*ReSQ: No Need Of Change Internal Table IT_DATA Already Sorted
    DELETE it_data INDEX 1.

    SPLIT wa_data AT char_f INTO TABLE ex_data.
    w_index = 1.
    LOOP AT ex_data INTO wa_data.
      INSERT wa_data INTO it_data INDEX sy-tabix.
    ENDLOOP.
    LOOP AT it_data INTO wa_data.
      TRANSLATE wa_data TO UPPER CASE.
      IF wa_data CS 'SALDO' AND wa_data CS 'ABONOS'.
        pos = sy-fdpos.
        ADD 6 TO pos.
        IF wa_data CS ','.
          mlen = 1000 - pos - 1.
          SPLIT wa_data+pos(mlen) AT ';' INTO wa_scoc-fecha wa_scoc-desc wa_scoc-nrodoc wa_scoc-cargo wa_scoc-abono wa_scoc-saldo.
          FIND ALL OCCURRENCES OF REGEX '\d+-\d+-\d+'
           IN wa_data RESULTS result_tab.
          IF sy-subrc EQ 0.
*ReSQ: No Need Of Change Internal Table RESULT_TAB Already Sorted
            READ TABLE result_tab INDEX 1 ASSIGNING <fs_linetab>.
            wa_cabec-ctbkn = wa_data+<fs_linetab>-offset(<fs_linetab>-length).
            SHIFT wa_cabec-ctbkn LEFT DELETING LEADING '0'.
            REPLACE ALL OCCURRENCES OF '-' IN wa_cabec-ctbkn WITH ''.
          ENDIF.
          FIND ALL OCCURRENCES OF '/'
                IN wa_data RESULTS result_tab.
          IF sy-subrc EQ 0.
*ReSQ: No Need Of Change Internal Table RESULT_TAB Already Sorted
            READ TABLE result_tab INDEX 3 ASSIGNING <fs_linetab>.
            moff = <fs_linetab>-offset - 2.
            desc = wa_data+moff(10).
            CONCATENATE desc+0(2) '.' desc+3(2) '.' desc+8(2) INTO wa_cabec-fec_cont.
            CONCATENATE desc+3(2) desc+0(2) INTO wa_cabec-num_ctla.
          ENDIF.
          wa_cabec-moneda = 'CLP'.
          wa_cabec-cod_bank = '014'.
        ENDIF.
      ELSE.
        SPLIT wa_data AT ';' INTO wa_scoc-fecha wa_scoc-desc wa_scoc-nrodoc wa_scoc-cargo wa_scoc-abono wa_scoc-saldo.
      ENDIF.
      APPEND wa_scoc TO it_scoc.
    ENDLOOP.

    CLEAR contador.
    CLEAR tot_c.
    CLEAR tot_a.
* Procesamos tabla de Scotia Bank
    LOOP AT it_scoc INTO wa_scoc.
      CONDENSE wa_scoc-fecha.
      CONDENSE wa_scoc-desc.
      CONDENSE wa_scoc-nrodoc.
      IF wa_scoc-fecha CO '1234567890 '.
        aux_num = wa_scoc-fecha.
        IF aux_num > 0.
          wa_detalle-cod_bank = wa_cabec-cod_bank.
          wa_detalle-ctbkn = wa_cabec-ctbkn.
          SHIFT wa_detalle-ctbkn LEFT DELETING LEADING '0'.
          wa_detalle-num_ctla = wa_cabec-num_ctla.
          CONCATENATE wa_scoc-fecha+0(2) '.' wa_scoc-fecha+2(2) '.' wa_scoc-fecha+6(2) INTO wa_detalle-fec_val.
          wa_detalle-prnot_num = 'CLP'.
          nrodoc = wa_scoc-nrodoc.
          wa_detalle-not_pay01 = nrodoc.

          FIND ',' IN wa_scoc-saldo MATCH OFFSET moff
                                    MATCH LENGTH mlen.
          moff = moff - 1.
          IF wa_scoc-saldo+0(1) EQ '+'.
            sal_fin = wa_scoc-saldo+1(moff).
          ELSE.
            sal_fin = wa_scoc-saldo+1(moff) * -1.
          ENDIF.

          FIND ',' IN wa_scoc-cargo MATCH OFFSET moff
                                    MATCH LENGTH mlen.
          IF sy-subrc EQ 0.
            signo = '-'.
            aux_monto = wa_scoc-cargo+0(moff).
            tot_c = tot_c + aux_monto.
            IF sal_ini EQ 0.
              sal_ini = sal_fin + aux_monto.
            ENDIF.
          ENDIF.

          FIND ',' IN wa_scoc-abono MATCH OFFSET moff
                                    MATCH LENGTH mlen.
          IF sy-subrc EQ 0.
            signo = '+'.
            aux_monto = wa_scoc-abono+0(moff).
            tot_a = tot_a + aux_monto.
            IF sal_ini EQ 0.
              sal_ini = sal_fin - aux_monto.
            ENDIF.
          ENDIF.

          CONCATENATE signo aux_monto INTO wa_detalle-monto.
          CONCATENATE wa_scoc-fecha+0(2) '.' wa_scoc-fecha+2(2) '.' wa_scoc-fecha+6(2) INTO wa_detalle-p_date.
          CALL FUNCTION 'ZCOD_OPERACION'
            EXPORTING
              i_cbanco = '014'
              i_cbusq  = 'C'
              i_movbco = signo
              i_desc   = wa_scoc-desc
            IMPORTING
              e_codigo = tbankl.
          wa_detalle-bank_postext = tbankl.
          contador = contador + 1.
          wa_detalle-not_pay02 = '000'.
          wa_detalle-not_pay03 = wa_scoc-desc+0(27).
          wa_detalle-not_pay04 = wa_scoc-desc+27(27).
          APPEND wa_detalle TO it_det.
        ELSEIF wa_scoc-desc CS 'CUENTA'.
          FIND ALL OCCURRENCES OF ':'
          IN wa_scoc-desc RESULTS result_tab.
          IF sy-subrc EQ 0.
*ReSQ: No Need Of Change Internal Table RESULT_TAB Already Sorted
            READ TABLE result_tab INDEX 1 ASSIGNING <fs_linetab>.
            moff = <fs_linetab>-offset + 1.
            mlen = 100 - moff.
            desc = wa_scoc-desc+moff(mlen).
            CONDENSE desc.
            REPLACE ALL OCCURRENCES OF '-' IN desc WITH ''.
            wa_cabec-ctbkn = desc.
            SHIFT wa_cabec-ctbkn LEFT DELETING LEADING '0'.
          ENDIF.
        ELSEIF wa_scoc-desc CS 'HASTA'.
          FIND ALL OCCURRENCES OF '/'
            IN wa_scoc-desc RESULTS result_tab.
          IF sy-subrc EQ 0.
*ReSQ: No Need Of Change Internal Table RESULT_TAB Already Sorted
            READ TABLE result_tab INDEX 1 ASSIGNING <fs_linetab>.
            moff = <fs_linetab>-offset - 2.
            desc = wa_scoc-desc+moff(10).
            CONCATENATE desc+0(2) '.' desc+3(2) '.' desc+8(2) INTO wa_cabec-fec_cont.
            CONCATENATE desc+3(2) desc+0(2) INTO wa_cabec-num_ctla.
            wa_cabec-moneda = 'CLP'.
            wa_cabec-cod_bank = '014'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    wa_cabec-tot_a = tot_a.
    wa_cabec-tot_c = tot_c.
    IF sal_fin < 0.
      sal_fin_n = sal_fin.
      CONCATENATE '-' sal_fin_n INTO wa_cabec-sal_fin.
    ELSE.
      sal_fin_n = sal_fin.
      CONCATENATE '+' sal_fin_n INTO wa_cabec-sal_fin.
    ENDIF.
    IF sal_ini < 0.
      sal_ini_n = sal_ini.
      CONCATENATE '-' sal_ini_n INTO wa_cabec-sal_ini.
    ELSE.
      sal_ini_n = sal_ini.
      CONCATENATE '+' sal_ini_n INTO wa_cabec-sal_ini.
    ENDIF.

    wa_cabec-nom_mov = contador.
    APPEND wa_cabec TO it_cab.
*Recorremos y grabamos en las lineas de cabecera y detalle
    LOOP AT it_cab INTO wa_cabec.
      CONCATENATE
                    wa_cabec-cod_bank
                    wa_cabec-ctbkn
                    wa_cabec-num_ctla
                    wa_cabec-fec_cont
                    wa_cabec-moneda
                    wa_cabec-sal_ini
                    wa_cabec-tot_c
                    wa_cabec-tot_a
                    wa_cabec-sal_fin
                    wa_cabec-in_cta
                    wa_cabec-xp_cta
                    wa_cabec-l_ini
                    wa_cabec-l_fin
                    wa_cabec-nu1
                    wa_cabec-nu2
                    wa_cabec-nu3
                    wa_cabec-nu4
                    wa_cabec-nom_mov
       INTO wa_c
       SEPARATED BY ';'.
      APPEND wa_c TO ito_c.
    ENDLOOP.

    LOOP AT it_det INTO wa_detalle.
      CONCATENATE
                    wa_detalle-cod_bank
                    wa_detalle-ctbkn
                    wa_detalle-num_ctla
                    wa_detalle-fec_val
                    wa_detalle-prnot_num
                    wa_detalle-not_pay01
                    wa_detalle-bank_postext
                    wa_detalle-filler1
                    wa_detalle-cod_op
                    wa_detalle-numck
                    wa_detalle-monto
                    wa_detalle-descp
                    wa_detalle-nu1
                    wa_detalle-p_date
                    wa_detalle-nu2
                    wa_detalle-nu3
                    wa_detalle-not_pay02
                    wa_detalle-not_pay03
                    wa_detalle-not_pay04
                    wa_detalle-not_pay05
                    wa_detalle-not_pay06
                    wa_detalle-not_pay07
                    wa_detalle-not_pay08
                    wa_detalle-not_pay09
                    wa_detalle-not_pay10
                    wa_detalle-not_pay11
                    wa_detalle-not_pay12
                    wa_detalle-not_pay13
                    wa_detalle-not_pay14
                    wa_detalle-bus_part1
                    wa_detalle-bus_part2
                    wa_detalle-bank_part1
                    wa_detalle-bank_part2
                    wa_detalle-bus_tcode
                    wa_detalle-nu4
       INTO wa_d
       SEPARATED BY ';'.
      APPEND wa_d TO ito_d.
    ENDLOOP.

  ENDMETHOD.                    "M_PROCESA_SCOTIA

  METHOD m_procesa_all_xls.
    TYPES:   BEGIN OF ty_all,
                    cod_bank(12) TYPE c,
                    ctbkn(24) TYPE c,
                    num_ctla(4) TYPE c,
                    moneda(3) TYPE c,
                    fec_cont(10) TYPE c,
                    fec_val(10) TYPE c,
                    secuencia(5) TYPE c,
                    nro_doc(27) TYPE c,
                    cod_ope(27) TYPE c,
                    sal_pre(18) TYPE c,
                    monto(18) TYPE c,
                    sucursal(3) TYPE c,
                    desc(50) TYPE c,
                    over_i(50) TYPE c,
              END OF ty_all.
    DATA: wa_cab TYPE ty_mcc,
          wa_det TYPE ty_mcd,
          it_cab TYPE STANDARD TABLE OF ty_mcc,
          it_det TYPE STANDARD TABLE OF ty_mcd,
          it_all TYPE STANDARD TABLE OF ty_all,
          wa_all TYPE ty_all,
          w_lines TYPE i,
          tot_c(18) TYPE n,
          tot_a(18) TYPE n,
          sal_ini_n(17) TYPE n,
          sal_fin_n(17) TYPE n,
          sal_fin_p TYPE p,
          aux_p TYPE p,
          aux_monto(17) TYPE n,
          n_mov(5) TYPE n,
          ctla(4) TYPE n,
          nro_doc(8) TYPE n,
          signo TYPE sign,
          sucur(3) TYPE n,
          cod_bank(3) TYPE n
          .

    LOOP AT it_data INTO wa_data.
      CLEAR wa_all.
      SPLIT wa_data AT ';' INTO
                wa_all-cod_bank
                wa_all-ctbkn
                wa_all-num_ctla
                wa_all-moneda
                wa_all-fec_cont
                wa_all-fec_val
                wa_all-secuencia
                wa_all-nro_doc
                wa_all-cod_ope
                wa_all-sal_pre
                wa_all-monto
                wa_all-sucursal
                wa_all-desc
                wa_all-over_i.
      APPEND wa_all TO it_all.
    ENDLOOP.
    DESCRIBE TABLE it_all LINES w_lines.

    LOOP AT it_all INTO wa_all.
      CLEAR wa_det.
      cod_bank = wa_all-cod_bank.
      ctla = wa_all-num_ctla.
      nro_doc = wa_all-nro_doc.
      CONDENSE wa_all-monto NO-GAPS.
      REPLACE ALL OCCURRENCES OF '-' IN wa_all-monto WITH ''.
      IF sy-subrc EQ 0.
        tot_c = tot_c + wa_all-monto.
        signo = '-'.
      ELSE.
        tot_a = tot_a + wa_all-monto.
        signo = '+'.
      ENDIF.
      aux_monto = wa_all-monto.
      CONDENSE wa_all-desc.
      sucur = wa_all-sucursal.

      wa_det-cod_bank = cod_bank.
      wa_det-ctbkn = wa_all-ctbkn.
      wa_det-num_ctla = ctla.
      CONCATENATE
        wa_all-fec_val+0(2) '.'
        wa_all-fec_val+3(2) '.'
        wa_all-fec_val+8(2)
      INTO wa_det-fec_val.
      wa_det-prnot_num = wa_all-moneda.
      wa_det-not_pay01 = nro_doc.
      wa_det-bank_postext = wa_all-cod_ope.
      CONCATENATE signo aux_monto INTO wa_det-monto.
      wa_det-p_date = wa_det-fec_val.
      wa_det-not_pay02 = sucur.
      wa_det-not_pay03 = wa_all-desc+0(27).
      wa_det-not_pay04 = wa_all-desc+27(23).
      APPEND wa_det TO it_det.

      IF sy-tabix = 1.
        REPLACE ALL OCCURRENCES OF '-' IN wa_all-sal_pre WITH ''.
        IF sy-subrc EQ 0.
          sal_ini_n = wa_all-sal_pre.
          CONCATENATE '-' sal_ini_n INTO wa_cab-sal_ini.
        ELSE.
          sal_ini_n = wa_all-sal_pre.
          CONCATENATE '+' sal_ini_n INTO wa_cab-sal_ini.
        ENDIF.

      ELSEIF sy-tabix EQ w_lines.
        n_mov = wa_all-secuencia.
        REPLACE ALL OCCURRENCES OF '-' IN wa_all-sal_pre WITH ''.
        IF sy-subrc EQ 0.
          IF signo = '-'.
            sal_fin_p = - ( wa_all-sal_pre + wa_all-monto ).
          ELSE.
            sal_fin_p = - ( wa_all-sal_pre - wa_all-monto ).
          ENDIF.
        ELSE.
          IF signo = '-'.
            sal_fin_p = wa_all-sal_pre - wa_all-monto.
          ELSE.
            sal_fin_p = wa_all-sal_pre + wa_all-monto.
          ENDIF.
        ENDIF.
        IF sal_fin_p < 0.
          signo = '-'.
          sal_fin_p  = sal_fin_p * -1.
          sal_fin_n = sal_fin_p.
        ELSE.
          signo = '+'.
          sal_fin_n = sal_fin_p.
        ENDIF.
        CONCATENATE signo sal_fin_n INTO wa_cab-sal_fin.

        wa_cab-cod_bank = wa_det-cod_bank.
        wa_cab-ctbkn = wa_det-ctbkn.
        wa_cab-num_ctla = wa_det-num_ctla.
        wa_cab-moneda = wa_det-prnot_num.
        CONCATENATE
          wa_all-fec_cont+0(2) '.'
          wa_all-fec_cont+3(2) '.'
          wa_all-fec_cont+8(2)
        INTO wa_cab-fec_cont.
        wa_cab-moneda = wa_det-prnot_num.
        wa_cab-tot_c = tot_c.
        wa_cab-tot_a = tot_a.
        wa_cab-nom_mov = n_mov.
        APPEND wa_cab TO it_cab.
      ENDIF.
    ENDLOOP.

    LOOP AT it_cab INTO wa_cab.
      CONCATENATE
                    wa_cab-cod_bank
                    wa_cab-ctbkn
                    wa_cab-num_ctla
                    wa_cab-fec_cont
                    wa_cab-moneda
                    wa_cab-sal_ini
                    wa_cab-tot_c
                    wa_cab-tot_a
                    wa_cab-sal_fin
                    wa_cab-in_cta
                    wa_cab-xp_cta
                    wa_cab-l_ini
                    wa_cab-l_fin
                    wa_cab-nu1
                    wa_cab-nu2
                    wa_cab-nu3
                    wa_cab-nu4
                    wa_cab-nom_mov
       INTO wa_c
       SEPARATED BY ';'.
      APPEND wa_c TO ito_c.
    ENDLOOP.

    LOOP AT it_det INTO wa_det.
      CONCATENATE
                    wa_det-cod_bank
                    wa_det-ctbkn
                    wa_det-num_ctla
                    wa_det-fec_val
                    wa_det-prnot_num
                    wa_det-not_pay01
                    wa_det-bank_postext
                    wa_det-filler1
                    wa_det-cod_op
                    wa_det-numck
                    wa_det-monto
                    wa_det-descp
                    wa_det-nu1
                    wa_det-p_date
                    wa_det-nu2
                    wa_det-nu3
                    wa_det-not_pay02
                    wa_det-not_pay03
                    wa_det-not_pay04
                    wa_det-not_pay05
                    wa_det-not_pay06
                    wa_det-not_pay07
                    wa_det-not_pay08
                    wa_det-not_pay09
                    wa_det-not_pay10
                    wa_det-not_pay11
                    wa_det-not_pay12
                    wa_det-not_pay13
                    wa_det-not_pay14
                    wa_det-bus_part1
                    wa_det-bus_part2
                    wa_det-bank_part1
                    wa_det-bank_part2
                    wa_det-bus_tcode
                    wa_det-nu4
       INTO wa_d
       SEPARATED BY ';'.
      APPEND wa_d TO ito_d.
    ENDLOOP.
  ENDMETHOD.                    "M_PROCESA_ALL_XLS

  METHOD m_dwn_file.
    DATA v_filename TYPE string.

    CLEAR v_filename.
    v_filename = p_file2.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
*     bin_filesize              =
        filename                  = v_filename
        filetype                  = 'ASC'
*     append                    = space
     write_field_separator     = ';'
*     header                    = '00'
*        TRUNC_TRAILING_BLANKS     = 'X'
*     write_lf                  = 'x'
*     col_select                = space
*     col_select_mask           = space
*     dat_mode                  = space
*     confirm_overwrite         = space
      no_auth_check             = 'X'      " space
*     codepage                  = space
      ignore_cerr               = abap_true
*     replacement               = '#'
*     write_bom                 = space
*     trunc_trailing_blanks_eol = 'x'
*     wk1_n_format              = space
*     wk1_n_size                = space
*     wk1_t_format              = space
*     wk1_t_size                = space
*   IMPORTING
*     filelength                =
      CHANGING
        data_tab                  = iti_c
      EXCEPTIONS
        file_write_error          = 1
        no_batch                  = 2
        gui_refuse_filetransfer   = 3
        invalid_type              = 4
        no_authority              = 5
        unknown_error             = 6
        header_not_allowed        = 7
        separator_not_allowed     = 8
        filesize_not_allowed      = 9
        header_too_long           = 10
        dp_error_create           = 11
        dp_error_send             = 12
        dp_error_write            = 13
        unknown_dp_error          = 14
        access_denied             = 15
        dp_out_of_memory          = 16
        disk_full                 = 17
        dp_timeout                = 18
        file_not_found            = 19
        dataprovider_exception    = 20
        control_flush_error       = 21
        not_supported_by_gui      = 22
        error_no_gui              = 23
        OTHERS                    = 24.
    IF sy-subrc <> 0.
      MESSAGE ID '00' TYPE 'I' NUMBER '398' WITH text-m02.
      LEAVE TO CURRENT TRANSACTION.
    ENDIF.
*
    CLEAR v_filename.
    v_filename = p_file3.
*
    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
*     bin_filesize              =
        filename                  = v_filename
        filetype                  = 'ASC'
*        APPEND                    = ';'
        write_field_separator     = ';'
*     header                    = '00'
*     trunc_trailing_blanks     = space
*     write_lf                  = 'x'
*     col_select                = space
     col_select_mask           = ';'
*     dat_mode                  = space
*     confirm_overwrite         = space
*     no_auth_check             = space
*     codepage                  = space
*     ignore_cerr               = abap_true
*     replacement               = '#'
*     write_bom                 = space
*     trunc_trailing_blanks_eol = 'x'
*     wk1_n_format              = space
*     wk1_n_size                = space
*     wk1_t_format              = space
*     wk1_t_size                = space
*   IMPORTING
*     filelength                =
      CHANGING
        data_tab                  = iti_d
      EXCEPTIONS
        file_write_error          = 1
        no_batch                  = 2
        gui_refuse_filetransfer   = 3
        invalid_type              = 4
        no_authority              = 5
        unknown_error             = 6
        header_not_allowed        = 7
        separator_not_allowed     = 8
        filesize_not_allowed      = 9
        header_too_long           = 10
        dp_error_create           = 11
        dp_error_send             = 12
        dp_error_write            = 13
        unknown_dp_error          = 14
        access_denied             = 15
        dp_out_of_memory          = 16
        disk_full                 = 17
        dp_timeout                = 18
        file_not_found            = 19
        dataprovider_exception    = 20
        control_flush_error       = 21
        not_supported_by_gui      = 22
        error_no_gui              = 23
        OTHERS                    = 24.
    IF sy-subrc <> 0.
      MESSAGE ID '00' TYPE 'I' NUMBER '398' WITH text-m02.
      LEAVE TO CURRENT TRANSACTION.
    ELSE.
      MESSAGE ID '00' TYPE 'S' NUMBER '398' WITH text-m01.
    ENDIF.

  ENDMETHOD.                    "M_DWN_FILE

  METHOD m_find_file.
* * variables auxiliares
    DATA v_rc TYPE i.
    DATA itab_files TYPE TABLE OF file_table.
    DATA wa_files TYPE file_table.
    DATA v_title TYPE string.

    CLEAR v_title.
    v_title = text-t01.

    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        window_title          = v_title
     default_extension        = 'TXT'
     default_filename         = '.txt'
*     file_filter             =
*     with_encoding           = '1'
     initial_directory        = 'C:\'
*     multiselection          =
      CHANGING
        file_table            = itab_files
        rc                    = v_rc
*     user_action             =
*     file_encoding           = w_encoding
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
SORT ITAB_FILES .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
      READ TABLE itab_files INTO wa_files INDEX 1.
      p_file1 = wa_files.
*      P_FILE2 = P_FILE1.
    ENDIF.
  ENDMETHOD.                    "M_find_file

ENDCLASS.                    "c_contador IMPLEMENTATION
