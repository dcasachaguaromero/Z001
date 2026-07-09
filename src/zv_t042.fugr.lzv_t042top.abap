FUNCTION-POOL zv_t042                    MESSAGE-ID sv.

* INCLUDE LZV_T042D...                       " Local class definition
INCLUDE lsvimdat                                . "general data decl.
INCLUDE lzv_t042t00                             . "view rel. data dcl.

* tables
TABLES: t005,
        *t001,
        x001,
        *x001.

DATA: absbu_t      LIKE t001-butxt,
      zbukr_t      LIKE t001-butxt,
      aktyp        TYPE c,
      g_jump       TYPE xfeld,
      gv_name_text TYPE ad_namtext.

DATA:    BEGIN OF f4hlp OCCURS 1.
           INCLUDE STRUCTURE dynpread.
         DATA:    END OF f4hlp.
DATA: BEGIN OF f4,
        pgnam(4) TYPE c VALUE '_110', " Programmname
        tdobject LIKE stxh-tdobject  " Anwendungsobjekt
                   VALUE 'FORM',
        tdid     LIKE stxh-tdid      " Text-ID
                   VALUE 'TXT ',
        ulsxx    LIKE t042-ulsk1,    " SHB-Liste
      END   OF f4.

DATA: BEGIN OF zv_t042_total_resp OCCURS 0010.
        INCLUDE STRUCTURE zv_t042.
        INCLUDE STRUCTURE vimflagtab.
      DATA: END OF zv_t042_total_resp.
