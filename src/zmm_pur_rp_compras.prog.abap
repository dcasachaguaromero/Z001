*&---------------------------------------------------------------------*
*& Report ZMM_PUR_RP_COMPRAS
*&---------------------------------------------------------------------*
*& Created by:
*&    Developer: Carlos Nievas - VisionOne
*&    Business:  Maryanireth Garcia
*& Created on :  05.06.2020
*& Description: Reporte que muestra información de un ciclo de compras,
*&              es decir, datos de OC, EM y VF.
*&---------------------------------------------------------------------*
REPORT zmm_pur_rp_compras MESSAGE-ID z001 NO STANDARD PAGE HEADING.

INCLUDE zmm_pur_rp_compras_top.  "Declaraciones globales
INCLUDE zmm_pur_rp_compras_sel.  "Pantalla de selección
INCLUDE zmm_pur_rp_compras_f01.  "Rutinas locales

*--------------------------------------------------------------------*
*        START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.

* Rescata datos de las ordenes de compra según criterios. Ideal sería
* utilizar un CDS tipo Table Control para hacer la lectura en la base
* de datos HANA pero la versión actual no contempla esa posibilidad
  PERFORM get_data_po TABLES gt_po.

  IF gt_po IS INITIAL.
*   No se encontraron datos para los criterios indicados
    MESSAGE i007.
    RETURN.
  ENDIF.

  CHECK NOT gt_po IS INITIAL.

* Buscar liberaciones
  PERFORM buscar_liberadores TABLES gt_po
                                    gt_lib.

* Buscar historial de los pedidos
  PERFORM buscar_historial TABLES gt_po
                                  gt_ekbe.

* Busca datos de aprobaciones/historial/stock y arma tabla de salida
  PERFORM armar_tabla_salida TABLES gt_po
                                    gt_lib
                                    gt_ekbe
                                    gt_sal.

  SORT gt_sal BY aedat ebeln ebelp belnr_m belnr_f.

* Salida en formato ALV
  PERFORM mostrar_reporte TABLES gt_sal.
