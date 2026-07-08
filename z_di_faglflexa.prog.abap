*&---------------------------------------------------------------------*
*& Report  Z_DI_FAGLFLEXA
*&
*&---------------------------------------------------------------------*
*&   Extrae datos de FAGLFLEXA para PWC
*&
*&---------------------------------------------------------------------*

REPORT Z_DI_FAGLFLEXA message-id 26 line-size 255
no standard page heading.
* Z_DI_FAGLFLEXA.
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
*    02/10/16 17:18:06
* SAP used for generated this ABAP:
*    Release: 700
*    Host   : 172.31.100.10
*
* ABAP Dataflow Name:
*    FAGLFLEXA_ABAP
* ABAP program name in SAP:
*  Z_DI_FAGLFLEXA
* Generated ABAP file name:
*  C:/ProgramData/SAP BusinessObjects/Data Services/workspace/Z_D
*I_F
*    AGLFLEXA
TABLES FAGLFLEXA.

DATA: begin of ITAB2 occurs 0,
RCLNT(3) TYPE C,
RYEAR(4) TYPE N,
DOCNR(10) TYPE C,
RLDNR(2) TYPE C,
RBUKRS(4) TYPE C,
DOCLN(6) TYPE C,
ACTIV(4) TYPE C,
RMVCT(3) TYPE C,
RTCUR(5) TYPE C,
RUNIT(3) TYPE C,
AWTYP(5) TYPE C,
RRCTY(1) TYPE C,
RVERS(3) TYPE C,
LOGSYS(10) TYPE C,
RACCT(10) TYPE C,
COST_ELEM(10) TYPE C,
RCNTR(10) TYPE C,
PRCTR(10) TYPE C,
RFAREA(16) TYPE C,
RBUSA(4) TYPE C,
KOKRS(4) TYPE C,
SEGMENT(10) TYPE C,
ZZPRESTAC(10) TYPE C,
ZZDESC_EST(10) TYPE C,
ZZMOT_EMIS(10) TYPE C,
ZZRUT_TERC(10) TYPE C,
ZZUNID_PRO(10) TYPE C,
ZZ_AGENCIA(10) TYPE C,
SCNTR(10) TYPE C,
PPRCTR(10) TYPE C,
SFAREA(16) TYPE C,
SBUSA(4) TYPE C,
RASSC(6) TYPE C,
PSEGMENT(10) TYPE C,
TSL(16) TYPE P DECIMALS 2,
HSL(16) TYPE P DECIMALS 2,
KSL(16) TYPE P DECIMALS 2,
OSL(16) TYPE P DECIMALS 2,
MSL(16) TYPE P DECIMALS 3,
WSL(16) TYPE P DECIMALS 2,
DRCRK(1) TYPE C,
POPER(3) TYPE N,
RWCUR(5) TYPE C,
GJAHR(4) TYPE N,
BUDAT TYPE D,
BELNR(10) TYPE C,
BUZEI(3) TYPE N,
BSCHL(2) TYPE C,
BSTAT(1) TYPE C,
LINETYPE(5) TYPE C,
XSPLITMOD(1) TYPE C,
USNAM(12) TYPE C,
TIMESTAMP(16) TYPE P DECIMALS 0.
DATA: end of ITAB2.

data: append_flag(1) value ' ',
      cntbuf type i,
      delimleng type i,last_batch(1) value ' '.

CONSTANTS C_DF_VK(40) VALUE '586'.
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



PERFORM FORM2.
last_batch = 'X'.
PERFORM FORM3.
FREE ITAB2.
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

FORM FORM2.
DATA ALTMP1(3) TYPE C.
DATA ALTMP2(4) TYPE N.
DATA ALTMP3(10) TYPE C.
DATA ALTMP4(2) TYPE C.
DATA ALTMP5(4) TYPE C.
DATA ALTMP6(6) TYPE C.
DATA ALTMP7(4) TYPE C.
DATA ALTMP8(3) TYPE C.
DATA ALTMP9(5) TYPE C.
DATA ALTMP10(3) TYPE C.
DATA ALTMP11(5) TYPE C.
DATA ALTMP12(1) TYPE C.
DATA ALTMP13(3) TYPE C.
DATA ALTMP14(10) TYPE C.
DATA ALTMP15(10) TYPE C.
DATA ALTMP16(10) TYPE C.
DATA ALTMP17(10) TYPE C.
DATA ALTMP18(10) TYPE C.
DATA ALTMP19(16) TYPE C.
DATA ALTMP20(4) TYPE C.
DATA ALTMP21(4) TYPE C.
DATA ALTMP22(10) TYPE C.
DATA ALTMP23(10) TYPE C.
DATA ALTMP24(10) TYPE C.
DATA ALTMP25(10) TYPE C.
DATA ALTMP26(10) TYPE C.
DATA ALTMP27(10) TYPE C.
DATA ALTMP28(10) TYPE C.
DATA ALTMP29(10) TYPE C.
DATA ALTMP30(10) TYPE C.
DATA ALTMP31(16) TYPE C.
DATA ALTMP32(4) TYPE C.
DATA ALTMP33(6) TYPE C.
DATA ALTMP34(10) TYPE C.
DATA ALTMP35(16) TYPE P DECIMALS 2.
DATA ALTMP36(16) TYPE P DECIMALS 2.
DATA ALTMP37(16) TYPE P DECIMALS 2.
DATA ALTMP38(16) TYPE P DECIMALS 2.
DATA ALTMP39(16) TYPE P DECIMALS 3.
DATA ALTMP40(16) TYPE P DECIMALS 2.
DATA ALTMP41(1) TYPE C.
DATA ALTMP42(3) TYPE N.
DATA ALTMP43(5) TYPE C.
DATA ALTMP44(4) TYPE N.
DATA ALTMP45 TYPE D.
DATA ALTMP46(10) TYPE C.
DATA ALTMP47(3) TYPE N.
DATA ALTMP48(2) TYPE C.
DATA ALTMP49(1) TYPE C.
DATA ALTMP50(5) TYPE C.
DATA ALTMP51(1) TYPE C.
DATA ALTMP52(12) TYPE C.
DATA ALTMP53(16) TYPE P DECIMALS 0.




SELECT
  RCLNT
  RYEAR
  DOCNR
  RLDNR
  RBUKRS
  DOCLN
  ACTIV
  RMVCT
  RTCUR
  RUNIT
  AWTYP
  RRCTY
  RVERS
  LOGSYS
  RACCT
  COST_ELEM
  RCNTR
  PRCTR
  RFAREA
  RBUSA
  KOKRS
  SEGMENT
  ZZPRESTAC
  ZZDESC_EST
  ZZMOT_EMIS
  ZZRUT_TERC
  ZZUNID_PRO
  ZZ_AGENCIA
  SCNTR
  PPRCTR
  SFAREA
  SBUSA
  RASSC
  PSEGMENT
  TSL
  HSL
  KSL
  OSL
  MSL
  WSL
  DRCRK
  POPER
  RWCUR
  GJAHR
  BUDAT
  BELNR
  BUZEI
  BSCHL
  BSTAT
  LINETYPE
  XSPLITMOD
  USNAM
  TIMESTAMP
INTO CORRESPONDING FIELDS OF FAGLFLEXA
FROM FAGLFLEXA
WHERE ( ( BUDAT <= $PARAM3 )
 AND ( ( BUDAT >= $PARAM2 )
 AND ( RBUKRS IN ('CL24',
'CL01')
 AND ( ( RLDNR = '1S' )
 AND ( RYEAR = $PARAM1 ) ) ) ) ).
ALTMP1 = FAGLFLEXA-RCLNT.
ALTMP2 = FAGLFLEXA-RYEAR.
ALTMP3 = FAGLFLEXA-DOCNR.
ALTMP4 = FAGLFLEXA-RLDNR.
ALTMP5 = FAGLFLEXA-RBUKRS.
ALTMP6 = FAGLFLEXA-DOCLN.
ALTMP7 = FAGLFLEXA-ACTIV.
ALTMP8 = FAGLFLEXA-RMVCT.
ALTMP9 = FAGLFLEXA-RTCUR.
ALTMP10 = FAGLFLEXA-RUNIT.
ALTMP11 = FAGLFLEXA-AWTYP.
ALTMP12 = FAGLFLEXA-RRCTY.
ALTMP13 = FAGLFLEXA-RVERS.
ALTMP14 = FAGLFLEXA-LOGSYS.
ALTMP15 = FAGLFLEXA-RACCT.
ALTMP16 = FAGLFLEXA-COST_ELEM.
ALTMP17 = FAGLFLEXA-RCNTR.
ALTMP18 = FAGLFLEXA-PRCTR.
ALTMP19 = FAGLFLEXA-RFAREA.
ALTMP20 = FAGLFLEXA-RBUSA.
ALTMP21 = FAGLFLEXA-KOKRS.
ALTMP22 = FAGLFLEXA-SEGMENT.
ALTMP23 = FAGLFLEXA-ZZPRESTAC.
ALTMP24 = FAGLFLEXA-ZZDESC_EST.
ALTMP25 = FAGLFLEXA-ZZMOT_EMIS.
ALTMP26 = FAGLFLEXA-ZZRUT_TERC.
ALTMP27 = FAGLFLEXA-ZZUNID_PRO.
ALTMP28 = FAGLFLEXA-ZZ_AGENCIA.
ALTMP29 = FAGLFLEXA-SCNTR.
ALTMP30 = FAGLFLEXA-PPRCTR.
ALTMP31 = FAGLFLEXA-SFAREA.
ALTMP32 = FAGLFLEXA-SBUSA.
ALTMP33 = FAGLFLEXA-RASSC.
ALTMP34 = FAGLFLEXA-PSEGMENT.
ALTMP35 = FAGLFLEXA-TSL.
ALTMP36 = FAGLFLEXA-HSL.
ALTMP37 = FAGLFLEXA-KSL.
ALTMP38 = FAGLFLEXA-OSL.
ALTMP39 = FAGLFLEXA-MSL.
ALTMP40 = FAGLFLEXA-WSL.
ALTMP41 = FAGLFLEXA-DRCRK.
ALTMP42 = FAGLFLEXA-POPER.
ALTMP43 = FAGLFLEXA-RWCUR.
ALTMP44 = FAGLFLEXA-GJAHR.
ALTMP45 = FAGLFLEXA-BUDAT.
ALTMP46 = FAGLFLEXA-BELNR.
ALTMP47 = FAGLFLEXA-BUZEI.
ALTMP48 = FAGLFLEXA-BSCHL.
ALTMP49 = FAGLFLEXA-BSTAT.
ALTMP50 = FAGLFLEXA-LINETYPE.
ALTMP51 = FAGLFLEXA-XSPLITMOD.
ALTMP52 = FAGLFLEXA-USNAM.
ALTMP53 = FAGLFLEXA-TIMESTAMP.
 move ALTMP1 to ITAB2-RCLNT.
 move ALTMP2 to ITAB2-RYEAR.
 move ALTMP3 to ITAB2-DOCNR.
 move ALTMP4 to ITAB2-RLDNR.
 move ALTMP5 to ITAB2-RBUKRS.
 move ALTMP6 to ITAB2-DOCLN.
 move ALTMP7 to ITAB2-ACTIV.
 move ALTMP8 to ITAB2-RMVCT.
 move ALTMP9 to ITAB2-RTCUR.
 move ALTMP10 to ITAB2-RUNIT.
 move ALTMP11 to ITAB2-AWTYP.
 move ALTMP12 to ITAB2-RRCTY.
 move ALTMP13 to ITAB2-RVERS.
 move ALTMP14 to ITAB2-LOGSYS.
 move ALTMP15 to ITAB2-RACCT.
 move ALTMP16 to ITAB2-COST_ELEM.
 move ALTMP17 to ITAB2-RCNTR.
 move ALTMP18 to ITAB2-PRCTR.
 move ALTMP19 to ITAB2-RFAREA.
 move ALTMP20 to ITAB2-RBUSA.
 move ALTMP21 to ITAB2-KOKRS.
 move ALTMP22 to ITAB2-SEGMENT.
 move ALTMP23 to ITAB2-ZZPRESTAC.
 move ALTMP24 to ITAB2-ZZDESC_EST.
 move ALTMP25 to ITAB2-ZZMOT_EMIS.
 move ALTMP26 to ITAB2-ZZRUT_TERC.
 move ALTMP27 to ITAB2-ZZUNID_PRO.
 move ALTMP28 to ITAB2-ZZ_AGENCIA.
 move ALTMP29 to ITAB2-SCNTR.
 move ALTMP30 to ITAB2-PPRCTR.
 move ALTMP31 to ITAB2-SFAREA.
 move ALTMP32 to ITAB2-SBUSA.
 move ALTMP33 to ITAB2-RASSC.
 move ALTMP34 to ITAB2-PSEGMENT.
 move ALTMP35 to ITAB2-TSL.
 move ALTMP36 to ITAB2-HSL.
 move ALTMP37 to ITAB2-KSL.
 move ALTMP38 to ITAB2-OSL.
 move ALTMP39 to ITAB2-MSL.
 move ALTMP40 to ITAB2-WSL.
 move ALTMP41 to ITAB2-DRCRK.
 move ALTMP42 to ITAB2-POPER.
 move ALTMP43 to ITAB2-RWCUR.
 move ALTMP44 to ITAB2-GJAHR.
 move ALTMP45 to ITAB2-BUDAT.
 move ALTMP46 to ITAB2-BELNR.
 move ALTMP47 to ITAB2-BUZEI.
 move ALTMP48 to ITAB2-BSCHL.
 move ALTMP49 to ITAB2-BSTAT.
 move ALTMP50 to ITAB2-LINETYPE.
 move ALTMP51 to ITAB2-XSPLITMOD.
 move ALTMP52 to ITAB2-USNAM.
 move ALTMP53 to ITAB2-TIMESTAMP.
 append ITAB2.
 cntbuf = cntbuf + 1.
 if download = 'N'.
  if cntbuf > 5000.
    perform FORM3.
    clear cntbuf.
    refresh ITAB2.
    append_flag = 'A'.
  endif.
 endif.
 if download = 'S'.
  if cntbuf > P_PKGSZ.
    perform FORM3.
    clear cntbuf.
    refresh ITAB2.
  endif.
 endif.
ENDSELECT.
ENDFORM.

FORM FORM3.
data: outfile(128), ldfile(50).
ldfile = 'FI_S_STG_MOVIMIENTO_CONTABLE_PASO1_R3.dat'.
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
            E_TABLE = ITAB2
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
           tables   ITAB2
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
