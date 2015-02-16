<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Cuenta.aspx.cs" Inherits="Sistema_Cuenta" %>

<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=9.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
    Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>
<%@ Register Src="/Controles/header3.ascx" TagPrefix="uc1" TagName="header" %>
<%@ Register Src="/Controles/Info-Alumno3.ascx" TagPrefix="uc1" TagName="InfoAlumno" %>
<%@ Register Src="/Controles/Script3.ascx" TagPrefix="uc1" TagName="Script3" %>

<!DOCTYPE html>
<html lang="es">
<head id="Head1" runat="server">
    <title>Estado de Cuenta</title>
    <link href="/css/bootstrap3.css" rel="stylesheet" />
    <link href="/css/bootstrap-theme.min.css" rel="stylesheet" />
    <link href="/css/select2.css" rel="stylesheet" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <style type="text/css">
        /*Sirve para el link de los recibos o trámites.*/
        .btn-link {
            text-decoration: underline !important;
            padding: 0px 0px !important;
        }
        /*Sirve para diferenciar un recibo dentro de la tabla de detalles.*/
        .recibo > td,
        .recibo > th {
            background-color: #CEE3F6 !important;
            border-color: #CEE3F6 !important;
        }

        /*Sirve para que cambie de color el total de la tabla de Resumen.*/
        .total > td,
        .total > th {
            background-color: #d9edf7 !important;
            border-color: #d9edf7 !important;
        }

        #gvExoneracion > tbody > tr > td {
            vertical-align: middle !important;
        }

        #gvFraccionamiento > tbody > tr > td {
            vertical-align: middle !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <uc1:header runat="server" ID="header" />
        <br />
        <div class="container">
            <div class="panel panel-info">
                <div style="background-color: #FAFAFA; border: 1px solid #e3e3e3; border-radius: 4px">
                    <div class="row" style="margin-top: 5px; margin-bottom: 5px">
                        <div class="col-md-12">
                            <div class="col-md-3 col-lg-2">
                                <uc1:InfoAlumno runat="server" ID="InfoAlumno" />
                            </div>
                            <div class="col-md-9 col-lg-8 table-bordered">
                                <div class="row" style="margin-top: 5px">
                                    <div class="col-md-4 col-lg-offset-0 col-lg-4">
                                        <div class="col-md-12">
                                            <div class="panel panel-info">
                                                <div class="panel-heading">
                                                    <h4 class="panel-title text-center">Becas</h4>
                                                </div>

                                                <div class="row">
                                                    <div id="dvBecaNo" runat="server">
                                                        <div class="col-md-12">
                                                            <div class="alert alert-warning text-center" style="margin-top: 30px; margin-bottom: 35px">
                                                                <label style="color: #B18904"><strong>NO TIENE BECA</strong> </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div id="dvBecaSi" runat="server">
                                                        <div class="col-md-12 text-center">
                                                            <label runat="server" id="lblDescBeca" class="text-center"></label>
                                                        </div>
                                                        <div class="col-md-5 col-xs-3 col-lg-5 col-xs-offset-3 col-md-offset-0 col-lg-offset-0">
                                                            <div class="col-md-12 col-xs-12">
                                                                <label style="font-size: 12px">MT%</label>
                                                            </div>
                                                            <div class="col-md-12 col-xs-12">
                                                                <label style="font-size: 12px">Q</label>
                                                            </div>
                                                            <div class="col-md-12 col-xs-12">
                                                                <label style="font-size: 12px">CT%</label>
                                                            </div>
                                                            <div class="col-md-12 col-xs-12">
                                                                <label style="font-size: 12px">Q</label>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-7 text-right col-lg-7 col-xs-3">
                                                            <div class="col-md-11 col-xs-11">
                                                                <label runat="server" id="lblMtpor" style="font-size: 12px"></label>
                                                            </div>
                                                            <div class="col-md-11 col-xs-11">
                                                                <label runat="server" id="lblMtCant" style="font-size: 12px"></label>
                                                            </div>
                                                            <div class="col-md-11 col-xs-11">
                                                                <label runat="server" id="lblCtpor" style="font-size: 12px"></label>
                                                            </div>
                                                            <div class="col-md-11 col-xs-11">
                                                                <label runat="server" id="lblCtCant" style="font-size: 12px"></label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4 col-lg-offset-0 col-lg-4">
                                        <div class="col-md-12">
                                            <div class=" panel panel-info">
                                                <div class="panel-heading">
                                                    <div class="row">
                                                        <h4 class="panel-title text-center">Cuotas</h4>
                                                    </div>
                                                </div>
                                                <div class="panel-group" style="margin-top: 25px; margin-bottom: 25px;">
                                                    <!--Cuotas-->
                                                    <div class="row">
                                                        <div class="col-md-5 col-lg-5 col-xs-3 col-xs-offset-2 col-sm-offset-3 col-sm-2 col-md-offset-0 col-lg-offset-0">
                                                            <div class="col-md-12 col-xs-12">
                                                                <label class="text-center" style="font-size: 12px"><strong>Fija</strong></label>
                                                            </div>
                                                            <div class="col-md-12 col-xs-12">
                                                                <label style="font-size: 12px"><strong>Variable</strong></label>
                                                            </div>
                                                            <div class="col-md-12 col-xs-12">
                                                                <label style="font-size: 12px"><strong>Sugerida</strong></label>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-7 col-xs-3 text-right">
                                                            <div class="col-md-11 col-xs-12">
                                                                <label runat="server" id="lblCuotaFija" style="font-size: 12px"></label>
                                                            </div>
                                                            <div class="col-md-11 col-xs-12">
                                                                <label runat="server" id="lblCuotaVar" style="font-size: 12px"></label>
                                                            </div>
                                                            <div class="col-md-11 col-xs-12">
                                                                <label runat="server" id="lblCuotaSug" style="font-size: 12px"></label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4 col-lg-offset-0 col-lg-4">
                                        <div class="col-md-12">
                                            <div class=" panel panel-info">
                                                <div class="panel-heading">
                                                    <div class="row">
                                                        <h4 class="panel-title text-center">Saldos</h4>
                                                    </div>
                                                </div>
                                                <!--Saldos-->
                                                <div style="margin-top: 25px; margin-bottom: 25px;">
                                                    <div class="row">
                                                        <div class="col-md-6 col-lg-5 col-xs-4 col-sm-2 col-xs-offset-1 col-sm-offset-3 col-lg-offset-0 col-md-offset-0">
                                                            <div class="col-md-12 col-xs-12 col-lg-12">
                                                                <label style="font-size: 12px"><strong>Por_Ctas</strong></label>
                                                            </div>
                                                            <div class="col-md-12 col-xs-12">
                                                                <label style="font-size: 12px"><strong>Extraordinario</strong></label>
                                                            </div>
                                                            <div class="col-md-12 col-xs-12">
                                                                <label style="font-size: 12px"><strong>Sugerido</strong></label>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-5 col-lg-7 col-xs-3 col-xs-offset-1 col-lg-offset-0 col-sm-3 col-sm-offset-0 col-md-offset-0 text-right">
                                                            <div class="col-md-12 col-xs-12">
                                                                <label runat="server" id="lblPorCtas" style="font-size: 12px"></label>
                                                            </div>
                                                            <div class="col-md-12 col-xs-12">
                                                                <label runat="server" id="lblExtraordinario" style="font-size: 12px"></label>
                                                            </div>
                                                            <div class="col-md-12 col-xs-12">
                                                                <label runat="server" id="lblSalSugerido" style="font-size: 12px"></label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-12 col-xs-12" style="margin-top: 10px; margin-bottom: 5px">
                                            <div class="col-lg-5 col-md-6 col-xs-12">
                                                <div class="col-md-9 col-sm-5 col-lg-9 text-right col-xs-7">
                                                    <label>Total a Pagar del Ciclo: </label>
                                                </div>
                                                <div class="col-md-3 text-left col-xs-4">
                                                    <label id="lblTotalPagar" runat="server"></label>
                                                </div>
                                            </div>
                                            <div class="col-lg-6 col-md-6 col-xs-12">
                                                <div class="col-md-8 col-lg-7 text-right col-xs-6 col-xs-offset-1 col-sm-4 col-sm-offset-1">
                                                    <label>Total a Pagar Hoy:</label>
                                                </div>
                                                <div class="col-md-3  col-xs-5 col-sm-6">
                                                    <label id="lblPagarHoy" runat="server"></label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 col-lg-2 col-lg-offset-0 col-md-offset-2">
                                <div class="row">
                                    <div class="col-md-12 col-xs-12">
                                        <div class=" panel panel-info" style="margin-top: 5px">
                                            <div class="panel-heading">
                                                <div class="row">
                                                    <h4 class="panel-title text-center">Multas</h4>
                                                </div>
                                            </div>

                                            <!--Multas-->
                                            <div class="form-search pull-right hidden" data-tabla="gvMultas">
                                                <input type="text" class="search-query" placeholder="Buscar..." />
                                            </div>

                                            <table class="table table-striped table-bordered table-hover table-condensed" data-orden="false" data-filtro="true" data-fuente="dtLlenar"
                                                id="gvMultas">
                                                <thead>
                                                    <tr style="font-size: 11px;">
                                                        <th data-tipo="int" data-campo="MONTO" style="text-align: center" data-alineacion="centro">MONTO
                                                        </th>
                                                        <th data-tipo="int" data-campo="MULTA" style="text-align: center" data-alineacion="centro">CUOTA</th>
                                                        <th data-tipo="int" data-campo="DIAS" style="text-align: center" data-alineacion="centro">DIAS
                                                        </th>
                                                    </tr>
                                                </thead>
                                                <tbody class="grid" style="font-size: 11px">
                                                </tbody>
                                            </table>
                                        </div>


                                        <div class="col-md-11">

                                            <button type="button" id="exoneracion" visible="false" class="btn btn-info"
                                                style="width: 100%; margin-bottom: 10px" runat="server">
                                                Exoneración</button>


                                            <button type="button" id="fraccionamiento" visible="false" runat="server" class="btn btn-info" style="width: 100%; margin-bottom: 10px">Fraccionamiento</button>
                                        </div>

                                        <br />

                                        <div class="row">
                                            <div class="col-md-12">
                                                <div class="col-md-4 col-xs-1 col-xs-offset-4 col-md-offset-0">
                                                    <label>Total</label>
                                                </div>
                                                <div class="col-md-6 col-xs-5 col-xs-offset-1">
                                                    <label runat="server" id="lblTotalMultas"></label>
                                                </div>
                                            </div>
                                        </div>


                                        <div class="col-md-2 hidden">
                                            <div class="pagination pagination-centered hidden" style="display: block;">
                                                <ul data-tabla="gvMultas" data-cantidad="30" data-grupo="1">
                                                </ul>
                                            </div>
                                        </div>

                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12 col-xs-12">
                    <div class="panel panel-info" style="overflow-x: auto">
                        <div class="panel-heading">
                            <div class="row">
                                <h4 class="panel-title text-center">Resumen</h4>
                            </div>
                        </div>
                        <div style="overflow-x: auto">
                            <!--Resumen-->
                            <div class="form-search pull-right hidden" data-tabla="gvResumen">
                                <input type="text" class="search-query" placeholder="Buscar..." />
                            </div>
                            <table class="table table-striped table-bordered table-hover table-condensed" data-orden="false" data-filtro="true" data-fuente="dtLlenar1"
                                id="gvResumen">
                                <thead>
                                    <tr style="font-size: 12px">
                                        <th data-tipo="string" data-campo="CONCEPTO" style="text-align: center" data-alineacion="centro">Cod.</th>
                                        <th data-tipo="string" data-campo="CENTRO" style="text-align: center" data-alineacion="centro">Centro</th>
                                        <th data-tipo="string" data-campo="CODMOVTO" style="text-align: center" data-alineacion="left">Concepto
                                        </th>
                                        <th data-tipo="string" data-campo="CUOTA" style="text-align: center" data-alineacion="derecha">Cuota
                                        </th>
                                        <th data-tipo="string" data-campo="CARGOS" style="text-align: center" data-alineacion="derecha">Cargos
                                        </th>
                                        <th data-tipo="string" data-campo="PAGOS" style="text-align: center" data-alineacion="derecha">Pagos
                                        </th>
                                        <th data-tipo="string" data-campo="ABONOS" style="text-align: center" data-alineacion="derecha">Abonos
                                        </th>
                                        <th data-tipo="string" data-campo="MORA" style="text-align: center" data-alineacion="derecha">Mora
                                        </th>
                                        <th data-tipo="string" data-campo="ADELANTO" style="text-align: center" data-alineacion="derecha">Adelanto
                                        </th>
                                        <th data-tipo="string" data-campo="SALDO" style="text-align: center" data-alineacion="derecha">Saldo</th>
                                    </tr>
                                </thead>
                                <tbody class="grid" style="font-size: 11px">
                                </tbody>
                            </table>
                            <div class="col-md-2 hidden">
                                <div class="pagination pagination-centered hidden" style="display: block;">
                                    <ul data-tabla="gvResumen" data-cantidad="200" data-grupo="1">
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-3 col-md-offset-3">
                    <div class="col-md-8 col-md-offset-3">
                        <button type="button" runat="server" id="btnHitorial" class="btn btn-info"
                            onserverclick="Historial_OnClick" style="width: 100%; margin-bottom: 10px">
                            Ver Historial</button>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="col-xs-12">
                        <button type="button" class="btn btn-info" style="width: 100%; margin-bottom: 10px" runat="server" onserverclick="Imprimir_Click">Imprimir</button>
                    </div>
                </div>
            </div>


            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-info">
                        <div class="panel-heading">
                            <div class="row">
                                <h4 class="panel-title text-center">Detalles</h4>
                            </div>
                        </div>
                        <div style="overflow-x: auto">
                            <div class="form-search pull-right hidden" data-tabla="gvDetalles" style="overflow: auto">
                                <input type="text" class="search-query" placeholder="Buscar..." />
                            </div>
                            <table class="table table-striped table-bordered table-hover table-condensed " data-orden="false" data-filtro="true" data-fuente="dtLlenar2"
                                id="gvDetalles">
                                <thead>
                                    <tr style="font-size: 12px">
                                        <th data-tipo="datetime" data-campo="FECHA" style="text-align: center" data-formato="dd/MM/yyyy" data-alineacion="centro">FECHA</th>
                                        <th data-tipo="string" data-campo="CENTRO" style="text-align: center" data-alineacion="centro">Centro
                                        </th>
                                        <th data-tipo="string" data-campo="TIPO" style="text-align: center" data-alineacion="centro">Tipo
                                        </th>
                                        <th data-tipo="html" data-campo="OPERACION2" style="text-align: center" data-alineacion="centro">OPERACION
                                        </th>
                                        <th data-tipo="string" data-campo="NUMCTA" style="text-align: center" data-alineacion="centro">Ciclo
                                        </th>
                                        <th data-tipo="string" data-campo="FRACCION" style="text-align: center" data-alineacion="centro">FR
                                        </th>
                                        <th data-tipo="string" data-campo="INI_FRAC" style="text-align: center" data-alineacion="centro">INI
                                        </th>
                                        <th data-tipo="string" data-campo="CODMOVTO" style="text-align: center" data-alineacion="centro">Cpto.
                                        </th>
                                        <th data-tipo="string" data-campo="MOVIMIENTO" style="text-align: center" data-alineacion="left">Movimientos
                                        </th>
                                        <th data-tipo="string" data-campo="CURSO" style="text-align: center" data-alineacion="centro">Curso</th>
                                        <th data-tipo="string" data-campo="CARGO" style="text-align: center" data-alineacion="derecha">Cargo</th>
                                        <th data-tipo="string" data-campo="ABONO" style="text-align: center" data-alineacion="derecha">Abono</th>
                                        <th data-tipo="string" data-campo="SALDO" style="text-align: center" data-alineacion="derecha">Saldo</th>
                                        <th data-tipo="string" data-campo="OBSERVACIONES" style="text-align: center">Observaciones</th>
                                        <th data-tipo="html" data-campo="OPERACION" style="text-align: center" data-alineacion="centro" class="hidden">OPERACION
                                        </th>
                                    </tr>
                                </thead>
                                <tbody class="grid" style="font-size: 11px">
                                </tbody>
                            </table>
                            <div class="col-md-2 hidden">
                                <div class="pagination pagination-centered hidden" style="display: block;">
                                    <ul data-tabla="gvDetalles" data-cantidad="300" data-grupo="1">
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!---->
            <div class="row">
                <div class="col-md-12">
                    <div class=" panel panel-info">
                        <div class="panel-heading">
                            <div class="row">
                                <h4 class="panel-title text-center">Cursos Asignados</h4>
                            </div>
                        </div>
                        <div style="overflow-y: auto">
                            <div class="form-search pull-right hidden" data-tabla="gvCursos">
                                <input type="text" class="search-query" placeholder="Buscar..." />
                            </div>
                            <table class="table table-striped table-bordered table-hover table-condensed" data-orden="false" data-filtro="true" data-fuente="dtLlenar3"
                                id="gvCursos">
                                <thead>
                                    <tr style="font-size: 12px">
                                        <th data-tipo="string" data-campo="CARRERA" data-alineacion="centro" style="text-align: center">Carrera</th>
                                        <th data-tipo="int" data-campo="CICLO" data-alineacion="centro" style="text-align: center">Ciclo
                                        </th>
                                        <th data-tipo="string" data-campo="CURSO" data-alineacion="centro" style="text-align: center">Curso
                                        </th>
                                        <th data-tipo="string" data-campo="NOMBRE" data-alineacion="left">Nombre</th>
                                        <th data-tipo="string" data-campo="UMAS" data-alineacion="centro" style="text-align: center">CAs
                                        </th>
                                        <th data-tipo="string" data-campo="TIPOASIG" data-alineacion="centro" style="text-align: center">AS
                                        </th>
                                        <th data-tipo="string" data-campo="SECCION" data-alineacion="centro" style="text-align: center">Sección
                                        </th>
                                        <th data-tipo="string" data-campo="FECHAASIG" data-alineacion="centro" style="text-align: center">Fec. Asig.
                                        </th>
                                        <th data-tipo="string" data-campo="FECHARETIRO" data-alineacion="centro" style="text-align: center">Fec. Retiro</th>
                                        <th data-tipo="string" data-campo="HOJACAMBIO" data-alineacion="centro" style="text-align: center">Solicitud</th>
                                        <th data-tipo="string" data-campo="CODSTATUS" data-alineacion="centro" style="text-align: center">Status</th>
                                        <th data-tipo="string" data-campo="STATUSCURSO" data-alineacion="centro" style="text-align: center">Desc Status</th>
                                    </tr>
                                </thead>
                                <tbody style="font-size: 11px">
                                </tbody>
                            </table>
                            <div class="col-md-2 hidden">
                                <div class="pagination pagination-centered hidden" style="display: block;">
                                    <ul data-tabla="gvCursos" data-cantidad="100" data-grupo="1">
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hidden">
            <rsweb:ReportViewer ID="rvCuenta" runat="server" Height="1000px"
                Width="1000px">
            </rsweb:ReportViewer>
        </div>



        <!-- Modal -->

        <div id="myModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true">


            <%-- Componentes del tab --%>


            <ul id="tab" class="nav nav-list">
                <li class="active" style="display: none"><a id="first" href="#firstTab" data-toggle="tab"></a></li>
                <li style="display: none"><a id="second" href="#secondTab" data-toggle="tab"></a></li>
            </ul>

            <div class="tabbable">
                <div class="tab-content">
                    <%-- Tab de exoneracion --%>
                    <div class="tab-pane fade active in" id="firstTab">
                        <div class="modal-dialog modal-lg">
                            <div class="modal-content">
                                <div class="modal-header text-center text-info">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true" style="text-align: center"><span class="glyphicon glyphicon-remove text-danger"></span></button>
                                    <h3>Exoneración  de Pagos</h3>

                                </div>
                                <div class="modal-body" id="myModalBody">
                                    <br />

                                    <div class="col-md-12">

                                        <div class="form-search pull-right" data-tabla="gvExoneracion" id="search3">
                                            <input type="text" class="search-query form-control input-sm hidden" placeholder="Buscar" />
                                        </div>

                                        <div class="panel panel-info">
                                            <div class="panel-heading" style="text-align: center"><strong>Cargos del Alumno que se pueden Exonerar</strong></div>
                                            <table class="table table-striped table-bordered table-hover tabla" data-orden="true" data-filtro="true" data-fuente="gvExoneracion"
                                                id="gvExoneracion">
                                                <thead>
                                                    <tr style="font-size: 12px">
                                                        <th data-tipo="string" data-campo="CENTRO" class="hidden"></th>
                                                        <th data-tipo="string" data-campo="CODMOVTO" data-alineacion="centro" style="text-align: center">Cod.
                                                        </th>
                                                        <th data-tipo="string" data-campo="MOVIMIENTO" data-alineacion="izquierda" style="text-align: center">Descripción
                                                        </th>
                                                        <th data-tipo="string" data-campo="CURSO" data-alineacion="centro" style="text-align: center">Curso
                                                        </th>
                                                        <th data-tipo="string" data-campo="NOMBRE" data-alineacion="izquierda" style="text-align: center">Nombre
                                                        </th>
                                                        <th data-tipo="datetime" data-formato="dd/MM/yyyy" data-campo="FECHA" data-alineacion="centro" style="text-align: center">Fecha
                                                        </th>
                                                        <th data-tipo="string" data-campo="SALDO" data-alineacion="centro" style="text-align: center">Saldo
                                                        </th>

                                                        <th data-tipo="html" data-campo="MONTO" data-alineacion="centro" style="text-align: center; width: 15%">Monto
                                                        </th>
                                                        <th data-tipo="checkbox" data-campo="SELECCION" data-alineacion="centro" style="text-align: center"></th>

                                                    </tr>
                                                </thead>
                                                <tbody class="grid" style="font-size: 11px;">
                                                </tbody>
                                            </table>
                                        </div>


                                        <div class="pagination hidden">
                                            <ul id="Ul3" data-tabla="gvExoneracion" class="pagination pagination-centered" data-cantidad="500" data-grupo="10">
                                            </ul>
                                        </div>


                                    </div>

                                    <div class="row">

                                        <div class="col-md-3 text-right">
                                            <b>Solicitud de trámite:</b>
                                        </div>
                                        <div class="col-md-3">
                                            <input type="text" id="cboExoneracion" style="width: 100%; text-align: center" />
                                        </div>

                                        <div class="col-md-1">
                                            <b>Razón:</b>
                                        </div>
                                        <div class="col-md-4">
                                            <input type="text" id="txtAreaExoneracion" maxlength="35" placeholder="Ingrese la razón de la exoneración." class="form-control input-sm" style="width: 100%;" />
                                        </div>

                                    </div>

                                    <br />

                                    <div class="row" style="text-align: center">
                                        <div class="col-md-12" style="text-align: center">
                                            <div class="col-md-12">
                                                <div class="btn-group" style="text-align: center">
                                                    <button class="btn btn-info" id="grabarExoneracion" type="button">Realizar Exoneración&nbsp;&nbsp;<span class="glyphicon glyphicon-floppy-save"></span></button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <br />

                                    <div class="row">
                                        <div class="col-md-12 text-center">
                                            <div id="dvAlertaInfo" class="alert alert-warning alert-dismissible" role="alert">
                                                <button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                                                <strong>Nota:</strong> Los montos de los conceptos que aparecen, son los que al alumno le falta para completar el pago de dicho concepto. 
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-12">
                                            <div id="dvAlertaOk" class="alert alert-success alert-dismissable" style="text-align: center; display: none">
                                            </div>
                                            <div id="dvAlerta" class="alert alert-danger alert-dismissable" style="text-align: center; display: none">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <div class="pull-right">
                                                <div class="btn-group">
                                                    <button id="btnFraccionar" class="btn btn-default" type="button">Fraccionamiento <span class="glyphicon glyphicon-arrow-right"></span></button>
                                                </div>
                                                <div class="btn-group">
                                                    <button class="btn btn-danger" id="cancelar" data-dismiss="modal" aria-hidden="true" type="button">Cerrar <span class="glyphicon glyphicon-remove"></span></button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <%-- Tab de fraccionamiento --%>
                    <div class="tab-pane fade in" id="secondTab">
                        <div class="modal-dialog modal-lg">
                            <div class="modal-content">
                                <div class="modal-header text-center text-info">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true" style="text-align: center"><span class="glyphicon glyphicon-remove text-danger"></span></button>
                                    <h3>Fraccionamiento de Pagos</h3>

                                </div>
                                <div class="modal-body">
                                    <br />

                                    <div class="col-md-12">
                                        <div class="form-search pull-right" data-tabla="gvFraccionamiento" id="search2">
                                            <input type="text" class="search-query form-control input-sm hidden" placeholder="Buscar" />
                                        </div>

                                        <div class="panel panel-info">
                                            <div class="panel-heading" style="text-align: center"><strong>Cargos del Alumno que se pueden Fraccionar</strong></div>
                                            <table class="table table-striped table-bordered table-hover tabla" data-orden="true" data-filtro="true" data-fuente="gvFraccionamiento"
                                                id="gvFraccionamiento">
                                                <thead>
                                                    <tr style="font-size: 12px">
                                                        <th data-tipo="string" data-campo="CENTRO" class="hidden"></th>
                                                        <th data-tipo="string" data-campo="CODMOVTO" data-alineacion="centro" style="text-align: center">Cod.
                                                        </th>
                                                        <th data-tipo="string" data-campo="MOVIMIENTO" data-alineacion="izquierda" style="text-align: center">Descripción
                                                        </th>
                                                        <th data-tipo="string" data-campo="CURSO" data-alineacion="centro" style="text-align: center">Curso
                                                        </th>
                                                        <th data-tipo="string" data-campo="NOMBRE" data-alineacion="izquierda" style="text-align: center">Nombre
                                                        </th>
                                                        <th data-tipo="datetime" data-formato="dd/MM/yyyy" data-campo="FECHA" data-alineacion="centro" style="text-align: center">Fecha
                                                        </th>
                                                        <th data-tipo="string" data-campo="SALDO" data-alineacion="centro" style="text-align: center">Saldo
                                                        </th>

                                                        <th data-tipo="html" data-campo="MONTO" data-alineacion="centro" style="text-align: center; width: 15%">Monto
                                                        </th>
                                                        <th data-tipo="html" data-campo="PAGOS" data-alineacion="centro" style="text-align: center; width: 7%">Pagos
                                                        </th>
                                                        <th data-tipo="html" data-campo="INICIO" data-alineacion="centro" style="text-align: center; width: 7%">Inicio
                                                        </th>
                                                        <th data-tipo="checkbox" data-campo="SELECCION" data-alineacion="centro" style="text-align: center"></th>
                                                    </tr>
                                                </thead>
                                                <tbody class="grid" style="font-size: 11px;">
                                                </tbody>
                                            </table>
                                        </div>


                                        <div class="pagination hidden">
                                            <ul id="Ul2" data-tabla="gvFraccionamiento" class="pagination pagination-centered" data-cantidad="500" data-grupo="10">
                                            </ul>
                                        </div>


                                    </div>

                                    <div class="row">

                                        <div class="col-md-3 text-right">
                                            <b>Solicitud de trámite:</b>
                                        </div>
                                        <div class="col-md-3">
                                            <input type="text" id="cboFraccionamiento" style="width: 100%; text-align: center" />
                                        </div>

                                        <div class="col-md-1">
                                            <b>Razón:</b>
                                        </div>
                                        <div class="col-md-4">
                                            <input type="text" id="txtAreaFraccionamiento" maxlength="35" placeholder="Ingrese la razón del Fraccionamiento." class="form-control input-sm" style="width: 100%;" />

                                        </div>

                                    </div>

                                    <br />

                                    <div class="row" style="text-align: center">
                                        <div class="col-md-12" style="text-align: center">
                                            <div class="col-md-12">
                                                <div class="btn-group" style="text-align: center">
                                                    <button class="btn btn-info" id="grabarFraccionamiento" type="button">Realizar Fraccionamiento&nbsp;&nbsp;<span class="glyphicon glyphicon-floppy-save"></span></button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <br />

                                    <div class="row">
                                        <div class="col-md-12 text-center">
                                            <div id="dvAlertaInfof" class="alert alert-warning alert-dismissible" role="alert">
                                                <button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                                                <strong>Nota:</strong> Los montos de los conceptos que aparecen, son los que al alumno le falta para completar el pago de dicho concepto. 
                                            </div>
                                        </div>
                                    </div>


                                    <div class="row">
                                        <div class="col-md-12">
                                            <div id="dvAlertaOkf" class="alert alert-success alert-dismissable" style="text-align: center; display: none">
                                            </div>
                                            <div id="dvAlertaf" class="alert alert-danger alert-dismissable" style="text-align: center; display: none">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <div class="pull-right">
                                                <div class="btn-group">
                                                    <button id="btnExonerar" class="btn btn-default" type="button">Exoneración <span class="glyphicon glyphicon-arrow-left"></span></button>
                                                </div>
                                                <div class="btn-group">
                                                    <button class="btn btn-danger" data-dismiss="modal" aria-hidden="true" type="button">Cerrar <span class="glyphicon glyphicon-remove"></span></button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>

        </div>

    </form>
    <uc1:Script3 runat="server" ID="Script3" />
    <script src="/js/tabla3.js"></script>
    <script src="/js/select2.js"></script>
    <script type="text/javascript">



        //función que Obtiene los parametros enviados de la url
        function getURLParameter(name) {
            return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [, ""])[1].replace(/\+/g, '%20')) || null;
        }

        var carne = getURLParameter("carnet");
        var carrera = getURLParameter("carrera");
        var pensum;

        //pensum = document.getElementById("lblPensum").innerHTML;


        var strong = $("<strong>");
        var cerrar = $("<button type='button' class='close' aria-hidden='true'>&times;</button>");


        // Funciones de manejo de navegacion en tabs

        function nextTab(elem) {

            $(elem + ' li.active')
              .next()
              .find('a[data-toggle="tab"]')
              .click();
        }

        function prevTab(elem) {
            $(elem + ' li.active')
              .prev()
              .find('a[data-toggle="tab"]')
              .click();
        }

        function onlyNumbers(evt) {
            var keyPressed = (evt.which) ? evt.which : event.keyCode;
            return !(keyPressed > 31 && (keyPressed < 46 || keyPressed > 57));

        }


        $(document).on("click", "#gvExoneracion > tbody > tr > td > input.info", function () {

            if ($(this).prop("checked")) {

                $(this).attr('checked', 'checked');
            }
            else {

                $(this).removeAttr('checked');
            }
        });


        $(document).on("click", "#gvFraccionamiento > tbody > tr > td > input.info", function () {

            if ($(this).prop("checked")) {

                $(this).attr('checked', 'checked');
            }
            else {

                $(this).removeAttr('checked');
            }
        });

        $(document).on("keyup", "#gvExoneracion > tbody > tr > td > .texto", function () {

            var valor;
            valor = $(this).val();

            $(this).removeAttr('value');

            $(this).attr('value', valor);

        });


        $(document).on("keyup", "#gvFraccionamiento > tbody > tr > td > .texto", function () {

            var valor;
            valor = $(this).val();

            $(this).removeAttr('value');

            $(this).attr('value', valor);

        });


        var centro, codigo, curso, fecha, saldo, monto, solicitud;

        var error, codigos, flag;

        $("#grabarExoneracion").on("click", function () {

            if ($("#txtAreaExoneracion").val() != "") {

                error = false;
                codigos = "";
                flag = 0;

                for (i = 0; i < $('#gvExoneracion tr').length - 1; i++) {
                    var fila = $("#gvExoneracion > tbody").children(':eq(' + i + ')');

                    if ($(fila.children(':eq(8)').html()).prop("checked")) {

                        flag = flag + 1;

                        centro = fila.children(':eq(0)').html();
                        codigo = fila.children(':eq(1)').html();
                        curso = fila.children(':eq(3)').html();
                        fecha = fila.children(':eq(5)').html();
                        saldo = fila.children(':eq(6)').html();
                        monto = $(fila.children(':eq(7)').html()).val();

                        if (monto == "") {

                            var r = confirm("Si no se ingresa el monto del codigo " + codigo + " se exonerara el monto Total.");
                            if (r == true) {

                                monto = saldo;

                            } else {

                                continue;

                            }

                        }


                        var params = JSON.stringify({ observaciones: $("#txtAreaExoneracion").val(), centro: centro, solicitud: $("#cboExoneracion").val(), monto: monto, curso: curso, codigo: codigo, carrera: carrera, carnet: carne });

                        $.ajax({
                            type: "POST",
                            data: params,
                            async: false,
                            url: "cuenta.aspx/exonerar",
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (msg) {

                                if (msg.d == "Esta hoja de cambio ya esta ingresada") {

                                    $("#dvAlertaInfo").hide();
                                    $("#dvAlertaOk").hide();
                                    strong.text("La solicitud " + $("#cboExoneracion").val() + " Ya fue utilizada en la exoneración del concepto " + codigo + " por favor verificar.");

                                    $("#dvAlerta").append(cerrar);
                                    $("#dvAlerta").append(strong);

                                    $("#dvAlerta > button").attr("onclick", "$('#dvAlerta').hide('slow')");
                                    $("#dvAlerta").show('slow');

                                    error = true;

                                }
                                else if (msg.d == "0") {

                                    codigos = codigos + " " + codigo;

                                }

                            },
                            error: function (msg) {


                                $("#dvAlertaInfo").hide();
                                $("#dvAlertaOk").hide();
                                strong.text("Ha ocurrido un error al querer Exonerar el Concepto.");

                                $("#dvAlerta").append(cerrar);
                                $("#dvAlerta").append(strong);

                                $("#dvAlerta > button").attr("onclick", "$('#dvAlerta').hide('slow')");
                                $("#dvAlerta").show('slow');

                                error = true;

                            }


                        });

                    }


                    if (error == true) {
                        break;
                    }
                }

                if (flag == 0) {


                    $("#dvAlertaInfo").hide();
                    $("#dvAlertaOk").hide();
                    strong.text("Por favor seleccionar los conceptos a los que se les aplicara una exoneración.");

                    $("#dvAlerta").append(cerrar);
                    $("#dvAlerta").append(strong);

                    $("#dvAlerta > button").attr("onclick", "$('#dvAlerta').hide('slow')");
                    $("#dvAlerta").show('slow');

                    error = true;
                }

                if (error == false) {

                    mensajeOK();
                }
            }
            else {

                $("#dvAlertaInfo").hide();
                $("#dvAlertaOk").hide();
                strong.text("Por favor ingresar la razón por la que se realizara la exoneración.");

                $("#dvAlerta").append(cerrar);
                $("#dvAlerta").append(strong);

                $("#dvAlerta > button").attr("onclick", "$('#dvAlerta').hide('slow')");
                $("#dvAlerta").show('slow');

            }
        });

        var fracc, inicio;

        $("#grabarFraccionamiento").on("click", function () {

            if ($("#txtAreaFraccionamiento").val() != "") {

                error = false;
                codigos = "";
                flag = 0;

                for (i = 0; i < $('#gvFraccionamiento tr').length - 1; i++) {
                    var fila = $("#gvFraccionamiento > tbody").children(':eq(' + i + ')');

                    if ($(fila.children(':eq(10)').html()).prop("checked")) {

                        flag = flag + 1;

                        centro = fila.children(':eq(0)').html();
                        codigo = fila.children(':eq(1)').html();
                        curso = fila.children(':eq(3)').html();
                        fecha = fila.children(':eq(5)').html();
                        saldo = fila.children(':eq(6)').html();
                        monto = $(fila.children(':eq(7)').html()).val();
                        fracc = $(fila.children(':eq(8)').html()).val();
                        inicio = $(fila.children(':eq(9)').html()).val();

                        if (codigo == "MT") {

                            if (monto == "") {

                                var r = confirm("Si no se ingresa el monto del codigo " + codigo + " se fraccionara el monto Total.");
                                if (r == true) {

                                    monto = saldo;

                                } else {

                                    continue;

                                }

                            }


                            var params = JSON.stringify({ observaciones: $("#txtAreaFraccionamiento").val(), centro: centro, solicitud: $("#cboFraccionamiento").val(), monto: monto, curso: curso, codigo: codigo, carrera: carrera, carnet: carne, fraccionamiento: fracc, inicio: inicio });

                            $.ajax({
                                type: "POST",
                                data: params,
                                async: false,
                                url: "cuenta.aspx/tr_fracc",
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",
                                success: function (msg) {

                                    if (msg.d == "Esta hoja de cambio ya esta ingresada") {

                                        $("#dvAlertaInfof").hide();
                                        $("#dvAlertaOkf").hide();
                                        strong.text("La solicitud " + $("#cboFraccionamiento").val() + " Ya fue utilizada en la exoneración del concepto " + codigo + " por favor verificar.");

                                        $("#dvAlertaf").append(cerrar);
                                        $("#dvAlertaf").append(strong);

                                        $("#dvAlertaf > button").attr("onclick", "$('#dvAlertaf').hide('slow')");
                                        $("#dvAlertaf").show('slow');

                                        error = true;

                                    }
                                    else if (msg.d == "0") {

                                        codigos = codigos + " " + codigo;

                                    }

                                },
                                error: function (msg) {


                                    $("#dvAlertaInfof").hide();
                                    $("#dvAlertaOkf").hide();
                                    strong.text("Ha ocurrido un error al querer Fraccionar el Concepto.");

                                    $("#dvAlertaf").append(cerrar);
                                    $("#dvAlertaf").append(strong);

                                    $("#dvAlertaf > button").attr("onclick", "$('#dvAlertaf').hide('slow')");
                                    $("#dvAlertaf").show('slow');

                                    error = true;

                                }


                            });
                        }
                        else {

                            $("#dvAlertaInfof").hide();
                            $("#dvAlertaOkf").hide();
                            strong.text("No es posible fraccionar el Concepto " + codigo +".");

                            $("#dvAlertaf").append(cerrar);
                            $("#dvAlertaf").append(strong);

                            $("#dvAlertaf > button").attr("onclick", "$('#dvAlertaf').hide('slow')");
                            $("#dvAlertaf").show('slow');

                            break;
                            error = true;
                        }

                    }


                    if (error == true) {
                        break;
                    }
                }

                if (flag == 0) {


                    $("#dvAlertaInfof").hide();
                    $("#dvAlertaOkf").hide();
                    strong.text("Por favor seleccionar los conceptos a los que se les aplicara el Fraccionamiento.");

                    $("#dvAlertaf").append(cerrar);
                    $("#dvAlertaf").append(strong);

                    $("#dvAlertaf > button").attr("onclick", "$('#dvAlertaf').hide('slow')");
                    $("#dvAlertaf").show('slow');

                    error = true;
                }

                if (error == false) {

                    mensajeOK2();
                }
            }
            else {

                $("#dvAlertaInfof").hide();
                $("#dvAlertaOkf").hide();
                strong.text("Por favor ingresar la razón por la que se realizara el Fraccionamiento.");

                $("#dvAlertaf").append(cerrar);
                $("#dvAlertaf").append(strong);

                $("#dvAlertaf > button").attr("onclick", "$('#dvAlertaf').hide('slow')");
                $("#dvAlertaf").show('slow');

            }
        });

        function mensajeOK() {

            $("#txtAreaExoneracion").val("");

            $("#gvExoneracion").tabla("Cuenta.aspx/llenarExoneracion", { carnet: carne, carrera: carrera }, false);

            cargar();

            $("#dvAlertaInfo").hide();
            $("#dvAlerta").hide();
            strong.text("La exoneración de los conceptos fue realizada con éxito.");

            $("#dvAlertaOk").append(cerrar);
            $("#dvAlertaOk").append(strong);

            $("#dvAlertaOk > button").attr("onclick", "$('#dvAlertaOk').hide('slow')");
            $("#dvAlertaOk").show('slow');
        }

        function mensajeOK2() {

            $("#txtAreaFraccionamiento").val("");

            $("#gvFraccionamiento").tabla("Cuenta.aspx/llenarExoneracion", { carnet: carne, carrera: carrera }, false);

            cargar();

            $("#dvAlertaInfof").hide();
            $("#dvAlertaf").hide();
            strong.text("El fraccionamiento de los conceptos fue realizado con éxito.");

            $("#dvAlertaOkf").append(cerrar);
            $("#dvAlertaOkf").append(strong);

            $("#dvAlertaOkf > button").attr("onclick", "$('#dvAlertaOkf').hide('slow')");
            $("#dvAlertaOkf").show('slow');
        }

        $("#exoneracion").on("click", function () {

            solicitudExonerar();

            $("#dvAlertaInfo").show();
            $("#dvAlerta").hide();
            $("#dvAlertaOk").hide();

            $("#dvAlertaOk").hide();
            $("#dvAlerta").hide();


            $("#gvExoneracion").tabla("Cuenta.aspx/llenarExoneracion", { carnet: carne, carrera: carrera }, false);

            prevTab('#tab');

            $('#myModal').modal({
                keyboard: true,
                backdrop: 'static'
            })

        });


        $("#fraccionamiento").on("click", function () {

            solicitudFraccionamiento();

            $("#dvAlertaInfof").show();
            $("#dvAlertaOkf").hide();
            $("#dvAlertaf").hide();

            $("#gvFraccionamiento").tabla("Cuenta.aspx/llenarExoneracion", { carnet: carne, carrera: carrera }, false);

            nextTab('#tab');

            $('#myModal').modal({
                keyboard: true,
                backdrop: 'static'
            })

        });

        $("#btnFraccionar").on("click", function () {

            solicitudFraccionamiento();

            $("#dvAlertaInfof").show();
            $("#dvAlertaf").hide();
            $("#dvAlertaOkf").hide();

            $("#gvFraccionamiento").tabla("Cuenta.aspx/llenarExoneracion", { carnet: carne, carrera: carrera }, false);
            nextTab('#tab');

        });

        $("#btnExonerar").on("click", function () {

            solicitudExonerar();

            $("#dvAlertaInfo").show();
            $("#dvAlerta").hide();
            $("#dvAlertaOk").hide();

            $("#gvExoneracion").tabla("Cuenta.aspx/llenarExoneracion", { carnet: carne, carrera: carrera }, false);
            prevTab('#tab');

        });



        function solicitudExonerar() {

            var datosj = new Array();
            var valor;

            $("#txtAreaExoneracion").val("");

            var params = JSON.stringify({ paso: "6", carnet: carne, carrera: carrera, tramite: "28" });

            $.ajax({
                type: "POST",
                data: params,
                async: false,
                url: "cuenta.aspx/solicitud",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    datos = $.parseJSON(msg.d);

                    valor = String(datos[0].SOLICITUD)

                    for (i = 0; i < datos.length; i++) {

                        datosj[i] = { id: String(datos[i].SOLICITUD), text: String(datos[i].SOLICITUD) };
                    }

                    if (valor == "Sin Solicitudes") {
                        $("#grabarExoneracion").prop("disabled", true);
                    }
                    else {
                        $("#grabarExoneracion").prop("disabled", false);
                    }


                    $("#cboExoneracion").select2({
                        data: datosj
                    });

                    $("#cboExoneracion").select2("val", valor);

                },
                error: function (msg) {

                    $("#dvAlertaOk").hide();
                    strong.text("Ha ocurrido un error al querer cargar las solicitudes de Exoneración .");

                    $("#dvAlerta").append(cerrar);
                    $("#dvAlerta").append(strong);

                    $("#dvAlerta > button").attr("onclick", "$('#dvAlerta').hide()");
                    $("#dvAlerta").show();

                }

            });
        }


        function solicitudFraccionamiento() {

            var datosj = new Array();
            var valor;

            var params = JSON.stringify({ carnet: carne, carrera: carrera, tramite: "33" });

            $.ajax({
                type: "POST",
                data: params,
                async: false,
                url: "cuenta.aspx/solicitud2",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    datos = $.parseJSON(msg.d);

                    valor = String(datos[0].SOLICITUD)

                    for (i = 0; i < datos.length; i++) {

                        datosj[i] = { id: String(datos[i].SOLICITUD), text: String(datos[i].SOLICITUD) };
                    }

                    if (valor == "Sin Solicitudes") {
                        $("#grabarFraccionamiento").prop("disabled", true);
                    }
                    else {
                        $("#grabarFraccionamiento").prop("disabled", false);
                    }


                    $("#cboFraccionamiento").select2({
                        data: datosj
                    });

                    $("#cboFraccionamiento").select2("val", valor);

                },
                error: function (msg) {

                    $("#dvAlertaOk").hide();
                    strong.text("Ha ocurrido un error al querer cargar las solicitudes de Exoneración .");

                    $("#dvAlerta").append(cerrar);
                    $("#dvAlerta").append(strong);

                    $("#dvAlerta > button").attr("onclick", "$('#dvAlerta').hide()");
                    $("#dvAlerta").show();

                }

            });
        }


        cargar();

        function cargar() {

            if (carne != null && carrera != null) {

                //funcion que cambia de color cuando encuentre en la tabla detalles un RECIBO
                function cambioColor() {
                    var cont = 0;
                    while (($("#gvDetalles > tbody").children(":eq(" + cont + ")").html() != undefined)) {
                        if ($("#gvDetalles > tbody").children(":eq(" + cont + ")").children(":eq(2)").html() == "RECIBO") {
                            $("#gvDetalles > tbody").children(":eq(" + cont + ")").addClass("recibo");
                        }
                        cont++;
                    }
                }

                //Cambia la fila Total en la tabla Resumen
                function cambioColorTotal() {
                    var cont = 0;
                    while (($("#gvResumen > tbody").children(":eq(" + cont + ")").html() != undefined)) {
                        if ($("#gvResumen > tbody").children(":eq(" + cont + ")").children(":eq(2)").html() == "Total") {
                            $("#gvResumen > tbody").children(":eq(" + cont + ")").addClass("total");
                            totalpagar = $("#gvResumen > tbody").children(":eq(" + cont + ")").children(":eq(9)").html();
                            var total = totalpagar.toString();
                            total = total.substring(2, total.length);

                            if (parseFloat(total) > 0) {
                                $("#lblTotalPagar").text(totalpagar);
                            }
                            else {
                                $("#lblTotalPagar").text("Q.0.00");
                            }
                        }
                        cont++;
                    }
                }

                //Funcion que se utiliza para llenar cada Tabla.
                function llenar() {
                    $("#gvMultas").tabla("Cuenta.aspx/llenar_multas", { carrera: carrera, carne: carne }, false);
                    $("#gvResumen").tabla("Cuenta.aspx/llenar_resumen", { carrera: carrera, carne: carne }, false);
                    $("#gvDetalles").tabla("Cuenta.aspx/llenar_detalles", { carrera: carrera, carne: carne }, false);
                    $("#gvCursos").tabla("Cuenta.aspx/llenar_cursos", { carne: carne }, false);
                    cambioColor();
                    cambioColorTotal();
                }
                llenar();

                //Evento que sirve para visualizar algún recibo o trámite en la tabla de Detalles > columna Operacion.
                $(document).on("click", "#gvDetalles > tbody > tr > td > a", function () {
                    var tipo = $(this).parent().parent().children(":eq(2)").html();
                    if (tipo == "RECIBO") {
                        //- 23/05/2014 - Se agregó la variable correlativo ya que no existia.
                        var correlativo = $(this).parent().parent().children(":eq(14)").html();
                        var parametros = JSON.stringify({ recibo: correlativo, carne: carne, carrera: carrera });
                        var request = $.ajax({
                            type: "POST",
                            async: false,
                            url: "Cuenta.aspx/parametros",
                            data: parametros,
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                        });

                        request.done(function (msg) {
                            window.open('DatosRecibos.aspx', '_blank');
                        });

                        request.fail(function (msg) {
                            alert("La acción no se pudo realizar debido a que ocurrió un error interno");
                        });


                    }
                    else {
                        var correlativo = $(this).parent().parent().children(":eq(14)").html();

                        var request = $.ajax({
                            type: "POST",
                            async: false,
                            url: "Cuenta.aspx/Verificar_tramite",
                            data: JSON.stringify({ correlativo: correlativo }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json"
                        });

                        request.done(function (msg) {
                            var datos2 = $.parseJSON(msg.d);
                            var validar = datos2[0]["VALOR"];
                            if (validar == 1) {

                                var request_Tramite = $.ajax({
                                    type: "POST",
                                    async: false,
                                    url: "Cuenta.aspx/parametros_sol",
                                    data: JSON.stringify({ correlativo: correlativo }),
                                    contentType: "application/json; charset=utf-8",
                                    dataType: "json"
                                });

                                request_Tramite.done(function () {
                                    window.open('SolicutudDecideVista.aspx', '_blank');
                                });
                            }
                            else {
                                alert("No existe ninguna acción para este correlativo");
                            }
                        });
                    }
                });
            }
        }

    </script>
</body>
</html>
