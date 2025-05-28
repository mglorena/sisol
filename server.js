const express = require('express');
const fs = require('fs');
const path = require('path');
const config = require('./modules/conf');
// server.js
const Calculadora = require('./modules/calculadora');
//const Fotovoltaico = require('./modules/fotovoltaico');
//const Errores = require('./modules/errores');
//const Calefon = require('./modules/calefon');
const Conf = require('./modules/conf');
const app = express();
app.use(express.json());
const PORT = 3000;

// Función para leer archivos HTML
const readHTML = (filename) => {
    return fs.readFileSync(path.join(__dirname, 'public', filename), 'utf-8');
};
// server.js
// Ruta POST para /goForData
app.post('/goForData', async (req, res) => {
  

    if (req.body) {
        const { lat, long, type } = req.body;
        try {
            const result = await new Calculadora().getRadiacion(lat, long, type);
            res.json(result);
            
        } catch (error) {
            res.status(500).json({ error: `Error en la consulta: ${error.message}` });
        }
    } else {
        res.status(400).json({ error: 'Cuerpo de la solicitud no válido' });
    }
});

app.post('/goCalcularFoto', (req, res) => {
    const { args } = req.body;
    // Lógica para manejar la solicitud
    const result = goCalcularFoto(args);
    res.json(result);
});

// Otras rutas para goCalTermGasNat, goCalTermGasEnv, etc.
// Ruta principal para servir la página completa
app.get('/', (req, res) => {
    let headerHTML = readHTML('/templates/header.html');
    let menuHTML = readHTML('/templates/menu.html');
    let mapaHTML = readHTML('/templates/mapa.html');
    let infoInfoHTML = readHTML('/templates/infoInfo.html');
    let infoRadHTML = readHTML('/templates/infoRad.html');
    let infoTempHTML = readHTML('/templates/infoTemp.html');
    let infoFotoHTML = readHTML('/templates/infoFoto.html');
    let infoTermHTML = readHTML('/templates/infoTerm.html');
    let infoBookHTML = readHTML('/templates/infoBook.html');
    let toolCalHTML = readHTML('/templates/toolCal.html');
    let footerHTML = readHTML('/templates/footer.html');

    // Reemplazar marcadores de posición
    headerHTML = headerHTML.replace(/<TMPL_VAR NAME=HOST>/g, config.hostGeoMapa);
    headerHTML = headerHTML.replace(/<TMPL_VAR NAME=VERSION>/g, '1.0.0'); // Ejemplo de versión
    footerHTML = footerHTML.replace(/<TMPL_VAR NAME=VERSION>/g, '1.0.0'); // Ejemplo de versión

    const html = `
        ${headerHTML}
        ${menuHTML}
        ${mapaHTML}
        <div class='toolbarForms'>
            ${infoInfoHTML}
            ${infoRadHTML}
            ${infoTempHTML}
            ${infoFotoHTML}
            ${infoTermHTML}
            ${infoBookHTML}
        </div>
        ${toolCalHTML}
        ${footerHTML}
    `;

    res.send(html);
});

// Servir archivos estáticos
app.use(express.static(path.join(__dirname, 'public')));

app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});