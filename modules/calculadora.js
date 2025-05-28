const axios = require('axios');
const math = require('mathjs');

class Calculadora {
    constructor() {
        this.hostGeoDatos = "http://localhost:8080/geoserver/sisol/wms?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&FORMAT=image%2Fpng&TRANSPARENT=true&QUERY_LAYERS=sisol%3Adatos&STYLES&LAYERS=datos%3Adatos&INFO_FORMAT=application%2Fjson&FEATURE_COUNT=50&X=50&Y=50&SRS=EPSG%3A4326&WIDTH=101&HEIGHT=101";
    }

    async getRadiacion(lat, long, type) {
        let retorno = [];

        if (this.isInSalta(lat, long)) {
            try {
                const boundingBox = this.boundingBox(lat, long);
                const url = `${this.hostGeoDatos}&BBOX=${boundingBox[0]}%2C${boundingBox[3]}%2C${boundingBox[2]}%2C${boundingBox[1]}`;
                const response = await axios.get(url);

                if (response.data.features.length === 0) {
                    retorno.push("Error response.data.features.length - getRadiación");
                    retorno.push("No está en Salta");
                    return retorno;
                }
                if (!response.data || !response.data.features) {
                    retorno.push("Error response.data || !response.data.features- getRadiación");
                    retorno.push("Datos de radiación no disponibles");
                    return retorno;
                }
                const dia = this.parserDia(response.data);
                const mes = this.parserMes(response.data);
                const anual = this.parserAnual(response.data);

                let output = [];
                let year = [];

                year.push(...anual);
                year.push(Math.floor(anual[0] * 80) / 100);
                year.push(Math.floor(anual[0] * 75) / 100);
                year.push(Math.floor((anual[0] - (anual[0] * 75 / 100)) * 100) / 100);
                console.log("Elegimos que tipo " + type)   
                if (/^[dm]/.test(type)) {
                     type = type.slice(1);
                    
                    const indice = this.defMes(type);
                    
                    const valorDia = this.componentesDia(type, lat, dia[indice - 1]);
                    
                    const radDiaInclinada = this.radiacionDiaInclinada(type, 30, lat, dia[indice - 1]);

                    let valDia = [];
                    valDia.push(valorDia[0]);
                    valDia.push(radDiaInclinada[0]);
                    valDia.push(valorDia[1]);
                    valDia.push(valorDia[2]);
                     
                    let valMes = [];
                    const valorMes = this.componentesMes(type, lat, mes[indice - 1]);
                    console.log("datos por mes "+ valorMes);
                    valMes.push(valorMes[0]);
                    valMes.push(radDiaInclinada[0] * this.getCantDias(type));
                    valMes.push(Math.floor(valorMes[1] * 100) / 100);
                    valMes.push(Math.floor(valorMes[2] * 100) / 100);

                    output.push(dia);
                    output.push(mes);
                    output.push(valDia);
                    output.push(valMes);
                    output.push(year);
                }
                else {
                    console.log("toma por anual");
                    output.push(dia);
                    output.push(mes);
                    output.push([]);
                    output.push([]);
                    output.push(year);
                }
                const url2 = `http://localhost:8080/geoserver/sisol/wms?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&FORMAT=image%2Fpng&TRANSPARENT=true&QUERY_LAYERS=sisol%3AdatosTemperatura&STYLES&LAYERS=sisol%3AdatosTemperatura&INFO_FORMAT=application%2Fjson&FEATURE_COUNT=50&X=50&Y=50&SRS=EPSG%3A4326&WIDTH=101&HEIGHT=101&BBOX=${boundingBox[0]}%2C${boundingBox[3]}%2C${boundingBox[2]}%2C${boundingBox[1]}`;
                const response2 = await axios.get(url2);

                if (response2.data.features.length === 0) {
                    retorno.push("Error response2.data.features.length - getRadiación");
                    retorno.push("No está en Salta - Temperatura");
                    return retorno;
                }

                const temperatura = this.parserTemperatura(response2.data);
                console.log(temperatura)
                output.push(temperatura);

                retorno.push("Done");
                retorno.push(output);
                return retorno;
            } catch (error) {
                retorno.push("Error catch - getRadiación");
                retorno.push(`Failed: ${error.message}`);
                return retorno;
            }
        } else {
            retorno.push("Error - getRadiación");
            retorno.push("No pasa nada");
            return retorno;
        }
    }

    isInSalta(lat, long) {
        const westLimit = -68.5821533203125;
        const eastLimit = -62.33299255371094;
        const northLimit = -21.993988560906036;
        const southLimit = -26.394945029678645;
        return westLimit < long && long < eastLimit && lat > southLimit && lat < northLimit;
    }

    boundingBox(lat, long) {
        const westLimit = long;
        const eastLimit = long + 0.001;
        const northLimit = lat;
        const southLimit = lat + 0.001;
        return [westLimit, southLimit, eastLimit, northLimit];
    }

    parserDia(sentence) {
        // Verifica que sentence sea un objeto JSON válido
        if (typeof sentence !== 'object' || sentence === null) {
            throw new Error('Función parserDia: El parámetro sentence debe ser un objeto JSON');
        }

        // Extrae las propiedades relevantes del JSON
        const properties = sentence.features[0].properties;

        // Define los meses y sus claves en el JSON
        const meses = [
            "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
            "Julio", "Agosto", "Setiembre", "Octubre", "Noviembre", "Diciembre"
        ];

        // Array para almacenar los valores de radiación por día
        const radiacionDia = [];

        // Itera sobre los meses y extrae los valores numéricos
        for (const mes of meses) {
            if (properties.hasOwnProperty(mes)) {
                radiacionDia.push(properties[mes]);
            } else {
                // Si no existe la clave, agrega null o un valor por defecto
                radiacionDia.push(null);
            }
        }

        return radiacionDia;
    }

    parserMes(sentence) {
        // Verifica que sentence sea un objeto JSON válido
        if (typeof sentence !== 'object' || sentence === null) {
            throw new Error('Función parserMes: El parámetro sentence debe ser un objeto JSON');
        }

        // Extrae las propiedades relevantes del JSON
        const properties = sentence.features[0].properties;

        // Define los meses y sus claves en el JSON
        const meses = [
            "mesEnero", "mesFebrero", "mesMarzo", "mesAbril", "mesMayo", "mesJunio",
            "mesJulio", "mesAgosto", "mesSetiemb", "mesOctubre", "mesNoviembre", "mesDiciembre","mesAnual"
        ];

        // Array para almacenar los valores de radiación por día
        const radiacionMes = [];

        // Itera sobre los meses y extrae los valores numéricos
        for (const mes of meses) {
            if (properties.hasOwnProperty(mes)) {
                radiacionMes.push(properties[mes]);
            } else {
                // Si no existe la clave, agrega null o un valor por defecto
                radiacionMes.push(null);
            }
        }

        return radiacionMes;
    }

    parserAnual(sentence) {
        // Verifica que sentence sea un objeto JSON válido
        if (typeof sentence !== 'object' || sentence === null) {
            throw new Error('Función parserlAnual: El parámetro sentence debe ser un objeto JSON');
        }

        // Extrae las propiedades relevantes del JSON
        const properties = sentence.features[0].properties;

        // Define el año y su claves en el JSON
        const anual = ["mesAnual"];

        // Array para almacenar los valores de radiación por año
        const radiacionAnual = [];

        // Itera sobre los meses y extrae los valores numéricos
        for (const mes of anual) {
            if (properties.hasOwnProperty(mes)) {
                radiacionAnual.push(properties[mes]);
            } else {
                // Si no existe la clave, agrega null o un valor por defecto
                radiacionAnual.push(null);
            }
        }

        return radiacionAnual;
    }

    parserTemperatura(sentence) {
        // Verifica que sentence sea un objeto JSON válido

        if (typeof sentence !== 'object' || sentence === null) {
            throw new Error('Función parserTemperatura: El parámetro sentence debe ser un objeto JSON');
        }

        // Extrae las propiedades relevantes del JSON
        const properties = sentence.features[0].properties;

        // Define los meses y sus claves en el JSON
        const meses = [
            "tenero", "tfebrero", "tmarzo", "tabril", "tmayo", "tjunio",
            "tjulio", "tagosto", "tsetiembr", "toctubre", "tnoviembre", "tdiciembre","tanual"
        ];

        // Array para almacenar los valores de radiación por día
        const temperaturaMes = [];

        // Itera sobre los meses y extrae los valores numéricos
        for (const mes of meses) {
            if (properties.hasOwnProperty(mes)) {
                temperaturaMes.push(properties[mes]);
            } else {
                // Si no existe la clave, agrega null o un valor por defecto
                temperaturaMes.push(null);
            }
        }

        return temperaturaMes;
    }

    radiacionDiaInclinada(mes, beta, latitud, H) {
        // Función para calcular el día juliano
        

        // Convertir grados a radianes
        function toRadians(degrees) {
            return degrees * (Math.PI / 180);
        }

        // Convertir radianes a grados
        function toDegrees(radians) {
            return radians * (180 / Math.PI);
        }

        // Cálculo del día juliano
        const juliano =this.getDiaJuliano(mes);

        // Cálculo de delta (declinación solar)
        const delta = 23.45 * Math.sin(toRadians(360 * (284 + juliano) / 365));

        // Constante solar (Gsc)
        const Gsc = 1366;

        // Cálculo de omegaS (ángulo de puesta del sol)
        const omegaS = toDegrees(Math.acos(-Math.tan(toRadians(latitud)) * Math.tan(toRadians(delta))));

        // Cálculo de Ho (radiación extraterrestre diaria)
        const Ho = (24 * 3600 * Gsc / Math.PI / 3.6 / 1000000) *
            (1 + 0.033 * Math.cos(toRadians(360 * juliano / 365))) *
            (Math.cos(toRadians(latitud)) * Math.cos(toRadians(delta)) * Math.sin(toRadians(omegaS)) +
                (Math.PI * omegaS / 180 * Math.sin(toRadians(latitud)) * Math.sin(toRadians(delta))));

        // Índice de claridad (kt)
        const kt = H / Ho;

        // Cálculo de omegaSprima (ángulo de puesta del sol para el plano inclinado)
        const omegaSprima1 = toDegrees(Math.acos(-Math.tan(toRadians(latitud)) * Math.tan(toRadians(delta))));
        const omegaSprima2 = toDegrees(Math.acos(-Math.tan(toRadians(latitud + beta)) * Math.tan(toRadians(delta))));
        const omegaSprima = Math.min(omegaSprima1, omegaSprima2);

        // Cálculo de Rb (factor de relación de radiación)
        const numerador = Math.cos(toRadians(latitud + beta)) * Math.cos(toRadians(delta)) * Math.sin(toRadians(omegaSprima)) +
            (Math.PI / 180 * omegaSprima * Math.sin(toRadians(latitud + beta)) * Math.sin(toRadians(delta)));
        const denominador = Math.cos(toRadians(latitud)) * Math.cos(toRadians(delta)) * Math.sin(toRadians(omegaS)) +
            (Math.PI / 180 * omegaS * Math.sin(toRadians(latitud)) * Math.sin(toRadians(delta)));
        const Rb = numerador / denominador;

        // Cálculo de Htt (radiación global acumulada sobre el plano inclinado)
        const Hd = H * (1 - kt); // Radiación difusa
        const albedo = 0.2; // Valor de albedo (puedes ajustarlo según sea necesario)
        const Htt = H * (Rb * (1 - Hd / H) + (Hd / H * (1 + Math.cos(toRadians(beta))) / 2) + albedo * (1 - Math.cos(toRadians(beta))) / 2);

        // Cálculo de Hdt (radiación difusa sobre el plano inclinado)
        const Hdt = (0.755 + 0.00606 * (omegaS - 90) - (0.505 + 0.00455 * (omegaS - 90)) * Math.cos(toRadians(115 * kt - 103))) * Htt;

        // Cálculo de Hbt (radiación directa sobre el plano inclinado)
        const Hbt = Htt - Hdt;

        // Retornar los resultados en un array
        return [Htt, Hbt, Hdt];
    }
    componentesMes(mes, latitud, Hmes) {
        const Gsc = 1366;
        const juliano = this.getDiaJuliano(mes);
        const delta = 23.45 * Math.sin(math.pi / 180 * 360 * (284 + juliano) / 365);
        const omegaS = 180 / math.pi * Math.acos(-Math.tan(math.pi / 180 * latitud) * Math.tan(math.pi / 180 * delta));

        const Ho = (24 * 3600 * Gsc / math.pi / 3.6 / 1000000) * (1 + 0.033 * Math.cos(math.pi / 180 * 360 * juliano / 365)) *
            (Math.cos(math.pi / 180 * latitud) * Math.cos(math.pi / 180 * delta) * Math.sin(math.pi / 180 * omegaS) +
                (math.pi * omegaS / 180 * Math.sin(math.pi / 180 * latitud) * Math.sin(math.pi / 180 * delta)));

        const Haverage = Hmes / this.getCantDias(mes);
        const kt = Haverage / Ho;
        let Hdifmes;

        if (omegaS > 81.4 && kt >= 0.3 && kt <= 0.8) {
            Hdifmes = (1.391 - (3.560 * kt) + (4.189 * (kt ** 2)) - (2.137 * (kt ** 3))) * Haverage;
        } else {
            Hdifmes = (1.311 - (3.022 * kt) + (3.427 * (kt ** 2)) - (1.821 * (kt ** 3))) * Haverage;
        }

        let radiacionMes = [Hmes];
        Hdifmes *= this.getCantDias(mes);

        if (Hdifmes > (Hmes - Hdifmes)) {
            radiacionMes.push(Hdifmes, (Hmes - Hdifmes));
        } else {
            radiacionMes.push((Hmes - Hdifmes), Hdifmes);
        }

        return radiacionMes;
    }

    componentesDia(mes, latitud, Hdia) {
        
        const Gsc = 1366;
        const juliano = this.getDiaJuliano(mes);
        const delta = 23.45 * Math.sin(math.pi / 180 * 360 * (284 + juliano) / 365);
        const omegaS = 180 / math.pi * Math.acos(-Math.tan(math.pi / 180 * latitud) * Math.tan(math.pi / 180 * delta));

        const Ho = (24 * 3600 * Gsc / math.pi / 3.6 / 1000000) * (1 + 0.033 * Math.cos(math.pi / 180 * 360 * juliano / 365)) *
            (Math.cos(math.pi / 180 * latitud) * Math.cos(math.pi / 180 * delta) * Math.sin(math.pi / 180 * omegaS) +
                (math.pi * omegaS / 180 * Math.sin(math.pi / 180 * latitud) * Math.sin(math.pi / 180 * delta)));

        const kt = Hdia / Ho;
        let Hdif;

        if (omegaS <= 81.4) {
            if (kt < 0.715) {
                Hdif = (1 - (0.2727 * kt) + (2.4495 * (kt ** 2)) - (11.9514 * (kt ** 3)) + (9.3879 * (kt ** 4))) * Hdia;
            } else {
                Hdif = 0.175 * Hdia;
            }
        } else {
            if (kt < 0.722) {
                Hdif = (1.0 + (0.2832 * kt) - (2.5557 * (kt ** 2)) + (0.8448 * (kt ** 3))) * Hdia;
            } else {
                Hdif = 0.175 * Hdia;
            }
        }

        return [Hdia, Hdif, Hdia - Hdif];
    }


    getDiaJuliano(mes) {
        const diaJuliano = {
            "enero": 17,
            "febrero": 47,
            "marzo": 75,
            "abril": 105,
            "mayo": 135,
            "junio": 162,
            "julio": 198,
            "agosto": 228,
            "septiembre": 258,
            "octubre": 288,
            "noviembre": 318,
            "diciembre": 344
        };
        return diaJuliano[mes];
    }
    
    getCantDias(mes) {
        const diasPorMes = {
            'enero': 31, 'febrero': 28, 'marzo': 31, 'abril': 30, 'mayo': 31,
            'junio': 30, 'julio': 31, 'agosto': 31, 'septiembre': 30,
            'octubre': 31, 'noviembre': 30, 'diciembre': 31
        };
        return diasPorMes[mes.toLowerCase()] || 30;
    }

    defMes(mes) {
        const meses = {
            enero: 1,
            febrero: 2,
            marzo: 3,
            abril: 4,
            mayo: 5,
            junio: 6,
            julio: 7,
            agosto: 8,
            septiembre: 9,
            octubre: 10,
            noviembre: 11,
            diciembre: 12
        };
        
        mes = mes.toLowerCase(); // Aseguramos que la entrada esté en minúsculas
        
        return meses[mes] || null;
    }
}

module.exports = Calculadora;