REPORT ZAL_ABAP message-id 26 line-size 255
no standard page heading.
* Z_EXTRAC_CTA_CTE.
PARAMETER DOWNLOAD(1) DEFAULT 'S' lower case. "N-svr,Y-clnt
PARAMETER EXECMODE(1) DEFAULT 'D' lower case. "D-dlg,B-btch
PARAMETER OUT_DIR(48) DEFAULT "output file dir
'\\172.31.100.10\' lower case.
PARAMETER IN_DIR(48) DEFAULT "input file dir
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

PARAMETER $PARAM1(4) TYPE C.

PARAMETER $PARAM2 TYPE D.

PARAMETER $PARAM3 TYPE D.

PARAMETER P_DF_VK(40) DEFAULT "ABAP data flow object key
'' lower case.
PARAMETER P_DI_GEN(40) DEFAULT "DI version that generated ABAP
'' lower case.

*** Machine generated ABAP. Do not modify.            ***
*** (C)Copyright Business Objects S.A.  All rights reserved. ***
*
* Date Time:
*    06/08/16 11:29:53
* SAP used for generated this ABAP:
*    Release: 700
*    Host   : 172.31.100.10
*
* ABAP Dataflow Name:
*    EXTRAC_CTACTE
* ABAP Dataflow comments:
*  EXTRAE INFORMACION CTA CTE
* ABAP program name in SAP:
*  Z_EXTRAC_CTA_CTE
* Generated ABAP file name:
*  C:/ProgramData/SAP BusinessObjects/Data Services/workspace/Z_E
*XTR
*    AC_CTACTE
TABLES BKPF.
TABLES BSAD.
TABLES VBRK.

DATA: begin of ITAB4 occurs 0,
BUDAT TYPE D,
BUKRS(4) TYPE C,
KUNNR(10) TYPE C,
UMSKZ(1) TYPE C,
AUGDT TYPE D,
AUGBL(10) TYPE C,
ZUONR(18) TYPE C,
GJAHR(4) TYPE N,
BELNR(10) TYPE C,
BUZEI(3) TYPE N,
BLDAT TYPE D,
XBLNR(16) TYPE C,
BLART(2) TYPE C,
SHKZG(1) TYPE C,
DMBTR(16) TYPE P DECIMALS 2,
SGTXT(50) TYPE C,
HKONT(10) TYPE C,
VBELN(10) TYPE C,
VERTN(13) TYPE C,
XREF1(12) TYPE C,
XREF2(12) TYPE C,
ZNUM_DOC_CORE(10) TYPE C,
CPUDT TYPE D,
ZFBDT TYPE D.
DATA: end of ITAB4.

data: append_flag(1) value ' ',
      cntbuf type i,
      delimleng type i,last_batch(1) value ' '.

CONSTANTS C_DF_VK(40) VALUE '207'.
CONSTANTS C_DI_GEN(40) VALUE '14.1.1.210'.
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
DATA ALTMP1 TYPE D.
DATA ALTMP2(4) TYPE C.
DATA ALTMP3(10) TYPE C.
DATA ALTMP4(1) TYPE C.
DATA ALTMP5 TYPE D.
DATA ALTMP6(10) TYPE C.
DATA ALTMP7(18) TYPE C.
DATA ALTMP8(4) TYPE N.
DATA ALTMP9(10) TYPE C.
DATA ALTMP10(3) TYPE N.
DATA ALTMP11 TYPE D.
DATA ALTMP12(16) TYPE C.
DATA ALTMP13(2) TYPE C.
DATA ALTMP14(1) TYPE C.
DATA ALTMP15(16) TYPE P DECIMALS 2.
DATA ALTMP16(50) TYPE C.
DATA ALTMP17(10) TYPE C.
DATA ALTMP18(10) TYPE C.
DATA ALTMP19(13) TYPE C.
DATA ALTMP20(12) TYPE C.
DATA ALTMP21(12) TYPE C.
DATA ALTMP22(10) TYPE C.
DATA ALTMP23 TYPE D.
DATA ALTMP24 TYPE D.
DATA ALOJF0 TYPE C.
DATA ALOJF2 TYPE C.

DATA BSAD9BUDAT LIKE BSAD-BUDAT.
DATA BSAD9BUKRS LIKE BSAD-BUKRS.
DATA BSAD9KUNNR LIKE BSAD-KUNNR.
DATA BSAD9UMSKZ LIKE BSAD-UMSKZ.
DATA BSAD9AUGDT LIKE BSAD-AUGDT.
DATA BSAD9AUGBL LIKE BSAD-AUGBL.
DATA BSAD9ZUONR LIKE BSAD-ZUONR.
DATA BSAD9GJAHR LIKE BSAD-GJAHR.
DATA BSAD9BELNR LIKE BSAD-BELNR.
DATA BSAD9BUZEI LIKE BSAD-BUZEI.
DATA BSAD9BLDAT LIKE BSAD-BLDAT.
DATA BSAD9XBLNR LIKE BSAD-XBLNR.
DATA BSAD9BLART LIKE BSAD-BLART.
DATA BSAD9SHKZG LIKE BSAD-SHKZG.
DATA BSAD9DMBTR LIKE BSAD-DMBTR.
DATA BSAD9SGTXT LIKE BSAD-SGTXT.
DATA BSAD9HKONT LIKE BSAD-HKONT.
DATA BSAD9VBELN LIKE BSAD-VBELN.
DATA BSAD9VERTN LIKE BSAD-VERTN.
DATA BSAD9XREF1 LIKE BSAD-XREF1.
DATA BSAD9XREF2 LIKE BSAD-XREF2.
DATA BKPF9CPUDT LIKE BKPF-CPUDT.
DATA BSAD9ZFBDT LIKE BSAD-ZFBDT.
DATA BKPF9BUKRS LIKE BKPF-BUKRS.
DATA BKPF9BELNR LIKE BKPF-BELNR.
DATA BKPF9GJAHR LIKE BKPF-GJAHR.
DATA BSAD9KIDNO LIKE BSAD-KIDNO.



SELECT
  BSAD9~BUDAT
  BSAD9~BUKRS
  BSAD9~KUNNR
  BSAD9~UMSKZ
  BSAD9~AUGDT
  BSAD9~AUGBL
  BSAD9~ZUONR
  BSAD9~GJAHR
  BSAD9~BELNR
  BSAD9~BUZEI
  BSAD9~BLDAT
  BSAD9~XBLNR
  BSAD9~BLART
  BSAD9~SHKZG
  BSAD9~DMBTR
  BSAD9~SGTXT
  BSAD9~HKONT
  BSAD9~VBELN
  BSAD9~VERTN
  BSAD9~XREF1
  BSAD9~XREF2
  BKPF9~CPUDT
  BSAD9~ZFBDT
  BKPF9~BUKRS
  BKPF9~BELNR
  BKPF9~GJAHR
  BSAD9~KIDNO
into (BSAD9BUDAT,
  BSAD9BUKRS,
  BSAD9KUNNR,
  BSAD9UMSKZ,
  BSAD9AUGDT,
  BSAD9AUGBL,
  BSAD9ZUONR,
  BSAD9GJAHR,
  BSAD9BELNR,
  BSAD9BUZEI,
  BSAD9BLDAT,
  BSAD9XBLNR,
  BSAD9BLART,
  BSAD9SHKZG,
  BSAD9DMBTR,
  BSAD9SGTXT,
  BSAD9HKONT,
  BSAD9VBELN,
  BSAD9VERTN,
  BSAD9XREF1,
  BSAD9XREF2,
  BKPF9CPUDT,
  BSAD9ZFBDT,
  BKPF9BUKRS,
  BKPF9BELNR,
  BKPF9GJAHR,
  BSAD9KIDNO)
FROM BKPF AS BKPF9
 LEFT OUTER JOIN BSAD AS BSAD9
 ON ( ( BKPF9~GJAHR = BSAD9~GJAHR )
 AND ( ( BKPF9~BELNR = BSAD9~BELNR )
 AND ( BKPF9~BUKRS = BSAD9~BUKRS ) ) )
WHERE ( ( BKPF9~CPUDT >= $PARAM2 )
 AND ( ( BKPF9~CPUDT <= $PARAM3 )
 AND BKPF9~BUKRS IN ('CL51',
'CL06') ) ).
ALTMP1 = BSAD9BUDAT.
ALTMP2 = BSAD9BUKRS.
ALTMP3 = BSAD9KUNNR.
ALTMP4 = BSAD9UMSKZ.
ALTMP5 = BSAD9AUGDT.
ALTMP6 = BSAD9AUGBL.
ALTMP7 = BSAD9ZUONR.
ALTMP8 = BSAD9GJAHR.
ALTMP9 = BSAD9BELNR.
ALTMP10 = BSAD9BUZEI.
ALTMP11 = BSAD9BLDAT.
ALTMP12 = BSAD9XBLNR.
ALTMP13 = BSAD9BLART.
ALTMP14 = BSAD9SHKZG.
ALTMP15 = BSAD9DMBTR.
ALTMP16 = BSAD9SGTXT.
ALTMP17 = BSAD9HKONT.
ALTMP18 = BSAD9VBELN.
ALTMP19 = BSAD9VERTN.
ALTMP20 = BSAD9XREF1.
ALTMP21 = BSAD9XREF2.
ALTMP23 = BKPF9CPUDT.
ALTMP24 = BSAD9ZFBDT.
ALOJF0 = 'Y'.
ALOJF2 = 'N'.
IF ( ALOJF0 = 'Y' ).

SELECT
  ZNUM_DOC_CORE
  VBELN
INTO CORRESPONDING FIELDS OF VBRK
FROM VBRK
WHERE ( VBELN = BSAD9KIDNO ).
ALTMP22 = VBRK-ZNUM_DOC_CORE.
ALOJF2 = 'Y'.
 move ALTMP1 to ITAB4-BUDAT.
 move ALTMP2 to ITAB4-BUKRS.
 move ALTMP3 to ITAB4-KUNNR.
 move ALTMP4 to ITAB4-UMSKZ.
 move ALTMP5 to ITAB4-AUGDT.
 move ALTMP6 to ITAB4-AUGBL.
 move ALTMP7 to ITAB4-ZUONR.
 move ALTMP8 to ITAB4-GJAHR.
 move ALTMP9 to ITAB4-BELNR.
 move ALTMP10 to ITAB4-BUZEI.
 move ALTMP11 to ITAB4-BLDAT.
 move ALTMP12 to ITAB4-XBLNR.
 move ALTMP13 to ITAB4-BLART.
 move ALTMP14 to ITAB4-SHKZG.
 move ALTMP15 to ITAB4-DMBTR.
 move ALTMP16 to ITAB4-SGTXT.
 move ALTMP17 to ITAB4-HKONT.
 move ALTMP18 to ITAB4-VBELN.
 move ALTMP19 to ITAB4-VERTN.
 move ALTMP20 to ITAB4-XREF1.
 move ALTMP21 to ITAB4-XREF2.
 move ALTMP22 to ITAB4-ZNUM_DOC_CORE.
 move ALTMP23 to ITAB4-CPUDT.
 move ALTMP24 to ITAB4-ZFBDT.
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
ENDIF.
IF ( ALOJF2 = 'N' ).
clear VBRK-ZNUM_DOC_CORE.
clear VBRK-VBELN.
clear ALTMP22.
 move ALTMP1 to ITAB4-BUDAT.
 move ALTMP2 to ITAB4-BUKRS.
 move ALTMP3 to ITAB4-KUNNR.
 move ALTMP4 to ITAB4-UMSKZ.
 move ALTMP5 to ITAB4-AUGDT.
 move ALTMP6 to ITAB4-AUGBL.
 move ALTMP7 to ITAB4-ZUONR.
 move ALTMP8 to ITAB4-GJAHR.
 move ALTMP9 to ITAB4-BELNR.
 move ALTMP10 to ITAB4-BUZEI.
 move ALTMP11 to ITAB4-BLDAT.
 move ALTMP12 to ITAB4-XBLNR.
 move ALTMP13 to ITAB4-BLART.
 move ALTMP14 to ITAB4-SHKZG.
 move ALTMP15 to ITAB4-DMBTR.
 move ALTMP16 to ITAB4-SGTXT.
 move ALTMP17 to ITAB4-HKONT.
 move ALTMP18 to ITAB4-VBELN.
 move ALTMP19 to ITAB4-VERTN.
 move ALTMP20 to ITAB4-XREF1.
 move ALTMP21 to ITAB4-XREF2.
 move ALTMP22 to ITAB4-ZNUM_DOC_CORE.
 move ALTMP23 to ITAB4-CPUDT.
 move ALTMP24 to ITAB4-ZFBDT.
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
ENDIF.
ENDSELECT.
ENDFORM.

FORM FORM5.
data: outfile(128), ldfile(50).
ldfile = 'STG_EXTRAC_CTACTE.dat'.
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
append_flag = 'A'.
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
