*&---------------------------------------------------------------------*
*& Report YRELREM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT YRELREM.
*&---------------------------------------------------------------------*
*& Report  YRELREM                                                     *
*&---------------------------------------------------------------------*
*&  Relatório de remessas                                              *
*&  Autor: Wilson Costa                                                *
*&  Data: 10/08/1999                                                   *
*&---------------------------------------------------------------------*
*$ YRELREM
*$
*$0 Wilson  - 10/08/1999
*$1 Olympio - 29/11/1999 - D01K905652 - Alterado forma de cálculo do
*             volume das remessas qdo tem amostras e produtos na mesma
*             remessa, e colocado o cep do cliente na etiqueta a pedido
*             do Bernard.
*$2 Olympio - 18/05/2000 - D01K910183 - Colocadas 2 novas colunas de
*             fila e Unidade, para ajudar a preparação do picking, e
*             também o lote fornecedor dos produtos importados que ti-
*             verem.
*----------------------------------------------------------------------*

*REPORT YRELREM NO STANDARD PAGE HEADING LINE-SIZE 80.

* Tabelas que serão utilizadas no relatório
TABLES: KNA1,       " Clientes
        VBAK,       " Cabeçalho do documento de vendas
        VBAP,       " Itens do documento de vendas
        LIKP,       " Cabeçalho da remessa
        LIPS,       " Itens da remessa
        LTAP,       " Itens de ordens de transferência
        LTAK,       " Cabeçalho de ordens de transferência
        KNVV,       " Tipo de cliente
        T311,       " Referencias
        VBPA,       " Parceiros do documento de vendas
        LFA1,       " Fornecedores
        T001,       " Empresas
        MLGT,       " Quantidade de unidades por caixa por dep/produto
        MARA,       " Materiais
        MCH1,       " Lotes (p/ administr. lotes a nível todos centros)
        YWMCXEMB,   " Tabela customizada com tamanho das caixas do pick
        YWMVOLUM,   " Tabela customizada com volumes das remessas
        YWMVOLUMCX, " Tabela customizada com caixas das remessas
        *VBAK,
        *LIPS,
        MVKE.       " Tabela caracteristicas

* Estruturas que serão utilizadas no relatório
DATA: BEGIN OF LIKP_INT OCCURS 100,
      DESCREF         LIKE T311-REFNT,
      REFNR(10)       TYPE N,
      NUMREM          LIKE LIKP-VBELN,
      DATAREM         LIKE LIKP-LFDAT.
DATA: END OF LIKP_INT.

DATA: BEGIN OF LIPS_INT OCCURS 100,
      NUMREM           LIKE LIPS-VBELN,
      ITMREM           LIKE LIPS-POSNR,
      VALLIQ           LIKE LIPS-NETWR,
      PESBRUTO         LIKE LIPS-BRGEW,
      NUMPED           LIKE LIPS-VGBEL,
      ITMPED           LIKE LIPS-VGPOS,
      CODCLICOMP       LIKE KNA1-KUNNR,
      NOMECLICOMP      LIKE KNA1-NAME1,
      CIDCLICOMP       LIKE KNA1-ORT01,
      CEPCLICOMP       LIKE KNA1-PSTLZ,
      PAISCLICOMP      LIKE KNA1-REGIO,
      GRPCLICOMP       LIKE KNVV-KDGRP,
      CODCLIREC        LIKE KNA1-KUNNR,
      NOMECLIREC       LIKE KNA1-NAME1,
      CIDCLIREC        LIKE KNA1-ORT01,
      PAISCLIREC       LIKE KNA1-REGIO,
      CODTRANS         LIKE LFA1-LIFNR,
      NOMETRANS        LIKE LFA1-NAME1.
DATA: END OF LIPS_INT.

DATA: BEGIN OF LTAP_INT OCCURS 100,
      NUMDEPOS         LIKE LTAP-LGNUM,
      NUMOT            LIKE LTAP-TANUM,
      ITMOT            LIKE LTAP-TAPOS,
      CODPRO           LIKE LTAP-MATNR,
      DESCPRO          LIKE LTAP-MAKTX,
      TIPDEPOS         LIKE LTAP-VLTYP,
      END              LIKE LTAP-VLPLA,
      PALETE           LIKE LTAP-VLENR,
      LOTE             LIKE LTAP-CHARG,
      LOTE_FORN        LIKE MCH1-LICHA,
      REMA             LIKE MARM-UMREZ,
      QTD              LIKE LTAP-VSOLA,
      NUMREM           LIKE LIKP-VBELN.
DATA: END OF LTAP_INT.

DATA: BEGIN OF MLGT_INT OCCURS 100,
      CODPRO           LIKE MLGT-MATNR,
      TIPDEPOS         LIKE MLGT-LGTYP,
      QTDEST           LIKE MLGT-RDMNG,
      QTDESTMIN        LIKE MLGT-LPMIN,
      PICKING          LIKE MLGT-KOBER,
      QTDESTMAX        LIKE MLGT-LPMAX.
DATA: END OF MLGT_INT.

DATA: BEGIN OF LTAP105_INT OCCURS 100.
      INCLUDE STRUCTURE LTAP_INT.
DATA: END OF LTAP105_INT.

DATA: BEGIN OF CAIXAS OCCURS 100,
      TIPOCX(2)        TYPE N,
      QTDCX(5)         TYPE N.
DATA: END OF CAIXAS.

DATA: BEGIN OF ETIQ_INT OCCURS 100,
      TIPO_ETIQ        TYPE N,
      NUMREF           LIKE LTAK-REFNR,
      NUMREM           LIKE LIPS-VBELN,
      TIPDEPOS         LIKE LTAP-VLTYP,
      PICKING          LIKE MLGT-KOBER,
      CODPRO           LIKE LTAP-MATNR,
      LOTE             LIKE LTAP-CHARG,
      LOTE_FORN        LIKE MCH1-LICHA,
      CODTRAN          LIKE LFA1-LIFNR,
      CODCLI           LIKE KNA1-KUNNR,
      NOMECLI          LIKE KNA1-NAME1,
      CIDCLI           LIKE KNA1-ORT01,
      CEPCLI           LIKE KNA1-PSTLZ,
      UFCLI            LIKE KNA1-REGIO,
      NOMETRANS        LIKE LFA1-NAME1,
      DATA             LIKE YWMVOLUM-DATA,
      VOLUME(4)        TYPE N,
      ENDERECO         LIKE LTAP-VLPLA,
      NOMEPRO          LIKE LTAP-MAKTX,
      INDICE(4)        TYPE N,
      TIPOCLI          LIKE YWMVOLUM-TIPOCLI.
DATA: END OF ETIQ_INT.

DATA: BEGIN OF ARQUIVO OCCURS 100,
      LINHA_ARQ(100)   TYPE C.
DATA: END OF ARQUIVO.

DATA: BEGIN OF TABTEMP OCCURS 100,
      CODTRANS          LIKE LIPS_INT-CODTRANS,
      NOMETRANS         LIKE LIPS_INT-NOMETRANS,
      NUMREF            LIKE LIKP_INT-REFNR,
      DESCREF           LIKE LIKP_INT-DESCREF,
      CODPRO            LIKE LTAP_INT-CODPRO,
      DESCPRO           LIKE LTAP_INT-DESCPRO,
      OR(5)             TYPE N,
      LOTE              LIKE LTAP_INT-LOTE,
      QUANT(5)          TYPE N,
      FECH(5)           TYPE N,
      FRACAO(5)         TYPE N,
      NUMREM            LIKE LTAP_INT-NUMREM,
      TIPDEPOS          LIKE LTAP_INT-TIPDEPOS.
DATA: END OF TABTEMP.

DATA: BEGIN OF TABTEMP2 OCCURS 100.
      INCLUDE STRUCTURE TABTEMP.
DATA: END OF TABTEMP2.

DATA: BEGIN OF END_INT OCCURS 100,
      REFNR(10)       TYPE N,
      DESCREF         LIKE T311-REFNT,
      NUMREM          LIKE LIKP-VBELN,
      DATAREM         LIKE LIKP-LFDAT,
      NUMDEPOS         LIKE LTAP-LGNUM,
      NUMOT            LIKE LTAP-TANUM,
      ITMOT            LIKE LTAP-TAPOS,
      CODPRO           LIKE LTAP-MATNR,
      DESCPRO          LIKE LTAP-MAKTX,
      TIPDEPOS         LIKE LTAP-VLTYP,
      END              LIKE LTAP-VLPLA,
      PALETE           LIKE LTAP-VLENR,
      LOTE             LIKE LTAP-CHARG,
      QTD              LIKE LTAP-VSOLA,
      FECH             LIKE TABTEMP-FECH.
DATA: END OF END_INT.

DATA: BEGIN OF END105_INT OCCURS 100,
      REFNR(10)        TYPE N,
      DESCREF          LIKE T311-REFNT,
      NUMREM           LIKE LIKP-VBELN,
      DATAREM          LIKE LIKP-LFDAT,
      NUMDEPOS         LIKE LTAP-LGNUM,
      NUMOT            LIKE LTAP-TANUM,
      ITMOT            LIKE LTAP-TAPOS,
      CODPRO           LIKE LTAP-MATNR,
      DESCPRO          LIKE LTAP-MAKTX,
      TIPDEPOS         LIKE LTAP-VLTYP,
      END              LIKE LTAP-VLPLA,
      PALETE           LIKE LTAP-VLENR,
      LOTE             LIKE LTAP-CHARG,
      QTD              LIKE LTAP-VSOLA,
      FECH             LIKE TABTEMP-FECH.
DATA: END OF END105_INT.

* Variáveis que serão utilizadas no relatório
DATA: EMPRESA           LIKE T001-BUKRS VALUE 'SASY',
      CENTRO            LIKE LTAP-LGORT VALUE 'SASY',
      DEP               LIKE LTAP-WERKS VALUE 'PROD',
      PAG(3)            TYPE N VALUE '1',
      LINHA(2)          TYPE N VALUE '0',
      NUMPROD           LIKE LTAP_INT-CODPRO,
      NUMLOTE           LIKE LTAP_INT-LOTE,
      NOMEPROD          LIKE LTAP_INT-DESCPRO,
      TOTQTD(6)         TYPE N,
      TOTFE(4)          TYPE N,
      TOTFR(4)          TYPE N,
      UNIDCX(4)         TYPE N,
      END(5)            TYPE C,
      NREM              LIKE LTAK-VBELN,
      TRANSP            LIKE LFA1-LIFNR,
      FECH(3)           TYPE N,
      OR1(4)            TYPE N,
      TOT(6)            TYPE N,
      FRA(4)            TYPE N,
      MSG(50)           TYPE C,
      TOTPESBRUTO       LIKE LIPS-BRGEW,
      TOTVALLIQ(13)     TYPE P DECIMALS 2,
      TOTFECH(10)       TYPE N,
      VTOTFECH(5)       TYPE N,
      TOTFRA(10)        TYPE N,
      TOTCXFRA(4)       TYPE N,
      TOTCX105(5)       TYPE N,
      VOLMAT(10)        TYPE N,
      FLAG_END          TYPE N VALUE 0,
      INDEX_ETIQ(3)     TYPE N VALUE 0,
      FLAG_START        TYPE N VALUE 0,
      TOTCXFECH(4)      TYPE N,
      TOTPESO(8)        TYPE N,
      QTDREM(3)         TYPE N,
      CODTRANS          LIKE LIPS_INT-CODTRANS,
      NOMETRANS         LIKE LIPS_INT-NOMETRANS,
      TOTGERPESO(8)     TYPE N,
      TOTGERCXFECH(4)   TYPE N,
      TOTGERCXFRA(4)    TYPE N,
      TOTGERREM(3)      TYPE N,
      TOTGERVAL(13)     TYPE P DECIMALS 2,
      V_FORM            LIKE LTAP_INT-END,
      V_PASSOU(1),
      PORTA(4),
      CORTA(1),
      FILA(4),
      FILA_UN(2),
      M_LICHA           LIKE MCH1-LICHA,
      M_UMREZ           LIKE MARM-UMREZ,
      VOL1(10)          TYPE N,
      VOL2(10)          TYPE N,
      VOL3(10)          TYPE N,
      VOL4(10)          TYPE N,
      VOLAMOSTRA(10)    TYPE N,
      VOLLITERA(10)     TYPE N,
      VOLPROMO(10)      TYPE N.

* Inclusões de outros programas
INCLUDE YINCRELRP.
INCLUDE YINCRELRC.
INCLUDE YINCRELRT.
INCLUDE YINCRELRR.
INCLUDE YINCIMPETQREM.

* Seleções possíveis para o relatório
SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK GERAL WITH FRAME TITLE T1.
   SELECT-OPTIONS REF FOR LTAK-REFNR.
   SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN COMMENT 1(30) L1.
      SELECTION-SCREEN POSITION 33.
      PARAMETERS: TIPOREL LIKE YTIPORELREM-TIPOREL DEFAULT 'RP'.
   SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK GERAL.

SELECTION-SCREEN BEGIN OF BLOCK IMP WITH FRAME TITLE T2.
   SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN COMMENT 4(30) L2.
      SELECTION-SCREEN POSITION 1.
      PARAMETERS IMPETIQ AS CHECKBOX DEFAULT 'X'.
   SELECTION-SCREEN END OF LINE.
   SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN COMMENT 4(35) L5.
      SELECTION-SCREEN POSITION 1.
      PARAMETERS CORTAETQ AS CHECKBOX DEFAULT ' '.
   SELECTION-SCREEN END OF LINE.
   SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN COMMENT 4(30) L3.
      SELECTION-SCREEN POSITION 1.
      PARAMETERS PORTA1 RADIOBUTTON GROUP PRT DEFAULT 'X'.
   SELECTION-SCREEN END OF LINE.
   SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN COMMENT 4(30) L4.
      SELECTION-SCREEN POSITION 1.
      PARAMETERS PORTA2 RADIOBUTTON GROUP PRT.
   SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK IMP.

* Inicialização da tela de seleção
INITIALIZATION.
   T1 = 'REFERÊNCIA'.
   T2 = 'IMPRESSÃO'.
   L1 = 'TIPO DE RELATÓRIO'.
   L2 = 'IMPRIMIR ETIQUETAS'.
   L3 = 'PORTA DE COMUNICAÇÃO 1 (COM1)'.
   L4 = 'PORTA DE COMUNICAÇÃO 2 (COM2)'.
   L5 = 'CORTAR CADA MUDANÇA NAS ETIQUETAS'.

* Selecionar conforme o tipo de relatório
START-OF-SELECTION.

   IF PORTA1 EQ 'X'.
      PORTA = 'COM1'.
   ELSEIF PORTA2 EQ 'X'.
      PORTA = 'COM2'.
   ENDIF.
   MOVE CORTAETQ TO CORTA.

   " Preencher as tabelas internas necessárias para os relatórios
   PERFORM PREENCHE_TABINT.

   CASE TIPOREL.

      " Tipo de relatório de remessas de picking
      WHEN 'RP'.
         PERFORM IMPRIME_RELRP USING IMPETIQ PORTA CORTA.

      " Tipo de relatório de caixas fechadas
      WHEN 'RC'.
         PERFORM IMPRIME_RELRC.

      " Tipo de relatório de remessas de picking
      WHEN 'RT'.
         PERFORM IMPRIME_RELRT.

      " Tipo de relatório resumo das remessas por transportadora
      WHEN 'RR'.
         PERFORM IMPRIME_RELRR.

   ENDCASE.

END-OF-SELECTION.

* Preenche as tabelas internas para utilização dos relatórios
FORM PREENCHE_TABINT.

   SELECT * FROM LTAK WHERE REFNR IN REF.

      SELECT * FROM LTAP WHERE LGNUM = LTAK-LGNUM AND
      TANUM = LTAK-TANUM.

         MOVE LTAP-LGNUM TO LTAP_INT-NUMDEPOS.
         MOVE LTAP-TAPOS TO LTAP_INT-ITMOT.
         MOVE LTAP-TANUM TO LTAP_INT-NUMOT.
         MOVE LTAP-MATNR TO LTAP_INT-CODPRO.
         MOVE LTAP-MAKTX TO LTAP_INT-DESCPRO.
         MOVE LTAP-VLTYP TO LTAP_INT-TIPDEPOS.
         MOVE LTAP-VLPLA TO LTAP_INT-END.
         MOVE LTAP-VLENR TO LTAP_INT-PALETE.
         MOVE LTAP-CHARG TO LTAP_INT-LOTE.
         "MOVE ltap-vsola TO ltap_int-qtd.
         LTAP_INT-QTD = LTAP-VSOLA + LTAP-VDIFA.
         MOVE LTAK-VBELN TO LTAP_INT-NUMREM.

         "Procura o lote do fornecedor se existir, gravar na tabela
         SELECT SINGLE LICHA INTO M_LICHA
                FROM MCH1 WHERE MATNR = LTAP-MATNR
                            AND CHARG = LTAP-CHARG
                            AND LICHA <> ''
                            AND HERKL <> ''.
         IF SY-SUBRC = 0.
            MOVE M_LICHA TO LTAP_INT-LOTE_FORN.
         ELSE.
            CLEAR LTAP_INT-LOTE_FORN.
         ENDIF.

         LTAP_INT-REMA = 0.
         "Procura o fator de conversão REMA e divide a quantidade
         SELECT SINGLE UMREZ INTO M_UMREZ
                FROM MARM WHERE MATNR = LTAP-MATNR
                            AND MEINH = 'FIL'.

         LTAP_INT-REMA = M_UMREZ.

         IF LTAP_INT-QTD > 0.
            APPEND LTAP_INT.
         ENDIF.

      ENDSELECT.

      SELECT * FROM LIKP WHERE VBELN = LTAK-VBELN.

         MOVE LTAK-REFNR TO LIKP_INT-REFNR.
         SELECT * FROM T311 WHERE LGNUM = LTAK-LGNUM AND
         REFNR = LTAK-REFNR.
            MOVE T311-REFNT TO LIKP_INT-DESCREF.
         ENDSELECT.
         MOVE LIKP-VBELN TO LIKP_INT-NUMREM.
         MOVE LIKP-LFDAT TO LIKP_INT-DATAREM.
         APPEND LIKP_INT.

         SELECT * FROM LIPS WHERE VBELN = LIKP-VBELN.

            MOVE LIPS-VBELN TO LIPS_INT-NUMREM.
            MOVE LIPS-POSNR TO LIPS_INT-ITMREM.

            SELECT * FROM VBAK WHERE VBELN = LIPS-VGBEL.
               MOVE VBAK-NETWR TO LIPS_INT-VALLIQ.
            ENDSELECT.

            MOVE LIPS-BRGEW TO LIPS_INT-PESBRUTO.
            MOVE LIPS-VGBEL TO LIPS_INT-NUMPED.
            MOVE LIPS-VGPOS TO LIPS_INT-ITMPED.

            " Buscar os dados do cliente comprador da mercadoria
            SELECT * FROM VBPA WHERE VBELN = LIPS-VGBEL
            AND PARVW = 'AG'.
               SELECT * FROM KNA1 WHERE KUNNR = VBPA-KUNNR.
                  MOVE KNA1-KUNNR TO LIPS_INT-CODCLICOMP.
                  MOVE KNA1-NAME1 TO LIPS_INT-NOMECLICOMP.
                  MOVE KNA1-ORT01 TO LIPS_INT-CIDCLICOMP.
                  MOVE KNA1-PSTLZ TO LIPS_INT-CEPCLICOMP.
                  MOVE KNA1-REGIO TO LIPS_INT-PAISCLICOMP.
                  SELECT * FROM KNVV WHERE KUNNR = KNA1-KUNNR.
                     MOVE KNVV-KDGRP TO LIPS_INT-GRPCLICOMP.
                  ENDSELECT.
               ENDSELECT.
            ENDSELECT.

            " Buscar os dados do cliente recebedor da mercadoria
            SELECT * FROM VBPA WHERE VBELN = LIPS-VGBEL
            AND PARVW = 'WE'.
               SELECT * FROM KNA1 WHERE KUNNR = VBPA-KUNNR.
                  MOVE KNA1-KUNNR TO LIPS_INT-CODCLIREC.
                  MOVE KNA1-NAME1 TO LIPS_INT-NOMECLIREC.
                  MOVE KNA1-ORT01 TO LIPS_INT-CIDCLIREC.
                  MOVE KNA1-REGIO TO LIPS_INT-PAISCLIREC.
               ENDSELECT.
            ENDSELECT.

            " Buscar os dados do transportador da mercadoria
            SELECT * FROM VBPA WHERE VBELN = LIPS-VGBEL
            AND PARVW = 'SP'.
               SELECT * FROM LFA1 WHERE LIFNR = VBPA-LIFNR.
                  MOVE LFA1-LIFNR TO LIPS_INT-CODTRANS.
                  MOVE LFA1-NAME1 TO LIPS_INT-NOMETRANS.
               ENDSELECT.
            ENDSELECT.

            APPEND LIPS_INT.

         ENDSELECT.
      ENDSELECT.
   ENDSELECT.

   SELECT * FROM MLGT.
      MOVE MLGT-MATNR TO MLGT_INT-CODPRO.
      MOVE MLGT-LGTYP TO MLGT_INT-TIPDEPOS.
      MOVE MLGT-RDMNG TO MLGT_INT-QTDEST.
      MOVE MLGT-LPMIN TO MLGT_INT-QTDESTMIN.
      MOVE MLGT-LPMAX TO MLGT_INT-QTDESTMAX.
      MOVE MLGT-KOBER TO MLGT_INT-PICKING.
      APPEND MLGT_INT.
   ENDSELECT.

ENDFORM.
