// ============================================================================
//  MuseScore: Music Composition & Notation
//  NoteMapper Pitch Class Speller Plugin
//  Copyright (c) 2018 by Paul Nauert
//  
//  The "Show accidentals on all notes" feature is adapted from
//  the Implied Accidentals plugin by Jörn Eichler (heuchi)
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
// ============================================================================

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.3
import QtQuick.Dialogs 1.2
import MuseScore 1.0

MuseScore {
    version: "0.9"
    description: "This plugin applies a user-specified spelling to each pitch class, "
               + "with an option to show accidentals explicitly on every note."

    menuPath: "Plugins.NoteMapper.Pc Speller"
/*  to avoid creating a NoteMapper submenu in your Plugins Menu, swap the menuPath statements above/below this line
    menuPath: "Plugins.Composing Tools.NoteMapper Pc Speller"
*/

    // tpcAndSpelling[n][0] is tpc values, and tpcAndSpelling[n][1] is spellings, 
    // available for pc n. tpc 99 means preserve a pc's existing spelling(s).
    // Unicode accidentals require font "FreeSerif"; otherwise function checkFont() 
    // will switch to alphanumeric accidentals (per altTpcAndSpelling).
    property var tpcAndSpelling: [
        [[99, 26, 14, 2], ["--", "B\u266F", "C", "D\uD834\uDD2B"]], 
        [[99, 33, 21, 9], ["--", "B\uD834\uDD2A", "C\u266F", "D\u266D"]], 
        [[99, 28, 16, 4], ["--", "C\uD834\uDD2A", "D", "E\uD834\uDD2B"]], 
        [[99, 23, 11, -1], ["--", "D\u266F", "E\u266D", "F\uD834\uDD2B"]], 
        [[99, 30, 18, 6], ["--", "D\uD834\uDD2A", "E", "F\u266D"]], 
        [[99, 25, 13, 1], ["--", "E\u266F", "F", "G\uD834\uDD2B"]], 
        [[99, 32, 20, 8], ["--", "E\uD834\uDD2A", "F\u266F", "G\u266D"]], 
        [[99, 27, 15, 3], ["--", "F\uD834\uDD2A", "G", "A\uD834\uDD2B"]], 
        [[99, 22, 10], ["--", "G\u266F", "A\u266D"]], 
        [[99, 29, 17, 5], ["--", "G\uD834\uDD2A", "A", "B\uD834\uDD2B"]], 
        [[99, 24, 12, 0], ["--", "A\u266F", "B\u266D", "C\uD834\uDD2B"]], 
        [[99, 31, 19, 7], ["--", "A\uD834\uDD2A", "B", "C\u266D"]]
    ]
    property var altTpcAndSpelling: [
        [[99, 26, 14, 2], ["--", "B#", "C", "Dbb"]], 
        [[99, 33, 21, 9], ["--", "Bx", "C#", "Db"]], 
        [[99, 28, 16, 4], ["--", "Cx", "D", "Ebb"]], 
        [[99, 23, 11, -1], ["--", "D#", "Eb", "Fbb"]], 
        [[99, 30, 18, 6], ["--", "Dx", "E", "Fb"]], 
        [[99, 25, 13, 1], ["--", "E#", "F", "Gbb"]], 
        [[99, 32, 20, 8], ["--", "Ex", "F#", "Gb"]], 
        [[99, 27, 15, 3], ["--", "Fx", "G", "Abb"]], 
        [[99, 22, 10], ["--", "G#", "Ab"]], 
        [[99, 29, 17, 5], ["--", "Gx", "A", "Bbb"]], 
        [[99, 24, 12, 0], ["--", "A#", "Bb", "Cbb"]], 
        [[99, 31, 19, 7], ["--", "Ax", "B", "Cb"]]
    ]

    // tpcToCpc[n] is cpc (chromatic pitch class) value of tpc n-1
    property var tpcToCpc: [
        3, 10, 5, 0, 7, 2, 9, 4, 11, 6, 1, 8, 3, 10, 5, 0, 7, 2, 9, 4, 11, 
        6, 1, 8, 3, 10, 5, 0, 7, 2, 9, 4, 11, 6, 1 
    ]

    property int keyWidth: 105
    property int keyHeight: 130
    property real keyRadius: 2.5
    property var ebony: "#AAAAAA"
    property var ivory: "#CCCCCC"
    property var keyBorder: "#111111"

    property var keyFont: "FreeSerif"
    property int fSize: 12

    function checkFont() {
        if (Qt.fontFamilies().indexOf("FreeSerif") < 0) {
            tpcAndSpelling = altTpcAndSpelling;
            fSize = 10;
        }
    }

// ================================================================ DIALOGS

    // get input from user, then launch MAIN
    Dialog {
        id: getInput
        width: 800
        visible: false
        title: "Map Input"
        standardButtons: StandardButton.Apply | StandardButton.Cancel

        onApply: {
            console.log("getInput: Apply");
            var arr = [
                tpcAndSpelling[0][0][cb0.currentIndex],
                tpcAndSpelling[1][0][cb1.currentIndex],
                tpcAndSpelling[2][0][cb2.currentIndex],
                tpcAndSpelling[3][0][cb3.currentIndex],
                tpcAndSpelling[4][0][cb4.currentIndex],
                tpcAndSpelling[5][0][cb5.currentIndex],
                tpcAndSpelling[6][0][cb6.currentIndex],
                tpcAndSpelling[7][0][cb7.currentIndex],
                tpcAndSpelling[8][0][cb8.currentIndex],
                tpcAndSpelling[9][0][cb9.currentIndex],
                tpcAndSpelling[10][0][cb10.currentIndex],
                tpcAndSpelling[11][0][cb11.currentIndex]
            ];
            main(arr);
        }
        onRejected: {
            console.log("getInput: Cancel");
            Qt.quit();
        }

        Item {
            id: kb
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            height: keyHeight + 15; width: keyWidth * 7 + 6

            Rectangle {
                id: rect0
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 10
                height: keyHeight; width: keyWidth
                border.width: 2; border.color: keyBorder
                color: ivory
                radius: keyRadius
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "0"
                }
                ComboBox {
                    id: cb0
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    width: parent.width - 20
                    style: ComboBoxStyle {id: cbStyle; font.family: keyFont; font.pointSize: fSize }
                    model: tpcAndSpelling[0][1]
                }
            }
            Rectangle {
                id: rect2
                anchors.top: rect0.top
                anchors.left: rect0.right
                anchors.leftMargin: -2
                height: keyHeight; width: keyWidth
                border.width: 2; border.color: keyBorder
                color: ivory
                radius: keyRadius
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "2"
                }
                ComboBox {
                    id: cb2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    width: parent.width - 20
                    style: ComboBoxStyle {id: cbStyle; font.family: keyFont; font.pointSize: fSize }
                    model: tpcAndSpelling[2][1]
                }
            }
            Rectangle {
                id: rect4
                anchors.top: rect2.top
                anchors.left: rect2.right
                anchors.leftMargin: -2
                height: keyHeight; width: keyWidth
                border.width: 2; border.color: keyBorder
                color: ivory
                radius: keyRadius
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "4"
                }
                ComboBox {
                    id: cb4
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    width: parent.width - 20
                    style: ComboBoxStyle {id: cbStyle; font.family: keyFont; font.pointSize: fSize }
                    model: tpcAndSpelling[4][1]
                }
            }
            Rectangle {
                id: rect5
                anchors.top: rect4.top
                anchors.left: rect4.right
                anchors.leftMargin: -2
                height: keyHeight; width: keyWidth
                border.width: 2; border.color: keyBorder
                color: ivory
                radius: keyRadius
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "5"
                }
                ComboBox {
                    id: cb5
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    width: parent.width - 20
                    style: ComboBoxStyle {id: cbStyle; font.family: keyFont; font.pointSize: fSize }
                    model: tpcAndSpelling[5][1]
                }
            }
            Rectangle {
                id: rect7
                anchors.top: rect5.top
                anchors.left: rect5.right
                anchors.leftMargin: -2
                height: keyHeight; width: keyWidth
                border.width: 2; border.color: keyBorder
                color: ivory
                radius: keyRadius
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "7"
                }
                ComboBox {
                    id: cb7
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    width: parent.width - 20
                    style: ComboBoxStyle {id: cbStyle; font.family: keyFont; font.pointSize: fSize }
                    model: tpcAndSpelling[7][1]
                }
            }
            Rectangle {
                id: rect9
                anchors.top: rect7.top
                anchors.left: rect7.right
                anchors.leftMargin: -2
                height: keyHeight; width: keyWidth
                border.width: 2; border.color: keyBorder
                color: ivory
                radius: keyRadius
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "9"
                }
                ComboBox {
                    id: cb9
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    width: parent.width - 20
                    style: ComboBoxStyle {id: cbStyle; font.family: keyFont; font.pointSize: fSize }
                    model: tpcAndSpelling[9][1]
                }
            }
            Rectangle {
                id: rect11
                anchors.top: rect9.top
                anchors.left: rect9.right
                anchors.leftMargin: -2
                height: keyHeight; width: keyWidth
                border.width: 2; border.color: keyBorder
                color: ivory
                radius: keyRadius
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "11"
                }
                ComboBox {
                    id: cb11
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    width: parent.width - 20
                    style: ComboBoxStyle {id: cbStyle; font.family: keyFont; font.pointSize: fSize }
                    model: tpcAndSpelling[11][1]
                }
            }
            Rectangle {
                id: rect1
                anchors.top: rect0.top
                anchors.left: rect0.left
                anchors.leftMargin: keyWidth * 5 / 8
                height: keyHeight * 5 / 8; width: keyWidth * 3 / 4
                border.width: 2; border.color: keyBorder
                color: ebony
                radius: keyRadius
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "1"
                }
                ComboBox {
                    id: cb1
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5
                    width: parent.width - 10
                    style: ComboBoxStyle {id: cbStyle; font.family: keyFont; font.pointSize: fSize }
                    model: tpcAndSpelling[1][1]
                }
            }
            Rectangle {
                id: rect3
                anchors.top: rect2.top
                anchors.left: rect2.left
                anchors.leftMargin: keyWidth * 5 / 8
                height: keyHeight * 5 / 8; width: keyWidth * 3 / 4
                border.width: 2; border.color: keyBorder
                color: ebony
                radius: keyRadius
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "3"
                }
                ComboBox {
                    id: cb3
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5
                    width: parent.width - 10
                    style: ComboBoxStyle {id: cbStyle; font.family: keyFont; font.pointSize: fSize }
                    model: tpcAndSpelling[3][1]
                }
            }
            Rectangle {
                id: rect6
                anchors.top: rect5.top
                anchors.left: rect5.left
                anchors.leftMargin: keyWidth * 5 / 8
                height: keyHeight * 5 / 8; width: keyWidth * 3 / 4
                border.width: 2; border.color: keyBorder
                color: ebony
                radius: keyRadius
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "6"
                }
                ComboBox {
                    id: cb6
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5
                    width: parent.width - 10
                    style: ComboBoxStyle {id: cbStyle; font.family: keyFont; font.pointSize: fSize }
                    model: tpcAndSpelling[6][1]
                }
            }
            Rectangle {
                id: rect8
                anchors.top: rect7.top
                anchors.left: rect7.left
                anchors.leftMargin: keyWidth * 5 / 8
                height: keyHeight * 5 / 8; width: keyWidth * 3 / 4
                border.width: 2; border.color: keyBorder
                color: ebony
                radius: keyRadius
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "8"
                }
                ComboBox {
                    id: cb8
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5
                    width: parent.width - 10
                    style: ComboBoxStyle {id: cbStyle; font.family: keyFont; font.pointSize: fSize }
                    model: tpcAndSpelling[8][1]
                }
            }
            Rectangle {
                id: rect10
                anchors.top: rect9.top
                anchors.left: rect9.left
                anchors.leftMargin: keyWidth * 5 / 8
                height: keyHeight * 5 / 8; width: keyWidth * 3 / 4
                border.width: 2; border.color: keyBorder
                color: ebony
                radius: keyRadius
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "10"
                }
                ComboBox {
                    id: cb10
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5
                    width: parent.width - 10
                    style: ComboBoxStyle {id: cbStyle; font.family: keyFont; font.pointSize: fSize }
                    model: tpcAndSpelling[10][1]
                }
            }

        } // end kb

// accBoxes
        CheckBox {
            id: addAccBox
            anchors.top: kb.bottom
            anchors.left: kb.left
            anchors.margins: 20
            text: qsTr("Show accidentals on all notes")
            checked: false
        }
        CheckBox {
            id: natBox
            anchors.top: addAccBox.bottom
            anchors.left: addAccBox.left
            anchors.topMargin: 10
            anchors.leftMargin: 50
            text: qsTr("Include naturals")
            checked: true
            enabled: addAccBox.checked
            opacity: enabled ? 1.0 : 0.5
        }
        CheckBox {
            id: tieBox
            anchors.top: natBox.bottom
            anchors.left: natBox.left
            anchors.topMargin: 10
            text: qsTr("Include tied notes")
            checked: false
            enabled: addAccBox.checked
            opacity: enabled ? 1.0 : 0.5
        }

// instructions
        Text {
            id: instructions
            anchors.top: tieBox.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            anchors.topMargin: 20
            text: "Choose a spelling for each pitch class (pc), or leave the setting at '--' to "
                + "preserve a pc's existing spelling(s). Use the check boxes to show accidentals "
                + "explicitly on every note.\n"
            font.pointSize: 10
            // textFormat: Text.StyledText
            wrapMode: Text.Wrap            
        }

    } // end getInput dialog

// =========== error dialog, terminates execution

    MessageDialog {
        id: errorDialog
        title: "Error"
        visible: false
        onAccepted: {
            Qt.quit();
        }
    }

    function error(msg) {
        errorDialog.text = qsTr(msg);
        errorDialog.open();
    }    

// ================================================================ NOTE PROCESSING
    
    // Apply the given function to all notes in selection
    // or, if nothing is selected, in the entire score
    function applyToNotesInSelection(func) {
        var cursor = curScore.newCursor();
        cursor.rewind(1);
        var startStaff;
        var endStaff;
        var endTick;
        var fullScore = false;
        if (!cursor.segment) { // no selection
            fullScore = true;
            startStaff = 0; // start with 1st staff
            endStaff = curScore.nstaves - 1; // and end with last
        } else {
            startStaff = cursor.staffIdx;
            cursor.rewind(2);
            if (cursor.tick == 0) {
                // this happens when the selection includes the last measure of the score.
                // rewind(2) goes behind the last segment (where there's none) and sets tick=0
                endTick = curScore.lastSegment.tick + 1;
            } else {
                endTick = cursor.tick;
            }
            endStaff = cursor.staffIdx;
        }
        console.log(startStaff + " - " + endStaff + " - " + endTick)
        for (var staff = startStaff; staff <= endStaff; staff++) {
            for (var voice = 0; voice < 4; voice++) {
                cursor.rewind(1); // sets voice to 0
                cursor.voice = voice; //voice has to be set after goTo
                cursor.staffIdx = staff;

                if (fullScore) {
                    cursor.rewind(0); // if no selection, beginning of score
                }

                while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                    if (cursor.element && cursor.element.type == Element.CHORD) {

                        // handle any graceNotes
                        var graceChords = cursor.element.graceNotes;
                        for (var j = 0; j < graceChords.length; j++) {
                            var notes = graceChords[j].notes;
                            for (var i = 0; i < notes.length; i++) {
                                func(notes[i]);
                            }
                        }
                        
                        // handle notes
                        var notes = cursor.element.notes;
                        for (var i = 0; i < notes.length; i++) {
                            func(notes[i]);
                        }
                    }
                    cursor.next();
                }
            }
        }
    }

    function makePcSpeller(spellingArray) {
        return function(note) {
            // get displayedCpc aka oldCpc
            var oldTpc = note.tpc;
            var oldCpc = tpcToCpc[oldTpc + 1];      // toDo: declare tpcToCpc
            // lookup newTpc
            var newTpc = spellingArray[oldCpc];
            // 99 means "preserve existing spelling(s)"
            if ((newTpc === 99) || (newTpc === oldTpc)) return; // in case no mapping needed, we're done

            if (note.tpc1 !== oldTpc) {                         // case (1) concertTpc !== displayedTpc
                note.tpc2 = newTpc;
                // don't touch note.tpc1
            } else {                                            // case (2) concertTpc === displayedTpc
                note.tpc1 = newTpc;
                // don't touch note.tpc2
            }
        }
    }

    // return type of accidental associated with given tonal pitch class -1 to 33
    function tpcToAccType(tpc) {
        var type = Accidental.NONE;
        if(tpc < 6) {
            type = Accidental.FLAT2;
        } else if(tpc < 13) {
            type = Accidental.FLAT;
        } else if(tpc < 20) {
            type = Accidental.NATURAL;
        } else if(tpc < 27) {
            type = Accidental.SHARP;
        } else if(tpc < 34) {
            type = Accidental.SHARP2;
        }
        return type;
    }
    
    // if note doesn't already carry explicit accidental, 
    // add one according to status of natBox and tieBox
    function addAcc(note) {
        if (!note.accidental && (tieBox.checked || !note.tieBack)) {
            var accType = tpcToAccType(note.tpc);
            if (natBox.checked || accType !== Accidental.NATURAL) {
                note.accidentalType = accType;
            }
        }
    }    

// ================================================================ MAIN
    
    function main(spellingArray) {
        console.log("-------- applying spellings");
        curScore.startCmd();
        applyToNotesInSelection(makePcSpeller(spellingArray));
        if (addAccBox.checked) {
            console.log("-------- applying accidentals");
            applyToNotesInSelection(addAcc);
        }
        curScore.endCmd();
        console.log("end noteMapper");
        Qt.quit();
    }    

// ================================================================ RUN
    
    onRun: {
        console.log("begin noteMapper");

        if (typeof curScore === 'undefined' || curScore == null) {
            error("NoteMapper plugin requires an open score.\n");
        } else {
            getInput.open();
            cb0.forceActiveFocus();
        }
    }
}
