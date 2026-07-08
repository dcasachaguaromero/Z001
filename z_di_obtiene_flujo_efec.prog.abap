*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
REPORT ZAL_ABAP message-id 26 line-size 255
no standard page heading.
* Z_DI_OBTIENE_FLUJO_EFEC.
PARAMETER DOWNLOAD(1) DEFAULT 'S' lower case. "N-svr,Y-clnt
PARAMETER EXECMODE(1) DEFAULT 'D' lower case. "D-dlg,B-btch
PARAMETER OUT_DIR(48) DEFAULT "output file dir
'\\172.31.100.100\' lower case.
PARAMETER IN_DIR(48) DEFAULT "input file dir
'\\172.31.100.100\' lower case.
PARAMETER P_DEST TYPE RFCDES-RFCDEST DEFAULT
'NONE'.
PARAMETER P_PROGID TYPE RFCOPT-RFCEXEC DEFAULT
SPACE.
PARAMETER P_GWHOST TYPE RFCOPT-RFCGWHOST DEFAULT
SPACE.
PARAMETER P_GWSERV TYPE RFCOPT-RFCGWSERV DEFAULT
SPACE.
PARAMETER P_SRVFM(30) DEFAULT "Server Callback function
SPACE.
PARAMETER P_PKGSZ TYPE I DEFAULT "Stream package size
5000.
PARAMETER P_SNC_ON(1) DEFAULT "X-on SPACE-off
SPACE.

PARAMETER $PARAM1(4) TYPE C.

PARAMETER $PARAM2 TYPE I.

PARAMETER $PARAM3 TYPE I.

PARAMETER $PARAM4 TYPE D.

PARAMETER $PARAM5 TYPE D.

PARAMETER $PARAM6 TYPE D.

PARAMETER $PARAM7 TYPE D.

PARAMETER P_DF_VK(40) DEFAULT "ABAP data flow object key
'' lower case.
PARAMETER P_DI_GEN(40) DEFAULT "DI version that generated ABAP
'' lower case.

*** Machine generated ABAP. Do not modify.            ***
*** (C)Copyright Business Objects S.A.  All rights reserved. ***
*
* Date Time:
*    09/21/18 11:08:34
* SAP used for generated this ABAP:
*    Release: 700
*    Host   : 172.31.100.100
*
* ABAP Dataflow Name:
*    FE_S_STG_MOVIMIENTO_CONTABLE
* ABAP Dataflow comments:
*  EXTRAE INFORMACION DE BKPF Y BSEG
* ABAP program name in SAP:
*  Z_DI_OBTIENE_FLUJO_EFEC
* Generated ABAP file name:
*  C:/ProgramData/SAP BusinessObjects/Data Services/workspace/Z_D
*I_O
*    BTIENE_FLUJO_EFEC
TABLES BKPF.
TABLES BSEG.

DATA: begin of ITAB3 occurs 0,
MANDT(3) TYPE C,
BUKRS(4) TYPE C,
BELNR(10) TYPE C,
GJAHR(4) TYPE N,
BLART(2) TYPE C,
BLDAT TYPE D,
BUDAT TYPE D,
CPUDT TYPE D,
TCODE(20) TYPE C,
BVORG(16) TYPE C,
XBLNR(16) TYPE C,
STBLG(10) TYPE C,
WAERS(5) TYPE C,
XREF2_HD(20) TYPE C,
LDGRP(4) TYPE C,
SHKZG(1) TYPE C,
GSBER(4) TYPE C,
DMBTR(16) TYPE P DECIMALS 2,
SGTXT(50) TYPE C,
FDTAG TYPE D,
KOSTL(10) TYPE C,
ANBWA(3) TYPE C,
HKONT(10) TYPE C,
LIFNR(10) TYPE C,
PRCTR(10) TYPE C,
SEGMENT(10) TYPE C,
ZZPRESTAC(10) TYPE C,
ZZUNID_PRO(10) TYPE C,
ZZRUT_TERC(10) TYPE C,
ZZMOT_EMIS(10) TYPE C,
KOART(1) TYPE C,
KUNNR(10) TYPE C.
DATA: end of ITAB3.

data: append_flag(1) value ' ',
      cntbuf type i,
      delimleng type i,last_batch(1) value ' '.

CONSTANTS C_DF_VK(40) VALUE '216'.
CONSTANTS C_DI_GEN(40) VALUE '14.2.7.1641'.
DATA WARN_MSG(50).


start-of-selection.


  IF DOWNLOAD = 'S' OR
     DOWNLOAD = 'N' OR
     DOWNLOAD = 'Y'.
      .
  ELSE.
     DATA: m_xfer_err_msg(700).
     CONCATENATE
'ABAP program does not recognize this new '
'data transfer method: ' DOWNLOAD
'. Regenerate the ABAP program and upload to this system.'
     INTO m_xfer_err_msg.
     MESSAGE  E240(S#) WITH m_xfer_err_msg.
  ENDIF.

  IF EXECMODE = 'B' OR
     EXECMODE = 'D'.
      .
  ELSE.
     DATA: m_exec_err_msg(700).
     CONCATENATE
'ABAP program does not recognize this new '
'execution option: ' EXECMODE
'. Regenerate the ABAP program and upload to this system.'
     INTO m_exec_err_msg.
     MESSAGE  E240(S#) WITH m_exec_err_msg.
  ENDIF.

  IF DOWNLOAD = 'S'.
     PERFORM CONNECT_RFCDEST_TO_PROGID.
  ENDIF.



PERFORM FORM3.
last_batch = 'X'.
PERFORM FORM4.
FREE ITAB3.
  IF DOWNLOAD = 'S'.
     PERFORM DISCONNECT_RFCDEST_FROM_PROGID.
  ENDIF.


end-of-selection.

CLEAR WARN_MSG.

IF NOT P_DF_VK IS INITIAL.
  IF P_DF_VK <> C_DF_VK.
     CONCATENATE '$$Warning$'
                 C_DF_VK
                 '$' INTO WARN_MSG.
  ENDIF.
ENDIF.
IF NOT P_DI_GEN IS INITIAL.
  IF P_DI_GEN <> C_DI_GEN.
     IF WARN_MSG IS INITIAL.
       CONCATENATE '$$Warning$$'
                   C_DI_GEN
                   INTO WARN_MSG.
     ELSE.
       CONCATENATE WARN_MSG
                   C_DI_GEN
                   INTO WARN_MSG.
     ENDIF.
  ENDIF.
ENDIF.

IF NOT WARN_MSG IS INITIAL.
  IF EXECMODE = 'D'.
    WRITE WARN_MSG.
    NEW-LINE.
  ELSE.
    MESSAGE S240(S#) with WARN_MSG.
  ENDIF.
ENDIF.


write  '* Program Complete *'.
write
 '(C)Copyright Business Objects S.A.  All rights reserved.'.

FORM FORM3.
DATA ALTMP1(3) TYPE C.
DATA ALTMP2(4) TYPE C.
DATA ALTMP3(10) TYPE C.
DATA ALTMP4(4) TYPE N.
DATA ALTMP5(2) TYPE C.
DATA ALTMP6 TYPE D.
DATA ALTMP7 TYPE D.
DATA ALTMP8 TYPE D.
DATA ALTMP9(20) TYPE C.
DATA ALTMP10(16) TYPE C.
DATA ALTMP11(16) TYPE C.
DATA ALTMP12(10) TYPE C.
DATA ALTMP13(5) TYPE C.
DATA ALTMP14(20) TYPE C.
DATA ALTMP15(4) TYPE C.
DATA ALTMP16(1) TYPE C.
DATA ALTMP17(4) TYPE C.
DATA ALTMP18(16) TYPE P DECIMALS 2.
DATA ALTMP19(50) TYPE C.
DATA ALTMP20 TYPE D.
DATA ALTMP21(10) TYPE C.
DATA ALTMP22(3) TYPE C.
DATA ALTMP23(10) TYPE C.
DATA ALTMP24(10) TYPE C.
DATA ALTMP25(10) TYPE C.
DATA ALTMP26(10) TYPE C.
DATA ALTMP27(10) TYPE C.
DATA ALTMP28(10) TYPE C.
DATA ALTMP29(10) TYPE C.
DATA ALTMP30(10) TYPE C.
DATA ALTMP31(1) TYPE C.
DATA ALTMP32(10) TYPE C.




SELECT
  MANDT
  BUKRS
  BELNR
  GJAHR
  BLART
  BLDAT
  BUDAT
  CPUDT
  TCODE
  BVORG
  XBLNR
  STBLG
  WAERS
  XREF2_HD
  LDGRP
INTO CORRESPONDING FIELDS OF BKPF
FROM BKPF
WHERE ( ( CPUDT <= $PARAM7 )
 AND ( ( CPUDT >= $PARAM6 )
 AND ( ( BUDAT <= $PARAM5 )
 AND ( ( BUDAT >= $PARAM4 )
 AND ( ( GJAHR >= $PARAM3 )
 AND ( ( GJAHR <= $PARAM2 )
 AND ( BUKRS = $PARAM1 ) ) ) ) ) ) ).
ALTMP1 = BKPF-MANDT.
ALTMP2 = BKPF-BUKRS.
ALTMP3 = BKPF-BELNR.
ALTMP4 = BKPF-GJAHR.
ALTMP5 = BKPF-BLART.
ALTMP6 = BKPF-BLDAT.
ALTMP7 = BKPF-BUDAT.
ALTMP8 = BKPF-CPUDT.
ALTMP9 = BKPF-TCODE.
ALTMP10 = BKPF-BVORG.
ALTMP11 = BKPF-XBLNR.
ALTMP12 = BKPF-STBLG.
ALTMP13 = BKPF-WAERS.
ALTMP14 = BKPF-XREF2_HD.
ALTMP15 = BKPF-LDGRP.

SELECT
SHKZG
GSBER
DMBTR
SGTXT
FDTAG
KOSTL
ANBWA
HKONT
LIFNR
PRCTR
SEGMENT
ZZPRESTAC
ZZUNID_PRO
ZZRUT_TERC
ZZMOT_EMIS
KOART
KUNNR
BUKRS
BELNR
GJAHR
INTO CORRESPONDING FIELDS OF BSEG
FROM BSEG
WHERE ( ( GJAHR = BKPF-GJAHR )
AND ( ( BELNR = BKPF-BELNR )
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 20/12/2019 EY_DES02 ECDK917080 *
*AND ( BUKRS = BKPF-BUKRS ) ) ).
AND ( BUKRS = BKPF-BUKRS ) ) ) ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 20/12/2019 EY_DES02 ECDK917080 *
ALTMP16 = BSEG-SHKZG.
ALTMP17 = BSEG-GSBER.
ALTMP18 = BSEG-DMBTR.
ALTMP19 = BSEG-SGTXT.
ALTMP20 = BSEG-FDTAG.
ALTMP21 = BSEG-KOSTL.
ALTMP22 = BSEG-ANBWA.
ALTMP23 = BSEG-HKONT.
ALTMP24 = BSEG-LIFNR.
ALTMP25 = BSEG-PRCTR.
ALTMP26 = BSEG-SEGMENT.
ALTMP27 = BSEG-ZZPRESTAC.
ALTMP28 = BSEG-ZZUNID_PRO.
ALTMP29 = BSEG-ZZRUT_TERC.
ALTMP30 = BSEG-ZZMOT_EMIS.
ALTMP31 = BSEG-KOART.
ALTMP32 = BSEG-KUNNR.
 move ALTMP1 to ITAB3-MANDT.
 move ALTMP2 to ITAB3-BUKRS.
 move ALTMP3 to ITAB3-BELNR.
 move ALTMP4 to ITAB3-GJAHR.
 move ALTMP5 to ITAB3-BLART.
 move ALTMP6 to ITAB3-BLDAT.
 move ALTMP7 to ITAB3-BUDAT.
 move ALTMP8 to ITAB3-CPUDT.
 move ALTMP9 to ITAB3-TCODE.
 move ALTMP10 to ITAB3-BVORG.
 move ALTMP11 to ITAB3-XBLNR.
 move ALTMP12 to ITAB3-STBLG.
 move ALTMP13 to ITAB3-WAERS.
 move ALTMP14 to ITAB3-XREF2_HD.
 move ALTMP15 to ITAB3-LDGRP.
 move ALTMP16 to ITAB3-SHKZG.
 move ALTMP17 to ITAB3-GSBER.
 move ALTMP18 to ITAB3-DMBTR.
 move ALTMP19 to ITAB3-SGTXT.
 move ALTMP20 to ITAB3-FDTAG.
 move ALTMP21 to ITAB3-KOSTL.
 move ALTMP22 to ITAB3-ANBWA.
 move ALTMP23 to ITAB3-HKONT.
 move ALTMP24 to ITAB3-LIFNR.
 move ALTMP25 to ITAB3-PRCTR.
 move ALTMP26 to ITAB3-SEGMENT.
 move ALTMP27 to ITAB3-ZZPRESTAC.
 move ALTMP28 to ITAB3-ZZUNID_PRO.
 move ALTMP29 to ITAB3-ZZRUT_TERC.
 move ALTMP30 to ITAB3-ZZMOT_EMIS.
 move ALTMP31 to ITAB3-KOART.
 move ALTMP32 to ITAB3-KUNNR.
 append ITAB3.
 cntbuf = cntbuf + 1.
 if download = 'N'.
  if cntbuf > 5000.
    perform FORM4.
    clear cntbuf.
    refresh ITAB3.
    append_flag = 'A'.
  endif.
 endif.
 if download = 'S'.
  if cntbuf > P_PKGSZ.
    perform FORM4.
    clear cntbuf.
    refresh ITAB3.
  endif.
 endif.
ENDSELECT.
ENDSELECT.
ENDFORM.

FORM FORM4.
data: outfile(512), ldfile(50).
ldfile = 'aR3dt.dat'.
concatenate out_dir ldfile into outfile
  separated by '/'.
  IF DOWNLOAD = 'S'.
     DATA: error_message(700),mtext(800),iEOP(1).
     CALL FUNCTION P_SRVFM
          DESTINATION P_DEST
          KEEPING LOGICAL UNIT OF WORK
          EXPORTING
            EOS = last_batch
          IMPORTING
            EOP = iEOP
          TABLES
            E_TABLE = ITAB3
          EXCEPTIONS
            READ_ERROR = 1
            SYSTEM_FAILURE = 2
            MESSAGE error_message
            COMMUNICATION_FAILURE = 3
            MESSAGE error_message
            OTHERS = 4.

     IF sy-subrc ne 0.
        Case sy-subrc.
        when 1.
        CONCATENATE
        'Data Services read error. '
        'Check Data Services error log.'
        INTO mtext.
        MESSAGE  E240(S#) WITH mtext.
        when 2.
        CONCATENATE
'SAP System Failure while calling DS remote function: '
      error_message INTO mtext.
        MESSAGE  E240(S#) WITH mtext.
        when 3.
        CONCATENATE
'SAP System Failure while calling DS remote function: '
      error_message INTO mtext.
        MESSAGE  E240(S#) WITH mtext.
        when 4.
        MESSAGE  E240(S#) WITH
'Other SAP System Failure while calling DS remote function.'.
        endcase.
      ENDIF.
      IF iEOP = 'X'.
         PERFORM DISCONNECT_RFCDEST_FROM_PROGID.
         LEAVE PROGRAM.
       ENDIF.
  ELSE.
data  dlmtlen type i value '1'.
data xdlmtlen type i value '1'.
data:
  ht(1) type c,
  xht(1) type x,
  conv type ref to cl_abap_conv_in_ce.
xht = '7F'.
conv = cl_abap_conv_in_ce=>create(
  encoding = '1100'
  input = xht
).
call method conv->read(
  exporting n    = xdlmtlen
  importing data = ht
            len = dlmtlen
).
data return_code type i.
 perform write_delimited_file
           tables   ITAB3
           using    outfile
                    append_flag
                    ht
                    dlmtlen
                    download
           changing return_code.

  case return_code.
    when 1.
      IF EXECMODE = 'D'.
        WRITE: /5 'No line selected'.
      ELSE.
        MESSAGE E047(S#).
      ENDIF.
    when 2.
      IF EXECMODE = 'D'.
        WRITE: /5 'Open File Error -- ', 25 OUTFILE.
      ELSE.
        MESSAGE  E084(E0) WITH OUTFILE.
      ENDIF.
    when 3.
      IF EXECMODE = 'D'.
        WRITE: /5 'Data exceed length limit (8192) '.
      ELSE.
        MESSAGE  E240(S#) WITH
             'Data exceed length limit (8192) '.
      ENDIF.
    when 4.
      IF EXECMODE = 'D'.
        WRITE: /5 'Call function WS_DOWNLOAD error'.
      ELSE.
        MESSAGE  E240(S#) WITH
             'Call function WS_DOWNLOAD error'.
      ENDIF.
  endcase.
 ENDIF.
ENDFORM.

FORM SUBSTRING USING SRC BEG LEN CHANGING RET.

DATA: VA1 TYPE I.
DATA: VA2 TYPE I.
DATA: VA3 TYPE I.

VA3 = STRLEN( SRC ).

IF  BEG = 0.   VA1 = 0.
ELSE.
  IF  BEG < 0.
    VA1 = VA3 + BEG.
    IF  VA1 < 0.   VA1 = 0.
    ENDIF.
  ELSE.          VA1 = BEG - 1.
  ENDIF.
ENDIF.

IF  LEN < 0.   VA2 = 0.
ELSE.          VA2 = VA3 - VA1.
ENDIF.

IF  VA2 > LEN. VA2 = LEN.
ENDIF.

IF  VA2 < 1.   MOVE ''           TO RET.
ELSE.          MOVE SRC+VA1(VA2) TO RET.
ENDIF.

ENDFORM.

form write_delimited_file
           tables   datatab
           using    file
                    append
                    delimit
                    dlength
                    dwnload
          changing rc.

  data: type1,
        appd(1),
        temp(32),
        time1(8),
        date1(10),
        output(8192),
        rcount type i,
        offset type i,
        tablen type i,
        maxlen type i value '8192'.

  data: begin of clientab occurs 0,
             output(8192),
          end of clientab.

  field-symbols: <f>.
  field-symbols <delim1>.
  data delim2(16).
  data l_filename type string.

  appd = append.
  if appd is not initial.
     appd = 'X'.
  endif.
  move file to l_filename.
  describe table datatab lines tablen.


  if dwnload = 'Y'.
     clear clientab. refresh clientab.
     rcount = 0.
  else.
     if appd = space.
   open dataset file for output in text mode ENCODING UTF-8.
     else.
    open dataset file for appending in text mode ENCODING UTF-8.

     endif.
     if sy-subrc <> 0.
         rc = 2. exit.
     endif.
  endif.

  loop at datatab.
    clear: tablen, offset, output.
    do.
      assign component sy-index of
         structure datatab to <f>.
      if sy-subrc <> 0. exit. endif.
      if sy-index > 1.
         assign delimit(dlength) TO <delim1> CASTING TYPE C.
         delim2 = <delim1>.
         write delim2(dlength) to output+offset(dlength).
         add dlength to offset.
      endif.

      describe field <f> type type1.

      if type1 = 'I' or type1 = 'N'.
          type1 = 'P'.
      endif.

      case type1.
        when 'D'.
          if <f> = '00000000'.
             <f> = ' '.
          else.
             move <f> to time1.
             assign time1 to <f>.
          endif.
        when 'F'.
          if <f> = '0.0'.
            temp = '0.0'.
          else.
             write <f> to temp exponent 0.
          endif.
          condense temp no-gaps.
          translate temp using ',.'.
          assign temp to <f>.
        when 'P'.
          if <f> < 0.
             write '-' to output+offset(1).
             add 1 to offset.
             <f> = <f> * ( -1 ).
          endif.
          move <f> to temp.
          condense temp no-gaps.
          translate temp using ',.'.
          assign temp to <f>.
      endcase.

      sy-fdpos = strlen( <f> ).

      tablen = offset + sy-fdpos.
      if tablen > maxlen.
         rc = 3. exit.
      endif.
      write <f> to output+offset(sy-fdpos).
      add sy-fdpos to offset.
    enddo.

    if dwnload = 'Y'.
       clientab-output = output.
       append clientab.
       rcount = rcount + 1.
       if rcount >= 50.
          SY-BATCH = SPACE.
          CALL FUNCTION 'GUI_DOWNLOAD'
            EXPORTING
              FILENAME = l_filename
              FILETYPE = 'ASC'
              CODEPAGE = '4110'
              APPEND   = appd
              WRITE_FIELD_SEPARATOR = 'X'
*            IMPORTING
*              FILELENGTH =
            TABLES
              DATA_TAB = clientab
            EXCEPTIONS
              OTHERS = 1.
          if sy-subrc <> 0.
             rc = 4.
          endif.
          clear clientab. refresh clientab.
          rcount = 0. appd = 'A'.
       endif.
    else.
       transfer output to file.
    endif.
  endloop.

  if dwnload = 'Y'.
       SY-BATCH = SPACE.
       CALL FUNCTION 'GUI_DOWNLOAD'
         EXPORTING
           FILENAME = l_filename
           FILETYPE = 'ASC'
              CODEPAGE = '4110'
           APPEND   = appd
           WRITE_FIELD_SEPARATOR = 'X'
*         IMPORTING
*           FILELENGTH =
         TABLES
           DATA_TAB = clientab
         EXCEPTIONS
           OTHERS = 1.
          if sy-subrc <> 0.
             rc = 4.
          endif.
  else.
       close dataset file.
  endif.
endform.

FORM CONNECT_RFCDEST_TO_PROGID.
 INCLUDE rfctypes.

 DATA: len     type i,
       R3NAME(4),
       SYSTNR(2),
       uid     LIKE SYS_UID,
       options LIKE RFCOPT,
       isunicode  TYPE n.

 DATA: NTOTAL     LIKE GWY_STRUCT-NOREG,
       GWY_GWHOST LIKE GWY_STRUCT-GWHOST,
       GWY_GWSERV LIKE GWY_STRUCT-GWSERV,
       GWY_TPNAME LIKE GWY_SYSTEM-TPNAME.

 TABLES: RFCSI.

* Check program ID
 IF P_PROGID = SPACE.
    RAISE INVALID_PROGRAM_ID.
 ENDIF.

* determine if the RFC destination authority
  CALL FUNCTION 'RFC_READ_TCPIP_DESTINATION'
       EXPORTING destination = P_DEST
                 authority_check = 'X'
  IMPORTING rfcunicode = isunicode.

* Use current gateway if no info exits
 IF P_GWHOST = SPACE OR P_GWSERV = SPACE.
  CALL FUNCTION 'RFC_SYSTEM_INFO'
      IMPORTING
          RFCSI_EXPORT = RFCSI.

  len = strlen( rfcsi-rfcdest ) - 2.
  systnr = rfcsi-rfcdest+len.
  len = len - 1 - 3.
  r3name = rfcsi-rfcdest+len(3).
  len = len - 1.
  options-rfcgwhost = rfcsi-rfcdest(len).
  CONCATENATE 'sapgw' SYSTNR INTO options-rfcgwserv.
 ELSE.
   options-rfcgwhost = P_GWHOST.
   options-rfcgwserv = P_GWSERV.
 ENDIF.

* Parameters for GWY function call
  GWY_GWHOST = OPTIONS-RFCGWHOST.
  GWY_GWSERV = OPTIONS-RFCGWSERV.
  GWY_TPNAME = P_PROGID.

* Check gateway and server program registered
  CALL FUNCTION 'GWY_GET_NO_REG_PROGRAMS'
     EXPORTING
        GWHOST      = GWY_GWHOST
        GWSERV      = GWY_GWSERV
        TPNAME      = GWY_TPNAME
     IMPORTING
        NOREG_TOTAL = NTOTAL
     EXCEPTIONS
        OTHERS      = 1.

  IF sy-subrc NE 0.
     raise CONNECT_TO_GATEWAY_FAILED.
  ENDIF.

  IF NTOTAL = 0.
     raise SERVER_NOT_REGISTERED.
  ENDIF.

  IF NTOTAL GT 1.
     raise DUPLICATE_REG_PROGRAMS.
  ENDIF.

* build new connection to a registered server
  options-rfcexec   = gwy_tpname.
  options-rfcgwhost = gwy_gwhost.
  options-rfcgwserv = gwy_gwserv.
  options-rfchost   = '%%RFCSERVER%%'.
  IF P_SNC_ON = 'X'.
    options-rfcsnc  = 'X'.
  ENDIF.

  CALL 'RFCControl' ID 'CODE' FIELD 'O'
                    ID 'DESTINATION' FIELD P_DEST
                    ID 'TYPE' FIELD rfctype_external_tcp
                    ID 'OPTIONS' FIELD options.

  IF sy-subrc NE 0.
     RAISE CONNECT_TO_REG_SERVER_FAILED.
   ENDIF.

* and set exclusive mode to keep server owned
  CALL FUNCTION 'SYSTEM_SET_REG_SERVER_PROPERTY'
      EXPORTING  destination = P_DEST
                 exclusiv    = 'Y'
      EXCEPTIONS connect_to_reg_server_failed = 1
                 exclusiv_not_supported       = 2.

  IF SY-SUBRC NE 0.
     CASE SY-SUBRC.
          WHEN 1.
              RAISE CONNECT_TO_REG_SERVER_FAILED.
          WHEN 2.
              RAISE EXCLUSIV_NOT_SUPPORTED.
     ENDCASE.
  ENDIF.

ENDFORM.

FORM DISCONNECT_RFCDEST_FROM_PROGID.
* set exclusive mode to E to end the session
  CALL FUNCTION 'SYSTEM_SET_REG_SERVER_PROPERTY'
     EXPORTING
         destination = P_DEST
         exclusiv    = 'E'
     EXCEPTIONS
         connect_to_reg_server_failed = 1
         exclusiv_not_supported       = 2.
ENDFORM.
