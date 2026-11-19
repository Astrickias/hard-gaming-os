// Hello Hard Gaming OS – eigene App (Qt Quick, läuft über das qml-Werkzeug von Qt 6).
// Aktionen laufen über hgos://-Links (hgos-url), Webseiten über den Standardbrowser.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtCore

ApplicationWindow {
    id: root
    width: 1180
    height: 760
    minimumWidth: 900
    minimumHeight: 600
    visible: true
    title: "Hello Hard Gaming OS"
    color: "#0b1013"

    readonly property bool live: Qt.application.arguments.indexOf("--live") >= 0
    readonly property string version: "2.6.0 Beta"
    readonly property color green: "#54ef61"
    readonly property color greenDark: "#20332b"
    readonly property color text: "#eaf0f0"
    readonly property color textDim: "#aebec0"
    readonly property color card: "#141e22"
    readonly property color border: "#2c3a3e"
    property int page: 0

    // Merkt sich, ob Hello beim Anmelden starten soll (liest hg-welcome-autostart).
    Settings {
        id: prefs
        location: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/hg-welcome.conf"
        property bool showOnStartup: true
    }

    function open(url) { Qt.openUrlExternally(url) }

    readonly property var pages: [
        { title: "Startseite", glyph: "⌂" },
        { title: "System", glyph: "⬇" },
        { title: "Gaming", glyph: "▣" },
        { title: "Craft Apps", glyph: "✦" },
        { title: "Hard Gaming", glyph: "◆" },
        { title: "Hilfe", glyph: "ⓘ" }
    ]

    // ---------- wiederverwendbare Bausteine ----------
    component ActionCard: Rectangle {
        id: cardItem
        property string glyph: ""
        property string heading: ""
        property string body: ""
        property string action: ""
        property string url: ""
        Layout.fillWidth: true
        Layout.preferredHeight: 190
        radius: 16
        color: hover.hovered ? "#18252a" : root.card
        border.color: hover.hovered ? "#3d5a47" : root.border
        HoverHandler { id: hover; cursorShape: cardItem.url !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor }
        TapHandler { enabled: cardItem.url !== ""; onTapped: root.open(cardItem.url) }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 8
            Label { text: cardItem.glyph; color: root.green; font.pixelSize: 24 }
            Label { text: cardItem.heading; color: root.text; font.pixelSize: 18; font.bold: true }
            Label {
                text: cardItem.body; color: root.textDim; font.pixelSize: 14
                wrapMode: Text.WordWrap; Layout.fillWidth: true; Layout.fillHeight: true
                verticalAlignment: Text.AlignTop
            }
            Label { visible: cardItem.action !== ""; text: cardItem.action; color: "#87ed7a"; font.pixelSize: 14; font.bold: true }
        }
    }

    component PageHeader: ColumnLayout {
        property string eyebrow: ""
        property string heading: ""
        property string body: ""
        spacing: 6
        Layout.fillWidth: true
        Label { text: parent.eyebrow; color: "#76e766"; font.pixelSize: 12; font.bold: true; font.letterSpacing: 3 }
        Label { text: parent.heading; color: root.text; font.pixelSize: 34; font.bold: true }
        Label {
            text: parent.body; color: root.textDim; font.pixelSize: 15
            wrapMode: Text.WordWrap; Layout.fillWidth: true; Layout.maximumWidth: 720
        }
    }

    // ---------- Layout ----------
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Seitenleiste
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 260
            color: "#10181b"
            Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: "#253236" }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 6

                Image {
                    source: "../hg-os.png"
                    Layout.preferredWidth: 170
                    Layout.preferredHeight: 120
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignLeft
                    smooth: true
                }
                Label { text: "HARD GAMING OS"; color: root.text; font.pixelSize: 13; font.bold: true; font.letterSpacing: 2 }
                Label { text: "WELCOME"; color: "#6dff5d"; font.pixelSize: 11; font.letterSpacing: 3 }
                Item { Layout.preferredHeight: 26 }

                Repeater {
                    model: root.pages
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: 10
                        color: root.page === index ? root.greenDark : (navHover.hovered ? "#16231f" : "transparent")
                        HoverHandler { id: navHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: root.page = index }
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            text: modelData.glyph + "   " + modelData.title
                            color: root.page === index ? "#8aff75" : "#b7c5c7"
                            font.pixelSize: 15
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Image {
                    source: "../hg-labs.png"
                    Layout.preferredWidth: 105
                    Layout.preferredHeight: 70
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignLeft
                }
                Label { text: "Entwickelt von Hard Gaming Labs"; color: "#859596"; font.pixelSize: 11 }
                CheckBox {
                    id: startupBox
                    checked: prefs.showOnStartup
                    onToggled: prefs.showOnStartup = checked
                    contentItem: Label {
                        leftPadding: startupBox.indicator.width + 8
                        text: "Beim Start anzeigen"; color: "#b7c5c7"; font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // Inhalt
        ScrollView {
            id: scroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: scroll.availableWidth
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 40
                    Layout.bottomMargin: 0
                    Label { text: "HARD GAMING DESKTOP"; color: "#8c9d9f"; font.pixelSize: 11; font.letterSpacing: 2; Layout.fillWidth: true }
                    Rectangle {
                        radius: 14; color: "#1c292c"; border.color: "#334044"
                        Layout.preferredHeight: 28; Layout.preferredWidth: badge.implicitWidth + 24
                        Label { id: badge; anchors.centerIn: parent; text: root.live ? "Live-System" : "Version " + root.version; color: root.textDim; font.pixelSize: 12 }
                    }
                }

                StackLayout {
                    Layout.fillWidth: true
                    Layout.margins: 40
                    currentIndex: root.page

                    // 0 Startseite
                    ColumnLayout {
                        spacing: 24
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 300
                            radius: 20
                            clip: true
                            border.color: "#32443a"
                            color: "#14251e"
                            Image {
                                anchors.fill: parent
                                source: "../wallpaper.jpg"
                                fillMode: Image.PreserveAspectCrop
                                opacity: 0.35
                            }
                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 44
                                width: parent.width * 0.6
                                spacing: 12
                                Label { text: "WILLKOMMEN"; color: "#76e766"; font.pixelSize: 12; font.bold: true; font.letterSpacing: 3 }
                                Label { text: "Dein System."; color: root.text; font.pixelSize: 44; font.bold: true }
                                Label { text: "Deine Möglichkeiten."; color: "#79e76e"; font.pixelSize: 44; font.bold: true }
                                Label {
                                    text: "Hard Gaming OS – eine vertraute Desktop-Oberfläche mit der Freiheit von Linux."
                                    color: "#b8c8c5"; font.pixelSize: 15; wrapMode: Text.WordWrap; Layout.fillWidth: true
                                }
                                RowLayout {
                                    spacing: 12
                                    Button {
                                        text: root.live ? "Hard Gaming OS installieren" : "Update Center öffnen"
                                        onClicked: root.open(root.live ? "hgos://install" : "hgos://update")
                                        palette.button: "#76e66a"; palette.buttonText: "#102013"
                                        font.bold: true
                                    }
                                    Button {
                                        text: "Apps entdecken"
                                        onClicked: root.page = 2
                                    }
                                }
                            }
                        }
                        GridLayout {
                            columns: 2; columnSpacing: 16; rowSpacing: 16; Layout.fillWidth: true
                            ActionCard { glyph: "⬇"; heading: root.live ? "Installieren" : "System aktuell halten"
                                body: root.live ? "Installiere Hard Gaming OS aus dem Live-System auf deine Festplatte." : "Das Update Center zeigt neue Updates unten rechts in der Taskleiste an."
                                action: root.live ? "Installer starten →" : "Update Center öffnen →"
                                url: root.live ? "hgos://install" : "hgos://update" }
                            ActionCard { glyph: "▣"; heading: "Gaming"; body: "Steam, Lutris und Heroic sind schon installiert."; action: "Zu den Spielen →"
                                TapHandler { onTapped: root.page = 2 } }
                        }
                    }

                    // 1 System
                    ColumnLayout {
                        spacing: 24
                        PageHeader { eyebrow: "SYSTEM"; heading: "Installieren und aktualisieren"
                            body: "Alles, was Hard Gaming OS auf dem neuesten Stand hält." }
                        GridLayout {
                            columns: 2; columnSpacing: 16; rowSpacing: 16; Layout.fillWidth: true
                            ActionCard { visible: root.live; glyph: "⬇"; heading: "Hard Gaming OS installieren"
                                body: "Startet den Installer. Er führt dich Schritt für Schritt durch Sprache, Festplatte und Benutzer."
                                action: "Installer starten →"; url: "hgos://install" }
                            ActionCard { glyph: "⟳"; heading: "Hard Gaming Update Center"
                                body: "Updates für System, Treiber, Programme und Flatpaks. Neue Updates meldet es unten rechts in der Taskleiste."
                                action: "Update Center öffnen →"; url: "hgos://update" }
                            ActionCard { glyph: "◐"; heading: "Hard-Gaming-Design"
                                body: "Setzt Plasma-Design, grüne Akzente und HG-Wallpaper für deinen Benutzer (wieder) auf den Hard-Gaming-Standard."
                                action: "Design übernehmen →"; url: "hgos://design" }
                            ActionCard { glyph: "⚙"; heading: "Systemeinstellungen"
                                body: "Bildschirm, Ton, Netzwerk, Design und mehr."
                                action: "Einstellungen öffnen →"; url: "hgos://settings" }
                        }
                    }

                    // 2 Gaming
                    ColumnLayout {
                        spacing: 24
                        PageHeader { eyebrow: "GAMING"; heading: "Deine Spiele"
                            body: "Die wichtigsten Launcher sind vorinstalliert. Ein Klick öffnet sie." }
                        GridLayout {
                            columns: 2; columnSpacing: 16; rowSpacing: 16; Layout.fillWidth: true
                            ActionCard { glyph: "▣"; heading: "Steam"; body: "Deine Steam-Bibliothek mit Proton für Windows-Spiele."
                                action: "Steam öffnen →"; url: "steam://open/main" }
                            ActionCard { glyph: "◈"; heading: "Heroic Games Launcher"; body: "Spiele von Epic, GOG und Amazon."
                                action: "Heroic öffnen →"; url: "hgos://app/heroic" }
                            ActionCard { glyph: "◇"; heading: "Lutris"; body: "Alle weiteren Spiele, Emulatoren und Installer an einem Ort."
                                action: "Lutris öffnen →"; url: "hgos://app/lutris" }
                            ActionCard { glyph: "▤"; heading: "MangoHud & GameMode"; body: "FPS-Anzeige und mehr Leistung im Spiel. In Steam unter Startoptionen: mangohud gamemoderun %command%"
                                action: "" }
                        }
                    }

                    // 3 Craft Apps
                    ColumnLayout {
                        spacing: 24
                        PageHeader { eyebrow: "CRAFT APPS"; heading: "Kreativ werden"
                            body: "Kreativprogramme von ArtCraft. Die Installation läuft über den offiziellen Launcher." }
                        GridLayout {
                            columns: 2; columnSpacing: 16; rowSpacing: 16; Layout.fillWidth: true
                            ActionCard { glyph: "✦"; heading: "ArtCraft Launcher"; body: "Lade den Launcher von der offiziellen Release-Seite."
                                action: "Releases öffnen ↗"; url: "https://github.com/storytold/craft-launcher/releases" }
                        }
                        Label { text: "ArtCraft ist eine eigenständige Drittanbieter-Marke."; color: "#7e9091"; font.pixelSize: 12 }
                    }

                    // 4 Hard Gaming
                    ColumnLayout {
                        spacing: 24
                        PageHeader { eyebrow: "HARD GAMING"; heading: "Mehr von Hard Gaming"
                            body: "Hard Gaming OS ist ein Projekt von Hard Gaming. Entdecke auch unsere anderen Projekte." }
                        GridLayout {
                            columns: 2; columnSpacing: 16; rowSpacing: 16; Layout.fillWidth: true
                            ActionCard { glyph: "◆"; heading: "Hard Gaming CMS"
                                body: "Das Content-Management-System von Hard Gaming Labs für Gaming-Communities, Clans und Projekte."
                                action: "Mehr erfahren ↗"; url: "https://hardgaming.net/" }
                            ActionCard { glyph: "▲"; heading: "Machi – Stadt der Gespräche"
                                body: "Das kommende Spiel von Hard Gaming Studios. Baue eine Stadt, die von ihren Bewohnern lebt."
                                action: "Zur Website ↗"; url: "https://hardgaming.net/" }
                        }
                    }

                    // 5 Hilfe
                    ColumnLayout {
                        spacing: 24
                        PageHeader { eyebrow: "HILFE"; heading: "Neu bei Linux?"
                            body: "Startmenü, Dateien, Apps und Updates – vieles funktioniert ganz vertraut." }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: guide.implicitHeight + 48
                            radius: 16; color: root.card; border.color: root.border
                            Label {
                                id: guide
                                anchors.fill: parent; anchors.margins: 24
                                wrapMode: Text.WordWrap; color: root.textDim; font.pixelSize: 15; lineHeight: 1.4
                                textFormat: Text.StyledText
                                text: "<b>1.</b> Öffne das Anwendungsmenü unten links in der Taskleiste.<br>" +
                                      "<b>2.</b> Nutze Dolphin für deine Dateien.<br>" +
                                      "<b>3.</b> Neue Programme findest du über die Paketverwaltung oder Flatpak.<br>" +
                                      "<b>4.</b> Halte dein System mit dem Update Center aktuell."
                            }
                        }
                        GridLayout {
                            columns: 2; columnSpacing: 16; rowSpacing: 16; Layout.fillWidth: true
                            ActionCard { glyph: "ⓘ"; heading: "Hard Gaming Website"; body: "Infos, Neuigkeiten und Hilfe zu deinem System."
                                action: "hardgaming.net öffnen ↗"; url: "https://hardgaming.net/" }
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.margins: 40
                    Layout.topMargin: 8
                    wrapMode: Text.WordWrap
                    color: "#7e9091"
                    font.pixelSize: 11
                    textFormat: Text.StyledText
                    linkColor: "#87ed7a"
                    onLinkActivated: (link) => root.open(link)
                    text: "Hello Hard Gaming OS · Version " + root.version + " · © Hard Gaming Labs<br>" +
                          "Hard Gaming OS basiert auf <a href=\"https://cachyos.org/\">CachyOS</a> und " +
                          "<a href=\"https://archlinux.org/\">Arch Linux</a>. Wir danken beiden Projekten."
                }
            }
        }
    }
}
