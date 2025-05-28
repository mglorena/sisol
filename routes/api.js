const express = require('express');
const router = express.Router();
const Calculadora = require('../modules/calculadora');
const Fotovoltaico = require('../modules/fotovoltaico');
const Calefon = require('../modules/calefon');

router.post('/goForData', (req, res) => {
    const { lat, long, type } = req.body;
    const result = Calculadora.getRadiacion(lat, long, type);
    res.json(result);
});

router.post('/goCalcularFoto', (req, res) => {
    const result = Fotovoltaico.calculaEnergia(req.body);
    res.json(result);
});

router.post('/goCalTermGasNat', (req, res) => {
    const result = Calefon.calculaNatural(req.body);
    res.json(result);
});

module.exports = router;
