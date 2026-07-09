
*&---------------------------------------------------------------------*
*&      Form  VALIDA_DEUDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDA_DEUDOR       TABLES  RETURN STRUCTURE BAPIRET2
                        USING    P_TI_DEUDOR STRUCTURE ZDEUDOR
                        CHANGING P_T_ERROR..
* Validacion Grupo de ctas. Deudor (KTOKD) y ID de cliente (KUNNR)
  DATA: P_KTOKD LIKE T077D-KTOKD,
        P_NUMKR LIKE NRIV-NRRANGENR,
        P_EXTERNIND LIKE NRIV-EXTERNIND.
  DATA: E_VALID(1) TYPE C.

  DATA: O_T077D  LIKE  T077D OCCURS 0 WITH HEADER LINE.
  DATA: INTERVAL LIKE  NRIV OCCURS 0 WITH HEADER LINE.
  DATA:  XKNA1 LIKE KNA1.

* Validacion si es un cleinte Nuevo o una ampliación de Sociedad FI para el Deudor.
  IF P_TI_DEUDOR-KUNNR NE SPACE.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = P_TI_DEUDOR-KUNNR
      IMPORTING
        OUTPUT = P_TI_DEUDOR-KUNNR.



    CALL FUNCTION 'READ_KNA1'
      EXPORTING
        XKUNNR         = P_TI_DEUDOR-KUNNR
      IMPORTING
        XKNA1          = XKNA1
      EXCEPTIONS
        KEY_INCOMPLETE = 1
        NOT_AUTHORIZED = 2
        NOT_FOUND      = 3
        OTHERS         = 4.
    IF SY-SUBRC = 0.
      P_TI_DEUDOR-KTOKD = XKNA1-KTOKD.
      P_TI_DEUDOR-LAND1 = XKNA1-LAND1.
      P_TI_DEUDOR-STCD1 = XKNA1-STCD1.
    ENDIF.
  ELSE.
    DATA A_KNA1 LIKE KNA1.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM KNA1 INTO A_KNA1
*    WHERE STCD1 = P_TI_DEUDOR-STCD1.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM KNA1 INTO A_KNA1
    WHERE STCD1 = P_TI_DEUDOR-STCD1 ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF SY-SUBRC EQ 0.
      P_T_ERROR = 4.
      RETURN-TYPE              = 'E'.
      RETURN-ID                = '01'.
      RETURN-MESSAGE_V1        = 'La El Rut ya Existe'.
      APPEND RETURN.
    ENDIF.
  ENDIF.

* Valida el Grupo de Cuenta.
  IF XKNA1-KTOKD EQ SPACE.
    CALL FUNCTION 'T077D_SINGLE_READ'
      EXPORTING
        I_KTOKD         = P_TI_DEUDOR-KTOKD
      IMPORTING
        O_T077D         = O_T077D
      EXCEPTIONS
        NOT_FOUND       = 1
        PARAMETER_ERROR = 2
        OTHERS          = 3.
    IF SY-SUBRC =  0.
      CALL FUNCTION 'NUMBER_GET_INFO'
        EXPORTING
          NR_RANGE_NR        = O_T077D-NUMKR
          OBJECT             = 'DEBITOR'
        IMPORTING
          INTERVAL           = INTERVAL
        EXCEPTIONS
          INTERVAL_NOT_FOUND = 1
          OBJECT_NOT_FOUND   = 2
          OTHERS             = 3.
      IF SY-SUBRC EQ 0.
        IF INTERVAL-EXTERNIND EQ SPACE.
          IF   P_TI_DEUDOR-KUNNR NE SPACE.
            P_T_ERROR = 4.
            RETURN-TYPE              = 'E'.
            RETURN-ID                = '01'.
            RETURN-MESSAGE_V1        = 'La asignación  del Deudor'.
            RETURN-MESSAGE_V2        = ' debe ser interna'.
            APPEND RETURN.
          ENDIF.
        ELSE.
          IF INTERVAL-EXTERNIND EQ 'X'.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                INPUT  = P_TI_DEUDOR-KUNNR
              IMPORTING
                OUTPUT = P_TI_DEUDOR-KUNNR.


            CALL FUNCTION 'SD_CHECK_CUSTOMER_NUMBER_RANGE'
              EXPORTING
                I_ACCOUNT_GROUP       = P_TI_DEUDOR-KTOKD
                I_NUMBER_RANGE_OBJECT = 'DEBITOR'
              CHANGING
                IO_CUSTOMER           = P_TI_DEUDOR-KUNNR
              EXCEPTIONS
                PARAMETER_ERROR       = 1
                INTERNAL_ERROR        = 2
                OTHERS                = 3.
            IF SY-SUBRC = 0.
              CALL FUNCTION 'BPAR_P_FI_CUSTOMER_CHECK'
                EXPORTING
                  CUSTOMER = P_TI_DEUDOR-KUNNR
                EXCEPTIONS
                  CUSTOMER = 1
                  OTHERS   = 2.
              IF SY-SUBRC <> 0.
                P_T_ERROR = 4.
                RETURN-TYPE              = 'E'.
                RETURN-ID                = '02'.
                RETURN-MESSAGE_V1        = 'El Numero de deudor '.
                RETURN-MESSAGE_V2        = P_TI_DEUDOR-KUNNR.
                RETURN-MESSAGE_V3        = 'ya Existe'.
                APPEND RETURN.
              ENDIF.
            ELSE.
              P_T_ERROR = 4.
* error grupo de cuentas no existe.
              RETURN-TYPE              = 'E'.
              RETURN-ID                = '03'.
              RETURN-MESSAGE_V1        = 'El Grupo de Cuenteas '.
              RETURN-MESSAGE_V2        = P_TI_DEUDOR-KTOKD.
              RETURN-MESSAGE_V3        = ' NO Existe'.
              APPEND RETURN.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        P_T_ERROR = 4.
        RETURN-TYPE              = 'E'.
        RETURN-ID                = '01'.
        RETURN-MESSAGE_V1        = 'Rangos de Numero'.
        RETURN-MESSAGE_V2        = 'no existe'.
        APPEND RETURN.
      ENDIF.
    ELSE.
      P_T_ERROR = 4.
      RETURN-TYPE              = 'E'.
      RETURN-ID                = '01'.
      RETURN-MESSAGE_V1        = 'Grupo de Cuenta'.
      RETURN-MESSAGE_V2        = 'no existe'.
      APPEND RETURN.
    ENDIF.
  ENDIF.

* Validación Sociedad (BUKRS)
  CALL FUNCTION 'VALIDATE_COMPANY_CODE'
    EXPORTING
      I_COMPANY  = P_TI_DEUDOR-BUKRS
    IMPORTING
      E_VALID    = E_VALID
    EXCEPTIONS
      INCOMPLETE = 1
      OTHERS     = 2.

  IF  E_VALID EQ 0.
    P_T_ERROR = 4.
    RETURN-TYPE              = 'E'.
    RETURN-ID                = '04'.
    RETURN-MESSAGE_V1        = 'La Sociedad FI'.
    RETURN-MESSAGE_V2        = P_TI_DEUDOR-BUKRS.
    RETURN-MESSAGE_V3        = ' NO Existe'.
    APPEND RETURN.
  ENDIF.

  DATA:
  KONTENPLAN_WA LIKE  SKA1 OCCURS 0 WITH HEADER LINE,
  SACHKONTO_WA LIKE  SKB1 OCCURS 0 WITH HEADER LINE,
  ET_DUPLICATE_CUSTOMERS TYPE CMDS_CHECKDATA_CUSTOMER_T.


* Validación Cuenta de mayor (AKONT)
  CALL FUNCTION 'READ_HAUPTBUCH'
    EXPORTING
      BUCHUNGSKREIS        = P_TI_DEUDOR-BUKRS
      SACHKONTO            = P_TI_DEUDOR-AKONT
      AUTH_CHECK_ACTIVITY  = ' '
    IMPORTING
      KONTENPLAN_WA        = KONTENPLAN_WA
      SACHKONTO_WA         = SACHKONTO_WA
    EXCEPTIONS
      KONTENPLAN_NOT_FOUND = 1
      SACHKONTO_NOT_FOUND  = 2
      NOT_AUTHORIZED       = 3
      OTHERS               = 4.
  IF SY-SUBRC = 0.
    READ TABLE SACHKONTO_WA INDEX 1.
    IF SY-SUBRC EQ 0.
      IF SACHKONTO_WA-MITKZ NE  'D'.
        P_T_ERROR = 4.
        RETURN-TYPE              = 'E'.
        RETURN-ID                = '05'.
        RETURN-MESSAGE_V1        = 'La cuenta de Mayor'.
        RETURN-MESSAGE_V2        =  P_TI_DEUDOR-AKONT.
        RETURN-MESSAGE_V3        = ' no asociada'.
        APPEND RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

* Validación Tratamiento
  IF P_TI_DEUDOR-TITLE NE SPACE.
    CALL FUNCTION 'ADDR_TSAD3_READ'
      EXPORTING
        TITLE_KEY           = P_TI_DEUDOR-TITLE
      EXCEPTIONS
        TITLE_KEY_NOT_FOUND = 1
        OTHERS              = 2.
    IF SY-SUBRC <> 0.
      P_T_ERROR = 4.
      RETURN-TYPE              = 'E'.
      RETURN-ID                = '06'.
      RETURN-MESSAGE_V1        = 'El Tratamiento '.
      RETURN-MESSAGE_V2        =  P_TI_DEUDOR-TITLE.
      RETURN-MESSAGE_V3        = ' NO existe'.
      APPEND RETURN.
    ENDIF.
  ENDIF.

* Validación codigo de Pais
  CALL FUNCTION 'FSBP_CHECK_COUNTRY'
    EXPORTING
      COUNTRY = P_TI_DEUDOR-LAND1
    EXCEPTIONS
      COUNTRY = 1
      OTHERS  = 2.
  IF SY-SUBRC <> 0.
    P_T_ERROR = 4.
    RETURN-TYPE              = 'E'.
    RETURN-ID                = '07'.
    RETURN-MESSAGE_V1        = 'El Pais ingresado'.
    RETURN-MESSAGE_V2        =   P_TI_DEUDOR-LAND1.
    RETURN-MESSAGE_V3        = ' NO existe'.
    APPEND RETURN.

  ENDIF.



* Validación de Region Ingresada.
  IF P_TI_DEUDOR-REGIO NE SPACE.
    CALL FUNCTION 'BPAR_C_REGIONALCODE_CHECK'
      EXPORTING
        COUNTRY      = P_TI_DEUDOR-LAND1
        REGIONALCODE = P_TI_DEUDOR-REGIO
      EXCEPTIONS
        REGIONALCODE = 1
        OTHERS       = 2.
    IF SY-SUBRC <> 0.
      P_T_ERROR = 4.
      RETURN-TYPE              = 'E'.
      RETURN-ID                = '08'.
      RETURN-MESSAGE_V1        = 'La Region ingresada'.
      RETURN-MESSAGE_V2        =  P_TI_DEUDOR-REGIO.
      RETURN-MESSAGE_V3        = ' NO existe'.
      APPEND RETURN.
    ENDIF.
  ENDIF.

* Valida  que el  Acreedor  no exista
  IF P_TI_DEUDOR-LIFNR NE SPACE.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = P_TI_DEUDOR-LIFNR
      IMPORTING
        OUTPUT = P_TI_DEUDOR-LIFNR.



    CALL FUNCTION 'FI_VENDOR_CHECK'
      EXPORTING
        I_BUKRS = P_TI_DEUDOR-BUKRS
        I_LIFNR = P_TI_DEUDOR-LIFNR
      EXCEPTIONS
        VENDOR  = 1
        OTHERS  = 2.
    IF SY-SUBRC <> 0.
      P_T_ERROR = 4.
      RETURN-TYPE              = 'E'.
      RETURN-ID                = '09'.
      RETURN-MESSAGE_V1        = 'El Numero de Acreedor'.
      RETURN-MESSAGE_V2        =  P_TI_DEUDOR-LIFNR.
      RETURN-MESSAGE_V3        = ' Ya existe'.
      APPEND RETURN.
    ENDIF.
  ENDIF.


* Valida que el Rut Ingreado sea Valido
  CALL FUNCTION 'TAX_NUMBER_CHECK'
    EXPORTING
      COUNTRY         = P_TI_DEUDOR-LAND1
      TAX_CODE_1      = P_TI_DEUDOR-STCD1
    EXCEPTIONS
      NOT_VALID       = 1
      DIFFERENT_FPRCD = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
    P_T_ERROR = 4.
    RETURN-TYPE              = 'E'.
    RETURN-ID                = '10'.
    RETURN-MESSAGE_V1        = 'El R.U.T Ingresado'.
    RETURN-MESSAGE_V2        =  P_TI_DEUDOR-STCD1.
    RETURN-MESSAGE_V3        = ' No es Valido'.
    APPEND RETURN.
  ELSE.
    DATA:  T_KNA1 TYPE  KNA1.
    T_KNA1-MANDT = SY-MANDT.
    T_KNA1-LAND1 = P_TI_DEUDOR-LAND1.
    T_KNA1-STCD1 = P_TI_DEUDOR-STCD1.
    T_KNA1-KUNNR = P_TI_DEUDOR-KUNNR.

    DATA: XFELD TYPE XFELD VALUE 'X'.
* Valida que no exista el rut
    CALL FUNCTION 'TAXNUMBER_CHECK_DUPL_CUSTOMER'
      EXPORTING
        CUSTOMER               = T_KNA1
        IV_NO_DIALOG           = XFELD
      IMPORTING
        ET_DUPLICATE_CUSTOMERS = ET_DUPLICATE_CUSTOMERS.
    DATA: CONT_REG TYPE I.
    DESCRIBE TABLE ET_DUPLICATE_CUSTOMERS LINES  CONT_REG.
    IF CONT_REG > 0.
      P_T_ERROR = 4.
      P_T_ERROR = 4.
      RETURN-TYPE              = 'E'.
      RETURN-ID                = '11'.
      RETURN-MESSAGE_V1        = 'El R.U.T Ingresado'.
      RETURN-MESSAGE_V2        =  P_TI_DEUDOR-STCD1.
      RETURN-MESSAGE_V3        = ' ya esta registrado'.
      APPEND RETURN.
    ENDIF.
  ENDIF.

*Valida Ramo
  CALL FUNCTION 'T016_SINGLE_READ'
    EXPORTING
      I_BRSCH         = P_TI_DEUDOR-BRSCH
*   IMPORTING
*     O_T016          =
   EXCEPTIONS
     NOT_FOUND       = 1
     OTHERS          = 2.
  IF SY-SUBRC <> 0.
    P_T_ERROR = 4.
    RETURN-TYPE              = 'E'.
    RETURN-ID                = '13'.
    RETURN-MESSAGE_V1        = 'El indicador de Ramo'.
    RETURN-MESSAGE_V2        =  P_TI_DEUDOR-BRSCH.
    RETURN-MESSAGE_V3        = 'No existe'.
    APPEND RETURN.
  ENDIF.


* Valida Clave para clasificar por números de asignación
  CALL FUNCTION 'TZUN_SINGLE_READ'
    EXPORTING
      I_ZUAWA   = P_TI_DEUDOR-ZUAWA
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
    P_T_ERROR = 4.
    RETURN-TYPE              = 'E'.
    RETURN-ID                = '12'.
    RETURN-MESSAGE_V1        = 'La condicion de Clacificación'.
    RETURN-MESSAGE_V2        =  P_TI_DEUDOR-ZUAWA.
    RETURN-MESSAGE_V3        = 'No existe o no es Valida'.
    APPEND RETURN.
  ENDIF.


* Valida Grupo de tesorería
  CALL FUNCTION 'CASH_FORECAST_CHECK_LEVEL_GRP'
    EXPORTING
      FDGRP         = P_TI_DEUDOR-FDGRV
      KOART         = 'D'
    EXCEPTIONS
      GROUP_INVALID = 1
      LEVEL_INVALID = 2
      ORIGN_INVALID = 3
      OTHERS        = 4.
  IF SY-SUBRC <> 0.
    P_T_ERROR = 4.
    RETURN-TYPE             = 'E'.
    RETURN-ID                = '14'.
    RETURN-MESSAGE_V1        = 'El Grupo de tesorería'.
    RETURN-MESSAGE_V2        =  P_TI_DEUDOR-FDGRV.
    RETURN-MESSAGE_V3        = 'No existe o no es Valida'.
    APPEND RETURN.
  ENDIF.

* Valida La Condición de pago
  CALL FUNCTION 'FI_CHECK_ZTERM'
    EXPORTING
      I_ZTERM       = P_TI_DEUDOR-ZTERM1
    EXCEPTIONS
      INVALID_ZTERM = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    P_T_ERROR = 4.
    RETURN-TYPE             = 'E'.
    RETURN-ID                = '15'.
    RETURN-MESSAGE_V1        = 'La Condición de pago'.
    RETURN-MESSAGE_V2        =  P_TI_DEUDOR-ZTERM1.
    RETURN-MESSAGE_V3        = 'No existe o no es Valida'.
    APPEND RETURN.
  ENDIF.
ENDFORM.                    " VALIDA_DEUDOR
*&---------------------------------------------------------------------*
*&      Form  CREA_DEUDORES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_DEUDOR  text
*      -->P_ENDIF  text
*----------------------------------------------------------------------*
FORM CREA_DEUDORES TABLES  RETURN STRUCTURE BAPIRET2
                   USING   P_TI_DEUDOR STRUCTURE ZDEUDOR.

  DATA:  I_KNA1  LIKE  KNA1 OCCURS 0 WITH HEADER LINE.
  DATA:  I_KNB1 LIKE  KNB1 OCCURS 0 WITH HEADER LINE.
  DATA:  I_BAPIADDR2 LIKE  BAPIADDR2 OCCURS 0 WITH HEADER LINE.
  DATA:  P_KNA1   LIKE KNA1.
  DATA:  P_ADRC   LIKE ADRC.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = P_TI_DEUDOR-KUNNR
    IMPORTING
      OUTPUT = P_TI_DEUDOR-KUNNR.


  CALL FUNCTION 'READ_KNA1'
    EXPORTING
      XKUNNR         = P_TI_DEUDOR-KUNNR
    IMPORTING
      XKNA1          = P_KNA1
    EXCEPTIONS
      KEY_INCOMPLETE = 1
      NOT_AUTHORIZED = 2
      NOT_FOUND      = 3
      OTHERS         = 4.
  IF SY-SUBRC EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * INTO P_ADRC
*      FROM ADRC
*WHERE ADDRNUMBER EQ P_KNA1-ADRNR.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  INTO P_ADRC
      FROM ADRC
WHERE ADDRNUMBER EQ P_KNA1-ADRNR ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF SY-SUBRC EQ 0.
      I_BAPIADDR2-TITLE_P        =   P_ADRC-TITLE.
      I_BAPIADDR2-FIRSTNAME      =   P_ADRC-NAME1.
      I_BAPIADDR2-LASTNAME       =   P_ADRC-NAME2.
      I_BAPIADDR2-SORT1_P        =   P_ADRC-SORT1.
      I_BAPIADDR2-SORT2_P        =   P_ADRC-SORT2.
      I_BAPIADDR2-STREET         =   P_ADRC-STREET.
      I_BAPIADDR2-HOUSE_NO       =   P_ADRC-HOUSE_NUM1.
      I_BAPIADDR2-HOUSE_NO2      =   P_ADRC-HOUSE_NUM2.
      I_BAPIADDR2-POSTL_COD2     =   P_ADRC-POSTALAREA.
      I_BAPIADDR2-CITY           =   P_ADRC-CITY1.
      I_BAPIADDR2-DISTRICT       =   P_ADRC-CITY2.
      I_BAPIADDR2-COUNTRY        =   P_ADRC-COUNTRY.
      I_BAPIADDR2-REGION         =   P_ADRC-REGION.
      I_BAPIADDR2-TEL1_NUMBR     =   P_ADRC-TEL_NUMBER.
      I_BAPIADDR2-TEL1_EXT       =   P_ADRC-TEL_EXTENS.
      I_BAPIADDR2-FAX_NUMBER     =   P_ADRC-FAX_NUMBER.
      I_BAPIADDR2-FAX_EXTENS     =   P_ADRC-FAX_EXTENS.
      I_BAPIADDR2-TIME_ZONE     = 'CHILE'.

    ENDIF.
  ENDIF.

* Genera Estructuras para ejecutar función Standar de Creación de Deudores.
  IF P_TI_DEUDOR-TITLE NE SPACE.
    I_BAPIADDR2-TITLE_P        =   P_TI_DEUDOR-TITLE.
  ENDIF.
  IF P_TI_DEUDOR-NAME1 NE SPACE.
    I_BAPIADDR2-FIRSTNAME      =   P_TI_DEUDOR-NAME1.
  ENDIF.
  IF P_TI_DEUDOR-NAME2 NE SPACE.
    I_BAPIADDR2-LASTNAME       =   P_TI_DEUDOR-NAME2.
  ENDIF.
  IF P_TI_DEUDOR-SORT1 NE SPACE.
    I_BAPIADDR2-SORT1_P        =   P_TI_DEUDOR-SORT1.
  ENDIF.
  IF P_TI_DEUDOR-SORT2 NE SPACE.
    I_BAPIADDR2-SORT2_P        =   P_TI_DEUDOR-SORT2.
  ENDIF.
  IF P_TI_DEUDOR-STREET NE SPACE.
    I_BAPIADDR2-STREET         =   P_TI_DEUDOR-STREET.
  ENDIF.
  IF P_TI_DEUDOR-HOUSE_NUM1 NE SPACE.
    I_BAPIADDR2-HOUSE_NO       =   P_TI_DEUDOR-HOUSE_NUM1.
  ENDIF.
  IF P_TI_DEUDOR-HOUSE_NUM2 NE SPACE.
    I_BAPIADDR2-HOUSE_NO2      =   P_TI_DEUDOR-HOUSE_NUM2.
  ENDIF.
  IF P_TI_DEUDOR-PSTLZ NE SPACE.
    I_BAPIADDR2-POSTL_COD2     =   P_TI_DEUDOR-PSTLZ.
  ENDIF.
  IF P_TI_DEUDOR-ORT01 NE SPACE.
    I_BAPIADDR2-CITY           =   P_TI_DEUDOR-ORT01.
  ENDIF.
  IF P_TI_DEUDOR-ORT02 NE SPACE.
    I_BAPIADDR2-DISTRICT       =   P_TI_DEUDOR-ORT02.
  ENDIF.
  IF P_TI_DEUDOR-LAND1 NE SPACE.
    I_BAPIADDR2-COUNTRY        =   P_TI_DEUDOR-LAND1.
  ENDIF.
  IF  P_TI_DEUDOR-REGIO NE SPACE.
    I_BAPIADDR2-REGION         =   P_TI_DEUDOR-REGIO.
  ENDIF.
  IF P_TI_DEUDOR-TEL_NUMBER NE SPACE.
    I_BAPIADDR2-TEL1_NUMBR     =   P_TI_DEUDOR-TEL_NUMBER.
  ENDIF.
  IF  P_TI_DEUDOR-TEL1_EXT NE SPACE.
    I_BAPIADDR2-TEL1_EXT       =   P_TI_DEUDOR-TEL1_EXT.
  ENDIF.
  IF P_TI_DEUDOR-TELFAX NE SPACE.
    I_BAPIADDR2-FAX_NUMBER     =   P_TI_DEUDOR-TELFAX.
  ENDIF.
  IF P_TI_DEUDOR-FAX_EXTENS NE SPACE.
    I_BAPIADDR2-FAX_EXTENS     =   P_TI_DEUDOR-FAX_EXTENS.
  ENDIF.
  IF P_TI_DEUDOR-SMTP_ADDR NE SPACE.
    I_BAPIADDR2-E_MAIL         =   P_TI_DEUDOR-SMTP_ADDR.
  ENDIF.
* se agrega ES  09-04-2015
  I_BAPIADDR2-LANGU_P        =   'S'.
  I_BAPIADDR2-TIME_ZONE     = 'CHILE'.
  APPEND I_BAPIADDR2.

  I_KNB1-KUNNR = P_TI_DEUDOR-KUNNR.
  I_KNB1-BUKRS = P_TI_DEUDOR-BUKRS.
  I_KNB1-AKONT = P_TI_DEUDOR-AKONT.
  I_KNB1-ZUAWA = P_TI_DEUDOR-ZUAWA.
  I_KNB1-FDGRV = 'E5'.   "P_TI_DEUDOR-FDGRV.  HCD 02-03-2016
  I_KNB1-ZTERM = 'ZD01'. "P_TI_DEUDOR-ZTERM1. HCD 02-03-2016
* HCD 08032018
  I_KNB1-ERDAT = SY-DATUM.
  I_KNB1-ERNAM = 'PISUPER'.

  APPEND I_KNB1.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = P_TI_DEUDOR-LIFNR
    IMPORTING
      OUTPUT = P_TI_DEUDOR-LIFNR.


  I_KNA1-MANDT = SY-MANDT.
  I_KNA1-KUNNR = P_TI_DEUDOR-KUNNR.
  I_KNA1-KTOKD = P_TI_DEUDOR-KTOKD.
  I_KNA1-LIFNR = P_TI_DEUDOR-LIFNR.
  I_KNA1-STCD1 = P_TI_DEUDOR-STCD1.
  I_KNA1-BRSCH = P_TI_DEUDOR-BRSCH.
* se agrega ES  09-04-2015
  I_KNA1-SPRAS = 'S'.
* HCD 08032018
   I_KNA1-ERDAT = SY-DATUM.
   I_KNA1-ERNAM = 'PISUPER'.

  APPEND I_KNA1.


  DATA: E_KUNNR TYPE KUNNR.


  CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
    EXPORTING
      I_KNA1                  = I_KNA1
      I_KNB1                  = I_KNB1
      I_BAPIADDR2             = I_BAPIADDR2
    IMPORTING
      E_KUNNR                 = E_KUNNR
    EXCEPTIONS
      CLIENT_ERROR            = 1
      KNA1_INCOMPLETE         = 2
      KNB1_INCOMPLETE         = 3
      KNB5_INCOMPLETE         = 4
      KNVV_INCOMPLETE         = 5
      KUNNR_NOT_UNIQUE        = 6
      SALES_AREA_NOT_UNIQUE   = 7
      SALES_AREA_NOT_VALID    = 8
      INSERT_UPDATE_CONFLICT  = 9
      NUMBER_ASSIGNMENT_ERROR = 10
      NUMBER_NOT_IN_RANGE     = 11
      NUMBER_RANGE_NOT_EXTERN = 12
      NUMBER_RANGE_NOT_INTERN = 13
      ACCOUNT_GROUP_NOT_VALID = 14
      PARNR_INVALID           = 15
      BANK_ADDRESS_INVALID    = 16
      TAX_DATA_NOT_VALID      = 17
      NO_AUTHORITY            = 18
      COMPANY_CODE_NOT_UNIQUE = 19
      DUNNING_DATA_NOT_VALID  = 20
      KNB1_REFERENCE_INVALID  = 21
      CAM_ERROR               = 22
      OTHERS                  = 23.
  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    RETURN-TYPE             = 'S'.
    RETURN-ID                = '21'.
    RETURN-MESSAGE_V1        = 'El Deudor '.
    RETURN-MESSAGE_V2        = E_KUNNR.
    RETURN-MESSAGE_V3        = 'Para la Sociedad '.
    CONCATENATE P_TI_DEUDOR-BUKRS 'fue Creado con exito' INTO RETURN-MESSAGE_V4  SEPARATED BY SPACE.
    APPEND RETURN.
  ENDIF.
ENDFORM.                    " CREA_DEUDORES
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DEUDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RETURN  text
*      -->P_T_DEUDOR  text
*      <--P_T_ERROR  text
*----------------------------------------------------------------------*
FORM BUSCA_DEUDOR  TABLES  RETURN STRUCTURE BAPIRET2
                        USING    P_TI_DEUDOR STRUCTURE ZDEUDOR
                        CHANGING P_T_ERROR.

  DATA:  CUSTOMERADDRESS LIKE  BAPICUSTOMER_04,
         CUSTOMERGENERALDETAIL LIKE  BAPICUSTOMER_KNA1,
         CUSTOMERCOMPANYDETAIL LIKE  BAPICUSTOMER_05,
         RETURN3  LIKE  BAPIRET1,
         ES_KNB1  LIKE KNB1,
         ADDRESS_SELECTION LIKE  ADDR1_SEL,
         ADDRESS_VALUE TYPE  ADDR1_VAL,
         ET_ADR6 LIKE  ADR6 OCCURS 0 WITH HEADER LINE.



  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = P_TI_DEUDOR-KUNNR
    IMPORTING
      OUTPUT = P_TI_DEUDOR-KUNNR.


* Busca la informacion de un deudor ya creado para posterialmente actualizarlo.
  CALL FUNCTION 'BAPI_CUSTOMER_GETDETAIL2'
    EXPORTING
      CUSTOMERNO            = P_TI_DEUDOR-KUNNR
      COMPANYCODE           = P_TI_DEUDOR-BUKRS
    IMPORTING
      CUSTOMERADDRESS       = CUSTOMERADDRESS
      CUSTOMERGENERALDETAIL = CUSTOMERGENERALDETAIL
      CUSTOMERCOMPANYDETAIL = CUSTOMERCOMPANYDETAIL
      RETURN                = RETURN3.

  CALL FUNCTION 'KNB1_READ_SINGLE'
    EXPORTING
      ID_KUNNR            = P_TI_DEUDOR-KUNNR
      ID_BUKRS            = P_TI_DEUDOR-BUKRS
    IMPORTING
      ES_KNB1             = ES_KNB1
    EXCEPTIONS
      NOT_FOUND           = 1
      INPUT_NOT_SPECIFIED = 2
      OTHERS              = 3.
  IF SY-SUBRC <> 0.
    P_T_ERROR = 4.
    RETURN-TYPE             = 'E'.
    RETURN-ID                = '15'.
    RETURN-MESSAGE_V1        = 'El Deudor '.
    RETURN-MESSAGE_V2        = P_TI_DEUDOR-KUNNR.
    RETURN-MESSAGE_V3        = 'Para la Sociedad '.
    CONCATENATE P_TI_DEUDOR-BUKRS 'no Existe' INTO RETURN-MESSAGE_V4  SEPARATED BY SPACE.
    APPEND RETURN.
  ELSE.
    ADDRESS_SELECTION-ADDRNUMBER   =  CUSTOMERGENERALDETAIL-ADDRESS.
    CALL FUNCTION 'ADDR_GET'
      EXPORTING
        ADDRESS_SELECTION = ADDRESS_SELECTION
      IMPORTING
        ADDRESS_VALUE     = ADDRESS_VALUE
      EXCEPTIONS
        PARAMETER_ERROR   = 1
        ADDRESS_NOT_EXIST = 2
        VERSION_NOT_EXIST = 3
        INTERNAL_ERROR    = 4
        OTHERS            = 5.
    IF SY-SUBRC <> 0.
      P_T_ERROR = 4.
      RETURN-TYPE             = 'E'.
      RETURN-ID                = '16'.
      RETURN-MESSAGE_V1        = 'Los Datos de direccion'.
      RETURN-MESSAGE_V2        = ' Para el deudor'.
      CONCATENATE P_TI_DEUDOR-KUNNR 'no Existe' INTO RETURN-MESSAGE_V3  SEPARATED BY SPACE.
      APPEND RETURN.
    ELSE.
      CALL FUNCTION 'ADDR_SELECT_ADR6_SINGLE'
        EXPORTING
          ADDRNUMBER          = CUSTOMERGENERALDETAIL-ADDRESS
        TABLES
          ET_ADR6             = ET_ADR6
        EXCEPTIONS
          COMM_DATA_NOT_EXIST = 1
          PARAMETER_ERROR     = 2
          INTERNAL_ERROR      = 3
          OTHERS              = 4.
*      IF SY-SUBRC <> 0.
*        P_T_ERROR = 4.
*        RETURN-TYPE             = 'E'.
*        RETURN-ID                = '16'.
*        RETURN-MESSAGE_V1        = 'Los Datos de direccion'.
*        RETURN-MESSAGE_V2        = ' Para el deudor'.
*        CONCATENATE P_TI_DEUDOR-KUNNR 'no Existe' INTO RETURN-MESSAGE_V3  SEPARATED BY SPACE.
*        APPEND RETURN.
*      ELSE.
      IF SY-SUBRC = 0.
        READ TABLE ET_ADR6 INDEX 1.
      ENDIF.
      TI_CONT_DED-KUNNR = ES_KNB1-KUNNR.
      TI_CONT_DED-BUKRS = ES_KNB1-BUKRS.
      TI_CONT_DED-KTOKD = CUSTOMERGENERALDETAIL-ACCNT_GRP.
      TI_CONT_DED-TITLE = CUSTOMERADDRESS-FORMOFADDR.
      TI_CONT_DED-NAME1 = CUSTOMERADDRESS-NAME.
      TI_CONT_DED-NAME2 = CUSTOMERADDRESS-NAME_2.
      TI_CONT_DED-SORT1 = CUSTOMERADDRESS-SORT_FLD.
      TI_CONT_DED-SORT2 = ADDRESS_VALUE-SORT2.
      TI_CONT_DED-STREET = ADDRESS_VALUE-STREET.
      TI_CONT_DED-HOUSE_NUM1 = ADDRESS_VALUE-HOUSE_NUM1.
      TI_CONT_DED-HOUSE_NUM2 = ADDRESS_VALUE-HOUSE_NUM2.
      TI_CONT_DED-PSTLZ = CUSTOMERADDRESS-PO_BOX.
      TI_CONT_DED-ORT01 = CUSTOMERADDRESS-CITY.
      TI_CONT_DED-ORT02 = CUSTOMERADDRESS-DISTRICT.
      TI_CONT_DED-LAND1 = CUSTOMERADDRESS-COUNTRY.
      TI_CONT_DED-REGIO = CUSTOMERADDRESS-REGION.
      TI_CONT_DED-TEL_NUMBER = ADDRESS_VALUE-TEL_NUMBER.
      TI_CONT_DED-TEL1_EXT = ADDRESS_VALUE-TEL_EXTENS.
      TI_CONT_DED-TELFAX = ADDRESS_VALUE-FAX_NUMBER.
      TI_CONT_DED-FAX_EXTENS = ADDRESS_VALUE-FAX_EXTENS.
      TI_CONT_DED-SMTP_ADDR = ET_ADR6-SMTP_ADDR.
      TI_CONT_DED-LIFNR = CUSTOMERGENERALDETAIL-VENDOR_NO.
      TI_CONT_DED-STCD1 = CUSTOMERGENERALDETAIL-TAX_NO_1.
      TI_CONT_DED-BRSCH = CUSTOMERGENERALDETAIL-INDUSTRY.
      TI_CONT_DED-AKONT = ES_KNB1-AKONT.
      TI_CONT_DED-ZUAWA = ES_KNB1-ZUAWA.
      TI_CONT_DED-FDGRV = ES_KNB1-FDGRV.
      TI_CONT_DED-ZTERM1 = ES_KNB1-ZTERM.
      APPEND TI_CONT_DED.
      REFRESH: ET_ADR6.
      CLEAR: ES_KNB1, CUSTOMERGENERALDETAIL, ET_ADR6, ADDRESS_VALUE, CUSTOMERADDRESS.
*      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " BUSCA_DEUDOR
*&---------------------------------------------------------------------*
*&      Form  VALIDA_UPDATE_DEUDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RETURN  text
*      -->P_T_DEUDOR  text
*      <--P_T_ERROR  text
*----------------------------------------------------------------------*
FORM VALIDA_UPDATE_DEUDOR    TABLES  RETURN STRUCTURE BAPIRET2
                        USING    P_TI_DEUDOR STRUCTURE ZDEUDOR
                        CHANGING P_T_ERROR.

  DATA: E_VALID(1) TYPE C.

  CALL FUNCTION 'BPAR_P_FI_CUSTOMER_CHECK'
    EXPORTING
      CUSTOMER = P_TI_DEUDOR-KUNNR
    EXCEPTIONS
      CUSTOMER = 1
      OTHERS   = 2.
  IF SY-SUBRC <> 0.
    P_T_ERROR = 4.
    RETURN-TYPE              = 'E'.
    RETURN-ID                = '02'.
    RETURN-MESSAGE_V1        = 'El Numero de deudor '.
    RETURN-MESSAGE_V2        = P_TI_DEUDOR-KUNNR.
    RETURN-MESSAGE_V3        = 'ya Existe'.
    APPEND RETURN.
  ENDIF.


  IF P_TI_DEUDOR-TITLE NE SPACE.
    CALL FUNCTION 'ADDR_TSAD3_READ'
      EXPORTING
        TITLE_KEY           = P_TI_DEUDOR-TITLE
      EXCEPTIONS
        TITLE_KEY_NOT_FOUND = 1
        OTHERS              = 2.
    IF SY-SUBRC <> 0.
      P_T_ERROR = 4.
      RETURN-TYPE              = 'E'.
      RETURN-ID                = '06'.
      RETURN-MESSAGE_V1        = 'El Tratamiento '.
      RETURN-MESSAGE_V2        =  P_TI_DEUDOR-TITLE.
      RETURN-MESSAGE_V3        = ' NO existe'.
      APPEND RETURN.
    ENDIF.
  ENDIF.

  IF P_TI_DEUDOR-REGIO NE SPACE.
    CALL FUNCTION 'BPAR_C_REGIONALCODE_CHECK'
      EXPORTING
        COUNTRY      = P_TI_DEUDOR-LAND1
        REGIONALCODE = P_TI_DEUDOR-REGIO
      EXCEPTIONS
        REGIONALCODE = 1
        OTHERS       = 2.
    IF SY-SUBRC <> 0.
      P_T_ERROR = 4.
      RETURN-TYPE              = 'E'.
      RETURN-ID                = '08'.
      RETURN-MESSAGE_V1        = 'La Region ingresada'.
      RETURN-MESSAGE_V2        =  P_TI_DEUDOR-REGIO.
      RETURN-MESSAGE_V3        = ' NO existe'.
      APPEND RETURN.
    ENDIF.
  ENDIF.


  IF P_TI_DEUDOR-LIFNR NE SPACE.
    CALL FUNCTION 'FI_VENDOR_CHECK'
      EXPORTING
        I_BUKRS = P_TI_DEUDOR-BUKRS
        I_LIFNR = P_TI_DEUDOR-LIFNR
      EXCEPTIONS
        VENDOR  = 1
        OTHERS  = 2.
    IF SY-SUBRC <> 0.
      P_T_ERROR = 4.
      RETURN-TYPE              = 'E'.
      RETURN-ID                = '09'.
      RETURN-MESSAGE_V1        = 'El Numero de Acreedor'.
      RETURN-MESSAGE_V2        =  P_TI_DEUDOR-LIFNR.
      RETURN-MESSAGE_V3        = ' Ya existe'.
      APPEND RETURN.
    ENDIF.
  ENDIF.


*    VALIDACIÓN SOCIEDAD (BUKRS)
  CALL FUNCTION 'VALIDATE_COMPANY_CODE'
    EXPORTING
      I_COMPANY  = P_TI_DEUDOR-BUKRS
    IMPORTING
      E_VALID    = E_VALID
    EXCEPTIONS
      INCOMPLETE = 1
      OTHERS     = 2.

  IF  E_VALID EQ 0.
    P_T_ERROR = 4.
    RETURN-TYPE              = 'E'.
    RETURN-ID                = '04'.
    RETURN-MESSAGE_V1        = 'La Sociedad FI'.
    RETURN-MESSAGE_V2        = P_TI_DEUDOR-BUKRS.
    RETURN-MESSAGE_V3        = ' NO Existe'.
    APPEND RETURN.
  ENDIF.

  CALL FUNCTION 'TZUN_SINGLE_READ'
    EXPORTING
      I_ZUAWA   = P_TI_DEUDOR-ZUAWA
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
    P_T_ERROR = 4.
    RETURN-TYPE              = 'E'.
    RETURN-ID                = '12'.
    RETURN-MESSAGE_V1        = 'La condicion de Clacificación'.
    RETURN-MESSAGE_V2        =  P_TI_DEUDOR-ZUAWA.
    RETURN-MESSAGE_V3        = 'No existe o no es Valida'.
    APPEND RETURN.
  ENDIF.


  CALL FUNCTION 'CASH_FORECAST_CHECK_LEVEL_GRP'
    EXPORTING
      FDGRP         = P_TI_DEUDOR-FDGRV
      KOART         = 'D'
    EXCEPTIONS
      GROUP_INVALID = 1
      LEVEL_INVALID = 2
      ORIGN_INVALID = 3
      OTHERS        = 4.
  IF SY-SUBRC <> 0.
    P_T_ERROR = 4.
    RETURN-TYPE             = 'E'.
    RETURN-ID                = '14'.
    RETURN-MESSAGE_V1        = 'El Grupo de tesorería'.
    RETURN-MESSAGE_V2        =  P_TI_DEUDOR-FDGRV.
    RETURN-MESSAGE_V3        = 'No existe o no es Valida'.
    APPEND RETURN.
  ENDIF.


  CALL FUNCTION 'FI_CHECK_ZTERM'
    EXPORTING
      I_ZTERM       = P_TI_DEUDOR-ZTERM1
    EXCEPTIONS
      INVALID_ZTERM = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    P_T_ERROR = 4.
    RETURN-TYPE             = 'E'.
    RETURN-ID                = '15'.
    RETURN-MESSAGE_V1        = 'La Condición de pago'.
    RETURN-MESSAGE_V2        =  P_TI_DEUDOR-ZTERM1.
    RETURN-MESSAGE_V3        = 'No existe o no es Valida'.
    APPEND RETURN.
  ENDIF.

  IF P_TI_DEUDOR-BRSCH NE SPACE.
    CALL FUNCTION 'T016_SINGLE_READ'
      EXPORTING
        I_BRSCH         = P_TI_DEUDOR-BRSCH
*     IMPORTING
*       O_T016          =
     EXCEPTIONS
       NOT_FOUND       = 1
       OTHERS          = 2.
    IF SY-SUBRC <> 0.
      P_T_ERROR = 4.
      RETURN-TYPE              = 'E'.
      RETURN-ID                = '13'.
      RETURN-MESSAGE_V1        = 'El indicador de Ramo'.
      RETURN-MESSAGE_V2        =  P_TI_DEUDOR-BRSCH.
      RETURN-MESSAGE_V3        = 'No existe'.
      APPEND RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    " VALIDA_UPDATE_DEUDOR
*&---------------------------------------------------------------------*
*&      Form  PROCESO_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TI_BAPI_DED  text
*      -->P_TI_CONT_DED  text
*----------------------------------------------------------------------*
FORM PROCESO_DATA  TABLES   P_TI_BAPI_DED STRUCTURE ZDEUDOR
                            P_TI_CONT_DED STRUCTURE TI_CONT_DED.

  DATA:  P_INDEX LIKE SY-TABIX.

  LOOP AT P_TI_BAPI_DED.

    READ TABLE P_TI_CONT_DED WITH KEY      ACCION = P_TI_CONT_DED-ACCION
                                           KUNNR  = P_TI_CONT_DED-KUNNR
                                           BUKRS  = P_TI_CONT_DED-BUKRS.
    P_INDEX = SY-TABIX.
    IF SY-SUBRC EQ 0.
      IF P_TI_BAPI_DED-TITLE  NE SPACE.
        P_TI_CONT_DED-TITLE = P_TI_BAPI_DED-TITLE.
      ENDIF.
      IF P_TI_BAPI_DED-NAME1  NE SPACE.
        P_TI_CONT_DED-NAME1 = P_TI_BAPI_DED-NAME1.
      ENDIF.
      IF P_TI_BAPI_DED-NAME2  NE SPACE.
        P_TI_CONT_DED-NAME2 = P_TI_BAPI_DED-NAME2.
      ENDIF.
      IF P_TI_BAPI_DED-SORT1 NE SPACE.
        P_TI_CONT_DED-SORT1 = P_TI_BAPI_DED-SORT1.
      ENDIF.
      IF P_TI_BAPI_DED-SORT2 NE SPACE.
        P_TI_CONT_DED-SORT2 = P_TI_BAPI_DED-SORT2.
      ENDIF.
      IF P_TI_BAPI_DED-STREET NE SPACE.
        P_TI_CONT_DED-STREET = P_TI_BAPI_DED-STREET.
      ENDIF.
      IF P_TI_BAPI_DED-HOUSE_NUM1 NE SPACE.
        P_TI_CONT_DED-HOUSE_NUM1 = P_TI_BAPI_DED-HOUSE_NUM1.
      ENDIF.
      IF P_TI_BAPI_DED-HOUSE_NUM2 NE SPACE.
        P_TI_CONT_DED-HOUSE_NUM2 = P_TI_BAPI_DED-HOUSE_NUM2.
      ENDIF.
      IF P_TI_BAPI_DED-PSTLZ NE SPACE.
        P_TI_CONT_DED-PSTLZ = P_TI_BAPI_DED-PSTLZ.
      ENDIF.
      IF P_TI_BAPI_DED-ORT01 NE SPACE.
        P_TI_CONT_DED-ORT01 = P_TI_BAPI_DED-ORT01.
      ENDIF.
      IF P_TI_BAPI_DED-ORT02 NE SPACE.
        P_TI_CONT_DED-ORT02 = P_TI_BAPI_DED-ORT02.
      ENDIF.
      IF P_TI_BAPI_DED-REGIO NE SPACE.
        P_TI_CONT_DED-REGIO = P_TI_BAPI_DED-REGIO.
      ENDIF.
      IF P_TI_BAPI_DED-TEL_NUMBER NE SPACE.
        P_TI_CONT_DED-TEL_NUMBER = P_TI_BAPI_DED-TEL_NUMBER.
      ENDIF.
      IF P_TI_BAPI_DED-TEL1_EXT NE SPACE.
        P_TI_CONT_DED-TEL1_EXT = P_TI_BAPI_DED-TEL1_EXT.
      ENDIF.
      IF P_TI_BAPI_DED-TELFAX NE SPACE.
        P_TI_CONT_DED-TELFAX = P_TI_BAPI_DED-TELFAX.
      ENDIF.
      IF P_TI_BAPI_DED-FAX_EXTENS NE SPACE.
        P_TI_CONT_DED-FAX_EXTENS = P_TI_BAPI_DED-FAX_EXTENS.
      ENDIF.
      IF P_TI_BAPI_DED-SMTP_ADDR NE SPACE.
        P_TI_CONT_DED-SMTP_ADDR = P_TI_BAPI_DED-SMTP_ADDR.
      ENDIF.
      IF P_TI_BAPI_DED-ZUAWA NE SPACE.
        P_TI_CONT_DED-ZUAWA = P_TI_BAPI_DED-ZUAWA.
      ENDIF.
      IF P_TI_BAPI_DED-FDGRV NE SPACE.
        P_TI_CONT_DED-FDGRV = P_TI_BAPI_DED-FDGRV.
      ENDIF.
      IF P_TI_BAPI_DED-ZTERM1 NE SPACE.
        P_TI_CONT_DED-ZTERM1 = P_TI_BAPI_DED-ZTERM1.
      ENDIF.
      IF P_TI_BAPI_DED-BRSCH NE SPACE.
        P_TI_CONT_DED-BRSCH = P_TI_BAPI_DED-BRSCH.
      ENDIF.


      P_TI_CONT_DED-PROC = 'X'.
      MODIFY P_TI_CONT_DED INDEX P_INDEX.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " PROCESO_DATA
*&---------------------------------------------------------------------*
*&      Form  UPDATE_DEUDORES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_DEUDOR  text
*      -->P_ENDIF  text
*----------------------------------------------------------------------*
FORM UPDATE_DEUDORES TABLES  RETURN STRUCTURE BAPIRET2
                        USING   P_TI_DEUDOR STRUCTURE ZDEUDOR.

  DATA:  I_KNA1  LIKE  KNA1 OCCURS 0 WITH HEADER LINE.
  DATA:  I_KNB1 LIKE  KNB1 OCCURS 0 WITH HEADER LINE.
  DATA:  I_BAPIADDR2 LIKE  BAPIADDR2 OCCURS 0 WITH HEADER LINE.

  I_BAPIADDR2-TITLE_P        =   P_TI_DEUDOR-TITLE.
  I_BAPIADDR2-FIRSTNAME          =   P_TI_DEUDOR-NAME1.
  I_BAPIADDR2-LASTNAME          =   P_TI_DEUDOR-NAME2.
  I_BAPIADDR2-SORT1_P        =   P_TI_DEUDOR-SORT1.
  I_BAPIADDR2-SORT2_P        =   P_TI_DEUDOR-SORT2.
  I_BAPIADDR2-STREET         =   P_TI_DEUDOR-STREET.
  I_BAPIADDR2-HOUSE_NO       =   P_TI_DEUDOR-HOUSE_NUM1.
  I_BAPIADDR2-HOUSE_NO2      =   P_TI_DEUDOR-HOUSE_NUM2.
  I_BAPIADDR2-POSTL_COD2     =   P_TI_DEUDOR-PSTLZ.
  I_BAPIADDR2-CITY           =   P_TI_DEUDOR-ORT01.
  I_BAPIADDR2-DISTRICT       =   P_TI_DEUDOR-ORT02.
  I_BAPIADDR2-COUNTRY        =   P_TI_DEUDOR-LAND1.
  I_BAPIADDR2-REGION         =   P_TI_DEUDOR-REGIO.
  I_BAPIADDR2-TEL1_NUMBR     =   P_TI_DEUDOR-TEL_NUMBER.
  I_BAPIADDR2-TEL1_EXT       =   P_TI_DEUDOR-TEL1_EXT.
  I_BAPIADDR2-FAX_NUMBER     =   P_TI_DEUDOR-TELFAX.
  I_BAPIADDR2-FAX_EXTENS     =   P_TI_DEUDOR-FAX_EXTENS.
  I_BAPIADDR2-E_MAIL         =   P_TI_DEUDOR-SMTP_ADDR.
  I_BAPIADDR2-LANGU_P        =   'S'.
  I_BAPIADDR2-TIME_ZONE     = 'CHILE'.
  APPEND I_BAPIADDR2.

  I_KNB1-KUNNR = P_TI_DEUDOR-KUNNR.
  I_KNB1-BUKRS = P_TI_DEUDOR-BUKRS.
  I_KNB1-AKONT = P_TI_DEUDOR-AKONT.
  I_KNB1-ZUAWA = P_TI_DEUDOR-ZUAWA.
  I_KNB1-FDGRV = P_TI_DEUDOR-FDGRV.
  I_KNB1-ZTERM = P_TI_DEUDOR-ZTERM1.
* HCD 07032018

 I_KNB1-ERDAT = SY-DATUM.
 I_KNB1-ERNAM = 'PISUPER'.
  APPEND I_KNB1.

  I_KNA1-MANDT = SY-MANDT.
  I_KNA1-KUNNR = P_TI_DEUDOR-KUNNR.
  I_KNA1-KTOKD = P_TI_DEUDOR-KTOKD.
  I_KNA1-LIFNR = P_TI_DEUDOR-LIFNR.
  I_KNA1-STCD1 = P_TI_DEUDOR-STCD1.
  I_KNA1-BRSCH = P_TI_DEUDOR-BRSCH.
* se agrega ES  09-04-2015
  I_KNA1-SPRAS = 'S'.
* HCD 07032018
 I_KNA1-ERDAT = SY-DATUM.
 I_KNA1-ERNAM = 'PISUPER'.

  APPEND I_KNA1.


  DATA: E_KUNNR TYPE KUNNR.

  CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
    EXPORTING
      I_KNA1                  = I_KNA1
      I_KNB1                  = I_KNB1
      I_BAPIADDR2             = I_BAPIADDR2
    IMPORTING
      E_KUNNR                 = E_KUNNR
    EXCEPTIONS
      CLIENT_ERROR            = 1
      KNA1_INCOMPLETE         = 2
      KNB1_INCOMPLETE         = 3
      KNB5_INCOMPLETE         = 4
      KNVV_INCOMPLETE         = 5
      KUNNR_NOT_UNIQUE        = 6
      SALES_AREA_NOT_UNIQUE   = 7
      SALES_AREA_NOT_VALID    = 8
      INSERT_UPDATE_CONFLICT  = 9
      NUMBER_ASSIGNMENT_ERROR = 10
      NUMBER_NOT_IN_RANGE     = 11
      NUMBER_RANGE_NOT_EXTERN = 12
      NUMBER_RANGE_NOT_INTERN = 13
      ACCOUNT_GROUP_NOT_VALID = 14
      PARNR_INVALID           = 15
      BANK_ADDRESS_INVALID    = 16
      TAX_DATA_NOT_VALID      = 17
      NO_AUTHORITY            = 18
      COMPANY_CODE_NOT_UNIQUE = 19
      DUNNING_DATA_NOT_VALID  = 20
      KNB1_REFERENCE_INVALID  = 21
      CAM_ERROR               = 22
      OTHERS                  = 23.
  IF SY-SUBRC EQ 0.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    RETURN-TYPE             = 'S'.
    RETURN-ID                = '22'.
    RETURN-MESSAGE_V1        = 'El Deudor '.
    RETURN-MESSAGE_V2        = TI_CONT_DED-KUNNR.
    RETURN-MESSAGE_V3        = 'Para la Sociedad '.
    CONCATENATE P_TI_DEUDOR-BUKRS 'fue Actualizado con exito' INTO RETURN-MESSAGE_V4  SEPARATED BY SPACE.
    APPEND RETURN.
  ENDIF.
ENDFORM.                    " UPDATE_DEUDORES
