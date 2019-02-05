unit SOLContabiliza;

//  Modificado : 01/08/2002

//  Comentarios:
//
//  xTipoC='P'     Si Previo
//  xTipoC='C'     Si Contabiliza
//  xTipoC='BP'    Si Contabiliza Bloque
//  xTipoC='PCNA'  Si Previo con Caja que NO es Autonoma
//  xTipoC='CCNA'  Si Contabiliza con Caja que NO es Autonoma
//  xTipoC='M'     Solo Mayoriza
//  xTipoC='MC'    Solo Mayoriza Cuenta
//  xTipoC='MCACC' Solo Mayoriza Cuentas con Auxiliar y C.Costo
//
//
//  Cambios:
//
//  Al : 27/12/2001  18:30:00
//       Se añadio cambio de JCC para generar Cabecera de CNT300
//  Al : 2001/12/29, 11:30 a.m. pjsv
//       se añadio CTA_AUT1 y CTA_AUT2 = 'S', Linea 157
//  Al : 2002/01/23, 12:05 p.m. vhn
//       Se añadio en la Descripción de Auxiliar QuotedStr( cAuxDes )
//                                     en vez de '''' + cAuxDes + ''''
//  Al : 18/04/2002
//       Se Añade Funciones para Mayorizar Presupuestos
//
//  Al : 01/08/2002
//       Se Añade xTipoC='MC' para Moayorizar Solo Una Cuenta de un Mes
//

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, db,
  DBClient, wwclient, MConnect, ComCtrls, StdCtrls, ExtCtrls, Buttons, 
  Wwdatsrc, ppCtrls;
type
  TFSOLConta = class(TForm)
    Label1: TLabel;
  private
    { Private declarations }

    xxSuma   : String;
    wFlTexto : String;

    procedure GeneraEnLinea401( xxxCia, xxxDiario, xxxAnoMM, xxxNoComp, xSuma : String );
    //function  CuentaExiste( xCia1, xAno1, xCuenta1, xAux1, xCCos1: String ): Boolean;
    function  CuentaExiste( xCia1, xAno1, xCuenta1, xClAux1, xAux1, xCCos1: String ): Boolean;
    procedure InsertaMov(cCia, cAnoMM, cCuenta, cClAux, cAux, cCCosto, cDH, cMov,
                         cCtaDes, cAuxDes, cCCoDes, cNivel, cTipReg: String; nImpMN, nImpME: Double);
    procedure ActualizaMov(cCia, cAnoMM, cCuenta, cClAux, cAux, cCCosto, cDH, cMov,
                           cCtaDes, cAuxDes, cCCoDes, cNivel,cTipReg : String;
                           nImpMN, nImpME : Double );
    function  StrZero(wNumero:String;wLargo:Integer):string;
    function  FRound( xReal:DOUBLE; xEnteros,xDecimal:Integer ) : DOUBLE;
    procedure AplicaDatos(wCDS: TClientDataSet; wNomArch : String);
    procedure CreaPanel( xForma:TForm; xMensaje:String );
    procedure PanelMsg( xMensaje:String; xProc:Integer );
    procedure GeneraAsientosComplementarios( xCia, xDiario, xAnoMM, xNoComp, xTCP : String; cdsMovCNT : TwwClientDataSet );
    procedure cdsPost(xxCds:TwwClientDataSet);
    procedure AsientosComplementarios( xCia, xDiario, xAnoMM, xNoComp : String );
    procedure GeneraMayorPresupuestos( xxxCia, xxxUsuario, xxxNumero, xSuma : String );
    function  PPresExiste( xCia1, xAno1, xCuenta1, xCCosto1, xTipPres1 : String ): Boolean;
    procedure InsertaPPres(cCia, cAnoMM, cCuenta, cCCosto, cTipPres, cTipoCol, cDH, cMov,
                           cCtaDes, cNivel : String; nImpMN, nImpME : Double) ;
    procedure ActualizaPPres(cCia,cAnoMM,cCuenta,cCCosto,cTipPres, cTipoCol, cDH, cMov,
                             cCtaDes, cNivel : String; nImpMN, nImpME : double );
    procedure CerrarTablas;
public
    { Public declarations }
  end;

var
  FSOLConta   : TFSOLConta;
  iOrden      : integer;
  wReplaCeros : String;
  DCOM_C      : TDCOMConnection;
  cdsNivel_C  : TwwClientDataSet;
  cdsPresup_C   : TwwClientDataSet;
  cdsQry_C      : TwwClientDataSet;
  cdsResultSet_C: TwwClientDataSet;
  cdsMovPRE2    : TwwClientDataSet;
  Errorcount2 : Integer;
  SRV_C       : String;
  pnlConta_C  : TPanel;
  pbConta_C   : tprogressbar ;
  CNTCab      : String;
  CNTDet      : String;
  Provider_C  : String;
  xCtaDebe    : String;
  xAux_D       : String;
  xCCos_D      : String;
  xCtaHaber   : String;
  xCtaRetHaber   : String;
  xCtaRetDebe   : String;
  xGlosaRetHaber, xGlosaRetDebe : String;
  xAux_H       : String;
  xCCos_H      : String;
  xOrigen     : String;
  xCiaOri     : String;
  xOrigen2    : String;
  xNoComp1    : String;
  xNoComp2    : String;
  xRutaVoucher: String;
  xUsuarioRep : String;
  xSQLAdicional :String;
  xSQLAdicional2:String;
  xRegAdicional :String;
  xTipoC_C    : String;
  wTMay       : String;
  wOrigenPRE  : String;
  wTMonExt_C, wTMonLoc_C : String;

  function SOLConta( xCia, xTDiario, xAnoMM, xNoComp, xSRV, xTipoC, xModulo : String;
                      cdsMovCNT, cdsNivelx, cdsResultSetx : TwwClientDataSet;
                      DCOMx                           : TDCOMConnection;
                      xForm_C : TForm ) : Boolean;

  function SOLDesConta( xxxCia, xxxDiario, xxxAnoMM, xxxNoComp, xSRV : String ;
                        cdsNivelx : TwwClientDataSet;
                        DCOMx : TDCOMConnection; xForm_C : TForm ) : Boolean;

  function SOLPresupuesto( xCia, xUsuario, xNumero, xSRV, xModulo : String;
                           cdsResultSetx     : TwwClientDataSet;
                           DCOMx             : TDCOMConnection;
                           xForm_C : TForm;  xTipoMay : String ) : Boolean;
//
//   xTipoMay='A'  Mayorizacion es Anual    es decir Mayoriza el año completo
//   xTipoMay='M'  Mayorizacion es Mensual  es decir Mayoriza el Mes que se envia
//
implementation

{$R *.DFM}


function SOLDesConta( xxxCia, xxxDiario, xxxAnoMM, xxxNoComp, xSRV : String;
                      cdsNivelx : TwwClientDataSet;
                      DCOMx : TDCOMConnection; xForm_C : TForm ) : Boolean;
var
   xSQL : String;
begin
   SRV_C      := xSRV;
   CNTDet     := 'CNT301';
   Provider_C := 'dspTem6';
   DCOM_C     := DCOMx;

   cdsNivel_C    := cdsNivelx;

   cdsQry_C:=TwwClientDataSet.Create(nil);
   cdsQry_C.RemoteServer:= DCOMx;
   cdsQry_C.ProviderName:=Provider_C;

   if (SRV_C='DB2NT') or (SRV_C='DB2400') then
   begin
      wReplaCeros:='COALESCE';
   end
   else
   if SRV_C='ORACLE' then
   begin
      wReplaCeros:='NVL';
   end;

   FSOLConta.CreaPanel( xForm_C, 'Contabilizando' );
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

   xSQL:='Insert into CNT311( '
        +' CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
        +  'CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
        +  'CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
        +  'CNTFEMIS, CNTFVCMTO, CNTFCOMP, CNTESTADO, CNTCUADRE, CNTFAUTOM, '
        +  'CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
        +  'CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
        +  'TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
        +  'CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
        +  'CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
        +  'CNTMODDOC, CNTREG, MODULO, CTA_SECU ) '
        +'Select CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
        +  'CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
        +  'CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
        +  'CNTFEMIS, CNTFVCMTO, CNTFCOMP, ''P'', ''S'', CNTFAUTOM, '
        +  'CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
        +  'CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
        +  'TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
        +  'CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
        +  'CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
        +  'CNTMODDOC, CNTREG, MODULO, CTA_SECU '
        +'From CNT301 '
        +'Where CIAID='     +quotedstr( xxxCia    )+' and '
        +      'TDIARID='   +quotedstr( xxxDiario )+' and '
        +      'CNTANOMM='  +quotedstr( xxxAnoMM  )+' and '
        +      'CNTCOMPROB='+quotedstr( xxxNoComp )+' and ';

   if (SRV_C = 'DB2NT') or (SRV_C = 'DB2400') then
      xSql:=xSQL+'Coalesce( CNTFAUTOM,''N'' )<>' +quotedstr('S')
   else
      xSQL:=xSQL+'NVL( CNTFAUTOM,''N'' )<>' +quotedstr('S');

   try
      cdsQry_C.Close;
      cdsQry_C.DataRequest( xSQL );
      cdsQry_C.Execute;
   except
      Errorcount2:=1;
      Exit;
   end;


   xSql:='UPDATE CNT311 SET CNTCUADRE=NULL, CNTESTADO=''I'' '
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

   // Descontabiliza del CNT401

   FSOLConta.GeneraEnLinea401( xxxCia, xxxDiario, xxxAnoMM, xxxNoComp, 'N' ) ;

   //

   xSql:='Delete from CNT301 '
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
{
   // Descontabiliza del CNT401

   FSOLConta.GeneraEnLinea401( xxxCia, xxxDiario, xxxAnoMM, xxxNoComp, 'N' ) ;
}

   pnlConta_C.Free;

   Result:=True ;

end;


function SOLConta( xCia, xTDiario, xAnoMM, xNoComp, xSRV, xTipoC, xModulo : String;
                   cdsMovCNT, cdsNivelx, cdsResultSetx : TwwClientDataSet;
                   DCOMx                           : TDCOMConnection;
                   xForm_C : TForm ) : Boolean;
var
   sSQL, xNREG, xSQL, xCajaAut : String;
   xNumT, iOrdenx       : Integer;
   sCIA,sCuenta,sDeHa   : string;
   dDebeMN,dHabeMN,dDebeME,dHabeME:double;
   xTotDebeMN, xTotHaberMN, xTotDebeME, xTotHaberME, xDif : Double;
   cdsClone : TwwClientDataSet;
   xxModulo  : String;
begin
   if (xTipoC='P') or (xTipoC='C') or (xTipoC='BP') or (xTipoC='CCNA') or (xTipoC='PCNA')  then begin
      CNTDet:='CNT311';
      if xTipoC='P' then
         CNTCab:='CNT310'
      else
         CNTCab:='CNT300';
   end
   else
   begin
      // Para Mayorización
      CNTCab:='CNT300';
      CNTDet:='CNT301';
   end;

   FSOLConta.CreaPanel( xForm_C, 'Contabilizando' );

   DCOM_C     := DCOMx;
   SRV_C      := xSRV;
   xTipoC_C   := xTipoC;

   if (SRV_C='DB2NT') or (SRV_C='DB2400') then
   begin
      wReplaCeros:='COALESCE';
   end
   else
   if SRV_C='ORACLE' then
   begin
      wReplaCeros:='NVL';
   end;

   Provider_C := 'dspTem6';

   cdsNivel_C    := cdsNivelx;
   cdsResultSet_C:= cdsResultSetx;

   cdsQry_C:=TwwClientDataSet.Create(nil);
   cdsQry_C.RemoteServer:= DCOMx;
   cdsQry_C.ProviderName:=Provider_C;

   // Se Añade Para Mayorizar Solamente
   if (xTipoC='M') then begin
      FSOLConta.GeneraEnLinea401( xCia, xTDiario, xAnoMM, xNoComp, 'S' );

      pnlConta_C.Free;

      FSOLConta.CerrarTablas;

      if Errorcount2>0 then Exit;

      Result:=True ;
      Exit;
   end;

   // Se Añade Para Mayorizar Solamente
   if (xTipoC='MC')  then begin

      if xNoComp='' then begin
         FSOLConta.CerrarTablas;
         Result:=False;
         Exit;
      end;

      FSOLConta.GeneraEnLinea401( xCia, xTDiario, xAnoMM, xNoComp, 'S' );
      pnlConta_C.Free;

      FSOLConta.CerrarTablas;

      if Errorcount2>0 then Exit;

      Result:=True ;
      Exit;
   end;

   // Se Añade Para Mayorizar Solamente Cuentas con Auxiliar y CCosto
   if (xTipoC='MCACC')  then begin

      FSOLConta.GeneraEnLinea401( xCia, xTDiario, xAnoMM, xNoComp, 'S' );
      pnlConta_C.Free;

      FSOLConta.CerrarTablas;

      if Errorcount2>0 then Exit;

      Result:=True ;
      Exit;
   end;

   xRegAdicional:='';

   xSQL:='Select TMONID from TGE103 where TMON_LOC='+''''+'L'+'''';
   cdsQry_C.Close;
   cdsQry_C.DataRequest( xSQL );
   cdsQry_C.Open;
   wTMonLoc_C:=cdsQry_C.FieldByname('TMONID').AsString;

   xSQL:='Select TMONID from TGE103 where TMON_LOC='+''''+'E'+'''';
   cdsQry_C.Close;
   cdsQry_C.DataRequest( xSQL );
   cdsQry_C.Open;
   wTMonExt_C:=cdsQry_C.FieldByname('TMONID').AsString;

   cdsMovCNT.Last;
   iOrdenx:=cdsMovCNT.FieldByName('CNTREG').AsInteger+1;

   //  xTipoC='PCNA'  Si Previo con Caja que NO es Autonoma
   //  xTipoC='CCNA'  Si Contabiliza con Caja que NO es Autonoma
   if (xTipoC='PCNA') or (xTipoC='CCNA') then begin
      xSQL:='Select CJAAUTONOM from TGE101 where CIAID='''+xCia+'''';
      cdsQry_C.Close;
      cdsQry_C.DataRequest( xSQL );
      cdsQry_C.Open;
      xCajaAut:=cdsQry_C.FieldByName('CJAAUTONOM').AsString;
      cdsQry_C.Close;

      if xCajaAut='N' then begin

         xSQL:='Select CTADEBE, B.CTA_AUX AUX_D, B.CTA_CCOS CCOS_D, '
              +      'CTAHABER, C.CTA_AUX AUX_H, C.CTA_CCOS CCOS_H, '
              +      'TDIARID, CIAORIGEN, TDIARID2 '
              +'From CAJA103 A, TGE202 B, TGE202 C '
              +'Where A.CIAID='''+xCia+''' '
              +  ' AND B.CIAID=A.CIAID AND A.CTADEBE=B.CUENTAID '
              +  ' AND C.CIAID=A.CIAID AND A.CTAHABER=C.CUENTAID ';
         cdsQry_C.DataRequest( xSQL );
         cdsQry_C.Open;

         if cdsQry_C.RecordCount=0 then begin
            Errorcount2:=1;
            FSOLConta.CerrarTablas;
            ShowMessage('Error : Caja de Compañía '+xCia+' No es Autonoma. Faltan Cuentas Reflejas');
            Exit;
         end;

         xCiaOri  :=cdsQry_C.FieldByName('CIAORIGEN').AsString;
         xOrigen  :=cdsQry_C.FieldByName('TDIARID').AsString;
         xCtaDebe :=cdsQry_C.FieldByName('CTADEBE').AsString;
         xAux_D   :=cdsQry_C.FieldByName('AUX_D').AsString;
         xCCos_D  :=cdsQry_C.FieldByName('CCOS_D').AsString;
         xCtaHaber:=cdsQry_C.FieldByName('CTAHABER').AsString;
         xAux_H   :=cdsQry_C.FieldByName('AUX_H').AsString;
         xCCos_H  :=cdsQry_C.FieldByName('CCOS_H').AsString;
         xOrigen2 :=cdsQry_C.FieldByName('TDIARID2').AsString;
         cdsQry_C.Close;
         xSQL:=' SELECT CUENTAID,CPTODES FROM CAJA201 WHERE CPTOIS=''R''';
         cdsQry_C.DataRequest( xSQL );
         cdsQry_C.Open;
         xCtaRetDebe    := cdsQry_C.FieldByName('CUENTAID').AsString;
         xGlosaRetDebe  := cdsQry_C.FieldByName('CPTODES').AsString;
         cdsQry_C.Close;
         xSQL:=' SELECT CUENTAID,CPTODES FROM CAJA201 WHERE CPTOIS=''T''';
         cdsQry_C.DataRequest( xSQL );
         cdsQry_C.Open;
         xCtaRetHaber   := cdsQry_C.FieldByName('CUENTAID').AsString;
         xGlosaRetHaber := cdsQry_C.FieldByName('CPTODES').AsString;
         cdsQry_C.Close;

         if ( xCtaDebe='' ) or ( xCtaHaber='' ) then begin
            Errorcount2:=1;
            FSOLConta.CerrarTablas;
            ShowMessage('Error : Caja de Compañía '+xCia+' No es Autonoma. Faltan Cuentas Reflejas');
            Exit;
         end;

         FSOLConta.GeneraAsientosComplementarios( xCia, xTDiario, xAnoMM, xNoComp, xTipoC, cdsMovCNT );

         xSQL:='SELECT * FROM CNT311 '
              +'WHERE CIAID='     +quotedstr( xCia     ) +' AND '
              +      'TDIARID='   +quotedstr( xTDiario ) +' AND '
              +      'CNTANOMM='  +quotedstr( xAnoMM   ) +' AND '
              +      'CNTCOMPROB='+quotedstr( xNoComp  ) +' '
              +'ORDER BY CNTREG';
         cdsMovCNT.Close;
         cdsMovCNT.DataRequest( xSQL );
         cdsMovCNT.Open;

      end;
   end;

   FSOLConta.PanelMsg( 'Generando Asientos Automaticos', 0 );

   // GENERA ASIENTOS AUTOMATICOS PARA LA CUENTA 1

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
       +'FROM '+CNTDet+' A, TGE202 B '
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

   FSOLConta.PanelMsg( 'Generando Asientos Automaticos', 0 );

   iOrden:=iOrdenx;


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
       cdsMovCNT.FieldByName('CNTREG').AsInteger    :=iOrden;
       iOrden:=iOrden+1;
       FSOLConta.cdsPost( cdsMovCNT );

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
       cdsMovCNT.FieldByName('CNTREG').AsInteger    :=iOrden;
       iOrden:=iOrden+1;
       FSOLConta.cdsPost( cdsMovCNT );

       FSOLConta.AplicaDatos( cdsMovCNT, 'MOVCNT' );
     end;

     cdsClone.Next;
   end;
   //
   FSOLConta.AplicaDatos( cdsMovCNT, 'MOVCNT' );
   //
   // CUADRA ASIENTO
   xTotDebeMN:=0;  xTotHaberMN:=0;
   xTotDebeME:=0;  xTotHaberME:=0;
   cdsMovCnt.First ;
   while not cdsMovCnt.eof do begin
      if cdsMovCnt.FieldByName('CNTDH').AsString='D' then begin
         xTotDebeMN := xTotDebeMN  + cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
         xTotDebeME := xTotDebeME  + cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
      end
      else begin
         xTotHaberMN:= xTotHaberMN + cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
         xTotHaberME:= xTotHaberME + cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
      end;
      cdsMovCnt.Next;
   end;

   xDif:=0;

   if cdsMovCnt.FieldByName('TMONID').AsString=wTMonExt_C then
   begin
      if FSOLConta.FRound(xTotHaberMN,15,2)<>FSOLConta.FRound(xTotDebeMN,15,2) then begin
         if FSOLConta.fround(xTotHaberMN,15,2)>FSOLConta.fround(xTotDebeMN,15,2) then begin
            xDIf:=FSOLConta.fround(FSOLConta.fround(xTotHaberMN,15,2)-FSOLConta.fround(xTotDebeMN,15,2),15,2);
            cdsMovCnt.First ;
            while not cdsMovCnt.eof do begin
               if cdsMovCnt.FieldByName('CNTDH').AsString='D' then begin
                  cdsMovCnt.Edit;
                  cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat:=FSOLConta.FRound(cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat+xDif,15,2);
                  cdsMovCnt.FieldByName('CNTDEBEMN').AsFloat:=cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
                  cdsMovCnt.Post;
                  Break;
               end;
               cdsMovCnt.Next;
            end;
         end
         else begin
            xDIf:=FSOLConta.Fround(FSOLConta.fround(xTotDebeMN,15,2)-FSOLConta.fround(xTotHaberMN,15,2),15,2);
            cdsMovCnt.First ;
            while not cdsMovCnt.eof do begin
               if cdsMovCnt.FieldByName('CNTDH').AsString='H' then begin
                  cdsMovCnt.Edit;
                  cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat:=FSOLConta.FRound(cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat+xDif,15,2);
                  cdsMovCnt.FieldByName('CNTHABEMN').AsFloat:=cdsMovCnt.FieldByName('CNTMTOLOC').AsFloat;
                  cdsMovCnt.Post;
                  Break;
               end;
               cdsMovCnt.Next;
            end;
         end

      end;
   end
   else begin
      if FSOLConta.fround(xTotHaberME,15,2)<>FSOLConta.fround(xTotDebeME,15,2) then begin
         if FSOLConta.fround(xTotHaberME,15,2)>FSOLConta.fround(xTotDebeME,15,2) then begin
            xDIf:=FSOLConta.fround(FSOLConta.fround(xTotHaberME,15,2)-FSOLConta.fround(xTotDebeME,15,2),15,2);
            cdsMovCnt.First ;
            while not cdsMovCnt.eof do begin
               if cdsMovCnt.FieldByName('CNTDH').AsString='D' then begin
                  cdsMovCnt.Edit;
                  cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat:=FSOLConta.FRound(cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat+xDif,15,2);
                  cdsMovCnt.FieldByName('CNTDEBEME').AsFloat:=cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
                  cdsMovCnt.Post;
                  Break;
               end;
               cdsMovCnt.Next;
            end;
         end
         else begin
            xDIf:=FSOLConta.fround(FSOLConta.fround(xTotDebeME,15,2)-FSOLConta.fround(xTotHaberME,15,2),15,2);
            cdsMovCnt.First ;
            while not cdsMovCnt.eof do begin
               if cdsMovCnt.FieldByName('CNTDH').AsString='H' then begin
                  cdsMovCnt.Edit;
                  cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat:=FSOLConta.FRound(cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat+xDif,15,2);
                  cdsMovCnt.FieldByName('CNTHABEME').AsFloat:=cdsMovCnt.FieldByName('CNTMTOEXT').AsFloat;
                  cdsMovCnt.Post;
                  Break;
               end;
               cdsMovCnt.Next;
            end;
         end
      end;
   end;

   FSOLConta.AplicaDatos( cdsMovCNT, 'MOVCNT' );
   cdsMovCnt.First;
   cdsMovCnt.EnableControls;
   // FIN CUADRA ASIENTO
   //

   Result:=False;
   cdsMovCNT.EnableControls;

   if (xTipoC='C') or (xTipoC='CCNA') then begin

      xSQL:='Insert into CNT301 ('
           +' CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
           +  'CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
           +  'CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
           +  'CNTFEMIS, CNTFVCMTO, CNTFCOMP, CNTESTADO, CNTCUADRE, CNTFAUTOM, '
           +  'CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
           +  'CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
           +  'TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
           +  'CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
           +  'CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
           +  'CNTMODDOC, CNTREG, MODULO, CTA_SECU ) '
           +'Select CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
           +  'CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
           +  'CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
           +  'CNTFEMIS, CNTFVCMTO, CNTFCOMP, ''P'', ''S'', CNTFAUTOM, '
           +  'CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
           +  'CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
           +  'TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
           +  'CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
           +  'CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
           +  'CNTMODDOC, CNTREG, MODULO, CTA_SECU '
           +'From CNT311 Where '
           +  'CIAID='     +''''+ xCia     +''''+' AND '
           +  'TDIARID='   +''''+ xTDiario +''''+' AND '
           +  'CNTANOMM='  +''''+ xAnoMM   +''''+' AND '
           +  'CNTCOMPROB='+''''+ xNoComp  +'''' ;

      try
         cdsQry_C.Close;
         cdsQry_C.DataRequest( xSQL );
         cdsQry_C.Execute;
      except
         Errorcount2:=1;
         Exit;
      end;

   end;

   // Genera Cabecera si Modulo no es Contabilidad

   xxModulo:=cdsClone.FieldByName('MODULO').AsString;

   cdsClone.First;
   if ( cdsClone.FieldByName('MODULO').AsString<>'CNT') OR
      ( ( cdsClone.FieldByName('MODULO').AsString='CNT') AND
        ( cdsClone.FieldByName('CNTLOTE').AsString='AJDE') ) then begin

      xSQL:='SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB ';
      xSQL:=xSQL+ 'FROM '+CNTCab+' A ';
      xSQL:=xSQL+ 'WHERE A.CIAID='     +''''+xCia    +''''+' and ';
      xSQL:=xSQL+       'A.TDIARID='   +''''+xTDiario+''''+' and ';
      xSQL:=xSQL+       'A.CNTANOMM='  +''''+xAnoMM  +''''+' and ';
      xSQL:=xSQL+       'A.CNTCOMPROB='+''''+xNoComp +''''+' ';

      cdsQry_C.Close;
      cdsQry_C.DataRequest( xSQL );
      cdsQry_C.Open;

      if cdsQry_C.RecordCount<=0 then begin
         if (SRV_C = 'DB2NT') or (SRV_C = 'DB2400') then
         begin
            //xSQL:='INSERT INTO CNT300 ';
            xSQL:='INSERT INTO '+CNTCab;
            xSQL:=xSQL+ '( CIAID, TDIARID, CNTANOMM, CNTCOMPROB, CNTLOTE, ';
            xSQL:=xSQL+ 'CNTGLOSA, CNTTCAMBIO, CNTFCOMP, CNTESTADO, CNTCUADRE, ';
            xSQL:=xSQL+ 'CNTUSER, CNTFREG, CNTHREG, CNTANO, CNTMM, CNTDD, CNTTRI, ';
            xSQL:=xSQL+ 'CNTSEM, CNTSS, CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, ';
            xSQL:=xSQL+ 'TDIARDES, CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, ';
            xSQL:=xSQL+ 'CNTTS, DOCMOD, MODULO ) ' ;

            xSQL:=xSQL+ 'SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB,  A.CNTLOTE, ';
            //xSQL:=xSQL+ 'CASE WHEN MIN(A.CNTREG) = 1 THEN MAX( A.CNTGLOSA ) ELSE  ''COMPROBANTE DE ''||MAX(MODULO) END, ';
            xSQL:=xSQL+ 'MAX( CASE WHEN A.CNTREG = 1 THEN A.CNTGLOSA END ) CNTGLOSA, ';
            xSQL:=xSQL+ 'MAX( COALESCE(A.CNTTCAMBIO, 0 )), ';
            xSQL:=xSQL+ 'A.CNTFCOMP, ''P'', ''S'', ';
            xSQL:=xSQL+ 'MAX(CNTUSER), MAX( CNTFREG ), MAX( CNTHREG ), A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI, ';
            xSQL:=xSQL+ 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
            xSQL:=xSQL+ 'MAX( CASE WHEN A.CNTREG = 1 THEN A.TMONID  END ) TMONID, '' '', ';
            xSQL:=xSQL+ 'A.TDIARDES, ';
            xSQL:=xSQL+ 'SUM(A.CNTDEBEMN), SUM(A.CNTDEBEME), SUM(A.CNTHABEMN), SUM(A.CNTHABEME), ';
            xSQL:=xSQL+ 'MAX( CNTTS ), MAX( CNTMODDOC), MAX( MODULO ) ';
            xSQL:=xSQL+ 'FROM '+CNTDet+' A ';
            xSQL:=xSQL+ 'WHERE A.CIAID='     +''''+xCia    +''''+' AND ';
            xSQL:=xSQL+       'A.TDIARID='   +''''+xTDiario+''''+' AND ';
            xSQL:=xSQL+       'A.CNTANOMM='  +''''+xAnoMM  +''' ';
            xSQL:=xSQL+'AND A.CNTCOMPROB='+''''+xNoComp +''''+' ';
            xSQL:=xSQL+ 'GROUP BY A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB, A.CNTLOTE, ';
            xSQL:=xSQL+ 'A.CNTFCOMP, A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI,  ';
            xSQL:=xSQL+ 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
            xSQL:=xSQL+ 'A.TDIARDES';
         end;

         if SRV_C = 'ORACLE' then
         begin
            xSQL:='INSERT INTO '+CNTCab;
            xSQL:=xSQL+ '( CIAID, TDIARID, CNTANOMM, CNTCOMPROB, CNTLOTE, ';
            xSQL:=xSQL+ 'CNTGLOSA, CNTTCAMBIO, CNTFCOMP, CNTESTADO, CNTCUADRE, ';
            xSQL:=xSQL+ 'CNTUSER, CNTFREG, CNTHREG, CNTANO, CNTMM, CNTDD, CNTTRI, ';
            xSQL:=xSQL+ 'CNTSEM, CNTSS, CNTAATRI, CNTAASEM, CNTAASS, TMONID, ';
            xSQL:=xSQL+ 'FLAGVAR, TDIARDES, CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, ';
            xSQL:=xSQL+ 'CNTTS, DOCMOD, MODULO ) ' ;
            xSQL:=xSQL+ 'SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB,  A.CNTLOTE, ';
            xSQL:=xSQL+ 'DECODE( MIN(A.CNTREG), 1, MAX( A.CNTGLOSA ), ''COMPROBANTE DE ''||MAX(MODULO) ), ';
            xSQL:=xSQL+ 'MAX( NVL( A.CNTTCAMBIO, 0 ) ), ';
            xSQL:=xSQL+ 'A.CNTFCOMP, ''P'', ''S'', ';
            xSQL:=xSQL+ 'MAX( CNTUSER ), MAX( CNTFREG ), MAX( CNTHREG ), A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI, ';
            xSQL:=xSQL+ 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
            xSQL:=xSQL+ 'CASE WHEN SUM( CASE WHEN TMONID='''+wTMonExt_C+''' THEN 1 ELSE 0 END )>'
                      +          ' SUM( CASE WHEN TMONID='''+wTMonLoc_C+''' THEN 1 ELSE 0 END ) '
                      +     ' THEN '''+wTMonExt_C+''' ELSE '''+wTMonLoc_C+''' END, ';
            xSQL:=xSQL+ ''' '', A.TDIARDES, ';
            xSQL:=xSQL+ 'SUM(A.CNTDEBEMN), SUM(A.CNTDEBEME), SUM(A.CNTHABEMN), SUM(A.CNTHABEME), ';
            xSQL:=xSQL+ 'MAX( CNTTS ), MAX( CNTMODDOC), MAX( MODULO ) ';
            xSQL:=xSQL+ 'FROM '+CNTDet+' A ';
            xSQL:=xSQL+ 'WHERE A.CIAID='     +''''+xCia    +''''+' AND ';
            xSQL:=xSQL+       'A.TDIARID='   +''''+xTDiario+''''+' AND ';
            xSQL:=xSQL+       'A.CNTANOMM='  +''''+xAnoMM  +''' ';
            xSQL:=xSQL+'AND A.CNTCOMPROB='+''''+xNoComp +''''+' ';
            xSQL:=xSQL+ 'GROUP BY A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB, A.CNTLOTE, ';
            xSQL:=xSQL+ 'A.CNTFCOMP, A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI,  ';
            xSQL:=xSQL+ 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
            xSQL:=xSQL+ 'A.TDIARDES';
         end;

         try
            cdsQry_C.Close;
            cdsQry_C.DataRequest( xSQL );
            cdsQry_C.Execute;
         except
            Errorcount2:=1;
            Exit;
         end;
      end;
   end;

   cdsClone.Close;
   cdsClone.Free;

   if (xTipoC='C') or (xTipoC='CCNA') then
      FSOLConta.GeneraEnLinea401( xCia, xTDiario, xAnoMM, xNoComp, 'S' );


   pnlConta_C.Free;

   if (xTipoC='C') or (xTipoC='P') or (xTipoC='CCNA') or (xTipoC='PCNA') then begin

      xsql:='SELECT A.*, B.CIADES FROM CNT311 A, TGE101 B '
           +'WHERE ( A.CIAID='     + quotedstr( xCia     )+' AND '
           +        'A.CNTANOMM='  + quotedstr( xAnoMM   )+' AND '
           +        'A.TDIARID='   + quotedstr( xTDiario )+' AND '
           +        'A.CNTCOMPROB='+ quotedstr( xNoComp  )+' AND '
           +        'A.CIAID=B.CIAID ) '
           +        xSQLAdicional2+' '
           +'ORDER BY A.CIAID, A.CNTANOMM, A.TDIARID, A.CNTREG';

      try
         cdsMovCNT.IndexFieldNames:='';
         cdsMovCNT.Filter:='';
         cdsMovCNT.Filtered:=True;
         cdsMovCNT.Close;
         cdsMovCNT.DataRequest(xSQL);
         cdsMovCNT.Open;
      except
         Errorcount2:=1;
         Exit;
      end;
      //end;

      xSQL:='Delete From CNT311 A '
           +'Where ( A.CIAID='     +''''+ xCia     +''''+' AND '
           +        'A.TDIARID='   +''''+ xTDiario +''''+' AND '
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

      if xxModulo<>'CNT' then begin
         xSQL:='Delete From CNT310 '
              +'Where '
              +  'CIAID='     +''''+ xCia     +''''+' AND '
              +  'TDIARID='   +''''+ xTDiario +''''+' AND '
              +  'CNTANOMM='  +''''+ xAnoMM   +''''+' AND '
              +  'CNTCOMPROB='+''''+ xNoComp  +'''' ;
         try
            cdsQry_C.Close;
            cdsQry_C.DataRequest( xSQL );
            cdsQry_C.Execute;
         except
         end;
      end;
   end;

   FSOLConta.CerrarTablas;

   if Errorcount2>0 then Exit;

   Result:=True ;
end;


procedure TFSOLConta.CerrarTablas;
begin
   cdsNivel_C.Filtered:=False;
   cdsNivel_C.Filter:='';
   cdsNivel_C := NIL;
   cdsQry_C.Close;
   cdsQry_C.Free;
end;

procedure TFSOLConta.GeneraEnLinea401( xxxCia, xxxDiario, xxxAnoMM, xxxNoComp, xSuma : String );
var
   xCtaPrin, xClAux, xCuenta, xAuxDes, xAno, xMes, xDH, xSQL, xSQLn   : string;
   xMov, xAux, xCCos, xCCoDes, xCtaDes, xFLAux, xFLCCo, xNivel, xNREG : String;
   xDigitos, xDigAnt, xNumT : Integer;
   xImpMN, xImpME    : Double;
   cdsMovCNT2        : TwwClientDataSet;
   cdsQry2x          : TwwClientDataSet;
   cAno, cMes, cMesA, flDolar : String;
begin
   xAno := Copy(xxxAnoMM,1,4);
   xMes := Copy(xxxAnoMM,5,2);

   FSOLConta.PanelMsg( 'Actualizando Saldos...', 0 );

   cdsQry2x:=TwwClientDataSet.Create(nil);
   cdsQry2x.RemoteServer:=DCOM_C;
   cdsQry2x.ProviderName:=Provider_C;

   xSQL:='Select CNTSOLODOLAR from TGE101 Where CIAID='+quotedstr(xxxCia);
   cdsQry2x.Close;
   cdsQry2x.DataRequest(xSQL); // Llamada remota al provider del servidor
   cdsQry2x.Open;

   flDolar:=cdsQry2x.FieldByname('CNTSOLODOLAR').AsString;

   xSQL:='Select A.CUENTAID, A.CNTDH, SUM( A.CNTMTOLOC ) CNTMTOLOC, SUM( A.CNTMTOEXT ) CNTMTOEXT '
        +'From '+CNTDet+' A '
        +'Where A.CIAID='     +''''+xxxCia   +''''+' AND '
        +      'A.CNTANOMM='  +''''+xxxAnoMM +'''';

   if xTipoC_C='MC' then begin
      if xxxNoComp<>'' then
         xSQL:=xSQL+' and A.CUENTAID='+''''+xxxNoComp+''' ';

      if xxxNoComp='' then // Si es Mayorización Mensual
         xSQL:=xSQL+' and CNTESTADO=''P'' AND CNTCUADRE=''S'' ';

      // vhn 01/08/2002
      // Buscar El Nivel de la Cuenta y Filtrar el CDS de Nivel
      xSQLn:='Select CNT202.*, LENGTH( '''+xxxNoComp+''' ) FROM CNT202 '
            +'Where DIGITOS=LENGTH( '''+xxxNoComp+''' ) ';

      cdsQry2x.Close;
      cdsQry2x.DataRequest(xSQLn); // Llamada remota al provider del servidor
      cdsQry2x.Open;
      cdsNivel_C.Filtered:=False;
      cdsNivel_C.Filter:='';
      cdsNivel_C.Filter:='NIVEL='''+cdsQry2x.FieldByName('NIVEL').AsString+'''';
      cdsNivel_C.Filtered:=True;

   end
   else begin
      if xTipoC_C='MCACC' then begin   // Solo Mayoriza Cuentas con Auxiliar y C.Costo
         xSQL:=xSQL+' and A.TDIARID=''XX'' ';
         xSQL:=xSQL+' and A.CNTCOMPROB=''ZZZZZZZZZZ'' ';
         xSQL:=xSQL+' and CNTESTADO=''P'' AND CNTCUADRE=''S'' ';
      end
      else begin
         if xxxDiario<>'' then
            xSQL:=xSQL+' and A.TDIARID=' +''''+xxxDiario+''' ';

         if xxxNoComp<>'' then
            xSQL:=xSQL+' and A.CNTCOMPROB='+''''+xxxNoComp+''' ';

         if xxxNoComp='' then // Si es Mayorización Mensual
            xSQL:=xSQL+' and CNTESTADO=''P'' AND CNTCUADRE=''S'' ';
      end;
   end;

   xSQL:=xSQL+'Group by A.CUENTAID, A.CNTDH';

   cdsMovCNT2:=TwwClientDataSet.Create(nil);
   cdsMovCNT2.RemoteServer:= DCOM_C;
   cdsMovCNT2.ProviderName:=Provider_C;
   cdsMovCNT2.Close;
   cdsMovCNT2.DataRequest( xSQL );
   cdsMovCNT2.Open;

   FSOLConta.PanelMsg( 'Actualizando Saldos - Cuentas ...', 0 );

   cdsMovCNT2.First;
   while not cdsMovCNT2.Eof do begin

      xCtaPrin:= cdsMovCNT2.FieldByName( 'CUENTAID' ).AsString;
      xDH     := cdsMovCNT2.FieldByName( 'CNTDH'    ).AsString;
      xImpMN  := FRound(cdsMovCNT2.FieldByName( 'CNTMTOLOC').AsFloat,15,2);
      xImpME  := FRound(cdsMovCNT2.FieldByName( 'CNTMTOEXT').AsFloat,15,2);

      // si es Descontabilización
      if xSuma='N' then begin
         xImpMN:= xImpMN * (-1);
         xImpME:= xImpME * (-1);
      end;


      ////////////////////////////////////////////////////////////////
      //  Si Compañía Tiene Flag de Contabilizar Solamente Dolares  //
      ////////////////////////////////////////////////////////////////
      if flDolar='S' then begin

         xSQL:='Select CTA_MOV, CTA_ME from TGE202 '
              +'Where CIAID='   +quotedstr(xxxCia )
              + ' and CUENTAID='+quotedstr(xCtaPrin );
         cdsQry2x.Close;
         cdsQry2x.DataRequest(xSQL); // Llamada remota al provider del servidor
         cdsQry2x.Open;

         if cdsQry2x.FieldByName('CTA_ME').AsString='S' then
         else begin
            xImpME:=0;
         end;

      end;

      xDigAnt := 0;
      cdsNivel_C.First;
      while not cdsNivel_C.EOF do
      begin

         xDigitos := cdsNivel_C.fieldbyName('Digitos').AsInteger;
         xCuenta  := Trim( Copy( xCtaPrin , 1, xDigitos ) );
         xNivel   := cdsNivel_C.fieldbyName('Nivel').AsString;

         xCtaDes := '';
         xMov    := '';

         xSQL:='Select CTAABR, CTA_MOV, CTA_ME from TGE202 '
              +'Where CIAID='+quotedstr(xxxCia)
              +' and CUENTAID='+quotedstr(xCuenta)
              +' AND CTANIV='+quotedstr(xNivel);

         cdsQry2x.Close;
         cdsQry2x.DataRequest(xSQL); // Llamada remota al provider del servidor
         cdsQry2x.Open;

         xCtaDes := cdsQry2x.FieldByName( 'CTAABR'  ).AsString;
         xMov    := cdsQry2x.FieldByName( 'CTA_MOV' ).AsString;

         if Trim(cdsNivel_C.fieldbyName('Signo').AsString)='='  then
            if Length(xCuenta)=xDigitos  then  else Break;
         if cdsNivel_C.fieldbyName('Signo').AsString='<=' then
            if (Length(xCuenta)<=xDigitos) and (Length(xCuenta)>xDigAnt) then  else Break;
         if cdsNivel_C.fieldbyName('Signo').AsString='>=' then
            if Length(xCuenta)>=xDigitos then  else Break;

         if not FSOLConta.CuentaExiste( xxxCia, xAno, xCuenta, '', '', '' ) then
         begin
            FSOLConta.InsertaMov( xxxCia, xxxAnoMM, xCuenta, '', '', '', xDH, xMov,
                                  xCtaDes, '', '' , xNivel,'1', xImpMN, xImpME );
            if Errorcount2>0 then Exit;
         end
         else
         begin
            FSOLConta.ActualizaMov( xxxCia, xxxAnoMM, xCuenta, '', '', '', xDH, xMov,
                          xCtaDes, '', '' , xNivel,'1', xImpMN, xImpME );
            if Errorcount2>0 then Exit;
         end;

         xDigAnt := cdsNivel_C.fieldbyName('Digitos').AsInteger;

         cdsNivel_C.Next;
      end;

      cdsMovCNT2.Next;
   end;


// VERIFICAR PARA QUE SOLO FILTRE LAS CUENTAS QUE TENGAN AUXILIAR Y C.COSTO

   xSQL:='Select A.CUENTAID, A.CLAUXID, A.AUXID, A.AUXDES, A.CCOSID, A.CCOSDES, A.CNTDH, '
        +   'SUM( A.CNTMTOLOC ) CNTMTOLOC, SUM( A.CNTMTOEXT ) CNTMTOEXT, '
        +   'MAX(B.CTANIV) CTANIV, MAX(B.CTAABR) CTAABR, MAX(B.CTA_MOV) CTA_MOV, '
        +   'MAX(B.CTA_AUX) CTA_AUX, MAX(B.CTA_CCOS) CTA_CCOS '
        +'From '+CNTDet+' A, TGE202 B '
        +'Where A.CIAID='     +''''+xxxCia   +''''+' AND '
        +      'A.CNTANOMM='  +''''+xxxAnoMM +'''';

   if xTipoC_C='MC' then begin
      if xxxNoComp<>'' then
         xSQL:=xSQL+' and A.CUENTAID='+''''+xxxNoComp+''' ';

      if xxxNoComp='' then // Si es Mayorización Mensual
         xSQL:=xSQL+' and CNTESTADO=''P'' AND CNTCUADRE=''S'' ';
   end
   else begin
      if xTipoC_C='MCACC' then begin   // Solo Mayoriza Cuentas con Auxiliar y C.Costo
         if xxxDiario<>'' then
            xSQL:=xSQL+' and A.TDIARID=' +''''+xxxDiario+''' ';

         if xxxNoComp<>'' then
            xSQL:=xSQL+' and A.CNTCOMPROB='+''''+xxxNoComp+''' ';

         if xxxNoComp='' then // Si es Mayorización Mensual
            xSQL:=xSQL+' and CNTESTADO=''P'' AND CNTCUADRE=''S'' ';
      end
      else begin
         if xxxDiario<>'' then
            xSQL:=xSQL+' and A.TDIARID=' +''''+xxxDiario+''' ';

         if xxxNoComp<>'' then
            xSQL:=xSQL+' and A.CNTCOMPROB='+''''+xxxNoComp+''' ';

         if xxxNoComp='' then // Si es Mayorización Mensual
            xSQL:=xSQL+' and CNTESTADO=''P'' AND CNTCUADRE=''S'' ';
      end;
   end;

   xSQL:=xSQL
        +  'and A.CIAID=B.CIAID AND A.CUENTAID=B.CUENTAID '
        +'Group by A.CUENTAID, A.CLAUXID, A.AUXID, A.AUXDES, A.CCOSID, A.CCOSDES, A.CNTDH ';

   cdsMovCNT2.Close;
   cdsMovCNT2.DataRequest( xSQL );
   cdsMovCNT2.Open;

   FSOLConta.PanelMsg( 'Actualizando Saldos - Cuentas Auxiliar y C.Costo...', 0 );

   cdsMovCNT2.First;
   while not cdsMovCNT2.Eof do begin

//      PanelMsg( 'Generando Resultados', 0 );

      xCtaPrin:= cdsMovCNT2.FieldByName( 'CUENTAID' ).AsString;
      xDH     := cdsMovCNT2.FieldByName( 'CNTDH'    ).AsString;
      xImpMN  := FRound(cdsMovCNT2.FieldByName( 'CNTMTOLOC').AsFloat,15,2);
      xImpME  := FRound(cdsMovCNT2.FieldByName( 'CNTMTOEXT').AsFloat,15,2);
      xClAux  := cdsMovCNT2.FieldByName( 'CLAUXID'  ).AsString;
      xAux    := cdsMovCNT2.FieldByName( 'AUXID'    ).AsString;
      xAuxDes := cdsMovCNT2.FieldByName( 'AUXDES'   ).AsString;
      xCCos   := cdsMovCNT2.FieldByName( 'CCOSID'   ).AsString;
      xCCoDes := cdsMovCNT2.FieldByName( 'CCOSDES'  ).AsString;
      xCuenta := cdsMovCNT2.FieldByName( 'CUENTAID' ).AsString;
      xCtaDes := cdsMovCNT2.FieldByName( 'CTAABR'   ).AsString;
      xMov    := cdsMovCNT2.FieldByName( 'CTA_MOV'  ).AsString;
      xFlAux  := cdsMovCNT2.FieldByName( 'CTA_AUX'  ).AsString;
      xFlCCo  := cdsMovCNT2.FieldByName( 'CTA_CCOS' ).AsString;

      if xSuma='N' then begin
         xImpMN:= xImpMN * (-1);
         xImpME:= xImpME * (-1);
      end;

      ////////////////////////////////////////////////////////////////
      //  Si Compañía Tiene Flag de Contabilizar Solamente Dolares  //
      ////////////////////////////////////////////////////////////////
      if flDolar='S' then begin

         xSQL:='Select CTA_MOV, CTA_ME from TGE202 '
              +'Where CIAID='   +quotedstr(xxxCia )
              + ' and CUENTAID='+quotedstr(xCtaPrin );
         cdsQry2x.Close;
         cdsQry2x.DataRequest(xSQL); // Llamada remota al provider del servidor
         cdsQry2x.Open;

         if cdsQry2x.FieldByName('CTA_ME').AsString='S' then
         else begin
            xImpME:=0;
         end;

      end;


      ///////////////////////////
      //   Si Tiene Auxiliar   //
      ///////////////////////////
      if (xFlAux='S') and (xFlCCo='N') then
      begin

         if xAux='' then xAux:='OTROS';

         if not CuentaExiste( xxxCia, xAno, xCuenta, xClAux, xAux, '' ) then
         begin
            InsertaMov( xxxCia, xxxAnoMM, xCuenta, xClAux, xAux, '', xDH, xMov,
                        xCtaDes, xAuxDes, '' , xNivel,'2',xImpMN, xImpME );
            if Errorcount2>0 then Exit;
         end
         else
         begin
            ActualizaMov( xxxCia, xxxAnoMM, xCuenta, xClAux, xAux,'',xDH, xMov,
                          xCtaDes, xAuxDes, '' , xNivel,'2', xImpMN, xImpME );
            if Errorcount2>0 then Exit;
         end;
      end;

      ///////////////////////////
      //   Si Tiene C.Costo    //
      ///////////////////////////
      if (xFlCCo='S') and (xFlAux='N') then
      begin

         if xCCos='' then xCCos:='OTROS';

         if not CuentaExiste( xxxCia, xAno, xCuenta, '', '', xCCos ) then
         begin
            InsertaMov( xxxCia, xxxAnoMM, xCuenta, '', '', xCCos, xDH, xMov,
                        xCtaDes, xAuxDes, xCCoDes, xNivel, '3', xImpMN, xImpME );
            if Errorcount2>0 then Exit;
         end
         else
         begin
            ActualizaMov( xxxCia, xxxAnoMM, xCuenta, '', '', xCCos, xDH, xMov,
                          xCtaDes, xAuxDes, xCCoDes, xNivel, '3', xImpMN, xImpME );
            if Errorcount2>0 then Exit;
         end;
      end;

       //** 2002/02/12 - PJSV
      ///////////////////////////
      //   Si Tiene aUXILIAR Y C.Costo    //
      ///////////////////////////
      if (xFlCCo='S') AND (xFlAux='S') then
      begin

         if xAux=''  then xAux :='OTROS';
         if xCCos='' then xCCos:='OTROS';

         if not CuentaExiste( xxxCia, xAno, xCuenta, xClAux, xAux, xCCos ) then
         begin
            InsertaMov( xxxCia,xxxAnoMM,xCuenta, xClAux, xAux, xCCos, xDH,xMov,
                        xCtaDes, xAuxDes, xCCoDes, xNivel,'4',xImpMN, xImpME );
            if Errorcount2>0 then Exit;
         end
         else
         begin
            ActualizaMov( xxxCia,xxxAnoMM,xCuenta,xClAux,xAux, xCCos, xDH,xMov,
                          xCtaDes, xAuxDes, xCCoDes, xNivel,'4', xImpMN, xImpME );
            if Errorcount2>0 then Exit;
         end;
      end;
      //**

      cdsMovCNT2.Next;
   end;

   // Cuando es Mayorización por Compañía y Periodo
   if xTipoC_C='MC' then begin

      cAno  := Copy( xxxAnoMM,1,4 );
      cMes  := Copy( xxxAnoMM,5,2 );
      cMesA := StrZero( IntToStr( StrToInt( Copy( xxxAnoMM,5,2 ) )-1 ), 2 );

      xSQL:='Update CNT401 Set '
           +  'SALDMN'+ cMes +'='
           +'ROUND( '+wReplaCeros+'(SALDMN'+ cMesA +',0)+'+wReplaCeros+'( DEBEMN'+ cMes +',0)-'+wReplaCeros+'( HABEMN'+ cMes +',0),2 ) , '
           +  'SALDME'+ cMes +'='
           +'ROUND( '+wReplaCeros+'(SALDME'+ cMesA +',0)+'+wReplaCeros+'( DEBEME'+ cMes +',0)-'+wReplaCeros+'( HABEME'+ cMes +',0),2 ) '
           +'Where CIAID='''+xxxCia+''' and ANO='''+cAno+''' '
           +  'and CUENTAID='+''''+xxxNoComp+''' ';

      try
         cdsQry_C.Close;
         cdsQry_C.DataRequest( xSQL );
         cdsQry_C.Execute;
      except
         Errorcount2:=1;
         Exit;
      end;
   end
   else begin
      if xTipoC_C='MCACC' then begin   // Solo Mayoriza Cuentas con Auxiliar y C.Costo
         cAno  := Copy( xxxAnoMM,1,4 );
         cMes  := Copy( xxxAnoMM,5,2 );
         cMesA := StrZero( IntToStr( StrToInt( Copy( xxxAnoMM,5,2 ) )-1 ), 2 );

         xSQL:='Update CNT401 Set '
              +  'SALDMN'+ cMes +'='
              +'ROUND( '+wReplaCeros+'(SALDMN'+ cMesA +',0)+'+wReplaCeros+'( DEBEMN'+ cMes +',0)-'+wReplaCeros+'( HABEMN'+ cMes +',0),2 ) , '
              +  'SALDME'+ cMes +'='
              +'ROUND( '+wReplaCeros+'(SALDME'+ cMesA +',0)+'+wReplaCeros+'( DEBEME'+ cMes +',0)-'+wReplaCeros+'( HABEME'+ cMes +',0),2 ) '
              +'Where CIAID='''+xxxCia+''' and ANO='''+cAno+''''
              + ' and ( TIPREG=''2'' or TIPREG=''3'' or TIPREG=''4'' )'  ;
         try
            cdsQry_C.Close;
            cdsQry_C.DataRequest( xSQL );
            cdsQry_C.Execute;
         except
            Errorcount2:=1;
            Exit;
         end;
      end
      else begin
         if (xxxDiario='') and (xxxNoComp='') then begin

            cAno  := Copy( xxxAnoMM,1,4 );
            cMes  := Copy( xxxAnoMM,5,2 );
            cMesA := StrZero( IntToStr( StrToInt( Copy( xxxAnoMM,5,2 ) )-1 ), 2 );

            xSQL:='Update CNT401 Set '
                 +  'SALDMN'+ cMes +'='
                 +'ROUND( '+wReplaCeros+'(SALDMN'+ cMesA +',0)+'+wReplaCeros+'( DEBEMN'+ cMes +',0)-'+wReplaCeros+'( HABEMN'+ cMes +',0),2 ) , '
                 +  'SALDME'+ cMes +'='
                 +'ROUND( '+wReplaCeros+'(SALDME'+ cMesA +',0)+'+wReplaCeros+'( DEBEME'+ cMes +',0)-'+wReplaCeros+'( HABEME'+ cMes +',0),2 ) '
                 +'Where CIAID='''+xxxCia+''' and ANO='''+cAno+'''';
            try
               cdsQry_C.Close;
               cdsQry_C.DataRequest( xSQL );
               cdsQry_C.Execute;
            except
               Errorcount2:=1;
               Exit;
            end;
         end;
      end;
   end;
   FSOLConta.PanelMsg( 'Final de Actualiza Saldos...', 0 );

   cdsQry2x.IndexFieldNames:='';

   cdsNivel_C.Filtered:=False;
   cdsNivel_C.Filter:='';
   cdsMovCNT2.Close;
   cdsMovCNT2.Free;
   cdsQry2x.Close;
   cdsQry2x.Free;
end;


function TFSOLConta.CuentaExiste( xCia1, xAno1, xCuenta1, xCLAux1, xAux1, xCCos1: String ): Boolean;
var
   xSQL : String;
   xClAuxid, xAuxid, xCCosid : String;
begin
   xClAuxid:='';
   xAuxid  :='';
   xCCosid :='';

   If xCLAux1='' then
      xClAuxid := '( CLAUXID='+quotedstr( xClAux1 )+' OR CLAUXID IS NULL ) AND '
   else
      xClAuxid := 'CLAUXID='+quotedstr( xClAux1 ) + ' AND ';

   If xAux1='' then
      xAuxid := '( AUXID='+quotedstr( xAux1 )+' OR AUXID IS NULL ) AND '
   else
      xAuxid := 'AUXID='+quotedstr( xAux1 ) + ' AND ';

   If xCCos1='' then
      xCcosid := '( CCOSID='+quotedstr( xCCos1 )+' OR CCOSID IS NULL )'
   else
      xCcosid := 'CCOSID='+quotedstr( xCCos1 );

   xSQL:='Select COUNT(*) TOTREG from CNT401 '
        +'Where CIAID='   +''''+ xCia1   +''''+' and '
        +      'ANO='     +''''+ xAno1   +''''+' and '
        +      'CUENTAID='+''''+ xCuenta1+''''+' and ';
   xSQL:=xSQL + xClAuxId + xAuxid + xCCosid;

   cdsQry_C.Close;
   cdsQry_C.DataRequest( xSQL );
   cdsQry_C.Open;

   if cdsQry_C.fieldbyName('TOTREG').asInteger>0 then
      Result:=True
   else
      Result:=False;
end;


procedure TFSOLConta.ActualizaMov(cCia,cAnoMM,cCuenta,cClAux,cAux,cCCosto,cDH, cMov,
                            cCtaDes,cAuxDes,cCCoDes,cNivel,cTipReg: String;
                            nImpMN,nImpME:double );
var
   cMes, cAno, cSQL, cMesT, cMesA : String;
   nMes             : Integer;
   xAuxid,xCcosid,xClauxid : String;
begin

   cAno  := Copy( cAnoMM,1,4 );
   cMes  := Copy( cAnoMM,5,2 );

   cMesA := StrZero( IntToStr( StrToInt(cMes)-1 ), 2 );

   cSQL := 'Update CNT401 Set CTADES ='+''''+cCtaDes+''''+', '
                            +'AUXDES ='+QuotedStr(cAuxDes)+', '
                            +'CCODES ='+''''+cCCoDes+''''+', '
                            +'TIPREG ='+''''+cTipReg+''''+', ';

   if (SRV_C='DB2NT') or (SRV_C='DB2400') then
   begin
      if cDH='D' then begin
         cSQL:=cSQL+'  DEBEMN'+ cMes +'='+
                    ' '+wReplaCeros+'( DEBEMN'+ cMes +',0) + '+ FloatToStr( nImpMN )+' ';
         cSQL:=cSQL+', DEBEME'+ cMes+'='+
                    ' '+wReplaCeros+'( DEBEME'+ cMes +',0) + '+ FloatToStr( nImpME )+' ';
      end;
      if cDH='H' then begin
         cSQL:=cSQL+'  HABEMN'+ cMes +'='+
                    ' '+wReplaCeros+'( HABEMN'+ cMes +',0) + '+ FloatToStr( nImpMN )+' ';
         cSQL:=cSQL+', HABEME'+ cMes +'='+
                    ' '+wReplaCeros+'( HABEME'+ cMes +',0) + '+ FloatToStr( nImpME )+' ';
      end;
   end
   else
   if SRV_C='ORACLE' then
   begin
      if cDH='D' then begin
         cSQL:=cSQL+'  DEBEMN'+ cMes +'='+
                    'ROUND( '+wReplaCeros+'( DEBEMN'+ cMes +',0)+ROUND('+ FloatToStr( nImpMN )+',2 ),2 ) ';
         cSQL:=cSQL+', DEBEME'+ cMes+'='+
                    'ROUND( '+wReplaCeros+'( DEBEME'+ cMes +',0)+ROUND('+ FloatToStr( nImpME )+',2 ),2 ) ';
      end;
      if cDH='H' then begin
         cSQL:=cSQL+'  HABEMN'+ cMes +'='+
                    'ROUND( '+wReplaCeros+'( HABEMN'+ cMes +',0)+ROUND('+ FloatToStr( nImpMN )+',2 ),2 ) ';
         cSQL:=cSQL+', HABEME'+ cMes +'='+
                    'ROUND( '+wReplaCeros+'( HABEME'+ cMes +',0)+ROUND('+ FloatToStr( nImpME )+',2 ),2 ) ';
      end;
   end;

   cSQL:=cSQL + ', SALDMN'+ cMes +'=';

   if cMesA>='00' then
      cSQL:=cSQL + '('+wReplaCeros+'(SALDMN'+ cMesA +',0)+'+wReplaCeros+'( DEBEMN'+ cMes +',0)-'+wReplaCeros+'( HABEMN'+ cMes +',0)'
   else
      cSQL:=cSQL + '('+wReplaCeros+'( DEBEMN'+ cMes +',0)-'+wReplaCeros+'( HABEMN'+ cMes +',0)';

   if cDH='D' then cSQL:=cSQL+'+'
   else cSQL:=cSQL+'-';
   cSQL:=cSQL + '('+FloatToStr( nImpMN )+') ) ';

   cSQL:= cSQL + ', SALDME'+ cMes +'=';

   if cMesA>='00' then
      cSQL:= cSQL + '('+wReplaCeros+'(SALDME'+ cMesA +',0)+'+wReplaCeros+'( DEBEME'+ cMes +',0)-'+wReplaCeros+'( HABEME'+ cMes +',0)'
   else
      cSQL:= cSQL + '('+wReplaCeros+'( DEBEME'+ cMes +',0)-'+wReplaCeros+'( HABEME'+ cMes +',0)';

   if cDH='D' then cSQL:=cSQL+'+'
   else cSQL:=cSQL+'-';
   cSQL:=cSQL + '('+FloatToStr( nImpME )+') ) ';

   for nMes:=(StrToInt( cMes )+1) to 13 do begin
       cMesT := StrZero( IntToStr( nMes),2);

       cSQL:= cSQL + ', SALDMN'+ cMesT +'=';
       cSQL:= cSQL + '( '+wReplaCeros+'(SALDMN'+ cMesT +',0)';
       if cDH='D' then cSQL:=cSQL+'+' else cSQL:=cSQL+'-';
       cSQL:=cSQL + ' ( '+FloatToStr( nImpMN )+' ) '+' ) ';

       cSQL:= cSQL + ', SALDME'+ cMesT +'=';
       cSQL:= cSQL + '( '+wReplaCeros+'(SALDME'+ cMesT +',0)';
       if cDH='D' then cSQL:=cSQL+'+' else cSQL:=cSQL+'-';
       cSQL:=cSQL + ' ( '+FloatToStr( nImpME )+' ) '+' ) ';

   end;

   If cAux = '' then
     xAuxid := ' AND ( AUXID='+quotedstr(cAux)+' OR AUXID IS NULL ) '
   else
     xAuxid := ' AND AUXID='+quotedstr(cAux) + ' ';

   If cCCosto = '' then
      xCcosid := ' AND ( CCOSID='+quotedstr(cCCosto)+' OR CCOSID IS NULL ) '
   else
      xCcosid := ' AND CCOSID='+quotedstr(cCCosto) + ' ';

   If cClAux = '' then
      xClauxid := 'AND ( CLAUXID='+quotedstr(cClAux)+' OR CLAUXID IS NULL )'
   else
      xClauxid := 'AND CLAUXID='+quotedstr(cClAux);

   cSQL:=cSQL + 'Where CIAID=   '+''''+cCia    +''''+' and '
              +       'ANO=     '+''''+cAno    +''''+' and '
              +       'CUENTAID='+''''+cCuenta +''''+' ';

   cSQL:=cSQL +xClauxid+xAuxid+xCcosid;

   try
      cdsQry_C.Close;
      cdsQry_C.DataRequest( cSQL );
      cdsQry_C.Execute;
   except
      Errorcount2:=1;
   end;
end;


procedure TFSOLConta.InsertaMov(cCia,cAnoMM,cCuenta,cClAux,cAux,cCCosto,cDH, cMov,
                          cCtaDes,cAuxDes,cCCoDes,cNivel, cTipReg: String; nImpMN,nImpME: Double) ;
var
   cMes, cAno, cSQL, cMesT : String;
   nMes             : Integer;
   xCtaMov : String;
begin
   cAno := Copy( cAnoMM,1,4 );
   cMes := Copy( cAnoMM,5,2 );

   cSQL := 'Insert into CNT401( CIAID, ANO, CUENTAID, CLAUXID, AUXID, '
         +                    ' CCOSID, CTADES, AUXDES, CCODES, TIPO ,CTA_MOV ';

   if cDH='D' then cSQL:=cSQL+ ', DEBEMN'+ cMes + ', DEBEME' + cMes;
   if cDH='H' then cSQL:=cSQL+ ', HABEMN'+ cMes + ', HABEME' + cMes;

   //** 13/08/2001 - pjsv, para que genere el saldo del mes del movimiento
   cSQL:=cSQL + ', SALDMN'+ cMes;
   cSQL:=cSQL + ', SALDME'+ cMes;
   //**

   for nMes:=(StrToInt( cMes )+1) to 13 do begin
       cMesT := StrZero( IntToStr( nMes ),2);
       cSQL:=cSQL + ', SALDMN'+ cMesT;
       cSQL:=cSQL + ', SALDME'+ cMesT;
   end;
   cSQL:=cSQL+', TIPREG ) ';
   cSQL:=cSQL+'Values( '+''''+cCia    +''''+', '+''''+cAno   +''''+', '
                        +''''+cCuenta +''''+', '+''''+cClAux +''''+', '
                        +''''+cAux    +''''+', '+''''+cCCosto+''''+', '
                        +''''+cCtaDes +''''+', '+QuotedStr(cAuxDes)+', '
                        +''''+cCCoDes +''''+', '+''''+cNivel +''''+', '
                        +quotedstr( cMov)+','
                        +FloatToStr( nImpMN )+', '
                        +FloatToStr( nImpME )+' ';

   //** 13/08/2001 - psjv, para el monto del mes del movimiento
   if cDH='D' then cSQL:=cSQL+', + (' else cSQL:=cSQL+', - (';
     cSQL:=cSQL + FloatToStr( nImpMN )+') ';
   if cDH='D' then cSQL:=cSQL+', + (' else cSQL:=cSQL+', - (';
     cSQL:=cSQL + FloatToStr( nImpME )+') ';
   //**

   for nMes:=(StrToInt( cMes )+1) to 13 do begin
       cMesT := StrZero( IntToStr( nMes ),2);
       if cDH='D' then cSQL:=cSQL+', + (' else cSQL:=cSQL+', - (';
       cSQL:=cSQL + FloatToStr( nImpMN )+') ';
       if cDH='D' then cSQL:=cSQL+', + (' else cSQL:=cSQL+', - (';
       cSQL:=cSQL + FloatToStr( nImpME )+') ';
   end;

   cSQL:=cSQL+','''+cTipReg+''' ) ';

   try
      cdsQry_C.Close;
      cdsQry_C.DataRequest( cSQL );
      cdsQry_C.Execute;
   except
      Errorcount2:=1;
   end;
end;


function TFSOLConta.StrZero(wNumero:String;wLargo:Integer):string;
var
   i : integer;
   s : string;
begin
   s := '';
   for i:=1 to wLargo do
   begin
      s := s+'0';
   end;
   s := s+trim(wNumero);
   result:= copy(s,length(s)-(wLargo-1),wLargo);
end;

function TFSOLConta.FRound(xReal:DOUBLE;xEnteros,xDecimal:Integer):DOUBLE;
Var
   xNum   : String;
   code   : Integer;
   xNReal : DOUBLE;
begin
   xNum := Floattostrf( xReal, ffFixed, xEnteros, xDecimal );
   Val( xNum, xNReal, code );
   Result := xNReal;
end;

procedure TFSOLConta.AplicaDatos(wCDS: TClientDataSet; wNomArch : String);
var
  Delta, Results, OwnerData : OleVariant;
  ErrorCount_C : Integer;
begin
    ErrorCount_C:=0;

    if (wcds.ChangeCount>0) or (wcds.Modified) then begin

{       if (SRV_C = 'DB2NT') then
          DCOM_C.AppServer.ParamDSPGraba('1', wNomArch);
}
       wCDS.CheckBrowseMode;

       Results:=DCOM_C.AppServer.AS_ApplyUpdates(wCDS.ProviderName,wcds.Delta, -1,
                                              ErrorCount_C,OwnerData);
       cdsResultSet_C.Data := Results;
       wCDS.Reconcile(Results);
{
       if (SRV_C = 'DB2NT') then
          DCOM_C.AppServer.ParamDSPGraba('0', wNomArch);
}
    end;
end;


procedure TFSOLConta.CreaPanel( xForma:TForm; xMensaje:String );
begin
   pnlConta_C := TPanel.Create( xForma );
   pbConta_C  := TProgressBar.Create( NIL );
   pbConta_C.Width:= 300;
   pbConta_C.Top  := 72;
   pbConta_C.Left := 48;
   pbConta_C.Min  := 0;
   pbConta_C.Max  := 6;
   pbConta_C.Parent := pnlConta_c;
   pnlConta_C.Alignment := taCenter;
   pnlConta_C.BringToFront;
   pnlConta_C.Width  := 400;
   pnlConta_C.Height := 100;
   pnlConta_C.Top    := xForma.Height-380;
   pnlConta_C.Left   := strtoInt(FloattoStr(FRound( ( ((xForma.Width-100))/2)-100,3,0 )));
   pnlConta_C.Parent := xForma;
   pnlConta_C.BevelInner := bvRaised;
   pnlConta_C.BevelOuter := bvRaised;
   pnlConta_C.BevelWidth := 3;
   pnlConta_C.Font.Name  := 'Times New Roman';
   pnlConta_C.Font.Style := [fsBold,fsItalic];
   pnlConta_C.Font.Size  := 12;
   pnlConta_C.Caption:= xMensaje;
   pbConta_C.Position:=0;
   pnlConta_C.Refresh;
end;

procedure TFSOLConta.PanelMsg( xMensaje:String; xProc:Integer );
begin
   If xProc>0 then begin
      pbConta_C.Position:= 0;
      pbConta_C.Min     := 0;
      pbConta_C.Max     := xProc;
   end;
   pnlConta_C.Caption:= xMensaje;
   If xProc=0 then pbConta_C.Position:= pbConta_C.Position + 1;
   pnlConta_C.Refresh;
end;


procedure TFSOLConta.GeneraAsientosComplementarios( xCia, xDiario, xAnoMM, xNoComp, xTCP : String; cdsMovCNT : TwwClientDataSet );
var
   cdsQryT  : TwwClientDataSet;
   xSQL, xWhere : String;
   xCtaCaja : String;
   sDeHa    : String;
   dHabeMN, dHabeME, dDebeMN, dDebeME  : Double;
   nReg : Integer;
begin

   // Números de Comprobantes Nuevos
   // Caja Autonoma
   if (SRV_C = 'DB2NT') or (SRV_C = 'DB2400') then begin
      xWhere:='SELECT COALESCE( MAX( CNTCOMPROB ), ''0'' ) AS NUMERO FROM CNT300 '
             +'WHERE CIAID='   +''''+ xCiaori  +''''
             + ' and TDIARID=' +''''+ xOrigen2 +''''
             + ' and CNTANOMM='+''''+ xAnoMM   +'''';
   end;

   if SRV_C = 'ORACLE' then begin
      xWhere:='SELECT NVL( MAX( CNTCOMPROB ), ''0'' ) AS NUMERO FROM CNT300 '
             +'WHERE CIAID='   +''''+ xCiaOri  +''''
             + ' and TDIARID=' +''''+ xOrigen2 +''''
             + ' and CNTANOMM='+''''+ xAnoMM   +'''';
   end;



   // Verifica si ya tiene comprobantes
   xWhere:='SELECT ECPERREC FROM CAJA302 '
          +'WHERE CIAID='   +''''+ xCia     +''''
          + ' and TDIARID=' +''''+ xDiario  +''''
          + ' and ECANOMM=' +''''+ xAnoMM   +''''
          + ' and ECNOCOMP='+''''+ xNoComp  +'''';

   cdsQryT:=TwwClientDataSet.Create(nil);
   cdsQryT.RemoteServer:=DCOM_C;
   cdsQryT.ProviderName:=Provider_C;

   cdsQryT.Close;
   cdsQryT.DataRequest( xWhere );
   cdsQryT.Open;

   xNoComp1:='';
   xNoComp2:='';
   if cdsQryT.FieldByname('ECPERREC').AsString<>'' then begin
      xNoComp1:=Copy(cdsQryT.FieldByname('ECPERREC').AsString,10,10);
      xNoComp2:=Copy(cdsQryT.FieldByname('ECPERREC').AsString,31,10);
   end
   else begin
      // NUMEROS EN CAJA
      if (SRV_C = 'DB2NT') or (SRV_C = 'DB2400') then begin
         xWhere:='SELECT COALESCE( MAX( ECNOCOMP ), ''0'' ) AS NUMERO FROM CAJA302 '
                +'WHERE CIAID='   +''''+ xCiaori  +''''
                + ' and TDIARID=' +''''+ xOrigen2 +''''
                + ' and ECANOMM=' +''''+ xAnoMM   +'''';
      end;
      if SRV_C = 'ORACLE' then begin
         xWhere:='SELECT NVL( MAX( ECNOCOMP ), ''0'' ) AS NUMERO FROM CAJA302 '
                +'WHERE CIAID='   +''''+ xCiaOri  +''''
                + ' and TDIARID=' +''''+ xOrigen2 +''''
                + ' and ECANOMM=' +''''+ xAnoMM   +'''';
      end;
      cdsQryT.Close;
      cdsQryT.DataRequest( xWhere );
      cdsQryT.Open;

      xNoComp1:=Inttostr( StrToInt( cdsQryT.FieldByname('NUMERO').AsString ) +1 );
      xNoComp1:=StrZero(xNoComp1,10);
   end;

   xSQL:='SELECT CUENTAID, FCAB, DCDH, TMONID, DCMTOLO, DCMTOEXT FROM CAJA304 '
        +'WHERE '
        +  'CIAID='   +''''+ xCia     +''''+' AND '
        +  'TDIARID=' +''''+ xDiario  +''''+' AND '
        +  'ECANOMM=' +''''+ xAnoMM   +''''+' AND '
        +  'ECNOCOMP='+''''+ xNoComp  +''''+' AND '
        +  'FCAB=''1'' AND DCDH=''H'' ';
   cdsQry_C.Close;
   cdsQry_C.DataRequest( xSQL );
   cdsQry_C.Open;

   xCtaCaja:=cdsQry_C.FieldByName('CUENTAID').AsString;

    xSQL:='SELECT * FROM CNT311 '
        + 'WHERE '
        +   'CIAID='     +''''+ xCia     +''''+' AND '
        +   'TDIARID='   +''''+ xDiario  +''''+' AND '
        +   'CNTANOMM='  +''''+ xAnoMM   +''''+' AND '
        +   'CNTCOMPROB='+''''+ xNoComp  +''''+' '
        + 'ORDER BY CNTREG';
   cdsQry_C.Close;
   cdsQry_C.DataRequest( xSQL );
   cdsQry_C.Open;

   cdsMovCNT.Close;
   cdsMovCNT.DataRequest( 'Select * from CNT311 '
                         + 'Where CIAID='''+xCiaOri +''' AND TDIARID=''' +xOrigen2+''' AND '
                         +       'CNTANOMM='''+xAnoMM  +''' and CNTCOMPROB='''+xNoComp1+'''' );
   cdsMovCNT.Open;

   nReg:=0;
   while (not cdsQry_C.Eof) do begin

      if (xCtaCaja<>cdsQry_C.FieldByName('CUENTAID').AsString) AND (xCtaRetHaber<>cdsQry_C.FieldByName('CUENTAID').AsString) then begin

         if ( cdsQry_C.FieldByName('CNTMTOLOC').AsFloat=0 ) or
            ( cdsQry_C.FieldByName('CNTMTOEXT').AsFloat=0 ) then begin

            //
            // CUENTAS PRIMER ASIENTO
            //
            if cdsQry_C.FieldByName('CNTDH').AsString='D' then
            begin
              sDeHa:='D';
              dHabeMN:=0;
              dHabeME:=0;
              dDebeMN:=cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
              dDebeME:=cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            end
            else
            begin
              sDeHa:='H';
              dDebeMN:=0;
              dDebeME:=0;
              dHabeMN:=cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
              dHabeME:=cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            end;

            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString      :=xCiaOri;
            cdsMovCNT.FieldByName('TDIARID').AsString    :=xOrigen2;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString :=xNoComp1;
            cdsMovCNT.FieldByName('CNTANOMM').AsString   :=xAnoMM;

            //cdsMovCNT.FieldByName('CUENTAID').AsString   :=cdsQry_C.FieldByName('CUENTAID').AsString;
            cdsMovCNT.FieldByName('CUENTAID').AsString   :=xCtaDebe;

            if xAux_D='S' then begin
               cdsMovCNT.FieldByName('CLAUXID').AsString :=cdsQry_C.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString   :=cdsQry_C.FieldByName('AUXID').AsString;
            end;
            if xCCos_D='S' then begin
               cdsMovCNT.FieldByName('CCOSID').AsString  :=cdsQry_C.FieldByName('CCOSID').AsString;
            end;
            cdsMovCNT.FieldByName('CNTLOTE').AsString    :=cdsQry_C.FieldByName('CNTLOTE').AsString;
            cdsMovCNT.FieldByName('CNTMODDOC').AsString  :=cdsQry_C.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString      :=cdsQry_C.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString   :=cdsQry_C.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString   :=cdsQry_C.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString   :=cdsQry_C.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString      :=sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString :=cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString  :=cdsQry_C.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString  :=cdsQry_C.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString  :=cdsQry_C.FieldByName('CNTMTOEXT').AsString;
            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime :=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime:=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime :=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString  :='P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString  :='S';
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString  :='S';
            cdsMovCNT.FieldByName('CNTUSER').AsString    :=cdsQry_C.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime  :=cdsQry_C.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime  :=cdsQry_C.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString     :=cdsQry_C.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString      :=cdsQry_C.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString      :=cdsQry_C.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString     :=cdsQry_C.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString     :=cdsQry_C.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString      :=cdsQry_C.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString   :=cdsQry_C.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString   :=cdsQry_C.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString    :=cdsQry_C.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString     :=cdsQry_C.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString   :=cdsQry_C.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString     :=cdsQry_C.FieldByName('AUXDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString     :=cdsQry_C.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString    :=cdsQry_C.FieldByName('CCOSDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat   :=dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat   :=dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat   :=dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat   :=dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString     :=cdsQry_C.FieldByName('MODULO').AsString;
            nReg:=nReg+1;
            cdsMovCNT.FieldByName('CNTREG').AsInteger    :=nReg;
            cdsPost( cdsMovCNT );
         end
         else begin

            //
            // CUENTAS PRIMER ASIENTO
            //
            if cdsQry_C.FieldByName('CNTDH').AsString='D' then
            begin
              sDeHa:='D';
              dHabeMN:=0;
              dHabeME:=0;
              dDebeMN:=cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
              dDebeME:=cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            end
            else
            begin
              sDeHa:='H';
              dDebeMN:=0;
              dDebeME:=0;
              dHabeMN:=cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
              dHabeME:=cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
            end;

            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString      :=xCiaOri;
            cdsMovCNT.FieldByName('TDIARID').AsString    :=xOrigen2;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString :=xNoComp1;
            cdsMovCNT.FieldByName('CNTANOMM').AsString   :=xAnoMM;
            cdsMovCNT.FieldByName('CUENTAID').AsString   :=xCtaDebe;
            cdsMovCNT.FieldByName('CNTLOTE').AsString    :=cdsQry_C.FieldByName('CNTLOTE').AsString;
            if xAux_D='S' then begin
               cdsMovCNT.FieldByName('CLAUXID').AsString :=cdsQry_C.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString   :=cdsQry_C.FieldByName('AUXID').AsString;
            end;
            if xCCos_D='S' then begin
               cdsMovCNT.FieldByName('CCOSID').AsString  :=cdsQry_C.FieldByName('CCOSID').AsString;
            end;
            cdsMovCNT.FieldByName('CNTMODDOC').AsString  :=cdsQry_C.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString      :=cdsQry_C.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString   :=cdsQry_C.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString   :=cdsQry_C.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString   :=cdsQry_C.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString      :=sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString :=cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString  :=cdsQry_C.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString  :=cdsQry_C.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString  :=cdsQry_C.FieldByName('CNTMTOEXT').AsString;

            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime :=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime:=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime :=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString  :='P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString  :='S';
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString  :='S';
            cdsMovCNT.FieldByName('CNTUSER').AsString    :=cdsQry_C.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime  :=cdsQry_C.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime  :=cdsQry_C.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString     :=cdsQry_C.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString      :=cdsQry_C.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString      :=cdsQry_C.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString     :=cdsQry_C.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString     :=cdsQry_C.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString      :=cdsQry_C.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString   :=cdsQry_C.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString   :=cdsQry_C.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString    :=cdsQry_C.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString     :=cdsQry_C.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString   :=cdsQry_C.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString     :=cdsQry_C.FieldByName('AUXDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString     :=cdsQry_C.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString    :=cdsQry_C.FieldByName('CCOSDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat   :=dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat   :=dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat   :=dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat   :=dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString     :=cdsQry_C.FieldByName('MODULO').AsString;
            nReg:=nReg+1;
            cdsMovCNT.FieldByName('CNTREG').AsInteger    :=nReg;
            cdsPost( cdsMovCNT );
         end;
      end
      else begin

         //SI LA CUENTA ORIGES ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
         if cdsQry_C.FieldByName('CNTDH').AsString='H' then
         begin
           sDeHa:='H';
           dDebeMN:=0;
           dDebeME:=0;
           dHabeMN:=cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
           dHabeME:=cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
         end
         else
         begin
           sDeHa:='D';
           dDebeMN:=cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
           dDebeME:=cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
           dHabeMN:=0;
           dHabeME:=0;
         end;

         cdsMovCNT.Insert;
         cdsMovCNT.FieldByName('CIAID').AsString      :=xCiaOri;
         cdsMovCNT.FieldByName('TDIARID').AsString    :=xOrigen2;
         cdsMovCNT.FieldByName('CNTCOMPROB').AsString :=xNoComp1;
         cdsMovCNT.FieldByName('CNTANOMM').AsString   :=xAnoMM;
         if (cdsQry_C.FieldByName('CUENTAID').AsString=xCtaRetHaber) then
         begin
            cdsMovCNT.FieldByName('CUENTAID').AsString   :=xCtaRetDebe;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString   :=xGlosaRetDebe;
         end;
         if (cdsQry_C.FieldByName('CUENTAID').AsString=xCtaCaja) then
         begin
            cdsMovCNT.FieldByName('CUENTAID').AsString   :=cdsQry_C.FieldByName('CUENTAID').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString   :=cdsQry_C.FieldByName('CNTGLOSA').AsString;
         end;

         cdsMovCNT.FieldByName('CNTLOTE').AsString    :=cdsQry_C.FieldByName('CNTLOTE').AsString;
         cdsMovCNT.FieldByName('CLAUXID').AsString    :=cdsQry_C.FieldByName('CLAUXID').AsString;
         cdsMovCNT.FieldByName('AUXID').AsString      :=cdsQry_C.FieldByName('AUXID').AsString;
         cdsMovCNT.FieldByName('CCOSID').AsString     :=cdsQry_C.FieldByName('CCOSID').AsString;
         cdsMovCNT.FieldByName('CNTMODDOC').AsString  :=cdsQry_C.FieldByName('CNTMODDOC').AsString;
         cdsMovCNT.FieldByName('DOCID').AsString      :=cdsQry_C.FieldByName('DOCID').AsString;
         cdsMovCNT.FieldByName('CNTSERIE').AsString   :=cdsQry_C.FieldByName('CNTSERIE').AsString;
         cdsMovCNT.FieldByName('CNTNODOC').AsString   :=cdsQry_C.FieldByName('CNTNODOC').AsString;

// aqui estaba la glosa

         cdsMovCNT.FieldByName('CNTDH').AsString      :=sDeHa;
         cdsMovCNT.FieldByName('CNTTCAMBIO').AsString :=cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
         cdsMovCNT.FieldByName('CNTMTOORI').AsString  :=cdsQry_C.FieldByName('CNTMTOORI').AsString;
         cdsMovCNT.FieldByName('CNTMTOLOC').AsString  :=cdsQry_C.FieldByName('CNTMTOLOC').AsString;
         cdsMovCNT.FieldByName('CNTMTOEXT').AsString  :=cdsQry_C.FieldByName('CNTMTOEXT').AsString;
         cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime :=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime:=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime :=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTESTADO').AsString  :='P';
         cdsMovCNT.FieldByName('CNTCUADRE').AsString  :='S';
         cdsMovCNT.FieldByName('CNTFAUTOM').AsString  :='S';
         cdsMovCNT.FieldByName('CNTUSER').AsString    :=cdsQry_C.FieldByName('CNTUSER').AsString;
         cdsMovCNT.FieldByName('CNTFREG').AsDateTime  :=cdsQry_C.FieldByName('CNTFREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTHREG').AsDateTime  :=cdsQry_C.FieldByName('CNTHREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTANO').AsString     :=cdsQry_C.FieldByName('CNTANO').AsString;
         cdsMovCNT.FieldByName('CNTMM').AsString      :=cdsQry_C.FieldByName('CNTMM').AsString;
         cdsMovCNT.FieldByName('CNTDD').AsString      :=cdsQry_C.FieldByName('CNTDD').AsString;
         cdsMovCNT.FieldByName('CNTTRI').AsString     :=cdsQry_C.FieldByName('CNTTRI').AsString;
         cdsMovCNT.FieldByName('CNTSEM').AsString     :=cdsQry_C.FieldByName('CNTSEM').AsString;
         cdsMovCNT.FieldByName('CNTSS').AsString      :=cdsQry_C.FieldByName('CNTSS').AsString;
         cdsMovCNT.FieldByName('CNTAATRI').AsString   :=cdsQry_C.FieldByName('CNTAATRI').AsString;
         cdsMovCNT.FieldByName('CNTAASEM').AsString   :=cdsQry_C.FieldByName('CNTAASEM').AsString;
         cdsMovCNT.FieldByName('CNTAASS').AsString    :=cdsQry_C.FieldByName('CNTAASS').AsString;
         cdsMovCNT.FieldByName('TMONID').AsString     :=cdsQry_C.FieldByName('TMONID').AsString;
         cdsMovCNT.FieldByName('TDIARDES').AsString   :=cdsQry_C.FieldByName('TDIARDES').AsString;
         cdsMovCNT.FieldByName('AUXDES').AsString     :=cdsQry_C.FieldByName('AUXDES').AsString;
         cdsMovCNT.FieldByName('DOCDES').AsString     :=cdsQry_C.FieldByName('DOCDES').AsString;
         cdsMovCNT.FieldByName('CCOSDES').AsString    :=cdsQry_C.FieldByName('CCOSDES').AsString;
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat   :=dDebeMN;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat   :=dDebeME;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat   :=dHabeMN;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat   :=dHabeME;
         cdsMovCNT.FieldByName('MODULO').AsString     :=cdsQry_C.FieldByName('MODULO').AsString;
         nReg:=nReg+1;
         cdsMovCNT.FieldByName('CNTREG').AsInteger    :=nReg;
         cdsPost( cdsMovCNT );
      end;
      cdsQry_C.Next;
   end;

   FSOLConta.AplicaDatos( cdsMovCNT, 'MOVCNT' );


   /////////////////////////////////
   //  CUENTAS SEGUNDO ASIENTO    //
   /////////////////////////////////

   if xNoComp2='' then begin

      // Caja Autonoma
      if (SRV_C = 'DB2NT') or (SRV_C = 'DB2400') then begin
         xWhere:='SELECT COALESCE( MAX( CNTCOMPROB ), ''0'' ) AS NUMERO FROM CNT300 '
                +'WHERE CIAID='  +''''+ xCia    +''''
                +' and TDIARID=' +''''+ xOrigen +''''
                +' and CNTANOMM='+''''+ xAnoMM  +'''';
      end;

      if SRV_C = 'ORACLE' then begin
         xWhere:='SELECT NVL( MAX( CNTCOMPROB ), ''0'' ) AS NUMERO FROM CNT300 '
                +'WHERE CIAID='  +''''+ xCia    +''''
                +' and TDIARID=' +''''+ xOrigen +''''
                +' and CNTANOMM='+''''+ xAnoMM  +'''';
      end;
      cdsQryT.Close;
      cdsQryT.DataRequest( xWhere );
      cdsQryT.Open;

      xNoComp2:=Inttostr( StrToInt( cdsQryT.FieldByname('NUMERO').AsString ) +1 );
      xNoComp2:=StrZero(xNoComp1,10);

   end;

   cdsMovCNT.Close;
   cdsMovCNT.DataRequest( 'Select * from CNT311 '
                         +'Where CIAID='''   +xCia  +''' AND TDIARID='''   +xOrigen +''' AND '
                         +      'CNTANOMM='''+xAnoMM+''' and CNTCOMPROB='''+xNoComp2+'''' );
   cdsMovCNT.Open;

   nReg:=1;

   cdsQry_C.First;
   while (not cdsQry_C.Eof) do begin

      if (xCtaCaja=cdsQry_C.FieldByName('CUENTAID').AsString) OR (xCtaRetHaber=cdsQry_C.FieldByName('CUENTAID').AsString) then begin

         if cdsQry_C.FieldByName('CNTDH').AsString='H' then
         begin
           sDeHa:='D';
           dHabeMN:=0;
           dHabeME:=0;
           dDebeMN:=cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
           dDebeME:=cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
         end
         else
         begin
           sDeHa:='H';
           dDebeMN:=0;
           dDebeME:=0;
           dHabeMN:=cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
           dHabeME:=cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
         end;

         cdsMovCNT.Insert;
         cdsMovCNT.FieldByName('CIAID').AsString      :=xCia;
         cdsMovCNT.FieldByName('TDIARID').AsString    :=xOrigen;
         cdsMovCNT.FieldByName('CNTCOMPROB').AsString :=xNoComp2;
         cdsMovCNT.FieldByName('CNTANOMM').AsString   :=xAnoMM;
         if (xCtaCaja=cdsQry_C.FieldByName('CUENTAID').AsString) then
            cdsMovCNT.FieldByName('CUENTAID').AsString   :=xCtaCaja;
         if (xCtaRetHaber=cdsQry_C.FieldByName('CUENTAID').AsString) then
            cdsMovCNT.FieldByName('CUENTAID').AsString   :=xCtaRetHaber;


         cdsMovCNT.FieldByName('CNTLOTE').AsString    :=cdsQry_C.FieldByName('CNTLOTE').AsString;
         cdsMovCNT.FieldByName('CLAUXID').AsString    :=cdsQry_C.FieldByName('CLAUXID').AsString;
         cdsMovCNT.FieldByName('AUXID').AsString      :=cdsQry_C.FieldByName('AUXID').AsString;
         cdsMovCNT.FieldByName('CCOSID').AsString     :=cdsQry_C.FieldByName('CCOSID').AsString;
         cdsMovCNT.FieldByName('CNTMODDOC').AsString  :=cdsQry_C.FieldByName('CNTMODDOC').AsString;
         cdsMovCNT.FieldByName('DOCID').AsString      :=cdsQry_C.FieldByName('DOCID').AsString;
         cdsMovCNT.FieldByName('CNTSERIE').AsString   :=cdsQry_C.FieldByName('CNTSERIE').AsString;
         cdsMovCNT.FieldByName('CNTNODOC').AsString   :=cdsQry_C.FieldByName('CNTNODOC').AsString;
         cdsMovCNT.FieldByName('CNTGLOSA').AsString   :=cdsQry_C.FieldByName('CNTGLOSA').AsString;
         cdsMovCNT.FieldByName('CNTDH').AsString      :=sDeHa;
         cdsMovCNT.FieldByName('CNTTCAMBIO').AsString :=cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
         cdsMovCNT.FieldByName('CNTMTOORI').AsString  :=cdsQry_C.FieldByName('CNTMTOORI').AsString;
         cdsMovCNT.FieldByName('CNTMTOLOC').AsString  :=cdsQry_C.FieldByName('CNTMTOLOC').AsString;
         cdsMovCNT.FieldByName('CNTMTOEXT').AsString  :=cdsQry_C.FieldByName('CNTMTOEXT').AsString;
         cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime :=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime:=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime :=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
         cdsMovCNT.FieldByName('CNTESTADO').AsString  :='P';
         cdsMovCNT.FieldByName('CNTCUADRE').AsString  :='S';
         cdsMovCNT.FieldByName('CNTFAUTOM').AsString  :='S';
         cdsMovCNT.FieldByName('CNTUSER').AsString    :=cdsQry_C.FieldByName('CNTUSER').AsString;
         cdsMovCNT.FieldByName('CNTFREG').AsDateTime  :=cdsQry_C.FieldByName('CNTFREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTHREG').AsDateTime  :=cdsQry_C.FieldByName('CNTHREG').AsDateTime;
         cdsMovCNT.FieldByName('CNTANO').AsString     :=cdsQry_C.FieldByName('CNTANO').AsString;
         cdsMovCNT.FieldByName('CNTMM').AsString      :=cdsQry_C.FieldByName('CNTMM').AsString;
         cdsMovCNT.FieldByName('CNTDD').AsString      :=cdsQry_C.FieldByName('CNTDD').AsString;
         cdsMovCNT.FieldByName('CNTTRI').AsString     :=cdsQry_C.FieldByName('CNTTRI').AsString;
         cdsMovCNT.FieldByName('CNTSEM').AsString     :=cdsQry_C.FieldByName('CNTSEM').AsString;
         cdsMovCNT.FieldByName('CNTSS').AsString      :=cdsQry_C.FieldByName('CNTSS').AsString;
         cdsMovCNT.FieldByName('CNTAATRI').AsString   :=cdsQry_C.FieldByName('CNTAATRI').AsString;
         cdsMovCNT.FieldByName('CNTAASEM').AsString   :=cdsQry_C.FieldByName('CNTAASEM').AsString;
         cdsMovCNT.FieldByName('CNTAASS').AsString    :=cdsQry_C.FieldByName('CNTAASS').AsString;
         cdsMovCNT.FieldByName('TMONID').AsString     :=cdsQry_C.FieldByName('TMONID').AsString;
         cdsMovCNT.FieldByName('TDIARDES').AsString   :=cdsQry_C.FieldByName('TDIARDES').AsString;
         cdsMovCNT.FieldByName('AUXDES').AsString     :=cdsQry_C.FieldByName('AUXDES').AsString;
         cdsMovCNT.FieldByName('DOCDES').AsString     :=cdsQry_C.FieldByName('DOCDES').AsString;
         cdsMovCNT.FieldByName('CCOSDES').AsString    :=cdsQry_C.FieldByName('CCOSDES').AsString;
         cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat   :=dDebeMN;
         cdsMovCNT.FieldByName('CNTDEBEME').AsFloat   :=dDebeME;
         cdsMovCNT.FieldByName('CNTHABEMN').AsFloat   :=dHabeMN;
         cdsMovCNT.FieldByName('CNTHABEME').AsFloat   :=dHabeME;
         cdsMovCNT.FieldByName('MODULO').AsString     :=cdsQry_C.FieldByName('MODULO').AsString;
         cdsMovCNT.FieldByName('CNTREG').AsInteger    :=1;
         cdsPost( cdsMovCNT );
      end
      else begin

         //SI LA CUENTA ORIGES ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
         if cdsQry_C.FieldByName('CNTDH').AsString='D' then
         begin
           sDeHa:='H';
           dDebeMN:=0;
           dDebeME:=0;
           dHabeMN:=cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
           dHabeME:=cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
         end
         else
         begin
           sDeHa:='D';
           dDebeMN:=cdsQry_C.FieldByName('CNTMTOLOC').AsFloat;
           dDebeME:=cdsQry_C.FieldByName('CNTMTOEXT').AsFloat;
           dHabeMN:=0;
           dHabeME:=0;
         end;

         if ( cdsQry_C.FieldByName('CNTMTOLOC').AsFloat=0 ) or
            ( cdsQry_C.FieldByName('CNTMTOEXT').AsFloat=0 ) then begin
            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString      :=xCia;
            cdsMovCNT.FieldByName('TDIARID').AsString    :=xOrigen;
            cdsMovCNT.FieldByName('CNTANOMM').AsString   :=xAnoMM;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString :=xNoComp2;

            //cdsMovCNT.FieldByName('CUENTAID').AsString   :=cdsQry_C.FieldByName('CUENTAID').AsString;

            cdsMovCNT.FieldByName('CUENTAID').AsString   :=xCtaHaber;
            if xAux_H='S' then begin
               cdsMovCNT.FieldByName('CLAUXID').AsString :=cdsQry_C.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString   :=cdsQry_C.FieldByName('AUXID').AsString;
            end;
            if xCCos_H='S' then begin
               cdsMovCNT.FieldByName('CCOSID').AsString  :=cdsQry_C.FieldByName('CCOSID').AsString;
            end;
            cdsMovCNT.FieldByName('CNTLOTE').AsString    :=cdsQry_C.FieldByName('CNTLOTE').AsString;
            cdsMovCNT.FieldByName('CNTMODDOC').AsString  :=cdsQry_C.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString      :=cdsQry_C.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString   :=cdsQry_C.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString   :=cdsQry_C.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString   :=cdsQry_C.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString      :=sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString :=cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString  :=cdsQry_C.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString  :=cdsQry_C.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString  :=cdsQry_C.FieldByName('CNTMTOEXT').AsString;
            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime :=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime:=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime :=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString  :='P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString  :='S';
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString  :='S';
            cdsMovCNT.FieldByName('CNTUSER').AsString    :=cdsQry_C.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime  :=cdsQry_C.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime  :=cdsQry_C.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString     :=cdsQry_C.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString      :=cdsQry_C.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString      :=cdsQry_C.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString     :=cdsQry_C.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString     :=cdsQry_C.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString      :=cdsQry_C.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString   :=cdsQry_C.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString   :=cdsQry_C.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString    :=cdsQry_C.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString     :=cdsQry_C.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString   :=cdsQry_C.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString     :=cdsQry_C.FieldByName('AUXDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString     :=cdsQry_C.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString    :=cdsQry_C.FieldByName('CCOSDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat   :=dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat   :=dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat   :=dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat   :=dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString     :=cdsQry_C.FieldByName('MODULO').AsString;
            nReg:=nReg+1;
            cdsMovCNT.FieldByName('CNTREG').AsInteger    :=nReg;
            cdsPost( cdsMovCNT );

         end
         else begin
            cdsMovCNT.Insert;
            cdsMovCNT.FieldByName('CIAID').AsString      :=xCia;
            cdsMovCNT.FieldByName('TDIARID').AsString    :=xOrigen;
            cdsMovCNT.FieldByName('CNTANOMM').AsString   :=xAnoMM;
            cdsMovCNT.FieldByName('CNTCOMPROB').AsString :=xNoComp2;
            cdsMovCNT.FieldByName('CUENTAID').AsString   :=xCtaHaber;
            cdsMovCNT.FieldByName('CNTLOTE').AsString    :=cdsQry_C.FieldByName('CNTLOTE').AsString;
            if xAux_H='S' then begin
               cdsMovCNT.FieldByName('CLAUXID').AsString :=cdsQry_C.FieldByName('CLAUXID').AsString;
               cdsMovCNT.FieldByName('AUXID').AsString   :=cdsQry_C.FieldByName('AUXID').AsString;
            end;
            if xCCos_H='S' then begin
               cdsMovCNT.FieldByName('CCOSID').AsString  :=cdsQry_C.FieldByName('CCOSID').AsString;
            end;
            cdsMovCNT.FieldByName('CNTMODDOC').AsString  :=cdsQry_C.FieldByName('CNTMODDOC').AsString;
            cdsMovCNT.FieldByName('DOCID').AsString      :=cdsQry_C.FieldByName('DOCID').AsString;
            cdsMovCNT.FieldByName('CNTSERIE').AsString   :=cdsQry_C.FieldByName('CNTSERIE').AsString;
            cdsMovCNT.FieldByName('CNTNODOC').AsString   :=cdsQry_C.FieldByName('CNTNODOC').AsString;
            cdsMovCNT.FieldByName('CNTGLOSA').AsString   :=cdsQry_C.FieldByName('CNTGLOSA').AsString;
            cdsMovCNT.FieldByName('CNTDH').AsString      :=sDeHa;
            cdsMovCNT.FieldByName('CNTTCAMBIO').AsString :=cdsQry_C.FieldByName('CNTTCAMBIO').AsString;
            cdsMovCNT.FieldByName('CNTMTOORI').AsString  :=cdsQry_C.FieldByName('CNTMTOORI').AsString;
            cdsMovCNT.FieldByName('CNTMTOLOC').AsString  :=cdsQry_C.FieldByName('CNTMTOLOC').AsString;
            cdsMovCNT.FieldByName('CNTMTOEXT').AsString  :=cdsQry_C.FieldByName('CNTMTOEXT').AsString;
            cdsMovCNT.FieldByName('CNTFEMIS').AsDateTime :=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFVCMTO').AsDateTime:=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTFCOMP').AsDateTime :=cdsQry_C.FieldByName('CNTFCOMP').AsDateTime;
            cdsMovCNT.FieldByName('CNTESTADO').AsString  :='P';
            cdsMovCNT.FieldByName('CNTCUADRE').AsString  :='S';
            cdsMovCNT.FieldByName('CNTFAUTOM').AsString  :='S';
            cdsMovCNT.FieldByName('CNTUSER').AsString    :=cdsQry_C.FieldByName('CNTUSER').AsString;
            cdsMovCNT.FieldByName('CNTFREG').AsDateTime  :=cdsQry_C.FieldByName('CNTFREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTHREG').AsDateTime  :=cdsQry_C.FieldByName('CNTHREG').AsDateTime;
            cdsMovCNT.FieldByName('CNTANO').AsString     :=cdsQry_C.FieldByName('CNTANO').AsString;
            cdsMovCNT.FieldByName('CNTMM').AsString      :=cdsQry_C.FieldByName('CNTMM').AsString;
            cdsMovCNT.FieldByName('CNTDD').AsString      :=cdsQry_C.FieldByName('CNTDD').AsString;
            cdsMovCNT.FieldByName('CNTTRI').AsString     :=cdsQry_C.FieldByName('CNTTRI').AsString;
            cdsMovCNT.FieldByName('CNTSEM').AsString     :=cdsQry_C.FieldByName('CNTSEM').AsString;
            cdsMovCNT.FieldByName('CNTSS').AsString      :=cdsQry_C.FieldByName('CNTSS').AsString;
            cdsMovCNT.FieldByName('CNTAATRI').AsString   :=cdsQry_C.FieldByName('CNTAATRI').AsString;
            cdsMovCNT.FieldByName('CNTAASEM').AsString   :=cdsQry_C.FieldByName('CNTAASEM').AsString;
            cdsMovCNT.FieldByName('CNTAASS').AsString    :=cdsQry_C.FieldByName('CNTAASS').AsString;
            cdsMovCNT.FieldByName('TMONID').AsString     :=cdsQry_C.FieldByName('TMONID').AsString;
            cdsMovCNT.FieldByName('TDIARDES').AsString   :=cdsQry_C.FieldByName('TDIARDES').AsString;
            cdsMovCNT.FieldByName('AUXDES').AsString     :=cdsQry_C.FieldByName('AUXDES').AsString;
            cdsMovCNT.FieldByName('DOCDES').AsString     :=cdsQry_C.FieldByName('DOCDES').AsString;
            cdsMovCNT.FieldByName('CCOSDES').AsString    :=cdsQry_C.FieldByName('CCOSDES').AsString;
            cdsMovCNT.FieldByName('CNTDEBEMN').AsFloat   :=dDebeMN;
            cdsMovCNT.FieldByName('CNTDEBEME').AsFloat   :=dDebeME;
            cdsMovCNT.FieldByName('CNTHABEMN').AsFloat   :=dHabeMN;
            cdsMovCNT.FieldByName('CNTHABEME').AsFloat   :=dHabeME;
            cdsMovCNT.FieldByName('MODULO').AsString     :=cdsQry_C.FieldByName('MODULO').AsString;
            nReg:=nReg+1;
            cdsMovCNT.FieldByName('CNTREG').AsInteger    :=nReg;
            cdsPost( cdsMovCNT );
         end;
      end;

      cdsQry_C.Next;

   end;

   FSOLConta.AplicaDatos( cdsMovCNT, 'MOVCNT' );

// NUEVA MAYORIZACION

   if xTCP='CCNA' then begin

      AsientosComplementarios( xCiaOri, xOrigen2, xAnoMM, xNoComp1 );

      AsientosComplementarios( xCia,    xOrigen,  xAnoMM, xNoComp2 );

   end;

   xSQLAdicional:='or ( A.CIAID='     +quotedstr( xCiaOri  ) +' AND '
           +           'A.CNTANOMM='  +quotedstr( xAnoMM   ) +' AND '
           +           'A.TDIARID='   +quotedstr( xOrigen2 ) +' AND '
           +           'A.CNTCOMPROB='+quotedstr( xNoComp1 ) +' ) '
           +      'or ( A.CIAID='     +quotedstr( xCia     ) +' AND '
           +           'A.CNTANOMM='  +quotedstr( xAnoMM   ) +' AND '
           +           'A.TDIARID='   +quotedstr( xOrigen  ) +' AND '
           +           'A.CNTCOMPROB='+quotedstr( xNoComp2 ) +' ) ';

   xSQLAdicional2:='or ( A.CIAID='     +quotedstr( xCiaOri  ) +' AND '
            +           'A.CNTANOMM='  +quotedstr( xAnoMM   ) +' AND '
            +           'A.TDIARID='   +quotedstr( xOrigen2 ) +' AND '
            +           'A.CNTCOMPROB='+quotedstr( xNoComp1 ) +' AND '
            +           'A.CIAID=B.CIAID ) '
            +      'or ( A.CIAID='     +quotedstr( xCia     ) +' AND '
            +           'A.CNTANOMM='  +quotedstr( xAnoMM   ) +' AND '
            +           'A.TDIARID='   +quotedstr( xOrigen  ) +' AND '
            +           'A.CNTCOMPROB='+quotedstr( xNoComp2 ) +' AND '
            +           'A.CIAID=B.CIAID ) ';

   xRegAdicional :='1. '+xCiaOri+'/'+xOrigen2+'/'+xNoComp1+']['
            +      '2. '+xCia   +'/'+xOrigen +'/'+xNoComp2;

end;

procedure TFSOLConta.cdsPost(xxCds:TwwClientDataSet);
Var
  i:integer;
Begin
  For i:=0 to xxCds.Fields.Count-1 Do
    Begin
      If xxCds.Fields[i].ClassType=TStringField Then
        Begin
          If (xxCds.Fields[i].AsString='') Then
            xxCds.Fields[i].CLEAR;
        End;

      If xxCds.Fields[i].ClassType=TMemoField Then
        Begin
          If (xxCds.Fields[i].AsString='') or (xxCds.Fields[i].AsString=' ') Then xxCds.Fields[i].AsString:='.';
        End;

    End;
End;


procedure TFSOLConta.AsientosComplementarios( xCia, xDiario, xAnoMM, xNoComp : String );
var
   xSQL : String;
begin

   xSQL:='Insert into CNT301 ('
        +' CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
        +  'CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
        +  'CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
        +  'CNTFEMIS, CNTFVCMTO, CNTFCOMP, CNTESTADO, CNTCUADRE, CNTFAUTOM, '
        +  'CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
        +  'CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
        +  'TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
        +  'CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
        +  'CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
        +  'CNTMODDOC, CNTREG, MODULO, CTA_SECU ) '
        +'Select CIAID, TDIARID, CNTCOMPROB, CNTANO, CNTANOMM, CNTLOTE, '
        +  'CUENTAID, CLAUXID, AUXID, DOCID, CNTSERIE, CNTNODOC, CNTGLOSA, '
        +  'CNTDH, CCOSID, CNTTCAMBIO, CNTMTOORI, CNTMTOLOC, CNTMTOEXT, '
        +  'CNTFEMIS, CNTFVCMTO, CNTFCOMP, ''P'', ''S'', CNTFAUTOM, '
        +  'CNTUSER, CNTFREG, CNTHREG, CNTMM, CNTDD, CNTTRI, CNTSEM, CNTSS, '
        +  'CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, FCONS, CNTFMEC, '
        +  'TDIARDES, CTADES, AUXDES, DOCDES, CCOSDES, '
        +  'CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, '
        +  'CNTSALDMN, CNTSALDME, CAMPOVAR, CNTTS, CNTPAGADO, '
        +  'CNTMODDOC, CNTREG, MODULO, CTA_SECU '
        +'From CNT311 Where '
        +  'CIAID='     +''''+ xCia     +''''+' AND '
        +  'TDIARID='   +''''+ xDiario  +''''+' AND '
        +  'CNTANOMM='  +''''+ xAnoMM   +''''+' AND '
        +  'CNTCOMPROB='+''''+ xNoComp  +'''' ;
   try
      cdsQry_C.Close;
      cdsQry_C.DataRequest( xSQL );
      cdsQry_C.Execute;
   except
      Errorcount2:=1;
      Exit;
   end;

   // Genera Cabecera si Modulo no es Contabilidad

   xSQL:='SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB ';
   xSQL:=xSQL+ 'FROM '+CNTCab+' A ';
   xSQL:=xSQL+ 'WHERE A.CIAID='     +''''+xCia    +''''+' and ';
   xSQL:=xSQL+       'A.TDIARID='   +''''+xDiario +''''+' and ';
   xSQL:=xSQL+       'A.CNTANOMM='  +''''+xAnoMM  +''''+' and ';
   xSQL:=xSQL+       'A.CNTCOMPROB='+''''+xNoComp +''''+' ';

   cdsQry_C.Close;
   cdsQry_C.DataRequest( xSQL );
   cdsQry_C.Open;

   if cdsQry_C.RecordCount<=0 then begin
      if (SRV_C = 'DB2NT') or (SRV_C = 'DB2400') then
      begin
         xSQL:='INSERT INTO '+CNTCab;
         xSQL:=xSQL+ '( CIAID, TDIARID, CNTANOMM, CNTCOMPROB, CNTLOTE, ';
         xSQL:=xSQL+ 'CNTGLOSA, CNTTCAMBIO, CNTFCOMP, CNTESTADO, CNTCUADRE, ';
         xSQL:=xSQL+ 'CNTUSER, CNTFREG, CNTHREG, CNTANO, CNTMM, CNTDD, CNTTRI, ';
         xSQL:=xSQL+ 'CNTSEM, CNTSS, CNTAATRI, CNTAASEM, CNTAASS, TMONID, FLAGVAR, ';
         xSQL:=xSQL+ 'TDIARDES, CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, ';
         xSQL:=xSQL+ 'CNTTS, DOCMOD, MODULO ) ' ;

         xSQL:=xSQL+ 'SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB,  A.CNTLOTE, ';
         xSQL:=xSQL+ 'CASE WHEN MIN(A.CNTREG) = 1 THEN MAX( A.CNTGLOSA ) ELSE  ''COMPROBANTE DE ''||MAX(MODULO) END, ';
         xSQL:=xSQL+ 'MAX( COALESCE(A.CNTTCAMBIO, 0 )), ';
         xSQL:=xSQL+ 'A.CNTFCOMP, ''P'', ''S'', ';
         xSQL:=xSQL+ 'MAX(CNTUSER), MAX( CNTFREG ), MAX( CNTHREG ), A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI, ';
         xSQL:=xSQL+ 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, A.TMONID, '' '', ';
         xSQL:=xSQL+ 'A.TDIARDES, ';
         xSQL:=xSQL+ 'SUM(A.CNTDEBEMN), SUM(A.CNTDEBEME), SUM(A.CNTHABEMN), SUM(A.CNTHABEME), ';
         xSQL:=xSQL+ 'MAX( CNTTS ), MAX( CNTMODDOC), MAX( MODULO ) ';
         xSQL:=xSQL+ 'FROM '+CNTDet+' A ';
         xSQL:=xSQL+ 'WHERE A.CIAID='     +''''+xCia    +''''+' AND ';
         xSQL:=xSQL+       'A.TDIARID='   +''''+xDiario +''''+' AND ';
         xSQL:=xSQL+       'A.CNTANOMM='  +''''+xAnoMM  +''' ';
         xSQL:=xSQL+ 'AND A.CNTCOMPROB='+''''+xNoComp +''''+' ';
         xSQL:=xSQL+ 'GROUP BY A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB, A.CNTLOTE, ';
         xSQL:=xSQL+ 'A.CNTFCOMP, A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI,  ';
         xSQL:=xSQL+ 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, A.TMONID, ';
         xSQL:=xSQL+ 'A.TDIARDES, A.CNTMODDOC';
      end;

      if SRV_C = 'ORACLE' then
      begin
         xSQL:='INSERT INTO '+CNTCab;
         xSQL:=xSQL+ '( CIAID, TDIARID, CNTANOMM, CNTCOMPROB, CNTLOTE, ';
         xSQL:=xSQL+ 'CNTGLOSA, CNTTCAMBIO, CNTFCOMP, CNTESTADO, CNTCUADRE, ';
         xSQL:=xSQL+ 'CNTUSER, CNTFREG, CNTHREG, CNTANO, CNTMM, CNTDD, CNTTRI, ';
         xSQL:=xSQL+ 'CNTSEM, CNTSS, CNTAATRI, CNTAASEM, CNTAASS, TMONID, ';
         xSQL:=xSQL+ 'FLAGVAR, TDIARDES, CNTDEBEMN, CNTDEBEME, CNTHABEMN, CNTHABEME, ';
         xSQL:=xSQL+ 'CNTTS, DOCMOD, MODULO ) ' ;
         xSQL:=xSQL+ 'SELECT A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB,  A.CNTLOTE, ';
         xSQL:=xSQL+ 'DECODE( MIN(A.CNTREG), 1, MAX( A.CNTGLOSA ), ''COMPROBANTE DE ''||MAX(MODULO) ), ';
         xSQL:=xSQL+ 'MAX( NVL( A.CNTTCAMBIO, 0 ) ), ';
         xSQL:=xSQL+ 'A.CNTFCOMP, ''P'', ''S'', ';
         xSQL:=xSQL+ 'MAX( CNTUSER ), MAX( CNTFREG ), MAX( CNTHREG ), A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI, ';
         xSQL:=xSQL+ 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
         xSQL:=xSQL+ 'CASE WHEN SUM( CASE WHEN TMONID='''+wTMonExt_C+''' THEN 1 ELSE 0 END )>'
                   +          ' SUM( CASE WHEN TMONID='''+wTMonLoc_C+''' THEN 1 ELSE 0 END ) '
                   +     ' THEN '''+wTMonExt_C+''' ELSE '''+wTMonLoc_C+''' END, ';
         xSQL:=xSQL+ ''' '', A.TDIARDES, ';
         xSQL:=xSQL+ 'SUM(A.CNTDEBEMN), SUM(A.CNTDEBEME), SUM(A.CNTHABEMN), SUM(A.CNTHABEME), ';
         xSQL:=xSQL+ 'MAX( CNTTS ), MAX( CNTMODDOC), MAX( MODULO ) ';
         xSQL:=xSQL+ 'FROM '+CNTDet+' A ';
         xSQL:=xSQL+ 'WHERE A.CIAID='     +''''+xCia    +''''+' AND ';
         xSQL:=xSQL+       'A.TDIARID='   +''''+xDiario+''''+' AND ';
         xSQL:=xSQL+       'A.CNTANOMM='  +''''+xAnoMM  +''' ';
         xSQL:=xSQL+   'AND A.CNTCOMPROB='+''''+xNoComp +''''+' ';
         xSQL:=xSQL+ 'GROUP BY A.CIAID, A.TDIARID, A.CNTANOMM, A.CNTCOMPROB, A.CNTLOTE, ';
         xSQL:=xSQL+ 'A.CNTFCOMP, A.CNTANO, A.CNTMM, A.CNTDD, A.CNTTRI,  ';
         xSQL:=xSQL+ 'A.CNTSEM, A.CNTSS, A.CNTAATRI, A.CNTAASEM, A.CNTAASS, ';
         xSQL:=xSQL+ 'A.TDIARDES';
      end;

      try
         cdsQry_C.Close;
         cdsQry_C.DataRequest( xSQL );
         cdsQry_C.Execute;
      except

         Errorcount2:=1;
         Exit;
      end;
   end;

   FSOLConta.GeneraEnLinea401( xCia, xDiario, xAnoMM, xNoComp, 'S' );

end;


function SOLPresupuesto( xCia, xUsuario, xNumero, xSRV, xModulo : String;
                         cdsResultSetx     : TwwClientDataSet;
                         DCOMx             : TDCOMConnection;
                         xForm_C : TForm; xTipoMay : String ) : Boolean;
var
   sSQL, xNREG, xSQL, xCajaAut, xSQL1 : String;
   xNumT, iOrdenx       : Integer;
   sCIA,sCuenta,sDeHa   : string;
   dDebeMN,dHabeMN,dDebeME,dHabeME:double;
   cdsClone   : TwwClientDataSet;
   cdsAsiento : TwwClientDataSet;
begin
   CNTDet:='PPRES311';

   FSOLConta.CreaPanel( xForm_C, 'Generando Presupuestos' );

   DCOM_C     := DCOMx;
   SRV_C      := xSRV;

   wTMay      := xTipoMay;
   wOrigenPRE := xModulo;

   if (SRV_C='DB2NT') or (SRV_C='DB2400') then
   begin
      wReplaCeros:='COALESCE';
   end
   else
   if SRV_C='ORACLE' then
   begin
      wReplaCeros:='NVL';
   end;

   Provider_C := 'dspTem6';

   cdsResultSet_C:= cdsResultSetx;

   cdsPresup_C:=TwwClientDataSet.Create(nil);
   cdsPresup_C.RemoteServer:= DCOMx;
   cdsPresup_C.ProviderName:='dspTem5';

   cdsQry_C:=TwwClientDataSet.Create(nil);
   cdsQry_C.RemoteServer:= DCOMx;
   cdsQry_C.ProviderName:=Provider_C;


   xSQL:='Select A.CIAID, A.USUARIO, A.ANO, A.MES, A.NUMERO, A.TIPPRESID, A.PARPRESID, '
        +  'A.TIPOCOL, A.RQPARTIS, A.TMONID, A.MONTOMN, A.MONTOME, A.CCOSID, FMAYOR, '
        +  'MONTOMN01, MONTOME01, MONTOMN02, MONTOME02, MONTOMN03, MONTOME03, '
        +  'MONTOMN04, MONTOME04, MONTOMN05, MONTOME05, MONTOMN06, MONTOME06, '
        +  'MONTOMN07, MONTOME07, MONTOMN08, MONTOME08, MONTOMN09, MONTOME09, '
        +  'MONTOMN10, MONTOME10, MONTOMN11, MONTOME11, MONTOMN12, MONTOME12  '
        +'FROM PPRES311 A '
        +'WHERE A.CIAID  ='+QuotedStr( xCia     )
        + ' AND A.USUARIO='+QuotedStr( xUsuario )
        + ' AND A.NUMERO ='+QuotedStr( xNumero  );
   cdsPresup_C.Close;
   cdsPresup_C.DataRequest( xSQL );
   cdsPresup_C.Open;

   // Se Añade Para Mayorizar Solamente
   {
   if (xTipoC='M') then begin
      FSOLConta.GeneraEnLinea401( xCia, xTDiario, xAnoMM, xNoComp, 'S' );
      pnlConta_C.Free;
      cdsNivel_C := NIL;
      cdsNivelx  := NIL;

      if Errorcount2>0 then Exit;

      Result:=True ;
      Exit;
   end;

   }
   FSOLConta.PanelMsg( 'Generando Presupuestos Automaticos', 0 );

   // GENERA ASIENTOS AUTOMATICOS PARA LA CUENTA 1

   cdsClone:=TwwClientDataSet.Create(nil);
   cdsClone.RemoteServer:= DCOMx;
   cdsClone.ProviderName:=Provider_C;
   cdsClone.Close;

   sSQL:='Select A.CIAID, A.USUARIO, A.ANO, A.MES, A.NUMERO, A.TIPPRESID, A.PARPRESID, '
        +  'A.TIPOCOL, A.RQPARTIS, A.TMONID, A.MONTOMN, A.MONTOME, B.PARPRESDES, '
        +  'B.PARPRESAUT1, B.PARPRESAUT2, B.ASIENTOID, A.CCOSID, '
        +  'MONTOMN01, MONTOME01, MONTOMN02, MONTOME02, MONTOMN03, MONTOME03, '
        +  'MONTOMN04, MONTOME04, MONTOMN05, MONTOME05, MONTOMN06, MONTOME06, '
        +  'MONTOMN07, MONTOME07, MONTOMN08, MONTOME08, MONTOMN09, MONTOME09, '
        +  'MONTOMN10, MONTOME10, MONTOMN11, MONTOME11, MONTOMN12, MONTOME12  '
        +'FROM PPRES311 A, PPRES201 B '
        +'WHERE A.CIAID  ='+QuotedStr( xCia     )
        + ' AND A.USUARIO='+QuotedStr( xUsuario )
        + ' AND A.NUMERO ='+QuotedStr( xNumero  )
        + ' AND A.CIAID=B.CIAID AND A.TIPPRESID=B.TIPPRESID '
        + ' AND A.PARPRESID=B.PARPRESID AND A.PROCE=B.PROCE ';

   cdsClone.DataRequest(sSQL);
   cdsClone.Open;

   FSOLConta.PanelMsg( 'Generando Presupuestos Automaticos', 0 );

   cdsClone.First;
   while not cdsClone.EOF DO
   begin
     sCia   :=cdsClone.FieldByName('CIAID').AsString;
     sCuenta:=cdsClone.FieldByName('PARPRESID').AsString;

     //SI TIENE CUENTA AUTOMATICA 1 y 2
     if (cdsClone.FieldByName('PARPRESAUT1').AsString<>'') and
        (cdsClone.FieldByName('PARPRESAUT2').AsString<>'') then
     begin
       //SI LA CUENTA ORIGES ESTA DESTINADA AL DEBE LA CUENTA AUTOMATICA 1 IRA AL HABER
       if cdsClone.FieldByName('RQPARTIS').AsString='I' then
         sDeHa:='I'
       else begin
         sDeHa:='S';
       end;
       cdsPresup_C.Insert;
       cdsPresup_C.FieldByName('CIAID').AsString     :=cdsClone.FieldByName('CIAID').AsString;
       cdsPresup_C.FieldByName('USUARIO').AsString   :=cdsClone.FieldByName('USUARIO').AsString;
       cdsPresup_C.FieldByName('NUMERO').AsString    :=cdsClone.FieldByName('NUMERO').AsString;
       cdsPresup_C.FieldByName('ANO').AsString       :=cdsClone.FieldByName('ANO').AsString;
       cdsPresup_C.FieldByName('MES').AsString       :=cdsClone.FieldByName('MES').AsString;
       cdsPresup_C.FieldByName('TIPPRESID').AsString :=cdsClone.FieldByName('TIPPRESID').AsString;
       cdsPresup_C.FieldByName('PARPRESID').AsString :=cdsClone.FieldByName('PARPRESAUT1').AsString;
       cdsPresup_C.FieldByName('CCOSID').AsString    :=cdsClone.FieldByName('CCOSID').AsString;
       cdsPresup_C.FieldByName('RQPARTIS').AsString  :=sDeHa;
       cdsPresup_C.FieldByName('TMONID').AsString    :=cdsClone.FieldByName('TMONID').AsString;
       cdsPresup_C.FieldByName('MONTOMN').AsFloat    :=cdsClone.FieldByName('MONTOMN').AsFloat;
       cdsPresup_C.FieldByName('MONTOME').AsFloat    :=cdsClone.FieldByName('MONTOME').AsFloat;
       cdsPresup_C.FieldByName('TIPOCOL').AsString   :=cdsClone.FieldByName('TIPOCOL').AsString;
       cdsPresup_C.FieldByName('FMAYOR').AsString    :='N';

       // Para Mayorizar Anual
       cdsPresup_C.FieldByName('MONTOMN01').AsFloat  :=cdsClone.FieldByName('MONTOMN01').AsFloat;
       cdsPresup_C.FieldByName('MONTOME01').AsFloat  :=cdsClone.FieldByName('MONTOME01').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN02').AsFloat  :=cdsClone.FieldByName('MONTOMN02').AsFloat;
       cdsPresup_C.FieldByName('MONTOME02').AsFloat  :=cdsClone.FieldByName('MONTOME02').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN03').AsFloat  :=cdsClone.FieldByName('MONTOMN03').AsFloat;
       cdsPresup_C.FieldByName('MONTOME03').AsFloat  :=cdsClone.FieldByName('MONTOME03').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN04').AsFloat  :=cdsClone.FieldByName('MONTOMN04').AsFloat;
       cdsPresup_C.FieldByName('MONTOME04').AsFloat  :=cdsClone.FieldByName('MONTOME04').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN05').AsFloat  :=cdsClone.FieldByName('MONTOMN05').AsFloat;
       cdsPresup_C.FieldByName('MONTOME05').AsFloat  :=cdsClone.FieldByName('MONTOME05').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN06').AsFloat  :=cdsClone.FieldByName('MONTOMN06').AsFloat;
       cdsPresup_C.FieldByName('MONTOME06').AsFloat  :=cdsClone.FieldByName('MONTOME06').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN07').AsFloat  :=cdsClone.FieldByName('MONTOMN07').AsFloat;
       cdsPresup_C.FieldByName('MONTOME07').AsFloat  :=cdsClone.FieldByName('MONTOME07').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN08').AsFloat  :=cdsClone.FieldByName('MONTOMN08').AsFloat;
       cdsPresup_C.FieldByName('MONTOME08').AsFloat  :=cdsClone.FieldByName('MONTOME08').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN09').AsFloat  :=cdsClone.FieldByName('MONTOMN09').AsFloat;
       cdsPresup_C.FieldByName('MONTOME09').AsFloat  :=cdsClone.FieldByName('MONTOME09').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN10').AsFloat  :=cdsClone.FieldByName('MONTOMN10').AsFloat;
       cdsPresup_C.FieldByName('MONTOME10').AsFloat  :=cdsClone.FieldByName('MONTOME10').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN11').AsFloat  :=cdsClone.FieldByName('MONTOMN11').AsFloat;
       cdsPresup_C.FieldByName('MONTOME11').AsFloat  :=cdsClone.FieldByName('MONTOME11').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN12').AsFloat  :=cdsClone.FieldByName('MONTOMN12').AsFloat;
       cdsPresup_C.FieldByName('MONTOME12').AsFloat  :=cdsClone.FieldByName('MONTOME12').AsFloat;
       //

       //cdsMovCNT.FieldByName('MODULO').AsString  :=cdsClone.FieldByName('MODULO').AsString;
       //cdsMovCNT.FieldByName('CNTREG').AsInteger :=iOrden;
       iOrden:=iOrden+1;

       //SI LA CUENTA ORIGES ESTA DESTINADA AL HABER LA CUENTA AUTOMATICA 2 IRA AL DEBE
       if cdsClone.FieldByName('RQPARTIS').AsString='I' then
         sDeHa:='S'
       else begin
         sDeHa:='I';
       end;

       cdsPresup_C.Insert;
       cdsPresup_C.FieldByName('CIAID').AsString     :=cdsClone.FieldByName('CIAID').AsString;
       cdsPresup_C.FieldByName('USUARIO').AsString   :=cdsClone.FieldByName('USUARIO').AsString;
       cdsPresup_C.FieldByName('NUMERO').AsString    :=cdsClone.FieldByName('NUMERO').AsString;
       cdsPresup_C.FieldByName('ANO').AsString       :=cdsClone.FieldByName('ANO').AsString;
       cdsPresup_C.FieldByName('MES').AsString       :=cdsClone.FieldByName('MES').AsString;
       cdsPresup_C.FieldByName('TIPPRESID').AsString :=cdsClone.FieldByName('TIPPRESID').AsString;
       cdsPresup_C.FieldByName('PARPRESID').AsString :=cdsClone.FieldByName('PARPRESAUT2').AsString;
       cdsPresup_C.FieldByName('CCOSID').AsString    :=cdsClone.FieldByName('CCOSID').AsString;
       cdsPresup_C.FieldByName('RQPARTIS').AsString  :=sDeHa;
       cdsPresup_C.FieldByName('TMONID').AsString    :=cdsClone.FieldByName('TMONID').AsString;
       cdsPresup_C.FieldByName('MONTOMN').AsFloat    :=cdsClone.FieldByName('MONTOMN').AsFloat;
       cdsPresup_C.FieldByName('MONTOME').AsFloat    :=cdsClone.FieldByName('MONTOME').AsFloat;
       cdsPresup_C.FieldByName('TIPOCOL').AsString   :=cdsClone.FieldByName('TIPOCOL').AsString;
       cdsPresup_C.FieldByName('FMAYOR').AsString    :='N';

       // Para Mayorizar Anual
       cdsPresup_C.FieldByName('MONTOMN01').AsFloat  :=cdsClone.FieldByName('MONTOMN01').AsFloat;
       cdsPresup_C.FieldByName('MONTOME01').AsFloat  :=cdsClone.FieldByName('MONTOME01').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN02').AsFloat  :=cdsClone.FieldByName('MONTOMN02').AsFloat;
       cdsPresup_C.FieldByName('MONTOME02').AsFloat  :=cdsClone.FieldByName('MONTOME02').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN03').AsFloat  :=cdsClone.FieldByName('MONTOMN03').AsFloat;
       cdsPresup_C.FieldByName('MONTOME03').AsFloat  :=cdsClone.FieldByName('MONTOME03').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN04').AsFloat  :=cdsClone.FieldByName('MONTOMN04').AsFloat;
       cdsPresup_C.FieldByName('MONTOME04').AsFloat  :=cdsClone.FieldByName('MONTOME04').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN05').AsFloat  :=cdsClone.FieldByName('MONTOMN05').AsFloat;
       cdsPresup_C.FieldByName('MONTOME05').AsFloat  :=cdsClone.FieldByName('MONTOME05').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN06').AsFloat  :=cdsClone.FieldByName('MONTOMN06').AsFloat;
       cdsPresup_C.FieldByName('MONTOME06').AsFloat  :=cdsClone.FieldByName('MONTOME06').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN07').AsFloat  :=cdsClone.FieldByName('MONTOMN07').AsFloat;
       cdsPresup_C.FieldByName('MONTOME07').AsFloat  :=cdsClone.FieldByName('MONTOME07').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN08').AsFloat  :=cdsClone.FieldByName('MONTOMN08').AsFloat;
       cdsPresup_C.FieldByName('MONTOME08').AsFloat  :=cdsClone.FieldByName('MONTOME08').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN09').AsFloat  :=cdsClone.FieldByName('MONTOMN09').AsFloat;
       cdsPresup_C.FieldByName('MONTOME09').AsFloat  :=cdsClone.FieldByName('MONTOME09').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN10').AsFloat  :=cdsClone.FieldByName('MONTOMN10').AsFloat;
       cdsPresup_C.FieldByName('MONTOME10').AsFloat  :=cdsClone.FieldByName('MONTOME10').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN11').AsFloat  :=cdsClone.FieldByName('MONTOMN11').AsFloat;
       cdsPresup_C.FieldByName('MONTOME11').AsFloat  :=cdsClone.FieldByName('MONTOME11').AsFloat;
       cdsPresup_C.FieldByName('MONTOMN12').AsFloat  :=cdsClone.FieldByName('MONTOMN12').AsFloat;
       cdsPresup_C.FieldByName('MONTOME12').AsFloat  :=cdsClone.FieldByName('MONTOME12').AsFloat;
       //
       iOrden:=iOrden+1;

       FSOLConta.AplicaDatos( cdsPresup_C, 'MOVCNT' );
     end;

     cdsClone.Next;
   end;

   cdsAsiento:=TwwClientDataSet.Create(nil);
   cdsAsiento.RemoteServer:=DCOMx;
   cdsAsiento.ProviderName:='dspTem4';

   //////////////////////////////////////////
   //  Añadir Cuentas de  Tipo de Asiento  //
   //////////////////////////////////////////
   cdsClone.First;
   while not cdsClone.EOF DO
   begin

      if cdsClone.FieldByName('ASIENTOID').AsString<>'' then
      begin
         xSQL1:='Select * from PPRES202 '
               +'Where CIAID='''    +cdsClone.FieldByName('CIAID').AsString    +''''
               + ' AND ASIENTOID='''+cdsClone.FieldByName('ASIENTOID').AsString+'''';
         cdsAsiento.Close;
         cdsAsiento.DataRequest( xSQL1 );
         cdsAsiento.Open;

         if cdsAsiento.RecordCount>0 then begin

            while not cdsAsiento.eof do begin
               sCia   :=cdsClone.FieldByName('CIAID').AsString;
               sCuenta:=cdsClone.FieldByName('PARPRESID').AsString;

               //SI LA CUENTA ORIGES ESTA DESTINADA AL DEBE LA CUENTA AUTOMATICA 1 IRA AL HABER
               if cdsClone.FieldByName('RQPARTIS').AsString='I' then
                  sDeHa:='I'
               else begin
                  sDeHa:='S';
               end;
               cdsPresup_C.Insert;
               cdsPresup_C.FieldByName('CIAID').AsString     :=cdsClone.FieldByName('CIAID').AsString;
               cdsPresup_C.FieldByName('USUARIO').AsString   :=cdsClone.FieldByName('USUARIO').AsString;
               cdsPresup_C.FieldByName('NUMERO').AsString    :=cdsClone.FieldByName('NUMERO').AsString;
               cdsPresup_C.FieldByName('ANO').AsString       :=cdsClone.FieldByName('ANO').AsString;
               cdsPresup_C.FieldByName('MES').AsString       :=cdsClone.FieldByName('MES').AsString;
               cdsPresup_C.FieldByName('TIPPRESID').AsString :=cdsClone.FieldByName('TIPPRESID').AsString;
               cdsPresup_C.FieldByName('PARPRESID').AsString :=cdsAsiento.FieldByName('PARPRESID').AsString;
               cdsPresup_C.FieldByName('CCOSID').AsString    :=cdsClone.FieldByName('CCOSID').AsString;
               cdsPresup_C.FieldByName('RQPARTIS').AsString  :=sDeHa;
               cdsPresup_C.FieldByName('TMONID').AsString    :=cdsClone.FieldByName('TMONID').AsString;
               cdsPresup_C.FieldByName('MONTOMN').AsFloat    :=cdsClone.FieldByName('MONTOMN').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME').AsFloat    :=cdsClone.FieldByName('MONTOME').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('TIPOCOL').AsString   :=cdsClone.FieldByName('TIPOCOL').AsString;
               cdsPresup_C.FieldByName('FMAYOR').AsString    :='N';

               // Para Mayorizar Anual
               cdsPresup_C.FieldByName('MONTOMN01').AsFloat  :=cdsClone.FieldByName('MONTOMN01').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME01').AsFloat  :=cdsClone.FieldByName('MONTOME01').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOMN02').AsFloat  :=cdsClone.FieldByName('MONTOMN02').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME02').AsFloat  :=cdsClone.FieldByName('MONTOME02').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOMN03').AsFloat  :=cdsClone.FieldByName('MONTOMN03').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME03').AsFloat  :=cdsClone.FieldByName('MONTOME03').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOMN04').AsFloat  :=cdsClone.FieldByName('MONTOMN04').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME04').AsFloat  :=cdsClone.FieldByName('MONTOME04').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOMN05').AsFloat  :=cdsClone.FieldByName('MONTOMN05').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME05').AsFloat  :=cdsClone.FieldByName('MONTOME05').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOMN06').AsFloat  :=cdsClone.FieldByName('MONTOMN06').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME06').AsFloat  :=cdsClone.FieldByName('MONTOME06').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOMN07').AsFloat  :=cdsClone.FieldByName('MONTOMN07').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME07').AsFloat  :=cdsClone.FieldByName('MONTOME07').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOMN08').AsFloat  :=cdsClone.FieldByName('MONTOMN08').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME08').AsFloat  :=cdsClone.FieldByName('MONTOME08').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOMN09').AsFloat  :=cdsClone.FieldByName('MONTOMN09').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME09').AsFloat  :=cdsClone.FieldByName('MONTOME09').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOMN10').AsFloat  :=cdsClone.FieldByName('MONTOMN10').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME10').AsFloat  :=cdsClone.FieldByName('MONTOME10').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOMN11').AsFloat  :=cdsClone.FieldByName('MONTOMN11').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME11').AsFloat  :=cdsClone.FieldByName('MONTOME11').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOMN12').AsFloat  :=cdsClone.FieldByName('MONTOMN12').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               cdsPresup_C.FieldByName('MONTOME12').AsFloat  :=cdsClone.FieldByName('MONTOME12').AsFloat*cdsAsiento.FieldByName('PORCENTAJE').AsFloat/100;
               //
               iOrden:=iOrden+1;

               cdsAsiento.Next;
            end;
            FSOLConta.AplicaDatos( cdsPresup_C, 'MOVCNT' );
         end;
      end;

      cdsClone.Next;
   end;
   //////////////////7

   FSOLConta.AplicaDatos( cdsPresup_C, 'MOVCNT' );

   Result:=False;

   FSOLConta.GeneraMayorPresupuestos( xCia, xUsuario, xNumero, 'S'  );

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

   if Errorcount2>0 then Exit;

   Result:=True ;
end;



procedure TFSOLConta.GeneraMayorPresupuestos( xxxCia, xxxUsuario, xxxNumero, xSuma : String );
var
   xCtaPrin, xTipPres, xTipoCol, xAnoMM, xClAux, xCuenta, xAuxDes, xAno, xMes, xDH, xSQL : string;
   xMov, xAux, xCCos, xCCoDes, xCtaDes, xFLAux, xFLCCo, xNivel, xNREG: String;
   xDigitos, xDigAnt, xNumT, xContR : Integer;
   xImpMN, xImpME    : Double;
   cdsQry2x          : TwwClientDataSet;
   cdsNivel_C        : TwwClientDataSet;
   cAno  : String;
   cMes  : String;
   cMesA : String;
begin
   FSOLConta.PanelMsg( 'Actualizando Saldos...', 0 );

   xSQL:='Select * from PPRES103 Order by PARPRESNIV';
   cdsNivel_C :=TwwClientDataSet.Create(nil);
   cdsNivel_C.RemoteServer:=DCOM_C;
   cdsNivel_C.ProviderName:=Provider_C;
   cdsNivel_C.Close;
   cdsNivel_C.DataRequest( xSQL );
   cdsNivel_C.Open;

   cdsQry2x:=TwwClientDataSet.Create(nil);
   cdsQry2x.RemoteServer:=DCOM_C;
   cdsQry2x.ProviderName:=Provider_C;

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
   xSQL:='Select A.CIAID, A.USUARIO, A.ANO, A.MES, A.TIPPRESID, A.PARPRESID, '
        +  'TIPOCOL, RQPARTIS, A.CCOSID, SUM(MONTOMN) MONTOMN, SUM(MONTOME) MONTOME, FMAYOR, '
        +  'SUM(MONTOMN01) MONTOMN01, SUM(MONTOME01) MONTOME01, SUM(MONTOMN02) MONTOMN02, SUM(MONTOME02) MONTOME02, SUM(MONTOMN03) MONTOMN03, SUM(MONTOME03) MONTOME03, '
        +  'SUM(MONTOMN04) MONTOMN04, SUM(MONTOME04) MONTOME04, SUM(MONTOMN05) MONTOMN05, SUM(MONTOME05) MONTOME05, SUM(MONTOMN06) MONTOMN06, SUM(MONTOME06) MONTOME06, '
        +  'SUM(MONTOMN07) MONTOMN07, SUM(MONTOME07) MONTOME07, SUM(MONTOMN08) MONTOMN08, SUM(MONTOME08) MONTOME08, SUM(MONTOMN09) MONTOMN09, SUM(MONTOME09) MONTOME09, '
        +  'SUM(MONTOMN10) MONTOMN10, SUM(MONTOME10) MONTOME10, SUM(MONTOMN11) MONTOMN11, SUM(MONTOME11) MONTOME11, SUM(MONTOMN12) MONTOMN12, SUM(MONTOME12) MONTOME12  '
        +'FROM PPRES311 A '
        +'WHERE A.CIAID  ='+QuotedStr( xxxCia     )
        + ' AND A.USUARIO='+QuotedStr( xxxUsuario )
        + ' AND A.NUMERO ='+QuotedStr( xxxNumero  )
        +'GROUP BY A.CIAID, A.USUARIO, A.ANO, A.MES, A.TIPPRESID, A.PARPRESID, A.CCOSID, '
        +  'A.TIPOCOL, A.RQPARTIS, FMAYOR';

   cdsMovPRE2:=TwwClientDataSet.Create(nil);
   cdsMovPRE2.RemoteServer:= DCOM_C;
   cdsMovPRE2.ProviderName:=Provider_C;
   cdsMovPRE2.Close;
   cdsMovPRE2.DataRequest( xSQL );
   cdsMovPRE2.Open;

   FSOLConta.PanelMsg( 'Actualizando Saldos - Cuentas ...', 0 );

   xContR:=0;

   cdsMovPRE2.First;
   while not cdsMovPRE2.Eof do begin

      xContR:=xContR+1;
      xCtaPrin:= cdsMovPRE2.FieldByName( 'PARPRESID' ).AsString;
      xTipPres:= cdsMovPRE2.FieldByName( 'TIPPRESID' ).AsString;
      xCCos   := cdsMovPRE2.FieldByName( 'CCOSID'    ).AsString;
      xTipoCol:= cdsMovPRE2.FieldByName( 'TIPOCOL'   ).AsString;
      xAnoMM  := cdsMovPRE2.FieldByName( 'ANO'       ).AsString+cdsMovPRE2.FieldByName('MES').AsString;
      xDH     := cdsMovPRE2.FieldByName( 'RQPARTIS'  ).AsString;
      xImpMN  := FRound(cdsMovPRE2.FieldByName( 'MONTOMN').AsFloat,15,2);
      xImpME  := FRound(cdsMovPRE2.FieldByName( 'MONTOME').AsFloat,15,2);
      xAno    := Copy(xAnoMM,1,4);
      xMes    := Copy(xAnoMM,5,2);

      // si es Descontabilización
      if xSuma='N' then begin
         xImpMN:= xImpMN * (-1);
         xImpME:= xImpME * (-1);
      end;

      xDigAnt := 0;
      cdsNivel_C.First;
      while not cdsNivel_C.EOF do
      begin
         xDigitos:= cdsNivel_C.fieldbyName('DIGITOS').AsInteger;
         xCuenta := Trim( Copy( xCtaPrin , 1, xDigitos ) );
         xNivel  := cdsNivel_C.fieldbyName('PARPRESNIV').AsString;
         xCtaDes := '';
         xMov    := '';

         if ( cdsMovPRE2.FieldByName('FMAYOR').AsString='S' ) AND
            ( xCtaPrin=xCuenta ) then begin
            if xTipoCol<>'DPREOR' then
               Break;
         end;

         xSQL:='Select PARPRESDES, PARPRESMOV from PPRES201 '
              +'Where CIAID='     +quotedstr( xxxCia     )
              + ' and TIPPRESID=' +quotedstr( xTipPres   )
              + ' and PARPRESID=' +quotedstr( xCuenta    )
              + ' and PROCE='     +quotedstr( wOrigenPRE )
              + ' and PARPRESNIV='+quotedstr( xNivel     );

         cdsQry2x.Close;
         cdsQry2x.DataRequest(xSQL); // Llamada remota al provider del servidor
         cdsQry2x.Open;

         xCtaDes := cdsQry2x.FieldByName( 'PARPRESDES'  ).AsString;
         xMov    := cdsQry2x.FieldByName( 'PARPRESMOV' ).AsString;

         if Trim(cdsNivel_C.fieldbyName('Signo').AsString)='='  then
            if Length(xCuenta)=xDigitos  then  else Break;
         if cdsNivel_C.fieldbyName('Signo').AsString='<=' then
            if (Length(xCuenta)<=xDigitos) and (Length(xCuenta)>xDigAnt) then  else Break;
         if cdsNivel_C.fieldbyName('Signo').AsString='>=' then
            if Length(xCuenta)>=xDigitos then  else Break;

         // Mayoriza con Centro de Costo
         if not FSOLConta.PPresExiste( xxxCia, xAno, xCuenta, xCCos, xTipPres  ) then
         begin
            FSOLConta.InsertaPPres( xxxCia, xAnoMM, xCuenta, xCCos, xTipPres, xTipoCol, xDH, xMov,
                                    xCtaDes, xNivel, xImpMN, xImpME );
            if Errorcount2>0 then Exit;
         end
         else
         begin
            FSOLConta.ActualizaPPres( xxxCia, xAnoMM, xCuenta, xCCos, xTipPres, xTipoCol, xDH, xMov,
                                      xCtaDes, xNivel, xImpMN, xImpME );
            if Errorcount2>0 then Exit;
         end;
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
      end;
      cdsMovPRE2.Next;
   end;


   // MAYORIZA SIN CENTRO DE COSTO

   xSQL:='Select A.CIAID, A.USUARIO, A.ANO, A.MES, A.TIPPRESID, A.PARPRESID, '
        +  'TIPOCOL, RQPARTIS, '''' CCOSID, SUM(MONTOMN) MONTOMN, SUM(MONTOME) MONTOME, FMAYOR, '
        +  'SUM(MONTOMN01) MONTOMN01, SUM(MONTOME01) MONTOME01, SUM(MONTOMN02) MONTOMN02, SUM(MONTOME02) MONTOME02, SUM(MONTOMN03) MONTOMN03, SUM(MONTOME03) MONTOME03, '
        +  'SUM(MONTOMN04) MONTOMN04, SUM(MONTOME04) MONTOME04, SUM(MONTOMN05) MONTOMN05, SUM(MONTOME05) MONTOME05, SUM(MONTOMN06) MONTOMN06, SUM(MONTOME06) MONTOME06, '
        +  'SUM(MONTOMN07) MONTOMN07, SUM(MONTOME07) MONTOME07, SUM(MONTOMN08) MONTOMN08, SUM(MONTOME08) MONTOME08, SUM(MONTOMN09) MONTOMN09, SUM(MONTOME09) MONTOME09, '
        +  'SUM(MONTOMN10) MONTOMN10, SUM(MONTOME10) MONTOME10, SUM(MONTOMN11) MONTOMN11, SUM(MONTOME11) MONTOME11, SUM(MONTOMN12) MONTOMN12, SUM(MONTOME12) MONTOME12  '
        +'FROM PPRES311 A '
        +'WHERE A.CIAID  ='+QuotedStr( xxxCia     )
        + ' AND A.USUARIO='+QuotedStr( xxxUsuario )
        + ' AND A.NUMERO ='+QuotedStr( xxxNumero  )
        +'GROUP BY A.CIAID, A.USUARIO, A.ANO, A.MES, A.TIPPRESID, A.PARPRESID, '
        +  'A.TIPOCOL, A.RQPARTIS, FMAYOR';

   cdsMovPRE2.Close;
   cdsMovPRE2.DataRequest( xSQL );
   cdsMovPRE2.Open;

   FSOLConta.PanelMsg( 'Actualizando Saldos - Cuentas ...', 0 );

   cdsMovPRE2.First;
   while not cdsMovPRE2.Eof do begin

      xCtaPrin:= cdsMovPRE2.FieldByName( 'PARPRESID' ).AsString;
      xTipPres:= cdsMovPRE2.FieldByName( 'TIPPRESID' ).AsString;
      xCCos   := cdsMovPRE2.FieldByName( 'CCOSID'    ).AsString;
      xTipoCol:= cdsMovPRE2.FieldByName( 'TIPOCOL'   ).AsString;
      xAnoMM  := cdsMovPRE2.FieldByName( 'ANO'       ).AsString+cdsMovPRE2.FieldByName('MES').AsString;
      xDH     := cdsMovPRE2.FieldByName( 'RQPARTIS'  ).AsString;
      xImpMN  := FRound(cdsMovPRE2.FieldByName( 'MONTOMN').AsFloat,15,2);
      xImpME  := FRound(cdsMovPRE2.FieldByName( 'MONTOME').AsFloat,15,2);
      xAno    := Copy(xAnoMM,1,4);
      xMes    := Copy(xAnoMM,5,2);

      // si es Descontabilización
      if xSuma='N' then begin
         xImpMN:= xImpMN * (-1);
         xImpME:= xImpME * (-1);
      end;

      xDigAnt := 0;
      cdsNivel_C.First;
      while not cdsNivel_C.EOF do
      begin
         xDigitos:= cdsNivel_C.fieldbyName('DIGITOS').AsInteger;
         xCuenta := Trim( Copy( xCtaPrin , 1, xDigitos ) );
         xNivel  := cdsNivel_C.fieldbyName('PARPRESNIV').AsString;
         xCtaDes := '';
         xMov    := '';

         if ( cdsMovPRE2.FieldByName('FMAYOR').AsString='S' ) AND
            ( xCtaPrin=xCuenta ) then begin
            if xTipoCol<>'DPREOR' then
               Break;
         end;

         xSQL:='Select PARPRESDES, PARPRESMOV from PPRES201 '
              +'Where CIAID='     +quotedstr( xxxCia     )
              + ' and TIPPRESID=' +quotedstr( xTipPres   )
              + ' and PARPRESID=' +quotedstr( xCuenta    )
              + ' and PROCE='     +quotedstr( wOrigenPRE )
              + ' and PARPRESNIV='+quotedstr( xNivel     );

         cdsQry2x.Close;
         cdsQry2x.DataRequest(xSQL); // Llamada remota al provider del servidor
         cdsQry2x.Open;

         xCtaDes := cdsQry2x.FieldByName( 'PARPRESDES'  ).AsString;
         xMov    := cdsQry2x.FieldByName( 'PARPRESMOV' ).AsString;

         if Trim(cdsNivel_C.fieldbyName('Signo').AsString)='='  then
            if Length(xCuenta)=xDigitos  then  else Break;
         if cdsNivel_C.fieldbyName('Signo').AsString='<=' then
            if (Length(xCuenta)<=xDigitos) and (Length(xCuenta)>xDigAnt) then  else Break;
         if cdsNivel_C.fieldbyName('Signo').AsString='>=' then
            if Length(xCuenta)>=xDigitos then  else Break;

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

         xDigAnt := cdsNivel_C.fieldbyName('Digitos').AsInteger;
         cdsNivel_C.Next;
      end;
      cdsMovPRE2.Next;
   end;


   FSOLConta.PanelMsg( 'Final de Actualiza Saldos...', 0 );
   cdsQry2x.IndexFieldNames:='';
end;


function TFSOLConta.PPresExiste( xCia1, xAno1, xCuenta1, xCCosto1, xTipPres1 : String ): Boolean;
var
   xSQL : String;
   xAuxid,xCCosid : String;
begin
   If xCCosto1 = '' then begin
      if (SRV_C='DB2NT') or (SRV_C='DB2400') then begin
         xCcosid := 'CCOSID=''''';
      end;
      if SRV_C='ORACLE' then begin
         xCcosid := 'CCOSID IS NULL'
      end;
   end
   else begin
      xCcosid := 'CCOSID='+quotedstr( xCCosto1 );
   end;

   xSQL:='Select COUNT( PARPRESID ) TOTREG from PPRES301 '
        +'Where CIAID='    +''''+ xCia1    +''''+' and '
        +      'RQPARTANO='+''''+ xAno1    +''''+' and '
        +      'TIPPRESID='+''''+ xTipPres1+''''+' and '
        +      'PARPRESID='+''''+ xCuenta1 +''''+' and '
        +       xCCosid+ ' and '
        +      'PROCE='''+wOrigenPRE+'''';

   cdsQry_C.Close;
   cdsQry_C.DataRequest( xSQL );
   cdsQry_C.Open;

   if cdsQry_C.fieldbyName('TOTREG').asInteger>0 then
      Result:=True
   else
      Result:=False;
end;


procedure TFSOLConta.ActualizaPPres(cCia, cAnoMM, cCuenta, cCCosto, cTipPres, cTipoCol, cDH, cMov,
                                    cCtaDes, cNivel : String; nImpMN, nImpME : double );
var
   cMes, cAno, cSQL, cMesT, cMesA : String;
   nMes             : Integer;
   xAuxid, xCcosid, xClauxid, xTiTo : String;
begin
   cAno  := Copy( cAnoMM,1,4 );
   cMes  := Copy( cAnoMM,5,2 );
   //cMesA := StrZero( IntToStr( StrToInt(cMes)-1 ), 2 );
   cSQL  := 'Update PPRES301 Set PARPREDES ='+''''+cCtaDes+''''+', ';

   xTiTo   :=Copy( cTipoCol, 5, 2 );

   if wTMay='M' then begin
      if cDH='I' then begin
         // Columna de Movimientos
         cSQL:=cSQL+' '+cTipoCol+'MN'+ cMes +'='+
                    'ROUND( '+wReplaCeros+'( '+cTipoCol+'MN'+ cMes +',0)+ROUND('+ FloatToStr( nImpMN )+',2 ),2 ) ';
         cSQL:=cSQL+', '+cTipoCol+'ME'+ cMes+'='+
                    'ROUND( '+wReplaCeros+'( '+cTipoCol+'ME'+ cMes +',0)+ROUND('+ FloatToStr( nImpME )+',2 ),2 ) ';
         // Columna de Totales
         cSQL:=cSQL+', DPRETO'+xTiTo+'MN'+ '='+
                    'ROUND( '+wReplaCeros+'( DPRETO'+xTiTo+'MN'+',0)+ROUND('+ FloatToStr( nImpMN )+',2 ),2 ) ';
         cSQL:=cSQL+', DPRETO'+xTiTo+'ME'+ '='+
                    'ROUND( '+wReplaCeros+'( DPRETO'+xTiTo+'ME'+',0)+ROUND('+ FloatToStr( nImpME )+',2 ),2 ) ';
      end;
      if cDH='S' then begin
         // Columna de Movimientos
         cSQL:=cSQL+' '+cTipoCol+'MN'+ cMes +'='+
                    'ROUND( '+wReplaCeros+'( '+cTipoCol+'MN'+ cMes +',0)+ROUND('+ FloatToStr( nImpMN )+',2 ),2 ) ';
         cSQL:=cSQL+', '+cTipoCol+'ME'+ cMes +'='+
                    'ROUND( '+wReplaCeros+'( '+cTipoCol+'ME'+ cMes +',0)+ROUND('+ FloatToStr( nImpME )+',2 ),2 ) ';
         // Columna de Totales
         cSQL:=cSQL+', DPRETO'+xTiTo+'MN'+ '='+
                    'ROUND( '+wReplaCeros+'( DPRETO'+xTiTo+'MN'+ ',0)+ROUND('+ FloatToStr( nImpMN )+',2 ),2 ) ';
         cSQL:=cSQL+', DPRETO'+xTiTo+'ME'+ '='+
                    'ROUND( '+wReplaCeros+'( DPRETO'+xTiTo+'ME'+ ',0)+ROUND('+ FloatToStr( nImpME )+',2 ),2 ) ';
      end;

      cSQL:=cSQL+', DPRETO'+xTiTo+'MN=ROUND( '+wReplaCeros+'( DPRETO'+xTiTo+'MN,0)+'
                                 +'ROUND('+ FloatToStr( FRound( cdsMovPRE2.FieldByName( 'MONTOMN'+cMes).AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', DPRETO'+xTiTo+'ME=ROUND( '+wReplaCeros+'( DPRETO'+xTiTo+'ME,0)+'
                                 +'ROUND('+ FloatToStr( FRound( cdsMovPRE2.FieldByName( 'MONTOME'+cMes).AsFloat,15,2) )+',2 ),2 ) ';
   end;

   if wTMay='A' then begin
      // Columna de Movimientos
      cSQL:=cSQL+'  '+cTipoCol+'MN01=ROUND( '+wReplaCeros+'( '+cTipoCol+'MN01,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOMN01').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'ME01=ROUND( '+wReplaCeros+'( '+cTipoCol+'ME01,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOME01').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'MN02=ROUND( '+wReplaCeros+'( '+cTipoCol+'MN02,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOMN02').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'ME02=ROUND( '+wReplaCeros+'( '+cTipoCol+'ME02,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOME02').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'MN03=ROUND( '+wReplaCeros+'( '+cTipoCol+'MN03,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOMN03').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'ME03=ROUND( '+wReplaCeros+'( '+cTipoCol+'ME03,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOME03').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'MN04=ROUND( '+wReplaCeros+'( '+cTipoCol+'MN04,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOMN04').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'ME04=ROUND( '+wReplaCeros+'( '+cTipoCol+'ME04,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOME04').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'MN05=ROUND( '+wReplaCeros+'( '+cTipoCol+'MN05,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOMN05').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'ME05=ROUND( '+wReplaCeros+'( '+cTipoCol+'ME05,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOME05').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'MN06=ROUND( '+wReplaCeros+'( '+cTipoCol+'MN06,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOMN06').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'ME06=ROUND( '+wReplaCeros+'( '+cTipoCol+'ME06,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOME06').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'MN07=ROUND( '+wReplaCeros+'( '+cTipoCol+'MN07,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOMN07').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'ME07=ROUND( '+wReplaCeros+'( '+cTipoCol+'ME07,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOME07').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'MN08=ROUND( '+wReplaCeros+'( '+cTipoCol+'MN08,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOMN08').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'ME08=ROUND( '+wReplaCeros+'( '+cTipoCol+'ME08,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOME08').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'MN09=ROUND( '+wReplaCeros+'( '+cTipoCol+'MN09,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOMN09').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'ME09=ROUND( '+wReplaCeros+'( '+cTipoCol+'ME09,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOME09').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'MN10=ROUND( '+wReplaCeros+'( '+cTipoCol+'MN10,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOMN10').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'ME10=ROUND( '+wReplaCeros+'( '+cTipoCol+'ME10,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOME10').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'MN11=ROUND( '+wReplaCeros+'( '+cTipoCol+'MN11,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOMN11').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'ME11=ROUND( '+wReplaCeros+'( '+cTipoCol+'ME11,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOME11').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'MN12=ROUND( '+wReplaCeros+'( '+cTipoCol+'MN12,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOMN12').AsFloat,15,2) )+',2 ),2 ) ';
      cSQL:=cSQL+', '+cTipoCol+'ME12=ROUND( '+wReplaCeros+'( '+cTipoCol+'ME12,0)+ROUND('+ FloatToStr( FRound(cdsMovPRE2.FieldByName( 'MONTOME12').AsFloat,15,2) )+',2 ),2 ) ';

      cSQL:=cSQL+', DPRETO'+xTiTo+'MN=ROUND( '+wReplaCeros+'( DPRETO'+xTiTo+'MN,0)+'
                +FloatToStr( FRound( cdsMovPRE2.FieldByName( 'MONTOMN01'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOMN02'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOMN03'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOMN04'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOMN05'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOMN06'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOMN07'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOMN08'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOMN09'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOMN10'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOMN11'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOMN12'+cMes).AsFloat,15,2) )+', 2 ) ';
      cSQL:=cSQL+', DPRETO'+xTiTo+'ME=ROUND( '+wReplaCeros+'( DPRETO'+xTiTo+'ME,0)+'
                +FloatToStr( FRound( cdsMovPRE2.FieldByName( 'MONTOME01'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOME02'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOME03'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOME04'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOME05'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOME06'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOME07'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOME08'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOME08'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOME10'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOME11'+cMes).AsFloat +
                +                    cdsMovPRE2.FieldByName( 'MONTOME12'+cMes).AsFloat,15,2) )+', 2 ) ';
   end;

   If cCCosto = '' then begin
      if (SRV_C='DB2NT') or (SRV_C='DB2400') then begin
         xCcosid := 'CCOSID=''''';
      end;
      if SRV_C='ORACLE' then begin
         xCcosid := 'CCOSID IS NULL'
      end;
   end
   else begin
      xCcosid := 'CCOSID='+quotedstr(cCCosto);
   end;


   cSQL:=cSQL + 'Where CIAID='    +''''+cCia    +''''+' and '
              +       'RQPARTANO='+''''+cAno    +''''+' and '
              +       'TIPPRESID='+''''+cTipPres+''''+' and '
              +       'PARPRESID='+''''+cCuenta +''''+' and '
              +        xCCosid+ ' and '
              +       'PROCE='''+wOrigenPRE+'''';

   cSQL:=cSQL +xAuxid+xClauxid;

   try
      cdsQry_C.Close;
      cdsQry_C.DataRequest( cSQL );
      cdsQry_C.Execute;
   except
      Errorcount2:=1;
   end;
end;


procedure TFSOLConta.InsertaPPres(cCia, cAnoMM, cCuenta, cCCosto, cTipPres, cTipoCol, cDH, cMov,
                                  cCtaDes, cNivel : String; nImpMN, nImpME : Double);
var
   cMes, cAno, cSQL, cMesT : String;
   nMes             : Integer;
   xCtaMov, xTito : String;
begin
   cAno:=Copy( cAnoMM,1,4 );
   cMes:=Copy( cAnoMM,5,2 );

   xTiTo   :=Copy( cTipoCol, 5, 2 );

   cSQL:='Insert into PPRES301( CIAID, RQPARTANO, TIPPRESID, PARPRESID, BALANCE, '
        +                     ' PARPREDES, PARPRESMOV, PARPRESNIV, PROCE, CCOSID ';
   cSQL:='Insert into PPRES301( CIAID, RQPARTANO, TIPPRESID, PARPRESID, CCOSID, PROCE, '
        +                     ' PARPREDES, PARPRESMOV, PARPRESNIV, BALANCE ';
   if wTMay='M' then begin
      if cDH='I' then begin
         // Columna de Movimientos
         cSQL:=cSQL+', '+cTipoCol+'MN'+ cMes;
         cSQL:=cSQL+', '+cTipoCol+'ME'+ cMes;
         // Columna de Totales
         cSQL:=cSQL+', DPRETO'+xTiTo+'MN';
         cSQL:=cSQL+', DPRETO'+xTiTo+'ME';
      end;
      if cDH='S' then begin
         // Columna de Movimientos
         cSQL:=cSQL+', '+cTipoCol+'MN'+ cMes;
         cSQL:=cSQL+', '+cTipoCol+'ME'+ cMes;
         // Columna de Totales
         cSQL:=cSQL+', DPRETO'+xTiTo+'MN';
         cSQL:=cSQL+', DPRETO'+xTiTo+'ME';
      end;
      cSQL:=cSQL+' ) ';
      cSQL:=cSQL+'Values( '+''''+cCia    +''''+', '+''''+cAno    +''''+', '
                           +''''+cTipPres+''''+', '+''''+cCuenta +''''+', '
                           +quotedstr( cCCosto )+', '''+wOrigenPRE+''', '
                           +''''+cCtaDes +''''+', '+quotedstr( cMov)+', '
                           +quotedStr( cNivel ) +', '+''''+'S'     +''', '
                           +FloatToStr( nImpMN )+', '
                           +FloatToStr( nImpME )+', '
                           +FloatToStr( nImpMN )+', '
                           +FloatToStr( nImpME )+' ) ';
   end;

   if wTMay='A' then begin

      // Columna de Movimientos
      cSQL:=cSQL+', '+cTipoCol+'MN01, '+cTipoCol+'ME01';
      cSQL:=cSQL+', '+cTipoCol+'MN02, '+cTipoCol+'ME02';
      cSQL:=cSQL+', '+cTipoCol+'MN03, '+cTipoCol+'ME03';
      cSQL:=cSQL+', '+cTipoCol+'MN04, '+cTipoCol+'ME04';
      cSQL:=cSQL+', '+cTipoCol+'MN05, '+cTipoCol+'ME05';
      cSQL:=cSQL+', '+cTipoCol+'MN06, '+cTipoCol+'ME06';
      cSQL:=cSQL+', '+cTipoCol+'MN07, '+cTipoCol+'ME07';
      cSQL:=cSQL+', '+cTipoCol+'MN08, '+cTipoCol+'ME08';
      cSQL:=cSQL+', '+cTipoCol+'MN09, '+cTipoCol+'ME09';
      cSQL:=cSQL+', '+cTipoCol+'MN10, '+cTipoCol+'ME10';
      cSQL:=cSQL+', '+cTipoCol+'MN11, '+cTipoCol+'ME11';
      cSQL:=cSQL+', '+cTipoCol+'MN12, '+cTipoCol+'ME12';

      cSQL:=cSQL+', DPRETO'+xTiTo+'MN, DPRETO'+xTiTo+'ME';

      cSQL:=cSQL+' ) ';
{      cSQL:=cSQL+'Values( '+''''+cCia    +''''+', '+''''+cAno    +''''+', '
                           +''''+cTipPres+''''+', '+''''+cCuenta +''''+', '
                           +''''+'S'     +''''+', '+''''+cCtaDes +''''+', '
                           +quotedstr( cMov)+', '+quotedStr( cNivel ) +', '''+wOrigenPRE+''', '
                           +quotedstr( cCCosto )+', '}
      cSQL:=cSQL+'Values( '+''''+cCia    +''''+', '+''''+cAno    +''''+', '
                           +''''+cTipPres+''''+', '+''''+cCuenta +''''+', '
                           +quotedstr( cCCosto )+', '''+wOrigenPRE+''', '
                           +''''+cCtaDes +''''+', '+quotedstr( cMov)+', '
                           +quotedStr( cNivel ) +', '+''''+'S'     +''', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN01').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME01').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN02').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME02').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN03').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME03').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN04').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME04').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN05').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME05').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN06').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME06').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN07').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME07').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN08').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME08').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN09').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME09').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN10').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME10').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN11').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME11').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN12').AsFloat )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME12').AsFloat )+', '

                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOMN01').AsFloat
                                       +cdsMovPRE2.FieldByName( 'MONTOMN02').AsFloat
                                       +cdsMovPRE2.FieldByName( 'MONTOMN03').AsFloat
                                       +cdsMovPRE2.FieldByName( 'MONTOMN04').AsFloat
                                       +cdsMovPRE2.FieldByName( 'MONTOMN05').AsFloat
                                       +cdsMovPRE2.FieldByName( 'MONTOMN06').AsFloat
                                       +cdsMovPRE2.FieldByName( 'MONTOMN07').AsFloat
                                       +cdsMovPRE2.FieldByName( 'MONTOMN08').AsFloat
                                       +cdsMovPRE2.FieldByName( 'MONTOMN09').AsFloat
                                       +cdsMovPRE2.FieldByName( 'MONTOMN10').AsFloat
                                       +cdsMovPRE2.FieldByName( 'MONTOMN11').AsFloat
                                       +cdsMovPRE2.FieldByName( 'MONTOMN12').AsFloat
                                       )+', '
                           +FloatToStr( cdsMovPRE2.FieldByName( 'MONTOME01').AsFloat
                                      + cdsMovPRE2.FieldByName( 'MONTOME02').AsFloat
                                      + cdsMovPRE2.FieldByName( 'MONTOME03').AsFloat
                                      + cdsMovPRE2.FieldByName( 'MONTOME04').AsFloat
                                      + cdsMovPRE2.FieldByName( 'MONTOME05').AsFloat
                                      + cdsMovPRE2.FieldByName( 'MONTOME06').AsFloat
                                      + cdsMovPRE2.FieldByName( 'MONTOME07').AsFloat
                                      + cdsMovPRE2.FieldByName( 'MONTOME08').AsFloat
                                      + cdsMovPRE2.FieldByName( 'MONTOME09').AsFloat
                                      + cdsMovPRE2.FieldByName( 'MONTOME10').AsFloat
                                      + cdsMovPRE2.FieldByName( 'MONTOME11').AsFloat
                                      + cdsMovPRE2.FieldByName( 'MONTOME12').AsFloat
                                      )+' ) ';
   end;

   try
      cdsQry_C.Close;
      cdsQry_C.DataRequest( cSQL );
      cdsQry_C.Execute;
   except
      Errorcount2:=1;
   end;
end;





end.
