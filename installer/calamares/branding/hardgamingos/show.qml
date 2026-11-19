import QtQuick 2.15
Item {
    width: 800; height: 450
    Image { anchors.fill: parent; source: "slide1.jpg"; fillMode: Image.PreserveAspectCrop }
    Rectangle { anchors.fill: parent; color: "#990b1510" }
    Column {
        anchors.centerIn: parent; spacing: 14
        Image { source: "logo.png"; width: 128; height: 128; fillMode: Image.PreserveAspectFit; anchors.horizontalCenter: parent.horizontalCenter }
        Text { text: "Hard Gaming OS"; color: "#ffffff"; font.pixelSize: 36; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
        Text { text: "Gaming & Allround · Hard Gaming Labs"; color: "#9bf7a0"; font.pixelSize: 19; anchors.horizontalCenter: parent.horizontalCenter }
    }
}
