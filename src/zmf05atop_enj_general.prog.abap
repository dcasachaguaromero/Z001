*----------------------------------------------------------------------*
*   INCLUDE MF05ATOP_ENJ_GENERAL                                       *
*----------------------------------------------------------------------*

* Options
  tables: rfopte,                      " options for Enjoy-Transactions
          t100,
          vbkpf.

* Data for error log
  data: begin of error_info occurs 0.
          include structure acerrlog.
  data: end of error_info.

* Fields
  data: bukrs_first like bkpf-bukrs,   " Initial Comp Code
        err_at_cc_change,              " same as name
        tab_fb00(10),                  " required tab for FB00
        txt_struc(25),
        tree_initialized,              " Is the tree initialized ?
        g_save_okcode(4),              " Saved OK-Code
        g_start_tcode like sy-tcode,   " Note 676189
        g_ok_at_pai like ok-code,      " OK at start of PAI Note 338030
        suppress_dialog    type xfeld, " Note 0410289
        xenj(1),                       " Transport to FB00
        act_vor(2) value '77'.         " parking

  data: rcode like sy-subrc.

* tree
  include Zcnt4defs.                    "tree
  include <icon>.                      "icons für tree

  data: tree_changed(1) value 'X',
        no_tree(1) value 'X',

        node_table       like treev_node occurs 0 with header line,
        item_table       like mtreeitm occurs 0 with header line,
        node_table_1     like treev_node occurs 0 with header line,
        item_table_1     like mtreeitm occurs 0 with header line,
        columns          like treev_col occurs 0,
        headers          like treev_hdr occurs 0,
        hierarchy_header like treev_hdr.

  type-pools: gstc .

* edit control
  data  xecex.

* first call
  data first_call(1) value 'X'.
  data  error_line like bseg-buzei.
* hold documents
  data: begin of tmp_documents occurs 0,
          unami like uf05a-unami,
          tempi like uf05a-tempi,
        end of tmp_documents,
        bseg_kk like bseg.

* GL account master of creditor/debitor main account       "Note 360551
  data: g_skb1_mwskz like skb1-mwskz.                      "Note 360551

* account assignment models
  data: acc_models type table of pkomu with header line.

* parked documents
  data: begin of parked_docs occurs 0,
          ausbk like vbkpf-ausbk,
          belnr like vbkpf-belnr,
          gjahr like vbkpf-gjahr,
          xprfg like vbkpf-xprfg,                           "P00K025312
          bktxt like vbkpf-bktxt,
          xblnr like vbkpf-xblnr,
          cpudt like vbkpf-cpudt,
          cputm like vbkpf-cputm,
          usnam like vbkpf-usnam,
          ldgrp like vbkpf-ldgrp,                            "n961805
          text  like mtreeitm-text,
        end of parked_docs.

* screen variants
  types: begin of ty_shdsvci_1,
           shdsvci type shdsvci,
           scvtext like shdsvtxci-scvtext,
         end of ty_shdsvci_1.
  data: tab_shdsvci_1 type standard table of ty_shdsvci_1
                      with header line.

* text screen variant
  data: g_scvtext like shdsvtxci-scvtext.

* Screen variant provided by transaction variant           "Note 331997
  data: g_scvariant type scvariant.                        "Note 331997

* Indicator: FM 'rs_hdsys_set_tablecontrol' exists         "Note1105095
  data: gd_fmstc_exists type xfeld.                        "Note1105095

* data input
  data: g_datar like sy-datar.

* global check variable
  data: g_check_req(1).

* field names contained in screens of function group fskb
* (del) data  field_220(20).                                "Note487375

  data: save_okcode(4).

* global state variable (parking=2, completing=3, posting=1, display=4)
  data: g_status(1) value '1'.         "default posting

* global variable to indicate that (parked) document already exists
* X = Parked document                                      "Note 387235
* M = Held document, derivations made (creditor/debitor)   "Note 387235
* N = Held document, no derivations                        "Note 387235
  data: g_document_exists(1).
  data: g_crosscomp type xfeld.      "X=CC doc.             "Note809539
* activation type (overwrites T020-AKTYP)
* V = Change (only for parket document)
* H = else
  data: g_aktyp.                                                   "DMC
* Store Key values of document for possible change
  data: g_existing_doc type existing_doc.                   "Note447783

* Indicator: Enjoy transaction called from FBV2/FBV3/List   "P00K030072
  data: g_enjoy_from_fbv0.                                  "Note988188
  data: g_enjoy_from_fbv2.                                 "P00K030072
  data: g_enjoy_from_fbv3.
  data: g_enjoy_from_list.                                 "Note676189
  data  g_fv50l_doc.                                       "Note961805
* Indicator and status of Workflow. Inserted by Note 485043.
  data: xwfaf TYPE c.                                      "N485043

* Indicator: Call dispatcher to analyze ok-code only       "Note 317872
  data: g_analyze.                                         "Note 317872

* Return code used locally                                 "Note 393382
  data: g_subrc type subrc.                                "Note 393382


* Requesting objects, when called by a workflow            "Note 305821
  data: g_requester like swotobjid.                        "Note 304821
  data: tab_requester type table of swotobjid              "Note 305821
                      with header line.                    "Note 305821

* temporary internal table
  data xbseg_sav type bseg occurs 0 with header line.

* GL items                                                 "Note 193980
  data: gl_items like bsegs occurs 0 with header line.     "Note 193980

* fields of vbkpf not contained in bkpf
  data: g_xwffr type xwffr,
        g_xfrge type xfrge,
        g_xprfg type xprfg,
        g_upddt type upddt,
        g_reldt type releasedate,
        g_updtm type cputm,
        g_reltm type cputm,
        g_exit(1).

* XBSEG, XBKPF when starting simulation
  data: xbseg_sim type table of bseg,                      "Note668737
        xbkpf_sim type table of bkpf.

* Indicator: One time business partner data missing        "Note 325240
  data: g_cpd_req.                                         "Note 325240

* Indicator: Check document number                          "Note416081
  data: g_check_number type xfeld.                          "Note416081

* First and last BUZEI processed in the table control       "Note487375
  data: g_first_line like bseg-buzei,                       "Note487375
        g_last_line like bseg-buzei.                        "Note487375

* Indicator: Posting forbidden in simulation mode           "Note482563
  data: g_posting_forbidden type xfeld.                     "Note482563

* Indicator: Parking forbidden in simulation mode           "Note482563
  data: g_parking_forbidden type xfeld.                     "Note482563

* Indicator: Assignment template                            "Note536015
  data: g_komu type xfeld.                                  "Note536015
  data: g_komu_add type xfeld.                              "Note568934

* Indicator: Error in complete parking                      "Note 604100
  data: x_epbbp type xfeld.                                 "Note 604100

* GL in ERP
  data: gd_GLFLEX_active(1) value 'I'.                      "L = FB50L

* Original TCODE in case of failed try to post parked document
  DATA:  g_orig_tcode like bkpf-tcode.                      "Note1139902
