FUNCTION ZFICREA_AFIJO.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(COMPANUCODE) TYPE  BUKRS
*"     VALUE(ASSETCLASS) TYPE  ANLKL
*"     VALUE(QUANTITY) TYPE  QUANTITY OPTIONAL
*"     VALUE(BASE_UOM) TYPE  MEINS OPTIONAL
*"     VALUE(DESCRIPT) TYPE  TXA50_ANLT
*"     VALUE(VENDOR_NO) TYPE  KUNNR
*"     VALUE(VENDOR) TYPE  NAME1
*"     VALUE(COSTCENTER) TYPE  KOSTL
*"     VALUE(ASSET) TYPE  ASSETTYPE OPTIONAL
*"     VALUE(SUBN) TYPE  SUB_TYPE OPTIONAL
*"     VALUE(REF_ASSET) TYPE  ASSETTYPE OPTIONAL
*"     VALUE(REF_SUBN) TYPE  SUB_TYPE OPTIONAL
*"     VALUE(CREA_GRUPO) TYPE  C1 OPTIONAL
*"     VALUE(CREA_SUBNUM) TYPE  C1 OPTIONAL
*"     VALUE(XUPDATE) TYPE  C1 OPTIONAL
*"     VALUE(FECHA_CAP) TYPE  DATS OPTIONAL
*"     VALUE(SERIAL_NO) TYPE  SERNR OPTIONAL
*"     VALUE(INVENT_NO) TYPE  INVNR OPTIONAL
*"     VALUE(X_ORD41) TYPE  ORD41 OPTIONAL
*"     VALUE(X_ORD42) TYPE  ORD42 OPTIONAL
*"     VALUE(X_ORD43) TYPE  ORD43 OPTIONAL
*"     VALUE(X_PURCH_NEW) TYPE  XNEU_AM OPTIONAL
*"     VALUE(X_ANLUE) TYPE  ANLUE OPTIONAL
*"     VALUE(X_IZWEK) TYPE  IZWEK OPTIONAL
*"  EXPORTING
*"     VALUE(ASSETMAINO) LIKE  BAPI1022_1-ASSETMAINO
*"     VALUE(SUBNUMBER) LIKE  BAPI1022_1-ASSETSUBNO
*"     VALUE(RETURN1) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"  TABLES
*"      DEPRECIATIONAREAS STRUCTURE  BAPI1022_DEP_AREAS
*"      DEPRECIATIONAREASX STRUCTURE  BAPI1022_DEP_AREASX
*"----------------------------------------------------------------------

DATA: key TYPE bapi1022_key.
DATA: generaldata TYPE bapi1022_feglg001. " OCCURS 0 WITH HEADER LINE.
DATA: generaldata_x TYPE bapi1022_feglg001x.
DATA: timedependentdata TYPE bapi1022_feglg003." OCCURS 0 WITH HEADER LINE.
DATA: timedependentdata_x TYPE bapi1022_feglg003x.
DATA: origin TYPE BAPI1022_FEGLG009.
DATA: origin_x TYPE BAPI1022_FEGLG009x.
DATA: reference TYPE bapi1022_reference.

DATA: ls_allocations TYPE bapi1022_feglg004.
DATA: ls_allocations_x TYPE bapi1022_feglg004x.

DATA: ls_posting_information TYPE bapi1022_feglg002.
DATA: ls_posting_information_x TYPE bapi1022_feglg002x.
* DATA: xupdate TYPE C1.
DATA: createsubnumber TYPE  bapi1022_misc-xsubno. " Create Asset Subnumber?
DATA: creategroupasset TYPE  bapi1022_misc-xanlgr."  Indicator: Asset is a group asset
* DATA: assetmaino TYPE bapi1022_1 -assetmaino.
DATA: assetsubno TYPE bapi1022_1-assetsubno.
*DATA: return1 TYPE bapiret2 OCCURS 0 WITH HEADER LINE.

*DATA: depreciationareas TYPE bapi1022_dep_areas.


DATA: wait TYPE bapita-wait VALUE 'X'.
DATA return2 LIKE bapiret2 OCCURS 0 WITH HEADER LINE.
*--- Rellenamos los datos para crear activo FIJO


key-companycode = COMPANUCODE.

xupdate = ''.

* SI ES UPDATE
IF ASSET is not INITIAL.
  key-ASSET = ASSET.
  key-SUBNUMBER  = SUBN.
 xupdate = 'X'.
ENDIF.
reference-companycode = COMPANUCODE.

IF REF_ASSET is not INITIAL.
  reference-ASSET = REF_ASSET.
  reference-SUBNUMBER  = REF_SUBN.
ENDIF.


IF ASSETCLASS is not INITIAL.
  generaldata-assetclass = ASSETCLASS.
  generaldata_x-assetclass = xupdate.
ENDIF.

IF QUANTITY is not INITIAL.
  generaldata-quantity = QUANTITY.
  generaldata_x-quantity = xupdate.
ENDIF.

IF BASE_UOM is not INITIAL.
  generaldata-base_uom = BASE_UOM.
  generaldata_x-base_uom = xupdate.
ENDIF.

IF SERIAL_NO is not INITIAL.
  generaldata-SERIAL_NO = SERIAL_NO.
  generaldata_x-SERIAL_NO = xupdate.
ENDIF.

IF INVENT_NO is not INITIAL.
  generaldata-INVENT_NO = INVENT_NO.
  generaldata_x-INVENT_NO = xupdate.
ENDIF.


IF x_ord41 is not INITIAL.
ls_allocations-evalgroup1 = x_ord41.
ls_allocations_x-evalgroup1 = xupdate.
ENDIF.

IF  x_ord42 is not INITIAL.
ls_allocations-evalgroup2 = x_ord42.
ls_allocations_x-evalgroup2 = xupdate.
ENDIF.

IF x_ord43 is not INITIAL.
ls_allocations-evalgroup3 = x_ord43.
ls_allocations_x-evalgroup3 = xupdate.
ENDIF.
"Campos nuevos HCD 30-04-2020
" Hcastillo
"ANLUE Supranumero
"IZWEK destini inversion
IF X_IZWEK is not INITIAL.
ls_allocations-INV_REASON  = X_IZWEK.
ls_allocations_x-INV_REASON = xupdate.
ENDIF.
IF X_ANLUE is not INITIAL.
ls_allocations-ASSETSUPNO = X_ANLUE.
ls_allocations_x-ASSETSUPNO = xupdate.
ENDIF.


IF DESCRIPT is not INITIAL.
  generaldata-descript = DESCRIPT.
  generaldata_x-descript = xupdate.
ENDIF.

IF VENDOR_NO is not INITIAL.
  origin-vendor_no = VENDOR_NO.
  origin_x-vendor_no = xupdate.
ENDIF.

IF VENDOR is not INITIAL.
  origin-vendor = VENDOR.
  origin_x-vendor = xupdate.
ENDIF.

IF X_PURCH_NEW is not INITIAL.
  origin-PURCH_NEW = X_PURCH_NEW.
  origin_x-PURCH_NEW = xupdate.
ENDIF.




IF COSTCENTER is not INITIAL.
  timedependentdata-costcenter = COSTCENTER.
  timedependentdata_x-costcenter = xupdate.
ENDIF.
*--- Llamamos a la BAPI

*---Asset capitalization date

IF FECHA_CAP is not INITIAL.
ls_posting_information-cap_date = FECHA_CAP.
ls_posting_information_x-cap_date = xupdate.
ENDIF.

createsubnumber = CREA_SUBNUM.
creategroupasset = CREA_GRUPO .

* Actualizar areas de depresiacion
*  depreciationareas-AREA = '01'.
*  depreciationareas-ULIFE_YRS = '8'.
*  depreciationareas-ULIFE_PRDS ='0'.
*  depreciationareas-ODEP_START_DATE ='2014.03.01'.
*  APPEND   depreciationareas.

CALL FUNCTION 'BAPI_FIXEDASSET_CREATE1'
*CALL FUNCTION 'BAPI_FIXEDASSET_OVRTAKE_CREATE'
EXPORTING
    key = key
    CREATESUBNUMBER =  createsubnumber
    CREATEGROUPASSET = creategroupasset
    reference = reference
    generaldata = generaldata
    generaldatax = generaldata_x
    timedependentdata = timedependentdata
    timedependentdatax = timedependentdata_x
    postinginformation = ls_posting_information
    postinginformationx = ls_posting_information_x
    allocations = ls_allocations
    allocationsx = ls_allocations_x
    origin = origin
    originx = origin_x

IMPORTING
    asset     = assetmaino
    subnumber = SUBNUMBER
    return = return1

TABLES
    depreciationareas  =  depreciationareas
    depreciationareasx =  DEPRECIATIONAREASX.
*     postinginformation         = postinginformation
*     postinginformationx        = postinginformationx.
IF  assetmaino IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = wait
    IMPORTING
      return = return2.
ENDIF.

* LOOP AT return1.
* WRITE: / return1-message.
* ENDLOOP.



ENDFUNCTION.
