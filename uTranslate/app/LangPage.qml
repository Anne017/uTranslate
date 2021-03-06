/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 0.1 as ListItem

import "components"

Page {
    // id: langPage
    title: langPage.getTitle()

    property bool doSelect: false // show only selected langs ?

    head {
        actions : [
            Action {
                id : switchAction
                iconName: "select"
                text: i18n.tr("Show selected")
                onTriggered: {
                    langPage.doSelect = !langPage.doSelect
                    console.debug("show selected"+langPage.doSelect)
                    langPage.reloadLangs();
                }
            }
        ]
    }

    ListView {
        id: langList
        /*
        ListModelJson {
            liste: GlosbeLang.glosbe_lang_array
            id: langListModel
        }
        */
        anchors.fill: parent
        anchors.rightMargin: fastScroll.showing ? fastScroll.width - units.gu(1) : 0
        clip: true
        currentIndex: -1

        model: langListModel

        function getSectionText(index) {
            return langListModel.get(index).name.substring(0,1)
        }

        delegate: ListItem.Standard {
            // Both "name" and "team" are taken from the model
            text: i18n.tr(name) +" ("+code+")"
            // iconSource: Qt.resolvedUrl(icon_path)
            // fallbackIconSource: Qt.resolvedUrl("graphics/uTranslate.png")

            // TODO : handle flag
            // progression: (code === 'fr') ? true : false;
            // iconSource: Qt.resolvedUrl("graphics/uTranslate.png")
            // onClicked: console.debug("listItem clicked")

            control: Switch {
                checked: (used == 1)? true : false; // int2bool
                // text: "Click me"
                // width: units.gu(19)

                onClicked: {
                    console.debug("switch : "+code+" Clicked, value="+checked)
                    var val = (checked)? 1 : 0; // bool2int
                    console.debug("valDB="+val);
                    // update of Model
                    langListModel.setProperty(index, "used", val);
                    // console.debug("Model used="+used);

                    // update of db  (directly from the view ??? shouldn't it  be done from the listModel ?)
                    writeUsedLang(code, val);

                    // update other parts of UI
                    // the current page
                    langPage.updateTitle();
                    // the selection
                    if (langPage.doSelect)
                        loadUsedLangs()
                    // the settings page
                    settingsPage.updateLangInfos();
                }
            }
        }

        section {
            property: "name"
            criteria: ViewSection.FirstCharacter
            labelPositioning: ViewSection.InlineLabels
            delegate: SectionDelegate {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                text: section != "" ? section : "#"
            }
        }
    }


    FastScroll {
        id: fastScroll
        listView: langList
        enabled: true
        visible: true
        anchors {
            // top: langList.top
            // bottom: langList.bottom
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
    }

    Component.onCompleted:  {
        langPage.reloadLangs();
    }

    function reloadLangs(){
        if (langPage.doSelect)
            loadUsedLangs()
        else
            loadLangs();
    }

    function getTitle() {
        var nb = countUsedLangs();
        var s0 = "Languages, no selected";
        var s1 = "Languages, %n selected";
        var s2 = "Languages, %n selected";
        var text = my_i18n(s0, s1, s2, nb);
        return text;
    }

    function updateTitle() {
        langPage.title = langPage.getTitle();
    }
}
