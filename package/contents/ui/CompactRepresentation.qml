/*
 * SPDX-FileCopyrightText: zayronxio
 * SPDX-FileCopyrightText: 2026 Andrey Malakhovsky
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Modified: two-line layout (name over price), stock source, trend marker
 */
import QtQuick 2.12
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "components" as Components

Item {
    id: root
    property int pixelFontVar: Plasmoid.configuration.fontSize
    property int heightroot: 20

    implicitWidth: Math.max(nameRow.implicitWidth, priceLabel.implicitWidth) + 18
    implicitHeight: coinLabel.implicitHeight + priceLabel.implicitHeight

    // Trend marker: a small muted triangle before the name. None within +/-0.5 %;
    // fades in from 0.5 % and reaches full strength at 3 %.
    readonly property real change: getApi.change
    readonly property bool showTrend: !isNaN(change) && Math.abs(change) >= 0.5
    readonly property real trendStrength: showTrend ? 0.4 + 0.6 * Math.min(1, (Math.abs(change) - 0.5) / 2.5) : 0
    readonly property string changeText: isNaN(change) ? "" :
        (change >= 0 ? "+" : "−") + Math.abs(change).toFixed(2) + " %" +
        (Plasmoid.configuration.source === "stock" ? " since previous close" : " in 24 h")

    Components.GetAPI {
        id: getApi
        coinName: Plasmoid.configuration.coinName
        currencyAbbreviation: Plasmoid.configuration.currency
        source: Plasmoid.configuration.source
        stockSymbol: Plasmoid.configuration.stockSymbol
    }

    CoinModel {
        id: coinModel
    }

    Column {
        anchors.centerIn: parent

        Row {
            id: nameRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.showTrend ? 2 : 0

            Canvas {
                id: trend
                visible: root.showTrend
                width: visible ? 6 : 0
                height: 5
                anchors.verticalCenter: parent.verticalCenter
                opacity: root.trendStrength
                property bool up: root.change > 0
                onUpChanged: requestPaint()
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = up ? "#78be8c" : "#d76e69";   // muted green / muted red
                    ctx.beginPath();
                    if (up) { ctx.moveTo(0, 5); ctx.lineTo(6, 5); ctx.lineTo(3, 0); }
                    else    { ctx.moveTo(0, 0); ctx.lineTo(6, 0); ctx.lineTo(3, 5); }
                    ctx.closePath();
                    ctx.fill();
                }
            }

        Text {
            id: coinLabel
            font.pixelSize: Math.max(8, Math.round(root.pixelFontVar * 0.85))
            font.bold: false
            font.capitalization: Font.AllUppercase
            color: Kirigami.Theme.textColor
            text: Plasmoid.configuration.coinNameAbbreviation
        }
        }

        Text {
            id: priceLabel
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: root.pixelFontVar
            font.bold: true
            color: Kirigami.Theme.textColor
            text: Plasmoid.configuration.symbol + (getApi.price !== (-1) ? getApi.price : "?")
        }
    }
}
