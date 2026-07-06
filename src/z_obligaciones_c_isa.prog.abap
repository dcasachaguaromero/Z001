REPORT Z_OBLIGACIONES_C_ISA message-id 26 line-size 255
no standard page heading.
* Z_OBLIGACIONES_C_ISA.
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

PARAMETER P_DF_VK(40) DEFAULT "ABAP data flow object key
'' lower case.
PARAMETER P_DI_GEN(40) DEFAULT "DI version that generated ABAP
'' lower case.

*** Machine generated ABAP. Do not modify.            ***
*** (C)Copyright Business Objects S.A.  All rights reserved. ***
*
* Date Time:
*    12/18/18 17:34:43
* SAP used for generated this ABAP:
*    Release: 700
*    Host   : 172.31.100.100
*
* ABAP Dataflow Name:
*    ABAP_OB_2
* ABAP program name in SAP:
*  Z_OBLIGACIONES_C_ISA
* Generated ABAP file name:
*  C:/ProgramData/SAP BusinessObjects/Data Services/workspace/Z_O
*BLI
*    GACIONES_C_ISA
TABLES BKPF.
TABLES BSAK.
TABLES LFA1.
TABLES PAYR.

DATA: begin of ITAB3 occurs 0,
BUKRS(4) TYPE C,
BELNR(10) TYPE C,
GJAHR(4) TYPE N,
XBLNR(16) TYPE C,
STBLG(10) TYPE C,
BKTXT(25) TYPE C,
AWKEY(20) TYPE C,
XREF2_HD(20) TYPE C,
LIFNR(10) TYPE C,
BUDAT TYPE D,
BLDAT TYPE D,
CPUDT TYPE D,
AUGBL(10) TYPE C,
AUGDT TYPE D,
ZUONR(18) TYPE C,
BLART(2) TYPE C,
SHKZG(1) TYPE C,
DMBTR(16) TYPE P DECIMALS 2,
SGTXT(50) TYPE C,
HKONT(10) TYPE C,
ZFBDT TYPE D,
ZLSCH(1) TYPE C,
HBKID(5) TYPE C,
XREF1(12) TYPE C,
XREF2(12) TYPE C,
XREF3(20) TYPE C,
ZZMOT_EMIS(10) TYPE C,
ZZRUT_TERC(10) TYPE C,
ZZ_AGENCIA(10) TYPE C,
BUZEI(3) TYPE N.
DATA: end of ITAB3.

DATA: begin of ITAB6 occurs 0,
BUKRS(4) TYPE C,
BELNR(10) TYPE C,
GJAHR(4) TYPE N,
XBLNR(16) TYPE C,
STBLG(10) TYPE C,
BKTXT(25) TYPE C,
AWKEY(20) TYPE C,
XREF2_HD(20) TYPE C,
LIFNR(10) TYPE C,
STCD1(16) TYPE C,
NOMBRE(76) TYPE C,
BUDAT TYPE D,
BLDAT TYPE D,
CPUDT TYPE D,
AUGBL(10) TYPE C,
AUGDT TYPE D,
ZUONR(18) TYPE C,
BLART(2) TYPE C,
SHKZG(1) TYPE C,
DMBTR(16) TYPE P DECIMALS 2,
SGTXT(50) TYPE C,
HKONT(10) TYPE C,
ZFBDT TYPE D,
ZLSCH(1) TYPE C,
HBKID(5) TYPE C,
XREF1(12) TYPE C,
XREF2(12) TYPE C,
XREF3(20) TYPE C,
ZZMOT_EMIS(10) TYPE C,
ZZRUT_TERC(10) TYPE C,
ZZ_AGENCIA(10) TYPE C,
LAUFD TYPE D,
LAUFI(6) TYPE C,
CHECF(13) TYPE C,
PRIDT TYPE D,
PRIUS(12) TYPE C,
XBANC(1) TYPE C,
BANCD TYPE D,
BUZEI(3) TYPE N.
DATA: end of ITAB6.

data: append_flag(1) value ' ',
      cntbuf type i,
      delimleng type i,last_batch(1) value ' '.

CONSTANTS C_DF_VK(40) VALUE '311'.
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
PERFORM FORM6.
FREE ITAB3.
last_batch = 'X'.
PERFORM FORM7.
FREE ITAB6.
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
STATICS rowCount TYPE i VALUE 0.
DATA ALTMP1(4) TYPE C.
DATA ALTMP2(10) TYPE C.
DATA ALTMP3(4) TYPE N.
DATA ALTMP4(16) TYPE C.
DATA ALTMP5(10) TYPE C.
DATA ALTMP6(25) TYPE C.
DATA ALTMP7(20) TYPE C.
DATA ALTMP8(20) TYPE C.
DATA ALTMP9(10) TYPE C.
DATA ALTMP10 TYPE D.
DATA ALTMP11 TYPE D.
DATA ALTMP12 TYPE D.
DATA ALTMP13(10) TYPE C.
DATA ALTMP14 TYPE D.
DATA ALTMP15(18) TYPE C.
DATA ALTMP16(2) TYPE C.
DATA ALTMP17(1) TYPE C.
DATA ALTMP18(16) TYPE P DECIMALS 2.
DATA ALTMP19(50) TYPE C.
DATA ALTMP20(10) TYPE C.
DATA ALTMP21 TYPE D.
DATA ALTMP22(1) TYPE C.
DATA ALTMP23(5) TYPE C.
DATA ALTMP24(12) TYPE C.
DATA ALTMP25(12) TYPE C.
DATA ALTMP26(20) TYPE C.
DATA ALTMP27(10) TYPE C.
DATA ALTMP28(10) TYPE C.
DATA ALTMP29(10) TYPE C.
DATA ALTMP30(3) TYPE N.

DATA BKPF9BUKRS LIKE BKPF-BUKRS.
DATA BKPF9BELNR LIKE BKPF-BELNR.
DATA BKPF9GJAHR LIKE BKPF-GJAHR.
DATA BKPF9XBLNR LIKE BKPF-XBLNR.
DATA BKPF9STBLG LIKE BKPF-STBLG.
DATA BKPF9BKTXT LIKE BKPF-BKTXT.
DATA BKPF9AWKEY LIKE BKPF-AWKEY.
DATA BKPF9XREF2_HD LIKE BKPF-XREF2_HD.
DATA BSAK9LIFNR LIKE BSAK-LIFNR.
DATA BSAK9BUDAT LIKE BSAK-BUDAT.
DATA BSAK9BLDAT LIKE BSAK-BLDAT.
DATA BSAK9CPUDT LIKE BSAK-CPUDT.
DATA BSAK9AUGBL LIKE BSAK-AUGBL.
DATA BSAK9AUGDT LIKE BSAK-AUGDT.
DATA BSAK9ZUONR LIKE BSAK-ZUONR.
DATA BSAK9BLART LIKE BSAK-BLART.
DATA BSAK9SHKZG LIKE BSAK-SHKZG.
DATA BSAK9DMBTR LIKE BSAK-DMBTR.
DATA BSAK9SGTXT LIKE BSAK-SGTXT.
DATA BSAK9HKONT LIKE BSAK-HKONT.
DATA BSAK9ZFBDT LIKE BSAK-ZFBDT.
DATA BSAK9ZLSCH LIKE BSAK-ZLSCH.
DATA BSAK9HBKID LIKE BSAK-HBKID.
DATA BSAK9XREF1 LIKE BSAK-XREF1.
DATA BSAK9XREF2 LIKE BSAK-XREF2.
DATA BSAK9XREF3 LIKE BSAK-XREF3.
DATA BSAK9ZZMOT_EMIS LIKE BSAK-ZZMOT_EMIS.
DATA BSAK9ZZRUT_TERC LIKE BSAK-ZZRUT_TERC.
DATA BSAK9ZZ_AGENCIA LIKE BSAK-ZZ_AGENCIA.
DATA BSAK9BUZEI LIKE BSAK-BUZEI.
DATA BKPF9CPUDT LIKE BKPF-CPUDT.
DATA BSAK9BUKRS LIKE BSAK-BUKRS.
DATA BSAK9GJAHR LIKE BSAK-GJAHR.
DATA BSAK9BELNR LIKE BSAK-BELNR.



SELECT
  BKPF9~BUKRS
  BKPF9~BELNR
  BKPF9~GJAHR
  BKPF9~XBLNR
  BKPF9~STBLG
  BKPF9~BKTXT
  BKPF9~AWKEY
  BKPF9~XREF2_HD
  BSAK9~LIFNR
  BSAK9~BUDAT
  BSAK9~BLDAT
  BSAK9~CPUDT
  BSAK9~AUGBL
  BSAK9~AUGDT
  BSAK9~ZUONR
  BSAK9~BLART
  BSAK9~SHKZG
  BSAK9~DMBTR
  BSAK9~SGTXT
  BSAK9~HKONT
  BSAK9~ZFBDT
  BSAK9~ZLSCH
  BSAK9~HBKID
  BSAK9~XREF1
  BSAK9~XREF2
  BSAK9~XREF3
  BSAK9~ZZMOT_EMIS
  BSAK9~ZZRUT_TERC
  BSAK9~ZZ_AGENCIA
  BSAK9~BUZEI
  BKPF9~CPUDT
  BSAK9~BUKRS
  BSAK9~GJAHR
  BSAK9~BELNR
into (BKPF9BUKRS,
  BKPF9BELNR,
  BKPF9GJAHR,
  BKPF9XBLNR,
  BKPF9STBLG,
  BKPF9BKTXT,
  BKPF9AWKEY,
  BKPF9XREF2_HD,
  BSAK9LIFNR,
  BSAK9BUDAT,
  BSAK9BLDAT,
  BSAK9CPUDT,
  BSAK9AUGBL,
  BSAK9AUGDT,
  BSAK9ZUONR,
  BSAK9BLART,
  BSAK9SHKZG,
  BSAK9DMBTR,
  BSAK9SGTXT,
  BSAK9HKONT,
  BSAK9ZFBDT,
  BSAK9ZLSCH,
  BSAK9HBKID,
  BSAK9XREF1,
  BSAK9XREF2,
  BSAK9XREF3,
  BSAK9ZZMOT_EMIS,
  BSAK9ZZRUT_TERC,
  BSAK9ZZ_AGENCIA,
  BSAK9BUZEI,
  BKPF9CPUDT,
  BSAK9BUKRS,
  BSAK9GJAHR,
  BSAK9BELNR)
FROM BKPF AS BKPF9
 INNER JOIN BSAK AS BSAK9
 ON ( ( BSAK9~BELNR = BKPF9~BELNR )
 AND ( ( BSAK9~GJAHR = BKPF9~GJAHR )
 AND ( BSAK9~BUKRS = BKPF9~BUKRS ) ) )
WHERE ( BSAK9~BLART IN ('Z1',
'Z3',
'Z4',
'Z5',
'Z6',
'XG',
'XB',
'XC',
'SA',
'AB',
'B1',
'B2',
'B3',
'B4',
'B5',
'D1',
'D2',
'D3',
'D4',
'E1',
'E2',
'F0',
'F1',
'F2',
'F3',
'F4',
'F5',
'F6',
'F7',
'F8',
'F9',
'FA',
'FB',
'FC',
'FI',
'FR',
'I1',
'I2',
'N0',
'N1',
'N2',
'N3',
'N4',
'NA',
'NB',
'NC',
'NR',
'ZP')
 AND ( ( BSAK9~ZLSCH = 'C' )
 AND ( ( BKPF9~CPUDT <= $PARAM5 )
 AND ( ( BKPF9~CPUDT >= $PARAM4 )
 AND ( ( BKPF9~GJAHR <= $PARAM3 )
 AND ( ( BKPF9~GJAHR >= $PARAM2 )
 AND ( BKPF9~BUKRS = $PARAM1 ) ) ) ) ) ) ).
ALTMP1 = BKPF9BUKRS.
ALTMP2 = BKPF9BELNR.
ALTMP3 = BKPF9GJAHR.
ALTMP4 = BKPF9XBLNR.
ALTMP5 = BKPF9STBLG.
ALTMP6 = BKPF9BKTXT.
ALTMP7 = BKPF9AWKEY.
ALTMP8 = BKPF9XREF2_HD.
ALTMP9 = BSAK9LIFNR.
ALTMP10 = BSAK9BUDAT.
ALTMP11 = BSAK9BLDAT.
ALTMP12 = BSAK9CPUDT.
ALTMP13 = BSAK9AUGBL.
ALTMP14 = BSAK9AUGDT.
ALTMP15 = BSAK9ZUONR.
ALTMP16 = BSAK9BLART.
ALTMP17 = BSAK9SHKZG.
ALTMP18 = BSAK9DMBTR.
ALTMP19 = BSAK9SGTXT.
ALTMP20 = BSAK9HKONT.
ALTMP21 = BSAK9ZFBDT.
ALTMP22 = BSAK9ZLSCH.
ALTMP23 = BSAK9HBKID.
ALTMP24 = BSAK9XREF1.
ALTMP25 = BSAK9XREF2.
ALTMP26 = BSAK9XREF3.
ALTMP27 = BSAK9ZZMOT_EMIS.
ALTMP28 = BSAK9ZZRUT_TERC.
ALTMP29 = BSAK9ZZ_AGENCIA.
ALTMP30 = BSAK9BUZEI.
 move ALTMP1 to ITAB3-BUKRS.
 move ALTMP2 to ITAB3-BELNR.
 move ALTMP3 to ITAB3-GJAHR.
 move ALTMP4 to ITAB3-XBLNR.
 move ALTMP5 to ITAB3-STBLG.
 move ALTMP6 to ITAB3-BKTXT.
 move ALTMP7 to ITAB3-AWKEY.
 move ALTMP8 to ITAB3-XREF2_HD.
 move ALTMP9 to ITAB3-LIFNR.
 move ALTMP10 to ITAB3-BUDAT.
 move ALTMP11 to ITAB3-BLDAT.
 move ALTMP12 to ITAB3-CPUDT.
 move ALTMP13 to ITAB3-AUGBL.
 move ALTMP14 to ITAB3-AUGDT.
 move ALTMP15 to ITAB3-ZUONR.
 move ALTMP16 to ITAB3-BLART.
 move ALTMP17 to ITAB3-SHKZG.
 move ALTMP18 to ITAB3-DMBTR.
 move ALTMP19 to ITAB3-SGTXT.
 move ALTMP20 to ITAB3-HKONT.
 move ALTMP21 to ITAB3-ZFBDT.
 move ALTMP22 to ITAB3-ZLSCH.
 move ALTMP23 to ITAB3-HBKID.
 move ALTMP24 to ITAB3-XREF1.
 move ALTMP25 to ITAB3-XREF2.
 move ALTMP26 to ITAB3-XREF3.
 move ALTMP27 to ITAB3-ZZMOT_EMIS.
 move ALTMP28 to ITAB3-ZZRUT_TERC.
 move ALTMP29 to ITAB3-ZZ_AGENCIA.
 move ALTMP30 to ITAB3-BUZEI.
 append ITAB3.
rowCount = rowCount + 1.
IF ( download = 'S' ).
 IF ( rowCount = P_PKGSZ ).
   PERFORM FORM6.
   REFRESH ITAB3.
   rowCount = 0.
 ENDIF.
ELSE.
 IF ( rowCount = 5000 ).
   PERFORM FORM6.
   REFRESH ITAB3.
   rowCount = 0.
 ENDIF.
ENDIF.
ENDSELECT.
ENDFORM.

FORM FORM6.
STATICS firstRun(1) TYPE C VALUE 'Y'.
DATA ALTMP31(4) TYPE C.
DATA ALTMP32(10) TYPE C.
DATA ALTMP33(4) TYPE N.
DATA ALTMP34(16) TYPE C.
DATA ALTMP35(10) TYPE C.
DATA ALTMP36(25) TYPE C.
DATA ALTMP37(20) TYPE C.
DATA ALTMP38(20) TYPE C.
DATA ALTMP39(10) TYPE C.
DATA ALTMP40(16) TYPE C.
DATA ALTMP41(36) TYPE C.
DATA ALTMP42(71) TYPE C.
DATA ALTMP43 TYPE D.
DATA ALTMP44 TYPE D.
DATA ALTMP45 TYPE D.
DATA ALTMP46(10) TYPE C.
DATA ALTMP47 TYPE D.
DATA ALTMP48(18) TYPE C.
DATA ALTMP49(2) TYPE C.
DATA ALTMP50(1) TYPE C.
DATA ALTMP51(16) TYPE P DECIMALS 2.
DATA ALTMP52(50) TYPE C.
DATA ALTMP53(10) TYPE C.
DATA ALTMP54 TYPE D.
DATA ALTMP55(1) TYPE C.
DATA ALTMP56(5) TYPE C.
DATA ALTMP57(12) TYPE C.
DATA ALTMP58(12) TYPE C.
DATA ALTMP59(20) TYPE C.
DATA ALTMP60(10) TYPE C.
DATA ALTMP61(10) TYPE C.
DATA ALTMP62(10) TYPE C.
DATA ALTMP63 TYPE D.
DATA ALTMP64(6) TYPE C.
DATA ALTMP65(13) TYPE C.
DATA ALTMP66 TYPE D.
DATA ALTMP67(12) TYPE C.
DATA ALTMP68(1) TYPE C.
DATA ALTMP69 TYPE D.
DATA ALTMP70(3) TYPE N.
DATA ALOJF0 TYPE C.
DATA ALOJF1 TYPE C.
DATA ALOJF2 TYPE C.



LOOP AT ITAB3.
ALTMP31 = ITAB3-BUKRS.
ALTMP32 = ITAB3-BELNR.
ALTMP33 = ITAB3-GJAHR.
ALTMP34 = ITAB3-XBLNR.
ALTMP35 = ITAB3-STBLG.
ALTMP36 = ITAB3-BKTXT.
ALTMP37 = ITAB3-AWKEY.
ALTMP38 = ITAB3-XREF2_HD.
ALTMP43 = ITAB3-BUDAT.
ALTMP44 = ITAB3-BLDAT.
ALTMP45 = ITAB3-CPUDT.
ALTMP46 = ITAB3-AUGBL.
ALTMP47 = ITAB3-AUGDT.
ALTMP48 = ITAB3-ZUONR.
ALTMP49 = ITAB3-BLART.
ALTMP50 = ITAB3-SHKZG.
ALTMP51 = ITAB3-DMBTR.
ALTMP52 = ITAB3-SGTXT.
ALTMP53 = ITAB3-HKONT.
ALTMP54 = ITAB3-ZFBDT.
ALTMP55 = ITAB3-ZLSCH.
ALTMP56 = ITAB3-HBKID.
ALTMP57 = ITAB3-XREF1.
ALTMP58 = ITAB3-XREF2.
ALTMP59 = ITAB3-XREF3.
ALTMP60 = ITAB3-ZZMOT_EMIS.
ALTMP61 = ITAB3-ZZRUT_TERC.
ALTMP62 = ITAB3-ZZ_AGENCIA.
ALTMP70 = ITAB3-BUZEI.
ALOJF0 = 'Y'.
ALOJF1 = 'N'.
IF ( ALOJF0 = 'Y' ).

SELECT
  LIFNR
  STCD1
  NAME1
  NAME2
INTO CORRESPONDING FIELDS OF LFA1
FROM LFA1
WHERE ( LIFNR = ITAB3-LIFNR ).
ALTMP39 = LFA1-LIFNR.
ALTMP40 = LFA1-STCD1.
concatenate LFA1-NAME1 ' ' into ALTMP41.
concatenate ALTMP41 LFA1-NAME2 into ALTMP42.
ALOJF1 = 'Y'.
ALOJF2 = 'N'.
IF ( ALOJF0 = 'Y' ).

SELECT
  LAUFD
  LAUFI
  CHECF
  PRIDT
  PRIUS
  XBANC
  BANCD
  ZBUKR
  GJAHR
  LIFNR
  VBLNR
INTO CORRESPONDING FIELDS OF PAYR
FROM PAYR
WHERE ( ( VBLNR = ITAB3-AUGBL )
 AND ( ( LIFNR = ITAB3-LIFNR )
 AND ( ( GJAHR = ITAB3-GJAHR )
 AND ( ZBUKR = ITAB3-BUKRS ) ) ) ).
ALTMP63 = PAYR-LAUFD.
ALTMP64 = PAYR-LAUFI.
ALTMP65 = PAYR-CHECF.
ALTMP66 = PAYR-PRIDT.
ALTMP67 = PAYR-PRIUS.
ALTMP68 = PAYR-XBANC.
ALTMP69 = PAYR-BANCD.
ALOJF2 = 'Y'.
 move ALTMP31 to ITAB6-BUKRS.
 move ALTMP32 to ITAB6-BELNR.
 move ALTMP33 to ITAB6-GJAHR.
 move ALTMP34 to ITAB6-XBLNR.
 move ALTMP35 to ITAB6-STBLG.
 move ALTMP36 to ITAB6-BKTXT.
 move ALTMP37 to ITAB6-AWKEY.
 move ALTMP38 to ITAB6-XREF2_HD.
 move ALTMP39 to ITAB6-LIFNR.
 move ALTMP40 to ITAB6-STCD1.
 move ALTMP42 to ITAB6-NOMBRE.
 move ALTMP43 to ITAB6-BUDAT.
 move ALTMP44 to ITAB6-BLDAT.
 move ALTMP45 to ITAB6-CPUDT.
 move ALTMP46 to ITAB6-AUGBL.
 move ALTMP47 to ITAB6-AUGDT.
 move ALTMP48 to ITAB6-ZUONR.
 move ALTMP49 to ITAB6-BLART.
 move ALTMP50 to ITAB6-SHKZG.
 move ALTMP51 to ITAB6-DMBTR.
 move ALTMP52 to ITAB6-SGTXT.
 move ALTMP53 to ITAB6-HKONT.
 move ALTMP54 to ITAB6-ZFBDT.
 move ALTMP55 to ITAB6-ZLSCH.
 move ALTMP56 to ITAB6-HBKID.
 move ALTMP57 to ITAB6-XREF1.
 move ALTMP58 to ITAB6-XREF2.
 move ALTMP59 to ITAB6-XREF3.
 move ALTMP60 to ITAB6-ZZMOT_EMIS.
 move ALTMP61 to ITAB6-ZZRUT_TERC.
 move ALTMP62 to ITAB6-ZZ_AGENCIA.
 move ALTMP63 to ITAB6-LAUFD.
 move ALTMP64 to ITAB6-LAUFI.
 move ALTMP65 to ITAB6-CHECF.
 move ALTMP66 to ITAB6-PRIDT.
 move ALTMP67 to ITAB6-PRIUS.
 move ALTMP68 to ITAB6-XBANC.
 move ALTMP69 to ITAB6-BANCD.
 move ALTMP70 to ITAB6-BUZEI.
 append ITAB6.
firstRun = 'N' .
 cntbuf = cntbuf + 1.
 if download = 'N'.
  if cntbuf > 5000.
    perform FORM7.
    clear cntbuf.
    refresh ITAB6.
    append_flag = 'A'.
  endif.
 endif.
 if download = 'S'.
  if cntbuf > P_PKGSZ.
    perform FORM7.
    clear cntbuf.
    refresh ITAB6.
  endif.
 endif.
ENDSELECT.
ENDIF.
IF ( ALOJF2 = 'N' ).
clear PAYR-LAUFD.
clear PAYR-LAUFI.
clear PAYR-CHECF.
clear PAYR-PRIDT.
clear PAYR-PRIUS.
clear PAYR-XBANC.
clear PAYR-BANCD.
clear PAYR-ZBUKR.
clear PAYR-GJAHR.
clear PAYR-LIFNR.
clear PAYR-VBLNR.
clear ALTMP63.
clear ALTMP64.
clear ALTMP65.
clear ALTMP66.
clear ALTMP67.
clear ALTMP68.
clear ALTMP69.
 move ALTMP31 to ITAB6-BUKRS.
 move ALTMP32 to ITAB6-BELNR.
 move ALTMP33 to ITAB6-GJAHR.
 move ALTMP34 to ITAB6-XBLNR.
 move ALTMP35 to ITAB6-STBLG.
 move ALTMP36 to ITAB6-BKTXT.
 move ALTMP37 to ITAB6-AWKEY.
 move ALTMP38 to ITAB6-XREF2_HD.
 move ALTMP39 to ITAB6-LIFNR.
 move ALTMP40 to ITAB6-STCD1.
 move ALTMP42 to ITAB6-NOMBRE.
 move ALTMP43 to ITAB6-BUDAT.
 move ALTMP44 to ITAB6-BLDAT.
 move ALTMP45 to ITAB6-CPUDT.
 move ALTMP46 to ITAB6-AUGBL.
 move ALTMP47 to ITAB6-AUGDT.
 move ALTMP48 to ITAB6-ZUONR.
 move ALTMP49 to ITAB6-BLART.
 move ALTMP50 to ITAB6-SHKZG.
 move ALTMP51 to ITAB6-DMBTR.
 move ALTMP52 to ITAB6-SGTXT.
 move ALTMP53 to ITAB6-HKONT.
 move ALTMP54 to ITAB6-ZFBDT.
 move ALTMP55 to ITAB6-ZLSCH.
 move ALTMP56 to ITAB6-HBKID.
 move ALTMP57 to ITAB6-XREF1.
 move ALTMP58 to ITAB6-XREF2.
 move ALTMP59 to ITAB6-XREF3.
 move ALTMP60 to ITAB6-ZZMOT_EMIS.
 move ALTMP61 to ITAB6-ZZRUT_TERC.
 move ALTMP62 to ITAB6-ZZ_AGENCIA.
 move ALTMP63 to ITAB6-LAUFD.
 move ALTMP64 to ITAB6-LAUFI.
 move ALTMP65 to ITAB6-CHECF.
 move ALTMP66 to ITAB6-PRIDT.
 move ALTMP67 to ITAB6-PRIUS.
 move ALTMP68 to ITAB6-XBANC.
 move ALTMP69 to ITAB6-BANCD.
 move ALTMP70 to ITAB6-BUZEI.
 append ITAB6.
firstRun = 'N' .
 cntbuf = cntbuf + 1.
 if download = 'N'.
  if cntbuf > 5000.
    perform FORM7.
    clear cntbuf.
    refresh ITAB6.
    append_flag = 'A'.
  endif.
 endif.
 if download = 'S'.
  if cntbuf > P_PKGSZ.
    perform FORM7.
    clear cntbuf.
    refresh ITAB6.
  endif.
 endif.
ENDIF.
ENDSELECT.
ENDIF.
IF ( ALOJF1 = 'N' ).
clear LFA1-LIFNR.
clear LFA1-STCD1.
clear LFA1-NAME1.
clear LFA1-NAME2.
clear ALTMP39.
clear ALTMP40.
clear ALTMP41.
clear ALTMP42.
ALOJF2 = 'N'.
IF ( ALOJF0 = 'Y' ).

SELECT
  LAUFD
  LAUFI
  CHECF
  PRIDT
  PRIUS
  XBANC
  BANCD
  ZBUKR
  GJAHR
  LIFNR
  VBLNR
INTO CORRESPONDING FIELDS OF PAYR
FROM PAYR
WHERE ( ( VBLNR = ITAB3-AUGBL )
 AND ( ( LIFNR = ITAB3-LIFNR )
 AND ( ( GJAHR = ITAB3-GJAHR )
 AND ( ZBUKR = ITAB3-BUKRS ) ) ) ).
ALTMP63 = PAYR-LAUFD.
ALTMP64 = PAYR-LAUFI.
ALTMP65 = PAYR-CHECF.
ALTMP66 = PAYR-PRIDT.
ALTMP67 = PAYR-PRIUS.
ALTMP68 = PAYR-XBANC.
ALTMP69 = PAYR-BANCD.
ALOJF2 = 'Y'.
 move ALTMP31 to ITAB6-BUKRS.
 move ALTMP32 to ITAB6-BELNR.
 move ALTMP33 to ITAB6-GJAHR.
 move ALTMP34 to ITAB6-XBLNR.
 move ALTMP35 to ITAB6-STBLG.
 move ALTMP36 to ITAB6-BKTXT.
 move ALTMP37 to ITAB6-AWKEY.
 move ALTMP38 to ITAB6-XREF2_HD.
 move ALTMP39 to ITAB6-LIFNR.
 move ALTMP40 to ITAB6-STCD1.
 move ALTMP42 to ITAB6-NOMBRE.
 move ALTMP43 to ITAB6-BUDAT.
 move ALTMP44 to ITAB6-BLDAT.
 move ALTMP45 to ITAB6-CPUDT.
 move ALTMP46 to ITAB6-AUGBL.
 move ALTMP47 to ITAB6-AUGDT.
 move ALTMP48 to ITAB6-ZUONR.
 move ALTMP49 to ITAB6-BLART.
 move ALTMP50 to ITAB6-SHKZG.
 move ALTMP51 to ITAB6-DMBTR.
 move ALTMP52 to ITAB6-SGTXT.
 move ALTMP53 to ITAB6-HKONT.
 move ALTMP54 to ITAB6-ZFBDT.
 move ALTMP55 to ITAB6-ZLSCH.
 move ALTMP56 to ITAB6-HBKID.
 move ALTMP57 to ITAB6-XREF1.
 move ALTMP58 to ITAB6-XREF2.
 move ALTMP59 to ITAB6-XREF3.
 move ALTMP60 to ITAB6-ZZMOT_EMIS.
 move ALTMP61 to ITAB6-ZZRUT_TERC.
 move ALTMP62 to ITAB6-ZZ_AGENCIA.
 move ALTMP63 to ITAB6-LAUFD.
 move ALTMP64 to ITAB6-LAUFI.
 move ALTMP65 to ITAB6-CHECF.
 move ALTMP66 to ITAB6-PRIDT.
 move ALTMP67 to ITAB6-PRIUS.
 move ALTMP68 to ITAB6-XBANC.
 move ALTMP69 to ITAB6-BANCD.
 move ALTMP70 to ITAB6-BUZEI.
 append ITAB6.
firstRun = 'N' .
 cntbuf = cntbuf + 1.
 if download = 'N'.
  if cntbuf > 5000.
    perform FORM7.
    clear cntbuf.
    refresh ITAB6.
    append_flag = 'A'.
  endif.
 endif.
 if download = 'S'.
  if cntbuf > P_PKGSZ.
    perform FORM7.
    clear cntbuf.
    refresh ITAB6.
  endif.
 endif.
ENDSELECT.
ENDIF.
IF ( ALOJF2 = 'N' ).
clear PAYR-LAUFD.
clear PAYR-LAUFI.
clear PAYR-CHECF.
clear PAYR-PRIDT.
clear PAYR-PRIUS.
clear PAYR-XBANC.
clear PAYR-BANCD.
clear PAYR-ZBUKR.
clear PAYR-GJAHR.
clear PAYR-LIFNR.
clear PAYR-VBLNR.
clear ALTMP63.
clear ALTMP64.
clear ALTMP65.
clear ALTMP66.
clear ALTMP67.
clear ALTMP68.
clear ALTMP69.
 move ALTMP31 to ITAB6-BUKRS.
 move ALTMP32 to ITAB6-BELNR.
 move ALTMP33 to ITAB6-GJAHR.
 move ALTMP34 to ITAB6-XBLNR.
 move ALTMP35 to ITAB6-STBLG.
 move ALTMP36 to ITAB6-BKTXT.
 move ALTMP37 to ITAB6-AWKEY.
 move ALTMP38 to ITAB6-XREF2_HD.
 move ALTMP39 to ITAB6-LIFNR.
 move ALTMP40 to ITAB6-STCD1.
 move ALTMP42 to ITAB6-NOMBRE.
 move ALTMP43 to ITAB6-BUDAT.
 move ALTMP44 to ITAB6-BLDAT.
 move ALTMP45 to ITAB6-CPUDT.
 move ALTMP46 to ITAB6-AUGBL.
 move ALTMP47 to ITAB6-AUGDT.
 move ALTMP48 to ITAB6-ZUONR.
 move ALTMP49 to ITAB6-BLART.
 move ALTMP50 to ITAB6-SHKZG.
 move ALTMP51 to ITAB6-DMBTR.
 move ALTMP52 to ITAB6-SGTXT.
 move ALTMP53 to ITAB6-HKONT.
 move ALTMP54 to ITAB6-ZFBDT.
 move ALTMP55 to ITAB6-ZLSCH.
 move ALTMP56 to ITAB6-HBKID.
 move ALTMP57 to ITAB6-XREF1.
 move ALTMP58 to ITAB6-XREF2.
 move ALTMP59 to ITAB6-XREF3.
 move ALTMP60 to ITAB6-ZZMOT_EMIS.
 move ALTMP61 to ITAB6-ZZRUT_TERC.
 move ALTMP62 to ITAB6-ZZ_AGENCIA.
 move ALTMP63 to ITAB6-LAUFD.
 move ALTMP64 to ITAB6-LAUFI.
 move ALTMP65 to ITAB6-CHECF.
 move ALTMP66 to ITAB6-PRIDT.
 move ALTMP67 to ITAB6-PRIUS.
 move ALTMP68 to ITAB6-XBANC.
 move ALTMP69 to ITAB6-BANCD.
 move ALTMP70 to ITAB6-BUZEI.
 append ITAB6.
firstRun = 'N' .
 cntbuf = cntbuf + 1.
 if download = 'N'.
  if cntbuf > 5000.
    perform FORM7.
    clear cntbuf.
    refresh ITAB6.
    append_flag = 'A'.
  endif.
 endif.
 if download = 'S'.
  if cntbuf > P_PKGSZ.
    perform FORM7.
    clear cntbuf.
    refresh ITAB6.
  endif.
 endif.
ENDIF.
ENDIF.
ENDLOOP.
ENDFORM.

FORM FORM7.
data: outfile(512), ldfile(50).
ldfile = 'Z_OBLIGACIONES_C_ISA.dat'.
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
            E_TABLE = ITAB6
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
           tables   ITAB6
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
