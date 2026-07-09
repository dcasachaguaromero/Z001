report  zrsbdc_protocol message-id 00 no standard page heading.

parameters:
  session  like bdcld-grpn  default space no-display,
  from_dat like bdcld-edate default '00000000' no-display,
  to_dat   like bdcld-edate default '00000000' no-display,
  user     like bdcld-luser default space no-display,
  queue_id like bdcld-quid  default space no-display.

include rsbdcil3.                      "Read plain log from TemSe

constants:
      arch_object like arch_obj-object value 'BDCLOGPROD'.

tables: apqi, t100, snap, d0100.

tables: bdcuseop.                      "Benutzereinstellungen

controls:
  tc_protocol type tableview using screen 200,      " protokolliste
  tc_prot_dis type tableview using screen 1400,     " protokoll anzeigen
  tc_prot_del type tableview using screen 1600.     " protokoll loeschen

controls:
  tab_protocol type tabstrip.

field-symbols:
  <mtxt>,
  <vtxt>.

data:
  tc_wa like line of tc_protocol-cols.
*
data:
* this table keeps protocol lines to be displayed
  begin of bdc_protocol occurs 0.
        include structure bdclm.
data:
    longtext type bdc_mpar,
  end of bdc_protocol.
*
data begin of bdclm  occurs 0.         " ITabelle der Messageseintraege
        include structure bdclm.       " LogTabelle
data: counter type i,
      longtext type bdc_mpar,
      end of bdclm .
data: save_mpar type bdc_mpar.
*
data begin of itab_bdcld  occurs 0.    " ITAB der Verzeichniseintraege
        include structure bdcld.       " LogTabelle aller Protokolle
data: logname(80),                     " protokollpfad
      local_host(24),                  " lokaler rechner
      mappenstate(16),                 " Status der Mappe
      status(1) type c,                " Abkuerzung fuer Status
      mcreator(12) type c,             " Mappen-Ersteller
      cnt type i,                      " satzzaehler
      active(1) type c,                " active flag
      temseid type rstsoname.          " TemSe ID  29.03.1999
data end of itab_bdcld .

data: list_bdcld like itab_bdcld occurs 0 with header line.

data: del_protocol like itab_bdcld occurs 0 with header line.

data:
*   LOGTAB LIKE BDCLD OCCURS 0 WITH HEADER LINE,
   logtab_temse like apql occurs 0 with header line.

data:
  main_okcode like sy-ucomm,
  save_ok like main_okcode,

  d1400_pcode type sy-ucomm,
  d1600_fcode type sy-ucomm,
  tc_mark(1),
  selected_cnt type i,
  dynprotab_subscreen_dynpro like sy-dynnr,       "#EC NEEDED
  header_subscreen_dynpro    like sy-dynnr.       "#EC NEEDED

data:                                  "Felder fuer scrollen im TC
  new_page     like sy-tabix,          "#EC NEEDED
  total_pages  like sy-tabix,          "#EC NEEDED
  new_line     like sy-tabix,          "#EC NEEDED
  entries      like sy-tabix,          "#EC NEEDED
  loopc        like sy-tabix,          "#EC NEEDED
  loops        like sy-tabix.          "#EC NEEDED

data:
  bdc_lines like sy-index,
  del_lines like sy-index,             "#EC NEEDED
  i_lines   like sy-index,
  c_field(132),
  c_line type i,
  selected_index like sy-index,
  protocol_index like sy-index,
  mark_index     like sy-stepl.
*
data:
  wa like line of tc_protocol-cols,    "Felder für die Ermittlung
  offset type i,                       "der markierten Spalte
  selected_column(32),
  sort_direction(1).                   "U: up, D: down

data:
  d1020_fcode type fcode,
  opt_initialize(1) value 'X',
  opt_exist(1) value ' ',
* some variables for storing temporary copies of option flags
  rb_a, rb_m, rb_p,
  opt_creator like apqi-creator,
  opt_groupid like apqi-groupid,
  opt_detail(1).

data:
  begin of itab_apqi occurs 0.
        include structure apqi.
data:
  end of itab_apqi.

data:
  b_d_c like apqi-datatyp value 'BDC '."Datatyp = Batch-Input

data:                                  " Felder zu vergleichen
    d0100_init(1) value 'X',
    d0100_init_activetab(1) value 'X',
    d0100_mapn_old  like bdcld-grpn,
    d0100_von_old   like bdcld-edate,
    d0100_bis_old   like bdcld-edate,
    d0100_user_old  like bdcld-luser,
*   D0100_QUID_OLD  LIKE BDCLD-QUID,
    d0100_activetab_old like sy-ucomm,
    d1400_detail_log(1) value space.
data:                                  " Header mit QUID zu zeigen
    d0202_quid    like apqi-qid,
    d0202_mapn    like apqi-groupid,
    d0202_credate like apqi-credate,
    d0202_creator like apqi-creator.
data:
     local_quid like bdcld-quid,
     par_quid   like bdcld-quid,
     log_quid   like bdcld-quid.
*
data: d0100_von_init like sy-datum value is initial.

data:
  anareport(16) type c value 'RSBDC_ANALYSE'." Mappeninhalt analysieren
*
data: date_no_correct like sy-subrc,
      auth_rc like sy-subrc.
*
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*

start-of-selection.
*
*
  call screen 0100.
*----------------------------------------------------------------------*
*   PBO Module   PBO Module   PBO Module   PBO Module   PBO Module
*----------------------------------------------------------------------*
module d0100_init_main output.

  set pf-status 'PF_MAIN'.
  set titlebar '0100'.

  header_subscreen_dynpro    = 201.
  dynprotab_subscreen_dynpro = 200.

  clear: main_okcode, save_ok.

* Benutzereinstellungen laden.
  if opt_initialize = 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single * from bdcuseop where bdcuser = sy-uname
*                                    and tid     = 'SM35P'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  from bdcuseop where bdcuser = sy-uname
                                    and tid     = 'SM35P' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    if sy-subrc = 0.
*     Einstellungen wurden gespeichert -> laden und setzen
      opt_exist = 'X'.
      d0100-mapn    = bdcuseop-groupid.
      d0100-creator = bdcuseop-creator.
*
      case bdcuseop-entry_view.
        when 'A'. tab_protocol-activetab = 'ALL_PROT'.
                  d1400_detail_log = space.
        when 'B'. tab_protocol-activetab = 'ALL_PROT'.
                  d1400_detail_log = 'X'.
        when 'M'. tab_protocol-activetab = 'MAP_PROT'.
                  d1400_detail_log = space.
        when 'N'. tab_protocol-activetab = 'MAP_PROT'.
                  d1400_detail_log = 'X'.
        when 'P'. tab_protocol-activetab = 'ONLY_PROT'.
                  d1400_detail_log = space.
        when 'Q'. tab_protocol-activetab = 'ONLY_PROT'.
                  d1400_detail_log = 'X'.
        when others. tab_protocol-activetab = 'ALL_PROT'.
                     d1400_detail_log = space.
      endcase.

    else.
*   Keine Einstellungen gespeichert -> Defaultwerte setzen
      d0100-mapn    = '*'.
      d0100-creator = '*'.
      tab_protocol-activetab = 'ALL_PROT'.

    endif.
*
    clear opt_initialize.
  endif.
*
* Falls die Daten durch PARAMETERS aus SM35 uebergeben wurden
  if session ne space.
    perform init_with_param_sm35.
  endif.
* Falls die Daten durch 'queue_id' aus SM35 uebergeben wurden
  if queue_id ne space.
    perform init_with_quid_sm35.
  endif.
*
  if d0100-mapn is initial.
    d0100-mapn = '*'.
  endif.
  if d0100-creator is initial.
    d0100-creator = '*'.
  endif.

endmodule.                             "  init_main output

*&---------------------------------------------------------------------*
*&      Module  INIT_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
module d0200_init_subscreen output.

  if d0100_init = 'X'.
    clear: itab_bdcld.
    refresh: itab_bdcld.

* Es werden die Dateien aus Profilparameter 'bdc/logfile' pro Server
* gelesen und die Protokolle in ITAB_BDCLD ablegen.
* Es werden alle Felder der DD-Structure BDCLD und auch die Felder
* ITAB_BDCLD-LOGNAME und ITAB_BDCLD-LOCAL_HOST gefuellt.
* In dem Unterprogramm ist auch jetzt die Variante für TemSe-Datein
* implementiert.
    perform get_logfiles.

* Interne Tabelle ITAB_APQI aus der Tabelle APQI, um den Status
* einer Mappe zu lesen.
    perform fill_itab_apqi using  d0100-mapn '*'
                                  b_d_c sy-mandt '*'
                                  d0100_von_init sy-datum.

* In ITAB_BDCLD wird noch der Status einer Mappe mit Hilfe der
*  ITAB_APQI gebaut. Die Felder sind:
*  ITAB_BDCLD-MAPPENSTATE und ITAB_BDCLD-STATUS mit Werte wie z.B.:
*  fehlerhaft, verarbeitet, etc.
    perform bdcld_list.

    clear d0100_init.
  endif.
*
  if d0100_init_activetab = 'X'.
    clear: list_bdcld.
    refresh: list_bdcld.
    list_bdcld[] = itab_bdcld[].
    case tab_protocol-activetab.
      when 'ALL_PROT'.                 " Protokoll mit belibig.
                                       " Mappen-Status
      when 'MAP_PROT'.                 " Protokoll mit Mappe
        delete list_bdcld where status = 'N'.
      when 'ONLY_PROT'.                " Protokoll ohne Mappe
        delete list_bdcld where status ne 'N'.
    endcase.
    clear d0100_init_activetab.
  endif.
  d0100_activetab_old = tab_protocol-activetab.
  describe table list_bdcld lines i_lines.
  tc_protocol-lines = i_lines.         " fuer vert. scrolling
*
* Statusspalte der Mappen einblenden, falls TAB_PROTOCOL-ACTIVETAB
* gleich  ALL_PROT oder MAP_PROT ist.

  loop at tc_protocol-cols into tc_wa.
    check sy-tabix = 4.                " Status steht in Spalte 4
    if tab_protocol-activetab = 'ALL_PROT'
       or tab_protocol-activetab = 'MAP_PROT'.
      clear tc_wa-invisible.
    else.
      tc_wa-invisible = 1.
    endif.
    modify tc_protocol-cols from tc_wa.
  endloop.

* Sortieren
  if selected_column = 'MAPPENSTATE'.
    if tab_protocol-activetab = 'ALL_PROT'
    or tab_protocol-activetab = 'MAP_PROT'.
*    SELECTED_COLUMN = 'STATUS'.      " Umsetzen auf das LIST_BDCLD-Feld
    else.
      "Spalte wird nicht angezeigt -> Default-Sortierung
      clear selected_column.
    endif.
  endif.


  if not selected_column is initial.
    case sort_direction.
      when 'D'.
        sort list_bdcld as text by (selected_column) descending.
      when 'U'.
        sort list_bdcld as text by (selected_column) ascending.
    endcase.
  else.
    sort list_bdcld by edate descending etime descending.
  endif.

  if not c_field is initial.
    set cursor field c_field line c_line.
  endif.

endmodule.                             " INIT_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_LINE OUTPUT
*&---------------------------------------------------------------------*
* Markieren der Zeile fuer das Dynpro

module check_line output.
  if list_bdcld-edate = 0.
    exit from step-loop.
  else.
    if list_bdcld-active = 'X'.
      tc_mark = 'X'.
    endif.
  endif.
  loopc = sy-loopc.
endmodule.                             " check_line output
*----------------------------------------------------------------------*
*         Module d1400_init output
*----------------------------------------------------------------------*

module d1400_init output.
  set pf-status 'PF_PROTO'.
  set titlebar  '1400' with list_bdcld-grpn.
  clear d1400_pcode.
endmodule.

*----------------------------------------------------------------------*
*        Module fill_bdc_protocol
*----------------------------------------------------------------------*
module fill_bdc_protocol output.

  clear bdc_protocol. refresh bdc_protocol.

  loop at bdclm.
    if    ( bdclm-mid eq '00' )
      and ( d1400_detail_log eq space ).
      if   ( bdclm-mnr eq '162' )
        or ( bdclm-mnr eq '368' ).
         continue.
      endif.
    endif.

    move-corresponding bdclm to bdc_protocol.
    append bdc_protocol.
  endloop.

  describe table bdc_protocol lines bdc_lines.
  tc_prot_dis-lines = bdc_lines.

endmodule.
*----------------------------------------------------------------------*
*        Module check_bdc_tcodes output
*----------------------------------------------------------------------*

module check_bdc_protocol output.
* prevent those ugly entries in empty table views
  if bdc_protocol-indate is initial.
    exit from step-loop.
  endif.
  loops = sy-loopc.
endmodule.

*----------------------------------------------------------------------*
*         Module d1600_init
*----------------------------------------------------------------------*

module d1600_init output.
  set pf-status 'POPUP'.
  set titlebar  '1600'.
  clear d1600_fcode.
*  REFRESH CONTROL 'TC_PROT_DEL' FROM SCREEN '1600'.
endmodule.

*----------------------------------------------------------------------*
*   PAI Module   PAI Module   PAI Module   PAI Module   PAI Module
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       Module exit_main input
*----------------------------------------------------------------------*
module exit_main input.
  leave program.
endmodule.

*----------------------------------------------------------------------*
*       Module user_command_main
*----------------------------------------------------------------------*

module user_command_main input.

  DATA: l_tcode like tstc-tcode.

  save_ok =  main_okcode.
  clear  main_okcode.

  case save_ok.
*   change the active tab
    when 'ALL_PROT' or 'MAP_PROT' or 'ONLY_PROT'.
      tab_protocol-activetab = save_ok.
      if d0100_activetab_old ne tab_protocol-activetab.
        d0100_init_activetab = 'X'.
      endif.
      tc_protocol-top_line = 1.
    when 'PICK'.                       " Anzeige eines Protokolls
      if selected_cnt = 0.
        message s321 with 'Keine'(010)." Keine Protokoll(e) markiert
      elseif selected_cnt gt 1.
        message i323.                  " Mehrfachselekt unzulaessig
      else.
        perform get_log using mark_index.      " bauen itab bdclm
* check authority first
        clear: auth_rc.
        authority-check object 'S_BDC_MONI'
                 id 'BDCAKTI'    field 'ANAL'
                 id 'BDCGROUPID' field list_bdcld-grpn.
        if sy-subrc > 0.
          auth_rc = sy-subrc.
          if   ( list_bdcld-mcreator eq sy-uname )  "eigene Mappe
            or ( list_bdcld-luser    eq sy-uname ). "oder eigenes Protokoll?
            authority-check object 'S_BDC_MONI'
                       id 'BDCAKTI'     field 'OANA'
                       id 'BDCGROUPID'  field list_bdcld-grpn.
            auth_rc = sy-subrc.
          endif.
        endif.
        if auth_rc > 0.
          message i830(00) with list_bdcld-grpn.
        else.
          perform extend_message_texts." extended texts -> bdclm
          call screen 1400.
        endif.
      endif.
      clear selected_cnt.
    when 'DEL'.
      if selected_cnt = 0.
        message s321 with 'Keine'(010)." Keine Protokoll(e) markiert
      else.
        clear del_protocol. refresh del_protocol.
        if selected_cnt = 1.
          read table list_bdcld index mark_index.
          move-corresponding list_bdcld to del_protocol.
          append del_protocol.
        else.
          loop at list_bdcld where active = 'X'.
            move-corresponding list_bdcld to del_protocol.
            append del_protocol.
          endloop.
        endif.
        describe table del_protocol lines del_lines.
        tc_prot_del-lines = del_lines.
*
        perform delete_protocol.
*
        tc_protocol-top_line = 1.
        d0100_init = 'X'.
        d0100_init_activetab = 'X'.
        clear selected_cnt.
      endif.
    when 'MON'.                        " Transaction SM35
      l_tcode = 'SM35'.
      CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
           EXPORTING
                TCODE  = l_tcode
           EXCEPTIONS
                OK     = 1
                NOT_OK = 2
                OTHERS = 3.
      if SY-SUBRC <> 1.
        message i172(00) with l_tcode.
      else.
        call transaction l_tcode.
      endif.
    when 'ARCH'.                        " Transaction SARA von ADK
      l_tcode = 'SARA'.
      CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
           EXPORTING
                TCODE  = l_tcode
           EXCEPTIONS
                OK     = 1
                NOT_OK = 2
                OTHERS = 3.
      if SY-SUBRC <> 1.
        message i172(00) with l_tcode.
      else.
        set parameter id 'OBT' field arch_object.
        call transaction l_tcode.
      endif.
    when 'ANM'.                        " Report RSBDC_ANALYSE der Mappe,
      if selected_cnt = 0.             " wenn existiert.
        message s321 with 'Keine'(010).
      elseif selected_cnt gt 1.
        message i323.                  "Mehrfachselekt unzulaessig
      else.
        read table list_bdcld index mark_index.
        local_quid = list_bdcld-quid.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        select * from apqi where qid = local_quid.
**
* NEW CODE
        SELECT *
 from apqi where qid = local_quid ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        endselect.
        if sy-subrc ne 0.
          message i306(00).
        else.                          " die QUEUE_ID hier ist von SM35
          submit (anareport) with queue_id eq local_quid and return.
        endif.
        clear local_quid.
      endif.
      clear selected_cnt.
    when 'REOG'.                       " Report RSBDCREO
      submit rsbdc_reorg via selection-screen
                      and return.
    when 'CKT'.                       " Report RSBDCCKT
      submit rsbdcckt via selection-screen
                      and return.
    when 'CKA'.                       " Report RSBDCCKA
      submit rsbdccka via selection-screen
                      and return.
    when 'UMRK'.                       " Markierungen entfernen
      clear list_bdcld-active.
      modify list_bdcld transporting active where active = 'X'.
    when 'AMRK'.                       " Alle Mappen markieren
      list_bdcld-active = 'X'.
      modify list_bdcld transporting active where active = space.
    when 'SORT_UP'.
      perform get_tc_selected_column.
      sort_direction = 'U'.
    when 'SORT_DOWN'.
      perform get_tc_selected_column.
      sort_direction = 'D'.
    when 'P-' or 'P--' or 'P+' or 'P++'.
* Interne Tabelle blättern nach SAP Style Guide:
      call function 'SCROLLING_IN_TABLE'
           exporting
                entry_act             = tc_protocol-top_line
                entry_from            = 1
                entry_to              = tc_protocol-lines
                ok_code               = save_ok
                last_page_full        = ' '
                overlapping           = ' '
                loops                 = loopc
           importing
                entries_sum           = entries
                entry_new             = new_line
                pages_sum             = total_pages
                page_new              = new_page
           exceptions
                no_entry_or_page_act  = 01
                no_entry_to           = 02
                no_ok_code_or_page_go = 03.
      case sy-subrc.
        when 0.                                             "OK
        when 01.    "weder Aufsetzindex noch Aufsetzseite angegeben
          message w208 with text-050.
        when 02.    "Ende der tabellarischen Teilstruktur ist Null
          message w208 with text-051.
        when 03.    "weder Funktionscode noch Zielseite angegeben
          message w208 with text-052.
        when others.
          message w208 with text-050.
      endcase.

      tc_protocol-top_line = new_line.
    when 'INFO'.
      perform batch_input_hilfe.
*   change the viewing options
    when 'OPTI'.                       "voreinstellung
      call screen 1020 starting at 5 5.
      d0100_init = 'X'.
      d0100_init_activetab = 'X'.
      tc_protocol-top_line = 1.
*   leave this nice program
    when 'BACK' or 'END'.
      leave program.
    when 'REFR'.                       "refresh
      d0100_init = 'X'.
      d0100_init_activetab = 'X'.
      tc_protocol-top_line = 1.
    when 'CHANGE'.                     "von QUID "zur Standard Auswahl"
      clear queue_id.
      opt_initialize = 'X'.
      d0100_init = 'X'.
      d0100_init_activetab = 'X'.
      clear d0100-von.
      clear d0100-bis.
      clear par_quid.
      tc_protocol-top_line = 1.
    when 'PRI'.
      perform print_alv_list.
    when others.
                                                            "
  endcase.
  clear selected_cnt.
endmodule.                             " USER_COMMAND_MAIN INPUT
*&---------------------------------------------------------------------*
*&      Module D0200_GET_CURSOR INPUT
*&---------------------------------------------------------------------*
* Falls kein Protokoll 'hart' markiert ist, aber der Cursor auf eines
* steht.
*----------------------------------------------------------------------*
module d0200_get_cursor input.
  if selected_cnt = 0.
    get cursor field c_field line c_line.
    if c_line > 0.
      selected_index = tc_protocol-top_line + c_line - 1.
      mark_index = selected_index.
      selected_cnt = 1.
    else.
      selected_index = 0.
    endif.
  endif.
endmodule.                             " D0200_GET_CURSOR INPUT
*&---------------------------------------------------------------------*
*&      Module D1400_GET_CURSOR INPUT
*&---------------------------------------------------------------------*
* Falls kein Protokoll 'hart' markiert ist, aber der Cursor auf eines
* steht.
*----------------------------------------------------------------------*
module d1400_get_cursor input.
  get cursor field c_field line c_line.
  if c_line > 0.
    protocol_index = tc_prot_dis-top_line + c_line - 1.
  else.
    protocol_index = 0.
  endif.
endmodule.                             " D1400_GET_CURSOR INPUT
*----------------------------------------------------------------------*
*         Module d1600_fcode input
*----------------------------------------------------------------------*
module d1600_fcode input.
*  CLEAR LOGTAB. REFRESH LOGTAB.
  if d1600_fcode = 'POP_OKAY' or d1600_fcode = 'POP_CANCEL'.
    leave to screen 0.
  endif.
*
endmodule.
*----------------------------------------------------------------------*
*         Module d1400_pcode input
*----------------------------------------------------------------------*
module d1400_pcode input.
  case d1400_pcode.
    when 'CANCEL'.
      leave to screen 0.
    when 'DISPLAY'.
      perform set_new_display.
    when 'PRI'.
      perform print_alv_message.
    when 'BACK'.
      clear bdclm. refresh bdclm.
      leave to screen 0.
    when 'END'.
      leave to transaction ' '.
    when 'P-' or 'P--' or 'P+' or 'P++'.   "Scrolling Seitweise
* Interne Tabelle blättern nach SAP Style Guide:
      call function 'SCROLLING_IN_TABLE'
           exporting
                entry_act             = tc_prot_dis-top_line
                entry_from            = 1
                entry_to              = tc_prot_dis-lines
                ok_code               = d1400_pcode
                last_page_full        = ' '
                overlapping           = ' '
                loops                 = loops
           importing
                entries_sum           = entries
                entry_new             = new_line
                pages_sum             = total_pages
                page_new              = new_page
           exceptions
                no_entry_or_page_act  = 01
                no_entry_to           = 02
                no_ok_code_or_page_go = 03.
      case sy-subrc.
        when 0.                                             "OK
        when 01.   "weder Aufsetzindex noch Aufsetzseite angegeben
          message w208 with text-050.
        when 02.   "Ende der tabellarischen Teilstruktur ist Null
          message w208 with text-051.
        when 03.   "weder Funktionscode noch Zielseite angegeben
          message w208 with text-052.
        when others.
          message w208 with text-050.
      endcase.
*
      tc_prot_dis-top_line = new_line.
*
    when 'REFR'.
    when others.
  endcase.
endmodule.                             " D1400_PCODE INPUT
*----------------------------------------------------------------------*
*     Form: get_logfiles. Here are the date and down the form
*----------------------------------------------------------------------*
data:
  paramname(11) value 'bdc/logfile',
  logname(80),
  logname1(80),
* OLD_LOGFILE(06) VALUE 'bdclog',
  new_logfile(04) value 'BI* ',
  shiftlen type i value 0,
  protflen type i value 0,
  protfoff type i value 0,
  rlen     type i value 0,
  one type i,
  ec type i,
  protcnt type i.
* needed for check if TemSe interface is active:
data: protparam(60) value 'bdc/new_protocol',
      newprot(3)    value 'off'.

data:
  begin of prot_list occurs 0.
include     rstr0112.
data: seen(1), to_be_deleted(1), has_changed(1), local_host(24),
end of prot_list.

data:
  begin of file.
include rstr0112.
data end of file.

data:
  begin of bdclda  occurs 0.
        include structure bdcld.
data end of bdclda .

data:
  digits(10)  type c value '0123456789',
  mtext(124)  type c,                  "Messagetext
  mtext1(124) type c,                  "Messagetext
  mtext2(273) type c,                  "Messagetext
  do_condense type c,
  mtvaroff type i,
  parcnt   type i,
  mparcnt  type i,
  x(1)     type c value 'X'.
*
data:                                  "Aufbereitung Messagetext
  begin of mttab  occurs 4,
   off(02) type n,
   len(02) type n,
   text(99),
 end of mttab.
*
data:                                  "ParameterAufbereitung
  begin of par,
   len(02) type n,
   text(254),
 end of par.
*
*----------------------------------------------------------------------*
* Form get_logfiles
*   find all log files for the session,
*   either in common log or in TemSe
*----------------------------------------------------------------------*

form get_logfiles.



*** profile parameter bdc/logfile & bdc/new_protocol
*** not supported since 6.10
**
*** first check whether log files are in the common log or if TemSe
*** interface is active
**  call 'C_SAPGPARAM'  id 'NAME'   field protparam
**                      id 'VALUE'  field newprot.
**
**  translate newprot to upper case.
**  if newprot = 'OFF'.                  "get logs from bdc/logfile
***  get logs from common log file
**    call 'C_SAPGPARAM' id 'NAME'   field paramname
**                       id 'VALUE'  field logname.
**
**    perform list_protocol_files.       "all files from all servers and
***                                      "all times with BI* names
**    log_quid = par_quid.
**    clear par_quid.
**    loop at prot_list.
**      logname = prot_list-name.
**      perform log_dir.                 "gewaehlte Mappenname und Zeit-
**    endloop.                           "intervall
**    clear log_quid.
**  else.                                "get logs from TemSe
    log_quid = par_quid.
    clear par_quid.
    perform get_logfiles_from_temse.
    clear log_quid.
**  endif.
*
*  now bdcld contains the log files for the given session name and date
  sort itab_bdcld by edate descending etime descending.

endform.                               "form get_logfiles
*----------------------------------------------------------------------*
*     Form: get_logfiles_from_temse
*----------------------------------------------------------------------*
form get_logfiles_from_temse.
* are there any logs in the TemSe for this QID ?
  clear logtab_temse[].
  clear itab_bdcld[].
*----------------------------------------------------------------------*
  if log_quid eq 0.
    call function 'BDC_PROTOCOL_SELECT'
         exporting
              name         = d0100-mapn
              client       = sy-mandt
              date_from    = d0100-von
              date_to      = d0100-bis
              status       = '*'
              session_user = d0100-creator
         tables
              apqltab      = logtab_temse
         exceptions
              invalid_data = 1
              others       = 2.

    if sy-subrc <> 0.
      message s324.                    "Kein Protokoll vorhanden
      exit.
    endif.

  else.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    select * from apql into table logtab_temse
*             where ( qid = log_quid ).
*
* NEW CODE
    SELECT *
 from apql into table logtab_temse
             where ( qid = log_quid ) ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    check sy-subrc = 0.
  endif.
*----------------------------------------------------------------------*

* some logs were found: now put this info into table bdcld.
  data: wa_log like line of logtab_temse,
        wa_ld  like line of itab_bdcld.

  loop at logtab_temse into wa_log.
    clear wa_ld.
    wa_ld-temseid = wa_log-temseid.
    wa_ld-lmand   = wa_log-mandant.
    wa_ld-edate   = wa_log-credate.
    wa_ld-etime   = wa_log-cretime.
    wa_ld-luser   = wa_log-creator.
    wa_ld-grpn    = wa_log-groupid.
    wa_ld-quid    = wa_log-qid.
    wa_ld-local_host = wa_log-destsys.
    append wa_ld to itab_bdcld.
  endloop.

endform.

*----------------------------------------------------------------------*
*     Form: delete_protocol in screen 1600                   l
*----------------------------------------------------------------------*

form delete_protocol.
*
  call screen 1600 starting at 5 5.
  check d1600_fcode = 'POP_OKAY'.
  perform dele_biprot.
endform.
*----------------------------------------------------------------------*
*     Form: dele_biprot call delete with RemoveLogPartitionA or with
*           bdc_delete_protocol for TemSe files and APQL
*----------------------------------------------------------------------*
form dele_biprot.

  loop at del_protocol.
* check authority first
    clear: auth_rc.
    authority-check object 'S_BDC_MONI'
            id 'BDCAKTI'     field 'DELE'    "loesch eines Protok.
            id 'BDCGROUPID'  field del_protocol-grpn.
    if sy-subrc > 0.
      auth_rc = sy-subrc.
      if   ( del_protocol-mcreator eq sy-uname )  "eigene Mappe
        or ( del_protocol-luser    eq sy-uname ). "oder eigenes Protokoll?
        authority-check object 'S_BDC_MONI'
                id 'BDCAKTI'     field 'ODEL'    "loesch eines Protok.
                id 'BDCGROUPID'  field del_protocol-grpn.
        auth_rc = sy-subrc.
      endif.
    endif.
    if auth_rc > 0.
      message i831(00) with del_protocol-grpn.
    else.
      if newprot = 'OFF'.
        move del_protocol-logname    to  logname.
        call 'RemoveLogPartitionA'   id 'LOGN'    field logname
                                     id 'PART'    field del_protocol.
        if sy-subrc gt 0.              "Fehler beim loeschen der part.
          message i387(00) with del_protocol-grpn  del_protocol-edate
                                del_protocol-etime del_protocol-quid.
        else.
          message s386 with del_protocol-grpn.
        endif.
      else.                            " newport = 'ON'
*        CALL FUNCTION 'COMMON_LOG_REMOVE'
*             EXPORTING
*                  CLIENT  = SY-MANDT
*                  LOGNAME = DEL_PROTOCOL-TEMSEID
*             EXCEPTIONS
*                  OTHERS  = 20.
*
      call function 'BDC_PROTOCOL_DELETE'        "loescht Protokoll
           exporting
                temse_client = sy-mandt
                temse_id     = del_protocol-temseid
           exceptions
                temse_error = 1
                not_found = 2
                others = 20.
*        IF SY-SUBRC GT 0.
*          MESSAGE I001(TS).                  " Temse Error
*        ELSE.
*          DELETE FROM APQL WHERE MANDANT = SY-MANDT AND
*                                 TEMSEID = DEL_PROTOCOL-TEMSEID.
*          COMMIT WORK.
*          MESSAGE S386(00) WITH DEL_PROTOCOL-GRPN.
*        ENDIF.
        if sy-subrc gt 0.
          case sy-subrc.
            when 1.                      " Temse Error
              message i001(ts).
            when others.                 "Fehler beim lösch. Protok.
              message i387 with text-117 del_protocol-quid
                                text-228 del_protocol-temseid.
          endcase.
        else.
          message s386(00) with del_protocol-grpn.
        endif.
      endif.
*
    endif.
  endloop.
*
endform.

*----------------------------------------------------------------------*
*     Form: log_dir search with session name and time interval
*----------------------------------------------------------------------*

form log_dir.
*
  clear bdclda. refresh bdclda.

  call 'ReadLogDirA'       id 'LOGN'  field logname
                           id 'DTAB'  field bdclda[]
                           id 'AINF'  field one
                           id 'ECNT'  field ec.
*
  if sy-subrc ne 0.
    message s317.      "Protokoll Verzeichnis kann nicht gelesen werden
    exit.
  endif.
*
  if ec = 0.
    message s318.                      "Protokoll Verzeichnis ist leer
    exit.
  endif.
*
  perform log_bdclda_to_bdcld.         "filtern der gewuenschten Daten
*
endform.                               " log_dir.
*----------------------------------------------------------------------*
*      Form: log_bdclda_to_bdcld
*      Es wird ITAB_BDCLD aus BDCLDA gebaut
*----------------------------------------------------------------------*
form log_bdclda_to_bdcld.
  if log_quid eq 0.
   loop at bdclda where ( lmand = sy-mandt ) and ( grpn cp d0100-mapn )
                          and ( edate between d0100-von and d0100-bis )
                                 and ( luser cp d0100-creator ).
*
      move-corresponding bdclda to itab_bdcld.
      move logname to itab_bdcld-logname.
      move prot_list-local_host to itab_bdcld-local_host.
      append itab_bdcld.
    endloop.
  else.
    loop at bdclda where ( lmand = sy-mandt ) and ( quid = log_quid ).
      move-corresponding bdclda to itab_bdcld.
      move logname to itab_bdcld-logname.
      move prot_list-local_host to itab_bdcld-local_host.
      append itab_bdcld.
    endloop.
  endif.
endform.
*
*----------------------------------------------------------------------*
*      Form: list_protocol_files
*      Suche nach allen aktiven Protokolldateien -> Tabelle prot_list
*----------------------------------------------------------------------*
form list_protocol_files.

  clear:   logname1, prot_list, protcnt.
  refresh: prot_list.

  protflen = strlen( logname ).
  move logname to logname1.

  while shiftlen le protflen.
    if  logname1 cp '*#B#I*'.          "suchen nach muster *#B#I*
      if sy-fdpos eq 0.                "nur großbuchstaben
        shiftlen = 2.
      else.
        shiftlen = sy-fdpos.
      endif.
      protfoff = protfoff + shiftlen.
      shift logname1 by shiftlen places.
    else.
      shiftlen = protflen + 1.
      protfoff = protfoff - 2.
    endif.
  endwhile.
*
  if protfoff le 0.
    protfoff = 0.
  endif.
*
  rlen = 80 - protfoff.
*
  write space       to logname+protfoff(rlen).
  write new_logfile to logname+protfoff(4).
*
  perform search_prot using logname.

endform.                               " FILL_PROT_LIST
*
*---------------------------------------------------------------------*
* FORM : search_prot                                                  *
*---------------------------------------------------------------------*
form search_prot    using prot_files.
*
  data: errcnt(2) type p value 0.
*
  call 'C_DIR_READ_START' id 'FILE'   field prot_files
     id 'ERRNO'  field file-errno
     id 'ERRMSG' field file-errmsg.

  if sy-subrc <> 0.
    message i398(00)
            with sy-subrc 'C_DIR_READ_START' ' ' prot_files.
    message i398(00)
            with sy-subrc 'C_DIR_READ_START...'
                 file-errno file-errmsg.
  endif.

  do.                 "aufbau der internen tabelle fuer alle
                                       "BI-Protokolle
    clear file.

    call 'C_DIR_READ_NEXT'
      id 'TYPE'   field file-type
      id 'NAME'   field file-name
      id 'LEN'    field file-len
      id 'OWNER'  field file-owner
      id 'MTIME'  field file-mtime
      id 'MODE'   field file-mode
      id 'ERRNO'  field file-errno
      id 'ERRMSG' field file-errmsg.

    move sy-subrc to    file-subrc.

    case sy-subrc.
      when 0.
        case file-type(1).
          when 'F'.                    " normal file.
            move 1       to file-useable.
          when 'f'.                    " normal file.
            move 1       to file-useable.
          when others. " Directory, device, fifo, socket,...
            move 0       to file-useable.
        endcase.
        if file-len = 0.
          move 0      to file-useable.
        endif.
      when 1.
        exit.
      when others.                     " SY-SUBRC >= 2
        add 1 to errcnt.
        if errcnt > 10.
          exit.
        endif.
        if sy-subrc = 5.
          move: '???' to file-type,
                '???' to file-owner,
                '???' to file-mode.
        else.
        endif.
        file-useable = 0.
    endcase.

    move-corresponding file to prot_list.
    shift file-name by protfoff places.
    prot_list-local_host = file-name.
    protcnt = protcnt + 1.
    append prot_list.

  enddo.

  call 'C_DIR_READ_FINISH'
      id 'ERRNO'  field file-errno
      id 'ERRMSG' field file-errmsg.

  if sy-subrc <> 0.
*   WRITE: / 'C_DIR_READ_FINISH'(999), 'SUBRC', SY-SUBRC.
  endif.

endform.                               " search_prot
*----------------------------------------------------------------------*
*       FORM get_tc_selected_column
*----------------------------------------------------------------------*
form get_tc_selected_column.
  clear selected_column.
  loop at tc_protocol-cols into wa where selected = 'X'.
    "Einfachselektion wird vorausgesetzt
    search wa-screen-name for '-'.
    offset = sy-fdpos + 1.
    selected_column = wa-screen-name+offset.
  endloop.
endform.

*----------------------------------------------------------------------*
*      Form: get_recent_log
*----------------------------------------------------------------------*
form get_log using log_index.
  data: begin of logtable occurs 50,   " plain log information in TemSe
          enterdate like btctle-enterdate,
          entertime like btctle-entertime,
          logmessage(366) type c,
        end of logtable.
  data: l_bdclm type bdclm.

  clear bdclm. refresh bdclm.

  read table list_bdcld index log_index.
  logname = list_bdcld-logname.

* get logfile contents from TemSe

    perform read_bdc_log_plain
      tables logtable
      using  list_bdcld-temseid list_bdcld-lmand.

    if sy-subrc <> 0.                  " Fehler beim Lesen
      message s004(ts).
      exit.
    endif.

    clear bdclm[].
    loop at logtable.
*
      perform check_temse_date using logtable-enterdate.
*
      IF date_no_correct ne 0.         " datum  ist nicht gültig
        continue.
      endif.

      l_bdclm = logtable.

      if l_bdclm-mcnt > 0.
        l_bdclm-mcnt = l_bdclm-mcnt - 1.
      endif.

      clear bdclm.
      bdclm = l_bdclm.
      append bdclm.
    endloop.
endform.

*----------------------------------------------------------------------*
*     Form: extend_message_texts
*----------------------------------------------------------------------*
form extend_message_texts.

  loop at bdclm.
*    LM = BDCLM.
    save_mpar = bdclm-mpar.
    perform get_text.
    bdclm-longtext = mtext.
    bdclm-mpar = save_mpar.
    modify bdclm.
  endloop.
endform.

*---------------------------------------------------------------------*
* FORM : get_text                                                     *
*---------------------------------------------------------------------*
form get_text.
*
*** Aufbereiten des Messagetextes
*
  data: shiftln type i,
        vartcnt type i,
        fdpos like sy-fdpos.

  if bdclm-mparcnt cn digits.          "Korrupter Datensatz:
    bdclm-mparcnt = 0.                 "z.B. Hexnullen
  endif.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single * from t100
*   where sprsl = sy-langu
*   and  arbgb  = bdclm-mid
*   and  msgnr  = bdclm-mnr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  from t100
   where sprsl = sy-langu
   and  arbgb  = bdclm-mid
   and  msgnr  = bdclm-mnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
  if sy-subrc eq 0.
    clear: mtext,
           parcnt,
           mparcnt,
           sy-fdpos.
*
    move bdclm-mparcnt to mparcnt.
*
    if t100-text ca '$&'.              "Kennung fuer parameter:
      move t100-text to mtext1.        " alt '$' --- neu '&'
    else.
      move t100-text to mtext.
      exit.
    endif.
* variable teile aus batch-input protokoll in mttab bringen.
    refresh mttab.
    clear shiftln.
    do mparcnt times.
      clear: par, mttab.
      move bdclm-mpar to par.
      if par-len cn digits or par-len eq 0.        "convert_no_number
        par-len  = 1.                              "entschärfen
        par-text = ' '.
        shiftln  = 2.
      else.
        shiftln = par-len + 2.
      endif.
      write par-text to mttab-text(par-len).
      move par-len  to mttab-len.
      move mparcnt  to mttab-off.
      append mttab.
      shift bdclm-mpar by shiftln places.
    enddo.
*
    mtext2 = mtext1.
    if bdclm-mid eq  '00' and          " sonderbehandlung s00368
       bdclm-mnr eq '368' and
       bdclm-mart eq 'S'.
      clear mtext2.
      clear mttab.
      read table mttab index 1.
      write mttab-text to mtext2+0(mttab-len).
      clear mttab.
      read table mttab index 2.
      write mttab-text to mtext2+35(mttab-len).
      mtext = mtext2.
      exit.
    endif.

    do_condense = x.
    clear: vartcnt, mtvaroff.
    while vartcnt le 3.
      vartcnt = vartcnt + 1.
      if mtext1 ca '$&'.
        parcnt = parcnt + 1.
        if sy-fdpos gt 0.
          fdpos = sy-fdpos - 1.        " neu sy-fdpos -1
        else.
          fdpos = sy-fdpos.
        endif.
        shift mtext1 by sy-fdpos places.
        if mtext1(1) eq '&'.
          shift mtext1 by 1 places.
          case mtext1(1).
            when ' '.                  "'& '
              perform replace_var using '& ' parcnt fdpos.
            when '$'.                  "'&&'
              perform replace_var using '&&' 0      fdpos.
            when '1'.                  "'&1'
              perform replace_var using '&1' 1      fdpos.
            when '2'.                  "'&2'
              perform replace_var using '&2' 2      fdpos.
            when '3'.                  "'&3'
              perform replace_var using '&3' 3      fdpos.
            when '4'.                  "'&4'
              perform replace_var using '&4' 4      fdpos.
            when others.               "'&'
              perform replace_var using '&<' parcnt fdpos.
          endcase.
        endif.
        if mtext1(1) eq '$'.
          shift mtext1 by 1 places.
          case mtext1(1).
            when ' '.                  "'$ '
              perform replace_var using '$ ' parcnt  fdpos.
            when '$'.                  "'$$'
              perform replace_var using '$$' 0       fdpos.
            when '1'.                  "'$1'
              perform replace_var using '$1' 1       fdpos.
            when '2'.                  "'$2'
              perform replace_var using '$2' 2       fdpos.
            when '3'.                  "'$3'
              perform replace_var using '$3' 3       fdpos.
            when '4'.                  "'$4'
              perform replace_var using '$4' 4       fdpos.
            when others.               "'$'
              perform replace_var using '$<' parcnt  fdpos.
          endcase.
        endif.
      endif.
    endwhile.
*
    if mtext2 ca '%%_D_%%'.
      replace '%%_D_%%' with '$' into mtext2.
    endif.
    if mtext2 ca '%%_A_%%'.
      replace '%%_A_%%' with '&' into mtext2.
    endif.
    if do_condense eq space.
      mtext = mtext2.
    else.
      condense mtext2 .
      mtext = mtext2.
    endif.
  else.
    mtext = '???????????????????????????????????????????????????'.
  endif.
*
endform.                               " get_text
*---------------------------------------------------------------------*
* FORM : replace_var                                                  *
*                                                                     *
*---------------------------------------------------------------------*
form replace_var using vark
                       vari type i
                       varpos.
*
*   ersetzen der variablen teile einer fehlermeldung
*
  data: var(02),
        var1,
        moff type i.
*
  clear: mttab , moff.
  var = vark.
  shift var by 1 places.
  case var.
    when ' '.                          "'& '
      read table mttab index vari.
      if sy-subrc eq 0.
        moff = varpos + mtvaroff.                           "neu
        assign mtext2+moff(*) to <mtxt>.                    "neu
        assign mttab-text(mttab-len) to <vtxt>.
        var1 = vark.
        replace var1 with <vtxt>     into <mtxt>.           "neu
        mtvaroff = mttab-len.                               "neu
      else.
        if vari gt mparcnt.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          replace vark with '  ' into <mtxt>.               "neu
          mtvaroff = 2.                                     "neu
        else.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          replace vark with '%%_Z_%%' into <mtxt>.          "neu
          mtvaroff = 7.                                     "neu
        endif.
      endif.
    when '$'.                          "'&&'
      moff = varpos + mtvaroff.                             "neu
      assign mtext2+moff(*) to <mtxt>.                      "neu
      replace vark with '%%_D_%%' into <mtxt>.              "neu
      mtvaroff = 7.                                         "neu
    when '&'.                          "'&&'
      moff = varpos + mtvaroff.                             "neu
      assign mtext2+moff(*) to <mtxt>.                      "neu
      replace vark with '%%_A_%%' into <mtxt>.              "neu
      mtvaroff = 7.                                         "neu
    when '<'.                          "'&1'
      read table mttab index vari.
      if sy-subrc eq 0.
        if vark eq '&<'.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          assign mttab-text(mttab-len) to <vtxt>.
          replace '&' with <vtxt>     into <mtxt>.          "neu
          mtvaroff = mttab-len.                             "neu
        endif.
        if vark eq '$<'.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          assign mttab-text(mttab-len) to <vtxt>.
          replace '$' with <vtxt>     into <mtxt>.          "neu
          mtvaroff = mttab-len.                             "neu
        endif.
      else.
        if vark eq '&<'.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          replace '&' with ' ' into <mtxt>.                 "neu
          mtvaroff = 1.                                     "neu
        endif.
        if vark eq '$<'.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          replace '$' with ' ' into <mtxt>.                 "neu
          mtvaroff = 1.                                     "neu
        endif.
      endif.
    when '1'.                          "'&1'
      read table mttab index 1.
      if sy-subrc eq 0.
        moff = varpos + mtvaroff.                           "neu
        assign mtext2+moff(*) to <mtxt>.                    "neu
        assign mttab-text(mttab-len) to <vtxt>.
        replace vark with <vtxt>     into <mtxt>.           "neu
        mtvaroff = mttab-len.                               "neu
      else.
        if vari gt mparcnt.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          replace vark with '  ' into <mtxt>.               "neu
          mtvaroff = 2.                                     "neu
        else.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          replace vark with '%%_Z_%%' into <mtxt>.          "neu
          mtvaroff = 7.                                     "neu
        endif.
      endif.
    when '2'.                          "'&2'
      read table mttab index 2.
      if sy-subrc eq 0.
        moff = varpos + mtvaroff.                           "neu
        assign mtext2+moff(*) to <mtxt>.                    "neu
        assign mttab-text(mttab-len) to <vtxt>.
        replace vark with <vtxt>     into <mtxt>.           "neu
        mtvaroff = mttab-len.                               "neu
      else.
        if vari gt mparcnt.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          replace vark with '  ' into <mtxt>.               "neu
          mtvaroff = 2.                                     "neu
        else.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          replace vark with '%%_Z_%%' into <mtxt>.          "neu
          mtvaroff = 7.                                     "neu
        endif.
      endif.
    when '3'.                          "'&3'
      read table mttab index 3.
      if sy-subrc eq 0.
        moff = varpos + mtvaroff.                           "neu
        assign mtext2+moff(*) to <mtxt>.                    "neu
        assign mttab-text(mttab-len) to <vtxt>.
        replace vark with <vtxt>     into <mtxt>.           "neu
        mtvaroff = mttab-len.                               "neu
      else.
        if vari gt mparcnt.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          replace vark with '  ' into <mtxt>.               "neu
          mtvaroff = 2.                                     "neu
        else.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          replace vark with '%%_Z_%%' into <mtxt>.          "neu
          mtvaroff = 7.                                     "neu
        endif.
      endif.
    when '4'.                          "'&4'
      read table mttab index 4.
      if sy-subrc eq 0.
        moff = varpos + mtvaroff.                           "neu
        assign mtext2+moff(*) to <mtxt>.                    "neu
        assign mttab-text(mttab-len) to <vtxt>.
        replace vark with <vtxt>     into <mtxt>.           "neu
        mtvaroff = mttab-len.                               "neu
      else.
        if vari gt mparcnt.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          replace vark with '  ' into <mtxt>.               "neu
          mtvaroff = 2.                                     "neu
        else.
          moff = varpos + mtvaroff.                         "neu
          assign mtext2+moff(*) to <mtxt>.                  "neu
          replace vark with '%%_Z_%%' into <mtxt>.          "neu
          mtvaroff = 7.                                     "neu
        endif.
      endif.
*
  endcase.
*
  do_condense = space.
*
endform.                               "replace_var

*----------------------------------------------------------------------*
*           Form: set_new_display
*----------------------------------------------------------------------*
form set_new_display.

  check protocol_index > 0.
  read table bdc_protocol index protocol_index.
  check sy-subrc = 0.
  perform show_ltext.

endform.

*---------------------------------------------------------------------*
* FORM : show_ltext. Um doppelpflege zu vermeiden aus RSBDC_ANALYSE   *
*                    genommen.                                        *
*---------------------------------------------------------------------*
form show_ltext.
*
  field-symbols:
    <rabaxkey>.

  data:
    docnt type i.

  data:
    begin of my,
      msgv1 like sy-msgv1,
      msgv2 like sy-msgv2,
      msgv3 like sy-msgv3,
      msgv4 like sy-msgv4,
    end of my.

  data:
    msg_text  like shkontext-meldung,
    msg_arbgb like shkontext-meld_id,
    msg_nr    like shkontext-meld_nr,
    msg_title like shkontext-titel.

*
* RABAX- or T100 message ?
*
   if bdc_protocol-mid eq '00' and      "Rabax
     bdc_protocol-mnr eq '341'.
     clear: par.

* extract Rabax-ID and key fields from message string
     par = bdc_protocol-mpar.
     if par-len cn digits. exit. endif. "corrupt string"
     my-msgv1 = par-text(par-len).
     shift par left by par-len places.
     shift par left by 2 places.
     if par-len cn digits. exit. endif. "corrupt string"
     snap = par-text(par-len).

    call dialog 'RS_RUN_TIME_ERROR'
         exporting
              snap-mandt
              snap-datum
              snap-uzeit
              snap-ahost
              snap-uname
              snap-modno.
    exit.
  endif.
*
* variable teile in die sy-felder stellen.       "
  docnt = 0.
*
  clear: my.
  if bdc_protocol-mparcnt cn digits.   "Korrupter Datensatz:
    bdc_protocol-mparcnt = 0.          "z.B. Hexnullen
  endif.
*
  do bdc_protocol-mparcnt times.
    if bdc_protocol-mpar(1) eq space.
      exit.
    endif.
    docnt = docnt + 1.
    clear par.
    move bdc_protocol-mpar to par.
*
    if par-len cn digits.              "convert_no_number
      par-len = 1.                     "entschärfen
    endif.
*
    case docnt.
      when 1.
        write par-text to my-msgv1(par-len).
      when 2.
        write par-text to my-msgv2(par-len).
      when 3.
        write par-text to my-msgv3(par-len).
      when 4.
        write par-text to my-msgv4(par-len).
    endcase.
    par-len = par-len + 2.
    shift bdc_protocol-mpar by par-len places.
  enddo.

  msg_arbgb = bdc_protocol-mid.
  msg_nr    = bdc_protocol-mnr.
  msg_text =  mtext.
  msg_title = sy-title.
  call function 'HELPSCREEN_NA_CREATE'
       exporting
            meldung = msg_text
            meld_id = msg_arbgb
            meld_nr = msg_nr
            msgv1   = my-msgv1
            msgv2   = my-msgv2
            msgv3   = my-msgv3
            msgv4   = my-msgv4
            titel   = msg_title.

endform.                               " show_ltext.

*&---------------------------------------------------------------------*
*&      Module  check_date  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module d0201_check_data input.
  perform check_date.
  if d0100_mapn_old ne d0100-mapn or
   d0100_von_old    ne d0100-von or
   d0100_bis_old    ne d0100-bis or
   d0100_user_old   ne d0100-creator.
    d0100_init = 'X'.
    d0100_init_activetab = 'X'.
    tc_protocol-top_line = 1.
  endif.
*
endmodule.                             " check_date  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXTRACT_SELECTED  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module extract_selected input.
  if tc_mark = 'X'.
    selected_cnt = 1 + selected_cnt.
    mark_index = tc_protocol-top_line + sy-stepl - 1.
*   MARK_INDEX = SY-STEPL.        " nur noetig, wenn selected_cnt = 1.
* neue Markierung
    list_bdcld-active = 'X'.
    modify list_bdcld index tc_protocol-current_line
      transporting active.
*
  else.
* war die Zeile vorher markiert ?.
    clear list_bdcld-active.
    modify list_bdcld index tc_protocol-current_line
      transporting active.
  endif.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  D1020_INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module d1020_init output.
  set pf-status '1020'.
  set titlebar '1020' with sy-uname.
  clear: rb_a, rb_m, rb_p.
  clear: opt_groupid, opt_creator, opt_detail.
  if opt_exist = 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single * from bdcuseop where bdcuser = sy-uname
*                                    and tid     = 'SM35P'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  from bdcuseop where bdcuser = sy-uname
                                    and tid     = 'SM35P' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    opt_groupid = bdcuseop-groupid.
    opt_creator = bdcuseop-creator.
    case bdcuseop-entry_view.
      when 'A'.     rb_a = 'X'.
              opt_detail = space.
      when 'B'.     rb_a = 'X'.
              opt_detail = 'X'.
      when 'M'.     rb_m = 'X'.
              opt_detail = space.
      when 'N'.     rb_m = 'X'.
              opt_detail = 'X'.
      when 'P'.     rb_p = 'X'.
              opt_detail = space.
      when 'Q'.     rb_p = 'X'.
              opt_detail = 'X'.
      when others.  rb_a = 'X'.
              opt_detail = space.
    endcase.
  endif.

endmodule.                             " D1020_INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  D1020_FCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module d1020_fcode input.

  case d1020_fcode.
*   nur uebernehmen, nicht speichern
    when 'OPT_OK'.
      perform set_options_from_dialog.
*   uebernehmen und speichern
    when 'OPT_SAVE'.
      perform set_options_from_dialog.
      bdcuseop-bdcuser = sy-uname.
      bdcuseop-groupid = opt_groupid.
      bdcuseop-creator = opt_creator.
      bdcuseop-tid     = 'SM35P'.
      if opt_detail = 'X'.
        if rb_a = 'X'.  bdcuseop-entry_view = 'B'. endif.
        if rb_m = 'X'.  bdcuseop-entry_view = 'N'. endif.
        if rb_p = 'X'.  bdcuseop-entry_view = 'Q'. endif.
      else.
        if rb_a = 'X'.  bdcuseop-entry_view = 'A'. endif.
        if rb_m = 'X'.  bdcuseop-entry_view = 'M'. endif.
        if rb_p = 'X'.  bdcuseop-entry_view = 'P'. endif.
      endif.
      if opt_exist = 'X'.
        update bdcuseop.
      else.
        insert bdcuseop.
      endif.
      if sy-subrc = 0.
        opt_exist = 'X'.
      endif.
*   auf Datenbank loeschen
    when 'OPT_DELETE'.
      if opt_exist = 'X'.
        delete from bdcuseop where bdcuser = sy-uname
                               and tid     = 'SM35P'.
        if sy-subrc = 0. clear opt_exist. endif.
      endif.
    when 'OPT_CANCEL'.
  endcase.
  leave to screen 0.

endmodule.                             " D1020_FCODE  INPUT


*----------------------------------------------------------------------*
*      Form set_options_from_dialog
*----------------------------------------------------------------------*
form set_options_from_dialog.
  d0100-mapn = opt_groupid.
  d0100-creator = opt_creator.
  d1400_detail_log = opt_detail.
  if rb_a = 'X'.  tab_protocol-activetab  = 'ALL_PROT'.  endif.
  if rb_m = 'X'.  tab_protocol-activetab  = 'MAP_PROT'.  endif.
  if rb_p = 'X'.  tab_protocol-activetab  = 'ONLY_PROT'. endif.
endform.
*&---------------------------------------------------------------------*
*&      Form  batch_input_hilfe
*&---------------------------------------------------------------------*
form batch_input_hilfe.
  data:
    docu_object like dokhl-object,
    docu_id     like dokhl-id,
    docu_spras  like dokhl-langu,
    tx_header   like thead,
    tx_lines    like tline occurs 0 with header line.

  docu_object = 'BDC_INFO'.
  docu_id = 'TX'.
  docu_spras = sy-langu.
  call function 'DOCU_GET'
       exporting
            object                 = docu_object
            id                     = docu_id
            langu                  = docu_spras
            version_active_or_last = 'A'
       importing
            head                   = tx_header
       tables
            line                   = tx_lines
       exceptions
            others                 = 1.

  case sy-subrc.
    when 1.                            "Dokubaustein nicht gefunden
      message w208 with text-080.
  endcase.
*

  call function 'PRINT_TEXT'
       exporting
            application = 'TX'
            device      = 'SCREEN'
            header      = tx_header
       tables
            lines       = tx_lines
       exceptions
            others      = 1.

  case sy-subrc.
    when 1.                       "Anzeigen Text:Optionen sind ungültig
      message w208 with text-070.
  endcase.

endform.                               " batch_input_hilfe .

*---------------------------------------------------------------------*
* FORM : fill_itab_apqi                                               *
*---------------------------------------------------------------------*
form fill_itab_apqi using par_sessionname    like apqi-groupid
                          par_sessioncreator like apqi-creator
                          par_datatyp        like apqi-datatyp
                          par_mandant        like apqi-mandant
                          par_qstate         like apqi-qstate
                          par_credatefrom    like apqi-credate
                          par_credateto      like apqi-credate.

  refresh: itab_apqi.
  clear:   itab_apqi.
*
  call function 'BDC_OBJECT_SELECT'
       exporting
            name            = par_sessionname
            session_creator = par_sessioncreator
            datatype        = par_datatyp
            client          = par_mandant
            qstate          = par_qstate
            date_from       = par_credatefrom
            date_to         = par_credateto
       tables
            apqitab         = itab_apqi
       exceptions
            others          = 1.

  case sy-subrc.
    when 1.                            "Ungueltiger Datentyp
      message w208 with text-060.
  endcase.
*
endform.                               " fill_itab_apqi
* -------------------------------------------------------------------- *
form bdcld_list.

  sort itab_apqi by qid.

  loop at itab_bdcld.
    read table itab_apqi with key qid = itab_bdcld-quid binary search.
    if sy-subrc = 0.                   " eine Mappe gefunden
      itab_bdcld-status = itab_apqi-qstate.
      itab_bdcld-mcreator = itab_apqi-creator.

      case itab_apqi-qstate.
        when ' '. itab_bdcld-mappenstate    = 'neu'(031).
        when 'F'. itab_bdcld-mappenstate    = 'verarbeitet'(032).
        when 'E'. itab_bdcld-mappenstate    = 'fehlerhaft'(033).
        when 'R'. itab_bdcld-mappenstate    = 'in Bearbeitung'(034).
        when 'C'. itab_bdcld-mappenstate    = 'in Erstellung'(035).
        when 'S'. itab_bdcld-mappenstate    = 'im Hintergrund'(036).
        when others. itab_bdcld-mappenstate = '?'.
      endcase.
      modify itab_bdcld transporting status mappenstate mcreator.
    else.
      itab_bdcld-status = 'N'.         " keine Mappe gefunden
      itab_bdcld-mappenstate = 'Prot. ohne Mappe'(037).
      modify itab_bdcld transporting status mappenstate.
    endif.

  endloop.
endform.                               " bdcld_list
*---------------------------------------------------------------------*
* FORM : check_date                                                   *
*---------------------------------------------------------------------*

form check_date.
  if d0100-von gt 0 and
    d0100-bis eq 0.
    d0100-bis = sy-datum.
  endif.

  if d0100-von gt d0100-bis.
    message e208 with 'Bitte Datumsangabe korrigieren.'(020).
  endif.
endform.

*&---------------------------------------------------------------------*
*&      Module  D0201_INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module d0201_init output.
  d0100_mapn_old = d0100-mapn.
  d0100_von_old  = d0100-von.
  d0100_bis_old  = d0100-bis.
  d0100_user_old = d0100-creator.      " Hier ist der User der Mappe
endmodule.                             " D0201_INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  PRINT_ALV_LIST
*&---------------------------------------------------------------------*
*  LIST_BDCLD mit ABAP List Viewer im Bildschirm angezeigt und drucken
*----------------------------------------------------------------------*
form print_alv_list.
* Data declaration
  type-pools: slis.

  data:   gt_fieldcat type slis_t_fieldcat_alv.
  data:   gs_print type slis_print_alv.
  data:   g_repid like sy-repid.
  data:   gt_outtab  like itab_bdcld occurs 0 with header line.
  data:   gs_variant like disvariant.
  data:   g_save(1) type c.
*
  g_repid = sy-repid.
  gt_outtab[] = list_bdcld[].
*
* GS_PRINT-PRINT              = 'X'.     "nur drucken
* GS_PRINT-NO_COVERPAGE       = 'X'.
  gs_print-no_print_listinfos = 'X'.   "keine Statistik
*
  g_save              = 'A'.
  gs_variant-report   = sy-repid.
  gs_variant-username = sy-uname.
  gs_variant-handle   = 'LIST'.
*
  perform fieldcat_init using gt_fieldcat[].
*
  call function 'REUSE_ALV_LIST_DISPLAY'
       exporting
            i_callback_program = g_repid
            it_fieldcat        = gt_fieldcat[]
            is_print           = gs_print
            i_save             = g_save
            is_variant         = gs_variant
       tables
            t_outtab           = gt_outtab.
*
endform.                               " PRINT_ALV_LIST
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Initialization fieldcatalog
*---------------------------------------------------------------------*
form fieldcat_init
      using rt_fieldcat type slis_t_fieldcat_alv.
  data: ls_fieldcat type slis_fieldcat_alv.
  data: pos type i value 1.

* Initialization of fields and attributes to structure field

  clear ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'EDATE'.
* ls_fieldcat-datatype        = 'DATS'.
  ls_fieldcat-outputlen       =  10.
  ls_fieldcat-seltext_m       =  text-102 .
  ls_fieldcat-seltext_l       =  text-103.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'ETIME'.
* ls_fieldcat-datatype        = 'TIMS'.
  ls_fieldcat-outputlen       =  8.
  ls_fieldcat-seltext_m       =  text-105 .
  ls_fieldcat-seltext_l       =  text-106.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'GRPN'.
* ls_fieldcat-datatype        = 'CHAR12'.
  ls_fieldcat-outputlen       =  12.
  ls_fieldcat-seltext_m       =  text-108 .
  ls_fieldcat-seltext_l       =  text-109.
  ls_fieldcat-emphasize       =  'X'.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'MAPPENSTATE'.
* ls_fieldcat-datatype        = 'CHAR16'.
  ls_fieldcat-outputlen       =  16.
  ls_fieldcat-seltext_m       =  text-111 .
  ls_fieldcat-seltext_l       =  text-112.
* wegen ALV-Filter
  ls_fieldcat-lowercase       =  'X'.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'LUSER'.
* ls_fieldcat-datatype        = 'CHAR12'.
  ls_fieldcat-outputlen       =  12.
  ls_fieldcat-seltext_m       =  text-114 .
  ls_fieldcat-seltext_l       =  text-115.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'QUID'.
  ls_fieldcat-outputlen       =  20.
  ls_fieldcat-seltext_m       =  text-117 .
  ls_fieldcat-seltext_l       =  text-118.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'LOCAL_HOST'.
  ls_fieldcat-datatype        = 'CHAR17'.
  ls_fieldcat-outputlen       =  17.
  ls_fieldcat-seltext_m       =  text-120 .
  ls_fieldcat-seltext_l       =  text-121.
* wegen ALV-Filter
  ls_fieldcat-lowercase       =  'X'.
  append ls_fieldcat to rt_fieldcat.

endform.                               " fieldcat_init
*&---------------------------------------------------------------------*
*&      Form  PRINT_ALV_MESSAGE
*&---------------------------------------------------------------------*
*  BDC_PROTOCOL mit ABAP List Viewer im Bildschirm angezeigt und drucken
*----------------------------------------------------------------------*
form print_alv_message.
* Data declaration
  type-pools: slis.

  data:   gt_fieldcat type slis_t_fieldcat_alv.
  data:   gt_events type slis_t_event.
  data:   gs_event  type slis_alv_event.
  data:   gs_print type slis_print_alv.
  data:   g_repid like sy-repid.
  data:   gt_outtab  like bdc_protocol occurs 0 with header line.
  data:   gs_variant like disvariant.
  data:   g_save(1) type c.
*
  g_repid = sy-repid.
  gt_outtab[] = bdc_protocol[].
*
* GS_PRINT-PRINT              = 'X'.     "nur drucken
* GS_PRINT-NO_COVERPAGE       = 'X'.
  gs_print-no_print_listinfos = 'X'.   "keine Statistik
*
  g_save              = 'A'.
  gs_variant-report   = sy-repid.
  gs_variant-username = sy-uname.
  gs_variant-handle   = 'MESS'.
*
  gs_event-name = 'TOP_OF_LIST'.
  gs_event-form = 'TOP_OF_LIST_MESSAGE'.
  append gs_event to gt_events.
*
  perform fieldcat_init_msg using gt_fieldcat[].
*
  call function 'REUSE_ALV_LIST_DISPLAY'
       exporting
            i_callback_program = g_repid
            it_fieldcat        = gt_fieldcat[]
            it_events          = gt_events[]
            is_print           = gs_print
            i_save             = g_save
            is_variant         = gs_variant
       tables
            t_outtab           = gt_outtab.
*
endform.                               " PRINT_ALV_MESSAGE
*&--------------------------------------------------------------------*
*&      Form  TOP_OF_LIST_MESSAGE
*&--------------------------------------------------------------------*
*       Protokollheader
*---------------------------------------------------------------------*
form top_of_list_message.
  write: /    text-108, 17 list_bdcld-grpn,
           37 text-117, 46 list_bdcld-quid,
           74 text-114, 83 list_bdcld-luser.
  write: /    text-103, 17 list_bdcld-edate,
           37 text-228, 46 list_bdcld-temseid.
*
endform.                    "TOP_OF_LIST_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT_MSG
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Initialization fieldcatalog
*---------------------------------------------------------------------*
form fieldcat_init_msg
      using rt_fieldcat type slis_t_fieldcat_alv.
  data: ls_fieldcat type slis_fieldcat_alv.
  data: pos type i value 1.

* Initialization of fields and attributes to structure field

  clear ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'INTIME'.
  ls_fieldcat-outputlen       =  8.
  ls_fieldcat-seltext_m       =  text-202 .
  ls_fieldcat-seltext_l       =  text-203.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'LONGTEXT'.
  ls_fieldcat-datatype        = 'CHAR254'.
  ls_fieldcat-outputlen       =  92.
  ls_fieldcat-seltext_m       =  text-205.
  ls_fieldcat-seltext_l       =  text-206.
* wegen ALV-Filter
  ls_fieldcat-lowercase       =  'X'.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'TCODE'.
  ls_fieldcat-datatype        = 'CHAR8'.
  ls_fieldcat-outputlen       =  8.
  ls_fieldcat-seltext_m       =  text-208 .
  ls_fieldcat-seltext_l       =  text-209.
  ls_fieldcat-emphasize       =  'X'.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'TCNT'.
  ls_fieldcat-outputlen       =  6.
  ls_fieldcat-seltext_m       =  text-211 .
  ls_fieldcat-seltext_l       =  text-212.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'MODULE'.
  ls_fieldcat-datatype        = 'CHAR12'.
  ls_fieldcat-outputlen       =  12.
  ls_fieldcat-seltext_m       =  text-214 .
  ls_fieldcat-seltext_l       =  text-215.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'DYNR'.
  ls_fieldcat-outputlen       =  4.
  ls_fieldcat-seltext_m       =  text-217 .
  ls_fieldcat-seltext_l       =  text-218.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'MCNT'.
  ls_fieldcat-outputlen       =  3.
  ls_fieldcat-seltext_m       =  text-211 .
  ls_fieldcat-seltext_l       =  text-212.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'MART'.
  ls_fieldcat-outputlen       =  1.
  ls_fieldcat-seltext_m       =  text-220 .
  ls_fieldcat-seltext_l       =  text-221.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'MID'.
  ls_fieldcat-datatype        = 'CHAR2'.
  ls_fieldcat-outputlen       =  2.
  ls_fieldcat-seltext_m       =  text-223 .
  ls_fieldcat-seltext_l       =  text-224.
  append ls_fieldcat to rt_fieldcat.
  clear ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'MNR'.
  ls_fieldcat-outputlen       =  3.
  ls_fieldcat-seltext_m       =  text-226 .
  ls_fieldcat-seltext_l       =  text-227.
  append ls_fieldcat to rt_fieldcat.

endform.                               " fieldcat_init
*&---------------------------------------------------------------------*
*&      Module  D0202_CHECK_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module d0202_check_data input.
*  OPT_INITIALIZE = 'X'.
*  D0100_INIT = 'X'.
*  D0100_INIT_ACTIVETAB = 'X'.
endmodule.                             " D0202_CHECK_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Form  INIT_WITH_QUID_SM35.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form init_with_quid_sm35.
  local_quid = queue_id.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * from apqi where qid = local_quid.
*
* NEW CODE
  SELECT *
 from apqi where qid = local_quid ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  endselect.
  if sy-subrc ne 0.
    message i306(00).
  else.
    d0202_quid    = apqi-qid.
    d0202_mapn    = apqi-groupid.
    d0202_credate = apqi-credate.
    d0202_creator = apqi-creator.
* um wieder zur Standard Auswahl zu gehen
    d0100-mapn = apqi-groupid.
    d0100-von  = apqi-credate.
*      D0100-BIS es wird Sy-Datum gesetzt
*      D0100-CREATOR  es wird * gesetzt
  endif.
  clear local_quid.
  par_quid = queue_id.
  tab_protocol-activetab = 'ALL_PROT'.

  header_subscreen_dynpro    = 202.

  data: begin of itab_pf_status occurs 10,
          fcode like rsmpe-func,
        end of itab_pf_status.

  refresh itab_pf_status.
  move 'PRI' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'AMRK' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'UMRK' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'SORT_DOWN' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'SORT_UP' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'MON' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'REOG' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'OPTI' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'INFO' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'REFR' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'P--' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'P-' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'P++' to itab_pf_status-fcode.
  append itab_pf_status.
  move 'P+' to itab_pf_status-fcode.
  append itab_pf_status.
*
  set pf-status 'PF_MAIN' excluding itab_pf_status.
*
  loop at screen.
    if screen-name = 'PUSH_MAP_PROT'.
      screen-active = 0.
      modify screen.
    endif.
    if screen-name = 'PUSH_ONLY_PROT'.
      screen-active = 0.
      modify screen.
    endif.
  endloop.

endform.                               " INIT_WITH_QUID_SM35.
*&---------------------------------------------------------------------*
*&      Form  INIT_WITH_PARAM_SM35
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form init_with_param_sm35.
  d0100-mapn = session.
  d0100-von  = from_dat.
  d0100-bis  = to_dat.
  d0100-creator = user.
  clear: session, from_dat, to_dat, user.
  tab_protocol-activetab = 'ALL_PROT'.

endform.                               " INIT_WITH_PARAM_SM3


*&---------------------------------------------------------------------*
*&      Form  check_temse_date
*&---------------------------------------------------------------------*
*       Es wird geprüft, ob von TEMSE das Datum korrekt geliefert wurde
*       wenn nicht wird einfach den Satz ignoriert und nicht gelesen
*----------------------------------------------------------------------*
*      -->P_LOGTABLE_ENTERDATE  Datum
*----------------------------------------------------------------------*
data:
      P_LOGTABLE_ENTERDATE LIKE APQI-STARTDATE,
      EXTERNAL_DATE(10),
      INTERNAL_DATE TYPE D,
      BDATE LIKE APQI-STARTDATE.

FORM check_temse_date USING  P_LOGTABLE_ENTERDATE.

   CLEAR date_no_correct.
   MOVE P_LOGTABLE_ENTERDATE TO BDATE.
   CALL 'DATE_CONV_INT_TO_EXT'
        ID 'DATINT' FIELD BDATE
        ID 'DATEXT' FIELD EXTERNAL_DATE.

   CALL 'DATE_CONV_EXT_TO_INT'
        ID 'DATEXT' FIELD EXTERNAL_DATE
        ID 'DATINT' FIELD INTERNAL_DATE.
   IF SY-SUBRC ne 0.         " datum  ist nicht gültig
     date_no_correct = 1.
   ENDIF.

ENDFORM.                    " check_temse_date

*-------------------------ENDE-----------------------------------------*
