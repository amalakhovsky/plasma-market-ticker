/*
SPDX-FileCopyrightText: zayronxio
SPDX-FileCopyrightText: 2026 Andrey Malakhovsky
SPDX-License-Identifier: GPL-3.0-or-later
*/
import QtQuick 2.12
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: plasmoidRoot

    preferredRepresentation: fullRepresentation
    toolTipMainText: Plasmoid.configuration.coinNameAbbreviation.toUpperCase()
    toolTipSubText: fullRepresentationItem ? fullRepresentationItem.changeText : ""

    fullRepresentation: CompactRepresentation {
        heightroot: plasmoidRoot.height
    }
}
