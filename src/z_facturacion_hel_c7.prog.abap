*&---------------------------------------------------------------------*
*& Report Z_FACTURACION_HEL_C7
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*


REPORT Z_FACTURACION_HEL_C7 message-id 26 line-size 255

no standard page heading.
* Z_FACTURACION_HEL_C7.
PARAMETER DOWNLOAD(1) DEFAULT 'S' lower case. "N-svr,Y-clnt
PARAMETER EXECMODE(1) DEFAULT 'D' lower case. "D-dlg,B-btch
PARAMETER OUT_DIR(230) DEFAULT "output file dir
'\\172.31.100.10\' lower case.
PARAMETER IN_DIR(230) DEFAULT "input file dir
'\\172.31.100.10\' lower case.
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

PARAMETER $PARAM1 TYPE I.

PARAMETER $PARAM2(4) TYPE C.

PARAMETER $PARAM3 TYPE D.

PARAMETER $PARAM4 TYPE D.

PARAMETER $PARAM5 TYPE D.

PARAMETER $PARAM6 TYPE D.

PARAMETER P_DF_VK(40) DEFAULT "ABAP data flow object key
'' lower case.
PARAMETER P_DI_GEN(40) DEFAULT "DI version that generated ABAP
'' lower case.

*** Machine generated ABAP. Do not modify.            ***
*** (C)Copyright Business Objects S.A.  All rights reserved. ***
*
* Date Time:
*    01/11/22 12:44:32
* SAP used for generated this ABAP:
*    Release: 750
*    Host   : 172.31.100.100
*
* ABAP Dataflow Name:
*    Z_FACTURACION_HEL_C7
* ABAP program name in SAP:
*  Z_FACTURACION_HEL_C7
* Generated ABAP file name:
*  C:/ProgramData/SAP BusinessObjects/Data Services/workspace/Z_F
*ACT
*    URACION_HEL_C7
TABLES VBRK.
TABLES BSEG.
TABLES BKPF.

DATA: begin of ITAB4 occurs 0,
BUKRS(4) TYPE C,
BUZEI(3) TYPE N,
AWKEY(20) TYPE C,
BLART(2) TYPE C,
XBLNR(16) TYPE C,
BELNR(10) TYPE C,
BUDAT TYPE D,
VBEL2(10) TYPE C,
MATNR(18) TYPE C,
KOSTL(10) TYPE C,
ZZRUT_TERC(10) TYPE C,
VERTN(13) TYPE C,
ZUONR(18) TYPE C,
WERKS(4) TYPE C,
PSWBT(16) TYPE P DECIMALS 2,
PSWSL(5) TYPE C,
ZFBDT TYPE D,
ZTERM(4) TYPE C,
FDGRP(10) TYPE C,
FDTAG TYPE D,
MWSKZ(2) TYPE C,
HKONT(10) TYPE C,
AUGBL(10) TYPE C,
AUGCP TYPE D,
PRCTR(10) TYPE C,
GJAHR(4) TYPE N,
KOART(1) TYPE C,
MWART(1) TYPE C,
STBLG(10) TYPE C,
VBELN(10) TYPE C,
FKART(4) TYPE C,
ZNUM_DOC_CORE(10) TYPE C,
VKORG(4) TYPE C,
VTWEG(2) TYPE C,
SPART(2) TYPE C,
KUNRG(10) TYPE C,
ZLSCH(1) TYPE C,
SHKZG(1) TYPE C.
DATA: end of ITAB4.

data: append_flag(1) value ' ',
      cntbuf type i,
      delimleng type i,last_batch(1) value ' '.

CONSTANTS C_DF_VK(40) VALUE '289'.
CONSTANTS C_DI_GEN(40) VALUE '14.2.13.2467'.
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



PERFORM FORM4.
last_batch = 'X'.
PERFORM FORM5.
FREE ITAB4.
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

FORM FORM4.
DATA ALTMP1(4) TYPE C.
DATA ALTMP2(3) TYPE N.
DATA ALTMP3(20) TYPE C.
DATA ALTMP4(2) TYPE C.
DATA ALTMP5(16) TYPE C.
DATA ALTMP6(10) TYPE C.
DATA ALTMP7 TYPE D.
DATA ALTMP8(10) TYPE C.
DATA ALTMP9(18) TYPE C.
DATA ALTMP10(10) TYPE C.
DATA ALTMP11(10) TYPE C.
DATA ALTMP12(13) TYPE C.
DATA ALTMP13(18) TYPE C.
DATA ALTMP14(4) TYPE C.
DATA ALTMP15(16) TYPE P DECIMALS 2.
DATA ALTMP16(5) TYPE C.
DATA ALTMP17 TYPE D.
DATA ALTMP18(4) TYPE C.
DATA ALTMP19(10) TYPE C.
DATA ALTMP20 TYPE D.
DATA ALTMP21(2) TYPE C.
DATA ALTMP22(10) TYPE C.
DATA ALTMP23(10) TYPE C.
DATA ALTMP24 TYPE D.
DATA ALTMP25(10) TYPE C.
DATA ALTMP26(4) TYPE N.
DATA ALTMP27(1) TYPE C.
DATA ALTMP28(1) TYPE C.
DATA ALTMP29(10) TYPE C.
DATA ALTMP30(10) TYPE C.
DATA ALTMP31(4) TYPE C.
DATA ALTMP32(10) TYPE C.
DATA ALTMP33(4) TYPE C.
DATA ALTMP34(2) TYPE C.
DATA ALTMP35(2) TYPE C.
DATA ALTMP36(10) TYPE C.
DATA ALTMP37(1) TYPE C.
DATA ALTMP38(1) TYPE C.

DATA BKPF9BUKRS LIKE BKPF-BUKRS.
DATA BKPF9AWKEY LIKE BKPF-AWKEY.
DATA BKPF9BLART LIKE BKPF-BLART.
DATA BKPF9XBLNR LIKE BKPF-XBLNR.
DATA BKPF9BELNR LIKE BKPF-BELNR.
DATA BKPF9BUDAT LIKE BKPF-BUDAT.
DATA BKPF9GJAHR LIKE BKPF-GJAHR.
DATA BKPF9STBLG LIKE BKPF-STBLG.
DATA VBRK9VBELN LIKE VBRK-VBELN.
DATA VBRK9FKART LIKE VBRK-FKART.
DATA VBRK9ZNUM_DOC_CORE LIKE VBRK-ZNUM_DOC_CORE.
DATA VBRK9VKORG LIKE VBRK-VKORG.
DATA VBRK9VTWEG LIKE VBRK-VTWEG.
DATA VBRK9SPART LIKE VBRK-SPART.
DATA VBRK9KUNRG LIKE VBRK-KUNRG.
DATA VBRK9ZLSCH LIKE VBRK-ZLSCH.
DATA BKPF9CPUDT LIKE BKPF-CPUDT.
DATA VBRK9BUKRS LIKE VBRK-BUKRS.



SELECT
  BKPF9~BUKRS
  BKPF9~AWKEY
  BKPF9~BLART
  BKPF9~XBLNR
  BKPF9~BELNR
  BKPF9~BUDAT
  BKPF9~GJAHR
  BKPF9~STBLG
  VBRK9~VBELN
  VBRK9~FKART
  VBRK9~ZNUM_DOC_CORE
  VBRK9~VKORG
  VBRK9~VTWEG
  VBRK9~SPART
  VBRK9~KUNRG
  VBRK9~ZLSCH
  BKPF9~CPUDT
  VBRK9~BUKRS
into (BKPF9BUKRS,
  BKPF9AWKEY,
  BKPF9BLART,
  BKPF9XBLNR,
  BKPF9BELNR,
  BKPF9BUDAT,
  BKPF9GJAHR,
  BKPF9STBLG,
  VBRK9VBELN,
  VBRK9FKART,
  VBRK9ZNUM_DOC_CORE,
  VBRK9VKORG,
  VBRK9VTWEG,
  VBRK9SPART,
  VBRK9KUNRG,
  VBRK9ZLSCH,
  BKPF9CPUDT,
  VBRK9BUKRS)
FROM BKPF AS BKPF9
 INNER JOIN VBRK AS VBRK9
 ON ( ( BKPF9~AWKEY = VBRK9~VBELN )
 AND ( BKPF9~BUKRS = VBRK9~BUKRS ) )
WHERE ( ( BKPF9~CPUDT <= $PARAM6 )
 AND ( ( BKPF9~CPUDT >= $PARAM5 )
 AND ( ( BKPF9~BUDAT <= $PARAM4 )
 AND ( ( BKPF9~BUDAT >= $PARAM3 )
 AND ( ( BKPF9~GJAHR = $PARAM1 )
 AND ( BKPF9~BUKRS = $PARAM2 ) ) ) ) ) ).
ALTMP1 = BKPF9BUKRS.
ALTMP3 = BKPF9AWKEY.
ALTMP4 = BKPF9BLART.
ALTMP5 = BKPF9XBLNR.
ALTMP6 = BKPF9BELNR.
ALTMP7 = BKPF9BUDAT.
ALTMP26 = BKPF9GJAHR.
ALTMP29 = BKPF9STBLG.
ALTMP30 = VBRK9VBELN.
ALTMP31 = VBRK9FKART.
ALTMP32 = VBRK9ZNUM_DOC_CORE.
ALTMP33 = VBRK9VKORG.
ALTMP34 = VBRK9VTWEG.
ALTMP35 = VBRK9SPART.
ALTMP36 = VBRK9KUNRG.
ALTMP37 = VBRK9ZLSCH.

SELECT
  BUZEI
  VBEL2
  MATNR
  KOSTL
  ZZRUT_TERC
  VERTN
  ZUONR
  WERKS
  PSWBT
  PSWSL
  ZFBDT
  ZTERM
  FDGRP
  FDTAG
  MWSKZ
  HKONT
  AUGBL
  AUGCP
  PRCTR
  KOART
  MWART
  SHKZG
  BELNR
  BUKRS
  GJAHR
INTO CORRESPONDING FIELDS OF BSEG
FROM BSEG
WHERE ( ( GJAHR = BKPF9GJAHR )
 AND ( ( BUKRS = BKPF9BUKRS )
 AND ( BELNR = BKPF9BELNR ) ) ).
ALTMP2 = BSEG-BUZEI.
ALTMP8 = BSEG-VBEL2.
ALTMP9 = BSEG-MATNR.
ALTMP10 = BSEG-KOSTL.
ALTMP11 = BSEG-ZZRUT_TERC.
ALTMP12 = BSEG-VERTN.
ALTMP13 = BSEG-ZUONR.
ALTMP14 = BSEG-WERKS.
ALTMP15 = BSEG-PSWBT.
ALTMP16 = BSEG-PSWSL.
ALTMP17 = BSEG-ZFBDT.
ALTMP18 = BSEG-ZTERM.
ALTMP19 = BSEG-FDGRP.
ALTMP20 = BSEG-FDTAG.
ALTMP21 = BSEG-MWSKZ.
ALTMP22 = BSEG-HKONT.
ALTMP23 = BSEG-AUGBL.
ALTMP24 = BSEG-AUGCP.
ALTMP25 = BSEG-PRCTR.
ALTMP27 = BSEG-KOART.
ALTMP28 = BSEG-MWART.
ALTMP38 = BSEG-SHKZG.
 move ALTMP1 to ITAB4-BUKRS.
 move ALTMP2 to ITAB4-BUZEI.
 move ALTMP3 to ITAB4-AWKEY.
 move ALTMP4 to ITAB4-BLART.
 move ALTMP5 to ITAB4-XBLNR.
 move ALTMP6 to ITAB4-BELNR.
 move ALTMP7 to ITAB4-BUDAT.
 move ALTMP8 to ITAB4-VBEL2.
 move ALTMP9 to ITAB4-MATNR.
 move ALTMP10 to ITAB4-KOSTL.
 move ALTMP11 to ITAB4-ZZRUT_TERC.
 move ALTMP12 to ITAB4-VERTN.
 move ALTMP13 to ITAB4-ZUONR.
 move ALTMP14 to ITAB4-WERKS.
 move ALTMP15 to ITAB4-PSWBT.
 move ALTMP16 to ITAB4-PSWSL.
 move ALTMP17 to ITAB4-ZFBDT.
 move ALTMP18 to ITAB4-ZTERM.
 move ALTMP19 to ITAB4-FDGRP.
 move ALTMP20 to ITAB4-FDTAG.
 move ALTMP21 to ITAB4-MWSKZ.
 move ALTMP22 to ITAB4-HKONT.
 move ALTMP23 to ITAB4-AUGBL.
 move ALTMP24 to ITAB4-AUGCP.
 move ALTMP25 to ITAB4-PRCTR.
 move ALTMP26 to ITAB4-GJAHR.
 move ALTMP27 to ITAB4-KOART.
 move ALTMP28 to ITAB4-MWART.
 move ALTMP29 to ITAB4-STBLG.
 move ALTMP30 to ITAB4-VBELN.
 move ALTMP31 to ITAB4-FKART.
 move ALTMP32 to ITAB4-ZNUM_DOC_CORE.
 move ALTMP33 to ITAB4-VKORG.
 move ALTMP34 to ITAB4-VTWEG.
 move ALTMP35 to ITAB4-SPART.
 move ALTMP36 to ITAB4-KUNRG.
 move ALTMP37 to ITAB4-ZLSCH.
 move ALTMP38 to ITAB4-SHKZG.
 append ITAB4.
 cntbuf = cntbuf + 1.
 if download = 'N'.
  if cntbuf > 5000.
    perform FORM5.
    clear cntbuf.
    refresh ITAB4.
    append_flag = 'A'.
  endif.
 endif.
 if download = 'S'.
  if cntbuf > P_PKGSZ.
    perform FORM5.
    clear cntbuf.
    refresh ITAB4.
  endif.
 endif.
ENDSELECT.
ENDSELECT.
ENDFORM.

FORM FORM5.
data: outfile(512), ldfile(50).
ldfile = 'Z_SALIDA_HEL.dat'.
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
            E_TABLE = ITAB4
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
           tables   ITAB4
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
