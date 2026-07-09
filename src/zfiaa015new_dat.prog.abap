*&---------------------------------------------------------------------*
*&  Include  ZFIAA015NEW_DAT.
*&---------------------------------------------------------------------*

include <symbol>.
include <icon>.

constants:
  begin of %iqid,"type aqliqid
    workspace type aql_wsid   value ' ',
    usergroup type aql_ugroup value 'SYSTQV000013',
    query     type aql_query  value 'CAPEXVINTEGRA',
    lid       type aql_lid    value 'G00',
    struct    type aql_tname  value 'ZZFIAAREPORTE',
    infoset   type aql_iset   value 'SYSTQV000000000000000808',
  end of %iqid.

data %runmode type aqlimode.

data %seloptions type table of rsparams with header line.

field-symbols <%selopt> type rsparams_tt.

tables LFA1.
tables ANLA.
tables ANLZ.
tables ANEP.
TABLES ANEK.
tables T001.
tables T093B.
tables BKPF.

data: begin of %joinwa,
        LFA1 like LFA1,
        ANLA like ANLA,
        ANLZ like ANLZ,
        ANEP like ANEP,
        BKPF like BKPF,
      end of %joinwa.

TYPES: BEGIN OF gt_alv,
          BUKRS   LIKE ANLA-BUKRS,
          ANLN1   LIKE ANLA-ANLN1,
          ANLN2   LIKE ANLA-ANLN2,
          TXT50   LIKE ANLA-TXT50,
          ANLKL   LIKE ANLA-ANLKL,
          KTOGR   LIKE ANLA-KTOGR,
          ANLTP   LIKE ANLA-ANLTP,
          AKTIV   LIKE ANLA-AKTIV,
          ANLUE   LIKE ANLA-ANLUE,
          IZWEK   LIKE ANLA-IZWEK,
          LIFNR   LIKE ANLA-LIFNR,
          STCD1   LIKE LFA1-STCD1,
          LIEFE   LIKE ANLA-LIEFE,
          NAME1   LIKE LFA1-NAME1,
          URWRT   LIKE ANLA-URWRT,
          HKONT   LIKE BSEG-HKONT,
          KOSTL   LIKE ANLZ-KOSTL,
          EAUFN   LIKE ANLA-EAUFN,
          ZUJHR   LIKE ANLA-ZUJHR,
          ZUPER   LIKE ANLA-ZUPER,
          ZUGDT   LIKE ANLA-ZUGDT,
          AIBDT   LIKE ANLA-AIBDT,
          URJHR   LIKE ANLA-URJHR,
          AFABE   LIKE ANEP-AFABE,
          BZDAT   LIKE ANEP-BZDAT,
          BWASL   LIKE ANEP-BWASL,
          ANBTR   LIKE ANEP-ANBTR,
          WAERS   LIKE T093B-WAERS,
          PERAF   LIKE ANEP-PERAF,
          BELNR   LIKE ANEP-BELNR,
          BUZEI   LIKE ANEP-BUZEI,
          GJAHR   LIKE ANEP-GJAHR,
          ZUJHR001 LIKE ANEP-ZUJHR,
          LBLNR   LIKE ANLA-LBLNR,
          BLART   LIKE BKPF-BLART,
          XBLNR   LIKE BKPF-XBLNR,
          BUDAT   LIKE BKPF-BUDAT,
          USNAM   LIKE BKPF-USNAM,
     END OF   gt_alv.

DATA: lv_repid    TYPE sy-repid,
      wa_layout   TYPE slis_layout_alv,
      ti_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

CONSTANTS: c_x TYPE c VALUE 'X'.
