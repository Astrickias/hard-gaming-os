import QtQuick 2.15
// Das Folienbild enthält das HG-Logo bereits; deshalb hier nur Text darunter.
Item {
    width: 800; height: 450
    Image { anchors.fill: parent; source: "slide1.jpg"; fillMode: Image.PreserveAspectCrop }
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom; anchors.bottomMargin: parent.height * 0.12
        spacing: 8
        Text { text: "Hard Gaming OS wird installiert"; color: "#ffffff"; font.pixelSize: 26; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
        Text { text: "Gaming & Allround · Hard Gaming Labs"; color: "#9bf7a0"; font.pixelSize: 17; anchors.horizontalCenter: parent.horizontalCenter }
    }
}
