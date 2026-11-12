// SPDX-FileCopyrightText: zayronxio
// SPDX-FileCopyrightText: 2026 Andrey Malakhovsky
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.11
import org.kde.kirigami as Kirigami

Item {
    id: configRoot

    signal configurationChanged

    CoinModel {
        id: coinModel
    }

    CurrencyModel {
        id: currencyModel
    }

    QtObject {
        id: cryptoValue
        property var currency
        property var coinName
        property var symbol
        property var coinNameAbbreviation
        property var source
        property var stockSymbol
    }

    property alias cfg_coinName: cryptoValue.coinName
    property alias cfg_currency: cryptoValue.currency
    property alias cfg_symbol: cryptoValue.symbol
    property alias cfg_fontSize: fontsizedefault.value
    property alias cfg_textBold: boldTextCkeck.checked
    property alias cfg_coinNameAbbreviation: cryptoValue.coinNameAbbreviation
    property alias cfg_source: cryptoValue.source
    property alias cfg_stockSymbol: cryptoValue.stockSymbol

    ColumnLayout {
        Layout.preferredWidth: parent.width - Kirigami.Units.largeSpacing *2
        Layout.minimumWidth: preferredWidth
        Layout.maximumWidth: preferredWidth
        spacing: units.smallSpacing * 3
        GridLayout{
            Layout.preferredWidth: parent.width
            Layout.minimumWidth: preferredWidth
            Layout.maximumWidth: preferredWidth
            columns: 2

            Label {
                id: refrestitle
                Layout.minimumWidth: root.width/2
                text: i18n("Font Size:")
                horizontalAlignment: Label.AlignRight
            }
            SpinBox {
                from: 5
                id: fontsizedefault
                to: 40
            }
            Label {
            }
            Label {
            }
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Bold:")
                horizontalAlignment: Label.AlignRight
            }

            CheckBox{
                id: boldTextCkeck
                text: i18n("")
            }
            Label {
            }
            Label {
            }
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Source:")
                horizontalAlignment: Label.AlignRight
            }
            ComboBox {
                id: sourceBox
                textRole: "text"
                valueRole: "value"
                model: [ { text: i18n("Crypto (CoinGecko)"), value: "crypto" }, { text: i18n("Stock / ETF (Yahoo Finance)"), value: "stock" } ]
                onActivated: cryptoValue.source = currentValue
                Component.onCompleted: currentIndex = Math.max(0, indexOfValue(cryptoValue.source))
            }
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Ticker:")
                horizontalAlignment: Label.AlignRight
                visible: cryptoValue.source === "stock"
            }
            TextField {
                id: tickerField
                visible: cryptoValue.source === "stock"
                placeholderText: "TSLA"
                text: cryptoValue.stockSymbol || ""
                onTextEdited: {
                    cryptoValue.stockSymbol = text.trim().toUpperCase()
                    cryptoValue.coinNameAbbreviation = cryptoValue.stockSymbol
                }
            }
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Label:")
                horizontalAlignment: Label.AlignRight
                visible: cryptoValue.source === "stock"
            }
            TextField {
                visible: cryptoValue.source === "stock"
                placeholderText: "Shown above the price"
                text: cryptoValue.coinNameAbbreviation || ""
                onTextEdited: cryptoValue.coinNameAbbreviation = text.trim()
            }
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("From Crypto:")
                horizontalAlignment: Label.AlignRight
                visible: cryptoValue.source !== "stock"
            }
            ComboBox {
                visible: cryptoValue.source !== "stock"
                textRole: "name"
                valueRole: "name"
                id: nameFromCrypto
                model: coinModel
                onActivated: {
                    cryptoValue.coinName = currentValue
                    cryptoValue.coinNameAbbreviation = model.get(currentIndex).abbreviation
                }
                Component.onCompleted: currentIndex = indexOfValue(cryptoValue.coinName)
            }
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Currency:")
                horizontalAlignment: Label.AlignRight
                visible: cryptoValue.source !== "stock"
            }
            ComboBox {
                visible: cryptoValue.source !== "stock"
                textRole: "name"
                valueRole: "abbreviation"
                id: nameToCurrency
                model: currencyModel
                onActivated: {
                    cryptoValue.currency = currentValue
                    cryptoValue.symbol = currencyModel.get(currentIndex).symbol
                }
                Component.onCompleted: currentIndex = indexOfValue(cryptoValue.currency)
            }


        }
    }

}
