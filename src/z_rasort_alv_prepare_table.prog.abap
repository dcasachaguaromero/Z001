*---------------------------------------------------------------------*
*       FORM FIELDCAT_S_FIELDS_DEFINE                                 *
*---------------------------------------------------------------------*
*       Sx und Sx_TEXT Felder für den Feldkatalog definieren.
*---------------------------------------------------------------------*
*  -->  VALUE(TABNAME): Tabellenname des Feldkatalogs                 *
*  -->  COLPOS        : Zähler für die Spalten                        *
*---------------------------------------------------------------------*
FORM fieldcat_s_fields_define USING value(tabname).
  DATA: a(1), b(1), count(1).

  IF summb EQ space.
    a = 'X'.   b = ' '.
  ELSE.
    a = ' '.   b = ' '.
  ENDIF.

  DO con_srtst TIMES.                  " con_srtst == Summenstufen
    CLEAR x_fieldcat.
    MOVE sy-index TO count.
    CONCATENATE 'S' count INTO x_fieldcat-fieldname.
    x_fieldcat-tabname   = tabname.
    x_fieldcat-no_out    = a.
    x_fieldcat-tech      = b.
    PERFORM set_ref_table TABLES feld USING sy-index
                                      CHANGING x_fieldcat.
    CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
         EXPORTING fieldcat_line = x_fieldcat.

*   Bezeichner dazu
    CLEAR x_fieldcat.
    CONCATENATE 'S' count '_TEXT' INTO x_fieldcat-fieldname.
    x_fieldcat-tabname       = tabname.
    x_fieldcat-no_out        = 'X'.
    x_fieldcat-tech          = 'X'.
    CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
         EXPORTING fieldcat_line = x_fieldcat.
  ENDDO.

ENDFORM.                               " FIELDCAT_S_FIELDS_DEFINE

*---------------------------------------------------------------------*
*       FORM FIELDCAT_USER_FIELDS_APPEND                              *
*---------------------------------------------------------------------*
*       Die definierbare Userstruktur an den Feldkatalog anhängen.    *
*---------------------------------------------------------------------*
*  -->  FCAT              : Feldkatalog                               *
*  -->  VALUE(STRUCT_NAME): Userstrukturname                          *
*  -->  VALUE(TAB_NAME)   : Tabellenname des Feldkatalogs             *
*---------------------------------------------------------------------*
FORM fieldcat_user_fields_append USING value(struct_name)
                                       value(tab_name).

  DATA: tmp_fcat TYPE slis_t_fieldcat_alv,
        lfcat    LIKE LINE OF tmp_fcat.

  CHECK NOT struct_name IS INITIAL
    AND NOT tab_name    IS INITIAL.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING   i_program_name         = sy-cprog
                   i_structure_name       = struct_name
       CHANGING    ct_fieldcat            = tmp_fcat
       EXCEPTIONS  inconsistent_interface = 1
                   program_error          = 2
                   OTHERS                 = 3
                   .

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Die neuen Felder nicht anzeigen aber an den aktuellen
* Feldkatalog anhängen und im Vorrat zur Verfügung stellen
  LOOP AT tmp_fcat INTO lfcat.
     lfcat-tabname = tab_name.
    lfcat-no_out = 'X'.

* da hier ein Customer Include ankommt, in dem WAERS nicht definiert
* werden kann (ist im übergeordneten Include schon definiert), wird
* beim FIELDCATALOG_MERGE der CFIELDNAME wieder gelöscht. Ohne den kann
* die Währung aber nicht korrekt ausgegeben werden.
      IF lfcat-datatype = 'CURR' AND                           "> 526282
         lfcat-cfieldname IS INITIAL.                          "> 526282
        lfcat-cfieldname = 'WAERS'.                            "> 526282
      ENDIF.                                                   "> 526282

    CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
         EXPORTING fieldcat_line = lfcat.
  ENDLOOP.
ENDFORM.                               " FIELDCAT_USER_FIELDS_APPEND

*&---------------------------------------------------------------------*
*&      Form  get_blanks_from_sort_variant
*&---------------------------------------------------------------------*
* This form routine is necessary for ALV Information System Reports
* who have more than 1 output line per asset. In group total reports
* it is usual to have some value columns, and in the first of the output
* lines some additional text before the value columns. This text depends
* on the sort variant, in detail on which sort field and the count of
* sort fields. This routine now calculates how much digits there are
* used caused by the information given out in the first line per asset
* out of the sort variant.
* This routine was implemented with note 558765
*----------------------------------------------------------------------*
*      -->IT_FELD  Table with definition of the sort variant
*      <--ED_BLANKS  count of digits used by the sort variant
*----------------------------------------------------------------------*
form get_blanks_from_sort_variant tables   it_feld
                                  changing ed_blanks.

DATA: lt_dfies     TYPE table of dfies.
DATA: ls_dfies     TYPE dfies.
DATA: ld_tabname   TYPE ddobjname.
DATA: ld_fieldname TYPE dfies-fieldname.
DATA: ld_lines     TYPE sy-tabix.

* Die Spalten der ersten Ausgabezeile verschieben sich individuell, je
* nach Art und Ausgabelänge der Sortierfelder. Deshalb wird hier
* ausgelesen, bei welcher Spalte die Betragsfelder anfangen.
  LOOP AT feld.
    ld_tabname = feld-tabln.
    ld_fieldname = feld-feldn.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname              = ld_tabname
        FIELDNAME            = ld_fieldname
        all_types            = 'X'
      TABLES
        DFIES_TAB            = lt_dfies
      EXCEPTIONS
        NOT_FOUND            = 1
        INTERNAL_ERROR       = 2
        OTHERS               = 3.

*   Hier aufsummieren wie sich die Ausgabelänge der Sortierfelder
*   zusammensetzt
    READ TABLE lt_dfies INDEX 1 INTO ls_dfies.
    ADD ls_dfies-outputlen TO ed_blanks.
  ENDLOOP.

* Je nach Anzahl der Summenstufen wird auf der Ausgabeliste eine Anzahl
* von '*'-Zeichen vor der entsprechenden Summenstufe vorangestellt.
* Deshalb muß zusätzlich zu den Sortierfeldern noch die Anzahl der
* Sterne berücksichtigt werden. Standardmässig werden auch noch 30
* Leerzeichen in der ersten Zeile ausgegeben, diese auch noch
* berücksichtigen.
  DESCRIBE TABLE it_feld LINES ld_lines.
  ed_blanks = ed_blanks + ld_lines.

endform.                    " get_blanks_from_sort_variant
