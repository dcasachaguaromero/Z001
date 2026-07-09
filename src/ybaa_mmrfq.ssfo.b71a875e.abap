CLEAR gs_pekpo.
READ TABLE it_pekpo
INTO  gs_pekpo
WITH  KEY  ebelp = <fs>-ebelp.
