import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0
Rectangle {
    width: 1920; height: 1080; color: "#09120b"
    Image { anchors.fill: parent; source: "background.jpg"; fillMode: Image.PreserveAspectCrop }
    Rectangle { anchors.centerIn: parent; width: 420; height: 370; radius: 14; color: "#dd09120b"
        Column { anchors.centerIn: parent; spacing: 14
            Image { source: "logo.png"; width: 160; height: 100; fillMode: Image.PreserveAspectFit; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "Hard Gaming OS"; color: "white"; font.pixelSize: 26; anchors.horizontalCenter: parent.horizontalCenter }
            TextField { id: username; width: 300; placeholderText: "Benutzername" }
            TextField { id: password; width: 300; placeholderText: "Passwort"; echoMode: TextInput.Password; onAccepted: sddm.login(username.text, password.text, session.index) }
            ComboBox { id: session; width: 300; model: sessionModel; textRole: "name" }
            Button { text: "Anmelden"; width: 300; onClicked: sddm.login(username.text, password.text, session.index) }
        }
    }
}
