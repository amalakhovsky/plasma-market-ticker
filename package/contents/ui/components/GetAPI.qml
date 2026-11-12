// SPDX-FileCopyrightText: zayronxio
// SPDX-FileCopyrightText: 2026 Andrey Malakhovsky
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick

Item {
    property string coinName: ""
    property string currencyAbbreviation: ""
    property string source: "crypto"        // "crypto" (CoinGecko) or "stock" (Yahoo Finance)
    property string stockSymbol: ""

    property string combinedValues: source+coinName+currencyAbbreviation+stockSymbol
    property int refreshRate: 15 // Tasa de actualización en minutos
    property int price: -1
    // Percent change: last 24 h for crypto, since the previous close for stocks. NaN = unknown.
    property real change: NaN
    property bool isFirstConsultation: true
    property string link: ""

    // Detecta cambios en el precio
    onPriceChanged: {
        if (price !== -1 && price !== "") {
            update.restart()   // was update(): a Timer id is not callable
        }
    }
    onCombinedValuesChanged: {
        price = (-1)
        updateNow()
    }

    function updateNow() {
        if (source === "stock") {
            if (stockSymbol === "") { return; }
            // No key needed; Yahoo answers Qt's default "Mozilla/5.0" user agent but 429s bare clients.
            link = "https://query1.finance.yahoo.com/v8/finance/chart/" + encodeURIComponent(stockSymbol.toUpperCase()) + "?interval=1d&range=1d"
        } else {
            link = "https://api.coingecko.com/api/v3/simple/price?ids=" + coinName + "&vs_currencies=" + currencyAbbreviation
                 + "&include_24hr_change=true"
        }
        updatePrice(function(result) {
            if (result) {
                price = parseInt(result);
                isFirstConsultation = false;
                retry.interval = 5000;
            } else {
                // Back off 5 s -> 5 min with jitter: a fixed 5 s retry from every
                // instance keeps CoinGecko's free tier answering 429 indefinitely.
                retry.interval = Math.min(retry.interval * 2, 300000) + Math.floor(Math.random() * 3000);
                retry.start();
            }
        });
    }

    // Función para actualizar el precio desde la API de CoinGecko
    function updatePrice(callback) {
        let url = link;

        let req = new XMLHttpRequest();
        req.open("GET", url, true);

        req.onreadystatechange = function () {
            if (req.readyState === 4) {
                if (req.status === 200) {
                    let priceInCurrency = null;
                    try {
                        let datos = JSON.parse(req.responseText);
                        if (source === "stock") {
                            // regularMarketPrice is the live price in-session and the last close otherwise
                            const meta = datos.chart.result[0].meta;
                            priceInCurrency = meta.regularMarketPrice;
                            const prev = meta.chartPreviousClose || meta.previousClose;
                            change = (prev > 0 && priceInCurrency > 0) ? (priceInCurrency - prev) / prev * 100 : NaN;
                        } else {
                            priceInCurrency = datos[coinName][currencyAbbreviation];
                            const c = datos[coinName][currencyAbbreviation + "_24h_change"];
                            change = (typeof c === "number") ? c : NaN;
                        }
                    } catch (e) {
                        console.warn("[marketticker] unexpected reply for", source === "stock" ? stockSymbol : coinName, e);
                    }
                    callback(priceInCurrency);
                } else {
                    console.error(`Error en la solicitud: ${req.status}`);
                    callback(null); // En caso de error, devuelve null al callback
                }
            }
        };

        req.send();
    }

    // Temporizador para reintentar solicitudes fallidas
    Timer {
        id: retry
        interval: 5000 // doubled on each failure, reset on success
        repeat: false
        running: false
        onTriggered: {
            updateNow()
        }
    }

    // Temporizador para actualizaciones periódicas
    Timer {
        id: update
        interval: refreshRate * 60000 // Convierte minutos a milisegundos
        repeat: true
        running: true
        onTriggered: {
            updateNow()
        }
    }

    // Primera consulta al completar el componente
    Component.onCompleted: {
        updateNow()
    }
}
