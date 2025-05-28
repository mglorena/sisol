var nameurl;
var nname = "";
var flagType, datosRadMensual;
window.flagDomLoaded = false;

function initLoad() {
    try {
        $(".ventana").hide();
        $(".meses").hide();
        $("#divEscala").html("<img class='imgScala' src='images/Rescalaanual.svg'/>");
        flagType = "rad";
        $("#imgAnual").addClass("classOn");
        nameurl = "anual";
        window.flagDomLoaded = true;
        $("#imgInfo").addClass("classOn");
        $(".infoInfo").show();
        $("#txtLat").val(parseFloat(lat).toFixed(2));
        $("#txtLong").val(parseFloat(long).toFixed(2));

        goForData([lat, long, nameurl], [callback_goForData]);
    } catch (e) { }
}

function updateLabels(lat, long, altura) {
    try {
        $("#txtLat").val(parseFloat(lat).toFixed(2));
        $("#txtLong").val(parseFloat(long).toFixed(2));
        if (flagType == "rad") {
            $("#varlat").html(lat.toFixed(2));
            $("#varlong").html(long.toFixed(2));
            $("#varalt").html(altura);
        } else {
            $("#varlatTemp").html(lat.toFixed(2));
            $("#varlongTemp").html(long.toFixed(2));
            $("#varaltTemp").html(altura);
        }
    } catch (e) { }
}
$(document).ready(function (e) {
    try {
        $(".nav-tabs a").click(function (e) {
            e.preventDefault();
            $(this).tab('show');
        });
        $('#btnCalcular').click(function (e) {
            e.preventDefault();
            $("#divLoading").show();
            $("#divResFotoAll").hide();
            var datos = getDataForm();
            $("#divgrafFoto").show();
            goCalcularFoto([datos], [callback_goCalcularFoto]);
            $('.nav-tabs a[href="#resFoto"]').tab('show');
        })
        $('#btnCalcularTerm').click(function (e) {
            e.preventDefault();
            $("#divgrafTerm").show();
            $("#divLoadingT").show();
            $("#divResTermAll").hide();
            getFormTerm();
            $('.nav-tabs a[href="#resTerm"]').tab('show');
        })
        initLoad();
        $("#imgBook").click(function (e) {
            e.preventDefault();
            hideVentanas();
            $("#imgBook").addClass("classOn");
            $(".infoBook").show();
            nname = "";
            nameurl = "anual";
            flagType = "rad";
            LoadGrafFoto();
            $("#divEscala").html("<img class='imgScala' src='images/Rescalaanual.svg'/>");
            $("#imgAnual").addClass("classOn");
            $(".meses").hide();
            SetMap();
        });
        $("#imgInfo").click(function (e) {
            e.preventDefault();
            hideVentanas();
            $("#imgInfo").addClass("classOn");
            $(".infoInfo").show();
            $("#divEscala").html("<img class='imgScala' src='images/Rescalaanual.svg'/>");
            $("#title_calendar").html("RADIACI" + String.fromCharCode(211) + "N SOLAR ANUAL");
            $("#imgAnual").addClass("classOn");
        });
        $("#imgRad").click(function (e) {
            e.preventDefault();
            hideVentanas();
            clearCalendar();
            $("#title_calendar").html("RADIACI" + String.fromCharCode(211) + "N SOLAR ANUAL");
            $("#imgAnual").addClass("classOn");
            $(".meses").hide();
            $("#imgRad").addClass("classOn");
            $(".infoRad").show();
            $("#divEscala").html("<img class='imgScala' src='images/Rescalaanual.svg'/>");
            updateLabels(lat, long, altura);
            nname = "";
            nameurl = "anual";
            flagType = "rad";
            LoadGrafRad();
            SetMap();
        });
        $("#imgTemp").click(function (e) {
            e.preventDefault();
            hideVentanas();
            clearCalendar();
            $("#imgTemp").addClass("classOn");
            $(".infoTemp").show();
            $("#divEscala").html("<img class='imgScala' src='images/Tescalaanual.svg'/>");
            $(".meses").hide();
            $("#imgAnual").addClass("classOn");
            updateLabels(lat, long, altura);
            $("#title_calendar").html("TEMPERATURA ANUAL");
            nname = "";
            nameurl = "tanual";
            flagType = "temp";
            SetMap();
            LoadGrafTemp();
        });
        $("#imgSolar").click(function (e) {
            $("#divgrafFoto").hide();
            e.preventDefault();
            hideVentanas();
            $("#imgSolar").addClass("classOn");
            $(".infoFoto").show();
            nname = "";
            nameurl = "anual";
            flagType = "rad";
            LoadGrafFoto();
            $("#divEscala").html("<img class='imgScala' src='images/Rescalaanual.svg'/>");
            $("#imgAnual").addClass("classOn");
            $(".meses").hide();
            resetReportes();
            SetMap();
        });
        $("#imgTerm").click(function (e) {
            e.preventDefault();
            hideVentanas();
            $("#imgTerm").addClass("classOn");
            $(".infoTerm").show();
            $("#divEscala").html("<img class='imgScala' src='images/Rescalaanual.svg'/>");
            $("#imgAnual").addClass("classOn");
            $(".meses").hide();
            resetReportes();
            LoadGrafTerm();
        });
        $("#imgDiario").click(function (e) {
            e.preventDefault();
            nname = "d";
            clearCalendar();
            if (flagType == "rad") {
                $("#title_calendar").html("RADIACI" + String.fromCharCode(211) + "N SOLAR DIARIA");
                $("#imgDiario").addClass("classOn");
                $(".meses").show();
                $("#divEscala").html("<img src='images/Rescaladia.svg' class='imgScala' />");
                changeMap(null, "enero");
            } else {
                $(".meses").hide();
                flagType = "temp";
                $("#title_calendar").html("");
            }
        });
        $("#imgMensual").click(function (e) {
            e.preventDefault();
            nname = "m";
            clearCalendar();
            if (flagType == "rad") {
                $("#title_calendar").html("RADIACI" + String.fromCharCode(211) + "N SOLAR  MENSUAL");
                $("#imgMensual").addClass("classOn");
                $(".meses").show();
                $("#divEscala").html("<img src='images/Rescalames.svg' class='imgScala' />");
            } else {
                $("#title_calendar").html("TEMPERATURA MEDIA MENSUAL");
                $("#imgMensual").addClass("classOn");
                $(".meses").show();
                $("#divEscala").html("<img src='images/Tescalames.svg' class='imgScala' />");
                nname += "t";
            }
            changeMap(null, "enero");
        });
        $("#imgAnual").click(function (e) {
            e.preventDefault();
            nname = "";
            clearCalendar();
            if (flagType === "rad") {
                $("#title_calendar").html("RADIACI" + String.fromCharCode(211) + "N SOLAR ANUAL");
                $("#divEscala").html("<img src='images/Rescalaanual.svg' class='imgScala' />");
                changeMap(null, "anual");
                $("#imgAnual").addClass("classOn");
                $(".meses").hide();
            } else {
                $("#title_calendar").html("TEMPERATURA MEDIA ANUAL");
                $("#divEscala").html("<img src='images/Tescalaanual.svg' class='imgScala' />");
                changeMap(null, "tanual");
                $("#imgAnual").addClass("classOn");
                $(".meses").hide();
            }
        });
    } catch (e) { }
});

function clearCalendar() {
    try {
        $(".meses").hide();
        $(".meses").parent().find('div').removeAttr(" style ");
        $(".toolCal").each(function () {
            $(this).removeClass("classOn");
        });
    } catch (e) { }
}

function hideVentanas() {
    try {
        $(".ventana").hide();
        $(".meses").hide();
        $(".iconV").each(function () {
            $(this).removeClass("classOn");
        });
    } catch (e) { }
}
var datos;


var agrafTemp;

/*function getMonthFromString(mon){ 

    var d = Date.parse(mon + "1, 2012"); 
    if(!isNaN(d)){ 
     return new Date(d).getMonth() + 1; 
    } 
    return -1; 
}*/
function getMonthFromString(mon) {

    // var d = Date.parse(mon + "1, 2012"); 
    if (mon == "enero") { return 1; }
    if (mon == "febrero") { return 2; }
    if (mon == "marzo") { return 3; }
    if (mon == "abril") { return 4; }
    if (mon == "mayo") { return 5; }
    if (mon == "junio") { return 6; }
    if (mon == "julio") { return 7; }
    if (mon == "agosto") { return 8; }
    if (mon == "septiembre") { return 9; }
    if (mon == "octubre") { return 10; }
    if (mon == "noviembre") { return 11; }
    if (mon == "diciembre") { return 12; }
    /*if(!isNaN(d)){ 
     return new Date(d).getMonth() + 1; 
    } 
    return -1; */

}


var labelMeses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
var grafRad, grafTemp, grafFoto, grafTerm;

function updateDataSetGraf(chart, data1, data2, xlabel, ylabel) {
    try {
        chart.clear();
        chart.data.datasets[0].data = data1;
        if (chart.data.datasets.length > 1) {
            chart.data.datasets[1].data = data2;
        }
        if (xlabel) {
            chart.data.labels = xlabel;
        }
        if (ylabel) {
            chart.data.datasets[0].label = ylabel[0];
            chart.data.datasets[1].label = ylabel[1];
        }
        chart.update();
    } catch (ex) {
        humane.error("Exception updateDataSetGraf " + ex.menssage + "-" + ex.error);
    }
}

function LoadGrafTerm() {
    try {
        var ctxTerm = $("#grafTerm");
        grafTerm = new Chart(ctxTerm, {
            type: 'bar',
            data: {
                datasets: [{
                    label: 'Consumo',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    borderColor: "rgb(154, 66, 63)",
                    backgroundColor: "rgba(154, 66, 63, 0.2)"
                }, {
                    label: "Ahorro",
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    // Changes this dataset to become a line
                    type: 'line'
                }],
                labels: labelMeses
            }
        });
    } catch (e) { }
}

function LoadGrafRad() {
    try {
        var ctxR = $("#grafRad");
        grafRad = new Chart(ctxR, {
            type: 'bar',
            data: {
                datasets: [{
                    label: "kWh/m" + String.fromCharCode(178),
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    borderColor: "rgba(249,180,8,0.2)",
                    backgroundColor: "rgba(249,180,8,0.5)"
                }],
                labels: labelMeses
            }
        });
    } catch (e) { }
}

function LoadGrafTemp() {
    try {
        var ctxT = $("#grafT");
        grafTemp = new Chart(ctxT, {
            type: 'bar',
            data: {
                datasets: [{
                    label: "(" + String.fromCharCode(176) + "C grados Celsius)",
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    borderColor: "rgba(75, 192, 192, 1)",
                    backgroundColor: "rgba(75, 192, 192, 0.2)"
                }],
                labels: labelMeses
            }
        });
    } catch (ex) {
        humane.error("Exception LoadGrafTemp " + ex.menssage + "-" + ex.error);
    }
}

function LoadGrafFoto() {
    try {
        var ctxF = $("#grafFoto");
        grafFoto = new Chart(ctxF, {
            type: 'bar',
            data: {
                datasets: [{
                    label: 'Consumo (kWh)',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    borderColor: "rgb(154, 66, 63)",
                    backgroundColor: "rgba(154, 66, 63, 0.2)"
                }, {
                    label: "Generaci" + String.fromCharCode(243) + "n (kWh)",
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    // Changes this dataset to become a line
                    type: 'line'
                }],
                labels: labelMeses
            }
        });
    } catch (e) { }
}
var conexionRed = 1;

function disabledMeses(red) {
    try {
        conexionRed = red;
        if (red === 0) {
            $(".iMes").css("color", "#B6B6B6");
            $(".iMes").each(function () {
                //To disable 
                $(this).val(0);
                $(this).attr('disabled', 'disabled');
                $(".tipUser").hide();
            });
        } else {
            $(".iMes").removeAttr(" style ");
            //To enable 
            $('.iMes').removeAttr('disabled');
            // OR you can set attr to "" 
            $("#txtENE").val(168);
            $("#txtFEB").val(139);
            $("#txtMAR").val(228);
            $("#txtABR").val(148);
            $("#txtMAY").val(217);
            $("#txtJUN").val(331);
            $("#txtJUL").val(250);
            $("#txtAGO").val(228);
            $("#txtSEP").val(197);
            $("#txtOCT").val(174);
            $("#txtNOV").val(169);
            $("#txtDIC").val(142);
            if (hasR == 1) $(".tipUser").show();
        }
    } catch (e) { }
}
var tipUser, hasR = 0,
    hasRT = 0;

function hasReporte(v, e) {
    try {


        if (conexionRed == 1) {
            if (v === 1) {
                $(".tipUser").show();
                hasR = 1;
            } else {
                $(".tipUser").hide();
                hasR = 0;
            }
            $(".rReporte").prop('checked', false);
            $("#" + e.id).prop('checked', true);
        } else {
            $(".tipUser").hide();
        }
    } catch (e) { }
}

function disabledBloque(b, t) {
    try {

        $(".dBloque").hide();
        $("#" + b).show();
        tipoTerm = t;
    } catch (e) { }
}

function resetReportes() {
    try {
        $(".reporteF").hide();
        $(".rReporte").prop('checked', false);
        $("#rRTNo").prop("checked", true);
        $(".rFGasNat").hide();
        $(".repFGasEnv").hide();
        $(".repFinan").hide();
        $("#rReNo").prop("checked", true);
        $(".repFElectri").hide();
        $("#rPSanNo").prop("checked", true);
        $(".tipUser").hide();
        $("#rRNo").prop("checked", true);
    } catch (e) { }
}

function hasReporteT(v, e) {
    try {
        if (v === 1) {
            hasRT = 1;
        } else {
            hasRT = 0;
        }
        $(".rReporteT").prop('checked', false);
        $("#" + e.id).prop('checked', true);
    } catch (e) { }
}

function hasCalFinan(v, e) {
    try {
        if (v === 1) {
            $(".repFinan").show();
            if (tipoTerm == 1) $(".repFGasNat").show();
            else {
                $(".repFGasNat").hide();
                if (tipoTerm == 2) {
                    $(".repFGasEnv").show();
                } else {
                    $(".repFGasEnv").hide();
                    if (tipoTerm == 3) {
                        $(".repFElectri").show();
                    } else {
                        $(".repFElectri").hide();
                    }
                }
            }
            hasRT = 1;
        } else {
            $(".repFinan").hide();
            $(".repFGasNat").hide();
            $(".repFGasEnv").hide();
            hasRT = 0;
        }
        $(".repFinan").prop('checked', false);
        $("#" + e.id).prop('checked', true);
    } catch (e) { }
}
/**************** TERMICO ********************/
var tipoTerm = "1";
var xLabelTerm, yLabelTerm, daConsTerm, daGrafTerm, tPeriodo;

function getFormTerm() {
    try {
        var datos;
        var perso = $("#txtFlia").val();
        //var tcolector = $("input[name=rColector]").val();
        var tcolector = $('input[name=rColector]:checked').val();
        try {
            lat = lat.toFixed(2);
            long = long.toFixed(2);
        } catch (e) { }
        var reporte = hasRT;
        var temperatura = agrafTemp;
        switch (tipoTerm) {
            case "1":
                var enefeb = $("#txtEneFeb").val();
                var marabr = $("#txtMarAbr").val();
                var mayjun = $("#txtMayJun").val();
                var julago = $("#txtJulAgo").val();
                var sepoct = $("#txtSepOct").val();
                var novdic = $("#txtNovDic").val();
                $("#titGrafTerm").html("Consumo y ahorro en m" + String.fromCharCode(179) + " equivalentes de gas natural");
                xLabelTerm = ['Ene-Feb', 'Mar-Abr', 'May-Jun', 'Jul-Ago', 'Sep-Oct', 'Nov-Dic'];
                yLabelTerm = ['Consumo (m' + String.fromCharCode(179) + ')', "Ahorro (m" + String.fromCharCode(179) + " eq. gas)"];
                daConsTerm = [enefeb, marabr, mayjun, julago, sepoct, novdic];
                tPeriodo = "Bimestres";
                datos = new Array(lat, long, altura, perso, tcolector, reporte, datosRadMensual, temperatura, enefeb, marabr, mayjun, julago, sepoct, novdic);

                goCalTermGasNat([datos], [callback_goCalcularFormTerm]);
                break;
            case "2":
                var garrafa = $("#txtGarrafa").val();
                var gameses = $("#txtGaMeses").val();
                var garmeses = garrafa / gameses;
                datos = new Array(lat, long, altura, perso, tcolector, reporte, datosRadMensual, temperatura, garmeses);
                $("#titGrafTerm").html("Consumo y ahorro en kg equivalentes de gas envasado");
                goCalTermGasEnv([datos], [callback_goCalcularFormTerm]);
                xLabelTerm = labelMeses;
                yLabelTerm = ['Consumo (kg)', "Ahorro (kg eq. gas)"];
                var cons = parseFloat(garrafa / gameses).toFixed(0);
                daConsTerm = [cons, cons, cons, cons, cons, cons, cons, cons, cons, cons, cons, cons];
                tPeriodo = "Meses";
                break;
            case "3":
                var ene = $("#txtENEt").val();
                var feb = $("#txtFEBt").val();
                var mar = $("#txtMARt").val();
                var abr = $("#txtABRt").val();
                var may = $("#txtMAYt").val();
                var jun = $("#txtJUNt").val();
                var jul = $("#txtJULt").val();
                var ago = $("#txtAGOt").val();
                var sep = $("#txtSEPt").val();
                var oct = $("#txtOCTt").val();
                var nov = $("#txtNOVt").val();
                var dic = $("#txtDICt").val();
                datos = new Array(lat, long, altura, perso, tcolector, reporte, datosRadMensual, temperatura, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic);
                goCalTermGasElec([datos], [callback_goCalcularFormTerm]);
                $("#titGrafTerm").html("Consumo y ahorro en kWh enquivalentes de electricidad");
                xLabelTerm = labelMeses;
                yLabelTerm = ['Consumo (kWh)', "Ahorro (kWh eq. elect.)"];
                daConsTerm = [ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic];
                tPeriodo = "Meses";
                break;
            case "4":
                datos = new Array(lat, long, altura, perso, tcolector, reporte, datosRadMensual, temperatura);
                goCalTermGasSin([datos], [callback_goCalcularFormTerm]);
                xLabelTerm = labelMeses;
                $("#titGrafTerm").html("Generaci" + String.fromCharCode(243) + "n de agua caliente sanitaria (litros de agua caliente acumulada mensual)");
                yLabelTerm = ["", "Litros de agua caliente acumulada mensual"];
                daConsTerm = null;
                tPeriodo = "Meses";
                break;
        }
    } catch (e) {
        humane.error("Exception getFormTerm " + e.menssage + " - " + e.error);
    }
}

function showResultTerm(datos, datosAgua) {
    try {
        if (grafTerm) updateDataSetGraf(grafTerm, daConsTerm, datos, xLabelTerm, yLabelTerm);
        var html = generateTableTerm(daConsTerm, datos, datosAgua, xLabelTerm, yLabelTerm);
        $("#divTableDatosTerm").html(html);
    } catch (e) {
        humane.error("Exception showResultTerm " + e.menssage + " - " + e.error);
    }
}

function generateTableTerm(datos1, datos2, datos3, xlabel, ylabel) {
    try {
        var html = "<table id='tableData' cellpadding='0' cellspacing='0' width='100%'><tr><th>" + tPeriodo + "</th>";
        if (datos1) {
            html += "<th>" + ylabel[0] + "</th>";
        }
        html += "<th>" + ylabel[1] + "</th>";
        html += "<th>Litros de agua caliente por d" + String.fromCharCode(237) + "a</th>";
        html += "</tr>";
        var labelP = xlabel;
        for (var i in datos2) {
            html += "<tr>";
            html += "<td>" + labelP[i] + "</td>";
            if (datos1) {
                html += "<td>" + datos1[i] + "</td>";
            }
            html += "<td>" + datos2[i] + "</td>";
            html += "<td>" + datos3[i] + "</td>";
            html += "</tr>";
        }
        html += "</table>";
        return html;
    } catch (e) {
        humane.error("Exception 'generateTableTerm ' " + e.menssage + '-' + e.error);
    }
}


/*************** FOTOVOLTAICO ******************/
var consumoMensualFoto;

function getDataForm() {
    try {
        ene = $("#txtENE").val();
        feb = $("#txtFEB").val();
        mar = $("#txtMAR").val();
        abr = $("#txtABR").val();
        may = $("#txtMAY").val();
        jun = $("#txtJUN").val();
        jul = $("#txtJUL").val();
        ago = $("#txtAGO").val();
        set = $("#txtSEP").val();
        oct = $("#txtOCT").val();
        nov = $("#txtNOV").val();
        dic = $("#txtDIC").val();
        //modelo = $('input[name=rModelo]').val();
        modelo = $('input[name=rModelo]:checked').val();
        consumoMensualFoto = new Array(ene, feb, mar, abr, may, jun, jul, ago, set, oct, nov, dic);
        beta = $("#txtInclinacion").val();
        PgfvAux = $("#txtCap").val();
        eficiencia = $("#txtInv").val();
        perdida = $("#txtFactor").val();
        var h_Mes = datosRadMensual;
        var conexion = conexionRed;
        var reporte = hasR;
        tipUser = $("#ddlTipoUsuario option:selected").val();
        var tipousuario = tipUser;
        try {
            lat = lat.toFixed(2);
            long = long.toFixed(2);
        } catch (e) { }
        var allData = new Array(lat, long, altura, conexion, modelo, PgfvAux, beta, eficiencia, perdida, reporte, tipousuario, h_Mes, consumoMensualFoto);
        
        return allData;

    } catch (e) { }
}

function callback_goCalcularFoto(result) {

    try {
        var da = JSON.parse(result);
        $("#divLoading").hide();
        $("#divResFotoAll").show();

        var d = da[0];
        if (d === "Done") {
            var genDatosFoto = da[1];
            if (da[2] !== "no") {
                var archivo = da[2];
                var linkRep = "<a href='files/reportes/fotovoltaico/" + archivo + "' target='_blank'>";
                linkRep += "<img src='images/descarga.svg' style='height: 40px; width: 40px;padding-right: 5px;'/>";
                linkRep += "Descargar Reporte</a>";
                $("#divLinkReporte").html(linkRep);
            } else {
                $("#divLinkReporte").html("");
            }
            updateDataSetGraf(grafFoto, consumoMensualFoto, genDatosFoto);
            $("#divTableDatos").html(generateTable(consumoMensualFoto, genDatosFoto));
        } else {
            if (window.flagDomLoaded) {
                humane.error(da[1]);
            }
        }
    } catch (e) {
        //   humane.error("Exception 'callback_goCalcularFoto ' " + e.menssage + '-' + e.error);
    }
}

function generateTable(datos1, datos2) {
    try {


        var html = "<table id='tableData' cellpadding='0' cellspacing='0'><tr><th>Meses</th><th>Consumo kWh</th><th> Generaci&#243;n kWh</th></tr>";
        var meses = labelMeses;
        for (var i in datos1) {
            html += "<tr>";
            html += "<td>" + meses[i] + "</td>";
            html += "<td>" + datos1[i] + "</td>";
            html += "<td>" + datos2[i] + "</td>";
            html += "</tr>";
        }
        html += "</table>";
        return html;
    } catch (e) {
        humane.error("Exception 'generateTable ' " + e.menssage + '-' + e.error);
    }
}

function ChangeLitros(txt) {
    try {
        var perso = $("#txtFlia").val();
        if (perso > 2) {
            var cal = perso * 45;
            $("#divLitros").html(cal);
        } else $("#divLitros").html("90");
    } catch (e) { }
}
/***************12/02/2025 */
function goForData(paramsArray, callback) {

    const lat = paramsArray[0]; // Primera posición: latitud
    const long = paramsArray[1]; // Segunda posición: longitud
    const type = paramsArray[2]; // Tercera posición: tipo

    // Realiza la solicitud fetch
    // Verifica que callback sea una función
    callback = callback[0];
    fetch('/goForData', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ lat, long, type }),
    })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => callback(data))
        .catch(error => console.error('Error:', error));
}
function callback_goForData(result, e) {

    try {
        /*var da = JSON.parse(result);*/

        var d = result[0];
        if (d === "Done") {
            datos = result[1];


            if (window.flagDomLoaded) {

                UpdateData();
            }
        } else {
           if (window.flagDomLoaded) {
                lat = -24.79;
                long = -65.42;
                try {
                    $("#txtLat").val(parseFloat(lat).toFixed(2));
                    $("#txtLong").val(parseFloat(long).toFixed(2));
                } catch (e) { }
                setNewLatLong();
                humane.error("Error callback_goForData" + result[1]);
            }
        }
    } catch (e) {
        humane.error("Exception callback_goForData " + e.menssage + " - " + e.error);
    }
}
function UpdateData() {
    try {
        if (typeof datos === 'undefined') return;

        console.log(datos);
        let datosRadMensual = datos[1];
        let n = nameurl.charAt(0);
        let mes = nameurl.substring(1);
        
        
        let path = "files/";

        const tipoMap = { d: 'dia', m: 'mes', a: 'anual' };
        let tipo = tipoMap[n] || 'anual';
        

        let titGrafRad, titDescRad, titGrafTemp = "", titDescTemp = "";
        let agraf, vargbl, vargblin, vardiNo, vardiHo, vargblTemp = 0, agrafTemp;

        const TITULOS = {
            dia: {
                rad: "RADIACIÓN SOLAR GLOBAL SOBRE PLANO HORIZONTAL DÍA CARACTERÍSTICO",
                descRad: `RADIACIÓN SOLAR GLOBAL SOBRE PLANO HORIZONTAL DÍA CARACTERÍSTICO: ${mes.toUpperCase()}`,
                path: "diario/",
                indices: [0, 2]
            },
            mes: {
                rad: "RADIACIÓN SOLAR GLOBAL SOBRE PLANO HORIZONTAL ACUMULADA MENSUAL",
                descRad: `RADIACIÓN SOLAR GLOBAL SOBRE PLANO HORIZONTAL ACUMULADA MENSUAL: ${mes.toUpperCase()}`,
                temp: "TEMPERATURA MEDIA MENSUAL",
                descTemp: `TEMPERATURA MEDIA MENSUAL: ${mes.substring(1).toUpperCase()}`,
                path: "mes/",
                indices: [1, 3]
            },
            anual: {
                rad: "RADIACIÓN SOLAR GLOBAL SOBRE PLANO HORIZONTAL ACUMULADA MENSUAL",
                descRad: "RADIACIÓN SOLAR GLOBAL SOBRE PLANO HORIZONTAL ACUMULADA ANUAL",
                temp: "TEMPERATURA MEDIA MENSUAL",
                descTemp: "TEMPERATURA MEDIA ANUAL",
                path: "",
                indices: [1, 4]
            }
        };

        let config = TITULOS[tipo];
        titGrafRad = config.rad;
        titDescRad = config.descRad;
        titGrafTemp = config.temp || "";
        titDescTemp = config.descTemp || "";
        path += config.path;

        [agraf, [vargbl, vargblin, vardiNo, vardiHo]] = [datos[config.indices[0]], datos[config.indices[1]]];

        try {
            if (tipo !== 'dia') {
                let mesName = nameurl.substring(2);
                let m = getMonthFromString(mesName);
                if(tipo==="anual") m=12;
                vargblTemp = datos[5][m];
                agrafTemp = datos[5].slice(0, 12);
            }
        } catch (e) { }

        if (grafRad) updateDataSetGraf(grafRad, agraf);
        if (grafTemp) updateDataSetGraf(grafTemp, agrafTemp);
        try {
            $("#vargbl").html(vargbl);
            console.log(vargblTemp);
            $("#vargblTemp").html(parseFloat(vargblTemp).toFixed(2));
            $("#vargblin").html(vargblin.toFixed(2));
            $("#vardiNo").html(vardiNo.toFixed(2));
            $("#vardiHo").html(vardiHo.toFixed(2));
        } catch (error) {
            //humane.error(`Exception 'toFixed' ${error.message} - ${error.error}`);
        }


        let pathFull = path + name;
        let pathShapes = `shapes/${name}`;
        const createLink = (file) => `<a href='${file}' target='_blank'><img src='images/descarga.svg' style='width:70px' alt='descargar'/></a>`;

        $("#link1").html(createLink(`${pathFull}.pdf`));
        $("#link2").html(createLink(`${pathFull}.png`));
        $("#link3").html(createLink(`${pathShapes}.tif`));
        $("#link1Temp").html(createLink(`${pathFull}.pdf`));
        $("#link2Temp").html(createLink(`${pathFull}.png`));
        $("#link3Temp").html(createLink(`${pathShapes}.tif`));
        $("#link1Foto").html(createLink(`${pathShapes}.tif`));

        $("#titGrafRad").html(titGrafRad);
        $("#titDescRad").html(titDescRad);
        $("#titleInfoRad").html(titDescRad);
        $("#titGrafTemp").html(titGrafTemp);
        $("#titDescTemp").html(titDescTemp);
        $("#titleInfoTemp").html(titDescTemp);
    } catch (ex) {
        humane.error(`Exception 'UpdateData' ${ex.message} - ${ex.error}`);
    }
}

function UpdateData2() {// vieja
    try {
        if (typeof datos !== 'undefined') {
           
            datosRadMensual = datos[1];

            var tipo;
            var n = nameurl.substring(0, 1);
            switch (n) {
                case 'd':
                    tipo = 'dia';
                    break;
                case 'm':
                    tipo = 'mes';
                    break;
                case 'a':
                    tipo = 'anual';
                    break;
                default:
                    tipo = 'anual';
            }
            var mes = nameurl.substring(1, nameurl.length);
            var titGrafRad, titDescRad, titGrafTemp, titDescTemp;
            var agraf, vargbl, vargblin, vardiNo, vardiHo, vargblTemp = 0;
            var path = "files/";
            
            switch (tipo) {
                case 'dia':
                    agraf = datos[0];
                    vargbl = datos[2][0];
                    vargblin = datos[2][1];
                    vardiNo = datos[2][2];
                    vardiHo = datos[2][3];
                    titGrafRad = "RADIACI" + String.fromCharCode(211) + "N SOLAR GLOBAL SOBRE PLANO HORIZONTAL D" + String.fromCharCode(205) + "A CARACTER" + String.fromCharCode(205) + "STICO ";
                    titDescRad = "RADIACI" + String.fromCharCode(211) + "N SOLAR GLOBAL SOBRE PLANO HORIZONTAL D" + String.fromCharCode(205) + "A CARACTER" + String.fromCharCode(205) + "STICO: " + mes.toUpperCase();
                    path = path + "diario/";
                    break;
                case 'mes':
                    agraf = datos[1];
                    datosRadMensual = datos[1];
                    vargbl = datos[3][0];
                    vargblin = datos[3][1];
                    vardiNo = datos[3][2];
                    vardiHo = datos[3][3];
                    titGrafRad = "RADIACI" + String.fromCharCode(211) + "N SOLAR GLOBAL SOBRE PLANO HORIZONTAL ACUMULADA MENSUAL ";
                    titDescRad = "RADIACI" + String.fromCharCode(211) + "N SOLAR GLOBAL SOBRE PLANO HORIZONTAL ACUMULADA MENSUAL: " + mes.toUpperCase();
                    titGrafTemp = "TEMPERATURA MEDIA MENSUAL ";
                    titDescTemp = "TEMPERATURA MEDIA MENSUAL: " + mes.toUpperCase().substring(1, mes.length);
                    path = path + "mes/";
                    try {

                        var mesName = nameurl.substring(2, nameurl.length);
                        var m = getMonthFromString(mesName);                      
                        vargblTemp = datos[5][m];
                        agrafTemp = datos[5].slice(0, 12);

                    } catch (e) { }



                    break;
                case 'anual':
                    agraf = datos[1];
                    vargbl = datos[4][0];
                    vargblin = datos[4][1];
                    vardiNo = datos[4][2];
                    vardiHo = datos[4][3];

                    try {

                        vargblTemp = datos[5][12];
                        agrafTemp = datos[5].slice(0, 12);
                    } catch (e) { }
                    titGrafRad = "RADIACI" + String.fromCharCode(211) + "N SOLAR GLOBAL SOBRE PLANO HORIZONTAL ACUMULADA MENSUAL";
                    titDescRad = "RADIACI" + String.fromCharCode(211) + "N SOLAR GLOBAL SOBRE PLANO HORIZONTAL ACUMULADA ANUAL";
                    titGrafTemp = "TEMPERATURA MEDIA MENSUAL ";
                    titDescTemp = "TEMPERATURA MEDIA ANUAL";
                    break;
                default:
                    agraf = datos[1];
                    vargbl = datos[4][0];
                    vargblin = datos[4][1];
                    vardiNo = datos[4][2];
                    vardiHo = datos[4][3];
                    try {
                        vargblTemp = datos[5][12];
                        agrafTemp = datos[5].slice(1, 13);
                    } catch (e) { }
            }
            if (grafRad) updateDataSetGraf(grafRad, agraf);
            if (grafTemp) updateDataSetGraf(grafTemp, agrafTemp);
            // Would update the first dataset's value of 'March' to be 50
            $("#vargbl").html(vargbl);
            try {
                $("#vargblTemp").html(parseFloat(vargblTemp).toFixed(2));
            } catch (e) { }
            try {
                try {
                    $("#vargblin").html(vargblin.toFixed(2));
                    $("#vardiNo").html(vardiNo.toFixed(2));
                    $("#vardiHo").html(vardiHo.toFixed(2));
                } catch (e) { }
                var path = path + name;
                var path2 = "shapes/" + name;
                var link1 = "<a href='" + path + ".pdf' target='_blank' ><img src='images/descarga.svg' style='width:70px' alt='descargar'/></a>";
                var link2 = "<a href='" + path + ".png' target='_blank' ><img src='images/descarga.svg' style='width:70px' alt='descargar'/></a>";
                var link3 = "<a href='" + path2 + ".tif' target='_blank' ><img src='images/descarga.svg' style='width:70px' alt='descargar'/></a>";
                var link1Temp = "<a href='" + path + ".pdf' target='_blank' ><img src='images/descarga.svg' style='width:70px' alt='descargar'/></a>";
                var link2Temp = "<a href='" + path + ".png' target='_blank' ><img src='images/descarga.svg' style='width:70px' alt='descargar'/></a>";
                var link3Temp = "<a href='" + path2 + ".tif' target='_blank' ><img src='images/descarga.svg' style='width:70px' alt='descargar'/></a>";
                var link1Foto = "<a href='" + path2 + ".tif' target='_blank' ><img src='images/descarga.svg' style='width:70px' alt='descargar'/></a>";
                $("#link1").html(link1);
                $("#link2").html(link2);
                $("#link3").html(link3);
                $("#link1Temp").html(link1Temp);
                $("#link2Temp").html(link2Temp);
                $("#link3Temp").html(link3Temp);
                $("#titGrafRad").html(titGrafRad);
                $("#titDescRad").html(titDescRad);
                $("#titleInfoRad").html(titDescRad);
                $("#titGrafTemp").html(titGrafTemp);
                $("#titDescTemp").html(titDescTemp);
                $("#titleInfoTemp").html(titDescTemp);
                $("#link1Foto").html(link1Foto);
            } catch (e) {
                // humane.error("Exception 'UpdateData pantallas '" + e.menssage + '-' + e.error);
            }
        }
    } catch (ex) {
        humane.error("Exception 'UpdateData '" + ex.menssage + '-' + ex.error);
    }
}
function callback_goCalcularFormTerm(result) {
    
    try {

        var da = JSON.parse(result);


        var d = da[0];
        $("#divLoadingT").hide();
        $("#divResTermAll").show();

        if (d === "Done") {
            var datos = da[1];
            var datosAgua = da[2];
            if (window.flagDomLoaded) {
                if (da[3] !== "no") {
                    var archivo = da[3];
                    var linkRep = "<a href='files/reportes/termico/" + archivo + "' target='_blank'>";
                    linkRep += "<img src='images/descarga.svg' style='height: 40px; width: 40px;padding-right: 5px;'/>";
                    linkRep += "Descargar Reporte</a>";
                    $("#divLinkReporteT").html(linkRep);
                } else {
                    $("#divLinkReporteT").html("");
                }
                showResultTerm(datos, datosAgua);
            }
        } else {
            if (window.flagDomLoaded) {
                humane.error(da[1]);
            }
        }
    } catch (e) {
        humane.error("Exception2 callback_goCalcularFormTerm " + e.menssage + " - " + e.error);
    }
}