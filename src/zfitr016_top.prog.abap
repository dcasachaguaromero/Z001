*&---------------------------------------------------------------------*
*&  Include           ZFITR016_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_out_reg_bci,
         mod_servico(1)    TYPE c,
         rut_prv(08)       TYPE n,
         rut_prv_dvr(01)   TYPE c,
         unidad(5)         TYPE c,
         nombre_prv(45)    TYPE c,
         medio_aviso(1)    TYPE c,
         direc_aviso(35)   TYPE c,
         comuna_aviso(4)   TYPE n,
         forma_pago(3)     TYPE c,
         cod_banco(03)     TYPE n,
         cuenta_cte(20)    TYPE n,
         cod_sucursal(03)  TYPE n,
         tipo_docto(03)    TYPE c,
         nro_docto(12)     TYPE n,
         nro_docto_rel(12) TYPE n,
         valor_info(11)    TYPE n, " cambio de 12 a 10
         valor_pago(11)    TYPE n, " cambio de 12 a 10
         estado_pago(03)   TYPE c,
         fecha_vcto(08)    TYPE c,
         fecha_pago(8)     TYPE c,
         glosa(30)         TYPE c,
         rut_ret1(08)      TYPE n,
         rut_ret1_dvr(01)  TYPE c,
         paterno1(15)      TYPE c,
         materno1(15)      TYPE c,
         nombre1(15)       TYPE c,
         rut_ret2(08)      TYPE n,
         rut_ret2_dvr(01)  TYPE c,
         paterno2(15)      TYPE c,
         materno2(15)      TYPE c,
         nombre2(15)       TYPE c,
       END OF ty_out_reg_bci,
       BEGIN OF ty_rendicion,
         rut_beneficiario TYPE char08,
         div_beneficiario TYPE char01,
         razon_social     TYPE char45,
         unidad           TYPE char10,
         nro_doc_relac    TYPE char12,
         nro_documento    TYPE char12,
         forma_pago       TYPE char03,
         banco_destino    TYPE char03,
         nro_cta_destino  TYPE char12,
         oficina_destino  TYPE char03,
         monto_pago       TYPE char13,
         fecha_pago       TYPE char08,
         estado_pago      TYPE char05,
         glosa            TYPE char50,
         filer            TYPE char105,
       END OF ty_rendicion,
       ty_t_out_reg_bci TYPE STANDARD TABLE OF ty_out_reg_bci,
       ty_t_rendicion   TYPE STANDARD TABLE OF ty_rendicion.
*
DATA : BEGIN OF wa_selec,
         datum    TYPE datum,
         uname    TYPE syuname,
         convenio TYPE zfitr016-convenio,
       END OF wa_selec,
       BEGIN OF wa_sociedad,
         bukrs  TYPE bukrs,
         stcd1  TYPE stcd1,
         puerto TYPE  char060,
       END OF wa_sociedad,
       wa_zfitr016 TYPE zfitr016.
*
DATA : gt_tabla_00     TYPE TABLE OF reguh,
       gt_out_reg_bci  TYPE TABLE OF ty_out_reg_bci,
       gt_list         TYPE vrm_values,
       gt_convenio     TYPE vrm_values,
       gt_salida       TYPE TABLE OF zfi_log_ws,
       gv_contar       TYPE numc06,
       gv_sumpagos     TYPE numc15,
       gv_nvoant       TYPE char01,
       gv_contardoc    TYPE numc06,
       gv_contabilizar TYPE char01,
       gv_repid        TYPE syrepid,
       gv_fecha_pg     TYPE xflag,
       gv_lineas       TYPE numc5,
       gv_bktxt        TYPE bkpf-bktxt,
       gv_zaldt        TYPE reguh-zaldt,
       gv_cuenta       TYPE reguh-ubhkt,
       gv_cuenta_2     TYPE reguh-ubhkt,
       gv_secuencia    TYPE numc2,
       gv_zzmot_emis   TYPE bseg-zzmot_emis,
       gv_day          TYPE cind,
       gv_valut        TYPE reguh-valut.
*
TYPES : BEGIN OF ty_file,
          linea(640) TYPE c,
        END OF ty_file,
        ty_gt_file TYPE TABLE OF ty_file.
*
DATA : BEGIN OF gt_file OCCURS 0,
         linea(640) TYPE c.
DATA : END OF gt_file.

*
DATA : gr_fac     TYPE RANGE OF bkpf-blart,
       gr_ncr     TYPE RANGE OF bkpf-blart,
       gr_proceso TYPE RANGE OF char10.
*
CONSTANTS: gc_banco TYPE c LENGTH 15 VALUE '016',
           gc_x     TYPE c LENGTH 01 VALUE 'X',
           gc_tabla TYPE c LENGTH 30 VALUE 'ZFI_LOG_WS'.

*
CLASS lcl_evt_handler DEFINITION.
  PUBLIC SECTION.
    METHODS: event_close FOR EVENT close OF cl_gui_dialogbox_container IMPORTING sender.
ENDCLASS.
