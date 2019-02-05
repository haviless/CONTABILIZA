Unit oaContabiliza;

//  xTipoC='P'     Si Previo
//  xTipoC='C'     Si Contabiliza
//  xTipoC='BP'    Si Contabiliza Bloque
//  xTipoC='PCNA'  Si Previo con Caja que NO es Autonoma
//  xTipoC='CCNA'  Si Contabiliza con Caja que NO es Autonoma
//  xTipoC='M'     Solo Mayoriza
//  xTipoC='MC'    Solo Mayoriza Cuenta
//  xTipoC='MCACC' Solo Mayoriza Cuentas con Auxiliar y C.Costo
//

// Inicio Uso Estándares:   01/08/2011
// Unidad               :   oaContabiliza
// Formulario           :   FoaConta
// Fecha de Creación    :
// Autor                :   Equipo de Desarrollo
// Objetivo             :   Contabilizar las Operaciones de caja.
//
// Actualizaciones      :
// HPC_201109_CAJA  24/01/2013  Se modifica el indicador de Automático en la
//                              generación del detalle de los asientos
// HPC_201301_CNT   18/02/2013  Se restituye marca de Flag automático para generación
//                              de asientos automáticos.
// HPC_201401_CNT               Se realizan adecuaciones para que mayorice el mes 13.
// HPC_201701_CAJA  Modificar calculo de Diferencia de cambio para pagos en dólares

Interface

Uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, db,
   DBClient, wwclient, MConnect, ComCtrls, StdCtrls, ExtCtrls, Buttons,
   Wwdatsrc, ppCtrls, SConnect;
Type
   TFoaConta = Class(TForm)
      Label1: TLabel;
   Private
    { Private declarations }

      xxSuma: String;
      wFlTexto: String;

      Procedure GeneraEnLinea401(xxxCia, xxxDiario, xxxAnoMM, xxxNoComp, xSuma: String);
    //function  CuentaExiste( xCia1, xAno1, xCuenta1, xAux1, xCCos1: String ): Boolean;
      Function CuentaExiste(xCia1, xAno1, xCuenta1, xClAux1, xAux1, xCCos1: String): Boolean;
      Procedure InsertaMov(cCia, cAnoMM, cCuenta, cClAux, cAux, cCCosto, cDH, cMov,
         cCtaDes, cAuxDes, cCCoDes, cNivel, cTipReg: String; nImpMN, nImpME: Double);
      Procedure ActualizaMov(cCia, cAnoMM, cCuenta, cClAux, cAux, cCCosto, cDH, cMov,
         cCtaDes, cAuxDes, cCCoDes, cNivel, cTipReg: String;
         nImpMN, nImpME: Double);
      Function StrZero(wNumero: String; wLargo: Integer): String;
      Function FRound(xReal: DOUBLE; xEnteros, xDecimal: Integer): DOUBLE;
      Procedure AplicaDatos(wCDS: TClientDataSet; wNomArch: String);
      Procedure CreaPanel(xForma: TForm; xMensaje: String);
      Procedure PanelMsg(xMensaje: String; xProc: Integer);
      Procedure GeneraAsientosComplementarios(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
      Procedure GeneraAsientosGlobal(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
      Procedure GeneraAsientoGlobal_N1(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
      Procedure GeneraAsientoGlobal_N2(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
      Procedure GeneraAsientoGlobal_N3(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
      Procedure GeneraAsientoGlobal_N4(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
      Procedure GeneraAsientoGlobal_NDif(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet); // HPC_201701_CAJA
      Procedure cdsPost(xxCds: TwwClientDataSet);
      Procedure AsientosComplementarios(xCia, xDiario, xAnoMM, xNoComp: String);
      Procedure GeneraMayorPresupuestos(xxxCia, xxxUsuario, xxxNumero, xSuma: String);
      Function PPresExiste(xCia1, xAno1, xCuenta1, xCCosto1, xTipPres1: String): Boolean;
      Procedure InsertaPPres(cCia, cAnoMM, cCuenta, cCCosto, cTipPres, cTipoCol, cDH, cMov,
         cCtaDes, cNivel: String; nImpMN, nImpME: Double);
      Procedure ActualizaPPres(cCia, cAnoMM, cCuenta, cCCosto, cTipPres, cTipoCol, cDH, cMov,
         cCtaDes, cNivel: String; nImpMN, nImpME: double);
      Procedure CerrarTablas;
      Procedure AsientosAdicionales(xCiaOri, xOrigen2, xAnoMM, xNoComp1, xNoCP: String; wMtoOri_P: Double);
   Public
    { Public declarations }
   End;

Var
   FoaConta: TFoaConta;
   s_vgUsuario: String;
   s_vgPassword: String;
   iOrden: integer;
   wReplaCeros: String;
   DCOM_C: TSocketConnection;
   cdsNivel_C: TwwClientDataSet;
   cdsPresup_C: TwwClientDataSet;
   cdsQry_C: TwwClientDataSet;
   cdsQry_D: TwwClientDataSet;
   cdsQry_G: TwwClientDataSet;
   cdsResultSet_C: TwwClientDataSet;
   cdsMovPRE2: TwwClientDataSet;
   cdsCNT: TwwClientDataSet;
   Errorcount2: Integer;
   SRV_C: String;
   pnlConta_C: TPanel;
   pbConta_C: tprogressbar;
   CNTCab: String;
   CNTDet: String;
   Provider_C: String;
   xCtaDebe: String;
   xAux_D: String;
   xCCos_D: String;
   xCtaHaber: String;
   xCtaRetHaber: String;
   xCtaRetDebe: String;
   xGlosaRetHaber, xGlosaRetDebe: String;
   xAux_H: String;
   xCCos_H: String;
   xOrigen: String;
   xCiaOri: String;
   xOrigen2: String;
   xNoComp1: String;
   xNoComp2: String;
   xNoCompP: String;
   xRutaVoucher: String;
   xUsuarioRep: String;
   xSQLAdicional: String;
   xSQLAdicional2: String;
   xRegAdicional: String;
   xTipoC_C: String;
   wTMay: String;
   wOrigenPRE: String;
   wTMonExt_C, wTMonLoc_C: String;
   wMtoOri_C, wMtoLoc_C, wMtoExt_C, wMtoDif: Double;
   wDoc_C, wSerie_C, wNodoc_C, wCtaBanco_C, wNoChq_C: String;
   wCptoGan, wCptoPer, wCtaGan, wCtaPer, wCCosDif: String;

Function SOLConta(xCia, xTDiario, xAnoMM, xNoComp, xSRV, xTipoC, xModulo: String;
   cdsMovCNT, cdsNivelx, cdsResultSetx: TwwClientDataSet;
   DCOMx: TSocketConnection;
   xForm_C: TForm): Boolean;

Function SOLContaG(xCia, xTDiario, xAnoMM, xNoComp, xSRV, xTipoC, xModulo: String;
   cdsMovCNT, cdsNivelx, cdsResultSetx: TwwClientDataSet;
   DCOMx: TSocketConnection;
   xForm_C: TForm): Boolean;

Function SOLDesConta(xxxCia, xxxDiario, xxxAnoMM, xxxNoComp, xSRV: String;
   cdsNivelx: TwwClientDataSet;
   DCOMx: TSocketConnection; xForm_C: TForm): Boolean;

Function SOLPresupuesto(xCia, xUsuario, xNumero, xSRV, xModulo: String;
   cdsResultSetx: TwwClientDataSet;
   DCOMx: TSocketConnection;
   xForm_C: TForm; xTipoMay: String): Boolean;
//
//   xTipoMay='A'  Mayorizacion es Anual    es decir Mayoriza el año completo
//   xTipoMay='M'  Mayorizacion es Mensual  es decir Mayoriza el Mes que se envia
//
Implementation

{$R *.DFM}

Function SOLDesConta(xxxCia, xxxDiario, xxxAnoMM, xxxNoComp, xSRV: String;
   cdsNivelx: TwwClientDataSet;
   DCOMx: TSocketConnection; xForm_C: TForm): Boolean;
Var
   xSQL: String;
Begin
   SRV_C := xSRV;
   CNTDet := 'CNT301';
   Provider_C := 'dspTem6';
   DCOM_C := DCOMx;

   cdsNivel_C := cdsNivelx;

   cdsQry_C := TwwClientDataSet.Create(Nil);
   cdsQry_C.RemoteServer := DCOMx;
   cdsQry_C.ProviderName := Provider_C;

   If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
   Begin
      wReplaCeros := 'COALESCE';
   End
   Else
      If SRV_C = 'ORACLE' Then
      Begin
         wReplaCeros := 'NVL';
      End;

   FoaConta.CreaPanel(xForm_C, 'Contabilizando');
{
   xSql:='UPDATE CNT300 SET CNTCUADRE=NULL, CNTESTADO=''I'' '
        +'Where CIAID='     +quotedstr( xxxCia    )+' and '
        +      'TDIARID='   +quotedstr( xxxDiario )+' and '
        +      'CNTANOMM='  +quotedstr( xxxAnoMM  )+' and '
        +      'CNTCOMPROB='+quotedstr( xxxNoComp );
   try
      cdsQry_C.Close;
      cdsQry_C.DataRequest( xSQL );
      cdsQry_C.Execute;
   except
      Errorcount2:=1;
      Exit;
   end;
 }

   xSQL := 'Insert into CNT311(CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
         + '                   CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
         + '                   CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
         + '                   CNTFEMIS, CNTFVCMTO, CNTFCOMP, CNTESTADO, CNTCUADRE, CNTFAUTOM, '
         + '                   CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
         + '                   CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
         + '                   TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
         + '                   CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
         + '                   CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
         + '                   CNTMODDOC, CNTREG, MODULO, CTA_SECU ) '
         + '                   Select CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
         + '                   CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
         + '                   CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
         + '                   CNTFEMIS, CNTFVCMTO, CNTFCOMP, ''P'', ''S'', CNTFAUTOM, '
         + '                   CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
         + '                   CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
         + '                   TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
         + '                   CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
         + '                   CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
         + '                   CNTMODDOC, CNTREG, MODULO, CTA_SECU '
         + '  From CNT301 '
         + ' Where CIAID=' + quotedstr(xxxCia)
         + '   and TDIARID=' + quotedstr(xxxDiario)
         + '   and CNTANOMM=' + quotedstr(xxxAnoMM)
         + '   and CNTCOMPROB=' + quotedstr(xxxNoComp)
         + '   and ';
   If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
      xSql := xSQL + 'Coalesce( CNTFAUTOM,''N'' )<>' + quotedstr('S')
   Else
      xSQL := xSQL + 'NVL( CNTFAUTOM,''N'' )<>' + quotedstr('S');
   Try
      cdsQry_C.Close;
      cdsQry_C.DataRequest(xSQL);
      cdsQry_C.Execute;
   Except
      Errorcount2 := 1;
      Exit;
   End;

   xSQL := 'Update CNT311 '
         +'    set CNTCUADRE=NULL, CNTESTADO=''I'' '
         +'  Where CIAID=' + quotedstr(xxxCia)
         +'    and TDIARID=' + quotedstr(xxxDiario)
         +'    and CNTANOMM=' + quotedstr(xxxAnoMM)
         +'    and CNTCOMPROB=' + quotedstr(xxxNoComp);
   Try
      cdsQry_C.Close;
      cdsQry_C.DataRequest(xSQL);
      cdsQry_C.Execute;
   Except
      Errorcount2 := 1;
      Exit;
   End;

// Descontabiliza del CNT401
   FoaConta.GeneraEnLinea401(xxxCia, xxxDiario, xxxAnoMM, xxxNoComp, 'N');

   xSql := 'Delete from CNT301 '
         + ' Where CIAID=' + quotedstr(xxxCia)
         + '   and TDIARID=' + quotedstr(xxxDiario)
         + '   and CNTANOMM=' + quotedstr(xxxAnoMM)
         + '   and CNTCOMPROB=' + quotedstr(xxxNoComp);
   Try
      cdsQry_C.Close;
      cdsQry_C.DataRequest(xSQL);
      cdsQry_C.Execute;
   Except
      Errorcount2 := 1;
      Exit;
   End;

   pnlConta_C.Free;
   Result := True;
End;

Function SOLContaG(xCia, xTDiario, xAnoMM, xNoComp, xSRV, xTipoC, xModulo: String;
   cdsMovCNT, cdsNivelx, cdsResultSetx: TwwClientDataSet;
   DCOMx: TSocketConnection;
   xForm_C: TForm): Boolean;
Var
   sSQL, xNREG, xSQL, xCajaAut, xWhere: String;
   xNumT, iOrdenx: Integer;
   sCIA, sCuenta, sDeHa: String;
   dDebeMN, dHabeMN, dDebeME, dHabeME: double;
   xTotDebeMN, xTotHaberMN, xTotDebeME, xTotHaberME, xDif: Double;
   cdsClone: TwwClientDataSet;
   xxModulo, sBancoTT, sCtaCteTT: String;
Begin
   If (xTipoC = 'P') Or (xTipoC = 'C') Or (xTipoC = 'BP') Or (xTipoC = 'CCNA') Or (xTipoC = 'PCNA') Or
      (xTipoC = 'PPG') Or (xTipoC = 'CPG') Then
   Begin
      CNTDet := 'CNT311';
      If xTipoC = 'P' Then
         CNTCab := 'CNT310'
      Else
         CNTCab := 'CNT300';
   End
   Else
   Begin
   // Para Mayorización
      CNTCab := 'CNT300';
      CNTDet := 'CNT301';
   End;

   FoaConta.CreaPanel(xForm_C, 'Contabilizando');

   DCOM_C := DCOMx;
   SRV_C := xSRV;
   xTipoC_C := xTipoC;

   If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
   Begin
      wReplaCeros := 'COALESCE';
   End
   Else
      If SRV_C = 'ORACLE' Then
      Begin
         wReplaCeros := 'NVL';
      End;

   Provider_C := 'dspTem6';

   cdsNivel_C := cdsNivelx;
   cdsResultSet_C := cdsResultSetx;

   cdsQry_C := TwwClientDataSet.Create(Nil);
   cdsQry_C.RemoteServer := DCOMx;
   cdsQry_C.ProviderName := Provider_C;

   cdsQry_D := TwwClientDataSet.Create(Nil);
   cdsQry_D.RemoteServer := DCOMx;
   cdsQry_D.ProviderName := Provider_C;

// Se Añade Para Mayorizar Solamente
   If (xTipoC = 'M') Then
   Begin
      FoaConta.GeneraEnLinea401(xCia, xTDiario, xAnoMM, xNoComp, 'S');
      pnlConta_C.Free;
      FoaConta.CerrarTablas;
      If Errorcount2 > 0 Then Exit;
      Result := True;
      Exit;
   End;

// Se Añade Para Mayorizar Solamente
   If (xTipoC = 'MC') Then
   Begin
      If xNoComp = '' Then
      Begin
         FoaConta.CerrarTablas;
         Result := False;
         Exit;
      End;
      FoaConta.GeneraEnLinea401(xCia, xTDiario, xAnoMM, xNoComp, 'S');
      pnlConta_C.Free;
      FoaConta.CerrarTablas;
      If Errorcount2 > 0 Then Exit;
      Result := True;
      Exit;
   End;

// Se Añade Para Mayorizar Solamente Cuentas con Auxiliar y CCosto
   If (xTipoC = 'MCACC') Then
   Begin
      FoaConta.GeneraEnLinea401(xCia, xTDiario, xAnoMM, xNoComp, 'S');
      pnlConta_C.Free;
      FoaConta.CerrarTablas;
      If Errorcount2 > 0 Then Exit;
      Result := True;
      Exit;
   End;

   xRegAdicional := '';

   xSQL := 'Select TMONID from TGE103 where TMON_LOC=' + '''' + 'L' + '''';
   cdsQry_C.Close;
   cdsQry_C.DataRequest(xSQL);
   cdsQry_C.Open;
   wTMonLoc_C := cdsQry_C.FieldByname('TMONID').AsString;

   xSQL := 'Select TMONID from TGE103 where TMON_LOC=' + '''' + 'E' + '''';
   cdsQry_C.Close;
   cdsQry_C.DataRequest(xSQL);
   cdsQry_C.Open;
   wTMonExt_C := cdsQry_C.FieldByname('TMONID').AsString;

   cdsMovCNT.IndexFieldNames := 'CNTREG';
   cdsMovCNT.Last;
   iOrdenx := cdsMovCNT.FieldByName('CNTREG').AsInteger + 1;
   cdsMovCNT.IndexFieldNames := '';

//  xTipoC='PCNA'  Si Previo con Caja que NO es Autonoma
//  xTipoC='CCNA'  Si Contabiliza con Caja que NO es Autonoma
   If (xTipoC = 'PCNA') Or (xTipoC = 'CCNA') Then
   Begin
      xSQL := 'Select CJAAUTONOM from TGE101 where CIAID=''' + xCia + '''';
      cdsQry_C.Close;
      cdsQry_C.DataRequest(xSQL);
      cdsQry_C.Open;
      xCajaAut := cdsQry_C.FieldByName('CJAAUTONOM').AsString;
      cdsQry_C.Close;

      If xCajaAut = 'N' Then
      Begin
         xSQL := 'Select CTADEBE, B.CTA_AUX AUX_D, B.CTA_CCOS CCOS_D, '
               + '       CTAHABER, C.CTA_AUX AUX_H, C.CTA_CCOS CCOS_H, '
               + '       TDIARID, CIAORIGEN, TDIARID2 '
               + '  From CAJA103 A, TGE202 B, TGE202 C '
               + ' Where A.CIAID=''' + xCia + ''' '
               + '   AND B.CIAID=A.CIAID AND A.CTADEBE=B.CUENTAID '
               + '   AND C.CIAID=A.CIAID AND A.CTAHABER=C.CUENTAID ';
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Open;

         If cdsQry_C.RecordCount = 0 Then
         Begin
            Errorcount2 := 1;
            FoaConta.CerrarTablas;
            ShowMessage('Error : Caja de Compañía ' + xCia + ' No es Autonoma. Faltan Cuentas Reflejas');
            Exit;
         End;

         xCiaOri   := cdsQry_C.FieldByName('CIAORIGEN').AsString;
         xOrigen   := cdsQry_C.FieldByName('TDIARID').AsString;
         xCtaDebe  := cdsQry_C.FieldByName('CTADEBE').AsString;
         xAux_D    := cdsQry_C.FieldByName('AUX_D').AsString;
         xCCos_D   := cdsQry_C.FieldByName('CCOS_D').AsString;
         xCtaHaber := cdsQry_C.FieldByName('CTAHABER').AsString;
         xAux_H    := cdsQry_C.FieldByName('AUX_H').AsString;
         xCCos_H   := cdsQry_C.FieldByName('CCOS_H').AsString;
         xOrigen2  := cdsQry_C.FieldByName('TDIARID2').AsString;

         cdsQry_C.Close;
         xSQL := ' SELECT CUENTAID,CPTODES FROM CAJA201 WHERE CPTOIS=''R''';
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Open;
         xCtaRetDebe := cdsQry_C.FieldByName('CUENTAID').AsString;
         xGlosaRetDebe := cdsQry_C.FieldByName('CPTODES').AsString;

         cdsQry_C.Close;
         xSQL := ' SELECT CUENTAID,CPTODES FROM CAJA201 WHERE CPTOIS=''T''';
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Open;
         xCtaRetHaber := cdsQry_C.FieldByName('CUENTAID').AsString;
         xGlosaRetHaber := cdsQry_C.FieldByName('CPTODES').AsString;

         cdsQry_C.Close;

         If (xCtaDebe = '') Or (xCtaHaber = '') Then
         Begin
            Errorcount2 := 1;
            FoaConta.CerrarTablas;
            ShowMessage('Error : Caja de Compañía ' + xCia + ' No es Autonoma. Faltan Cuentas Reflejas');
            Exit;
         End;

         FoaConta.GeneraAsientosComplementarios(xCia, xTDiario, xAnoMM, xNoComp, xTipoC, cdsMovCNT);

         xSQL := 'SELECT * FROM CNT311 '
               + ' WHERE CIAID=' + quotedstr(xCia)
               + '   AND TDIARID=' + quotedstr(xTDiario)
               + '   AND CNTANOMM=' + quotedstr(xAnoMM)
               + '   AND CNTCOMPROB=' + quotedstr(xNoComp)
               + ' ORDER BY CNTREG';
         cdsMovCNT.Close;
         cdsMovCNT.DataRequest(xSQL);
         cdsMovCNT.Open;

      End;
   End;

//  xTipoC='PPG'  Si Previo Pago global
//  xTipoC='CPG'  Si Contabiliza Pago Global
   If (xTipoC = 'PPG') Or (xTipoC = 'CPG') Then
   Begin
      wCtaBanco_C := '';
      wNoChq_C := '';
      sBancoTT := '';
      sCtaCteTT := '';

      cdsCNT := TwwClientDataSet.Create(Nil);
      cdsCNT.RemoteServer := DCOMx;
      cdsCNT.ProviderName := Provider_C;
      xSQL := 'select * '
            + '  from CNT311 '
            + ' where CIAID=' + quotedstr(xCia)
            + '   and TDIARID=' + quotedstr(xTDiario)
            + '   and CNTANOMM=' + quotedstr(xAnoMM)
            + '   and CNTCOMPROB=' + quotedstr(xNoComp)
            + ' order BY CNTREG';
      cdsCNT.Close;
      cdsCNT.DataRequest(xSQL);
      cdsCNT.Open;

      xNoCompP := xNoComp;

      cdsQry_G := TwwClientDataSet.Create(Nil);
      cdsQry_G.RemoteServer := DCOMx;
      cdsQry_G.ProviderName := Provider_C;

      xSQL := 'select * '
            + '  from CAJA303 '
            + ' where CIAID=' + quotedstr(xCia)
            + '   and TDIARID=' + quotedstr(xTDiario)
            + '   and ECANOMM=' + quotedstr(xAnoMM)
            + '   and ECNOCOMP=' + quotedstr(xNoComp)
            + '   and CIAID2<>''02'' '
            + ' order by CIAID2';
      cdsQry_G.Close;
      cdsQry_G.DataRequest(xSQL);
      cdsQry_G.Open;

      xSQLAdicional := ' ( A.CIAID=' + quotedstr(xCia)
                   + ' and A.CNTANOMM=' + quotedstr(xAnoMM)
                   + ' and A.TDIARID=' + quotedstr(xTDiario)
                   + ' and A.CNTCOMPROB=' + quotedstr(xNoComp) + ' ) ';

      xNoComp1 := '';
      xNoComp2 := '';
      While Not cdsQry_G.Eof Do
      Begin
         xCia := cdsQry_G.FieldByname('CIAID2').AsString;
         xNoComp := cdsQry_G.FieldByname('ECNOCOMP').AsString;
         xSQL := 'Select CTADEBE, B.CTA_AUX AUX_D, B.CTA_CCOS CCOS_D, '
               + '       CTAHABER, C.CTA_AUX AUX_H, C.CTA_CCOS CCOS_H, '
               + '       TDIARID, CIAORIGEN, TDIARID2 '
               + '  From CAJA103 A, TGE202 B, TGE202 C '
               + ' Where A.CIAID=''' + xCia + ''' '
               + '   and B.CIAID=A.CIAID AND A.CTADEBE=B.CUENTAID '
               + '   and C.CIAID=A.CIAID AND A.CTAHABER=C.CUENTAID ';
         cdsQry_C.Close;
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Open;

         If cdsQry_C.RecordCount = 0 Then
         Begin
            Errorcount2 := 1;
            FoaConta.CerrarTablas;
            ShowMessage('Error : Caja de Compañía ' + xCia + ' No es Autonoma. Faltan Cuentas Reflejas');
            Exit;
         End;

         xCiaOri   := cdsQry_C.FieldByName('CIAORIGEN').AsString;
         xOrigen   := cdsQry_C.FieldByName('TDIARID').AsString;
         xCtaDebe  := cdsQry_C.FieldByName('CTADEBE').AsString;
         xAux_D    := cdsQry_C.FieldByName('AUX_D').AsString;
         xCCos_D   := cdsQry_C.FieldByName('CCOS_D').AsString;
         xCtaHaber := cdsQry_C.FieldByName('CTAHABER').AsString;
         xAux_H    := cdsQry_C.FieldByName('AUX_H').AsString;
         xCCos_H   := cdsQry_C.FieldByName('CCOS_H').AsString;

         xOrigen2  := cdsQry_C.FieldByName('TDIARID2').AsString;
         If xTDiario = '62' Then // Para Detracción
            xOrigen2 := xTDiario;

         cdsQry_C.Close;
         xSQL := ' SELECT CUENTAID,CPTODES FROM CAJA201 WHERE CPTOIS=''R''';
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Open;
         xCtaRetDebe := cdsQry_C.FieldByName('CUENTAID').AsString;
         xGlosaRetDebe := cdsQry_C.FieldByName('CPTODES').AsString;
         cdsQry_C.Close;
         xSQL := ' SELECT CUENTAID,CPTODES FROM CAJA201 WHERE CPTOIS=''T''';
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Open;
         xCtaRetHaber := cdsQry_C.FieldByName('CUENTAID').AsString;
         xGlosaRetHaber := cdsQry_C.FieldByName('CPTODES').AsString;
         cdsQry_C.Close;

         If (xCtaDebe = '') Or (xCtaHaber = '') Then
         Begin
            Errorcount2 := 1;
            FoaConta.CerrarTablas;
            ShowMessage('Error : Caja de Compañía ' + xCia + ' No es Autonoma. Faltan Cuentas Reflejas');
            Exit;
         End;

         xCia := cdsQry_G.FieldByname('CIAID2').AsString;
      // Números de Comprobantes Nuevos
      // Verifica si ya tiene comprobantes
         xWhere := 'Select ECPERREC, CUENTAID, ECNOCHQ, PROV, BANCOID, CCBCOID '
                  +'  from CAJA302 '
                  +' where CIAID=' + '''' + xCiaOri + ''''
                  +'   and TDIARID=' + '''' + xTDiario + ''''
                  +'   and ECANOMM=' + '''' + xAnoMM + ''''
                  +'   and ECNOCOMP=' + '''' + xNoComp + '''';
         cdsQry_C.Close;
         cdsQry_C.DataRequest(xWhere);
         cdsQry_C.Open;
         xCiaOri := xCia;

         If wCtaBanco_C = '' Then wCtaBanco_C := cdsQry_C.FieldByname('CUENTAID').AsString;
         If wNoChq_C    = '' Then wNoChq_C := cdsQry_C.FieldByname('ECNOCHQ').AsString;
         If sBancoTT    = '' Then sBancoTT := cdsQry_C.FieldByname('BANCOID').AsString;
         If sCtaCteTT   = '' Then sCtaCteTT := cdsQry_C.FieldByname('CCBCOID').AsString;

         xWhere := 'Select ECPERREC, CUENTAID, ECNOCHQ, ECNOCOMP, PROV, BANCOID, CCBCOID '
                  +'  from CAJA302 '
                  +' where CIAID=''' + xCia + ''' and TDIARID=''' + xTDiario + ''''
                  +'   and ECANOMM=''' + xAnoMM + ''' and ECNOCHQ=''' + wNoChq_C + ''''
                  +'   and PROV=''' + cdsQry_C.FieldByname('PROV').AsString + ''''
                  +'   and CIAID<>''02''';
         cdsQry_C.Close;
         cdsQry_C.DataRequest(xWhere);
         cdsQry_C.Open;

         xWhere := 'Select CPTODIFG, CPTODIFP, CTADIFG, CTADIFP, CCOSDIF '
                  +'  from TGE106 '
                  +' where CIAID='+quotedstr('02')
                  +'   and BANCOID='+quotedstr(sBancoTT)
                  +'   and CCBCOID='+quotedstr(sCtaCteTT);
         cdsQry_D.Close;
         cdsQry_D.DataRequest(xWhere);
         cdsQry_D.Open;

         wCptoGan := cdsQry_D.fieldbyname('CPTODIFG').AsString;
         wCptoPer := cdsQry_D.fieldbyname('CPTODIFP').AsString;
         wCtaGan := cdsQry_D.fieldbyname('CTADIFG').AsString;
         wCtaPer := cdsQry_D.fieldbyname('CTADIFP').AsString;
         wCCosDif := cdsQry_D.fieldbyname('CCOSDIF').AsString;

         If cdsQry_C.FieldByname('ECNOCHQ').AsString = wNoChq_C Then
         Begin
            xNoComp1 := cdsQry_C.FieldByname('ECNOCOMP').AsString;
            xWhere := 'delete from CAJA302 '
                    + ' where CIAID='+quotedstr(xCia)
                    + '   and TDIARID='+quotedstr(xTDiario)
                    + '   and ECANOMM='+quotedstr(xAnoMM)
                    + '   and ECNOCHQ='+quotedstr(wNoChq_C)
                    + '   and PROV='+quotedstr(cdsQry_C.FieldByname('PROV').AsString)
                    + '   and CIAID<>'+quotedstr('02');
            cdsQry_C.Close;
            cdsQry_C.DataRequest(xWhere);
            cdsQry_C.execute;
            xWhere := 'delete from CNT301 '
                    + ' WHERE CIAID=''' + xCia + ''' and TDIARID=''' + xTDiario + ''''
                    + '   and CNTANOMM=''' + xAnoMM + ''' and CNTCOMPROB=''' + xNoComp1 + '''';
            cdsQry_C.Close;
            cdsQry_C.DataRequest(xWhere);
            cdsQry_C.execute;
            xWhere := 'delete FROM CNT300 '
                    + ' WHERE CIAID=''' + xCia + ''' and TDIARID=''' + xTDiario + ''''
                    + '   and CNTANOMM=''' + xAnoMM + ''' and CNTCOMPROB=''' + xNoComp1 + '''';
            cdsQry_C.Close;
            cdsQry_C.DataRequest(xWhere);
            cdsQry_C.execute;
            xWhere := 'delete FROM CNT301 '
                    + ' WHERE CIAID=''' + xCia + ''' and TDIARID=''91'''
                    + '   and CNTANOMM=''' + xAnoMM + ''' and CNTCOMPROB=''' + xNoComp + '''';
            cdsQry_C.Close;
            cdsQry_C.DataRequest(xWhere);
            cdsQry_C.execute;
            xWhere := 'delete FROM CNT300 '
                    + ' WHERE CIAID=''' + xCia + ''' and TDIARID=''91'''
                    + '   and CNTANOMM=''' + xAnoMM + ''' and CNTCOMPROB=''' + xNoComp + '''';
            cdsQry_C.Close;
            cdsQry_C.DataRequest(xWhere);
            cdsQry_C.execute;
         End
         Else
         Begin
            xWhere := 'SELECT NVL( MAX( ECNOCOMP ), ''0'' ) AS NUMERO '
                    + '  FROM CAJA302 '
                    + ' WHERE CIAID=' + '''' + xCiaOri + ''''
                    + '   and TDIARID=' + '''' + xOrigen2 + ''''
                    + '   and ECANOMM=' + '''' + xAnoMM + '''';
            cdsQry_C.Close;
            cdsQry_C.DataRequest(xWhere);
            cdsQry_C.Open;

            xNoComp1 := Inttostr(StrToInt(cdsQry_C.FieldByname('NUMERO').AsString) + 1);
            xNoComp1 := FoaConta.StrZero(xNoComp1, 10);
         End;

         // Números de Comprobantes Nuevos
         If xNoComp2 = '' Then xNoComp2 := xNoComp;

         // Detalle Asiento 1
         wMtoOri_C := 0;
         wMtoLoc_C := 0;
         wMtoExt_C := 0;
         iOrden := 0;
         While (xCia = cdsQry_G.FieldByname('CIAID2').AsString) And (Not cdsQry_G.Eof) Do
         Begin
            wDoc_C := cdsQry_G.FieldByname('DOCID2').AsString;
            wSerie_C := cdsQry_G.FieldByname('CPSERIE').AsString;
            wNodoc_C := cdsQry_G.FieldByname('CPNODOC').AsString;
            FoaConta.GeneraAsientoGlobal_N1(xCiaOri, xOrigen2, xAnoMM, xNoComp1, xTipoC, cdsMovCNT);
            FoaConta.GeneraAsientoGlobal_N4(xCia, xOrigen, xAnoMM, xNoComp2, xTipoC, cdsMovCNT);
            cdsQry_G.Next;
         End;

         // Total Asiento 1
         FoaConta.GeneraAsientoGlobal_N2(xCiaOri, xOrigen2, xAnoMM, xNoComp1, xTipoC, cdsMovCNT);
         FoaConta.GeneraEnLinea401(xCiaOri, xOrigen2, xAnoMM, xNoComp1, 'S');
         iOrdenx := iOrden;

         // Detalle Asiento 2
         iOrden := 0;
         FoaConta.GeneraAsientoGlobal_N3(xCia, xOrigen, xAnoMM, xNoComp2, xTipoC, cdsMovCNT);
// Inicio HPC_201701_CAJA
          //Código eliminado porque no se utiliza
         //FoaConta.GeneraAsientoGlobal_NDif(xCia, xOrigen, xAnoMM, xNoComp2, xTipoC, cdsMovCNT);
// Fin HPC_201701_CAJA
         FoaConta.GeneraEnLinea401(xCia, xOrigen, xAnoMM, xNoComp2, 'S');

         FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');

         xRegAdicional := '1. ' + xCiaOri + '/' + xOrigen2 + '/' + xNoComp1 + ']['
            + '2. ' + xCia + '/' + xOrigen + '/' + xNoComp2;

         //////////////////////////////////////////////////
         // GENERA ASIENTOS AUTOMATICOS PARA LA CUENTA 1
         //////////////////////////////////////////////////

         xCia := xCiaOri;
         xTDiario := xOrigen2;
         xNoComp := xNoComp1;

         cdsClone := TwwClientDataSet.Create(Nil);
         cdsClone.RemoteServer := DCOMx;
         cdsClone.ProviderName := Provider_C;
         cdsClone.Close;

         sSQL := 'Select A.CIAID, TDIARID, CNTCOMPROB, MAX(CNTANO) CNTANO, CNTANOMM, A.CUENTAID, '
               + '       CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CCOSID, '
               + '       MAX(CNTGLOSA) CNTGLOSA, CNTDH, MAX(CNTTCAMBIO) CNTTCAMBIO, MAX(CNTLOTE) CNTLOTE, '
               + '       SUM(CNTMTOORI) CNTMTOORI, SUM(CNTMTOLOC) CNTMTOLOC, SUM(CNTMTOEXT) CNTMTOEXT, '
               + '       MAX(CNTFCOMP) CNTFCOMP, MAX(CNTFEMIS) CNTFEMIS, MAX(CNTFVCMTO) CNTFVCMTO, '
               + '       MAX(CNTUSER) CNTUSER, MAX(CNTFREG) CNTFREG, MAX(CNTHREG) CNTHREG, MAX(CNTMM) CNTMM, '
               + '       MAX(CNTDD) CNTDD, MAX(CNTTRI) CNTTRI, MAX(CNTSEM) CNTSEM, MAX(CNTSS) CNTSS, '
               + '       MAX(CNTAATRI) CNTAATRI, MAX(CNTAASEM) CNTAASEM, MAX(CNTAASS) CNTAASS, MAX(TMONID) TMONID, '
               + '       MAX(TDIARDES) TDIARDES, MAX(A.CTADES) CTADES, MAX(AUXDES) AUXDES, MAX(DOCDES) DOCDES, '
               + '       SUM(CNTDEBEMN) CNTDEBEMN, SUM(CNTDEBEME) CNTDEBEME, SUM(CNTHABEMN) CNTHABEMN, '
               + '       SUM(CNTHABEME) CNTHABEME, MAX(CNTTS) CNTTS, MAX(CNTMODDOC) CNTMODDOC, MAX(CCOSDES) CCOSDES, '
               + '       MAX(CTA_AUX) CTA_AUX, MAX(CTA_CCOS) CTA_CCOS, MAX(CTAAUT1) CTAAUT1, MAX(CTAAUT2) CTAAUT2, '
               + '       MAX(CTA_AUT1) CTA_AUT1, MAX(CTA_AUT2) CTA_AUT2, MAX(MODULO) MODULO '
               + '  from CNT311 A, TGE202 B '
               + ' WHERE A.CIAID=' + QuotedStr(xCia)
               + '   and TDIARID=' + QuotedStr(xTDiario)
               + '   and CNTANOMM=' + QuotedStr(xAnoMM)
               + '   and CNTCOMPROB=' + QuotedStr(xnoComp)
               + '   and A.CIAID=B.CIAID AND A.CUENTAID=B.CUENTAID '
               + ' Group by A.CIAID, TDIARID, CNTANOMM, CNTCOMPROB, A.CUENTAID, CNTDH, CLAUXID, '
               + '          AUXID, CCOSID, DOCID, CNTSERIE, CNTNODOC';
         cdsClone.DataRequest(sSQL);
         cdsClone.Open;

         FoaConta.PanelMsg('Generando Asientos Automaticos', 0);

         iOrden := iOrdenx + 2;

         cdsMovCNT.DisableControls;
         cdsClone.First;
         While Not cdsClone.EOF Do
         Begin
            sCia := cdsClone.FieldByName('CIAID').AsString;
            sCuenta := cdsClone.FieldByName('CUENTAID').AsString;

           //SI TIENE CUENTA AUTOMATICA 1 y 2
            If (cdsClone.FieldByName('CTA_AUT1').AsString = 'S') And
               (cdsClone.FieldByName('CTA_AUT2').AsString = 'S') Then
            Begin

               xSQL := 'Select CTA_AUX, CTA_CCOS from TGE202 '
                  + 'Where CIAID=' + quotedstr(xCia)
                  + ' and CUENTAID=' + quotedstr(cdsClone.FieldByName('CTAAUT1').AsString);
               cdsQry_C.Close;
               cdsQry_C.DataRequest(xSQL);
               cdsQry_C.Open;

             //SI LA CUENTA ORIGES ESTA DESTINADA AL DEBE LA CUENTA AUTOMATICA 1 IRA AL HABER
               If cdsClone.FieldByName('CNTDH').AsString = 'D' Then
               Begin
                  sDeHa := 'D';
                  dHabeMN := 0;
                  dHabeME := 0;
                  dDebeMN := cdsClone.FieldByName('CNTMTOLOC').AsFloat;
                  dDebeME := cdsClone.FieldByName('CNTMTOEXT').AsFloat;
               End
               Else
               Begin
                  sDeHa := 'H';
                  dDebeMN := 0;
                  dDebeME := 0;
                  dHabeMN := cdsClone.FieldByName('CNTMTOLOC').AsFloat;
                  dHabeME := cdsClone.FieldByName('CNTMTOEXT').AsFloat;
               End;

               cdsMovCNT.Insert;
               cdsMovCNT.FieldByName('CIAID').AsString := cdsClone.FieldByName('CIAID').AsString;
               cdsMovCNT.FieldByName('TDIARID').AsString := cdsClone.FieldByName('TDIARID').AsString;
               cdsMovCNT.FieldByName('CNTCOMPROB').AsString := cdsClone.FieldByName('CNTCOMPROB').AsString;
               cdsMovCNT.FieldByName('CNTANOMM').AsString := cdsClone.FieldByName('CNTANOMM').AsString;
               cdsMovCNT.FieldByName('CUENTAID').AsString := cdsClone.FieldByName('CTAAUT1').AsString;
               cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsClone.FieldByName('CNTLOTE').AsString;

               If cdsQry_C.FieldByName('CTA_AUX').AsString = 'S' Then
               Begin
                  cdsMovCNT.FieldByName('CLAUXID').AsString := cdsClone.FieldByName('CLAUXID').AsString;
                  cdsMovCNT.FieldByName('AUXID').AsString := cdsClone.FieldByName('AUXID').AsString;
                  cdsMovCNT.FieldByName('AUXDES').AsString := cdsClone.FieldByName('AUXDES').AsString;
               End
               Else
               Begin
                  cdsMovCNT.FieldByName('CLAUXID').AsString := '';
                  cdsMovCNT.FieldByName('AUXID').AsString := '';
                  cdsMovCNT.FieldByName('AUXDES').AsString := '';
               End;

               If cdsQry_C.FieldByName('CTA_CCOS').AsString = 'S' Then
               Begin
                  cdsMovCNT.FieldByName('CCOSID').AsString := cdsClone.FieldByName('CCOSID').AsString;
                  cdsMovCNT.FieldByName('CCOSDES').AsString := cdsClone.FieldByName('CCOSDES').AsString;
               End
               Else
               Begin
                  cdsMovCNT.FieldByName('CCOSID').AsString := '';
                  cdsMovCNT.FieldByName('CCOSDES').AsString := '';
               End;

               cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsClone.FieldByName('CNTMODDOC').AsString;
               cdsMovCNT.FieldByName('DOCID').AsString := cdsClone.FieldByName('DOCID').AsString;
               cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsClone.FieldByName('CNTSERIE').AsString;
               cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsClone.FieldByName('CNTNODOC').AsString;
               cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsClone.FieldByName('CNTGLOSA').AsString;
               cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
               cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsClone.FieldByName('CNTTCAMBIO').AsString;
               cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsClone.FieldByName('CNTMTOORI').AsString;
               cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsClone.FieldByName('CNTMTOLOC').AsString;
               cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsClone.FieldByName('CNTMTOEXT').AsString;
               cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsClone.FieldByName('CNTFEMIS').AsDateTime;
               cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsClone.FieldByName('CNTFVCMTO').AsDateTime;
               cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsClone.FieldByName('CNTFCOMP').AsDateTime;
               cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
               cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
            // Inicio : HPC_201301_CNT
               cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
            // Fin : HPC_201301_CNT
               cdsMovCNT.FieldByName('CNTUSER').AsString := cdsClone.FieldByName('CNTUSER').AsString;
               cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsClone.FieldByName('CNTFREG').AsDateTime;
               cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsClone.FieldByName('CNTHREG').AsDateTime;
               cdsMovCNT.FieldByName('CNTANO').AsString := cdsClone.FieldByName('CNTANO').AsString;
               cdsMovCNT.FieldByName('CNTMM').AsString := cdsClone.FieldByName('CNTMM').AsString;
               cdsMovCNT.FieldByName('CNTDD').AsString := cdsClone.FieldByName('CNTDD').AsString;
               cdsMovCNT.FieldByName('CNTTRI').AsString := cdsClone.FieldByName('CNTTRI').AsString;
               cdsMovCNT.FieldByName('CNTSEM').AsString := cdsClone.FieldByName('CNTSEM').AsString;
               cdsMovCNT.FieldByName('CNTSS').AsString := cdsClone.FieldByName('CNTSS').AsString;
               cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsClone.FieldByName('CNTAATRI').AsString;
               cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsClone.FieldByName('CNTAASEM').AsString;
               cdsMovCNT.FieldByName('CNTAASS').AsString := cdsClone.FieldByName('CNTAASS').AsString;
               cdsMovCNT.FieldByName('TMONID').AsString := cdsClone.FieldByName('TMONID').AsString;
               cdsMovCNT.FieldByName('TDIARDES').AsString := cdsClone.FieldByName('TDIARDES').AsString;
               cdsMovCNT.FieldByName('DOCDES').AsString := cdsClone.FieldByName('DOCDES').AsString;
               cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
               cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
               cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
               cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
               cdsMovCNT.FieldByName('MODULO').AsString := cdsClone.FieldByName('MODULO').AsString;
               iOrden := iOrden + 1;
               cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
               FoaConta.cdsPost(cdsMovCNT);

             //SI LA CUENTA ORIGES ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
               If cdsClone.FieldByName('CNTDH').AsString = 'D' Then
               Begin
                  sDeHa := 'H';
                  dDebeMN := 0;
                  dDebeME := 0;
                  dHabeMN := cdsClone.FieldByName('CNTMTOLOC').AsFloat;
                  dHabeME := cdsClone.FieldByName('CNTMTOEXT').AsFloat;
               End
               Else
               Begin
                  sDeHa := 'D';
                  dDebeMN := cdsClone.FieldByName('CNTMTOLOC').AsFloat;
                  dDebeME := cdsClone.FieldByName('CNTMTOEXT').AsFloat;
                  dHabeMN := 0;
                  dHabeME := 0;
               End;

               xSQL := 'Select CTA_AUX, CTA_CCOS from TGE202 '
                  + 'Where CIAID=' + quotedstr(xCia)
                  + ' and CUENTAID=' + quotedstr(cdsClone.FieldByName('CTAAUT2').AsString);
               cdsQry_C.Close;
               cdsQry_C.DataRequest(xSQL);
               cdsQry_C.Open;

               cdsMovCNT.Insert;
               cdsMovCNT.FieldByName('CIAID').AsString := cdsClone.FieldByName('CIAID').AsString;
               cdsMovCNT.FieldByName('TDIARID').AsString := cdsClone.FieldByName('TDIARID').AsString;
               cdsMovCNT.FieldByName('CNTCOMPROB').AsString := cdsClone.FieldByName('CNTCOMPROB').AsString;
               cdsMovCNT.FieldByName('CNTANOMM').AsString := cdsClone.FieldByName('CNTANOMM').AsString;
               cdsMovCNT.FieldByName('CUENTAID').AsString := cdsClone.FieldByName('CTAAUT2').AsString;
               cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsClone.FieldByName('CNTLOTE').AsString;

               If cdsQry_C.FieldByName('CTA_AUX').AsString = 'S' Then
               Begin
                  cdsMovCNT.FieldByName('CLAUXID').AsString := cdsClone.FieldByName('CLAUXID').AsString;
                  cdsMovCNT.FieldByName('AUXID').AsString := cdsClone.FieldByName('AUXID').AsString;
                  cdsMovCNT.FieldByName('AUXDES').AsString := cdsClone.FieldByName('AUXDES').AsString;
               End
               Else
               Begin
                  cdsMovCNT.FieldByName('CLAUXID').Clear;
                  cdsMovCNT.FieldByName('AUXID').Clear;
                  cdsMovCNT.FieldByName('AUXDES').Clear;
               End;

               If cdsQry_C.FieldByName('CTA_CCOS').AsString = 'S' Then
               Begin
                  cdsMovCNT.FieldByName('CCOSID').AsString := cdsClone.FieldByName('CCOSID').AsString;
                  cdsMovCNT.FieldByName('CCOSDES').AsString := cdsClone.FieldByName('CCOSDES').AsString;
               End
               Else
               Begin
                  cdsMovCNT.FieldByName('CCOSID').Clear;
                  cdsMovCNT.FieldByName('CCOSDES').Clear;
               End;

               cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsClone.FieldByName('CNTMODDOC').AsString;
               cdsMovCNT.FieldByName('DOCID').AsString := cdsClone.FieldByName('DOCID').AsString;
               cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsClone.FieldByName('CNTSERIE').AsString;
               cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsClone.FieldByName('CNTNODOC').AsString;
               cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsClone.FieldByName('CNTGLOSA').AsString;
               cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
               cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsClone.FieldByName('CNTTCAMBIO').AsString;
               cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsClone.FieldByName('CNTMTOORI').AsString;
               cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsClone.FieldByName('CNTMTOLOC').AsString;
               cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsClone.FieldByName('CNTMTOEXT').AsString;
               cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsClone.FieldByName('CNTFEMIS').AsDateTime;
               cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsClone.FieldByName('CNTFVCMTO').AsDateTime;
               cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsClone.FieldByName('CNTFCOMP').AsDateTime;
               cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
               cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
            // Inicio : HPC_201301_CNT
               cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
            // Fin : HPC_201301_CNT
               cdsMovCNT.FieldByName('CNTUSER').AsString := cdsClone.FieldByName('CNTUSER').AsString;
               cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsClone.FieldByName('CNTFREG').AsDateTime;
               cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsClone.FieldByName('CNTHREG').AsDateTime;
               cdsMovCNT.FieldByName('CNTANO').AsString := cdsClone.FieldByName('CNTANO').AsString;
               cdsMovCNT.FieldByName('CNTMM').AsString := cdsClone.FieldByName('CNTMM').AsString;
               cdsMovCNT.FieldByName('CNTDD').AsString := cdsClone.FieldByName('CNTDD').AsString;
               cdsMovCNT.FieldByName('CNTTRI').AsString := cdsClone.FieldByName('CNTTRI').AsString;
               cdsMovCNT.FieldByName('CNTSEM').AsString := cdsClone.FieldByName('CNTSEM').AsString;
               cdsMovCNT.FieldByName('CNTSS').AsString := cdsClone.FieldByName('CNTSS').AsString;
               cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsClone.FieldByName('CNTAATRI').AsString;
               cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsClone.FieldByName('CNTAASEM').AsString;
               cdsMovCNT.FieldByName('CNTAASS').AsString := cdsClone.FieldByName('CNTAASS').AsString;
               cdsMovCNT.FieldByName('TMONID').AsString := cdsClone.FieldByName('TMONID').AsString;
               cdsMovCNT.FieldByName('TDIARDES').AsString := cdsClone.FieldByName('TDIARDES').AsString;
               cdsMovCNT.FieldByName('DOCDES').AsString := cdsClone.FieldByName('DOCDES').AsString;
               cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
               cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
               cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
               cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
               cdsMovCNT.FieldByName('MODULO').AsString := cdsClone.FieldByName('MODULO').AsString;
               iOrden := iOrden + 1;
               cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
               FoaConta.cdsPost(cdsMovCNT);

               FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');
            End;

            cdsClone.Next;
         End;
         //
         FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');

         //////////////////////////////////////////////////
         // GENERA ASIENTOS AUTOMATICOS PARA ASIENTO PRINCIPAL
         //////////////////////////////////////////////////

         {
         xCia    :='02';
         xTDiario:=xOrigen2;
         xNoComp :=xNoComp2;

         cdsClone:=TwwClientDataSet.Create(nil);
         cdsClone.RemoteServer:= DCOMx;
         cdsClone.ProviderName:=Provider_C;
         cdsClone.Close;

         sSQL:='Select A.CIAID, TDIARID, CNTCOMPROB, MAX(CNTANO) CNTANO, CNTANOMM, A.CUENTAID, '
             +  'CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CCOSID, '
             +  'MAX(CNTGLOSA) CNTGLOSA, CNTDH, MAX(CNTTCAMBIO) CNTTCAMBIO, MAX(CNTLOTE) CNTLOTE, '
             +  'SUM(CNTMTOORI) CNTMTOORI, SUM(CNTMTOLOC) CNTMTOLOC, SUM(CNTMTOEXT) CNTMTOEXT, '
             +  'MAX(CNTFCOMP) CNTFCOMP, MAX(CNTFEMIS) CNTFEMIS, MAX(CNTFVCMTO) CNTFVCMTO, '
             +  'MAX(CNTUSER) CNTUSER, MAX(CNTFREG) CNTFREG, MAX(CNTHREG) CNTHREG, MAX(CNTMM) CNTMM, '
             +  'MAX(CNTDD) CNTDD, MAX(CNTTRI) CNTTRI, MAX(CNTSEM) CNTSEM, MAX(CNTSS) CNTSS, '
             +  'MAX(CNTAATRI) CNTAATRI, MAX(CNTAASEM) CNTAASEM, MAX(CNTAASS) CNTAASS, MAX(TMONID) TMONID, '
             +  'MAX(TDIARDES) TDIARDES, MAX(A.CTADES) CTADES, MAX(AUXDES) AUXDES, MAX(DOCDES) DOCDES, '
             +  'SUM(CNTDEBEMN) CNTDEBEMN, SUM(CNTDEBEME) CNTDEBEME, SUM(CNTHABEMN) CNTHABEMN, SUM(CNTHABEME) CNTHABEME, '
             +  'MAX(CNTTS) CNTTS, MAX(CNTMODDOC) CNTMODDOC, MAX(CCOSDES) CCOSDES, MAX(CTA_AUX) CTA_AUX, MAX(CTA_CCOS) CTA_CCOS, '
             +  'MAX(CTAAUT1) CTAAUT1, MAX(CTAAUT2) CTAAUT2,MAX(CTA_AUT1) CTA_AUT1, MAX(CTA_AUT2) CTA_AUT2, MAX(MODULO) MODULO '
             +'FROM CNT311 A, TGE202 B '
      //       +'FROM CNT301 A, TGE202 B '
             +'WHERE A.CIAID='   +QuotedStr( xCia     )
             + ' and TDIARID='   +QuotedStr( xTDiario )
             + ' and CNTANOMM='  +QuotedStr( xAnoMM   )
             + ' and CNTCOMPROB='+QuotedStr( xnoComp  )
             + ' and A.CIAID=B.CIAID AND A.CUENTAID=B.CUENTAID '
             +'Group by A.CIAID, TDIARID, CNTANOMM, CNTCOMPROB, A.CUENTAID, CNTDH, CLAUXID, '
             +         'AUXID, CCOSID, DOCID, CNTSERIE, CNTNODOC';

         cdsClone.DataRequest(sSQL);
         cdsClone.Open;

         FoaConta.PanelMsg( 'Generando Asientos Automaticos', 0 );

         iOrden:=cdsClone.recordcount+2;

         cdsMovCNT.DisableControls;
         cdsClone.First;
         while not cdsClone.EOF do
         begin
           sCia:=cdsClone.FieldByName('CIAID').AsString;
           sCuenta:=cdsClone.FieldByName('CUENTAID').AsString;

           //SI TIENE CUENTA AUTOMATICA 1 y 2
           if (cdsClone.FieldByName('CTA_AUT1').AsString = 'S') and
              (cdsClone.FieldByName('CTA_AUT2').AsString = 'S') then
           begin

             xSQL:='Select CTA_AUX, CTA_CCOS from TGE202 '
                    +'Where CIAID='   +quotedstr( xCia )
                    + ' and CUENTAID='+quotedstr( cdsClone.FieldByName('CTAAUT1').AsString );
             cdsQry_C.Close;
             cdsQry_C.DataRequest( xSQL );
             cdsQry_C.Open;

             //SI LA CUENTA ORIGES ESTA DESTINADA AL DEBE LA CUENTA AUTOMATICA 1 IRA AL HABER
             if cdsClone.FieldByName('CNTDH').AsString='D' then
             begin
               sDeHa:='D';
               dHabeMN:=0;
               dHabeME:=0;
               dDebeMN:=cdsClone.FieldByName('CNTMTOLOC').AsFloat;
               dDebeME:=cdsClone.FieldByName('CNTMTOEXT').AsFloat;
             end
             else
             begin
               sDeHa:='H';
               dDebeMN:=0;
               dDebeME:=0;
               dHabeMN:=cdsClone.FieldByName('CNTMTOLOC').AsFloat;
               dHabeME:=cdsClone.FieldByName('CNTMTOEXT').AsFloat;
             end;

             cdsMovCNT.Insert;
             cdsMovCNT.FieldByName('CIAID').AsString      :=cdsClone.FieldByName('CIAID').AsString;
             cdsMovCNT.FieldByName('TDIARID').AsString    :=cdsClone.FieldByName('TDIARID').AsString;
             cdsMovCNT.FieldByName('CNTCOMPROB').AsString :=cdsClone.FieldByName('CNTCOMPROB').AsString;
             cdsMovCNT.FieldByName('CNTANOMM').AsString   :=cdsClone.FieldByName('CNTANOMM').AsString;
             cdsMovCNT.FieldByName('CUENTAID').AsString   :=cdsClone.FieldByName('CTAAUT1').AsString;
             cdsMovCNT.FieldByName('CNTLOTE').AsString    :=cdsClone.FieldByName('CNTLOTE').AsString;

             if cdsQry_C.FieldByName('CTA_AUX').AsString='S' then begin
                cdsMovCNT.FieldByName('CLAUXID').AsString    :=cdsClone.FieldByName('CLAUXID').AsString;
                cdsMovCNT.FieldByName('AUXID').AsString      :=cdsClone.FieldByName('AUXID').AsString;
                cdsMovCNT.FieldByName('AUXDES').AsString     :=cdsClone.FieldByName('AUXDES').AsString;
             end
             else begin
                cdsMovCNT.FieldByName('CLAUXID').AsString    :='';
                cdsMovCNT.FieldByName('AUXID').AsString      :='';
                cdsMovCNT.FieldByName('AUXDES').AsString     :='';
             end;

             if cdsQry_C.FieldByName('CTA_CCOS').AsString='S' then begin
                cdsMovCNT.FieldByName('CCOSID').AsString     :=cdsClone.FieldByName('CCOSID').AsString;
                cdsMovCNT.FieldByName('CCOSDES').AsString    :=cdsClone.FieldByName('CCOSDES').AsString;
             end
             else begin
                cdsMovCNT.FieldByName('CCOSID').AsString     :='';
                cdsMovCNT.FieldByName('CCOSDES').AsString    :='';
             end;

             cdsMovCNT.FieldByName('CNTMODDOC').AsString  :=cdsClone.FieldByName('CNTMODDOC').AsString;
             cdsMovCNT.FieldByName('DOCID').AsString      :=cdsClone.FieldByName('DOCID').AsString;
             cdsMovCNT.FieldByName('CNTSERIE').AsString   :=cdsClone.FieldByName('CNTSERIE').AsString;
             cdsMovCNT.FieldByName('CNTNODOC').AsString   :=cdsClone.FieldByName('CNTNODOC').AsString;
             cdsMovCNT.FieldByName('CNTGLOSA').AsString   :=cdsClone.FieldByName('CNTGLOSA').AsString;
             cdsMovCNT.FieldByName('CNTDH').AsString      :=sDeHa;
             cdsMovCNT.FieldByName('CNTTCAMBIO').AsString :=cdsClone.FieldByName('CNTTCAMBIO').AsString;
             cdsMovCNT.FieldByName('CNTMTOORI').AsString  :=cdsClone.FieldByName('CNTMTOORI').AsString;
             cdsMovCNT.FieldByName('CNTMTOLOC').AsString  :=cdsClone.FieldByName('CNTMTOLOC').AsString;
             cdsMovCNT.FieldByName('CNTMTOEXT').AsString  :=cdsClone.FieldByName('CNTMTOEXT').AsString;
             cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime :=cdsClone.FieldByName('CNTFEMIS').AsDateTime;
             cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime:=cdsClone.FieldByName('CNTFVCMTO').AsDateTime;
             cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime :=cdsClone.FieldByName('CNTFCOMP').AsDateTime;
             cdsMovCNT.FieldByName('CNTESTADO').AsString  :='P';
             cdsMovCNT.FieldByName('CNTCUADRE').AsString  :='S';
             cdsMovCNT.FieldByName('CNTFAUTOM').AsString  :='S';
             cdsMovCNT.FieldByName('CNTUSER').AsString    :=cdsClone.FieldByName('CNTUSER').AsString;
             cdsMovCNT.FieldByName('CNTFREG').AsDateTime  :=cdsClone.FieldByName('CNTFREG').AsDateTime;
             cdsMovCNT.FieldByName('CNTHREG').AsDateTime  :=cdsClone.FieldByName('CNTHREG').AsDateTime;
             cdsMovCNT.FieldByName('CNTANO').AsString     :=cdsClone.FieldByName('CNTANO').AsString;
             cdsMovCNT.FieldByName('CNTMM').AsString      :=cdsClone.FieldByName('CNTMM').AsString;
             cdsMovCNT.FieldByName('CNTDD').AsString      :=cdsClone.FieldByName('CNTDD').AsString;
             cdsMovCNT.FieldByName('CNTTRI').AsString     :=cdsClone.FieldByName('CNTTRI').AsString;
             cdsMovCNT.FieldByName('CNTSEM').AsString     :=cdsClone.FieldByName('CNTSEM').AsString;
             cdsMovCNT.FieldByName('CNTSS').AsString      :=cdsClone.FieldByName('CNTSS').AsString;
             cdsMovCNT.FieldByName('CNTAATRI').AsString   :=cdsClone.FieldByName('CNTAATRI').AsString;
             cdsMovCNT.FieldByName('CNTAASEM').AsString   :=cdsClone.FieldByName('CNTAASEM').AsString;
             cdsMovCNT.FieldByName('CNTAASS').AsString    :=cdsClone.FieldByName('CNTAASS').AsString;
             cdsMovCNT.FieldByName('TMONID').AsString     :=cdsClone.FieldByName('TMONID').AsString;
             cdsMovCNT.FieldByName('TDIARDES').AsString   :=cdsClone.FieldByName('TDIARDES').AsString;
             cdsMovCNT.FieldByName('DOCDES').AsString     :=cdsClone.FieldByName('DOCDES').AsString;
             cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat   :=dDebeMN;
             cdsMovCNT.FieldByName('CNTDEBEME').AsFloat   :=dDebeME;
             cdsMovCNT.FieldByName('CNTHABEMN').AsFloat   :=dHabeMN;
             cdsMovCNT.FieldByName('CNTHABEME').AsFloat   :=dHabeME;
             cdsMovCNT.FieldByName('MODULO').AsString     :=cdsClone.FieldByName('MODULO').AsString;
             iOrden:=iOrden+1;
             cdsMovCNT.FieldByName('CNTREG').AsInteger    :=iOrden;
             FoaConta.cdsPost( cdsMovCNT );

             //SI LA CUENTA ORIGES ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
             if cdsClone.FieldByName('CNTDH').AsString='D' then
             begin
               sDeHa:='H';
               dDebeMN:=0;
               dDebeME:=0;
               dHabeMN:=cdsClone.FieldByName('CNTMTOLOC').AsFloat;
               dHabeME:=cdsClone.FieldByName('CNTMTOEXT').AsFloat;
             end
             else
             begin
               sDeHa:='D';
               dDebeMN:=cdsClone.FieldByName('CNTMTOLOC').AsFloat;
               dDebeME:=cdsClone.FieldByName('CNTMTOEXT').AsFloat;
               dHabeMN:=0;
               dHabeME:=0;
             end;

             xSQL:='Select CTA_AUX, CTA_CCOS from TGE202 '
                    +'Where CIAID='   +quotedstr( xCia )
                    + ' and CUENTAID='+quotedstr( cdsClone.FieldByName('CTAAUT2').AsString );
             cdsQry_C.Close;
             cdsQry_C.DataRequest( xSQL );
             cdsQry_C.Open;

             cdsMovCNT.Insert;
             cdsMovCNT.FieldByName('CIAID').AsString      :=cdsClone.FieldByName('CIAID').AsString;
             cdsMovCNT.FieldByName('TDIARID').AsString    :=cdsClone.FieldByName('TDIARID').AsString;
             cdsMovCNT.FieldByName('CNTCOMPROB').AsString :=cdsClone.FieldByName('CNTCOMPROB').AsString;
             cdsMovCNT.FieldByName('CNTANOMM').AsString   :=cdsClone.FieldByName('CNTANOMM').AsString;
             cdsMovCNT.FieldByName('CUENTAID').AsString   :=cdsClone.FieldByName('CTAAUT2').AsString;
             cdsMovCNT.FieldByName('CNTLOTE').AsString    :=cdsClone.FieldByName('CNTLOTE').AsString;

             if cdsQry_C.FieldByName('CTA_AUX').AsString='S' then begin
                cdsMovCNT.FieldByName('CLAUXID').AsString    :=cdsClone.FieldByName('CLAUXID').AsString;
                cdsMovCNT.FieldByName('AUXID').AsString      :=cdsClone.FieldByName('AUXID').AsString;
                cdsMovCNT.FieldByName('AUXDES').AsString     :=cdsClone.FieldByName('AUXDES').AsString;
             end
             else begin
                cdsMovCNT.FieldByName('CLAUXID').Clear;
                cdsMovCNT.FieldByName('AUXID').Clear;
                cdsMovCNT.FieldByName('AUXDES').Clear;
             end;

             if cdsQry_C.FieldByName('CTA_CCOS').AsString='S' then begin
                cdsMovCNT.FieldByName('CCOSID').AsString     :=cdsClone.FieldByName('CCOSID').AsString;
                cdsMovCNT.FieldByName('CCOSDES').AsString    :=cdsClone.FieldByName('CCOSDES').AsString;
             end
             else begin
                cdsMovCNT.FieldByName('CCOSID').Clear;
                cdsMovCNT.FieldByName('CCOSDES').Clear;
             end;

             cdsMovCNT.FieldByName('CNTMODDOC').AsString  :=cdsClone.FieldByName('CNTMODDOC').AsString;
             cdsMovCNT.FieldByName('DOCID').AsString      :=cdsClone.FieldByName('DOCID').AsString;
             cdsMovCNT.FieldByName('CNTSERIE').AsString   :=cdsClone.FieldByName('CNTSERIE').AsString;
             cdsMovCNT.FieldByName('CNTNODOC').AsString   :=cdsClone.FieldByName('CNTNODOC').AsString;
             cdsMovCNT.FieldByName('CNTGLOSA').AsString   :=cdsClone.FieldByName('CNTGLOSA').AsString;
             cdsMovCNT.FieldByName('CNTDH').AsString      :=sDeHa;
             cdsMovCNT.FieldByName('CNTTCAMBIO').AsString :=cdsClone.FieldByName('CNTTCAMBIO').AsString;
             cdsMovCNT.FieldByName('CNTMTOORI').AsString  :=cdsClone.FieldByName('CNTMTOORI').AsString;
             cdsMovCNT.FieldByName('CNTMTOLOC').AsString  :=cdsClone.FieldByName('CNTMTOLOC').AsString;
             cdsMovCNT.FieldByName('CNTMTOEXT').AsString  :=cdsClone.FieldByName('CNTMTOEXT').AsString;
             cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime :=cdsClone.FieldByName('CNTFEMIS').AsDateTime;
             cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime:=cdsClone.FieldByName('CNTFVCMTO').AsDateTime;
             cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime :=cdsClone.FieldByName('CNTFCOMP').AsDateTime;
             cdsMovCNT.FieldByName('CNTESTADO').AsString  :='P';
             cdsMovCNT.FieldByName('CNTCUADRE').AsString  :='S';
             cdsMovCNT.FieldByName('CNTFAUTOM').AsString  :='S';
             cdsMovCNT.FieldByName('CNTUSER').AsString    :=cdsClone.FieldByName('CNTUSER').AsString;
             cdsMovCNT.FieldByName('CNTFREG').AsDateTime  :=cdsClone.FieldByName('CNTFREG').AsDateTime;
             cdsMovCNT.FieldByName('CNTHREG').AsDateTime  :=cdsClone.FieldByName('CNTHREG').AsDateTime;
             cdsMovCNT.FieldByName('CNTANO').AsString     :=cdsClone.FieldByName('CNTANO').AsString;
             cdsMovCNT.FieldByName('CNTMM').AsString      :=cdsClone.FieldByName('CNTMM').AsString;
             cdsMovCNT.FieldByName('CNTDD').AsString      :=cdsClone.FieldByName('CNTDD').AsString;
             cdsMovCNT.FieldByName('CNTTRI').AsString     :=cdsClone.FieldByName('CNTTRI').AsString;
             cdsMovCNT.FieldByName('CNTSEM').AsString     :=cdsClone.FieldByName('CNTSEM').AsString;
             cdsMovCNT.FieldByName('CNTSS').AsString      :=cdsClone.FieldByName('CNTSS').AsString;
             cdsMovCNT.FieldByName('CNTAATRI').AsString   :=cdsClone.FieldByName('CNTAATRI').AsString;
             cdsMovCNT.FieldByName('CNTAASEM').AsString   :=cdsClone.FieldByName('CNTAASEM').AsString;
             cdsMovCNT.FieldByName('CNTAASS').AsString    :=cdsClone.FieldByName('CNTAASS').AsString;
             cdsMovCNT.FieldByName('TMONID').AsString     :=cdsClone.FieldByName('TMONID').AsString;
             cdsMovCNT.FieldByName('TDIARDES').AsString   :=cdsClone.FieldByName('TDIARDES').AsString;
             cdsMovCNT.FieldByName('DOCDES').AsString     :=cdsClone.FieldByName('DOCDES').AsString;
             cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat   :=dDebeMN;
             cdsMovCNT.FieldByName('CNTDEBEME').AsFloat   :=dDebeME;
             cdsMovCNT.FieldByName('CNTHABEMN').AsFloat   :=dHabeMN;
             cdsMovCNT.FieldByName('CNTHABEME').AsFloat   :=dHabeME;
             cdsMovCNT.FieldByName('MODULO').AsString     :=cdsClone.FieldByName('MODULO').AsString;
             iOrden:=iOrden+1;
             cdsMovCNT.FieldByName('CNTREG').AsInteger    :=iOrden;
             FoaConta.cdsPost( cdsMovCNT );

             FoaConta.AplicaDatos( cdsMovCNT, 'MOVCNT' );
           end;

           cdsClone.Next;
         end;
         //
         FoaConta.AplicaDatos( cdsMovCNT, 'MOVCNT' );
         }
         //
         // CUADRA ASIENTO
         xTotDebeMN := 0;
         xTotHaberMN := 0;
         xTotDebeME := 0;
         xTotHaberME := 0;
         cdsMovCnt.First;
         While Not cdsMovCnt.eof Do
         Begin
            If cdsMovCnt.FieldByName('CNTDH').AsString = 'D' Then
            Begin
               xTotDebeMN := xTotDebeMN + cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
               xTotDebeME := xTotDebeME + cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
            End
            Else
            Begin
               xTotHaberMN := xTotHaberMN + cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
               xTotHaberME := xTotHaberME + cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
            End;
            cdsMovCnt.Next;
         End;

         xDif := 0;

         If cdsMovCnt.FieldByName('TMONID').AsString = wTMonExt_C Then
         Begin
            If FoaConta.FRound(xTotHaberMN, 15, 2) <> FoaConta.FRound(xTotDebeMN, 15, 2) Then
            Begin
               If FoaConta.fround(xTotHaberMN, 15, 2) > FoaConta.fround(xTotDebeMN, 15, 2) Then
               Begin
                  xDIf := FoaConta.fround(FoaConta.fround(xTotHaberMN, 15, 2) - FoaConta.fround(xTotDebeMN, 15, 2), 15, 2);
                  cdsMovCnt.First;
                  While Not cdsMovCnt.eof Do
                  Begin
                     If cdsMovCnt.FieldByName('CNTDH').AsString = 'D' Then
                     Begin
                        cdsMovCnt.Edit;
                        cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat := FoaConta.FRound(cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat + xDif, 15, 2);
                        cdsMovCnt.FieldByName('CNTDEBEMN').AsFloat := cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
                        cdsMovCnt.Post;
                        Break;
                     End;
                     cdsMovCnt.Next;
                  End;
               End
               Else
               Begin
                  xDIf := FoaConta.Fround(FoaConta.fround(xTotDebeMN, 15, 2) - FoaConta.fround(xTotHaberMN, 15, 2), 15, 2);
                  cdsMovCnt.First;
                  While Not cdsMovCnt.eof Do
                  Begin
                     If cdsMovCnt.FieldByName('CNTDH').AsString = 'H' Then
                     Begin
                        cdsMovCnt.Edit;
                        cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat := FoaConta.FRound(cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat + xDif, 15, 2);
                        cdsMovCnt.FieldByName('CNTHABEMN').AsFloat := cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
                        cdsMovCnt.Post;
                        Break;
                     End;
                     cdsMovCnt.Next;
                  End;
               End

            End;
         End
         Else
         Begin
            If FoaConta.fround(xTotHaberME, 15, 2) <> FoaConta.fround(xTotDebeME, 15, 2) Then
            Begin
               If FoaConta.fround(xTotHaberME, 15, 2) > FoaConta.fround(xTotDebeME, 15, 2) Then
               Begin
                  xDIf := FoaConta.fround(FoaConta.fround(xTotHaberME, 15, 2) - FoaConta.fround(xTotDebeME, 15, 2), 15, 2);
                  cdsMovCnt.First;
                  While Not cdsMovCnt.eof Do
                  Begin
                     If cdsMovCnt.FieldByName('CNTDH').AsString = 'D' Then
                     Begin
                        cdsMovCnt.Edit;
                        cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat := FoaConta.FRound(cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat + xDif, 15, 2);
                        cdsMovCnt.FieldByName('CNTDEBEME').AsFloat := cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
                        cdsMovCnt.Post;
                        Break;
                     End;
                     cdsMovCnt.Next;
                  End;
               End
               Else
               Begin
                  xDIf := FoaConta.fround(FoaConta.fround(xTotDebeME, 15, 2) - FoaConta.fround(xTotHaberME, 15, 2), 15, 2);
                  cdsMovCnt.First;
                  While Not cdsMovCnt.eof Do
                  Begin
                     If cdsMovCnt.FieldByName('CNTDH').AsString = 'H' Then
                     Begin
                        cdsMovCnt.Edit;
                        cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat := FoaConta.FRound(cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat + xDif, 15, 2);
                        cdsMovCnt.FieldByName('CNTHABEME').AsFloat := cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
                        cdsMovCnt.Post;
                        Break;
                     End;
                     cdsMovCnt.Next;
                  End;
               End
            End;
         End;

         FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');

         FoaConta.AsientosAdicionales(xCiaOri, xOrigen2, xAnoMM, xNoComp1, xNoCompP, wMtoOri_C);

         cdsMovCnt.First;
         cdsMovCnt.EnableControls;
         // FIN CUADRA ASIENTO
         Result := False;
      End;
   End;

   //////////////////////////////////////////////////
   // GENERA ASIENTOS AUTOMATICOS PARA ASIENTO PRINCIPAL
   //////////////////////////////////////////////////
//         if not cdsQry_G.Eof then
//         begin
   xCia := '02';
            //xTDiario:=xOrigen2;
            //xNoComp :=xNoComp2;
//         end;

   cdsClone := TwwClientDataSet.Create(Nil);
   cdsClone.RemoteServer := DCOMx;
   cdsClone.ProviderName := Provider_C;
   cdsClone.Close;

   sSQL := 'Select A.CIAID, TDIARID, CNTCOMPROB, MAX(CNTANO) CNTANO, CNTANOMM, A.CUENTAID, '
         + 'CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CCOSID, '
         + 'MAX(CNTGLOSA) CNTGLOSA, CNTDH, MAX(CNTTCAMBIO) CNTTCAMBIO, MAX(CNTLOTE) CNTLOTE, '
         + 'SUM(CNTMTOORI) CNTMTOORI, SUM(CNTMTOLOC) CNTMTOLOC, SUM(CNTMTOEXT) CNTMTOEXT, '
         + 'MAX(CNTFCOMP) CNTFCOMP, MAX(CNTFEMIS) CNTFEMIS, MAX(CNTFVCMTO) CNTFVCMTO, '
         + 'MAX(CNTUSER) CNTUSER, MAX(CNTFREG) CNTFREG, MAX(CNTHREG) CNTHREG, MAX(CNTMM) CNTMM, '
         + 'MAX(CNTDD) CNTDD, MAX(CNTTRI) CNTTRI, MAX(CNTSEM) CNTSEM, MAX(CNTSS) CNTSS, '
         + 'MAX(CNTAATRI) CNTAATRI, MAX(CNTAASEM) CNTAASEM, MAX(CNTAASS) CNTAASS, MAX(TMONID) TMONID, '
         + 'MAX(TDIARDES) TDIARDES, MAX(A.CTADES) CTADES, MAX(AUXDES) AUXDES, MAX(DOCDES) DOCDES, '
         + 'SUM(CNTDEBEMN) CNTDEBEMN, SUM(CNTDEBEME) CNTDEBEME, SUM(CNTHABEMN) CNTHABEMN, SUM(CNTHABEME) CNTHABEME, '
         + 'MAX(CNTTS) CNTTS, MAX(CNTMODDOC) CNTMODDOC, MAX(CCOSDES) CCOSDES, MAX(CTA_AUX) CTA_AUX, MAX(CTA_CCOS) CTA_CCOS, '
         + 'MAX(CTAAUT1) CTAAUT1, MAX(CTAAUT2) CTAAUT2,MAX(CTA_AUT1) CTA_AUT1, MAX(CTA_AUT2) CTA_AUT2, MAX(MODULO) MODULO '
         + 'FROM CNT311 A, TGE202 B '
      //       +'FROM CNT301 A, TGE202 B '
         + 'WHERE A.CIAID=' + QuotedStr(xCia)
         + ' and TDIARID=' + QuotedStr(xTDiario)
         + ' and CNTANOMM=' + QuotedStr(xAnoMM)
         + ' and CNTCOMPROB=' + QuotedStr(xnoComp)
         + ' and A.CIAID=B.CIAID AND A.CUENTAID=B.CUENTAID '
         + 'Group by A.CIAID, TDIARID, CNTANOMM, CNTCOMPROB, A.CUENTAID, CNTDH, CLAUXID, '
         + 'AUXID, CCOSID, DOCID, CNTSERIE, CNTNODOC';

   cdsClone.DataRequest(sSQL);
   cdsClone.Open;

   FoaConta.PanelMsg('Generando Asientos Automaticos', 0);

   iOrden := cdsClone.recordcount + 2;

   cdsMovCNT.DisableControls;
   cdsClone.First;
   While Not cdsClone.EOF Do
   Begin
      sCia := cdsClone.FieldByName('CIAID').AsString;
      sCuenta := cdsClone.FieldByName('CUENTAID').AsString;

           //SI TIENE CUENTA AUTOMATICA 1 y 2
      If (cdsClone.FieldByName('CTA_AUT1').AsString = 'S') And
         (cdsClone.FieldByName('CTA_AUT2').AsString = 'S') Then
      Begin

         xSQL := 'Select CTA_AUX, CTA_CCOS from TGE202 '
            + 'Where CIAID=' + quotedstr(xCia)
            + ' and CUENTAID=' + quotedstr(cdsClone.FieldByName('CTAAUT1').AsString);
         cdsQry_C.Close;
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Open;

             //SI LA CUENTA ORIGES ESTA DESTINADA AL DEBE LA CUENTA AUTOMATICA 1 IRA AL HABER
         If cdsClone.FieldByName('CNTDH').AsString = 'D' Then
         Begin
            sDeHa := 'D';
            dHabeMN := 0;
            dHabeME := 0;
            dDebeMN := cdsClone.FieldByName('CNTMTOLOC').AsFloat;
            dDebeME := cdsClone.FieldByName('CNTMTOEXT').AsFloat;
         End
         Else
         Begin
            sDeHa := 'H';
            dDebeMN := 0;
            dDebeME := 0;
            dHabeMN := cdsClone.FieldByName('CNTMTOLOC').AsFloat;
            dHabeME := cdsClone.FieldByName('CNTMTOEXT').AsFloat;
         End;

         cdsMovCNT.Insert;
         cdsMovCNT.FieldByName('CIAID').AsString := cdsClone.FieldByName('CIAID').AsString;
         cdsMovCNT.FieldByName('TDIARID').AsString := cdsClone.FieldByName('TDIARID').AsString;
         cdsMovCNT.FieldByName('CNTCOMPROB').AsString := cdsClone.FieldByName('CNTCOMPROB').AsString;
         cdsMovCNT.FieldByName('CNTANOMM').AsString := cdsClone.FieldByName('CNTANOMM').AsString;
         cdsMovCNT.FieldByName('CUENTAID').AsString := cdsClone.FieldByName('CTAAUT1').AsString;
         cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsClone.FieldByName('CNTLOTE').AsString;

         If cdsQry_C.FieldByName('CTA_AUX').AsString = 'S' Then
         Begin
            cdsMovCNT.FieldByName('CLAUXID').AsString := cdsClone.FieldByName('CLAUXID').AsString;
            cdsMovCNT.FieldByName('AUXID').AsString := cdsClone.FieldByName('AUXID').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString := cdsClone.FieldByName('AUXDES').AsString;
         End
         Else
         Begin
            cdsMovCNT.FieldByName('CLAUXID').AsString := '';
            cdsMovCNT.FieldByName('AUXID').AsString := '';
            cdsMovCNT.FieldByName('AUXDES').AsString := '';
         End;

         If cdsQry_C.FieldByName('CTA_CCOS').AsString = 'S' Then
         Begin
            cdsMovCNT.FieldByName('CCOSID').AsString := cdsClone.FieldByName('CCOSID').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString := cdsClone.FieldByName('CCOSDES').AsString;
         End
         Else
         Begin
            cdsMovCNT.FieldByName('CCOSID').AsString := '';
            cdsMovCNT.FieldByName('CCOSDES').AsString := '';
         End;

         cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsClone.FieldByName('CNTMODDOC').AsString;
         cdsMovCNT.FieldByName('DOCID').AsString := cdsClone.FieldByName('DOCID').AsString;
         cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsClone.FieldByName('CNTSERIE').AsString;
         cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsClone.FieldByName('CNTNODOC').AsString;
         cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsClone.FieldByName('CNTGLOSA').AsString;
         cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
         cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsClone.FieldByName('CNTTCAMBIO').AsString;
         cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsClone.FieldByName('CNTMTOORI').AsString;
         cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsClone.FieldByName('CNTMTOLOC').AsString;
         cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsClone.FieldByName('CNTMTOEXT').AsString;
         cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsClone.FieldByName('CNTFEMIS').AsDateTime;
         cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsClone.FieldByName('CNTFVCMTO').AsDateTime;
         cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsClone.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
         cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
      // Inicio : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
      // Fin : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTUSER').AsString := cdsClone.FieldByName('CNTUSER').AsString;
         cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsClone.FieldByName('CNTFREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsClone.FieldByName('CNTHREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTANO').AsString := cdsClone.FieldByName('CNTANO').AsString;
         cdsMovCNT.FieldByName('CNTMM').AsString := cdsClone.FieldByName('CNTMM').AsString;
         cdsMovCNT.FieldByName('CNTDD').AsString := cdsClone.FieldByName('CNTDD').AsString;
         cdsMovCNT.FieldByName('CNTTRI').AsString := cdsClone.FieldByName('CNTTRI').AsString;
         cdsMovCNT.FieldByName('CNTSEM').AsString := cdsClone.FieldByName('CNTSEM').AsString;
         cdsMovCNT.FieldByName('CNTSS').AsString := cdsClone.FieldByName('CNTSS').AsString;
         cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsClone.FieldByName('CNTAATRI').AsString;
         cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsClone.FieldByName('CNTAASEM').AsString;
         cdsMovCNT.FieldByName('CNTAASS').AsString := cdsClone.FieldByName('CNTAASS').AsString;
         cdsMovCNT.FieldByName('TMONID').AsString := cdsClone.FieldByName('TMONID').AsString;
         cdsMovCNT.FieldByName('TDIARDES').AsString := cdsClone.FieldByName('TDIARDES').AsString;
         cdsMovCNT.FieldByName('DOCDES').AsString := cdsClone.FieldByName('DOCDES').AsString;
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
         cdsMovCNT.FieldByName('MODULO').AsString := cdsClone.FieldByName('MODULO').AsString;
         iOrden := iOrden + 1;
         cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
         FoaConta.cdsPost(cdsMovCNT);

             //SI LA CUENTA ORIGES ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
         If cdsClone.FieldByName('CNTDH').AsString = 'D' Then
         Begin
            sDeHa := 'H';
            dDebeMN := 0;
            dDebeME := 0;
            dHabeMN := cdsClone.FieldByName('CNTMTOLOC').AsFloat;
            dHabeME := cdsClone.FieldByName('CNTMTOEXT').AsFloat;
         End
         Else
         Begin
            sDeHa := 'D';
            dDebeMN := cdsClone.FieldByName('CNTMTOLOC').AsFloat;
            dDebeME := cdsClone.FieldByName('CNTMTOEXT').AsFloat;
            dHabeMN := 0;
            dHabeME := 0;
         End;

         xSQL := 'Select CTA_AUX, CTA_CCOS from TGE202 '
            + 'Where CIAID=' + quotedstr(xCia)
            + ' and CUENTAID=' + quotedstr(cdsClone.FieldByName('CTAAUT2').AsString);
         cdsQry_C.Close;
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Open;

         cdsMovCNT.Insert;
         cdsMovCNT.FieldByName('CIAID').AsString := cdsClone.FieldByName('CIAID').AsString;
         cdsMovCNT.FieldByName('TDIARID').AsString := cdsClone.FieldByName('TDIARID').AsString;
         cdsMovCNT.FieldByName('CNTCOMPROB').AsString := cdsClone.FieldByName('CNTCOMPROB').AsString;
         cdsMovCNT.FieldByName('CNTANOMM').AsString := cdsClone.FieldByName('CNTANOMM').AsString;
         cdsMovCNT.FieldByName('CUENTAID').AsString := cdsClone.FieldByName('CTAAUT2').AsString;
         cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsClone.FieldByName('CNTLOTE').AsString;

         If cdsQry_C.FieldByName('CTA_AUX').AsString = 'S' Then
         Begin
            cdsMovCNT.FieldByName('CLAUXID').AsString := cdsClone.FieldByName('CLAUXID').AsString;
            cdsMovCNT.FieldByName('AUXID').AsString := cdsClone.FieldByName('AUXID').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString := cdsClone.FieldByName('AUXDES').AsString;
         End
         Else
         Begin
            cdsMovCNT.FieldByName('CLAUXID').Clear;
            cdsMovCNT.FieldByName('AUXID').Clear;
            cdsMovCNT.FieldByName('AUXDES').Clear;
         End;

         If cdsQry_C.FieldByName('CTA_CCOS').AsString = 'S' Then
         Begin
            cdsMovCNT.FieldByName('CCOSID').AsString := cdsClone.FieldByName('CCOSID').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString := cdsClone.FieldByName('CCOSDES').AsString;
         End
         Else
         Begin
            cdsMovCNT.FieldByName('CCOSID').Clear;
            cdsMovCNT.FieldByName('CCOSDES').Clear;
         End;

         cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsClone.FieldByName('CNTMODDOC').AsString;
         cdsMovCNT.FieldByName('DOCID').AsString := cdsClone.FieldByName('DOCID').AsString;
         cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsClone.FieldByName('CNTSERIE').AsString;
         cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsClone.FieldByName('CNTNODOC').AsString;
         cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsClone.FieldByName('CNTGLOSA').AsString;
         cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
         cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsClone.FieldByName('CNTTCAMBIO').AsString;
         cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsClone.FieldByName('CNTMTOORI').AsString;
         cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsClone.FieldByName('CNTMTOLOC').AsString;
         cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsClone.FieldByName('CNTMTOEXT').AsString;
         cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsClone.FieldByName('CNTFEMIS').AsDateTime;
         cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsClone.FieldByName('CNTFVCMTO').AsDateTime;
         cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsClone.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
         cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
      // Inicio : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
      // Fin : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTUSER').AsString := cdsClone.FieldByName('CNTUSER').AsString;
         cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsClone.FieldByName('CNTFREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsClone.FieldByName('CNTHREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTANO').AsString := cdsClone.FieldByName('CNTANO').AsString;
         cdsMovCNT.FieldByName('CNTMM').AsString := cdsClone.FieldByName('CNTMM').AsString;
         cdsMovCNT.FieldByName('CNTDD').AsString := cdsClone.FieldByName('CNTDD').AsString;
         cdsMovCNT.FieldByName('CNTTRI').AsString := cdsClone.FieldByName('CNTTRI').AsString;
         cdsMovCNT.FieldByName('CNTSEM').AsString := cdsClone.FieldByName('CNTSEM').AsString;
         cdsMovCNT.FieldByName('CNTSS').AsString := cdsClone.FieldByName('CNTSS').AsString;
         cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsClone.FieldByName('CNTAATRI').AsString;
         cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsClone.FieldByName('CNTAASEM').AsString;
         cdsMovCNT.FieldByName('CNTAASS').AsString := cdsClone.FieldByName('CNTAASS').AsString;
         cdsMovCNT.FieldByName('TMONID').AsString := cdsClone.FieldByName('TMONID').AsString;
         cdsMovCNT.FieldByName('TDIARDES').AsString := cdsClone.FieldByName('TDIARDES').AsString;
         cdsMovCNT.FieldByName('DOCDES').AsString := cdsClone.FieldByName('DOCDES').AsString;
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
         cdsMovCNT.FieldByName('MODULO').AsString := cdsClone.FieldByName('MODULO').AsString;
         iOrden := iOrden + 1;
         cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
         FoaConta.cdsPost(cdsMovCNT);

         FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');
      End;

      cdsClone.Next;
   End;
         //
   FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');

   FoaConta.PanelMsg('Generando Asientos Automaticos', 0);

   pnlConta_C.Free;

   If (xTipoC = 'C') Or (xTipoC = 'P') Or (xTipoC = 'CCNA') Or (xTipoC = 'PCNA') Or
      (xTipoC = 'PPG') Or (xTipoC = 'CPG') Then
   Begin

      xSQL := 'Insert into CNT301 ('
            + ' CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
            + 'CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
            + 'CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
            + 'CNTFEMIS, CNTFVCMTO, CNTFCOMP, CNTESTADO, CNTCUADRE, CNTFAUTOM, '
            + 'CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
            + 'CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
            + 'TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
            + 'CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
            + 'CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
            + 'CNTMODDOC, CNTREG, MODULO, CTA_SECU ) '
            + 'Select CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
            + 'CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
            + 'CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
            + 'CNTFEMIS, CNTFVCMTO, CNTFCOMP, ''P'', ''S'', CNTFAUTOM, '
            + 'CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
            + 'CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
            + 'TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
            + 'CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
            + 'CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
            + 'CNTMODDOC, CNTREG, MODULO, CTA_SECU '
            + 'From CNT311 a Where (' + xSQLAdicional + ' )';
      Try
         cdsQry_C.Close;
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Execute;
      Except
         Errorcount2 := 1;
         Exit;
      End;

      // Genera Cabecera si Modulo no es Contabilidad
      xxModulo := 'CAJA';
      xSQL := 'SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB '
            + 'FROM ' + CNTCab + ' A '
            + 'WHERE (' + xSQLAdicional + ' )';
      cdsQry_C.Close;
      cdsQry_C.DataRequest(xSQL);
      cdsQry_C.Open;

      If cdsQry_C.RecordCount <= 0 Then
      Begin
         xSQL := 'INSERT INTO ' + CNTCab;
         xSQL := xSQL + '( CIAID, TDIARID, CNTANOMM, CNTCOMPROB, CNTLOTE, ';
         xSQL := xSQL + 'CNTGLOSA, CNTTCAMBIO, CNTFCOMP, CNTESTADO, CNTCUADRE, ';
         xSQL := xSQL + 'CNTUSER, CNTFREG, CNTHREG, CNTANO, CNTMM, CNTDD, CNTTRI, ';
         xSQL := xSQL + 'CNTSEM, CNTSS, CNTAATRI, CNTAASEM, CNTAASS, TMONID, ';
         xSQL := xSQL + 'FLAGVAR, TDIARDES, CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, ';
         xSQL := xSQL + 'CNTTS, DOCMOD, MODULO ) ';
         xSQL := xSQL + 'SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB,  A.CNTLOTE, ';
         xSQL := xSQL + 'DECODE( MIN(A.CNTREG), 1, MAX( A.CNTGLOSA ), ''COMPROBANTE DE ''||MAX(MODULO) ), ';
         xSQL := xSQL + 'MAX( NVL( A.CNTTCAMBIO, 0 ) ), ';
         xSQL := xSQL + 'A.CNTFCOMP, ''P'', ''S'', ';
         xSQL := xSQL + 'MAX( CNTUSER ), MAX( CNTFREG ), MAX( CNTHREG ), A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI, ';
         xSQL := xSQL + 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
         xSQL := xSQL + 'CASE WHEN SUM( CASE WHEN TMONID=''' + wTMonExt_C + ''' THEN 1 ELSE 0 END )>'
            + ' SUM( CASE WHEN TMONID=''' + wTMonLoc_C + ''' THEN 1 ELSE 0 END ) '
            + ' THEN ''' + wTMonExt_C + ''' ELSE ''' + wTMonLoc_C + ''' END, ';
         xSQL := xSQL + ''' '', A.TDIARDES, ';
         xSQL := xSQL + 'SUM(A.CNTDEBEMN), SUM(A.CNTDEBEME), SUM(A.CNTHABEMN), SUM(A.CNTHABEME), ';
         xSQL := xSQL + 'MAX( CNTTS ), MAX( CNTMODDOC), MAX( MODULO ) ';
         xSQL := xSQL + 'FROM ' + CNTDet + ' A ';
         xSQL := xSQL + 'WHERE (' + xSQLAdicional + ' ) ';
         xSQL := xSQL + 'GROUP BY A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB, A.CNTLOTE, ';
         xSQL := xSQL + 'A.CNTFCOMP, A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI,  ';
         xSQL := xSQL + 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
         xSQL := xSQL + 'A.TDIARDES';

         Try
            cdsQry_C.Close;
            cdsQry_C.DataRequest(xSQL);
            cdsQry_C.Execute;
         Except
            Errorcount2 := 1;
            Exit;
         End;
      End;

      xsql := 'SELECT A.*, B.CIADES FROM CNT311 A, TGE101 B '
         + 'WHERE (' + xSQLAdicional + ' ) and a.ciaid=b.ciaid(+)'
         + 'ORDER BY A.CIAID, A.CNTANOMM, A.TDIARID, A.CNTREG';

      Try
         cdsMovCNT.IndexFieldNames := '';
         cdsMovCNT.Filter := '';
         cdsMovCNT.Filtered := True;
         cdsMovCNT.Close;
         cdsMovCNT.DataRequest(xSQL);
         cdsMovCNT.Open;
      Except
         Errorcount2 := 1;
         Exit;
      End;
      //end;

      xSQL := 'Delete From CNT311 A where ' + xSQLAdicional;
      Try
         cdsQry_C.Close;
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Execute;
      Except
         Errorcount2 := 1;
         Exit;
      End;

      If xxModulo <> 'CNT' Then
      Begin
         xSQL := 'Delete From CNT310 a where ' + xSQLAdicional;
         Try
            cdsQry_C.Close;
            cdsQry_C.DataRequest(xSQL);
            cdsQry_C.Execute;
         Except
         End;
      End;
   End;

   FoaConta.CerrarTablas;

   If Errorcount2 > 0 Then Exit;

   Result := True;
End;

Function SOLConta(xCia, xTDiario, xAnoMM, xNoComp, xSRV, xTipoC, xModulo: String;
   cdsMovCNT, cdsNivelx, cdsResultSetx: TwwClientDataSet;
   DCOMx: TSocketConnection;
   xForm_C: TForm): Boolean;
Var
   sSQL, xNREG, xSQL, xCajaAut: String;
   xNumT, iOrdenx: Integer;
   sCIA, sCuenta, sDeHa: String;
   dDebeMN, dHabeMN, dDebeME, dHabeME: double;
   xTotDebeMN, xTotHaberMN, xTotDebeME, xTotHaberME, xDif: Double;
   cdsClone: TwwClientDataSet;
   xxModulo: String;
Begin
   If (xTipoC = 'P') Or (xTipoC = 'C') Or (xTipoC = 'BP') Or (xTipoC = 'CCNA') Or (xTipoC = 'PCNA') Then
   Begin
      CNTDet := 'CNT311';
      If xTipoC = 'P' Then
         CNTCab := 'CNT310'
      Else
         CNTCab := 'CNT300';
   End
   Else
   Begin
      // Para Mayorización
      CNTCab := 'CNT300';
      CNTDet := 'CNT301';

   End;

   FoaConta.CreaPanel(xForm_C, 'Contabilizando');

   DCOM_C := DCOMx;
   SRV_C := xSRV;
   xTipoC_C := xTipoC;

   If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
   Begin
      wReplaCeros := 'COALESCE';
   End
   Else
      If SRV_C = 'ORACLE' Then
      Begin
         wReplaCeros := 'NVL';
      End;

   Provider_C := 'dspTem6';

   cdsNivel_C := cdsNivelx;
   cdsResultSet_C := cdsResultSetx;

   cdsQry_C := TwwClientDataSet.Create(Nil);
   cdsQry_C.RemoteServer := DCOMx;
   cdsQry_C.ProviderName := Provider_C;

   // Se Añade Para Mayorizar Solamente
   If (xTipoC = 'M') Then
   Begin
      FoaConta.GeneraEnLinea401(xCia, xTDiario, xAnoMM, xNoComp, 'S');

      pnlConta_C.Free;

      FoaConta.CerrarTablas;

      If Errorcount2 > 0 Then Exit;

      Result := True;
      Exit;
   End;

   // Se Añade Para Mayorizar Solamente
   If (xTipoC = 'MC') Then
   Begin

      If xNoComp = '' Then
      Begin
         FoaConta.CerrarTablas;
         Result := False;
         Exit;
      End;

      FoaConta.GeneraEnLinea401(xCia, xTDiario, xAnoMM, xNoComp, 'S');
      pnlConta_C.Free;

      FoaConta.CerrarTablas;

      If Errorcount2 > 0 Then Exit;

      Result := True;
      Exit;
   End;

   // Se Añade Para Mayorizar Solamente Cuentas con Auxiliar y CCosto
   If (xTipoC = 'MCACC') Then
   Begin

      FoaConta.GeneraEnLinea401(xCia, xTDiario, xAnoMM, xNoComp, 'S');
      pnlConta_C.Free;

      FoaConta.CerrarTablas;

      If Errorcount2 > 0 Then Exit;

      Result := True;
      Exit;
   End;

   xRegAdicional := '';
   xSQLAdicional := '';

   xSQL := 'Select TMONID from TGE103 where TMON_LOC=' + '''' + 'L' + '''';
   cdsQry_C.Close;
   cdsQry_C.DataRequest(xSQL);
   cdsQry_C.Open;
   wTMonLoc_C := cdsQry_C.FieldByname('TMONID').AsString;

   xSQL := 'Select TMONID from TGE103 where TMON_LOC=' + '''' + 'E' + '''';
   cdsQry_C.Close;
   cdsQry_C.DataRequest(xSQL);
   cdsQry_C.Open;
   wTMonExt_C := cdsQry_C.FieldByname('TMONID').AsString;

   cdsMovCNT.IndexFieldNames := 'CNTREG';
   cdsMovCNT.Last;
   iOrdenx := cdsMovCNT.FieldByName('CNTREG').AsInteger + 1;
   cdsMovCNT.IndexFieldNames := '';

// xTipoC='PCNA'  Si Previo con Caja que NO es Autonoma
// xTipoC='CCNA'  Si Contabiliza con Caja que NO es Autonoma
   If (xTipoC = 'PCNA') Or (xTipoC = 'CCNA') Then
   Begin
      xSQL := 'Select CJAAUTONOM from TGE101 where CIAID=''' + xCia + '''';
      cdsQry_C.Close;
      cdsQry_C.DataRequest(xSQL);
      cdsQry_C.Open;
      xCajaAut := cdsQry_C.FieldByName('CJAAUTONOM').AsString;
      cdsQry_C.Close;

      If xCajaAut = 'N' Then
      Begin

         xSQL := 'Select CTADEBE, B.CTA_AUX AUX_D, B.CTA_CCOS CCOS_D, '
               + 'CTAHABER, C.CTA_AUX AUX_H, C.CTA_CCOS CCOS_H, '
               + 'TDIARID, CIAORIGEN, TDIARID2 '
               + 'From CAJA103 A, TGE202 B, TGE202 C '
               + 'Where A.CIAID=''' + xCia + ''' '
               + ' AND B.CIAID=A.CIAID AND A.CTADEBE=B.CUENTAID '
               + ' AND C.CIAID=A.CIAID AND A.CTAHABER=C.CUENTAID ';
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Open;

         If cdsQry_C.RecordCount = 0 Then
         Begin
            Errorcount2 := 1;
            FoaConta.CerrarTablas;
            ShowMessage('Error : Caja de Compañía ' + xCia + ' No es Autonoma. Faltan Cuentas Reflejas');
            Exit;
         End;

         xCiaOri := cdsQry_C.FieldByName('CIAORIGEN').AsString;
         xOrigen := cdsQry_C.FieldByName('TDIARID').AsString;
         xCtaDebe := cdsQry_C.FieldByName('CTADEBE').AsString;
         xAux_D := cdsQry_C.FieldByName('AUX_D').AsString;
         xCCos_D := cdsQry_C.FieldByName('CCOS_D').AsString;
         xCtaHaber := cdsQry_C.FieldByName('CTAHABER').AsString;
         xAux_H := cdsQry_C.FieldByName('AUX_H').AsString;
         xCCos_H := cdsQry_C.FieldByName('CCOS_H').AsString;
         xOrigen2 := cdsQry_C.FieldByName('TDIARID2').AsString;
         cdsQry_C.Close;
         xSQL := ' SELECT CUENTAID,CPTODES FROM CAJA201 WHERE CPTOIS=''R''';
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Open;
         xCtaRetDebe := cdsQry_C.FieldByName('CUENTAID').AsString;
         xGlosaRetDebe := cdsQry_C.FieldByName('CPTODES').AsString;
         cdsQry_C.Close;
         xSQL := ' SELECT CUENTAID,CPTODES FROM CAJA201 WHERE CPTOIS=''T''';
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Open;
         xCtaRetHaber := cdsQry_C.FieldByName('CUENTAID').AsString;
         xGlosaRetHaber := cdsQry_C.FieldByName('CPTODES').AsString;
         cdsQry_C.Close;

         If (xCtaDebe = '') Or (xCtaHaber = '') Then
         Begin
            Errorcount2 := 1;
            FoaConta.CerrarTablas;
            ShowMessage('Error : Caja de Compañía ' + xCia + ' No es Autonoma. Faltan Cuentas Reflejas');
            Exit;
         End;


         FoaConta.GeneraAsientosComplementarios(xCia, xTDiario, xAnoMM, xNoComp, xTipoC, cdsMovCNT);

         xSQL := 'SELECT * FROM CNT311 '
               + 'WHERE CIAID=' + quotedstr(xCia) + ' AND '
               + 'TDIARID=' + quotedstr(xTDiario) + ' AND '
               + 'CNTANOMM=' + quotedstr(xAnoMM) + ' AND '
               + 'CNTCOMPROB=' + quotedstr(xNoComp) + ' '
               + 'ORDER BY CNTREG';
         cdsMovCNT.Close;
         cdsMovCNT.DataRequest(xSQL);
         cdsMovCNT.Open;

      End;
   End;

   If copy(xAnoMM, 5, 2) <> '13' Then
   Begin

      FoaConta.PanelMsg('Generando Asientos Automaticos', 0);

      // GENERA ASIENTOS AUTOMATICOS PARA LA CUENTA 1

      cdsClone := TwwClientDataSet.Create(Nil);
      cdsClone.RemoteServer := DCOMx;
      cdsClone.ProviderName := Provider_C;
      cdsClone.Close;

      sSQL := 'Select A.CIAID, TDIARID, CNTCOMPROB, MAX(CNTANO) CNTANO, CNTANOMM, A.CUENTAID, '
            + 'CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CCOSID, '
            + 'MAX(CNTGLOSA) CNTGLOSA, CNTDH, MAX(CNTTCAMBIO) CNTTCAMBIO, MAX(CNTLOTE) CNTLOTE, '
            + 'SUM(CNTMTOORI) CNTMTOORI, SUM(CNTMTOLOC) CNTMTOLOC, SUM(CNTMTOEXT) CNTMTOEXT, '
            + 'MAX(CNTFCOMP) CNTFCOMP, MAX(CNTFEMIS) CNTFEMIS, MAX(CNTFVCMTO) CNTFVCMTO, '
            + 'MAX(CNTUSER) CNTUSER, MAX(CNTFREG) CNTFREG, MAX(CNTHREG) CNTHREG, MAX(CNTMM) CNTMM, '
            + 'MAX(CNTDD) CNTDD, MAX(CNTTRI) CNTTRI, MAX(CNTSEM) CNTSEM, MAX(CNTSS) CNTSS, '
            + 'MAX(CNTAATRI) CNTAATRI, MAX(CNTAASEM) CNTAASEM, MAX(CNTAASS) CNTAASS, MAX(TMONID) TMONID, '
            + 'MAX(TDIARDES) TDIARDES, MAX(A.CTADES) CTADES, MAX(AUXDES) AUXDES, MAX(DOCDES) DOCDES, '
            + 'SUM(CNTDEBEMN) CNTDEBEMN, SUM(CNTDEBEME) CNTDEBEME, SUM(CNTHABEMN) CNTHABEMN, SUM(CNTHABEME) CNTHABEME, '
            + 'MAX(CNTTS) CNTTS, MAX(CNTMODDOC) CNTMODDOC, MAX(CCOSDES) CCOSDES, MAX(CTA_AUX) CTA_AUX, MAX(CTA_CCOS) CTA_CCOS, '
            + 'MAX(CTAAUT1) CTAAUT1, MAX(CTAAUT2) CTAAUT2,MAX(CTA_AUT1) CTA_AUT1, MAX(CTA_AUT2) CTA_AUT2, MAX(MODULO) MODULO '
            + 'FROM ' + CNTDet + ' A, TGE202 B '
   //       +'FROM CNT301 A, TGE202 B '
            + 'WHERE A.CIAID=' + QuotedStr(xCia)
            + ' and TDIARID=' + QuotedStr(xTDiario)
            + ' and CNTANOMM=' + QuotedStr(xAnoMM)
            + ' and CNTCOMPROB=' + QuotedStr(xnoComp)
            + ' and A.CIAID=B.CIAID AND A.CUENTAID=B.CUENTAID '
            + 'Group by A.CIAID, TDIARID, CNTANOMM, CNTCOMPROB, A.CUENTAID, CNTDH, CLAUXID, '
            + 'AUXID, CCOSID, DOCID, CNTSERIE, CNTNODOC';

      cdsClone.DataRequest(sSQL);
      cdsClone.Open;

      FoaConta.PanelMsg('Generando Asientos Automaticos', 0);

      iOrden := iOrdenx;

      cdsMovCNT.DisableControls;
      cdsClone.First;
      While Not cdsClone.EOF Do
      Begin
         sCia := cdsClone.FieldByName('CIAID').AsString;
         sCuenta := cdsClone.FieldByName('CUENTAID').AsString;

        //SI TIENE CUENTA AUTOMATICA 1 y 2
         If (cdsClone.FieldByName('CTA_AUT1').AsString = 'S') And
            (cdsClone.FieldByName('CTA_AUT2').AsString = 'S') Then
         Begin

            xSQL := 'Select CTA_AUX, CTA_CCOS from TGE202 '
               + 'Where CIAID=' + quotedstr(xCia)
               + ' and CUENTAID=' + quotedstr(cdsClone.FieldByName('CTAAUT1').AsString);
            cdsQry_C.Close;
            cdsQry_C.DataRequest(xSQL);
            cdsQry_C.Open;

          //SI LA CUENTA ORIGES ESTA DESTINADA AL DEBE LA CUENTA AUTOMATICA 1 IRA AL HABER
            If cdsClone.FieldByName('CNTDH').AsString = 'D' Then
            Begin
               sDeHa := 'D';
               dHabeMN := 0;
               dHabeME := 0;
               dDebeMN := cdsClone.FieldByName('CNTMTOLOC').AsFloat;
               dDebeME := cdsClone.FieldByName('CNTMTOEXT').AsFloat;
            End
            Else
            Begin
               sDeHa := 'H';
               dDebeMN := 0;
               dDebeME := 0;
               dHabeMN := cdsClone.FieldByName('CNTMTOLOC').AsFloat;
               dHabeME := cdsClone.FieldByName('CNTMTOEXT').AsFloat;
            End;

            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString := cdsClone.FieldByName('CIAID').AsString;
            cdsMovCNT.FieldByName('TDIARID').AsString := cdsClone.FieldByName('TDIARID').AsString;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString := cdsClone.FieldByName('CNTCOMPROB').AsString;
            cdsMovCNT.FieldByName('CNTANOMM').AsString := cdsClone.FieldByName('CNTANOMM').AsString;
            cdsMovCNT.FieldByName('CUENTAID').AsString := cdsClone.FieldByName('CTAAUT1').AsString;
            cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsClone.FieldByName('CNTLOTE').AsString;

            If cdsQry_C.FieldByName('CTA_AUX').AsString = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CLAUXID').AsString := cdsClone.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString := cdsClone.FieldByName('AUXID').AsString;
               cdsMovCNT.FieldByName('AUXDES').AsString := cdsClone.FieldByName('AUXDES').AsString;
            End
            Else
            Begin
               cdsMovCNT.FieldByName('CLAUXID').AsString := '';
               cdsMovCNT.FieldByName('AUXID').AsString := '';
               cdsMovCNT.FieldByName('AUXDES').AsString := '';
            End;

            If cdsQry_C.FieldByName('CTA_CCOS').AsString = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CCOSID').AsString := cdsClone.FieldByName('CCOSID').AsString;
               cdsMovCNT.FieldByName('CCOSDES').AsString := cdsClone.FieldByName('CCOSDES').AsString;
            End
            Else
            Begin
               cdsMovCNT.FieldByName('CCOSID').AsString := '';
               cdsMovCNT.FieldByName('CCOSDES').AsString := '';
            End;

            cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsClone.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString := cdsClone.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsClone.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsClone.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsClone.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsClone.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsClone.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsClone.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsClone.FieldByName('CNTMTOEXT').AsString;
            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsClone.FieldByName('CNTFEMIS').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsClone.FieldByName('CNTFVCMTO').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsClone.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
         // Inicio : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
         // Fin : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTUSER').AsString := cdsClone.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsClone.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsClone.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString := cdsClone.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString := cdsClone.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString := cdsClone.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString := cdsClone.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString := cdsClone.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString := cdsClone.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsClone.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsClone.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString := cdsClone.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString := cdsClone.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString := cdsClone.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString := cdsClone.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString := cdsClone.FieldByName('MODULO').AsString;
            cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
            iOrden := iOrden + 1;
            FoaConta.cdsPost(cdsMovCNT);

          //SI LA CUENTA ORIGES ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
            If cdsClone.FieldByName('CNTDH').AsString = 'D' Then
            Begin
               sDeHa := 'H';
               dDebeMN := 0;
               dDebeME := 0;
               dHabeMN := cdsClone.FieldByName('CNTMTOLOC').AsFloat;
               dHabeME := cdsClone.FieldByName('CNTMTOEXT').AsFloat;
            End
            Else
            Begin
               sDeHa := 'D';
               dDebeMN := cdsClone.FieldByName('CNTMTOLOC').AsFloat;
               dDebeME := cdsClone.FieldByName('CNTMTOEXT').AsFloat;
               dHabeMN := 0;
               dHabeME := 0;
            End;

            xSQL := 'Select CTA_AUX, CTA_CCOS from TGE202 '
               + 'Where CIAID=' + quotedstr(xCia)
               + ' and CUENTAID=' + quotedstr(cdsClone.FieldByName('CTAAUT2').AsString);
            cdsQry_C.Close;
            cdsQry_C.DataRequest(xSQL);
            cdsQry_C.Open;

            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString := cdsClone.FieldByName('CIAID').AsString;
            cdsMovCNT.FieldByName('TDIARID').AsString := cdsClone.FieldByName('TDIARID').AsString;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString := cdsClone.FieldByName('CNTCOMPROB').AsString;
            cdsMovCNT.FieldByName('CNTANOMM').AsString := cdsClone.FieldByName('CNTANOMM').AsString;
            cdsMovCNT.FieldByName('CUENTAID').AsString := cdsClone.FieldByName('CTAAUT2').AsString;
            cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsClone.FieldByName('CNTLOTE').AsString;

            If cdsQry_C.FieldByName('CTA_AUX').AsString = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CLAUXID').AsString := cdsClone.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString := cdsClone.FieldByName('AUXID').AsString;
               cdsMovCNT.FieldByName('AUXDES').AsString := cdsClone.FieldByName('AUXDES').AsString;
            End
            Else
            Begin
               cdsMovCNT.FieldByName('CLAUXID').Clear;
               cdsMovCNT.FieldByName('AUXID').Clear;
               cdsMovCNT.FieldByName('AUXDES').Clear;
            End;

            If cdsQry_C.FieldByName('CTA_CCOS').AsString = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CCOSID').AsString := cdsClone.FieldByName('CCOSID').AsString;
               cdsMovCNT.FieldByName('CCOSDES').AsString := cdsClone.FieldByName('CCOSDES').AsString;
            End
            Else
            Begin
               cdsMovCNT.FieldByName('CCOSID').Clear;
               cdsMovCNT.FieldByName('CCOSDES').Clear;
            End;

            cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsClone.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString := cdsClone.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsClone.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsClone.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsClone.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsClone.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsClone.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsClone.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsClone.FieldByName('CNTMTOEXT').AsString;
            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsClone.FieldByName('CNTFEMIS').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsClone.FieldByName('CNTFVCMTO').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsClone.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
         // Inicio : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
         // Fin : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTUSER').AsString := cdsClone.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsClone.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsClone.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString := cdsClone.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString := cdsClone.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString := cdsClone.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString := cdsClone.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString := cdsClone.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString := cdsClone.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsClone.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsClone.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString := cdsClone.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString := cdsClone.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString := cdsClone.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString := cdsClone.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString := cdsClone.FieldByName('MODULO').AsString;
            cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
            iOrden := iOrden + 1;
            FoaConta.cdsPost(cdsMovCNT);

            FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');
         End;

         cdsClone.Next;
      End;
      //
      FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');
   End; // si copy(xAnoMM,5,2)<>'13'
   //
   // CUADRA ASIENTO
   xTotDebeMN := 0;
   xTotHaberMN := 0;
   xTotDebeME := 0;
   xTotHaberME := 0;
   cdsMovCnt.First;
   While Not cdsMovCnt.eof Do
   Begin
      If cdsMovCnt.FieldByName('CNTDH').AsString = 'D' Then
      Begin
         xTotDebeMN := xTotDebeMN + cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
         xTotDebeME := xTotDebeME + cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
      End
      Else
      Begin
         xTotHaberMN := xTotHaberMN + cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
         xTotHaberME := xTotHaberME + cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
      End;
      cdsMovCnt.Next;
   End;

   xDif := 0;

   If cdsMovCnt.FieldByName('TMONID').AsString = wTMonExt_C Then
   Begin
      If FoaConta.FRound(xTotHaberMN, 15, 2) <> FoaConta.FRound(xTotDebeMN, 15, 2) Then
      Begin
         If FoaConta.fround(xTotHaberMN, 15, 2) > FoaConta.fround(xTotDebeMN, 15, 2) Then
         Begin
            xDIf := FoaConta.fround(FoaConta.fround(xTotHaberMN, 15, 2) - FoaConta.fround(xTotDebeMN, 15, 2), 15, 2);
            cdsMovCnt.First;
            While Not cdsMovCnt.eof Do
            Begin
               If cdsMovCnt.FieldByName('CNTDH').AsString = 'D' Then
               Begin
                  cdsMovCnt.Edit;
                  cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat := FoaConta.FRound(cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat + xDif, 15, 2);
                  cdsMovCnt.FieldByName('CNTDEBEMN').AsFloat := cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
                  cdsMovCnt.Post;
                  Break;
               End;
               cdsMovCnt.Next;
            End;
         End
         Else
         Begin
            xDIf := FoaConta.Fround(FoaConta.fround(xTotDebeMN, 15, 2) - FoaConta.fround(xTotHaberMN, 15, 2), 15, 2);
            cdsMovCnt.First;
            While Not cdsMovCnt.eof Do
            Begin
               If cdsMovCnt.FieldByName('CNTDH').AsString = 'H' Then
               Begin
                  cdsMovCnt.Edit;
                  cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat := FoaConta.FRound(cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat + xDif, 15, 2);
                  cdsMovCnt.FieldByName('CNTHABEMN').AsFloat := cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
                  cdsMovCnt.Post;
                  Break;
               End;
               cdsMovCnt.Next;
            End;
         End

      End;
   End
   Else
   Begin
      If FoaConta.fround(xTotHaberME, 15, 2) <> FoaConta.fround(xTotDebeME, 15, 2) Then
      Begin
         If FoaConta.fround(xTotHaberME, 15, 2) > FoaConta.fround(xTotDebeME, 15, 2) Then
         Begin
            xDIf := FoaConta.fround(FoaConta.fround(xTotHaberME, 15, 2) - FoaConta.fround(xTotDebeME, 15, 2), 15, 2);
            cdsMovCnt.First;
            While Not cdsMovCnt.eof Do
            Begin
               If cdsMovCnt.FieldByName('CNTDH').AsString = 'D' Then
               Begin
                  cdsMovCnt.Edit;
                  cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat := FoaConta.FRound(cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat + xDif, 15, 2);
                  cdsMovCnt.FieldByName('CNTDEBEME').AsFloat := cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
                  cdsMovCnt.Post;
                  Break;
               End;
               cdsMovCnt.Next;
            End;
         End
         Else
         Begin
            xDIf := FoaConta.fround(FoaConta.fround(xTotDebeME, 15, 2) - FoaConta.fround(xTotHaberME, 15, 2), 15, 2);
            cdsMovCnt.First;
            While Not cdsMovCnt.eof Do
            Begin
               If cdsMovCnt.FieldByName('CNTDH').AsString = 'H' Then
               Begin
                  cdsMovCnt.Edit;
                  cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat := FoaConta.FRound(cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat + xDif, 15, 2);
                  cdsMovCnt.FieldByName('CNTHABEME').AsFloat := cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
                  cdsMovCnt.Post;
                  Break;
               End;
               cdsMovCnt.Next;
            End;
         End
      End;
   End;

   FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');
   cdsMovCnt.First;
   cdsMovCnt.EnableControls;
   // FIN CUADRA ASIENTO
   //

   Result := False;
   cdsMovCNT.EnableControls;

   If (xTipoC = 'C') Or (xTipoC = 'CCNA') Then
   Begin

      xSQL := 'Insert into CNT301 ('
            + ' CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
            + 'CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
            + 'CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
            + 'CNTFEMIS, CNTFVCMTO, CNTFCOMP, CNTESTADO, CNTCUADRE, CNTFAUTOM, '
            + 'CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
            + 'CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
            + 'TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
            + 'CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
            + 'CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
            + 'CNTMODDOC, CNTREG, MODULO, CTA_SECU ) '
            + 'Select CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
            + 'CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
            + 'CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
            + 'CNTFEMIS, CNTFVCMTO, CNTFCOMP, ''P'', ''S'', CNTFAUTOM, '
            + 'CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
            + 'CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
            + 'TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
            + 'CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
            + 'CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
            + 'CNTMODDOC, CNTREG, MODULO, CTA_SECU '
            + 'From CNT311 Where '
            + 'CIAID=' + '''' + xCia + '''' + ' AND '
            + 'TDIARID=' + '''' + xTDiario + '''' + ' AND '
            + 'CNTANOMM=' + '''' + xAnoMM + '''' + ' AND '
            + 'CNTCOMPROB=' + '''' + xNoComp + '''';
      Try
         cdsQry_C.Close;
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Execute;
      Except
         Errorcount2 := 1;
         Exit;
      End;

   End;

   // Genera Cabecera si Modulo no es Contabilidad

// Inicio HPC_201401_CNT
// El cdsClone se utiliza para generar cuentas automáticas
// y para generar cabecera de <<módulos diferentes de CNT>> o <<Módulo CNT+LOTE=AJDE>>
   If copy(xAnoMM, 5, 2) <> '13' Then
   Begin

      xxModulo := cdsClone.FieldByName('MODULO').AsString;

      cdsClone.First;
      If (cdsClone.FieldByName('MODULO').AsString <> 'CNT') Or
         ((cdsClone.FieldByName('MODULO').AsString = 'CNT') And
         (cdsClone.FieldByName('CNTLOTE').AsString = 'AJDE')) Then
      Begin

         xSQL := 'SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB ';
         xSQL := xSQL + 'FROM ' + CNTCab + ' A ';
         xSQL := xSQL + 'WHERE A.CIAID=' + '''' + xCia + '''' + ' and ';
         xSQL := xSQL + 'A.TDIARID=' + '''' + xTDiario + '''' + ' and ';
         xSQL := xSQL + 'A.CNTANOMM=' + '''' + xAnoMM + '''' + ' and ';
         xSQL := xSQL + 'A.CNTCOMPROB=' + '''' + xNoComp + '''' + ' ';

         cdsQry_C.Close;
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Open;

         If cdsQry_C.RecordCount <= 0 Then
         Begin
            If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
            Begin
               //xSQL:='INSERT INTO CNT300 ';
               xSQL := 'INSERT INTO ' + CNTCab;
               xSQL := xSQL + '( CIAID, TDIARID, CNTANOMM, CNTCOMPROB, CNTLOTE, ';
               xSQL := xSQL + 'CNTGLOSA, CNTTCAMBIO, CNTFCOMP, CNTESTADO, CNTCUADRE, ';
               xSQL := xSQL + 'CNTUSER, CNTFREG, CNTHREG, CNTANO, CNTMM, CNTDD, CNTTRI, ';
               xSQL := xSQL + 'CNTSEM, CNTSS, CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, ';
               xSQL := xSQL + 'TDIARDES, CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, ';
               xSQL := xSQL + 'CNTTS, DOCMOD, MODULO ) ';

               xSQL := xSQL + 'SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB,  A.CNTLOTE, ';
               //xSQL:=xSQL+ 'CASE WHEN MIN(A.CNTREG) = 1 THEN MAX( A.CNTGLOSA ) ELSE  ''COMPROBANTE DE ''||MAX(MODULO) END, ';
               xSQL := xSQL + 'MAX( CASE WHEN A.CNTREG = 1 THEN A.CNTGLOSA END ) CNTGLOSA, ';
               xSQL := xSQL + 'MAX( COALESCE(A.CNTTCAMBIO, 0 )), ';
               xSQL := xSQL + 'A.CNTFCOMP, ''P'', ''S'', ';
               xSQL := xSQL + 'MAX(CNTUSER), MAX( CNTFREG ), MAX( CNTHREG ), A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI, ';
               xSQL := xSQL + 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
               xSQL := xSQL + 'MAX( CASE WHEN A.CNTREG = 1 THEN A.TMONID  END ) TMONID, '' '', ';
               xSQL := xSQL + 'A.TDIARDES, ';
               xSQL := xSQL + 'SUM(A.CNTDEBEMN), SUM(A.CNTDEBEME), SUM(A.CNTHABEMN), SUM(A.CNTHABEME), ';
               xSQL := xSQL + 'MAX( CNTTS ), MAX( CNTMODDOC), MAX( MODULO ) ';
               xSQL := xSQL + 'FROM ' + CNTDet + ' A ';
               xSQL := xSQL + 'WHERE A.CIAID=' + '''' + xCia + '''' + ' AND ';
               xSQL := xSQL + 'A.TDIARID=' + '''' + xTDiario + '''' + ' AND ';
               xSQL := xSQL + 'A.CNTANOMM=' + '''' + xAnoMM + ''' ';
               xSQL := xSQL + 'AND A.CNTCOMPROB=' + '''' + xNoComp + '''' + ' ';
               xSQL := xSQL + 'GROUP BY A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB, A.CNTLOTE, ';
               xSQL := xSQL + 'A.CNTFCOMP, A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI,  ';
               xSQL := xSQL + 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
               xSQL := xSQL + 'A.TDIARDES';
            End;

            If SRV_C = 'ORACLE' Then
            Begin
               xSQL := 'INSERT INTO ' + CNTCab;
               xSQL := xSQL + '( CIAID, TDIARID, CNTANOMM, CNTCOMPROB, CNTLOTE, ';
               xSQL := xSQL + 'CNTGLOSA, CNTTCAMBIO, CNTFCOMP, CNTESTADO, CNTCUADRE, ';
               xSQL := xSQL + 'CNTUSER, CNTFREG, CNTHREG, CNTANO, CNTMM, CNTDD, CNTTRI, ';
               xSQL := xSQL + 'CNTSEM, CNTSS, CNTAATRI, CNTAASEM, CNTAASS, TMONID, ';
               xSQL := xSQL + 'FLAGVAR, TDIARDES, CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, ';
               xSQL := xSQL + 'CNTTS, DOCMOD, MODULO ) ';
               xSQL := xSQL + 'SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB,  A.CNTLOTE, ';
               xSQL := xSQL + 'DECODE( MIN(A.CNTREG), 1, MAX( A.CNTGLOSA ), ''COMPROBANTE DE ''||MAX(MODULO) ), ';
               xSQL := xSQL + 'MAX( NVL( A.CNTTCAMBIO, 0 ) ), ';
               xSQL := xSQL + 'A.CNTFCOMP, ''P'', ''S'', ';
               xSQL := xSQL + 'MAX( CNTUSER ), MAX( CNTFREG ), MAX( CNTHREG ), A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI, ';
               xSQL := xSQL + 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
               xSQL := xSQL + 'CASE WHEN SUM( CASE WHEN TMONID=''' + wTMonExt_C + ''' THEN 1 ELSE 0 END )>'
                  + ' SUM( CASE WHEN TMONID=''' + wTMonLoc_C + ''' THEN 1 ELSE 0 END ) '
                  + ' THEN ''' + wTMonExt_C + ''' ELSE ''' + wTMonLoc_C + ''' END, ';
               xSQL := xSQL + ''' '', A.TDIARDES, ';
               xSQL := xSQL + 'SUM(A.CNTDEBEMN), SUM(A.CNTDEBEME), SUM(A.CNTHABEMN), SUM(A.CNTHABEME), ';
               xSQL := xSQL + 'MAX( CNTTS ), MAX( CNTMODDOC), MAX( MODULO ) ';
               xSQL := xSQL + 'FROM ' + CNTDet + ' A ';
               xSQL := xSQL + 'WHERE A.CIAID=' + '''' + xCia + '''' + ' AND ';
               xSQL := xSQL + 'A.TDIARID=' + '''' + xTDiario + '''' + ' AND ';
               xSQL := xSQL + 'A.CNTANOMM=' + '''' + xAnoMM + ''' ';
               xSQL := xSQL + 'AND A.CNTCOMPROB=' + '''' + xNoComp + '''' + ' ';
               xSQL := xSQL + 'GROUP BY A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB, A.CNTLOTE, ';
               xSQL := xSQL + 'A.CNTFCOMP, A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI,  ';
               xSQL := xSQL + 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
               xSQL := xSQL + 'A.TDIARDES';
            End;

            Try
               cdsQry_C.Close;
               cdsQry_C.DataRequest(xSQL);
               cdsQry_C.Execute;
            Except
               Errorcount2 := 1;
               Exit;
            End;
         End;
      End;

      cdsClone.Close;
      cdsClone.Free;

   End;
// Fin HPC_201401_CNT


   If (xTipoC = 'C') Or (xTipoC = 'CCNA') Then
      FoaConta.GeneraEnLinea401(xCia, xTDiario, xAnoMM, xNoComp, 'S');

   pnlConta_C.Free;

   If (xTipoC = 'C') Or (xTipoC = 'P') Or (xTipoC = 'CCNA') Or (xTipoC = 'PCNA') Then
   Begin

      xsql := 'SELECT A.*, B.CIADES FROM CNT311 A, TGE101 B '
            + 'WHERE ( A.CIAID=' + quotedstr(xCia) + ' AND '
            + 'A.CNTANOMM=' + quotedstr(xAnoMM) + ' AND '
            + 'A.TDIARID=' + quotedstr(xTDiario) + ' AND '
            + 'A.CNTCOMPROB=' + quotedstr(xNoComp) + ' AND '
            + 'A.CIAID=B.CIAID ) '
            + xSQLAdicional2 + ' '
            + 'ORDER BY A.CIAID, A.CNTANOMM, A.TDIARID, A.CNTREG';

      Try
         cdsMovCNT.IndexFieldNames := '';
         cdsMovCNT.Filter := '';
         cdsMovCNT.Filtered := True;
         cdsMovCNT.Close;
         cdsMovCNT.DataRequest(xSQL);
         cdsMovCNT.Open;
      Except
         Errorcount2 := 1;
         Exit;
      End;
      //end;

      xSQL := 'Delete From CNT311 A '
            + 'Where ( A.CIAID=' + '''' + xCia + '''' + ' AND '
            + 'A.TDIARID=' + '''' + xTDiario + '''' + ' AND '
            + 'A.CNTANOMM=' + '''' + xAnoMM + '''' + ' AND '
            + 'A.CNTCOMPROB=' + '''' + xNoComp + ''' ) '
            + xSQLAdicional + ' ';
      Try
         cdsQry_C.Close;
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Execute;
      Except
         Errorcount2 := 1;
         Exit;
      End;

      If xxModulo <> 'CNT' Then
      Begin
         xSQL := 'Delete From CNT310 '
               + 'Where '
               + 'CIAID=' + '''' + xCia + '''' + ' AND '
               + 'TDIARID=' + '''' + xTDiario + '''' + ' AND '
               + 'CNTANOMM=' + '''' + xAnoMM + '''' + ' AND '
               + 'CNTCOMPROB=' + '''' + xNoComp + '''';
         Try
            cdsQry_C.Close;
            cdsQry_C.DataRequest(xSQL);
            cdsQry_C.Execute;
         Except
         End;
      End;
   End;

   FoaConta.CerrarTablas;

   If Errorcount2 > 0 Then Exit;

   Result := True;
End;

Procedure TFoaConta.CerrarTablas;
Begin
   cdsNivel_C.Filtered := False;
   cdsNivel_C.Filter := '';
   cdsNivel_C := Nil;
   cdsQry_C.Close;
   cdsQry_C.Free;
End;

Procedure TFoaConta.GeneraEnLinea401(xxxCia, xxxDiario, xxxAnoMM, xxxNoComp, xSuma: String);
Var
   xCtaPrin, xClAux, xCuenta, xAuxDes, xAno, xMes, xDH, xSQL, xSQLn: String;
   xMov, xAux, xCCos, xCCoDes, xCtaDes, xFLAux, xFLCCo, xNivel, xNREG: String;
   xDigitos, xDigAnt, xNumT: Integer;
   xImpMN, xImpME: Double;
   cdsMovCNT2: TwwClientDataSet;
   cdsQry2x: TwwClientDataSet;
   cdsTge202x: TwwClientDataSet;
   cdsTge202xxx: TwwClientDataSet;
   cAno, cMes, cMesA, flDolar: String;
Begin
   xAno := Copy(xxxAnoMM, 1, 4);
   xMes := Copy(xxxAnoMM, 5, 2);

   FoaConta.PanelMsg('Actualizando Saldos...', 0);

   cdsQry2x := TwwClientDataSet.Create(Nil);
   cdsQry2x.RemoteServer := DCOM_C;
   cdsQry2x.ProviderName := Provider_C;

   xSQL := 'Select CNTSOLODOLAR from TGE101 Where CIAID=' + quotedstr(xxxCia);
   cdsQry2x.Close;
   cdsQry2x.DataRequest(xSQL); // Llamada remota al provider del servidor
   cdsQry2x.Open;

   flDolar := cdsQry2x.FieldByname('CNTSOLODOLAR').AsString;
   // VHNDEMA
   //xSQL:='Select A.CUENTAID, A.CNTDH, SUM( A.CNTMTOLOC ) CNTMTOLOC, SUM( A.CNTMTOEXT ) CNTMTOEXT '
   xSQL := 'Select A.CUENTAID, A.CNTDH, A.TMONID, CTA_ME, SUM( A.CNTMTOLOC ) CNTMTOLOC, SUM( A.CNTMTOEXT ) CNTMTOEXT '
   // END VHNDEMA
         + 'From ' + CNTDet + ' A, TGE202 B '
         + 'Where A.CIAID=' + '''' + xxxCia + '''' + ' AND '
         + 'A.CNTANOMM=' + '''' + xxxAnoMM + '''';

   If xTipoC_C = 'MC' Then
   Begin
      If xxxNoComp <> '' Then
         xSQL := xSQL + ' and A.CUENTAID=' + '''' + xxxNoComp + ''' ';

      If xxxNoComp = '' Then // Si es Mayorización Mensual
         xSQL := xSQL + ' and CNTESTADO=''P'' AND CNTCUADRE=''S'' ';

      // vhn 01/08/2002
      // Buscar El Nivel de la Cuenta y Filtrar el CDS de Nivel
      xSQLn := 'Select CNT202.*, LENGTH( ''' + xxxNoComp + ''' ) FROM CNT202 '
         + 'Where DIGITOS=LENGTH( ''' + xxxNoComp + ''' ) ';

      cdsQry2x.Close;
      cdsQry2x.DataRequest(xSQLn); // Llamada remota al provider del servidor
      cdsQry2x.Open;
      cdsNivel_C.Filtered := False;
      cdsNivel_C.Filter := '';
      cdsNivel_C.Filter := 'NIVEL=''' + cdsQry2x.FieldByName('NIVEL').AsString + '''';
      cdsNivel_C.Filtered := True;

   End
   Else
   Begin
      If xTipoC_C = 'MCACC' Then
      Begin // Solo Mayoriza Cuentas con Auxiliar y C.Costo
         xSQL := xSQL + ' and A.TDIARID=''XX'' ';
         xSQL := xSQL + ' and A.CNTCOMPROB=''ZZZZZZZZZZ'' ';
         xSQL := xSQL + ' and CNTESTADO=''P'' AND CNTCUADRE=''S'' ';
      End
      Else
      Begin
         If xxxDiario <> '' Then
            xSQL := xSQL + ' and A.TDIARID=' + '''' + xxxDiario + ''' ';

         If xxxNoComp <> '' Then
            xSQL := xSQL + ' and A.CNTCOMPROB=' + '''' + xxxNoComp + ''' ';

         If xxxNoComp = '' Then // Si es Mayorización Mensual
            xSQL := xSQL + ' and CNTESTADO=''P'' AND CNTCUADRE=''S'' ';
      End;
   End;

   xSQL := xSQL + ' AND A.CIAID=B.CIAID(+) AND A.CUENTAID=B.CUENTAID(+) ';

   xSQL := xSQL + 'Group by A.CUENTAID, A.CNTDH, A.TMONID, CTA_ME';

   cdsMovCNT2 := TwwClientDataSet.Create(Nil);
   cdsMovCNT2.RemoteServer := DCOM_C;
   cdsMovCNT2.ProviderName := Provider_C;
   cdsMovCNT2.Close;
   cdsMovCNT2.DataRequest(xSQL);
   cdsMovCNT2.Open;
   {
   cdsTge202xxx:=TwwClientDataSet.Create(nil);
   cdsTge202xxx.RemoteServer:= DCOM_C;
   cdsTge202xxx.ProviderName:=Provider_C;
   xSQL:='Select CUENTAID, CTANIV, CTAABR, CTA_MOV, CTA_ME from TGE202 Where CIAID='+quotedstr(xxxCia);
   cdsTge202xxx.Close;
   cdsTge202xxx.DataRequest( xSQL );
   cdsTge202xxx.Open;
   cdsTge202xxx.IndexFieldNames:='CUENTAID';
   }

   cdsTge202x := TwwClientDataSet.Create(Nil);
   cdsTge202x.RemoteServer := DCOM_C;
   cdsTge202x.ProviderName := Provider_C;
   xSQL := 'Select CUENTAID, CTANIV, CTAABR, CTA_MOV, CTA_ME from TGE202 Where CIAID=' + quotedstr(xxxCia);
   cdsTge202x.Close;
   cdsTge202x.DataRequest(xSQL);
   cdsTge202x.Open;
   cdsTge202x.IndexFieldNames := 'CUENTAID;CTANIV';

   FoaConta.PanelMsg('Actualizando Saldos - Cuentas ...', 0);

   cdsMovCNT2.First;
   While Not cdsMovCNT2.Eof Do
   Begin

      xCtaPrin := cdsMovCNT2.FieldByName('CUENTAID').AsString;
      xDH := cdsMovCNT2.FieldByName('CNTDH').AsString;
      xImpMN := FRound(cdsMovCNT2.FieldByName('CNTMTOLOC').AsFloat, 15, 2);
      xImpME := FRound(cdsMovCNT2.FieldByName('CNTMTOEXT').AsFloat, 15, 2);

      // si es Descontabilización
      If xSuma = 'N' Then
      Begin
         xImpMN := xImpMN * (-1);
         xImpME := xImpME * (-1);
      End;

      ////////////////////////////////////////////////////////////////
      //  Si Compañía Tiene Flag de Contabilizar Solamente Dolares  //
      ////////////////////////////////////////////////////////////////
      If flDolar = 'S' Then
      Begin

         {
         xSQL:='Select CTA_MOV, CTA_ME from TGE202 '
              +'Where CIAID='   +quotedstr(xxxCia )
              + ' and CUENTAID='+quotedstr(xCtaPrin );
         cdsQry2x.Close;
         cdsQry2x.DataRequest(xSQL); // Llamada remota al provider del servidor
         cdsQry2x.Open;
         }
         {
         cdsTge202xxx.SetKey;
         cdsTge202xxx.FieldbyName('CUENTAID').AsString:=xCtaPrin;
         cdsTge202xxx.GotoKey;

         // VHNDEMA
         // CUANDO LA CUENTA ES EN DOLARES:
         //if cdsQry2x.FieldByName('CTA_ME').AsString='S' then
         if ( cdsTge202xxx.FieldByName('CTA_ME').AsString='S' ) and
            ( cdsMovCNT2.FieldByName('TMONID').AsString='D' ) then
            // 1. MOVIMIENTO ES EN DOLARES
         else begin
            // 2. MOVIMIENTO ES EN SOLES
            xImpME:=0;
         }

         If (cdsMovCNT2.FieldByName('CTA_ME').AsString = 'S') And
            (cdsMovCNT2.FieldByName('TMONID').AsString = 'D') Then
            // 1. MOVIMIENTO ES EN DOLARES
         Else
         Begin
            // 2. MOVIMIENTO ES EN SOLES
            xImpME := 0;

         End;

      End;

      xDigAnt := 0;
      cdsNivel_C.First;
      While Not cdsNivel_C.EOF Do
      Begin

         xDigitos := cdsNivel_C.fieldbyName('Digitos').AsInteger;
         xCuenta := Trim(Copy(xCtaPrin, 1, xDigitos));
         xNivel := cdsNivel_C.fieldbyName('Nivel').AsString;

         xCtaDes := '';
         xMov := '';
         {
         xSQL:='Select CTAABR, CTA_MOV, CTA_ME from TGE202 '
              +'Where CIAID='+quotedstr(xxxCia)
              +' and CUENTAID='+quotedstr(xCuenta)
              +' AND CTANIV='+quotedstr(xNivel);
         cdsTge202x.Close;
         cdsTge202x.DataRequest(xSQL); // Llamada remota al provider del servidor
         cdsTge202x.Open;
         }
         cdsTge202x.SetKey;
         cdsTge202x.FieldbyName('CUENTAID').AsString := xCuenta;
         cdsTge202x.FieldbyName('CTANIV').AsString := xNivel;
         cdsTge202x.GotoKey;

         xCtaDes := cdsTge202x.FieldByName('CTAABR').AsString;
         xMov := cdsTge202x.FieldByName('CTA_MOV').AsString;

         If Trim(cdsNivel_C.fieldbyName('Signo').AsString) = '=' Then
            If Length(xCuenta) = xDigitos Then
            Else
               Break;
         If cdsNivel_C.fieldbyName('Signo').AsString = '<=' Then
            If (Length(xCuenta) <= xDigitos) And (Length(xCuenta) > xDigAnt) Then
            Else
               Break;
         If cdsNivel_C.fieldbyName('Signo').AsString = '>=' Then
            If Length(xCuenta) >= xDigitos Then
            Else
               Break;

         If Not FoaConta.CuentaExiste(xxxCia, xAno, xCuenta, '', '', '') Then
         Begin
            FoaConta.InsertaMov(xxxCia, xxxAnoMM, xCuenta, '', '', '', xDH, xMov,
               xCtaDes, '', '', xNivel, '1', xImpMN, xImpME);
            If Errorcount2 > 0 Then Exit;
         End
         Else
         Begin
            FoaConta.ActualizaMov(xxxCia, xxxAnoMM, xCuenta, '', '', '', xDH, xMov,
               xCtaDes, '', '', xNivel, '1', xImpMN, xImpME);
            If Errorcount2 > 0 Then Exit;
         End;

         xDigAnt := cdsNivel_C.fieldbyName('Digitos').AsInteger;

         cdsNivel_C.Next;
      End;

      cdsMovCNT2.Next;
   End;

// VERIFICAR PARA QUE SOLO FILTRE LAS CUENTAS QUE TENGAN AUXILIAR Y C.COSTO

   xSQL := 'Select A.CUENTAID, A.CLAUXID, A.AUXID, A.AUXDES, A.CCOSID, A.CCOSDES, A.CNTDH, '
         + 'SUM( A.CNTMTOLOC ) CNTMTOLOC, SUM( A.CNTMTOEXT ) CNTMTOEXT, '
         + 'MAX(B.CTANIV) CTANIV, MAX(B.CTAABR) CTAABR, MAX(B.CTA_MOV) CTA_MOV, '
         + 'MAX(B.CTA_AUX) CTA_AUX, MAX(B.CTA_CCOS) CTA_CCOS, MAX(B.CTA_ME) CTA_ME '
         + 'From ' + CNTDet + ' A, TGE202 B '
         + 'Where A.CIAID=' + '''' + xxxCia + '''' + ' AND '
         + 'A.CNTANOMM=' + '''' + xxxAnoMM + '''';

   If xTipoC_C = 'MC' Then
   Begin
      If xxxNoComp <> '' Then
         xSQL := xSQL + ' and A.CUENTAID=' + '''' + xxxNoComp + ''' ';

      If xxxNoComp = '' Then // Si es Mayorización Mensual
         xSQL := xSQL + ' and CNTESTADO=''P'' AND CNTCUADRE=''S'' ';
   End
   Else
   Begin
      If xTipoC_C = 'MCACC' Then
      Begin // Solo Mayoriza Cuentas con Auxiliar y C.Costo
         If xxxDiario <> '' Then
            xSQL := xSQL + ' and A.TDIARID=' + '''' + xxxDiario + ''' ';

         If xxxNoComp <> '' Then
            xSQL := xSQL + ' and A.CNTCOMPROB=' + '''' + xxxNoComp + ''' ';

         If xxxNoComp = '' Then // Si es Mayorización Mensual
            xSQL := xSQL + ' and CNTESTADO=''P'' AND CNTCUADRE=''S'' ';
      End
      Else
      Begin
         If xxxDiario <> '' Then
            xSQL := xSQL + ' and A.TDIARID=' + '''' + xxxDiario + ''' ';

         If xxxNoComp <> '' Then
            xSQL := xSQL + ' and A.CNTCOMPROB=' + '''' + xxxNoComp + ''' ';

         If xxxNoComp = '' Then // Si es Mayorización Mensual
            xSQL := xSQL + ' and CNTESTADO=''P'' AND CNTCUADRE=''S'' ';
      End;
   End;

   xSQL := xSQL
         + 'and A.CIAID=B.CIAID AND A.CUENTAID=B.CUENTAID '
         + 'Group by A.CUENTAID, A.CLAUXID, A.AUXID, A.AUXDES, A.CCOSID, A.CCOSDES, A.CNTDH '
         + 'having MAX(CTA_AUX)=''S'' or MAX(CTA_CCOS)=''S''';

   cdsMovCNT2.Close;
   cdsMovCNT2.DataRequest(xSQL);
   cdsMovCNT2.Open;

   FoaConta.PanelMsg('Actualizando Saldos - Cuentas Auxiliar y C.Costo...', 0);

   cdsMovCNT2.First;
   While Not cdsMovCNT2.Eof Do
   Begin

//    PanelMsg( 'Generando Resultados', 0 );

      xCtaPrin := cdsMovCNT2.FieldByName('CUENTAID').AsString;
      xDH := cdsMovCNT2.FieldByName('CNTDH').AsString;
      xImpMN := FRound(cdsMovCNT2.FieldByName('CNTMTOLOC').AsFloat, 15, 2);
      xImpME := FRound(cdsMovCNT2.FieldByName('CNTMTOEXT').AsFloat, 15, 2);
      xClAux := cdsMovCNT2.FieldByName('CLAUXID').AsString;
      xAux := cdsMovCNT2.FieldByName('AUXID').AsString;
      xAuxDes := cdsMovCNT2.FieldByName('AUXDES').AsString;
      xCCos := cdsMovCNT2.FieldByName('CCOSID').AsString;
      xCCoDes := cdsMovCNT2.FieldByName('CCOSDES').AsString;
      xCuenta := cdsMovCNT2.FieldByName('CUENTAID').AsString;
      xCtaDes := cdsMovCNT2.FieldByName('CTAABR').AsString;
      xMov := cdsMovCNT2.FieldByName('CTA_MOV').AsString;
      xFlAux := cdsMovCNT2.FieldByName('CTA_AUX').AsString;
      xFlCCo := cdsMovCNT2.FieldByName('CTA_CCOS').AsString;

      If xSuma = 'N' Then
      Begin
         xImpMN := xImpMN * (-1);
         xImpME := xImpME * (-1);
      End;

      ////////////////////////////////////////////////////////////////
      //  Si Compañía Tiene Flag de Contabilizar Solamente Dolares  //
      ////////////////////////////////////////////////////////////////
      If flDolar = 'S' Then
      Begin
         {
         xSQL:='Select CTA_MOV, CTA_ME from TGE202 '
              +'Where CIAID='   +quotedstr(xxxCia )
              + ' and CUENTAID='+quotedstr(xCtaPrin );
         cdsQry2x.Close;
         cdsQry2x.DataRequest(xSQL); // Llamada remota al provider del servidor
         cdsQry2x.Open;}
         {
         cdsTge202xxx.SetKey;
         cdsTge202xxx.FieldbyName('CUENTAID').AsString:=xCtaPrin;
         cdsTge202xxx.GotoKey;
         if cdsTge202xxx.FieldByName('CTA_ME').AsString='S' then
         else begin
            xImpME:=0;
         end;
         }
         If cdsMovCNT2.FieldByName('CTA_ME').AsString = 'S' Then
         Else
         Begin
            xImpME := 0;
         End;

      End;

      ///////////////////////////
      //   Si Tiene Auxiliar   //
      ///////////////////////////
      If (xFlAux = 'S') And (xFlCCo = 'N') Then
      Begin

         If xAux = '' Then xAux := 'OTROS';

         If Not CuentaExiste(xxxCia, xAno, xCuenta, xClAux, xAux, '') Then
         Begin
            InsertaMov(xxxCia, xxxAnoMM, xCuenta, xClAux, xAux, '', xDH, xMov,
               xCtaDes, xAuxDes, '', xNivel, '2', xImpMN, xImpME);
            If Errorcount2 > 0 Then Exit;
         End
         Else
         Begin
            ActualizaMov(xxxCia, xxxAnoMM, xCuenta, xClAux, xAux, '', xDH, xMov,
               xCtaDes, xAuxDes, '', xNivel, '2', xImpMN, xImpME);
            If Errorcount2 > 0 Then Exit;
         End;
      End;

      ///////////////////////////
      //   Si Tiene C.Costo    //
      ///////////////////////////
      If (xFlCCo = 'S') And (xFlAux = 'N') Then
      Begin

         If xCCos = '' Then xCCos := 'OTROS';

         If Not CuentaExiste(xxxCia, xAno, xCuenta, '', '', xCCos) Then
         Begin
            InsertaMov(xxxCia, xxxAnoMM, xCuenta, '', '', xCCos, xDH, xMov,
               xCtaDes, xAuxDes, xCCoDes, xNivel, '3', xImpMN, xImpME);
            If Errorcount2 > 0 Then Exit;
         End
         Else
         Begin
            ActualizaMov(xxxCia, xxxAnoMM, xCuenta, '', '', xCCos, xDH, xMov,
               xCtaDes, xAuxDes, xCCoDes, xNivel, '3', xImpMN, xImpME);
            If Errorcount2 > 0 Then Exit;
         End;
      End;

       //** 2002/02/12 - PJSV
      ///////////////////////////
      //   Si Tiene aUXILIAR Y C.Costo    //
      ///////////////////////////
      If (xFlCCo = 'S') And (xFlAux = 'S') Then
      Begin

         If xAux = '' Then xAux := 'OTROS';
         If xCCos = '' Then xCCos := 'OTROS';

         If Not CuentaExiste(xxxCia, xAno, xCuenta, xClAux, xAux, xCCos) Then
         Begin
            InsertaMov(xxxCia, xxxAnoMM, xCuenta, xClAux, xAux, xCCos, xDH, xMov,
               xCtaDes, xAuxDes, xCCoDes, xNivel, '4', xImpMN, xImpME);
            If Errorcount2 > 0 Then Exit;
         End
         Else
         Begin
            ActualizaMov(xxxCia, xxxAnoMM, xCuenta, xClAux, xAux, xCCos, xDH, xMov,
               xCtaDes, xAuxDes, xCCoDes, xNivel, '4', xImpMN, xImpME);
            If Errorcount2 > 0 Then Exit;
         End;
      End;
      //**

      cdsMovCNT2.Next;
   End;

   // Cuando es Mayorización por Compañía y Periodo
   If xTipoC_C = 'MC' Then
   Begin

      cAno := Copy(xxxAnoMM, 1, 4);
      cMes := Copy(xxxAnoMM, 5, 2);
      If cMes = '00' Then
      Begin
         xSQL := 'Update CNT401 Set '
               + 'SALDMN' + cMes + '='
               + 'ROUND( ' + wReplaCeros + '( DEBEMN' + cMes + ',0)-' + wReplaCeros + '( HABEMN' + cMes + ',0),2 ) , '
               + 'SALDME' + cMes + '='
               + 'ROUND( ' + wReplaCeros + '( DEBEME' + cMes + ',0)-' + wReplaCeros + '( HABEME' + cMes + ',0),2 ) '
               + 'Where CIAID=''' + xxxCia + ''' and ANO=''' + cAno + ''' '
               + 'and CUENTAID=' + '''' + xxxNoComp + ''' ';
      End
      Else
      Begin
         cMesA := StrZero(IntToStr(StrToInt(Copy(xxxAnoMM, 5, 2)) - 1), 2);
         xSQL := 'Update CNT401 Set '
               + 'SALDMN' + cMes + '='
               + 'ROUND( ' + wReplaCeros + '(SALDMN' + cMesA + ',0)+' + wReplaCeros + '( DEBEMN' + cMes + ',0)-' + wReplaCeros + '( HABEMN' + cMes + ',0),2 ) , '
               + 'SALDME' + cMes + '='
               + 'ROUND( ' + wReplaCeros + '(SALDME' + cMesA + ',0)+' + wReplaCeros + '( DEBEME' + cMes + ',0)-' + wReplaCeros + '( HABEME' + cMes + ',0),2 ) '
               + 'Where CIAID=''' + xxxCia + ''' and ANO=''' + cAno + ''' '
               + 'and CUENTAID=' + '''' + xxxNoComp + ''' ';
      End;

      Try
         cdsQry_C.Close;
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Execute;
      Except
         Errorcount2 := 1;
         Exit;
      End;
   End
   Else
   Begin
      If xTipoC_C = 'MCACC' Then
      Begin // Solo Mayoriza Cuentas con Auxiliar y C.Costo
         cAno := Copy(xxxAnoMM, 1, 4);
         cMes := Copy(xxxAnoMM, 5, 2);
         If cMes = '00' Then
         Begin
            xSQL := 'Update CNT401 Set '
                  + 'SALDMN' + cMes + '='
                  + 'ROUND( ' + wReplaCeros + '( DEBEMN' + cMes + ',0)-' + wReplaCeros + '( HABEMN' + cMes + ',0),2 ) , '
                  + 'SALDME' + cMes + '='
                  + 'ROUND( ' + wReplaCeros + '( DEBEME' + cMes + ',0)-' + wReplaCeros + '( HABEME' + cMes + ',0),2 ) '
                  + 'Where CIAID=''' + xxxCia + ''' and ANO=''' + cAno + ''''
                  + ' and ( TIPREG=''2'' or TIPREG=''3'' or TIPREG=''4'' )';
         End
         Else
         Begin
            cMesA := StrZero(IntToStr(StrToInt(Copy(xxxAnoMM, 5, 2)) - 1), 2);
            xSQL := 'Update CNT401 Set '
                  + 'SALDMN' + cMes + '='
                  + 'ROUND( ' + wReplaCeros + '(SALDMN' + cMesA + ',0)+' + wReplaCeros + '( DEBEMN' + cMes + ',0)-' + wReplaCeros + '( HABEMN' + cMes + ',0),2 ) , '
                  + 'SALDME' + cMes + '='
                  + 'ROUND( ' + wReplaCeros + '(SALDME' + cMesA + ',0)+' + wReplaCeros + '( DEBEME' + cMes + ',0)-' + wReplaCeros + '( HABEME' + cMes + ',0),2 ) '
                  + 'Where CIAID=''' + xxxCia + ''' and ANO=''' + cAno + ''''
                  + ' and ( TIPREG=''2'' or TIPREG=''3'' or TIPREG=''4'' )';
         End;
         Try
            cdsQry_C.Close;
            cdsQry_C.DataRequest(xSQL);
            cdsQry_C.Execute;
         Except
            Errorcount2 := 1;
            Exit;
         End;
      End
      Else
      Begin
         If (xxxDiario = '') And (xxxNoComp = '') Then
         Begin
            cAno := Copy(xxxAnoMM, 1, 4);
            cMes := Copy(xxxAnoMM, 5, 2);
            If cMes = '00' Then
            Begin
               xSQL := 'Update CNT401 Set '
                     + 'SALDMN' + cMes + '='
                     + 'ROUND( ' + wReplaCeros + '( DEBEMN' + cMes + ',0)-' + wReplaCeros + '( HABEMN' + cMes + ',0),2 ) , '
                     + 'SALDME' + cMes + '='
                     + 'ROUND( ' + wReplaCeros + '( DEBEME' + cMes + ',0)-' + wReplaCeros + '( HABEME' + cMes + ',0),2 ) '
                     + 'Where CIAID=''' + xxxCia + ''' and ANO=''' + cAno + '''';
            End
            Else
            Begin
               cMesA := StrZero(IntToStr(StrToInt(Copy(xxxAnoMM, 5, 2)) - 1), 2);
               xSQL := 'Update CNT401 Set '
                     + 'SALDMN' + cMes + '='
                     + 'ROUND( ' + wReplaCeros + '(SALDMN' + cMesA + ',0)+' + wReplaCeros + '( DEBEMN' + cMes + ',0)-' + wReplaCeros + '( HABEMN' + cMes + ',0),2 ) , '
                     + 'SALDME' + cMes + '='
                     + 'ROUND( ' + wReplaCeros + '(SALDME' + cMesA + ',0)+' + wReplaCeros + '( DEBEME' + cMes + ',0)-' + wReplaCeros + '( HABEME' + cMes + ',0),2 ) '
                     + 'Where CIAID=''' + xxxCia + ''' and ANO=''' + cAno + '''';
            End;

            Try
               cdsQry_C.Close;
               cdsQry_C.DataRequest(xSQL);
               cdsQry_C.Execute;
            Except
               Errorcount2 := 1;
               Exit;
            End;
         End;
      End;
   End;
   FoaConta.PanelMsg('Final de Actualiza Saldos...', 0);

   cdsQry2x.IndexFieldNames := '';

   cdsNivel_C.Filtered := False;
   cdsNivel_C.Filter := '';
   cdsMovCNT2.Close;
   cdsMovCNT2.Free;
   cdsQry2x.Close;
   cdsQry2x.Free;
End;

Function TFoaConta.CuentaExiste(xCia1, xAno1, xCuenta1, xCLAux1, xAux1, xCCos1: String): Boolean;
Var
   xSQL: String;
   xClAuxid, xAuxid, xCCosid: String;
Begin
   xClAuxid := '';
   xAuxid := '';
   xCCosid := '';

   If xCLAux1 = '' Then
      xClAuxid := '( CLAUXID=' + quotedstr(xClAux1) + ' OR CLAUXID IS NULL ) AND '
   Else
      xClAuxid := 'CLAUXID=' + quotedstr(xClAux1) + ' AND ';

   If xAux1 = '' Then
      xAuxid := '( AUXID=' + quotedstr(xAux1) + ' OR AUXID IS NULL ) AND '
   Else
      xAuxid := 'AUXID=' + quotedstr(xAux1) + ' AND ';

   If xCCos1 = '' Then
      xCcosid := '( CCOSID=' + quotedstr(xCCos1) + ' OR CCOSID IS NULL )'
   Else
      xCcosid := 'CCOSID=' + quotedstr(xCCos1);

   xSQL := 'Select COUNT(*) TOTREG from CNT401 '
         + 'Where CIAID=' + '''' + xCia1 + '''' + ' and '
         + 'ANO=' + '''' + xAno1 + '''' + ' and '
         + 'CUENTAID=' + '''' + xCuenta1 + '''' + ' and ';
   xSQL := xSQL + xClAuxId + xAuxid + xCCosid;

   cdsQry_C.Close;
   cdsQry_C.DataRequest(xSQL);
   cdsQry_C.Open;

   If cdsQry_C.fieldbyName('TOTREG').asInteger > 0 Then
      Result := True
   Else
      Result := False;
End;

Procedure TFoaConta.ActualizaMov(cCia, cAnoMM, cCuenta, cClAux, cAux, cCCosto, cDH, cMov,
   cCtaDes, cAuxDes, cCCoDes, cNivel, cTipReg: String;
   nImpMN, nImpME: double);
Var
   cMes, cAno, cSQL, cMesT, cMesA: String;
   nMes: Integer;
   xAuxid, xCcosid, xClauxid: String;
Begin

   cAno := Copy(cAnoMM, 1, 4);
   cMes := Copy(cAnoMM, 5, 2);

   cMesA := StrZero(IntToStr(StrToInt(cMes) - 1), 2);

   cSQL := 'Update CNT401 Set CTADES =' + '''' + cCtaDes + '''' + ', '
         + 'AUXDES =' + QuotedStr(cAuxDes) + ', '
         + 'CCODES =' + '''' + cCCoDes + '''' + ', '
         + 'TIPREG =' + '''' + cTipReg + '''' + ', ';

   If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
   Begin
      If cDH = 'D' Then
      Begin
         cSQL := cSQL + '  DEBEMN' + cMes + '=' +
            ' ' + wReplaCeros + '( DEBEMN' + cMes + ',0) + ' + FloatToStr(nImpMN) + ' ';
         cSQL := cSQL + ', DEBEME' + cMes + '=' +
            ' ' + wReplaCeros + '( DEBEME' + cMes + ',0) + ' + FloatToStr(nImpME) + ' ';
      End;
      If cDH = 'H' Then
      Begin
         cSQL := cSQL + '  HABEMN' + cMes + '=' +
            ' ' + wReplaCeros + '( HABEMN' + cMes + ',0) + ' + FloatToStr(nImpMN) + ' ';
         cSQL := cSQL + ', HABEME' + cMes + '=' +
            ' ' + wReplaCeros + '( HABEME' + cMes + ',0) + ' + FloatToStr(nImpME) + ' ';
      End;
   End
   Else
      If SRV_C = 'ORACLE' Then
      Begin
         If cDH = 'D' Then
         Begin
            cSQL := cSQL + '  DEBEMN' + cMes + '=' +
               'ROUND( ' + wReplaCeros + '( DEBEMN' + cMes + ',0)+ROUND(' + FloatToStr(nImpMN) + ',2 ),2 ) ';
            cSQL := cSQL + ', DEBEME' + cMes + '=' +
               'ROUND( ' + wReplaCeros + '( DEBEME' + cMes + ',0)+ROUND(' + FloatToStr(nImpME) + ',2 ),2 ) ';
         End;
         If cDH = 'H' Then
         Begin
            cSQL := cSQL + '  HABEMN' + cMes + '=' +
               'ROUND( ' + wReplaCeros + '( HABEMN' + cMes + ',0)+ROUND(' + FloatToStr(nImpMN) + ',2 ),2 ) ';
            cSQL := cSQL + ', HABEME' + cMes + '=' +
               'ROUND( ' + wReplaCeros + '( HABEME' + cMes + ',0)+ROUND(' + FloatToStr(nImpME) + ',2 ),2 ) ';
         End;
      End;

   cSQL := cSQL + ', SALDMN' + cMes + '=';

   If cMesA >= '00' Then
      cSQL := cSQL + '(' + wReplaCeros + '(SALDMN' + cMesA + ',0)+' + wReplaCeros + '( DEBEMN' + cMes + ',0)-' + wReplaCeros + '( HABEMN' + cMes + ',0)'
   Else
      cSQL := cSQL + '(' + wReplaCeros + '( DEBEMN' + cMes + ',0)-' + wReplaCeros + '( HABEMN' + cMes + ',0)';

   If cDH = 'D' Then
      cSQL := cSQL + '+'
   Else
      cSQL := cSQL + '-';
   cSQL := cSQL + '(' + FloatToStr(nImpMN) + ') ) ';

   cSQL := cSQL + ', SALDME' + cMes + '=';

   If cMesA >= '00' Then
      cSQL := cSQL + '(' + wReplaCeros + '(SALDME' + cMesA + ',0)+' + wReplaCeros + '( DEBEME' + cMes + ',0)-' + wReplaCeros + '( HABEME' + cMes + ',0)'
   Else
      cSQL := cSQL + '(' + wReplaCeros + '( DEBEME' + cMes + ',0)-' + wReplaCeros + '( HABEME' + cMes + ',0)';

   If cDH = 'D' Then
      cSQL := cSQL + '+'
   Else
      cSQL := cSQL + '-';
   cSQL := cSQL + '(' + FloatToStr(nImpME) + ') ) ';

   For nMes := (StrToInt(cMes) + 1) To 13 Do
   Begin
      cMesT := StrZero(IntToStr(nMes), 2);

      cSQL := cSQL + ', SALDMN' + cMesT + '=';
      cSQL := cSQL + '( ' + wReplaCeros + '(SALDMN' + cMesT + ',0)';
      If cDH = 'D' Then
         cSQL := cSQL + '+'
      Else
         cSQL := cSQL + '-';
      cSQL := cSQL + ' ( ' + FloatToStr(nImpMN) + ' ) ' + ' ) ';

      cSQL := cSQL + ', SALDME' + cMesT + '=';
      cSQL := cSQL + '( ' + wReplaCeros + '(SALDME' + cMesT + ',0)';
      If cDH = 'D' Then
         cSQL := cSQL + '+'
      Else
         cSQL := cSQL + '-';
      cSQL := cSQL + ' ( ' + FloatToStr(nImpME) + ' ) ' + ' ) ';

   End;

   If cAux = '' Then
      xAuxid := ' AND ( AUXID=' + quotedstr(cAux) + ' OR AUXID IS NULL ) '
   Else
      xAuxid := ' AND AUXID=' + quotedstr(cAux) + ' ';

   If cCCosto = '' Then
      xCcosid := ' AND ( CCOSID=' + quotedstr(cCCosto) + ' OR CCOSID IS NULL ) '
   Else
      xCcosid := ' AND CCOSID=' + quotedstr(cCCosto) + ' ';

   If cClAux = '' Then
      xClauxid := 'AND ( CLAUXID=' + quotedstr(cClAux) + ' OR CLAUXID IS NULL )'
   Else
      xClauxid := 'AND CLAUXID=' + quotedstr(cClAux);

   cSQL := cSQL + 'Where CIAID=   ' + '''' + cCia + '''' + ' and '
      + 'ANO=     ' + '''' + cAno + '''' + ' and '
      + 'CUENTAID=' + '''' + cCuenta + '''' + ' ';

   cSQL := cSQL + xClauxid + xAuxid + xCcosid;

   Try
      cdsQry_C.Close;
      cdsQry_C.DataRequest(cSQL);
      cdsQry_C.Execute;
   Except
      Errorcount2 := 1;
   End;
End;

Procedure TFoaConta.InsertaMov(cCia, cAnoMM, cCuenta, cClAux, cAux, cCCosto, cDH, cMov,
   cCtaDes, cAuxDes, cCCoDes, cNivel, cTipReg: String; nImpMN, nImpME: Double);
Var
   cMes, cAno, cSQL, cMesT: String;
   nMes: Integer;
   xCtaMov: String;
Begin
   cAno := Copy(cAnoMM, 1, 4);
   cMes := Copy(cAnoMM, 5, 2);

   cSQL := 'Insert into CNT401( CIAID, ANO, CUENTAID, CLAUXID, AUXID, '
         + ' CCOSID, CTADES, AUXDES, CCODES, TIPO ,CTA_MOV ';

   If cDH = 'D' Then cSQL := cSQL + ', DEBEMN' + cMes + ', DEBEME' + cMes;
   If cDH = 'H' Then cSQL := cSQL + ', HABEMN' + cMes + ', HABEME' + cMes;

   //** 13/08/2001 - pjsv, para que genere el saldo del mes del movimiento
   cSQL := cSQL + ', SALDMN' + cMes;
   cSQL := cSQL + ', SALDME' + cMes;
   //**

   For nMes := (StrToInt(cMes) + 1) To 13 Do
   Begin
      cMesT := StrZero(IntToStr(nMes), 2);
      cSQL := cSQL + ', SALDMN' + cMesT;
      cSQL := cSQL + ', SALDME' + cMesT;
   End;
   cSQL := cSQL + ', TIPREG ) ';
   cSQL := cSQL + 'Values( ' + '''' + cCia + '''' + ', ' + '''' + cAno + '''' + ', '
      + '''' + cCuenta + '''' + ', ' + '''' + cClAux + '''' + ', '
      + '''' + cAux + '''' + ', ' + '''' + cCCosto + '''' + ', '
      + '''' + cCtaDes + '''' + ', ' + QuotedStr(cAuxDes) + ', '
      + '''' + cCCoDes + '''' + ', ' + '''' + cNivel + '''' + ', '
      + quotedstr(cMov) + ','
      + FloatToStr(nImpMN) + ', '
      + FloatToStr(nImpME) + ' ';

   //** 13/08/2001 - psjv, para el monto del mes del movimiento
   If cDH = 'D' Then
      cSQL := cSQL + ', + ('
   Else
      cSQL := cSQL + ', - (';
   cSQL := cSQL + FloatToStr(nImpMN) + ') ';
   If cDH = 'D' Then
      cSQL := cSQL + ', + ('
   Else
      cSQL := cSQL + ', - (';
   cSQL := cSQL + FloatToStr(nImpME) + ') ';
   //**

   For nMes := (StrToInt(cMes) + 1) To 13 Do
   Begin
      cMesT := StrZero(IntToStr(nMes), 2);
      If cDH = 'D' Then
         cSQL := cSQL + ', + ('
      Else
         cSQL := cSQL + ', - (';
      cSQL := cSQL + FloatToStr(nImpMN) + ') ';
      If cDH = 'D' Then
         cSQL := cSQL + ', + ('
      Else
         cSQL := cSQL + ', - (';
      cSQL := cSQL + FloatToStr(nImpME) + ') ';
   End;

   cSQL := cSQL + ',''' + cTipReg + ''' ) ';

   Try
      cdsQry_C.Close;
      cdsQry_C.DataRequest(cSQL);
      cdsQry_C.Execute;
   Except
      Errorcount2 := 1;
   End;
End;

Function TFoaConta.StrZero(wNumero: String; wLargo: Integer): String;
Var
   i: integer;
   s: String;
Begin
   s := '';
   For i := 1 To wLargo Do
   Begin
      s := s + '0';
   End;
   s := s + trim(wNumero);
   result := copy(s, length(s) - (wLargo - 1), wLargo);
End;

Function TFoaConta.FRound(xReal: DOUBLE; xEnteros, xDecimal: Integer): DOUBLE;
Var
   xParteDec, xflgneg: String;
   xDec: Integer;
   xMultiplo10, xUltdec, xNReal, xPDec: Double;
Begin
   Result := 0;
   xflgneg := '0';

   If xReal < 0 Then
   Begin
      xflgneg := '1';
      xReal := xReal * -1;
   End;
   xreal := strtofloat(floattostr(xReal));

   If xReal = 0 Then exit;
// primer redondeo a un decimal + de lo indicado en los parámetros
   xDec := xDecimal + 1;
   If xDec = 0 Then xMultiplo10 := 1;
   If xDec = 1 Then xMultiplo10 := 10;
   If xDec = 2 Then xMultiplo10 := 100;
   If xDec = 3 Then xMultiplo10 := 1000;
   If xDec = 4 Then xMultiplo10 := 10000;
   If xDec = 5 Then xMultiplo10 := 100000;
   If xDec = 6 Then xMultiplo10 := 1000000;
   If xDec = 7 Then xMultiplo10 := 10000000;

   xNreal := strtofloat(floattostr(xReal * xMultiplo10));
   xPdec := int(strtofloat(floattostr(xReal))) * xMultiplo10;
   xPdec := xNReal - xPDec;

   xPDec := int(xPDec);
   xParteDec := floattostr(xPDec);
   If length(xParteDec) < xDec Then
      xParteDec := strZero(xParteDec, xDec);

   If length(xParteDec) >= xDec Then
      xultdec := strtofloat(copy(xParteDec, xDec, 1))
   Else
   Begin
      xUltDec := 0;
   End;
   xNReal := strtofloat(floattostr(xReal * xMultiplo10 / 10));
   xNReal := int(xNReal);
   If xultdec >= 5 Then xNReal := xNReal + 1;

   If xflgneg = '1' Then
   Begin
      Result := (xNReal / (xMultiplo10 / 10)) * -1;
   End
   Else
   Begin
      Result := xNReal / (xMultiplo10 / 10);
   End;
End;

Procedure TFoaConta.AplicaDatos(wCDS: TClientDataSet; wNomArch: String);
Var
   Delta, Results, OwnerData: OleVariant;
   ErrorCount_C: Integer;
Begin
   ErrorCount_C := 0;

   If (wcds.ChangeCount > 0) Or (wcds.Modified) Then
   Begin

{       if (SRV_C = 'DB2NT') then
          DCOM_C.AppServer.ParamDSPGraba('1', wNomArch);
}
      wCDS.CheckBrowseMode;

      Results := DCOM_C.AppServer.AS_ApplyUpdates(wCDS.ProviderName, wcds.Delta, -1,
         ErrorCount_C, OwnerData);
      cdsResultSet_C.Data := Results;
      wCDS.Reconcile(Results);
{
       if (SRV_C = 'DB2NT') then
          DCOM_C.AppServer.ParamDSPGraba('0', wNomArch);
}
   End;
End;

Procedure TFoaConta.CreaPanel(xForma: TForm; xMensaje: String);
Begin
   pnlConta_C := TPanel.Create(xForma);
   pbConta_C := TProgressBar.Create(Nil);
   pbConta_C.Width := 300;
   pbConta_C.Top := 72;
   pbConta_C.Left := 48;
   pbConta_C.Min := 0;
   pbConta_C.Max := 6;
   pbConta_C.Parent := pnlConta_c;
   pnlConta_C.Alignment := taCenter;
   pnlConta_C.BringToFront;
   pnlConta_C.Width := 400;
   pnlConta_C.Height := 100;
   pnlConta_C.Top := xForma.Height - 380;
   pnlConta_C.Left := strtoInt(FloattoStr(FRound((((xForma.Width - 100)) / 2) - 100, 3, 0)));
   pnlConta_C.Parent := xForma;
   pnlConta_C.BevelInner := bvRaised;
   pnlConta_C.BevelOuter := bvRaised;
   pnlConta_C.BevelWidth := 3;
   pnlConta_C.Font.Name := 'Times New Roman';
   pnlConta_C.Font.Style := [fsBold, fsItalic];
   pnlConta_C.Font.Size := 12;
   pnlConta_C.Caption := xMensaje;
   pbConta_C.Position := 0;
   pnlConta_C.Refresh;
End;

Procedure TFoaConta.PanelMsg(xMensaje: String; xProc: Integer);
Begin
   If xProc > 0 Then
   Begin
      pbConta_C.Position := 0;
      pbConta_C.Min := 0;
      pbConta_C.Max := xProc;
   End;
   pnlConta_C.Caption := xMensaje;
   If xProc = 0 Then pbConta_C.Position := pbConta_C.Position + 1;
   pnlConta_C.Refresh;
End;

Procedure TFoaConta.GeneraAsientoGlobal_N1(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
Var
   cdsQryT: TwwClientDataSet;
   xSQL, xWhere: String;
   xCtaCaja: String;
   sDeHa: String;
   dHabeMN, dHabeME, dDebeMN, dDebeME, nDifCam, nDifCam1, nDifCam2: Double;
   nReg: Integer;
Begin
   xCiaOri := xCia;

   //SI LA CUENTA ORIGEN ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
   dDebeMN := 0;
   dDebeME := 0;
   dHabeMN := 0;
   dHabeME := 0;

   If cdsQry_G.FieldByName('DEMTOLOC').AsFloat >= 0 Then
   Begin
      sDeHa := 'D';
      //dDebeMN:=cdsQry_G.FieldByName('DEMTOLOC').AsFloat;
      //dDebeME:=cdsQry_G.FieldByName('DEMTOEXT').AsFloat;
   End
   Else
   Begin
      sDeHa := 'H';
      //dHabeMN:=cdsQry_G.FieldByName('DEMTOLOC').AsFloat*(-1);
      //dHabeME:=cdsQry_G.FieldByName('DEMTOEXT').AsFloat*(-1);
   End;

   wMtoOri_C := wMtoOri_C + cdsQry_G.FieldByName('DEMTOORI').AsFloat;
   wMtoLoc_C := wMtoLoc_C + cdsQry_G.FieldByName('DEMTOLOC').AsFloat;
   wMtoExt_C := wMtoExt_C + cdsQry_G.FieldByName('DEMTOEXT').AsFloat;

   cdsMovCNT.Insert;
   cdsMovCNT.FieldByName('CIAID').AsString := xCiaOri;
   cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen2;
   cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp1;
   cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
   cdsMovCNT.FieldByName('CUENTAID').AsString := cdsQry_G.FieldByName('CUENTAID').AsString;
   cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_G.FieldByName('PROVDES').AsString;

   cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsCNT.FieldByName('CNTLOTE').AsString;
   cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_G.FieldByName('CLAUXID').AsString;
   cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_G.FieldByName('PROV').AsString;
   cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_G.FieldByName('CCOSID').AsString;
   cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsCNT.FieldByName('CNTMODDOC').AsString;
   cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_G.FieldByName('DOCID2').AsString;
   cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_G.FieldByName('CPSERIE').AsString;
   cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_G.FieldByName('CPNODOC').AsString;

   cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;

   If cdsCNT.FieldByName('TMONID').AsString = 'N' Then
   Begin
// Inicio HPC_201701_CAJA
   // cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_G.FieldByName('DETCPAG').AsString;
      cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_G.FieldByName('DETCDOC').AsString;
      cdsMovCNT.FieldByName('CNTMTOORI').AsFloat := Abs(cdsQry_G.FieldByName('DEMTOLOC').AsFloat);
      cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat := Abs(cdsQry_G.FieldByName('DEMTOLOC').AsFloat);
   // cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat := Abs(cdsQry_G.FieldByName('DEMTOEXT').AsFloat);
      cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat := FRound(Abs(cdsQry_G.FieldByName('DEMTOLOC').AsfLOAT) / cdsQry_G.FieldByName('DETCDOC').AsfLOAT, 15, 2);
// Fin HPC_201701_CAJA
      If sDeHa = 'D' Then
      Begin
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
      End
      Else
      Begin
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat;
      End;
   End
   Else
   Begin
      cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_G.FieldByName('DETCDOC').AsString;
      cdsMovCNT.FieldByName('CNTMTOORI').AsFloat := Abs(cdsQry_G.FieldByName('DEMTOEXT').AsFloat);
      cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT := FRound(Abs(cdsQry_G.FieldByName('DEMTOEXT').AsfLOAT) * cdsQry_G.FieldByName('DETCDOC').AsfLOAT, 15, 2);

      cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat := Abs(cdsQry_G.FieldByName('DEMTOEXT').Asfloat);
      If sDeHa = 'D' Then
      Begin
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
      End
      Else
      Begin
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat;
      End;
   End;

   dDebeMN := cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat;
   dDebeME := cdsMovCNT.FieldByName('CNTDEBEME').AsFloat;
   dHabeMN := cdsMovCNT.FieldByName('CNTHABEMN').AsFloat;
   dHabeME := cdsMovCNT.FieldByName('CNTHABEME').AsFloat;
// Inicio HPC_201701_CAJA
//cdsQry_G.FieldByName('CCOSID').AsString
// cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
// cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_G.FieldByName('CPFEMIS').AsDateTime;
   cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_G.FieldByName('CPFVCMTO').AsDateTime;

// Fin HPC_201701_CAJA
   cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
   cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
// Inicio : HPC_201301_CNT
   cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
// Fin : HPC_201301_CNT
   cdsMovCNT.FieldByName('CNTUSER').AsString := cdsCNT.FieldByName('CNTUSER').AsString;
   cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsCNT.FieldByName('CNTFREG').AsDateTime;
   cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsCNT.FieldByName('CNTHREG').AsDateTime;
   cdsMovCNT.FieldByName('CNTANO').AsString := cdsCNT.FieldByName('CNTANO').AsString;
   cdsMovCNT.FieldByName('CNTMM').AsString := cdsCNT.FieldByName('CNTMM').AsString;
   cdsMovCNT.FieldByName('CNTDD').AsString := cdsCNT.FieldByName('CNTDD').AsString;
   cdsMovCNT.FieldByName('CNTTRI').AsString := cdsCNT.FieldByName('CNTTRI').AsString;
   cdsMovCNT.FieldByName('CNTSEM').AsString := cdsCNT.FieldByName('CNTSEM').AsString;
   cdsMovCNT.FieldByName('CNTSS').AsString := cdsCNT.FieldByName('CNTSS').AsString;
   cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsCNT.FieldByName('CNTAATRI').AsString;
   cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsCNT.FieldByName('CNTAASEM').AsString;
   cdsMovCNT.FieldByName('CNTAASS').AsString := cdsCNT.FieldByName('CNTAASS').AsString;
   cdsMovCNT.FieldByName('TMONID').AsString := cdsCNT.FieldByName('TMONID').AsString;
   cdsMovCNT.FieldByName('TDIARDES').AsString := cdsCNT.FieldByName('TDIARDES').AsString;
   cdsMovCNT.FieldByName('AUXDES').AsString := cdsCNT.FieldByName('AUXDES').AsString;
   cdsMovCNT.FieldByName('DOCDES').AsString := cdsCNT.FieldByName('DOCDES').AsString;
   cdsMovCNT.FieldByName('CCOSDES').AsString := cdsCNT.FieldByName('CCOSDES').AsString;
   cdsMovCNT.FieldByName('MODULO').AsString := cdsCNT.FieldByName('MODULO').AsString;
   iOrden := iOrden + 1;
   cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
   cdsPost(cdsMovCNT);

   If cdsCNT.FieldByName('TMONID').AsString = 'D' Then
   Begin
      If cdsQry_G.FieldByName('DETCPAG').AsFloat <> cdsQry_G.FieldByName('DETCDOC').AsFloat Then
      Begin

         cdsMovCNT.Insert;
         cdsMovCNT.FieldByName('CIAID').AsString := xCiaOri;
         cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen2;
         cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp1;
         cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;

         If cdsQry_G.FieldByName('DETCPAG').AsFloat > cdsQry_G.FieldByName('DETCDOC').AsFloat Then
         Begin
            cdsMovCNT.FieldByName('CUENTAID').AsString := wCtaPer;
            cdsMovCNT.FieldByName('CCOSID').AsString := wCCosDif;
            nDifCam := cdsQry_G.FieldByName('DETCPAG').AsFloat - cdsQry_G.FieldByName('DETCDOC').AsFloat;

            // vhn redondeo nuevo
            nDifCam1 := FoaConta.FRound(cdsQry_G.FieldByName('DEMTOORI').AsFloat * cdsQry_G.FieldByName('DETCDOC').AsFloat, 15, 2);
            nDifCam2 := FoaConta.FRound(cdsQry_G.FieldByName('DEMTOORI').AsFloat * cdsQry_G.FieldByName('DETCPAG').AsFloat, 15, 2);
            nDifCam := nDifCam2 - nDifCam1;
            sDeHa := 'D';
            dDebeMN := FoaConta.FRound(nDifCam, 15, 2);

            cdsMovCNT.FieldByName('CNTTCAMBIO').AsFloat := cdsQry_G.FieldByName('DETCPAG').AsFloat;
            cdsMovCNT.FieldByName('CNTMTOORI').Asfloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT := dDebeMN;
            cdsMovCNT.FieldByName('CNTMTOEXT').Asfloat := 0;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
         End
         Else
         Begin

            nDifCam1 := FoaConta.FRound(cdsQry_G.FieldByName('DEMTOORI').AsFloat * cdsQry_G.FieldByName('DETCDOC').AsFloat, 15, 2);
            nDifCam2 := FoaConta.FRound(cdsQry_G.FieldByName('DEMTOORI').AsFloat * cdsQry_G.FieldByName('DETCPAG').AsFloat, 15, 2);
            nDifCam := nDifCam1 - nDifCam2;

            If nDifCam >= 0 Then
            Begin
               cdsMovCNT.FieldByName('CUENTAID').AsString := wCtaGan;
               cdsMovCNT.FieldByName('CCOSID').AsString := '';
               sDeHa := 'H';
               dDebeMN := FoaConta.FRound(nDifCam, 15, 2);
               cdsMovCNT.FieldByName('CNTTCAMBIO').AsFloat := cdsQry_G.FieldByName('DETCPAG').AsFloat;
               cdsMovCNT.FieldByName('CNTMTOORI').Asfloat := dDebeMN;
               cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT := dDebeMN;
               cdsMovCNT.FieldByName('CNTMTOEXT').Asfloat := 0;
               cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
               cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
               cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dDebeMN;
               cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
            End
            Else
            Begin
               cdsMovCNT.FieldByName('CUENTAID').AsString := wCtaPer;
               cdsMovCNT.FieldByName('CCOSID').AsString := wCCosDif;
               sDeHa := 'D';
               dDebeMN := FoaConta.FRound(nDifCam * -1, 15, 2);
               cdsMovCNT.FieldByName('CNTTCAMBIO').AsFloat := cdsQry_G.FieldByName('DETCPAG').AsFloat;
               cdsMovCNT.FieldByName('CNTMTOORI').Asfloat := dDebeMN;
               cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT := dDebeMN;
               cdsMovCNT.FieldByName('CNTMTOEXT').Asfloat := 0;
               cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
               cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
               cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
               cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
            End;
         End;

         cdsMovCNT.FieldByName('CNTGLOSA').AsString := 'Diferencia de Cambio';
         cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsCNT.FieldByName('CNTLOTE').AsString;
         cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_G.FieldByName('CLAUXID').AsString;
         cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_G.FieldByName('PROV').AsString;
         cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsCNT.FieldByName('CNTMODDOC').AsString;
         cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_G.FieldByName('DOCID2').AsString;
         cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_G.FieldByName('CPSERIE').AsString;
         cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_G.FieldByName('CPNODOC').AsString;

         cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
         cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
         cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
      // Inicio : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
      // Fin : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTUSER').AsString := cdsCNT.FieldByName('CNTUSER').AsString;
         cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsCNT.FieldByName('CNTFREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsCNT.FieldByName('CNTHREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTANO').AsString := cdsCNT.FieldByName('CNTANO').AsString;
         cdsMovCNT.FieldByName('CNTMM').AsString := cdsCNT.FieldByName('CNTMM').AsString;
         cdsMovCNT.FieldByName('CNTDD').AsString := cdsCNT.FieldByName('CNTDD').AsString;
         cdsMovCNT.FieldByName('CNTTRI').AsString := cdsCNT.FieldByName('CNTTRI').AsString;
         cdsMovCNT.FieldByName('CNTSEM').AsString := cdsCNT.FieldByName('CNTSEM').AsString;
         cdsMovCNT.FieldByName('CNTSS').AsString := cdsCNT.FieldByName('CNTSS').AsString;
         cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsCNT.FieldByName('CNTAATRI').AsString;
         cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsCNT.FieldByName('CNTAASEM').AsString;
         cdsMovCNT.FieldByName('CNTAASS').AsString := cdsCNT.FieldByName('CNTAASS').AsString;
         cdsMovCNT.FieldByName('TMONID').AsString := cdsCNT.FieldByName('TMONID').AsString;
         cdsMovCNT.FieldByName('TDIARDES').AsString := cdsCNT.FieldByName('TDIARDES').AsString;
         cdsMovCNT.FieldByName('AUXDES').AsString := cdsCNT.FieldByName('AUXDES').AsString;
         cdsMovCNT.FieldByName('DOCDES').AsString := cdsCNT.FieldByName('DOCDES').AsString;
         cdsMovCNT.FieldByName('CCOSDES').AsString := cdsCNT.FieldByName('CCOSDES').AsString;
         cdsMovCNT.FieldByName('MODULO').AsString := cdsCNT.FieldByName('MODULO').AsString;
         iOrden := iOrden + 1;
         cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
         cdsPost(cdsMovCNT);
      End;
   End;
End;

Procedure TFoaConta.GeneraAsientoGlobal_N2(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
Begin
   //SI LA CUENTA ORIGEN ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE

   cdsMovCNT.Insert;
   cdsMovCNT.FieldByName('CIAID').AsString := xCiaOri;
   cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen2;
   cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp1;
   cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
   cdsMovCNT.FieldByName('CUENTAID').AsString := wCtaBanco_C;
   cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_G.FieldByName('PROVDES').AsString;
   cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsCNT.FieldByName('CNTLOTE').AsString;
   cdsMovCNT.FieldByName('CLAUXID').AsString := '';
   cdsMovCNT.FieldByName('AUXID').AsString := '';
   cdsMovCNT.FieldByName('CCOSID').AsString := '';
   cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsCNT.FieldByName('CNTMODDOC').AsString;
   cdsMovCNT.FieldByName('DOCID').AsString := '';
   cdsMovCNT.FieldByName('CNTSERIE').AsString := '';
   cdsMovCNT.FieldByName('CNTNODOC').AsString := wNoChq_C;
   cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_G.FieldByName('DETCPAG').AsString;

   If wMtoOri_C < 0 Then
      cdsMovCNT.FieldByName('CNTDH').AsString := 'D'
   Else
      cdsMovCNT.FieldByName('CNTDH').AsString := 'H'; // normal

   If cdsCNT.FieldByName('TMONID').AsString = 'N' Then
   Begin
      cdsMovCNT.FieldByName('CNTMTOORI').AsFloat := Abs(wMtoOri_C);
      cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat := Abs(wMtoLoc_C);
      cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat := Abs(wMtoExt_C);
      If cdsMovCNT.FieldByName('CNTDH').AsString = 'H' Then
      Begin
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := wMtoLoc_C;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := wMtoExt_C;
      End
      Else
      Begin
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := Abs(wMtoLoc_C);
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := Abs(wMtoExt_C);
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
      End;
   End
   Else
   Begin
      cdsMovCNT.FieldByName('CNTMTOORI').AsFloat := Abs(wMtoOri_C);
// Inicio HPC_201701_CAJA  Modificar calculo de Diferencia de cambio para pagos en dólares
      //cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat := Abs(wMtoLoc_C);
      cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat   :=Abs(FoaConta.FRound(wMtoOri_C*cdsQry_G.FieldByName('DETCPAG').AsFloat,15,2));
// Fin  HPC_201701_CAJA  Modificar calculo de Diferencia de cambio para pagos en dólares
      cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat := Abs(wMtoExt_C);
      If cdsMovCNT.FieldByName('CNTDH').AsString = 'H' Then
      Begin
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := wMtoExt_C;
      End
      Else
      Begin
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := Abs(cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat);
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := Abs(wMtoExt_C);
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
      End;
   End;

   cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
   cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
   cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
// Inicio : HPC_201301_CNT
   cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
// Fin : HPC_201301_CNT
   cdsMovCNT.FieldByName('CNTUSER').AsString := cdsCNT.FieldByName('CNTUSER').AsString;
   cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsCNT.FieldByName('CNTFREG').AsDateTime;
   cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsCNT.FieldByName('CNTHREG').AsDateTime;
   cdsMovCNT.FieldByName('CNTANO').AsString := cdsCNT.FieldByName('CNTANO').AsString;
   cdsMovCNT.FieldByName('CNTMM').AsString := cdsCNT.FieldByName('CNTMM').AsString;
   cdsMovCNT.FieldByName('CNTDD').AsString := cdsCNT.FieldByName('CNTDD').AsString;
   cdsMovCNT.FieldByName('CNTTRI').AsString := cdsCNT.FieldByName('CNTTRI').AsString;
   cdsMovCNT.FieldByName('CNTSEM').AsString := cdsCNT.FieldByName('CNTSEM').AsString;
   cdsMovCNT.FieldByName('CNTSS').AsString := cdsCNT.FieldByName('CNTSS').AsString;
   cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsCNT.FieldByName('CNTAATRI').AsString;
   cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsCNT.FieldByName('CNTAASEM').AsString;
   cdsMovCNT.FieldByName('CNTAASS').AsString := cdsCNT.FieldByName('CNTAASS').AsString;
   cdsMovCNT.FieldByName('TMONID').AsString := cdsCNT.FieldByName('TMONID').AsString;
   cdsMovCNT.FieldByName('TDIARDES').AsString := cdsCNT.FieldByName('TDIARDES').AsString;
   cdsMovCNT.FieldByName('AUXDES').AsString := '';
   cdsMovCNT.FieldByName('DOCDES').AsString := cdsCNT.FieldByName('DOCDES').AsString;
   cdsMovCNT.FieldByName('CCOSDES').AsString := '';
   cdsMovCNT.FieldByName('MODULO').AsString := cdsCNT.FieldByName('MODULO').AsString;
   iOrden := iOrden + 1;
   cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
   cdsPost(cdsMovCNT);

   // NUEVA MAYORIZACION
   If xTCP = 'CPG' Then
   Begin

      AsientosComplementarios(xCiaOri, xOrigen2, xAnoMM, xNoComp1);

   End;

   xSQLAdicional := xSQLAdicional
      + 'or ( A.CIAID=' + quotedstr(xCiaOri) + ' AND '
      + 'A.CNTANOMM=' + quotedstr(xAnoMM) + ' AND '
      + 'A.TDIARID=' + quotedstr(xOrigen2) + ' AND '
      + 'A.CNTCOMPROB=' + quotedstr(xNoComp1) + ' ) ';

End;

Procedure TFoaConta.GeneraAsientoGlobal_N3(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
Begin
   //SI LA CUENTA ORIGEN ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE

   cdsMovCNT.Insert;
   cdsMovCNT.FieldByName('CIAID').AsString := xCia;
   cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen;
   cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp2;
   cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
   cdsMovCNT.FieldByName('CUENTAID').AsString := wCtaBanco_C;
   cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_G.FieldByName('PROVDES').AsString;
   cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsCNT.FieldByName('CNTLOTE').AsString;
   cdsMovCNT.FieldByName('CLAUXID').AsString := '';
   cdsMovCNT.FieldByName('AUXID').AsString := '';
   cdsMovCNT.FieldByName('CCOSID').AsString := '';
   cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsCNT.FieldByName('CNTMODDOC').AsString;
   cdsMovCNT.FieldByName('DOCID').AsString := '';
   cdsMovCNT.FieldByName('CNTSERIE').AsString := '';
   cdsMovCNT.FieldByName('CNTNODOC').AsString := wNoChq_C;

   If wMtoOri_C < 0 Then
      cdsMovCNT.FieldByName('CNTDH').AsString := 'H'
   Else
      cdsMovCNT.FieldByName('CNTDH').AsString := 'D';

   cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_G.FieldByName('DETCPAG').AsString;
   cdsMovCNT.FieldByName('CNTMTOORI').AsFloat := Abs(wMtoOri_C);
// Inicio HPC_201701_CAJA  Modificar calculo de Diferencia de cambio para pagos en dólares
   if cdsCNT.FieldByName('TMONID').AsString = 'N' Then
      cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat := Abs(wMtoLoc_C)
   else
      cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat := Abs(FoaConta.FRound(wMtoOri_C*cdsQry_G.FieldByName('DETCPAG').AsFloat,15,2));
// Fin HPC_201701_CAJA  Modificar calculo de Diferencia de cambio para pagos en dólares
   cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat := Abs(wMtoExt_C);
   cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
   cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
// Inicio : HPC_201301_CNT
   cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
// Fin : HPC_201301_CNT
   cdsMovCNT.FieldByName('CNTUSER').AsString := cdsCNT.FieldByName('CNTUSER').AsString;
   cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsCNT.FieldByName('CNTFREG').AsDateTime;
   cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsCNT.FieldByName('CNTHREG').AsDateTime;
   cdsMovCNT.FieldByName('CNTANO').AsString := cdsCNT.FieldByName('CNTANO').AsString;
   cdsMovCNT.FieldByName('CNTMM').AsString := cdsCNT.FieldByName('CNTMM').AsString;
   cdsMovCNT.FieldByName('CNTDD').AsString := cdsCNT.FieldByName('CNTDD').AsString;
   cdsMovCNT.FieldByName('CNTTRI').AsString := cdsCNT.FieldByName('CNTTRI').AsString;
   cdsMovCNT.FieldByName('CNTSEM').AsString := cdsCNT.FieldByName('CNTSEM').AsString;
   cdsMovCNT.FieldByName('CNTSS').AsString := cdsCNT.FieldByName('CNTSS').AsString;
   cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsCNT.FieldByName('CNTAATRI').AsString;
   cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsCNT.FieldByName('CNTAASEM').AsString;
   cdsMovCNT.FieldByName('CNTAASS').AsString := cdsCNT.FieldByName('CNTAASS').AsString;
   cdsMovCNT.FieldByName('TMONID').AsString := cdsCNT.FieldByName('TMONID').AsString;
   cdsMovCNT.FieldByName('TDIARDES').AsString := cdsCNT.FieldByName('TDIARDES').AsString;
   cdsMovCNT.FieldByName('AUXDES').AsString := '';
   cdsMovCNT.FieldByName('DOCDES').AsString := cdsCNT.FieldByName('DOCDES').AsString;
   cdsMovCNT.FieldByName('CCOSDES').AsString := '';

// Inicio HPC_201701_CAJA  Modificar calculo de Diferencia de cambio para pagos en dólares
   If cdsMovCNT.FieldByName('CNTDH').AsString = 'D' Then
   Begin
      cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat;
      cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := Abs(wMtoExt_C);
      cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
      cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
   End
   Else
   Begin
      cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
      cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
      cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat;
      cdsMovCNT.FieldByName('CNTHABEME').AsFloat := Abs(wMtoExt_C);
   End;
// Fin  HPC_201701_CAJA  Modificar calculo de Diferencia de cambio para pagos en dólares
   cdsMovCNT.FieldByName('MODULO').AsString := cdsCNT.FieldByName('MODULO').AsString;
   iOrden := iOrden + 1;
   cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
   cdsPost(cdsMovCNT);

   wMtoDif := wMtoLoc_C;
End;

Procedure TFoaConta.GeneraAsientoGlobal_NDif(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
Var
   xTDebeMN, xTHaberMN, xTDebeME, xTHaberME, xsDif: Double;
   wCptoGan, wCptoPer, wCtaGan, wCtaPer: String;
Begin
   //SI LA CUENTA ORIGEN ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE

   // CUADRA ASIENTO
   xTDebeMN := 0;
   xTHaberMN := 0;
   xTDebeME := 0;
   xTHaberME := 0;
   cdsMovCnt.First;
   While Not cdsMovCnt.eof Do
   Begin
      If cdsMovCnt.FieldByName('CNTDH').AsString = 'D' Then
      Begin
         xTDebeMN := xTDebeMN + cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
         xTDebeME := xTDebeME + cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
      End
      Else
      Begin
         xTHaberMN := xTHaberMN + cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
         xTHaberME := xTHaberME + cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
      End;
      cdsMovCnt.Next;
   End;

   xsDif := 0;

   If (xTDebeMN <> xTHaberMN) Then
   Begin
      If xTDebeMN > xTHaberMN Then
      Begin
         xsDif := xTDebeMN-xTHaberMN;
         cdsMovCnt.FieldByName('CNTMTOORI').AsFloat := Abs(0);
         cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat := abs(FRound(xsDif,15,2));
         cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat := Abs(0);
         cdsMovCnt.FieldByName('DCDH').Value := 'H';
         cdsMovCnt.FieldByName('CPTOID').Value := wCptoGan;
         cdsMovCnt.FieldByName('CUENTAID').Value := wCtaGan;
         cdsMovCnt.FieldByName('DCGLOSA').AsString := 'AJUSTE POR REDONDEO';
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := abs(FRound(xsDif,15,2));
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
      End
      Else
      Begin
         xsDif := xTHaberMN-xTDebeMN;
         cdsMovCnt.FieldByName('CNTMTOORI').AsFloat := 0;
         cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat := abs(FRound(xsDif, 15, 2));
         cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat := 0;
         cdsMovCnt.FieldByName('DCDH').Value := 'D';
         cdsMovCnt.FieldByName('CPTOID').Value := wCptoPer;
         cdsMovCnt.FieldByName('CUENTAID').Value := wCtaPer;
         cdsMovCnt.FieldByName('DCGLOSA').AsString := 'AJUSTE POR REDONDEO';
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := abs(FRound(xsDif,15,2));
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
      End;
   End;

   If (xTDebeME <> xTHaberME) Then
   Begin
      If xTDebeME > xTHaberME Then
      Begin
         xsDif := xTDebeME-xTHaberME;
         cdsMovCnt.FieldByName('CNTMTOORI').AsFloat := Abs(0);
         cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat := Abs(0);
         cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat := abs(FRound(xsDif, 15, 2));
         cdsMovCnt.FieldByName('DCDH').Value := 'H';
         cdsMovCnt.FieldByName('CPTOID').Value := wCptoGan;
         cdsMovCnt.FieldByName('CUENTAID').Value := wCtaGan;
         cdsMovCnt.FieldByName('DCGLOSA').AsString := 'AJUSTE POR REDONDEO';
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := abs(FRound(xsDif, 15, 2));

      End
      Else
      Begin
         xsDif := xTHaberME-xTDebeME;
         cdsMovCnt.FieldByName('CNTMTOORI').AsFloat := Abs(0);
         cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat := Abs(0);
         cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat := abs(FRound(xsDif, 15, 2));
         cdsMovCnt.FieldByName('DCDH').Value := 'D';
         cdsMovCnt.FieldByName('CPTOID').Value := wCptoPer;
         cdsMovCnt.FieldByName('CUENTAID').Value := wCtaPer;
         cdsMovCnt.FieldByName('DCGLOSA').AsString := 'AJUSTE POR REDONDEO';
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := abs(FRound(xsDif, 15, 2));

      End;
   End;

   cdsMovCNT.Insert;
   cdsMovCNT.FieldByName('CIAID').AsString := xCia;
   cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen;
   cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp2;
   cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
//   cdsMovCNT.FieldByName('CUENTAID').AsString := wCtaBanco_C;
// cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_G.FieldByName('PROVDES').AsString;
   cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsCNT.FieldByName('CNTLOTE').AsString;
   cdsMovCNT.FieldByName('CLAUXID').AsString := '';
   cdsMovCNT.FieldByName('AUXID').AsString := '';
   cdsMovCNT.FieldByName('CCOSID').AsString := '';
   cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsCNT.FieldByName('CNTMODDOC').AsString;
   cdsMovCNT.FieldByName('DOCID').AsString := '';
   cdsMovCNT.FieldByName('CNTSERIE').AsString := '';
   cdsMovCNT.FieldByName('CNTNODOC').AsString := wNoChq_C;
{
   If wMtoOri_C < 0 Then
      cdsMovCNT.FieldByName('CNTDH').AsString := 'H'
   Else
      cdsMovCNT.FieldByName('CNTDH').AsString := 'D';
}
   cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_G.FieldByName('DETCPAG').AsString;
//   cdsMovCNT.FieldByName('CNTMTOORI').AsFloat := Abs(wMtoOri_C);
//   cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat := Abs(wMtoLoc_C);
//   cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat := Abs(wMtoExt_C);
   cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
   cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
// Inicio : HPC_201301_CNT
   cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
// Fin : HPC_201301_CNT
   cdsMovCNT.FieldByName('CNTUSER').AsString := cdsCNT.FieldByName('CNTUSER').AsString;
   cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsCNT.FieldByName('CNTFREG').AsDateTime;
   cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsCNT.FieldByName('CNTHREG').AsDateTime;
   cdsMovCNT.FieldByName('CNTANO').AsString := cdsCNT.FieldByName('CNTANO').AsString;
   cdsMovCNT.FieldByName('CNTMM').AsString := cdsCNT.FieldByName('CNTMM').AsString;
   cdsMovCNT.FieldByName('CNTDD').AsString := cdsCNT.FieldByName('CNTDD').AsString;
   cdsMovCNT.FieldByName('CNTTRI').AsString := cdsCNT.FieldByName('CNTTRI').AsString;
   cdsMovCNT.FieldByName('CNTSEM').AsString := cdsCNT.FieldByName('CNTSEM').AsString;
   cdsMovCNT.FieldByName('CNTSS').AsString := cdsCNT.FieldByName('CNTSS').AsString;
   cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsCNT.FieldByName('CNTAATRI').AsString;
   cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsCNT.FieldByName('CNTAASEM').AsString;
   cdsMovCNT.FieldByName('CNTAASS').AsString := cdsCNT.FieldByName('CNTAASS').AsString;
   cdsMovCNT.FieldByName('TMONID').AsString := cdsCNT.FieldByName('TMONID').AsString;
   cdsMovCNT.FieldByName('TDIARDES').AsString := cdsCNT.FieldByName('TDIARDES').AsString;
   cdsMovCNT.FieldByName('AUXDES').AsString := '';
   cdsMovCNT.FieldByName('DOCDES').AsString := cdsCNT.FieldByName('DOCDES').AsString;
   cdsMovCNT.FieldByName('CCOSDES').AsString := '';
{
   If cdsMovCNT.FieldByName('CNTDH').AsString = 'D' Then
   Begin
      cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := Abs(wMtoLoc_C);
      cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := Abs(wMtoExt_C);
      cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
      cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
   End
   Else
   Begin
      cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
      cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
      cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := Abs(wMtoLoc_C);
      cdsMovCNT.FieldByName('CNTHABEME').AsFloat := Abs(wMtoExt_C);
   End;
}
   cdsMovCNT.FieldByName('MODULO').AsString := cdsCNT.FieldByName('MODULO').AsString;
   iOrden := iOrden + 1;
   cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
   cdsPost(cdsMovCNT);

//   wMtoDif := wMtoLoc_C;
End;

Procedure TFoaConta.GeneraAsientoGlobal_N4(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
Var
   sDeHa, sSQL24: String;
   dDebeMN, nDifCam, nDifCam1, nDifCam2: Double;

Begin
   //SI LA CUENTA ORIGEN ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE

   cdsMovCNT.Insert;
   cdsMovCNT.FieldByName('CIAID').AsString := xCia;
   cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen;
   cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp2;
   cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
   cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaHaber;
   cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_G.FieldByName('PROVDES').AsString;
   cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsCNT.FieldByName('CNTLOTE').AsString;
   cdsMovCNT.FieldByName('CLAUXID').AsString := '';
   cdsMovCNT.FieldByName('AUXID').AsString := '';
   cdsMovCNT.FieldByName('CCOSID').AsString := '';
   cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsCNT.FieldByName('CNTMODDOC').AsString;
   cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_G.FieldByName('DOCID2').AsString;
   cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_G.FieldByName('CPSERIE').AsString;
   cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_G.FieldByName('CPNODOC').AsString;

   If cdsQry_G.FieldByName('DEMTOLOC').AsFloat < 0 Then
      cdsMovCNT.FieldByName('CNTDH').AsString := 'D'
   Else
      cdsMovCNT.FieldByName('CNTDH').AsString := 'H';

   If cdsCNT.FieldByName('TMONID').AsString = 'N' Then
   Begin
      cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_G.FieldByName('DETCPAG').AsString;
      cdsMovCNT.FieldByName('CNTMTOORI').AsFloat := Abs(cdsQry_G.FieldByName('DEMTOLOC').AsFloat);
      cdsMovCNT.FieldByName('CNTMTOLOC').AsFloat := Abs(cdsQry_G.FieldByName('DEMTOLOC').AsFloat);
      cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat := Abs(cdsQry_G.FieldByName('DEMTOEXT').AsFloat);
      If cdsMovCNT.FieldByName('CNTDH').AsString = 'H' Then
      Begin
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := Abs(cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT);
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := Abs(cdsMovCNT.FieldByName('CNTMTOEXT').Asfloat);
      End
      Else
      Begin
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := Abs(cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT);
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := Abs(cdsMovCNT.FieldByName('CNTMTOEXT').Asfloat);
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
      End;
   End
   Else
   Begin
      cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_G.FieldByName('DETCDOC').AsString;
      cdsMovCNT.FieldByName('CNTMTOORI').AsFloat := Abs(cdsQry_G.FieldByName('DEMTOEXT').AsFloat);
      cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT := FRound(Abs(cdsQry_G.FieldByName('DEMTOEXT').AsfLOAT) * cdsQry_G.FieldByName('DETCDOC').AsfLOAT, 15, 2);

      cdsMovCNT.FieldByName('CNTMTOEXT').AsFloat := Abs(cdsQry_G.FieldByName('DEMTOEXT').AsFloat);
      If cdsMovCNT.FieldByName('CNTDH').AsString = 'H' Then
      Begin
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := Abs(cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT);
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := Abs(cdsMovCNT.FieldByName('CNTMTOEXT').Asfloat);
      End
      Else
      Begin
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := Abs(cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT);
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := Abs(cdsMovCNT.FieldByName('CNTMTOEXT').Asfloat);
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
      End;
   End;

   cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
   cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
   cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
// Inicio : HPC_201301_CNT
   cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
// Fin : HPC_201301_CNT
   cdsMovCNT.FieldByName('CNTUSER').AsString := cdsCNT.FieldByName('CNTUSER').AsString;
   cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsCNT.FieldByName('CNTFREG').AsDateTime;
   cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsCNT.FieldByName('CNTHREG').AsDateTime;
   cdsMovCNT.FieldByName('CNTANO').AsString := cdsCNT.FieldByName('CNTANO').AsString;
   cdsMovCNT.FieldByName('CNTMM').AsString := cdsCNT.FieldByName('CNTMM').AsString;
   cdsMovCNT.FieldByName('CNTDD').AsString := cdsCNT.FieldByName('CNTDD').AsString;
   cdsMovCNT.FieldByName('CNTTRI').AsString := cdsCNT.FieldByName('CNTTRI').AsString;
   cdsMovCNT.FieldByName('CNTSEM').AsString := cdsCNT.FieldByName('CNTSEM').AsString;
   cdsMovCNT.FieldByName('CNTSS').AsString := cdsCNT.FieldByName('CNTSS').AsString;
   cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsCNT.FieldByName('CNTAATRI').AsString;
   cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsCNT.FieldByName('CNTAASEM').AsString;
   cdsMovCNT.FieldByName('CNTAASS').AsString := cdsCNT.FieldByName('CNTAASS').AsString;
   cdsMovCNT.FieldByName('TMONID').AsString := cdsCNT.FieldByName('TMONID').AsString;
   cdsMovCNT.FieldByName('TDIARDES').AsString := cdsCNT.FieldByName('TDIARDES').AsString;
   cdsMovCNT.FieldByName('AUXDES').AsString := '';
   cdsMovCNT.FieldByName('DOCDES').AsString := cdsCNT.FieldByName('DOCDES').AsString;
   cdsMovCNT.FieldByName('CCOSDES').AsString := '';
   cdsMovCNT.FieldByName('MODULO').AsString := cdsCNT.FieldByName('MODULO').AsString;
   iOrden := iOrden + 1;
   cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
   cdsPost(cdsMovCNT);

   wMtoDif := wMtoDif - cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT;

   If cdsCNT.FieldByName('TMONID').AsString = 'D' Then
   Begin
      If cdsQry_G.FieldByName('DETCPAG').AsFloat <> cdsQry_G.FieldByName('DETCDOC').AsFloat Then
      Begin

         sSQL24 := 'SELECT CPTCAMPR FROM CXP301 '
                 + ' WHERE CIAID=' + quotedstr(xCia) + ' and CPANOMES=' + quotedstr(xAnoMM)
                 + '   and TDIARID=' + quotedstr(xOrigen) + ' and CPNOREG=' + quotedstr(xNoComp2);
         cdsQry_D.Close;
         cdsQry_D.DataRequest(sSQL24);
         cdsQry_D.Open;
         cdsMovCNT.FieldByName('DOCID').AsString := wDoc_C;
         cdsMovCNT.FieldByName('CNTSERIE').AsString := wSerie_C;
         cdsMovCNT.FieldByName('CNTNODOC').AsString := wNodoc_C;

         cdsMovCNT.Insert;
         cdsMovCNT.FieldByName('CIAID').AsString := xCia;
         cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen;
         cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp2;
         cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;

         If cdsQry_G.FieldByName('DETCPAG').AsFloat > cdsQry_G.FieldByName('DETCDOC').AsFloat Then
         Begin
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaHaber;
            cdsMovCNT.FieldByName('CCOSID').AsString := '';
            nDifCam1 := FoaConta.FRound(cdsQry_G.FieldByName('DEMTOORI').AsFloat * cdsQry_G.FieldByName('DETCDOC').AsFloat, 15, 2);
            nDifCam2 := FoaConta.FRound(cdsQry_G.FieldByName('DEMTOORI').AsFloat * cdsQry_G.FieldByName('DETCPAG').AsFloat, 15, 2);
            nDifCam := nDifCam2 - nDifCam1;
            sDeHa := 'H';
            dDebeMN := FoaConta.FRound(nDifCam, 15, 2);
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsFloat := cdsQry_G.FieldByName('DETCPAG').AsFloat;
            cdsMovCNT.FieldByName('CNTMTOORI').Asfloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT := dDebeMN;
            cdsMovCNT.FieldByName('CNTMTOEXT').Asfloat := 0;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dDebeMN;

            cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
         End
         Else
         Begin
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaHaber;
            cdsMovCNT.FieldByName('CCOSID').AsString := '';

            nDifCam1 := FoaConta.FRound(cdsQry_G.FieldByName('DEMTOORI').AsFloat * cdsQry_G.FieldByName('DETCDOC').AsFloat, 15, 2);
            nDifCam2 := FoaConta.FRound(cdsQry_G.FieldByName('DEMTOORI').AsFloat * cdsQry_G.FieldByName('DETCPAG').AsFloat, 15, 2);
            nDifCam := nDifCam1 - nDifCam2;

            If nDifCam >= 0 Then
            Begin
               sDeHa := 'D';
               dDebeMN := FoaConta.FRound(nDifCam, 15, 2);
               cdsMovCNT.FieldByName('CNTTCAMBIO').AsFloat := cdsQry_G.FieldByName('DETCPAG').AsFloat;
               cdsMovCNT.FieldByName('CNTMTOORI').Asfloat := dDebeMN;
               cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT := dDebeMN;
               cdsMovCNT.FieldByName('CNTMTOEXT').Asfloat := 0;
               cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
               cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
               cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := 0;
               cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
            End
            Else
            Begin
               sDeHa := 'H';
               dDebeMN := FoaConta.FRound(nDifCam * -1, 15, 2);
               cdsMovCNT.FieldByName('CNTTCAMBIO').AsFloat := cdsQry_G.FieldByName('DETCPAG').AsFloat;
               cdsMovCNT.FieldByName('CNTMTOORI').Asfloat := dDebeMN;
               cdsMovCNT.FieldByName('CNTMTOLOC').AsfLOAT := dDebeMN;
               cdsMovCNT.FieldByName('CNTMTOEXT').Asfloat := 0;
               cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := 0;
               cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := 0;
               cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dDebeMN;
               cdsMovCNT.FieldByName('CNTHABEME').AsFloat := 0;
            End;
         End;

         cdsMovCNT.FieldByName('CNTGLOSA').AsString := 'Diferencia de Cambio';
         cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsCNT.FieldByName('CNTLOTE').AsString;
         //cdsMovCNT.FieldByName('CLAUXID').AsString    :=cdsQry_G.FieldByName('CLAUXID').AsString;
         //cdsMovCNT.FieldByName('AUXID').AsString      :=cdsQry_G.FieldByName('PROV').AsString;
         cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsCNT.FieldByName('CNTMODDOC').AsString;
         cdsMovCNT.FieldByName('DOCID').AsString := wDoc_C;
         cdsMovCNT.FieldByName('CNTSERIE').AsString := wSerie_C;
         cdsMovCNT.FieldByName('CNTNODOC').AsString := wNodoc_C;

         cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
         cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsCNT.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
         cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
      // Inicio : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
      // Fin : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTUSER').AsString := cdsCNT.FieldByName('CNTUSER').AsString;
         cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsCNT.FieldByName('CNTFREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsCNT.FieldByName('CNTHREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTANO').AsString := cdsCNT.FieldByName('CNTANO').AsString;
         cdsMovCNT.FieldByName('CNTMM').AsString := cdsCNT.FieldByName('CNTMM').AsString;
         cdsMovCNT.FieldByName('CNTDD').AsString := cdsCNT.FieldByName('CNTDD').AsString;
         cdsMovCNT.FieldByName('CNTTRI').AsString := cdsCNT.FieldByName('CNTTRI').AsString;
         cdsMovCNT.FieldByName('CNTSEM').AsString := cdsCNT.FieldByName('CNTSEM').AsString;
         cdsMovCNT.FieldByName('CNTSS').AsString := cdsCNT.FieldByName('CNTSS').AsString;
         cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsCNT.FieldByName('CNTAATRI').AsString;
         cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsCNT.FieldByName('CNTAASEM').AsString;
         cdsMovCNT.FieldByName('CNTAASS').AsString := cdsCNT.FieldByName('CNTAASS').AsString;
         cdsMovCNT.FieldByName('TMONID').AsString := cdsCNT.FieldByName('TMONID').AsString;
         cdsMovCNT.FieldByName('TDIARDES').AsString := cdsCNT.FieldByName('TDIARDES').AsString;
         cdsMovCNT.FieldByName('AUXDES').AsString := cdsCNT.FieldByName('AUXDES').AsString;
         cdsMovCNT.FieldByName('DOCDES').AsString := cdsCNT.FieldByName('DOCDES').AsString;
         cdsMovCNT.FieldByName('CCOSDES').AsString := cdsCNT.FieldByName('CCOSDES').AsString;
         cdsMovCNT.FieldByName('MODULO').AsString := cdsCNT.FieldByName('MODULO').AsString;
         iOrden := iOrden + 1;
         cdsMovCNT.FieldByName('CNTREG').AsInteger := iOrden;
         cdsPost(cdsMovCNT);
      End;
   End;

   // NUEVA MAYORIZACION
   If xTCP = 'CPG' Then
   Begin

      AsientosComplementarios(xCia, xOrigen, xAnoMM, xNoComp2);

   End;

   xSQLAdicional := xSQLAdicional
      + 'or ( A.CIAID=' + quotedstr(xCia) + ' AND '
      + 'A.CNTANOMM=' + quotedstr(xAnoMM) + ' AND '
      + 'A.TDIARID=' + quotedstr(xOrigen) + ' AND '
      + 'A.CNTCOMPROB=' + quotedstr(xNoComp2) + ' ) '
End;

Procedure TFoaConta.GeneraAsientosGlobal(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
Var
   cdsQryT: TwwClientDataSet;
   xSQL, xWhere: String;
   xCtaCaja: String;
   sDeHa: String;
   dHabeMN, dHabeME, dDebeMN, dDebeME: Double;
   nReg: Integer;
Begin
   // Números de Comprobantes Nuevos
   // Verifica si ya tiene comprobantes
   xWhere := 'SELECT ECPERREC FROM CAJA302 '
           + 'WHERE CIAID=' + '''' + xCia + ''''
           + ' and TDIARID=' + '''' + xDiario + ''''
           + ' and ECANOMM=' + '''' + xAnoMM + ''''
           + ' and ECNOCOMP=' + '''' + xNoComp + '''';
   cdsQryT := TwwClientDataSet.Create(Nil);
   cdsQryT.RemoteServer := DCOM_C;
   cdsQryT.ProviderName := Provider_C;

   cdsQryT.Close;
   cdsQryT.DataRequest(xWhere);
   cdsQryT.Open;

   xNoComp1 := '';
   xNoComp2 := '';
   If cdsQryT.FieldByname('ECPERREC').AsString <> '' Then
   Begin
      xNoComp1 := Copy(cdsQryT.FieldByname('ECPERREC').AsString, 10, 10);
      xNoComp2 := Copy(cdsQryT.FieldByname('ECPERREC').AsString, 31, 10);
   End
   Else
   Begin
      // NUMEROS EN CAJA
      If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
      Begin
         xWhere := 'SELECT COALESCE( MAX( ECNOCOMP ), ''0'' ) AS NUMERO FROM CAJA302 '
                 + 'WHERE CIAID=' + '''' + xCiaori + ''''
                 + ' and TDIARID=' + '''' + xOrigen2 + ''''
                 + ' and ECANOMM=' + '''' + xAnoMM + '''';
      End;
      If SRV_C = 'ORACLE' Then
      Begin
         xWhere := 'SELECT NVL( MAX( ECNOCOMP ), ''0'' ) AS NUMERO FROM CAJA302 '
                 + 'WHERE CIAID=' + '''' + xCiaOri + ''''
                 + ' and TDIARID=' + '''' + xOrigen2 + ''''
                 + ' and ECANOMM=' + '''' + xAnoMM + '''';
      End;
      cdsQryT.Close;
      cdsQryT.DataRequest(xWhere);
      cdsQryT.Open;

      xNoComp1 := Inttostr(StrToInt(cdsQryT.FieldByname('NUMERO').AsString) + 1);
      xNoComp1 := StrZero(xNoComp1, 10);
   End;

   // CUENTA 104 DE LA CIA=02'
   xSQL := 'SELECT CUENTAID, FCAB, DCDH, TMONID, DCMTOLO, DCMTOEXT FROM CAJA304 '
         + 'WHERE CIAID=''02'' AND '
//        +  'CIAID='   +''''+ xCia     +''''+' AND '
         + 'TDIARID=' + '''' + xDiario + '''' + ' AND '
         + 'ECANOMM=' + '''' + xAnoMM + '''' + ' AND '
         + 'ECNOCOMP=' + '''' + xNoComp + '''' + ' AND '
         + 'FCAB=''1'' AND DCDH=''H'' ';
   cdsQry_C.Close;
   cdsQry_C.DataRequest(xSQL);
   cdsQry_C.Open;

   xCtaCaja := cdsQry_C.FieldByName('CUENTAID').AsString;

   xSQL := 'SELECT * FROM CNT311 '
         + 'WHERE CIAID=''02'' AND '
//        +   'CIAID='     +''''+ xCia     +''''+' AND '
         + 'TDIARID=' + '''' + xDiario + '''' + ' AND '
         + 'CNTANOMM=' + '''' + xAnoMM + '''' + ' AND '
         + 'CNTCOMPROB=' + '''' + xNoComp + '''' + ' '
         + 'ORDER BY CNTREG';
   cdsQry_C.Close;
   cdsQry_C.DataRequest(xSQL);
   cdsQry_C.Open;

   xCiaOri := xCia;

   cdsMovCNT.Close;
   cdsMovCNT.DataRequest('Select * from CNT311 '
      + 'Where CIAID=''' + xCiaOri + ''' AND TDIARID=''' + xOrigen2 + ''' AND '
      + 'CNTANOMM=''' + xAnoMM + ''' and CNTCOMPROB=''' + xNoComp1 + '''');
   cdsMovCNT.Open;

   nReg := 0;
   While (Not cdsQry_C.Eof) Do
   Begin

      //if (xCtaCaja<>cdsQry_C.FieldByName('CUENTAID').AsString) AND (xCtaRetHaber<>cdsQry_C.FieldByName('CUENTAID').AsString) then begin
      If false Then
      Begin

         If (cdsQry_C.FieldByName('CNTMTOLOC').AsFloat = 0) Or
            (cdsQry_C.FieldByName('CNTMTOEXT').AsFloat = 0) Then
         Begin

            //
            // CUENTAS PRIMER ASIENTO
            //
            If cdsQry_C.FieldByName('CNTDH').AsString = 'D' Then
            Begin
               sDeHa := 'D';
               dHabeMN := 0;
               dHabeME := 0;
               dDebeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
               dDebeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            End
            Else
            Begin
               sDeHa := 'H';
               dDebeMN := 0;
               dDebeME := 0;
               dHabeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
               dHabeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            End;

            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString := xCiaOri;
            cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen2;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp1;
            cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;

            //cdsMovCNT.FieldByName('CUENTAID').AsString   :=cdsQry_C.FieldByName('CUENTAID').AsString;
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaDebe;

            If xAux_D = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_C.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_C.FieldByName('AUXID').AsString;
            End;
            If xCCos_D = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_C.FieldByName('CCOSID').AsString;
            End;
            cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsQry_C.FieldByName('CNTLOTE').AsString;
            cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsQry_C.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_C.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_C.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_C.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsQry_C.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsQry_C.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsQry_C.FieldByName('CNTMTOEXT').AsString;
            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
         // Inicio : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
         // Fin : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTUSER').AsString := cdsQry_C.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsQry_C.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsQry_C.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString := cdsQry_C.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString := cdsQry_C.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString := cdsQry_C.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString := cdsQry_C.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString := cdsQry_C.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString := cdsQry_C.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsQry_C.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsQry_C.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString := cdsQry_C.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString := cdsQry_C.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString := cdsQry_C.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString := cdsQry_C.FieldByName('AUXDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString := cdsQry_C.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString := cdsQry_C.FieldByName('CCOSDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString := cdsQry_C.FieldByName('MODULO').AsString;
            nReg := nReg + 1;
            cdsMovCNT.FieldByName('CNTREG').AsInteger := nReg;
            cdsPost(cdsMovCNT);
         End
         Else
         Begin

            //
            // CUENTAS PRIMER ASIENTO
            //
            If cdsQry_C.FieldByName('CNTDH').AsString = 'D' Then
            Begin
               sDeHa := 'D';
               dHabeMN := 0;
               dHabeME := 0;
               dDebeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
               dDebeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            End
            Else
            Begin
               sDeHa := 'H';
               dDebeMN := 0;
               dDebeME := 0;
               dHabeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
               dHabeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            End;

            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString := xCiaOri;
            cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen2;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp1;
            cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaDebe;
            cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsQry_C.FieldByName('CNTLOTE').AsString;
            If xAux_D = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_C.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_C.FieldByName('AUXID').AsString;
            End;
            If xCCos_D = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_C.FieldByName('CCOSID').AsString;
            End;
            cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsQry_C.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_C.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_C.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_C.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsQry_C.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsQry_C.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsQry_C.FieldByName('CNTMTOEXT').AsString;

            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
         // Inicio : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
         // Fin : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTUSER').AsString := cdsQry_C.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsQry_C.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsQry_C.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString := cdsQry_C.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString := cdsQry_C.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString := cdsQry_C.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString := cdsQry_C.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString := cdsQry_C.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString := cdsQry_C.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsQry_C.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsQry_C.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString := cdsQry_C.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString := cdsQry_C.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString := cdsQry_C.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString := cdsQry_C.FieldByName('AUXDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString := cdsQry_C.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString := cdsQry_C.FieldByName('CCOSDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString := cdsQry_C.FieldByName('MODULO').AsString;
            nReg := nReg + 1;
            cdsMovCNT.FieldByName('CNTREG').AsInteger := nReg;
            cdsPost(cdsMovCNT);
         End;
      End
      Else
      Begin

         //SI LA CUENTA ORIGES ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
         If cdsQry_C.FieldByName('CNTDH').AsString = 'H' Then
         Begin
            sDeHa := 'H';
            dDebeMN := 0;
            dDebeME := 0;
            dHabeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
            dHabeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
         End
         Else
         Begin
            sDeHa := 'D';
            dDebeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
            dDebeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            dHabeMN := 0;
            dHabeME := 0;
         End;

         cdsMovCNT.Insert;
         cdsMovCNT.FieldByName('CIAID').AsString := xCiaOri;
         cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen2;
         cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp1;
         cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
         If (cdsQry_C.FieldByName('CUENTAID').AsString = xCtaRetHaber) Then
         Begin
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaRetDebe;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := xGlosaRetDebe;
         End;
         If (cdsQry_C.FieldByName('CUENTAID').AsString = xCtaCaja) Then
         Begin
            cdsMovCNT.FieldByName('CUENTAID').AsString := cdsQry_C.FieldByName('CUENTAID').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;
         End;

         cdsMovCNT.FieldByName('CUENTAID').AsString := cdsQry_C.FieldByName('CUENTAID').AsString;
         cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;

         cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsQry_C.FieldByName('CNTLOTE').AsString;
         cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_C.FieldByName('CLAUXID').AsString;
         cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_C.FieldByName('AUXID').AsString;
         cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_C.FieldByName('CCOSID').AsString;
         cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsQry_C.FieldByName('CNTMODDOC').AsString;
         cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_C.FieldByName('DOCID').AsString;
         cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_C.FieldByName('CNTSERIE').AsString;
         cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_C.FieldByName('CNTNODOC').AsString;

// aqui estaba la glosa

         cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
         cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
         cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsQry_C.FieldByName('CNTMTOORI').AsString;
         cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsQry_C.FieldByName('CNTMTOLOC').AsString;
         cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsQry_C.FieldByName('CNTMTOEXT').AsString;
         cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
         cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
      // Inicio : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
      // Fin : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTUSER').AsString := cdsQry_C.FieldByName('CNTUSER').AsString;
         cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsQry_C.FieldByName('CNTFREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsQry_C.FieldByName('CNTHREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTANO').AsString := cdsQry_C.FieldByName('CNTANO').AsString;
         cdsMovCNT.FieldByName('CNTMM').AsString := cdsQry_C.FieldByName('CNTMM').AsString;
         cdsMovCNT.FieldByName('CNTDD').AsString := cdsQry_C.FieldByName('CNTDD').AsString;
         cdsMovCNT.FieldByName('CNTTRI').AsString := cdsQry_C.FieldByName('CNTTRI').AsString;
         cdsMovCNT.FieldByName('CNTSEM').AsString := cdsQry_C.FieldByName('CNTSEM').AsString;
         cdsMovCNT.FieldByName('CNTSS').AsString := cdsQry_C.FieldByName('CNTSS').AsString;
         cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsQry_C.FieldByName('CNTAATRI').AsString;
         cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsQry_C.FieldByName('CNTAASEM').AsString;
         cdsMovCNT.FieldByName('CNTAASS').AsString := cdsQry_C.FieldByName('CNTAASS').AsString;
         cdsMovCNT.FieldByName('TMONID').AsString := cdsQry_C.FieldByName('TMONID').AsString;
         cdsMovCNT.FieldByName('TDIARDES').AsString := cdsQry_C.FieldByName('TDIARDES').AsString;
         cdsMovCNT.FieldByName('AUXDES').AsString := cdsQry_C.FieldByName('AUXDES').AsString;
         cdsMovCNT.FieldByName('DOCDES').AsString := cdsQry_C.FieldByName('DOCDES').AsString;
         cdsMovCNT.FieldByName('CCOSDES').AsString := cdsQry_C.FieldByName('CCOSDES').AsString;
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
         cdsMovCNT.FieldByName('MODULO').AsString := cdsQry_C.FieldByName('MODULO').AsString;
         nReg := nReg + 1;
         cdsMovCNT.FieldByName('CNTREG').AsInteger := nReg;
         cdsPost(cdsMovCNT);
      End;
      cdsQry_C.Next;
   End;

   FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');

   /////////////////////////////////
   //  CUENTAS SEGUNDO ASIENTO    //
   /////////////////////////////////

   If xNoComp2 = '' Then
   Begin

      // Caja Autonoma
      If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
      Begin
         xWhere := 'SELECT COALESCE( MAX( CNTCOMPROB ), ''0'' ) AS NUMERO FROM CNT300 '
                 + 'WHERE CIAID=' + '''' + xCia + ''''
                 + ' and TDIARID=' + '''' + xOrigen + ''''
                 + ' and CNTANOMM=' + '''' + xAnoMM + '''';
      End;

      If SRV_C = 'ORACLE' Then
      Begin
         xWhere := 'SELECT NVL( MAX( CNTCOMPROB ), ''0'' ) AS NUMERO FROM CNT300 '
            + 'WHERE CIAID=' + '''' + xCia + ''''
            + ' and TDIARID=' + '''' + xOrigen + ''''
            + ' and CNTANOMM=' + '''' + xAnoMM + '''';
      End;
      cdsQryT.Close;
      cdsQryT.DataRequest(xWhere);
      cdsQryT.Open;

      xNoComp2 := Inttostr(StrToInt(cdsQryT.FieldByname('NUMERO').AsString) + 1);
      xNoComp2 := StrZero(xNoComp1, 10);

   End;

   cdsMovCNT.Close;
   cdsMovCNT.DataRequest('Select * from CNT311 '
      + 'Where CIAID=''' + xCia + ''' AND TDIARID=''' + xOrigen + ''' AND '
      + 'CNTANOMM=''' + xAnoMM + ''' and CNTCOMPROB=''' + xNoComp2 + '''');
   cdsMovCNT.Open;

   nReg := 1;

   cdsQry_C.First;
   While (Not cdsQry_C.Eof) Do
   Begin

      If (xCtaCaja = cdsQry_C.FieldByName('CUENTAID').AsString) Or (xCtaRetHaber = cdsQry_C.FieldByName('CUENTAID').AsString) Then
      Begin

         If cdsQry_C.FieldByName('CNTDH').AsString = 'H' Then
         Begin
            sDeHa := 'D';
            dHabeMN := 0;
            dHabeME := 0;
            dDebeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
            dDebeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
         End
         Else
         Begin
            sDeHa := 'H';
            dDebeMN := 0;
            dDebeME := 0;
            dHabeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
            dHabeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
         End;

         cdsMovCNT.Insert;
         cdsMovCNT.FieldByName('CIAID').AsString := xCia;
         cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen;
         cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp2;
         cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
         If (xCtaCaja = cdsQry_C.FieldByName('CUENTAID').AsString) Then
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaCaja;
         If (xCtaRetHaber = cdsQry_C.FieldByName('CUENTAID').AsString) Then
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaRetHaber;

         cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsQry_C.FieldByName('CNTLOTE').AsString;
         cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_C.FieldByName('CLAUXID').AsString;
         cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_C.FieldByName('AUXID').AsString;
         cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_C.FieldByName('CCOSID').AsString;
         cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsQry_C.FieldByName('CNTMODDOC').AsString;
         cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_C.FieldByName('DOCID').AsString;
         cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_C.FieldByName('CNTSERIE').AsString;
         cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_C.FieldByName('CNTNODOC').AsString;
         cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;
         cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
         cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
         cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsQry_C.FieldByName('CNTMTOORI').AsString;
         cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsQry_C.FieldByName('CNTMTOLOC').AsString;
         cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsQry_C.FieldByName('CNTMTOEXT').AsString;
         cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
         cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
      // Inicio : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
      // Fin : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTUSER').AsString := cdsQry_C.FieldByName('CNTUSER').AsString;
         cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsQry_C.FieldByName('CNTFREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsQry_C.FieldByName('CNTHREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTANO').AsString := cdsQry_C.FieldByName('CNTANO').AsString;
         cdsMovCNT.FieldByName('CNTMM').AsString := cdsQry_C.FieldByName('CNTMM').AsString;
         cdsMovCNT.FieldByName('CNTDD').AsString := cdsQry_C.FieldByName('CNTDD').AsString;
         cdsMovCNT.FieldByName('CNTTRI').AsString := cdsQry_C.FieldByName('CNTTRI').AsString;
         cdsMovCNT.FieldByName('CNTSEM').AsString := cdsQry_C.FieldByName('CNTSEM').AsString;
         cdsMovCNT.FieldByName('CNTSS').AsString := cdsQry_C.FieldByName('CNTSS').AsString;
         cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsQry_C.FieldByName('CNTAATRI').AsString;
         cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsQry_C.FieldByName('CNTAASEM').AsString;
         cdsMovCNT.FieldByName('CNTAASS').AsString := cdsQry_C.FieldByName('CNTAASS').AsString;
         cdsMovCNT.FieldByName('TMONID').AsString := cdsQry_C.FieldByName('TMONID').AsString;
         cdsMovCNT.FieldByName('TDIARDES').AsString := cdsQry_C.FieldByName('TDIARDES').AsString;
         cdsMovCNT.FieldByName('AUXDES').AsString := cdsQry_C.FieldByName('AUXDES').AsString;
         cdsMovCNT.FieldByName('DOCDES').AsString := cdsQry_C.FieldByName('DOCDES').AsString;
         cdsMovCNT.FieldByName('CCOSDES').AsString := cdsQry_C.FieldByName('CCOSDES').AsString;
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
         cdsMovCNT.FieldByName('MODULO').AsString := cdsQry_C.FieldByName('MODULO').AsString;
         cdsMovCNT.FieldByName('CNTREG').AsInteger := 1;
         cdsPost(cdsMovCNT);
      End
      Else
      Begin

         //SI LA CUENTA ORIGES ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
         If cdsQry_C.FieldByName('CNTDH').AsString = 'D' Then
         Begin
            sDeHa := 'H';
            dDebeMN := 0;
            dDebeME := 0;
            dHabeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
            dHabeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
         End
         Else
         Begin
            sDeHa := 'D';
            dDebeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
            dDebeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            dHabeMN := 0;
            dHabeME := 0;
         End;

         If (cdsQry_C.FieldByName('CNTMTOLOC').AsFloat = 0) Or
            (cdsQry_C.FieldByName('CNTMTOEXT').AsFloat = 0) Then
         Begin
            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString := xCia;
            cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen;
            cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp2;

            //cdsMovCNT.FieldByName('CUENTAID').AsString   :=cdsQry_C.FieldByName('CUENTAID').AsString;

            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaHaber;
            If xAux_H = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_C.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_C.FieldByName('AUXID').AsString;
            End;
            If xCCos_H = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_C.FieldByName('CCOSID').AsString;
            End;
            cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsQry_C.FieldByName('CNTLOTE').AsString;
            cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsQry_C.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_C.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_C.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_C.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsQry_C.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsQry_C.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsQry_C.FieldByName('CNTMTOEXT').AsString;
            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
         // Inicio : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
         // Fin : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTUSER').AsString := cdsQry_C.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsQry_C.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsQry_C.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString := cdsQry_C.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString := cdsQry_C.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString := cdsQry_C.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString := cdsQry_C.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString := cdsQry_C.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString := cdsQry_C.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsQry_C.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsQry_C.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString := cdsQry_C.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString := cdsQry_C.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString := cdsQry_C.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString := cdsQry_C.FieldByName('AUXDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString := cdsQry_C.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString := cdsQry_C.FieldByName('CCOSDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString := cdsQry_C.FieldByName('MODULO').AsString;
            nReg := nReg + 1;
            cdsMovCNT.FieldByName('CNTREG').AsInteger := nReg;
            cdsPost(cdsMovCNT);

         End
         Else
         Begin
            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString := xCia;
            cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen;
            cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp2;
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaHaber;
            cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsQry_C.FieldByName('CNTLOTE').AsString;
            If xAux_H = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_C.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_C.FieldByName('AUXID').AsString;
            End;
            If xCCos_H = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_C.FieldByName('CCOSID').AsString;
            End;
            cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsQry_C.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_C.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_C.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_C.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsQry_C.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsQry_C.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsQry_C.FieldByName('CNTMTOEXT').AsString;
            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
         // Inicio : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
         // Fin : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTUSER').AsString := cdsQry_C.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsQry_C.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsQry_C.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString := cdsQry_C.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString := cdsQry_C.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString := cdsQry_C.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString := cdsQry_C.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString := cdsQry_C.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString := cdsQry_C.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsQry_C.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsQry_C.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString := cdsQry_C.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString := cdsQry_C.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString := cdsQry_C.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString := cdsQry_C.FieldByName('AUXDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString := cdsQry_C.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString := cdsQry_C.FieldByName('CCOSDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString := cdsQry_C.FieldByName('MODULO').AsString;
            nReg := nReg + 1;
            cdsMovCNT.FieldByName('CNTREG').AsInteger := nReg;
            cdsPost(cdsMovCNT);
         End;
      End;

      cdsQry_C.Next;

   End;

   FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');

// NUEVA MAYORIZACION

   If xTCP = 'CPG' Then
   Begin

      AsientosComplementarios(xCiaOri, xOrigen2, xAnoMM, xNoComp1);

      AsientosComplementarios(xCia, xOrigen, xAnoMM, xNoComp2);

   End;

   xSQLAdicional := 'or ( A.CIAID=' + quotedstr(xCiaOri) + ' AND '
      + 'A.CNTANOMM=' + quotedstr(xAnoMM) + ' AND '
      + 'A.TDIARID=' + quotedstr(xOrigen2) + ' AND '
      + 'A.CNTCOMPROB=' + quotedstr(xNoComp1) + ' ) '
      + 'or ( A.CIAID=' + quotedstr(xCia) + ' AND '
      + 'A.CNTANOMM=' + quotedstr(xAnoMM) + ' AND '
      + 'A.TDIARID=' + quotedstr(xOrigen) + ' AND '
      + 'A.CNTCOMPROB=' + quotedstr(xNoComp2) + ' ) ';

   xSQLAdicional2 := 'or ( A.CIAID=' + quotedstr(xCiaOri) + ' AND '
      + 'A.CNTANOMM=' + quotedstr(xAnoMM) + ' AND '
      + 'A.TDIARID=' + quotedstr(xOrigen2) + ' AND '
      + 'A.CNTCOMPROB=' + quotedstr(xNoComp1) + ' AND '
      + 'A.CIAID=B.CIAID ) '
      + 'or ( A.CIAID=' + quotedstr(xCia) + ' AND '
      + 'A.CNTANOMM=' + quotedstr(xAnoMM) + ' AND '
      + 'A.TDIARID=' + quotedstr(xOrigen) + ' AND '
      + 'A.CNTCOMPROB=' + quotedstr(xNoComp2) + ' AND '
      + 'A.CIAID=B.CIAID ) ';

   xRegAdicional := '1. ' + xCiaOri + '/' + xOrigen2 + '/' + xNoComp1 + ']['
      + '2. ' + xCia + '/' + xOrigen + '/' + xNoComp2;

End;

Procedure TFoaConta.GeneraAsientosComplementarios(xCia, xDiario, xAnoMM, xNoComp, xTCP: String; cdsMovCNT: TwwClientDataSet);
Var
   cdsQryT: TwwClientDataSet;
   xSQL, xWhere: String;
   xCtaCaja: String;
   sDeHa: String;
   dHabeMN, dHabeME, dDebeMN, dDebeME: Double;
   nReg: Integer;
Begin

   // Números de Comprobantes Nuevos
   // Caja Autonoma
   If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
   Begin
      xWhere := 'SELECT COALESCE( MAX( CNTCOMPROB ), ''0'' ) AS NUMERO FROM CNT300 '
         + 'WHERE CIAID=' + '''' + xCiaori + ''''
         + ' and TDIARID=' + '''' + xOrigen2 + ''''
         + ' and CNTANOMM=' + '''' + xAnoMM + '''';
   End;

   If SRV_C = 'ORACLE' Then
   Begin
      xWhere := 'SELECT NVL( MAX( CNTCOMPROB ), ''0'' ) AS NUMERO FROM CNT300 '
         + 'WHERE CIAID=' + '''' + xCiaOri + ''''
         + ' and TDIARID=' + '''' + xOrigen2 + ''''
         + ' and CNTANOMM=' + '''' + xAnoMM + '''';
   End;

   // Verifica si ya tiene comprobantes
   xWhere := 'SELECT ECPERREC FROM CAJA302 '
      + 'WHERE CIAID=' + '''' + xCia + ''''
      + ' and TDIARID=' + '''' + xDiario + ''''
      + ' and ECANOMM=' + '''' + xAnoMM + ''''
      + ' and ECNOCOMP=' + '''' + xNoComp + '''';

   cdsQryT := TwwClientDataSet.Create(Nil);
   cdsQryT.RemoteServer := DCOM_C;
   cdsQryT.ProviderName := Provider_C;

   cdsQryT.Close;
   cdsQryT.DataRequest(xWhere);
   cdsQryT.Open;

   xNoComp1 := '';
   xNoComp2 := '';
   If cdsQryT.FieldByname('ECPERREC').AsString <> '' Then
   Begin
      xNoComp1 := Copy(cdsQryT.FieldByname('ECPERREC').AsString, 10, 10);
      xNoComp2 := Copy(cdsQryT.FieldByname('ECPERREC').AsString, 31, 10);
   End
   Else
   Begin
      // NUMEROS EN CAJA
      If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
      Begin
         xWhere := 'SELECT COALESCE( MAX( ECNOCOMP ), ''0'' ) AS NUMERO FROM CAJA302 '
            + 'WHERE CIAID=' + '''' + xCiaori + ''''
            + ' and TDIARID=' + '''' + xOrigen2 + ''''
            + ' and ECANOMM=' + '''' + xAnoMM + '''';
      End;
      If SRV_C = 'ORACLE' Then
      Begin
         xWhere := 'SELECT NVL( MAX( ECNOCOMP ), ''0'' ) AS NUMERO FROM CAJA302 '
            + 'WHERE CIAID=' + '''' + xCiaOri + ''''
            + ' and TDIARID=' + '''' + xOrigen2 + ''''
            + ' and ECANOMM=' + '''' + xAnoMM + '''';
      End;
      cdsQryT.Close;
      cdsQryT.DataRequest(xWhere);
      cdsQryT.Open;

      xNoComp1 := Inttostr(StrToInt(cdsQryT.FieldByname('NUMERO').AsString) + 1);
      xNoComp1 := StrZero(xNoComp1, 10);
   End;
   // LA CUENTA DE CAJA 10401....
   xSQL := 'SELECT CUENTAID, FCAB, DCDH, TMONID, DCMTOLO, DCMTOEXT FROM CAJA304 '
      + 'WHERE '
      + 'CIAID=' + '''' + xCia + '''' + ' AND '
      + 'TDIARID=' + '''' + xDiario + '''' + ' AND '
      + 'ECANOMM=' + '''' + xAnoMM + '''' + ' AND '
      + 'ECNOCOMP=' + '''' + xNoComp + '''' + ' AND '
      + 'FCAB=''1'' AND DCDH=''H'' ';
   cdsQry_C.Close;
   cdsQry_C.DataRequest(xSQL);
   cdsQry_C.Open;

   xCtaCaja := cdsQry_C.FieldByName('CUENTAID').AsString;

   xSQL := 'SELECT * FROM CNT311 '
      + 'WHERE '
      + 'CIAID=' + '''' + xCia + '''' + ' AND '
      + 'TDIARID=' + '''' + xDiario + '''' + ' AND '
      + 'CNTANOMM=' + '''' + xAnoMM + '''' + ' AND '
      + 'CNTCOMPROB=' + '''' + xNoComp + '''' + ' '
      + 'ORDER BY CNTREG';
   cdsQry_C.Close;
   cdsQry_C.DataRequest(xSQL);
   cdsQry_C.Open;

   cdsMovCNT.Close;
   cdsMovCNT.DataRequest('Select * from CNT311 '
      + 'Where CIAID=''' + xCiaOri + ''' AND TDIARID=''' + xOrigen2 + ''' AND '
      + 'CNTANOMM=''' + xAnoMM + ''' and CNTCOMPROB=''' + xNoComp1 + '''');
   cdsMovCNT.Open;

   nReg := 0;
   While (Not cdsQry_C.Eof) Do
   Begin

      If (xCtaCaja <> cdsQry_C.FieldByName('CUENTAID').AsString) And (xCtaRetHaber <> cdsQry_C.FieldByName('CUENTAID').AsString) Then
      Begin

         If (cdsQry_C.FieldByName('CNTMTOLOC').AsFloat = 0) Or
            (cdsQry_C.FieldByName('CNTMTOEXT').AsFloat = 0) Then
         Begin

            //
            // CUENTAS PRIMER ASIENTO
            //
            If cdsQry_C.FieldByName('CNTDH').AsString = 'D' Then
            Begin
               sDeHa := 'D';
               dHabeMN := 0;
               dHabeME := 0;
               dDebeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
               dDebeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            End
            Else
            Begin
               sDeHa := 'H';
               dDebeMN := 0;
               dDebeME := 0;
               dHabeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
               dHabeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            End;

            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString := xCiaOri;
            cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen2;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp1;
            cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;

            //cdsMovCNT.FieldByName('CUENTAID').AsString   :=cdsQry_C.FieldByName('CUENTAID').AsString;
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaDebe;

            If xAux_D = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_C.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_C.FieldByName('AUXID').AsString;
            End;
            If xCCos_D = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_C.FieldByName('CCOSID').AsString;
            End;
            cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsQry_C.FieldByName('CNTLOTE').AsString;
            cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsQry_C.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_C.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_C.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_C.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsQry_C.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsQry_C.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsQry_C.FieldByName('CNTMTOEXT').AsString;
            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
         // Inicio : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
         // Fin : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTUSER').AsString := cdsQry_C.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsQry_C.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsQry_C.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString := cdsQry_C.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString := cdsQry_C.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString := cdsQry_C.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString := cdsQry_C.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString := cdsQry_C.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString := cdsQry_C.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsQry_C.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsQry_C.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString := cdsQry_C.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString := cdsQry_C.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString := cdsQry_C.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString := cdsQry_C.FieldByName('AUXDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString := cdsQry_C.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString := cdsQry_C.FieldByName('CCOSDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString := cdsQry_C.FieldByName('MODULO').AsString;
            nReg := nReg + 1;
            cdsMovCNT.FieldByName('CNTREG').AsInteger := nReg;
            cdsPost(cdsMovCNT);
         End
         Else
         Begin

            //
            // CUENTAS PRIMER ASIENTO  02
            //
            If cdsQry_C.FieldByName('CNTDH').AsString = 'D' Then
            Begin
               sDeHa := 'D';
               dHabeMN := 0;
               dHabeME := 0;
               dDebeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
               dDebeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            End
            Else
            Begin
               sDeHa := 'H';
               dDebeMN := 0;
               dDebeME := 0;
               dHabeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
               dHabeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            End;

            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString := xCiaOri; // '02'
            cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen2; // '06'
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp1; // '00000511'
            cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaDebe; // '16610'
            cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsQry_C.FieldByName('CNTLOTE').AsString;
            If xAux_D = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_C.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_C.FieldByName('AUXID').AsString;
            End;
            If xCCos_D = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_C.FieldByName('CCOSID').AsString;
            End;
            cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsQry_C.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_C.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_C.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_C.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsQry_C.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsQry_C.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsQry_C.FieldByName('CNTMTOEXT').AsString;

            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
         // Inicio : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
         // Fin : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTUSER').AsString := cdsQry_C.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsQry_C.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsQry_C.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString := cdsQry_C.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString := cdsQry_C.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString := cdsQry_C.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString := cdsQry_C.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString := cdsQry_C.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString := cdsQry_C.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsQry_C.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsQry_C.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString := cdsQry_C.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString := cdsQry_C.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString := cdsQry_C.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString := cdsQry_C.FieldByName('AUXDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString := cdsQry_C.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString := cdsQry_C.FieldByName('CCOSDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString := cdsQry_C.FieldByName('MODULO').AsString;
            nReg := nReg + 1;
            cdsMovCNT.FieldByName('CNTREG').AsInteger := nReg;
            cdsPost(cdsMovCNT);
         End;
      End
      Else
      Begin

         //SI LA CUENTA ORIGES ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
         If cdsQry_C.FieldByName('CNTDH').AsString = 'H' Then
         Begin
            sDeHa := 'H';
            dDebeMN := 0;
            dDebeME := 0;
            dHabeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
            dHabeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
         End
         Else
         Begin
            sDeHa := 'D';
            dDebeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
            dDebeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            dHabeMN := 0;
            dHabeME := 0;
         End;

         cdsMovCNT.Insert;
         cdsMovCNT.FieldByName('CIAID').AsString := xCiaOri;
         cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen2;
         cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp1;
         cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
         If (cdsQry_C.FieldByName('CUENTAID').AsString = xCtaRetHaber) Then
         Begin
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaRetDebe;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := xGlosaRetDebe;
         End;
         If (cdsQry_C.FieldByName('CUENTAID').AsString = xCtaCaja) Then
         Begin
            cdsMovCNT.FieldByName('CUENTAID').AsString := cdsQry_C.FieldByName('CUENTAID').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;
         End;

         cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsQry_C.FieldByName('CNTLOTE').AsString;
         cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_C.FieldByName('CLAUXID').AsString;
         cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_C.FieldByName('AUXID').AsString;
         cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_C.FieldByName('CCOSID').AsString;
         cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsQry_C.FieldByName('CNTMODDOC').AsString;
         cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_C.FieldByName('DOCID').AsString;
         cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_C.FieldByName('CNTSERIE').AsString;
         cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_C.FieldByName('CNTNODOC').AsString;

// aqui estaba la glosa

         cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
         cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
         cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsQry_C.FieldByName('CNTMTOORI').AsString;
         cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsQry_C.FieldByName('CNTMTOLOC').AsString;
         cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsQry_C.FieldByName('CNTMTOEXT').AsString;
         cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
         cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
      // Inicio : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
      // Fin : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTUSER').AsString := cdsQry_C.FieldByName('CNTUSER').AsString;
         cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsQry_C.FieldByName('CNTFREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsQry_C.FieldByName('CNTHREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTANO').AsString := cdsQry_C.FieldByName('CNTANO').AsString;
         cdsMovCNT.FieldByName('CNTMM').AsString := cdsQry_C.FieldByName('CNTMM').AsString;
         cdsMovCNT.FieldByName('CNTDD').AsString := cdsQry_C.FieldByName('CNTDD').AsString;
         cdsMovCNT.FieldByName('CNTTRI').AsString := cdsQry_C.FieldByName('CNTTRI').AsString;
         cdsMovCNT.FieldByName('CNTSEM').AsString := cdsQry_C.FieldByName('CNTSEM').AsString;
         cdsMovCNT.FieldByName('CNTSS').AsString := cdsQry_C.FieldByName('CNTSS').AsString;
         cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsQry_C.FieldByName('CNTAATRI').AsString;
         cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsQry_C.FieldByName('CNTAASEM').AsString;
         cdsMovCNT.FieldByName('CNTAASS').AsString := cdsQry_C.FieldByName('CNTAASS').AsString;
         cdsMovCNT.FieldByName('TMONID').AsString := cdsQry_C.FieldByName('TMONID').AsString;
         cdsMovCNT.FieldByName('TDIARDES').AsString := cdsQry_C.FieldByName('TDIARDES').AsString;
         cdsMovCNT.FieldByName('AUXDES').AsString := cdsQry_C.FieldByName('AUXDES').AsString;
         cdsMovCNT.FieldByName('DOCDES').AsString := cdsQry_C.FieldByName('DOCDES').AsString;
         cdsMovCNT.FieldByName('CCOSDES').AsString := cdsQry_C.FieldByName('CCOSDES').AsString;
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
         cdsMovCNT.FieldByName('MODULO').AsString := cdsQry_C.FieldByName('MODULO').AsString;
         nReg := nReg + 1;
         cdsMovCNT.FieldByName('CNTREG').AsInteger := nReg;
         cdsPost(cdsMovCNT);
      End;
      cdsQry_C.Next;
   End;

   FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');

   /////////////////////////////////
   //  CUENTAS SEGUNDO ASIENTO    //
   /////////////////////////////////

   If xNoComp2 = '' Then
   Begin

      // Caja Autonoma
      If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
      Begin
         xWhere := 'SELECT COALESCE( MAX( CNTCOMPROB ), ''0'' ) AS NUMERO FROM CNT300 '
            + 'WHERE CIAID=' + '''' + xCia + ''''
            + ' and TDIARID=' + '''' + xOrigen + ''''
            + ' and CNTANOMM=' + '''' + xAnoMM + '''';
      End;

      If SRV_C = 'ORACLE' Then
      Begin
         xWhere := 'SELECT NVL( MAX( CNTCOMPROB ), ''0'' ) AS NUMERO FROM CNT300 '
            + 'WHERE CIAID=' + '''' + xCia + ''''
            + ' and TDIARID=' + '''' + xOrigen + ''''
            + ' and CNTANOMM=' + '''' + xAnoMM + '''';
      End;
      cdsQryT.Close;
      cdsQryT.DataRequest(xWhere);
      cdsQryT.Open;

      xNoComp2 := Inttostr(StrToInt(cdsQryT.FieldByname('NUMERO').AsString) + 1);
      xNoComp2 := StrZero(xNoComp1, 10);

   End;

   cdsMovCNT.Close;
   cdsMovCNT.DataRequest('Select * from CNT311 '
      + 'Where CIAID=''' + xCia + ''' AND TDIARID=''' + xOrigen + ''' AND '
      + 'CNTANOMM=''' + xAnoMM + ''' and CNTCOMPROB=''' + xNoComp2 + '''');
   cdsMovCNT.Open;

   nReg := 1;

   cdsQry_C.First;
   While (Not cdsQry_C.Eof) Do
   Begin

      If (xCtaCaja = cdsQry_C.FieldByName('CUENTAID').AsString) Or (xCtaRetHaber = cdsQry_C.FieldByName('CUENTAID').AsString) Then
      Begin

         If cdsQry_C.FieldByName('CNTDH').AsString = 'H' Then
         Begin
            sDeHa := 'D';
            dHabeMN := 0;
            dHabeME := 0;
            dDebeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
            dDebeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
         End
         Else
         Begin
            sDeHa := 'H';
            dDebeMN := 0;
            dDebeME := 0;
            dHabeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
            dHabeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
         End;

         cdsMovCNT.Insert;
         cdsMovCNT.FieldByName('CIAID').AsString := xCia;
         cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen;
         cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp2;
         cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
         If (xCtaCaja = cdsQry_C.FieldByName('CUENTAID').AsString) Then
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaCaja;
         If (xCtaRetHaber = cdsQry_C.FieldByName('CUENTAID').AsString) Then
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaRetHaber;

         cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsQry_C.FieldByName('CNTLOTE').AsString;
         cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_C.FieldByName('CLAUXID').AsString;
         cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_C.FieldByName('AUXID').AsString;
         cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_C.FieldByName('CCOSID').AsString;
         cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsQry_C.FieldByName('CNTMODDOC').AsString;
         cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_C.FieldByName('DOCID').AsString;
         cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_C.FieldByName('CNTSERIE').AsString;
         cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_C.FieldByName('CNTNODOC').AsString;
         cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;
         cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
         cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
         cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsQry_C.FieldByName('CNTMTOORI').AsString;
         cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsQry_C.FieldByName('CNTMTOLOC').AsString;
         cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsQry_C.FieldByName('CNTMTOEXT').AsString;
         cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
         cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
      // Inicio : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
      // Fin : HPC_201301_CNT
         cdsMovCNT.FieldByName('CNTUSER').AsString := cdsQry_C.FieldByName('CNTUSER').AsString;
         cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsQry_C.FieldByName('CNTFREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsQry_C.FieldByName('CNTHREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTANO').AsString := cdsQry_C.FieldByName('CNTANO').AsString;
         cdsMovCNT.FieldByName('CNTMM').AsString := cdsQry_C.FieldByName('CNTMM').AsString;
         cdsMovCNT.FieldByName('CNTDD').AsString := cdsQry_C.FieldByName('CNTDD').AsString;
         cdsMovCNT.FieldByName('CNTTRI').AsString := cdsQry_C.FieldByName('CNTTRI').AsString;
         cdsMovCNT.FieldByName('CNTSEM').AsString := cdsQry_C.FieldByName('CNTSEM').AsString;
         cdsMovCNT.FieldByName('CNTSS').AsString := cdsQry_C.FieldByName('CNTSS').AsString;
         cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsQry_C.FieldByName('CNTAATRI').AsString;
         cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsQry_C.FieldByName('CNTAASEM').AsString;
         cdsMovCNT.FieldByName('CNTAASS').AsString := cdsQry_C.FieldByName('CNTAASS').AsString;
         cdsMovCNT.FieldByName('TMONID').AsString := cdsQry_C.FieldByName('TMONID').AsString;
         cdsMovCNT.FieldByName('TDIARDES').AsString := cdsQry_C.FieldByName('TDIARDES').AsString;
         cdsMovCNT.FieldByName('AUXDES').AsString := cdsQry_C.FieldByName('AUXDES').AsString;
         cdsMovCNT.FieldByName('DOCDES').AsString := cdsQry_C.FieldByName('DOCDES').AsString;
         cdsMovCNT.FieldByName('CCOSDES').AsString := cdsQry_C.FieldByName('CCOSDES').AsString;
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
         cdsMovCNT.FieldByName('MODULO').AsString := cdsQry_C.FieldByName('MODULO').AsString;
         cdsMovCNT.FieldByName('CNTREG').AsInteger := 1;
         cdsPost(cdsMovCNT);
      End
      Else
      Begin

         //SI LA CUENTA ORIGES ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
         If cdsQry_C.FieldByName('CNTDH').AsString = 'D' Then
         Begin
            sDeHa := 'H';
            dDebeMN := 0;
            dDebeME := 0;
            dHabeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
            dHabeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
         End
         Else
         Begin
            sDeHa := 'D';
            dDebeMN := cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
            dDebeME := cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            dHabeMN := 0;
            dHabeME := 0;
         End;

         If (cdsQry_C.FieldByName('CNTMTOLOC').AsFloat = 0) Or
            (cdsQry_C.FieldByName('CNTMTOEXT').AsFloat = 0) Then
         Begin
            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString := xCia;
            cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen;
            cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp2;

            //cdsMovCNT.FieldByName('CUENTAID').AsString   :=cdsQry_C.FieldByName('CUENTAID').AsString;

            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaHaber;
            If xAux_H = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_C.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_C.FieldByName('AUXID').AsString;
            End;
            If xCCos_H = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_C.FieldByName('CCOSID').AsString;
            End;
            cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsQry_C.FieldByName('CNTLOTE').AsString;
            cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsQry_C.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_C.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_C.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_C.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsQry_C.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsQry_C.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsQry_C.FieldByName('CNTMTOEXT').AsString;
            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
         // Inicio : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
         // Fin : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTUSER').AsString := cdsQry_C.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsQry_C.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsQry_C.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString := cdsQry_C.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString := cdsQry_C.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString := cdsQry_C.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString := cdsQry_C.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString := cdsQry_C.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString := cdsQry_C.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsQry_C.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsQry_C.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString := cdsQry_C.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString := cdsQry_C.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString := cdsQry_C.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString := cdsQry_C.FieldByName('AUXDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString := cdsQry_C.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString := cdsQry_C.FieldByName('CCOSDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString := cdsQry_C.FieldByName('MODULO').AsString;
            nReg := nReg + 1;
            cdsMovCNT.FieldByName('CNTREG').AsInteger := nReg;
            cdsPost(cdsMovCNT);

         End
         Else
         Begin
            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString := xCia;
            cdsMovCNT.FieldByName('TDIARID').AsString := xOrigen;
            cdsMovCNT.FieldByName('CNTANOMM').AsString := xAnoMM;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString := xNoComp2;
            cdsMovCNT.FieldByName('CUENTAID').AsString := xCtaHaber;
            cdsMovCNT.FieldByName('CNTLOTE').AsString := cdsQry_C.FieldByName('CNTLOTE').AsString;
            If xAux_H = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CLAUXID').AsString := cdsQry_C.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString := cdsQry_C.FieldByName('AUXID').AsString;
            End;
            If xCCos_H = 'S' Then
            Begin
               cdsMovCNT.FieldByName('CCOSID').AsString := cdsQry_C.FieldByName('CCOSID').AsString;
            End;
            cdsMovCNT.FieldByName('CNTMODDOC').AsString := cdsQry_C.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString := cdsQry_C.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString := cdsQry_C.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString := cdsQry_C.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString := cdsQry_C.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString := sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString := cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString := cdsQry_C.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString := cdsQry_C.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString := cdsQry_C.FieldByName('CNTMTOEXT').AsString;
            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime := cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString := 'P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString := 'S';
         // Inicio : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString := 'S';
         // Fin : HPC_201301_CNT
            cdsMovCNT.FieldByName('CNTUSER').AsString := cdsQry_C.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime := cdsQry_C.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime := cdsQry_C.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString := cdsQry_C.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString := cdsQry_C.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString := cdsQry_C.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString := cdsQry_C.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString := cdsQry_C.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString := cdsQry_C.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString := cdsQry_C.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString := cdsQry_C.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString := cdsQry_C.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString := cdsQry_C.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString := cdsQry_C.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString := cdsQry_C.FieldByName('AUXDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString := cdsQry_C.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString := cdsQry_C.FieldByName('CCOSDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat := dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat := dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat := dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat := dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString := cdsQry_C.FieldByName('MODULO').AsString;
            nReg := nReg + 1;
            cdsMovCNT.FieldByName('CNTREG').AsInteger := nReg;
            cdsPost(cdsMovCNT);
         End;
      End;

      cdsQry_C.Next;

   End;

   FoaConta.AplicaDatos(cdsMovCNT, 'MOVCNT');

// NUEVA MAYORIZACION

   If xTCP = 'CCNA' Then
   Begin

      AsientosComplementarios(xCiaOri, xOrigen2, xAnoMM, xNoComp1);

      AsientosComplementarios(xCia, xOrigen, xAnoMM, xNoComp2);

   End;

   xSQLAdicional := 'or ( A.CIAID=' + quotedstr(xCiaOri) + ' AND '
      + 'A.CNTANOMM=' + quotedstr(xAnoMM) + ' AND '
      + 'A.TDIARID=' + quotedstr(xOrigen2) + ' AND '
      + 'A.CNTCOMPROB=' + quotedstr(xNoComp1) + ' ) '
      + 'or ( A.CIAID=' + quotedstr(xCia) + ' AND '
      + 'A.CNTANOMM=' + quotedstr(xAnoMM) + ' AND '
      + 'A.TDIARID=' + quotedstr(xOrigen) + ' AND '
      + 'A.CNTCOMPROB=' + quotedstr(xNoComp2) + ' ) ';

   xSQLAdicional2 := 'or ( A.CIAID=' + quotedstr(xCiaOri) + ' AND '
      + 'A.CNTANOMM=' + quotedstr(xAnoMM) + ' AND '
      + 'A.TDIARID=' + quotedstr(xOrigen2) + ' AND '
      + 'A.CNTCOMPROB=' + quotedstr(xNoComp1) + ' AND '
      + 'A.CIAID=B.CIAID ) '
      + 'or ( A.CIAID=' + quotedstr(xCia) + ' AND '
      + 'A.CNTANOMM=' + quotedstr(xAnoMM) + ' AND '
      + 'A.TDIARID=' + quotedstr(xOrigen) + ' AND '
      + 'A.CNTCOMPROB=' + quotedstr(xNoComp2) + ' AND '
      + 'A.CIAID=B.CIAID ) ';

   xRegAdicional := '1. ' + xCiaOri + '/' + xOrigen2 + '/' + xNoComp1 + ']['
      + '2. ' + xCia + '/' + xOrigen + '/' + xNoComp2;

End;

Procedure TFoaConta.cdsPost(xxCds: TwwClientDataSet);
Var
   i: integer;
Begin
   For i := 0 To xxCds.Fields.Count - 1 Do
   Begin
      If xxCds.Fields[i].ClassType = TStringField Then
      Begin
         If (xxCds.Fields[i].AsString = '') Then
            xxCds.Fields[i].CLEAR;
      End;

      If xxCds.Fields[i].ClassType = TMemoField Then
      Begin
         If (xxCds.Fields[i].AsString = '') Or (xxCds.Fields[i].AsString = ' ') Then xxCds.Fields[i].AsString := '.';
      End;

   End;
End;

Procedure TFoaConta.AsientosComplementarios(xCia, xDiario, xAnoMM, xNoComp: String);
Var
   xSQL: String;
Begin
   xSQL := 'Insert into CNT301 ('
      + ' CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
      + 'CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
      + 'CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
      + 'CNTFEMIS, CNTFVCMTO, CNTFCOMP, CNTESTADO, CNTCUADRE, CNTFAUTOM, '
      + 'CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
      + 'CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
      + 'TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
      + 'CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
      + 'CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
      + 'CNTMODDOC, CNTREG, MODULO, CTA_SECU ) '
      + 'Select CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
      + 'CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
      + 'CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
      + 'CNTFEMIS, CNTFVCMTO, CNTFCOMP, ''P'', ''S'', CNTFAUTOM, '
      + 'CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
      + 'CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
      + 'TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
      + 'CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
      + 'CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
      + 'CNTMODDOC, CNTREG, MODULO, CTA_SECU '
      + 'From CNT311 Where '
      + 'CIAID=' + '''' + xCia + '''' + ' AND '
      + 'TDIARID=' + '''' + xDiario + '''' + ' AND '
      + 'CNTANOMM=' + '''' + xAnoMM + '''' + ' AND '
      + 'CNTCOMPROB=' + '''' + xNoComp + '''';
   Try
      cdsQry_C.Close;
      cdsQry_C.DataRequest(xSQL);
      cdsQry_C.Execute;
   Except
      Errorcount2 := 1;
      Exit;
   End;

   // Genera Cabecera si Modulo no es Contabilidad
   xSQL := 'SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB ';
   xSQL := xSQL + 'FROM ' + CNTCab + ' A ';
   xSQL := xSQL + 'WHERE A.CIAID=' + '''' + xCia + '''' + ' and ';
   xSQL := xSQL + 'A.TDIARID=' + '''' + xDiario + '''' + ' and ';
   xSQL := xSQL + 'A.CNTANOMM=' + '''' + xAnoMM + '''' + ' and ';
   xSQL := xSQL + 'A.CNTCOMPROB=' + '''' + xNoComp + '''' + ' ';

   cdsQry_C.Close;
   cdsQry_C.DataRequest(xSQL);
   cdsQry_C.Open;

   If cdsQry_C.RecordCount <= 0 Then
   Begin

      xSQL := 'INSERT INTO ' + CNTCab;
      xSQL := xSQL + '( CIAID, TDIARID, CNTANOMM, CNTCOMPROB, CNTLOTE, ';
      xSQL := xSQL + 'CNTGLOSA, CNTTCAMBIO, CNTFCOMP, CNTESTADO, CNTCUADRE, ';
      xSQL := xSQL + 'CNTUSER, CNTFREG, CNTHREG, CNTANO, CNTMM, CNTDD, CNTTRI, ';
      xSQL := xSQL + 'CNTSEM, CNTSS, CNTAATRI, CNTAASEM, CNTAASS, TMONID, ';
      xSQL := xSQL + 'FLAGVAR, TDIARDES, CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, ';
      xSQL := xSQL + 'CNTTS, DOCMOD, MODULO ) ';
      xSQL := xSQL + 'SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB,  A.CNTLOTE, ';
      xSQL := xSQL + 'DECODE( MIN(A.CNTREG), 1, MAX( A.CNTGLOSA ), ''COMPROBANTE DE ''||MAX(MODULO) ), ';
      xSQL := xSQL + 'MAX( NVL( A.CNTTCAMBIO, 0 ) ), ';
      xSQL := xSQL + 'A.CNTFCOMP, ''P'', ''S'', ';
      xSQL := xSQL + 'MAX( CNTUSER ), MAX( CNTFREG ), MAX( CNTHREG ), A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI, ';
      xSQL := xSQL + 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
      xSQL := xSQL + 'CASE WHEN SUM( CASE WHEN TMONID=''' + wTMonExt_C + ''' THEN 1 ELSE 0 END )>'
         + ' SUM( CASE WHEN TMONID=''' + wTMonLoc_C + ''' THEN 1 ELSE 0 END ) '
         + ' THEN ''' + wTMonExt_C + ''' ELSE ''' + wTMonLoc_C + ''' END, ';
      xSQL := xSQL + ''' '', A.TDIARDES, ';
      xSQL := xSQL + 'SUM(A.CNTDEBEMN), SUM(A.CNTDEBEME), SUM(A.CNTHABEMN), SUM(A.CNTHABEME), ';
      xSQL := xSQL + 'MAX( CNTTS ), MAX( CNTMODDOC), MAX( MODULO ) ';
      xSQL := xSQL + 'FROM ' + CNTDet + ' A ';
      xSQL := xSQL + 'WHERE A.CIAID=' + '''' + xCia + '''' + ' AND ';
      xSQL := xSQL + 'A.TDIARID=' + '''' + xDiario + '''' + ' AND ';
      xSQL := xSQL + 'A.CNTANOMM=' + '''' + xAnoMM + ''' ';
      xSQL := xSQL + 'AND A.CNTCOMPROB=' + '''' + xNoComp + '''' + ' ';
      xSQL := xSQL + 'GROUP BY A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB, A.CNTLOTE, ';
      xSQL := xSQL + 'A.CNTFCOMP, A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI,  ';
      xSQL := xSQL + 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
      xSQL := xSQL + 'A.TDIARDES';
      Try
         cdsQry_C.Close;
         cdsQry_C.DataRequest(xSQL);
         cdsQry_C.Execute;
      Except
         Errorcount2 := 1;
         Exit;
      End;
   End;

   FoaConta.GeneraEnLinea401(xCia, xDiario, xAnoMM, xNoComp, 'S');
End;

Function SOLPresupuesto(xCia, xUsuario, xNumero, xSRV, xModulo: String;
   cdsResultSetx: TwwClientDataSet;
   DCOMx: TSocketConnection;
   xForm_C: TForm; xTipoMay: String): Boolean;
Var
   sSQL, xNREG, xSQL, xCajaAut, xSQL1: String;
   xNumT, iOrdenx: Integer;
   sCIA, sCuenta, sDeHa: String;
   dDebeMN, dHabeMN, dDebeME, dHabeME: double;
   cdsClone: TwwClientDataSet;
   cdsAsiento: TwwClientDataSet;
Begin
   CNTDet := 'PPRES311';

   FoaConta.CreaPanel(xForm_C, 'Generando Presupuestos');

   DCOM_C := DCOMx;
   SRV_C := xSRV;

   wTMay := xTipoMay;
   wOrigenPRE := xModulo;

   If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
   Begin
      wReplaCeros := 'COALESCE';
   End
   Else
      If SRV_C = 'ORACLE' Then
      Begin
         wReplaCeros := 'NVL';
      End;

   Provider_C := 'dspTem6';

   cdsResultSet_C := cdsResultSetx;

   cdsPresup_C := TwwClientDataSet.Create(Nil);
   cdsPresup_C.RemoteServer := DCOMx;
   cdsPresup_C.ProviderName := 'dspTem5';

   cdsQry_C := TwwClientDataSet.Create(Nil);
   cdsQry_C.RemoteServer := DCOMx;
   cdsQry_C.ProviderName := Provider_C;

   xSQL := 'Select A.CIAID, A.USUARIO, A.ANO, A.MES, A.NUMERO, A.TIPPRESID, A.PARPRESID, '
      + 'A.TIPOCOL, A.RQPARTIS, A.TMONID, A.MONTOMN, A.MONTOME, A.CCOSID, FMAYOR, '
      + 'MONTOMN01, MONTOME01, MONTOMN02, MONTOME02, MONTOMN03, MONTOME03, '
      + 'MONTOMN04, MONTOME04, MONTOMN05, MONTOME05, MONTOMN06, MONTOME06, '
      + 'MONTOMN07, MONTOME07, MONTOMN08, MONTOME08, MONTOMN09, MONTOME09, '
      + 'MONTOMN10, MONTOME10, MONTOMN11, MONTOME11, MONTOMN12, MONTOME12  '
      + 'FROM PPRES311 A '
      + 'WHERE A.CIAID  =' + QuotedStr(xCia)
      + ' AND A.USUARIO=' + QuotedStr(xUsuario)
      + ' AND A.NUMERO =' + QuotedStr(xNumero);
   cdsPresup_C.Close;
   cdsPresup_C.DataRequest(xSQL);
   cdsPresup_C.Open;

   // Se Añade Para Mayorizar Solamente
   {
   if (xTipoC='M') then begin
      FoaConta.GeneraEnLinea401( xCia, xTDiario, xAnoMM, xNoComp, 'S' );
      pnlConta_C.Free;
      cdsNivel_C := NIL;
      cdsNivelx  := NIL;

      if Errorcount2>0 then Exit;

      Result:=True ;
      Exit;
   end;

   }
   FoaConta.PanelMsg('Generando Presupuestos Automaticos', 0);

   // GENERA ASIENTOS AUTOMATICOS PARA LA CUENTA 1

   cdsClone := TwwClientDataSet.Create(Nil);
   cdsClone.RemoteServer := DCOMx;
   cdsClone.ProviderName := Provider_C;
   cdsClone.Close;

   sSQL := 'Select A.CIAID, A.USUARIO, A.ANO, A.MES, A.NUMERO, A.TIPPRESID, A.PARPRESID, '
      + 'A.TIPOCOL, A.RQPARTIS, A.TMONID, A.MONTOMN, A.MONTOME, B.PARPRESDES, '
      + 'B.PARPRESAUT1, B.PARPRESAUT2, B.ASIENTOID, A.CCOSID, '
      + 'MONTOMN01, MONTOME01, MONTOMN02, MONTOME02, MONTOMN03, MONTOME03, '
      + 'MONTOMN04, MONTOME04, MONTOMN05, MONTOME05, MONTOMN06, MONTOME06, '
      + 'MONTOMN07, MONTOME07, MONTOMN08, MONTOME08, MONTOMN09, MONTOME09, '
      + 'MONTOMN10, MONTOME10, MONTOMN11, MONTOME11, MONTOMN12, MONTOME12  '
      + 'FROM PPRES311 A, PPRES201 B '
      + 'WHERE A.CIAID  =' + QuotedStr(xCia)
      + ' AND A.USUARIO=' + QuotedStr(xUsuario)
      + ' AND A.NUMERO =' + QuotedStr(xNumero)
      + ' AND A.CIAID=B.CIAID AND A.TIPPRESID=B.TIPPRESID '
      + ' AND A.PARPRESID=B.PARPRESID AND A.PROCE=B.PROCE ';

   cdsClone.DataRequest(sSQL);
   cdsClone.Open;

   FoaConta.PanelMsg('Generando Presupuestos Automaticos', 0);

   cdsClone.First;
   While Not cdsClone.EOF Do
   Begin
      sCia := cdsClone.FieldByName('CIAID').AsString;
      sCuenta := cdsClone.FieldByName('PARPRESID').AsString;

     //SI TIENE CUENTA AUTOMATICA 1 y 2
      If (cdsClone.FieldByName('PARPRESAUT1').AsString <> '') And
         (cdsClone.FieldByName('PARPRESAUT2').AsString <> '') Then
      Begin
       //SI LA CUENTA ORIGES ESTA DESTINADA AL DEBE LA CUENTA AUTOMATICA 1 IRA AL HABER
         If cdsClone.FieldByName('RQPARTIS').AsString = 'I' Then
            sDeHa := 'I'
         Else
         Begin
            sDeHa := 'S';
         End;
         cdsPresup_C.Insert;
         cdsPresup_C.FieldByName('CIAID').AsString := cdsClone.FieldByName('CIAID').AsString;
         cdsPresup_C.FieldByName('USUARIO').AsString := cdsClone.FieldByName('USUARIO').AsString;
         cdsPresup_C.FieldByName('NUMERO').AsString := cdsClone.FieldByName('NUMERO').AsString;
         cdsPresup_C.FieldByName('ANO').AsString := cdsClone.FieldByName('ANO').AsString;
         cdsPresup_C.FieldByName('MES').AsString := cdsClone.FieldByName('MES').AsString;
         cdsPresup_C.FieldByName('TIPPRESID').AsString := cdsClone.FieldByName('TIPPRESID').AsString;
         cdsPresup_C.FieldByName('PARPRESID').AsString := cdsClone.FieldByName('PARPRESAUT1').AsString;
         cdsPresup_C.FieldByName('CCOSID').AsString := cdsClone.FieldByName('CCOSID').AsString;
         cdsPresup_C.FieldByName('RQPARTIS').AsString := sDeHa;
         cdsPresup_C.FieldByName('TMONID').AsString := cdsClone.FieldByName('TMONID').AsString;
         cdsPresup_C.FieldByName('MONTOMN').AsFloat := cdsClone.FieldByName('MONTOMN').AsFloat;
         cdsPresup_C.FieldByName('MONTOME').AsFloat := cdsClone.FieldByName('MONTOME').AsFloat;
         cdsPresup_C.FieldByName('TIPOCOL').AsString := cdsClone.FieldByName('TIPOCOL').AsString;
         cdsPresup_C.FieldByName('FMAYOR').AsString := 'N';

       // Para Mayorizar Anual
         cdsPresup_C.FieldByName('MONTOMN01').AsFloat := cdsClone.FieldByName('MONTOMN01').AsFloat;
         cdsPresup_C.FieldByName('MONTOME01').AsFloat := cdsClone.FieldByName('MONTOME01').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN02').AsFloat := cdsClone.FieldByName('MONTOMN02').AsFloat;
         cdsPresup_C.FieldByName('MONTOME02').AsFloat := cdsClone.FieldByName('MONTOME02').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN03').AsFloat := cdsClone.FieldByName('MONTOMN03').AsFloat;
         cdsPresup_C.FieldByName('MONTOME03').AsFloat := cdsClone.FieldByName('MONTOME03').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN04').AsFloat := cdsClone.FieldByName('MONTOMN04').AsFloat;
         cdsPresup_C.FieldByName('MONTOME04').AsFloat := cdsClone.FieldByName('MONTOME04').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN05').AsFloat := cdsClone.FieldByName('MONTOMN05').AsFloat;
         cdsPresup_C.FieldByName('MONTOME05').AsFloat := cdsClone.FieldByName('MONTOME05').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN06').AsFloat := cdsClone.FieldByName('MONTOMN06').AsFloat;
         cdsPresup_C.FieldByName('MONTOME06').AsFloat := cdsClone.FieldByName('MONTOME06').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN07').AsFloat := cdsClone.FieldByName('MONTOMN07').AsFloat;
         cdsPresup_C.FieldByName('MONTOME07').AsFloat := cdsClone.FieldByName('MONTOME07').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN08').AsFloat := cdsClone.FieldByName('MONTOMN08').AsFloat;
         cdsPresup_C.FieldByName('MONTOME08').AsFloat := cdsClone.FieldByName('MONTOME08').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN09').AsFloat := cdsClone.FieldByName('MONTOMN09').AsFloat;
         cdsPresup_C.FieldByName('MONTOME09').AsFloat := cdsClone.FieldByName('MONTOME09').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN10').AsFloat := cdsClone.FieldByName('MONTOMN10').AsFloat;
         cdsPresup_C.FieldByName('MONTOME10').AsFloat := cdsClone.FieldByName('MONTOME10').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN11').AsFloat := cdsClone.FieldByName('MONTOMN11').AsFloat;
         cdsPresup_C.FieldByName('MONTOME11').AsFloat := cdsClone.FieldByName('MONTOME11').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN12').AsFloat := cdsClone.FieldByName('MONTOMN12').AsFloat;
         cdsPresup_C.FieldByName('MONTOME12').AsFloat := cdsClone.FieldByName('MONTOME12').AsFloat;
       //

       //cdsMovCNT.FieldByName('MODULO').AsString  :=cdsClone.FieldByName('MODULO').AsString;
       //cdsMovCNT.FieldByName('CNTREG').AsInteger :=iOrden;
         iOrden := iOrden + 1;

       //SI LA CUENTA ORIGES ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
         If cdsClone.FieldByName('RQPARTIS').AsString = 'I' Then
            sDeHa := 'S'
         Else
         Begin
            sDeHa := 'I';
         End;

         cdsPresup_C.Insert;
         cdsPresup_C.FieldByName('CIAID').AsString := cdsClone.FieldByName('CIAID').AsString;
         cdsPresup_C.FieldByName('USUARIO').AsString := cdsClone.FieldByName('USUARIO').AsString;
         cdsPresup_C.FieldByName('NUMERO').AsString := cdsClone.FieldByName('NUMERO').AsString;
         cdsPresup_C.FieldByName('ANO').AsString := cdsClone.FieldByName('ANO').AsString;
         cdsPresup_C.FieldByName('MES').AsString := cdsClone.FieldByName('MES').AsString;
         cdsPresup_C.FieldByName('TIPPRESID').AsString := cdsClone.FieldByName('TIPPRESID').AsString;
         cdsPresup_C.FieldByName('PARPRESID').AsString := cdsClone.FieldByName('PARPRESAUT2').AsString;
         cdsPresup_C.FieldByName('CCOSID').AsString := cdsClone.FieldByName('CCOSID').AsString;
         cdsPresup_C.FieldByName('RQPARTIS').AsString := sDeHa;
         cdsPresup_C.FieldByName('TMONID').AsString := cdsClone.FieldByName('TMONID').AsString;
         cdsPresup_C.FieldByName('MONTOMN').AsFloat := cdsClone.FieldByName('MONTOMN').AsFloat;
         cdsPresup_C.FieldByName('MONTOME').AsFloat := cdsClone.FieldByName('MONTOME').AsFloat;
         cdsPresup_C.FieldByName('TIPOCOL').AsString := cdsClone.FieldByName('TIPOCOL').AsString;
         cdsPresup_C.FieldByName('FMAYOR').AsString := 'N';

       // Para Mayorizar Anual
         cdsPresup_C.FieldByName('MONTOMN01').AsFloat := cdsClone.FieldByName('MONTOMN01').AsFloat;
         cdsPresup_C.FieldByName('MONTOME01').AsFloat := cdsClone.FieldByName('MONTOME01').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN02').AsFloat := cdsClone.FieldByName('MONTOMN02').AsFloat;
         cdsPresup_C.FieldByName('MONTOME02').AsFloat := cdsClone.FieldByName('MONTOME02').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN03').AsFloat := cdsClone.FieldByName('MONTOMN03').AsFloat;
         cdsPresup_C.FieldByName('MONTOME03').AsFloat := cdsClone.FieldByName('MONTOME03').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN04').AsFloat := cdsClone.FieldByName('MONTOMN04').AsFloat;
         cdsPresup_C.FieldByName('MONTOME04').AsFloat := cdsClone.FieldByName('MONTOME04').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN05').AsFloat := cdsClone.FieldByName('MONTOMN05').AsFloat;
         cdsPresup_C.FieldByName('MONTOME05').AsFloat := cdsClone.FieldByName('MONTOME05').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN06').AsFloat := cdsClone.FieldByName('MONTOMN06').AsFloat;
         cdsPresup_C.FieldByName('MONTOME06').AsFloat := cdsClone.FieldByName('MONTOME06').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN07').AsFloat := cdsClone.FieldByName('MONTOMN07').AsFloat;
         cdsPresup_C.FieldByName('MONTOME07').AsFloat := cdsClone.FieldByName('MONTOME07').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN08').AsFloat := cdsClone.FieldByName('MONTOMN08').AsFloat;
         cdsPresup_C.FieldByName('MONTOME08').AsFloat := cdsClone.FieldByName('MONTOME08').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN09').AsFloat := cdsClone.FieldByName('MONTOMN09').AsFloat;
         cdsPresup_C.FieldByName('MONTOME09').AsFloat := cdsClone.FieldByName('MONTOME09').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN10').AsFloat := cdsClone.FieldByName('MONTOMN10').AsFloat;
         cdsPresup_C.FieldByName('MONTOME10').AsFloat := cdsClone.FieldByName('MONTOME10').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN11').AsFloat := cdsClone.FieldByName('MONTOMN11').AsFloat;
         cdsPresup_C.FieldByName('MONTOME11').AsFloat := cdsClone.FieldByName('MONTOME11').AsFloat;
         cdsPresup_C.FieldByName('MONTOMN12').AsFloat := cdsClone.FieldByName('MONTOMN12').AsFloat;
         cdsPresup_C.FieldByName('MONTOME12').AsFloat := cdsClone.FieldByName('MONTOME12').AsFloat;
       //
         iOrden := iOrden + 1;

         FoaConta.AplicaDatos(cdsPresup_C, 'MOVCNT');
      End;

      cdsClone.Next;
   End;

   cdsAsiento := TwwClientDataSet.Create(Nil);
   cdsAsiento.RemoteServer := DCOMx;
   cdsAsiento.ProviderName := 'dspTem4';

   //////////////////////////////////////////
   //  Añadir Cuentas de  Tipo de Asiento  //
   //////////////////////////////////////////
   cdsClone.First;
   While Not cdsClone.EOF Do
   Begin

      If cdsClone.FieldByName('ASIENTOID').AsString <> '' Then
      Begin
         xSQL1 := 'Select * from PPRES202 '
            + 'Where CIAID=''' + cdsClone.FieldByName('CIAID').AsString + ''''
            + ' AND ASIENTOID=''' + cdsClone.FieldByName('ASIENTOID').AsString + '''';
         cdsAsiento.Close;
         cdsAsiento.DataRequest(xSQL1);
         cdsAsiento.Open;

         If cdsAsiento.RecordCount > 0 Then
         Begin

            While Not cdsAsiento.eof Do
            Begin
               sCia := cdsClone.FieldByName('CIAID').AsString;
               sCuenta := cdsClone.FieldByName('PARPRESID').AsString;

               //SI LA CUENTA ORIGES ESTA DESTINADA AL DEBE LA CUENTA AUTOMATICA 1 IRA AL HABER
               If cdsClone.FieldByName('RQPARTIS').AsString = 'I' Then
                  sDeHa := 'I'
               Else
               Begin
                  sDeHa := 'S';
               End;
               cdsPresup_C.Insert;
               cdsPresup_C.FieldByName('CIAID').AsString := cdsClone.FieldByName('CIAID').AsString;
               cdsPresup_C.FieldByName('USUARIO').AsString := cdsClone.FieldByName('USUARIO').AsString;
               cdsPresup_C.FieldByName('NUMERO').AsString := cdsClone.FieldByName('NUMERO').AsString;
               cdsPresup_C.FieldByName('ANO').AsString := cdsClone.FieldByName('ANO').AsString;
               cdsPresup_C.FieldByName('MES').AsString := cdsClone.FieldByName('MES').AsString;
               cdsPresup_C.FieldByName('TIPPRESID').AsString := cdsClone.FieldByName('TIPPRESID').AsString;
               cdsPresup_C.FieldByName('PARPRESID').AsString := cdsAsiento.FieldByName('PARPRESID').AsString;
               cdsPresup_C.FieldByName('CCOSID').AsString := cdsClone.FieldByName('CCOSID').AsString;
               cdsPresup_C.FieldByName('RQPARTIS').AsString := sDeHa;
               cdsPresup_C.FieldByName('TMONID').AsString := cdsClone.FieldByName('TMONID').AsString;
               cdsPresup_C.FieldByName('MONTOMN').AsFloat := cdsClone.FieldByName('MONTOMN').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME').AsFloat := cdsClone.FieldByName('MONTOME').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('TIPOCOL').AsString := cdsClone.FieldByName('TIPOCOL').AsString;
               cdsPresup_C.FieldByName('FMAYOR').AsString := 'N';

               // Para Mayorizar Anual
               cdsPresup_C.FieldByName('MONTOMN01').AsFloat := cdsClone.FieldByName('MONTOMN01').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME01').AsFloat := cdsClone.FieldByName('MONTOME01').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOMN02').AsFloat := cdsClone.FieldByName('MONTOMN02').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME02').AsFloat := cdsClone.FieldByName('MONTOME02').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOMN03').AsFloat := cdsClone.FieldByName('MONTOMN03').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME03').AsFloat := cdsClone.FieldByName('MONTOME03').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOMN04').AsFloat := cdsClone.FieldByName('MONTOMN04').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME04').AsFloat := cdsClone.FieldByName('MONTOME04').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOMN05').AsFloat := cdsClone.FieldByName('MONTOMN05').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME05').AsFloat := cdsClone.FieldByName('MONTOME05').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOMN06').AsFloat := cdsClone.FieldByName('MONTOMN06').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME06').AsFloat := cdsClone.FieldByName('MONTOME06').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOMN07').AsFloat := cdsClone.FieldByName('MONTOMN07').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME07').AsFloat := cdsClone.FieldByName('MONTOME07').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOMN08').AsFloat := cdsClone.FieldByName('MONTOMN08').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME08').AsFloat := cdsClone.FieldByName('MONTOME08').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOMN09').AsFloat := cdsClone.FieldByName('MONTOMN09').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME09').AsFloat := cdsClone.FieldByName('MONTOME09').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOMN10').AsFloat := cdsClone.FieldByName('MONTOMN10').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME10').AsFloat := cdsClone.FieldByName('MONTOME10').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOMN11').AsFloat := cdsClone.FieldByName('MONTOMN11').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME11').AsFloat := cdsClone.FieldByName('MONTOME11').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOMN12').AsFloat := cdsClone.FieldByName('MONTOMN12').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               cdsPresup_C.FieldByName('MONTOME12').AsFloat := cdsClone.FieldByName('MONTOME12').AsFloat * cdsAsiento.FieldByName('PORCENTAJE').AsFloat / 100;
               //
               iOrden := iOrden + 1;

               cdsAsiento.Next;
            End;
            FoaConta.AplicaDatos(cdsPresup_C, 'MOVCNT');
         End;
      End;

      cdsClone.Next;
   End;
   //////////////////7

   FoaConta.AplicaDatos(cdsPresup_C, 'MOVCNT');

   Result := False;

   FoaConta.GeneraMayorPresupuestos(xCia, xUsuario, xNumero, 'S');

   pnlConta_C.Free;

   {
   if (xTipoC='C') or (xTipoC='P') or (xTipoC='CCNA') or (xTipoC='PCNA') then begin

      xSQL:='Delete From CNT311 A '
           +'Where ( A.CIAID='     +''''+ xCia     +''''+' AND '
           +        'A.CNTANOMM='  +''''+ xAnoMM   +''''+' AND '
           +        'A.CNTCOMPROB='+''''+ xNoComp  +''' ) '
           + xSQLAdicional+' ';
      try
         cdsQry_C.Close;
         cdsQry_C.DataRequest( xSQL );
         cdsQry_C.Execute;
      except
         Errorcount2:=1;
         Exit;
      end;

   end;
   }

   If Errorcount2 > 0 Then Exit;

   Result := True;
End;

Procedure TFoaConta.GeneraMayorPresupuestos(xxxCia, xxxUsuario, xxxNumero, xSuma: String);
Var
   xCtaPrin, xTipPres, xTipoCol, xAnoMM, xClAux, xCuenta, xAuxDes, xAno, xMes, xDH, xSQL: String;
   xMov, xAux, xCCos, xCCoDes, xCtaDes, xFLAux, xFLCCo, xNivel, xNREG: String;
   xDigitos, xDigAnt, xNumT, xContR: Integer;
   xImpMN, xImpME: Double;
   cdsQry2x: TwwClientDataSet;
   cdsNivel_C: TwwClientDataSet;
   cAno: String;
   cMes: String;
   cMesA: String;
Begin
   FoaConta.PanelMsg('Actualizando Saldos...', 0);

   xSQL := 'Select * from PPRES103 Order by PARPRESNIV';
   cdsNivel_C := TwwClientDataSet.Create(Nil);
   cdsNivel_C.RemoteServer := DCOM_C;
   cdsNivel_C.ProviderName := Provider_C;
   cdsNivel_C.Close;
   cdsNivel_C.DataRequest(xSQL);
   cdsNivel_C.Open;

   cdsQry2x := TwwClientDataSet.Create(Nil);
   cdsQry2x.RemoteServer := DCOM_C;
   cdsQry2x.ProviderName := Provider_C;

   // MAYORIZA CON CENTRO DE COSTO
   {
   xSQL:='Select A.CIAID, A.USUARIO, A.ANO, A.MES, A.NUMERO, A.TIPPRESID, A.PARPRESID, '
        +  'A.TIPOCOL, A.RQPARTIS, A.CCOSID, A.TMONID, A.MONTOMN, A.MONTOME, FMAYOR, '
        +  'MONTOMN01, MONTOME01, MONTOMN02, MONTOME02, MONTOMN03, MONTOME03, '
        +  'MONTOMN04, MONTOME04, MONTOMN05, MONTOME05, MONTOMN06, MONTOME06, '
        +  'MONTOMN07, MONTOME07, MONTOMN08, MONTOME08, MONTOMN09, MONTOME09, '
        +  'MONTOMN10, MONTOME10, MONTOMN11, MONTOME11, MONTOMN12, MONTOME12  '
        +'FROM PPRES311 A '
        +'WHERE A.CIAID  ='+QuotedStr( xxxCia     )
        + ' AND A.USUARIO='+QuotedStr( xxxUsuario )
        + ' AND A.NUMERO ='+QuotedStr( xxxNumero  );
   }
   xSQL := 'Select A.CIAID, A.USUARIO, A.ANO, A.MES, A.TIPPRESID, A.PARPRESID, '
      + 'TIPOCOL, RQPARTIS, A.CCOSID, SUM(MONTOMN) MONTOMN, SUM(MONTOME) MONTOME, FMAYOR, '
      + 'SUM(MONTOMN01) MONTOMN01, SUM(MONTOME01) MONTOME01, SUM(MONTOMN02) MONTOMN02, SUM(MONTOME02) MONTOME02, SUM(MONTOMN03) MONTOMN03, SUM(MONTOME03) MONTOME03, '
      + 'SUM(MONTOMN04) MONTOMN04, SUM(MONTOME04) MONTOME04, SUM(MONTOMN05) MONTOMN05, SUM(MONTOME05) MONTOME05, SUM(MONTOMN06) MONTOMN06, SUM(MONTOME06) MONTOME06, '
      + 'SUM(MONTOMN07) MONTOMN07, SUM(MONTOME07) MONTOME07, SUM(MONTOMN08) MONTOMN08, SUM(MONTOME08) MONTOME08, SUM(MONTOMN09) MONTOMN09, SUM(MONTOME09) MONTOME09, '
      + 'SUM(MONTOMN10) MONTOMN10, SUM(MONTOME10) MONTOME10, SUM(MONTOMN11) MONTOMN11, SUM(MONTOME11) MONTOME11, SUM(MONTOMN12) MONTOMN12, SUM(MONTOME12) MONTOME12  '
      + 'FROM PPRES311 A '
      + 'WHERE A.CIAID  =' + QuotedStr(xxxCia)
      + ' AND A.USUARIO=' + QuotedStr(xxxUsuario)
      + ' AND A.NUMERO =' + QuotedStr(xxxNumero)
      + 'GROUP BY A.CIAID, A.USUARIO, A.ANO, A.MES, A.TIPPRESID, A.PARPRESID, A.CCOSID, '
      + 'A.TIPOCOL, A.RQPARTIS, FMAYOR';

   cdsMovPRE2 := TwwClientDataSet.Create(Nil);
   cdsMovPRE2.RemoteServer := DCOM_C;
   cdsMovPRE2.ProviderName := Provider_C;
   cdsMovPRE2.Close;
   cdsMovPRE2.DataRequest(xSQL);
   cdsMovPRE2.Open;

   FoaConta.PanelMsg('Actualizando Saldos - Cuentas ...', 0);

   xContR := 0;

   cdsMovPRE2.First;
   While Not cdsMovPRE2.Eof Do
   Begin

      xContR := xContR + 1;
      xCtaPrin := cdsMovPRE2.FieldByName('PARPRESID').AsString;
      xTipPres := cdsMovPRE2.FieldByName('TIPPRESID').AsString;
      xCCos := cdsMovPRE2.FieldByName('CCOSID').AsString;
      xTipoCol := cdsMovPRE2.FieldByName('TIPOCOL').AsString;
      xAnoMM := cdsMovPRE2.FieldByName('ANO').AsString + cdsMovPRE2.FieldByName('MES').AsString;
      xDH := cdsMovPRE2.FieldByName('RQPARTIS').AsString;
      xImpMN := FRound(cdsMovPRE2.FieldByName('MONTOMN').AsFloat, 15, 2);
      xImpME := FRound(cdsMovPRE2.FieldByName('MONTOME').AsFloat, 15, 2);
      xAno := Copy(xAnoMM, 1, 4);
      xMes := Copy(xAnoMM, 5, 2);

      // si es Descontabilización
      If xSuma = 'N' Then
      Begin
         xImpMN := xImpMN * (-1);
         xImpME := xImpME * (-1);
      End;

      xDigAnt := 0;
      cdsNivel_C.First;
      While Not cdsNivel_C.EOF Do
      Begin
         xDigitos := cdsNivel_C.fieldbyName('DIGITOS').AsInteger;
         xCuenta := Trim(Copy(xCtaPrin, 1, xDigitos));
         xNivel := cdsNivel_C.fieldbyName('PARPRESNIV').AsString;
         xCtaDes := '';
         xMov := '';

         If (cdsMovPRE2.FieldByName('FMAYOR').AsString = 'S') And
            (xCtaPrin = xCuenta) Then
         Begin
            If xTipoCol <> 'DPREOR' Then
               Break;
         End;

         xSQL := 'Select PARPRESDES, PARPRESMOV from PPRES201 '
            + 'Where CIAID=' + quotedstr(xxxCia)
            + ' and TIPPRESID=' + quotedstr(xTipPres)
            + ' and PARPRESID=' + quotedstr(xCuenta)
            + ' and PROCE=' + quotedstr(wOrigenPRE)
            + ' and PARPRESNIV=' + quotedstr(xNivel);

         cdsQry2x.Close;
         cdsQry2x.DataRequest(xSQL); // Llamada remota al provider del servidor
         cdsQry2x.Open;

         xCtaDes := cdsQry2x.FieldByName('PARPRESDES').AsString;
         xMov := cdsQry2x.FieldByName('PARPRESMOV').AsString;

         If Trim(cdsNivel_C.fieldbyName('Signo').AsString) = '=' Then
            If Length(xCuenta) = xDigitos Then
            Else
               Break;
         If cdsNivel_C.fieldbyName('Signo').AsString = '<=' Then
            If (Length(xCuenta) <= xDigitos) And (Length(xCuenta) > xDigAnt) Then
            Else
               Break;
         If cdsNivel_C.fieldbyName('Signo').AsString = '>=' Then
            If Length(xCuenta) >= xDigitos Then
            Else
               Break;

         // Mayoriza con Centro de Costo
         If Not FoaConta.PPresExiste(xxxCia, xAno, xCuenta, xCCos, xTipPres) Then
         Begin
            FoaConta.InsertaPPres(xxxCia, xAnoMM, xCuenta, xCCos, xTipPres, xTipoCol, xDH, xMov,
               xCtaDes, xNivel, xImpMN, xImpME);
            If Errorcount2 > 0 Then Exit;
         End
         Else
         Begin
            FoaConta.ActualizaPPres(xxxCia, xAnoMM, xCuenta, xCCos, xTipPres, xTipoCol, xDH, xMov,
               xCtaDes, xNivel, xImpMN, xImpME);
            If Errorcount2 > 0 Then Exit;
         End;
         {
         // Mayoriza sin Centro de Costo
         if not FSOLConta.PPresExiste( xxxCia, xAno, xCuenta, '', xTipPres  ) then
         begin
            FSOLConta.InsertaPPres( xxxCia, xAnoMM, xCuenta, '', xTipPres, xTipoCol, xDH, xMov,
                                    xCtaDes, xNivel, xImpMN, xImpME );
            if Errorcount2>0 then Exit;
         end
         else
         begin
            FSOLConta.ActualizaPPres( xxxCia, xAnoMM, xCuenta, '', xTipPres, xTipoCol, xDH, xMov,
                                      xCtaDes, xNivel, xImpMN, xImpME );
            if Errorcount2>0 then Exit;
         end;
         }

         xDigAnt := cdsNivel_C.fieldbyName('Digitos').AsInteger;
         cdsNivel_C.Next;
      End;
      cdsMovPRE2.Next;
   End;

   // MAYORIZA SIN CENTRO DE COSTO

   xSQL := 'Select A.CIAID, A.USUARIO, A.ANO, A.MES, A.TIPPRESID, A.PARPRESID, '
      + 'TIPOCOL, RQPARTIS, '''' CCOSID, SUM(MONTOMN) MONTOMN, SUM(MONTOME) MONTOME, FMAYOR, '
      + 'SUM(MONTOMN01) MONTOMN01, SUM(MONTOME01) MONTOME01, SUM(MONTOMN02) MONTOMN02, SUM(MONTOME02) MONTOME02, SUM(MONTOMN03) MONTOMN03, SUM(MONTOME03) MONTOME03, '
      + 'SUM(MONTOMN04) MONTOMN04, SUM(MONTOME04) MONTOME04, SUM(MONTOMN05) MONTOMN05, SUM(MONTOME05) MONTOME05, SUM(MONTOMN06) MONTOMN06, SUM(MONTOME06) MONTOME06, '
      + 'SUM(MONTOMN07) MONTOMN07, SUM(MONTOME07) MONTOME07, SUM(MONTOMN08) MONTOMN08, SUM(MONTOME08) MONTOME08, SUM(MONTOMN09) MONTOMN09, SUM(MONTOME09) MONTOME09, '
      + 'SUM(MONTOMN10) MONTOMN10, SUM(MONTOME10) MONTOME10, SUM(MONTOMN11) MONTOMN11, SUM(MONTOME11) MONTOME11, SUM(MONTOMN12) MONTOMN12, SUM(MONTOME12) MONTOME12  '
      + 'FROM PPRES311 A '
      + 'WHERE A.CIAID  =' + QuotedStr(xxxCia)
      + ' AND A.USUARIO=' + QuotedStr(xxxUsuario)
      + ' AND A.NUMERO =' + QuotedStr(xxxNumero)
      + 'GROUP BY A.CIAID, A.USUARIO, A.ANO, A.MES, A.TIPPRESID, A.PARPRESID, '
      + 'A.TIPOCOL, A.RQPARTIS, FMAYOR';

   cdsMovPRE2.Close;
   cdsMovPRE2.DataRequest(xSQL);
   cdsMovPRE2.Open;

   FoaConta.PanelMsg('Actualizando Saldos - Cuentas ...', 0);

   cdsMovPRE2.First;
   While Not cdsMovPRE2.Eof Do
   Begin

      xCtaPrin := cdsMovPRE2.FieldByName('PARPRESID').AsString;
      xTipPres := cdsMovPRE2.FieldByName('TIPPRESID').AsString;
      xCCos := cdsMovPRE2.FieldByName('CCOSID').AsString;
      xTipoCol := cdsMovPRE2.FieldByName('TIPOCOL').AsString;
      xAnoMM := cdsMovPRE2.FieldByName('ANO').AsString + cdsMovPRE2.FieldByName('MES').AsString;
      xDH := cdsMovPRE2.FieldByName('RQPARTIS').AsString;
      xImpMN := FRound(cdsMovPRE2.FieldByName('MONTOMN').AsFloat, 15, 2);
      xImpME := FRound(cdsMovPRE2.FieldByName('MONTOME').AsFloat, 15, 2);
      xAno := Copy(xAnoMM, 1, 4);
      xMes := Copy(xAnoMM, 5, 2);

      // si es Descontabilización
      If xSuma = 'N' Then
      Begin
         xImpMN := xImpMN * (-1);
         xImpME := xImpME * (-1);
      End;

      xDigAnt := 0;
      cdsNivel_C.First;
      While Not cdsNivel_C.EOF Do
      Begin
         xDigitos := cdsNivel_C.fieldbyName('DIGITOS').AsInteger;
         xCuenta := Trim(Copy(xCtaPrin, 1, xDigitos));
         xNivel := cdsNivel_C.fieldbyName('PARPRESNIV').AsString;
         xCtaDes := '';
         xMov := '';

         If (cdsMovPRE2.FieldByName('FMAYOR').AsString = 'S') And
            (xCtaPrin = xCuenta) Then
         Begin
            If xTipoCol <> 'DPREOR' Then
               Break;
         End;

         xSQL := 'Select PARPRESDES, PARPRESMOV from PPRES201 '
            + 'Where CIAID=' + quotedstr(xxxCia)
            + ' and TIPPRESID=' + quotedstr(xTipPres)
            + ' and PARPRESID=' + quotedstr(xCuenta)
            + ' and PROCE=' + quotedstr(wOrigenPRE)
            + ' and PARPRESNIV=' + quotedstr(xNivel);

         cdsQry2x.Close;
         cdsQry2x.DataRequest(xSQL); // Llamada remota al provider del servidor
         cdsQry2x.Open;

         xCtaDes := cdsQry2x.FieldByName('PARPRESDES').AsString;
         xMov := cdsQry2x.FieldByName('PARPRESMOV').AsString;

         If Trim(cdsNivel_C.fieldbyName('Signo').AsString) = '=' Then
            If Length(xCuenta) = xDigitos Then
            Else
               Break;
         If cdsNivel_C.fieldbyName('Signo').AsString = '<=' Then
            If (Length(xCuenta) <= xDigitos) And (Length(xCuenta) > xDigAnt) Then
            Else
               Break;
         If cdsNivel_C.fieldbyName('Signo').AsString = '>=' Then
            If Length(xCuenta) >= xDigitos Then
            Else
               Break;

         // Mayoriza sin Centro de Costo
         If Not FoaConta.PPresExiste(xxxCia, xAno, xCuenta, '', xTipPres) Then
         Begin
            FoaConta.InsertaPPres(xxxCia, xAnoMM, xCuenta, '', xTipPres, xTipoCol, xDH, xMov,
               xCtaDes, xNivel, xImpMN, xImpME);
            If Errorcount2 > 0 Then Exit;
         End
         Else
         Begin
            FoaConta.ActualizaPPres(xxxCia, xAnoMM, xCuenta, '', xTipPres, xTipoCol, xDH, xMov,
               xCtaDes, xNivel, xImpMN, xImpME);
            If Errorcount2 > 0 Then Exit;
         End;

         xDigAnt := cdsNivel_C.fieldbyName('Digitos').AsInteger;
         cdsNivel_C.Next;
      End;
      cdsMovPRE2.Next;
   End;

   FoaConta.PanelMsg('Final de Actualiza Saldos...', 0);
   cdsQry2x.IndexFieldNames := '';
End;

Function TFoaConta.PPresExiste(xCia1, xAno1, xCuenta1, xCCosto1, xTipPres1: String): Boolean;
Var
   xSQL: String;
   xAuxid, xCCosid: String;
Begin
   If xCCosto1 = '' Then
   Begin
      If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
      Begin
         xCcosid := 'CCOSID=''''';
      End;
      If SRV_C = 'ORACLE' Then
      Begin
         xCcosid := 'CCOSID IS NULL'
      End;
   End
   Else
   Begin
      xCcosid := 'CCOSID=' + quotedstr(xCCosto1);
   End;

   xSQL := 'Select COUNT( PARPRESID ) TOTREG from PPRES301 '
      + 'Where CIAID=' + '''' + xCia1 + '''' + ' and '
      + 'RQPARTANO=' + '''' + xAno1 + '''' + ' and '
      + 'TIPPRESID=' + '''' + xTipPres1 + '''' + ' and '
      + 'PARPRESID=' + '''' + xCuenta1 + '''' + ' and '
      + xCCosid + ' and '
      + 'PROCE=''' + wOrigenPRE + '''';

   cdsQry_C.Close;
   cdsQry_C.DataRequest(xSQL);
   cdsQry_C.Open;

   If cdsQry_C.fieldbyName('TOTREG').asInteger > 0 Then
      Result := True
   Else
      Result := False;
End;

Procedure TFoaConta.ActualizaPPres(cCia, cAnoMM, cCuenta, cCCosto, cTipPres, cTipoCol, cDH, cMov,
   cCtaDes, cNivel: String; nImpMN, nImpME: double);
Var
   cMes, cAno, cSQL, cMesT, cMesA: String;
   nMes: Integer;
   xAuxid, xCcosid, xClauxid, xTiTo: String;
Begin
   cAno := Copy(cAnoMM, 1, 4);
   cMes := Copy(cAnoMM, 5, 2);
   //cMesA := StrZero( IntToStr( StrToInt(cMes)-1 ), 2 );
   cSQL := 'Update PPRES301 Set PARPREDES =' + '''' + cCtaDes + '''' + ', ';

   xTiTo := Copy(cTipoCol, 5, 2);

   If wTMay = 'M' Then
   Begin
      If cDH = 'I' Then
      Begin
         // Columna de Movimientos
         cSQL := cSQL + ' ' + cTipoCol + 'MN' + cMes + '=' +
            'ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN' + cMes + ',0)+ROUND(' + FloatToStr(nImpMN) + ',2 ),2 ) ';
         cSQL := cSQL + ', ' + cTipoCol + 'ME' + cMes + '=' +
            'ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME' + cMes + ',0)+ROUND(' + FloatToStr(nImpME) + ',2 ),2 ) ';
         // Columna de Totales
         cSQL := cSQL + ', DPRETO' + xTiTo + 'MN' + '=' +
            'ROUND( ' + wReplaCeros + '( DPRETO' + xTiTo + 'MN' + ',0)+ROUND(' + FloatToStr(nImpMN) + ',2 ),2 ) ';
         cSQL := cSQL + ', DPRETO' + xTiTo + 'ME' + '=' +
            'ROUND( ' + wReplaCeros + '( DPRETO' + xTiTo + 'ME' + ',0)+ROUND(' + FloatToStr(nImpME) + ',2 ),2 ) ';
      End;
      If cDH = 'S' Then
      Begin
         // Columna de Movimientos
         cSQL := cSQL + ' ' + cTipoCol + 'MN' + cMes + '=' +
            'ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN' + cMes + ',0)+ROUND(' + FloatToStr(nImpMN) + ',2 ),2 ) ';
         cSQL := cSQL + ', ' + cTipoCol + 'ME' + cMes + '=' +
            'ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME' + cMes + ',0)+ROUND(' + FloatToStr(nImpME) + ',2 ),2 ) ';
         // Columna de Totales
         cSQL := cSQL + ', DPRETO' + xTiTo + 'MN' + '=' +
            'ROUND( ' + wReplaCeros + '( DPRETO' + xTiTo + 'MN' + ',0)+ROUND(' + FloatToStr(nImpMN) + ',2 ),2 ) ';
         cSQL := cSQL + ', DPRETO' + xTiTo + 'ME' + '=' +
            'ROUND( ' + wReplaCeros + '( DPRETO' + xTiTo + 'ME' + ',0)+ROUND(' + FloatToStr(nImpME) + ',2 ),2 ) ';
      End;

      cSQL := cSQL + ', DPRETO' + xTiTo + 'MN=ROUND( ' + wReplaCeros + '( DPRETO' + xTiTo + 'MN,0)+'
         + 'ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN' + cMes).AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', DPRETO' + xTiTo + 'ME=ROUND( ' + wReplaCeros + '( DPRETO' + xTiTo + 'ME,0)+'
         + 'ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME' + cMes).AsFloat, 15, 2)) + ',2 ),2 ) ';
   End;

   If wTMay = 'A' Then
   Begin
      // Columna de Movimientos
      cSQL := cSQL + '  ' + cTipoCol + 'MN01=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN01,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN01').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'ME01=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME01,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME01').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'MN02=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN02,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN02').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'ME02=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME02,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME02').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'MN03=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN03,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN03').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'ME03=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME03,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME03').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'MN04=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN04,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN04').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'ME04=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME04,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME04').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'MN05=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN05,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN05').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'ME05=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME05,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME05').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'MN06=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN06,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN06').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'ME06=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME06,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME06').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'MN07=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN07,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN07').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'ME07=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME07,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME07').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'MN08=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN08,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN08').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'ME08=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME08,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME08').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'MN09=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN09,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN09').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'ME09=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME09,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME09').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'MN10=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN10,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN10').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'ME10=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME10,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME10').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'MN11=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN11,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN11').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'ME11=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME11,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME11').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'MN12=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'MN12,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN12').AsFloat, 15, 2)) + ',2 ),2 ) ';
      cSQL := cSQL + ', ' + cTipoCol + 'ME12=ROUND( ' + wReplaCeros + '( ' + cTipoCol + 'ME12,0)+ROUND(' + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME12').AsFloat, 15, 2)) + ',2 ),2 ) ';

      cSQL := cSQL + ', DPRETO' + xTiTo + 'MN=ROUND( ' + wReplaCeros + '( DPRETO' + xTiTo + 'MN,0)+'
         + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOMN01' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOMN02' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOMN03' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOMN04' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOMN05' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOMN06' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOMN07' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOMN08' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOMN09' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOMN10' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOMN11' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOMN12' + cMes).AsFloat, 15, 2)) + ', 2 ) ';
      cSQL := cSQL + ', DPRETO' + xTiTo + 'ME=ROUND( ' + wReplaCeros + '( DPRETO' + xTiTo + 'ME,0)+'
         + FloatToStr(FRound(cdsMovPRE2.FieldByName('MONTOME01' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOME02' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOME03' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOME04' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOME05' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOME06' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOME07' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOME08' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOME08' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOME10' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOME11' + cMes).AsFloat +
         +cdsMovPRE2.FieldByName('MONTOME12' + cMes).AsFloat, 15, 2)) + ', 2 ) ';
   End;

   If cCCosto = '' Then
   Begin
      If (SRV_C = 'DB2NT') Or (SRV_C = 'DB2400') Then
      Begin
         xCcosid := 'CCOSID=''''';
      End;
      If SRV_C = 'ORACLE' Then
      Begin
         xCcosid := 'CCOSID IS NULL'
      End;
   End
   Else
   Begin
      xCcosid := 'CCOSID=' + quotedstr(cCCosto);
   End;

   cSQL := cSQL + 'Where CIAID=' + '''' + cCia + '''' + ' and '
      + 'RQPARTANO=' + '''' + cAno + '''' + ' and '
      + 'TIPPRESID=' + '''' + cTipPres + '''' + ' and '
      + 'PARPRESID=' + '''' + cCuenta + '''' + ' and '
      + xCCosid + ' and '
      + 'PROCE=''' + wOrigenPRE + '''';

   cSQL := cSQL + xAuxid + xClauxid;

   Try
      cdsQry_C.Close;
      cdsQry_C.DataRequest(cSQL);
      cdsQry_C.Execute;
   Except
      Errorcount2 := 1;
   End;
End;

Procedure TFoaConta.InsertaPPres(cCia, cAnoMM, cCuenta, cCCosto, cTipPres, cTipoCol, cDH, cMov,
   cCtaDes, cNivel: String; nImpMN, nImpME: Double);
Var
   cMes, cAno, cSQL, cMesT: String;
   nMes: Integer;
   xCtaMov, xTito: String;
Begin
   cAno := Copy(cAnoMM, 1, 4);
   cMes := Copy(cAnoMM, 5, 2);

   xTiTo := Copy(cTipoCol, 5, 2);

   cSQL := 'Insert into PPRES301( CIAID, RQPARTANO, TIPPRESID, PARPRESID, BALANCE, '
      + ' PARPREDES, PARPRESMOV, PARPRESNIV, PROCE, CCOSID ';
   cSQL := 'Insert into PPRES301( CIAID, RQPARTANO, TIPPRESID, PARPRESID, CCOSID, PROCE, '
      + ' PARPREDES, PARPRESMOV, PARPRESNIV, BALANCE ';
   If wTMay = 'M' Then
   Begin
      If cDH = 'I' Then
      Begin
         // Columna de Movimientos
         cSQL := cSQL + ', ' + cTipoCol + 'MN' + cMes;
         cSQL := cSQL + ', ' + cTipoCol + 'ME' + cMes;
         // Columna de Totales
         cSQL := cSQL + ', DPRETO' + xTiTo + 'MN';
         cSQL := cSQL + ', DPRETO' + xTiTo + 'ME';
      End;
      If cDH = 'S' Then
      Begin
         // Columna de Movimientos
         cSQL := cSQL + ', ' + cTipoCol + 'MN' + cMes;
         cSQL := cSQL + ', ' + cTipoCol + 'ME' + cMes;
         // Columna de Totales
         cSQL := cSQL + ', DPRETO' + xTiTo + 'MN';
         cSQL := cSQL + ', DPRETO' + xTiTo + 'ME';
      End;
      cSQL := cSQL + ' ) ';
      cSQL := cSQL + 'Values( ' + '''' + cCia + '''' + ', ' + '''' + cAno + '''' + ', '
         + '''' + cTipPres + '''' + ', ' + '''' + cCuenta + '''' + ', '
         + quotedstr(cCCosto) + ', ''' + wOrigenPRE + ''', '
         + '''' + cCtaDes + '''' + ', ' + quotedstr(cMov) + ', '
         + quotedStr(cNivel) + ', ' + '''' + 'S' + ''', '
         + FloatToStr(nImpMN) + ', '
         + FloatToStr(nImpME) + ', '
         + FloatToStr(nImpMN) + ', '
         + FloatToStr(nImpME) + ' ) ';
   End;

   If wTMay = 'A' Then
   Begin

      // Columna de Movimientos
      cSQL := cSQL + ', ' + cTipoCol + 'MN01, ' + cTipoCol + 'ME01';
      cSQL := cSQL + ', ' + cTipoCol + 'MN02, ' + cTipoCol + 'ME02';
      cSQL := cSQL + ', ' + cTipoCol + 'MN03, ' + cTipoCol + 'ME03';
      cSQL := cSQL + ', ' + cTipoCol + 'MN04, ' + cTipoCol + 'ME04';
      cSQL := cSQL + ', ' + cTipoCol + 'MN05, ' + cTipoCol + 'ME05';
      cSQL := cSQL + ', ' + cTipoCol + 'MN06, ' + cTipoCol + 'ME06';
      cSQL := cSQL + ', ' + cTipoCol + 'MN07, ' + cTipoCol + 'ME07';
      cSQL := cSQL + ', ' + cTipoCol + 'MN08, ' + cTipoCol + 'ME08';
      cSQL := cSQL + ', ' + cTipoCol + 'MN09, ' + cTipoCol + 'ME09';
      cSQL := cSQL + ', ' + cTipoCol + 'MN10, ' + cTipoCol + 'ME10';
      cSQL := cSQL + ', ' + cTipoCol + 'MN11, ' + cTipoCol + 'ME11';
      cSQL := cSQL + ', ' + cTipoCol + 'MN12, ' + cTipoCol + 'ME12';

      cSQL := cSQL + ', DPRETO' + xTiTo + 'MN, DPRETO' + xTiTo + 'ME';

      cSQL := cSQL + ' ) ';
{      cSQL:=cSQL+'Values( '+''''+cCia    +''''+', '+''''+cAno    +''''+', '
                           +''''+cTipPres+''''+', '+''''+cCuenta +''''+', '
                           +''''+'S'     +''''+', '+''''+cCtaDes +''''+', '
                           +quotedstr( cMov)+', '+quotedStr( cNivel ) +', '''+wOrigenPRE+''', '
                           +quotedstr( cCCosto )+', '}
      cSQL := cSQL + 'Values( ' + '''' + cCia + '''' + ', ' + '''' + cAno + '''' + ', '
         + '''' + cTipPres + '''' + ', ' + '''' + cCuenta + '''' + ', '
         + quotedstr(cCCosto) + ', ''' + wOrigenPRE + ''', '
         + '''' + cCtaDes + '''' + ', ' + quotedstr(cMov) + ', '
         + quotedStr(cNivel) + ', ' + '''' + 'S' + ''', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN01').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME01').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN02').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME02').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN03').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME03').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN04').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME04').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN05').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME05').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN06').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME06').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN07').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME07').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN08').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME08').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN09').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME09').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN10').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME10').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN11').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME11').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN12').AsFloat) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME12').AsFloat) + ', '

      + FloatToStr(cdsMovPRE2.FieldByName('MONTOMN01').AsFloat
         + cdsMovPRE2.FieldByName('MONTOMN02').AsFloat
         + cdsMovPRE2.FieldByName('MONTOMN03').AsFloat
         + cdsMovPRE2.FieldByName('MONTOMN04').AsFloat
         + cdsMovPRE2.FieldByName('MONTOMN05').AsFloat
         + cdsMovPRE2.FieldByName('MONTOMN06').AsFloat
         + cdsMovPRE2.FieldByName('MONTOMN07').AsFloat
         + cdsMovPRE2.FieldByName('MONTOMN08').AsFloat
         + cdsMovPRE2.FieldByName('MONTOMN09').AsFloat
         + cdsMovPRE2.FieldByName('MONTOMN10').AsFloat
         + cdsMovPRE2.FieldByName('MONTOMN11').AsFloat
         + cdsMovPRE2.FieldByName('MONTOMN12').AsFloat
         ) + ', '
         + FloatToStr(cdsMovPRE2.FieldByName('MONTOME01').AsFloat
         + cdsMovPRE2.FieldByName('MONTOME02').AsFloat
         + cdsMovPRE2.FieldByName('MONTOME03').AsFloat
         + cdsMovPRE2.FieldByName('MONTOME04').AsFloat
         + cdsMovPRE2.FieldByName('MONTOME05').AsFloat
         + cdsMovPRE2.FieldByName('MONTOME06').AsFloat
         + cdsMovPRE2.FieldByName('MONTOME07').AsFloat
         + cdsMovPRE2.FieldByName('MONTOME08').AsFloat
         + cdsMovPRE2.FieldByName('MONTOME09').AsFloat
         + cdsMovPRE2.FieldByName('MONTOME10').AsFloat
         + cdsMovPRE2.FieldByName('MONTOME11').AsFloat
         + cdsMovPRE2.FieldByName('MONTOME12').AsFloat
         ) + ' ) ';
   End;

   Try
      cdsQry_C.Close;
      cdsQry_C.DataRequest(cSQL);
      cdsQry_C.Execute;
   Except
      Errorcount2 := 1;
   End;
End;

Procedure TFoaConta.AsientosAdicionales(xCiaOri, xOrigen2, xAnoMM, xNoComp1, xNoCP: String; wMtoOri_P: Double);
Var
   xInsert, xWhere: String;
Begin
   xWhere := 'SELECT * FROM CAJA302 '
      + 'WHERE CIAID=' + '''' + '02' + ''''
      + ' and TDIARID=' + '''' + xOrigen2 + ''''
      + ' and ECANOMM=' + '''' + xAnoMM + ''''
      + ' and ECNOCOMP=' + '''' + xNoCP + '''';
   cdsQry_C.Close;
   cdsQry_C.DataRequest(xWhere);
   cdsQry_C.Open;

   xInsert := 'Insert Into CAJA302 ( CIAID, TDIARID, ECANOMM, ECNOCOMP, '
      + 'BANCOID, CCBCOID, ECNOCHQ, ECFCOMP, FPAGOID, '
      + 'TMONID, ECMTOORI, CLAUXID, PROV, PROVRUC, ECGIRA, ECGLOSA, ECFEMICH, '
      + 'EC_IE, ECESTADO, ECCONTA, ECUSER, ECPERREC ) '
      + 'Values( ' + QuotedStr(xCiaOri) + ', ' + QuotedStr(xOrigen2) + ', '
      + QuotedStr(xAnoMM) + ', ' + QuotedStr(xNoComp1) + ', '
      + QuotedStr(cdsQry_C.FieldByName('BANCOID').AsString) + ', '
      + QuotedStr(cdsQry_C.FieldByName('CCBCOID').AsString) + ', '
      + QuotedStr(cdsQry_C.FieldByName('ECNOCHQ').AsString) + ', '
      + QuotedStr(cdsQry_C.FieldByName('ECFCOMP').AsString) + ', '
      + QuotedStr(cdsQry_C.FieldByName('FPAGOID').AsString) + ', '
      + QuotedStr(cdsQry_C.FieldByName('TMONID').AsString) + ', '
      + FloatToStr(wMtoOri_P) + ', '
      + QuotedStr(cdsQry_C.FieldByName('CLAUXID').AsString) + ', '
      + QuotedStr(cdsQry_C.FieldByName('PROV').AsString) + ', '
      + QuotedStr(cdsQry_C.FieldByName('PROVRUC').AsString) + ', '
      + QuotedStr(cdsQry_C.FieldByName('ECGIRA').AsString) + ', '
      + QuotedStr(cdsQry_C.FieldByName('ECGLOSA').AsString) + ', '
      + QuotedStr(cdsQry_C.FieldByName('ECFEMICH').AsString) + ', '
      + '''E'', ''C'', ''S'', ''' + cdsQry_C.FieldByName('ECuser').AsString + ''', '
      + '''' + xRegAdicional + ''') ';
   cdsQry_C.Close;
   cdsQry_C.Datarequest(xInsert);
   Try
      cdsQry_C.Execute;
   Except
   End;
End;

End.

