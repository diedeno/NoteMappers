// ============================================================================
//  MuseScore: Music Composition & Notation
//  NoteMapper Pitch Class to Pitch Class Plugin
//  Copyright (c) 2018 by Paul Nauert
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
import QtQuick.Dialogs 1.2
import MuseScore 1.0

MuseScore {
    version: "0.9"
    description: "This plugin maps cpc to cpc (chromatic pitch class)"
    menuPath: "Plugins.NoteMapper.Pitch Class to Pitch Class"

    property int fieldWidth: 45 
    property int fieldHeight: 32 
    property int labelHeight: 24

    // tpcToCpc[n] is cpc (chromatic pitch class) value of tpc n-1
    property var tpcToCpc: [
        3, 10, 5, 0, 7, 2, 9, 4, 11, 6, 1, 8, 3, 10, 5, 0, 7, 2, 9, 4, 11, 
        6, 1, 8, 3, 10, 5, 0, 7, 2, 9, 4, 11, 6, 1 
    ]

    property var defaultTpc: [14, 21, 16, 11, 18, 13, 20, 15, 10, 17, 12, 19]
    // default spellings      C   C#  D   Eb  E   F   F#  G   Ab  A   Bb  B 
    
// ================================================================ DIALOGS

    // get input from user, then launch MAIN
    Dialog {
        id: getInput
        width: 700
        visible: false
        title: "Map Input"
        standardButtons: StandardButton.Help | StandardButton.Apply | StandardButton.Cancel

        onHelp: {
            console.log("getInput: Help");
            var arr = [];
            for (var i = 0; i < toRep.model; i++) {
                var txt = toRep.itemAt(i).text;
                if (txt) {
                    arr.push(Number(txt));
                } else {
                    arr.push(i);
                }
            }
            mapString.text =  arr.toString();
            helpDialog.open(); // this closes getInput dialog on most platforms
        }

        onApply: {
            console.log("getInput: Apply");
            var arr = [];
            for (var i = 0; i < toRep.model; i++) {
                var txt = toRep.itemAt(i).text;
                if (txt) {
                    arr.push(Number(txt));
                } else {
                    arr.push(i);
                }
            }
            main(arr);
        }
        onRejected: {
            console.log("getInput: Cancel");
            Qt.quit();
        }

// inputGrid
        Grid {
            id: inputGrid
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            focus: true
            columns: 13
            spacing: 5
            
            Label { 
                text: "From"
                color: "dark gray"; 
                horizontalAlignment: Text.AlignHCenter
                width: 50
                height: labelHeight 
            }
            Repeater {
                model: 12
                Label { 
                    text: index 
                    color: "dark gray"
                    horizontalAlignment: Text.AlignHCenter
                    width: fieldWidth
                    height: labelHeight 
                }
            }
            
            Label { 
                id: toLabel
                text: "To" 
                color: "black" 
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: 50
                height: fieldHeight 
            }
            Repeater {
                id: toRep
                model: 12
                TextField {
                    width: fieldWidth 
                    height: fieldHeight
                    horizontalAlignment: TextInput.AlignHCenter
                    validator: cpcVal
                    font.pointSize: 11
                    placeholderText: index
                    // to hide placeholderText behind cursor, use
                       // placeholderText: activeFocus ? "" : index 
                }
            }
        } // end inputGrid

        IntValidator { 
            id: cpcVal
            bottom: 0 
            top: 11
        }

// randRect
        Rectangle {
            id: randRect
            anchors.top: inputGrid.bottom
            anchors.left: inputGrid.left
            anchors.right: inputGrid.right
            anchors.topMargin: 20
            height: 90
            color: "light gray"
            border.color: "dark gray"
            border.width: 2
        
            Grid {
                id: randGrid
                anchors.top: randRect.top
                anchors.left: randRect.left
                anchors.margins: 10
                columns: 2
                spacing: 10

                Button {
                    id: randEachButton
                    text: qsTr("Random Each")

                    onClicked: {
                        console.log("getInput: randEachButton");
                        for (var i = 0; i < toRep.model; i++) {
                            toRep.itemAt(i).text = Math.floor(Math.random() * 12);
                        }
                    }
                }
                Label {
                    text: qsTr("Picks a value independently for each input field.")
                    height: randEachButton.height 
                    verticalAlignment: Text.AlignVCenter
                }
            
                Button {
                    id: randAllButton
                    text: qsTr("Random All")

                    onClicked: {
                        console.log("getInput: randAllButton");
                        var randArr = [];
                        for (var j = 0; j < toRep.model; j++) {
                            randArr.push(j);
                        }
                        randArr.sort(function(a, b) {return 0.5 - Math.random()}); // random order sort
                        for (var i = 0; i < toRep.model; i++) {
                            toRep.itemAt(i).text = randArr[i];
                        }
                    }
                }
                Label {
                    text: qsTr("Gives a permutation of all twelve values across the input fields.")
                    height: randAllButton.height
                    verticalAlignment: Text.AlignVCenter
                }
            }
        } // end randRect

// instructions
        Text {
            id: instructions
            anchors.top: randRect.bottom
            anchors.left: inputGrid.left
            anchors.right: inputGrid.right
            anchors.margins: 10
            text: "To map pc X to a new value Y, find X in the 'From' row at the top of the "
                + "interface, and enter Y in the 'To' field directly below it. Click Help "
                + "for more information.<br />"
            font.pointSize: 11
            textFormat: Text.StyledText 
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

// =========== help dialog

    Dialog {
        id: helpDialog
        width: 780
        title: "Help"
        visible: false
        standardButtons: StandardButton.Ok

        onAccepted: {
            loadMapString();
            getInput.open();
            toRep.itemAt(0).forceActiveFocus();
        }

        Text {
            id: helpText
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            text: "Pitch class (pc) values represent steps of the chromatic scale: 0 is C (and "
                + "its enharmonic equivalents), 1 is C-sharp (ditto), and so on. A map determines "
                + "how pc values will be changed in the music you are processing. <b>To map pc "
                + "X to a new value Y, find X in the 'From' row at the top of the interface, and "
                + "enter Y in the 'To' field directly below it.</b> Use as many 'To' fields as your "
                + "map requires, or try randomizing all twelve values; then click Apply.<br /><br />"
                + "New pc values are set in the octave that keeps notes nearest their original "
                + "positions, and they are spelled according to built-in defaults (e.g. 8 is A-flat "
                + "rather than G-sharp).<br /><br />Copy the Import/Export string below to save it as text "
                + "in a score or text file. Paste a previously saved string to re-use it here.<br />"
            font.pointSize: 10
            textFormat: Text.StyledText 
            wrapMode: Text.Wrap            
        }
        
        Label {
            id: mapStringLabel
            anchors.top: helpText.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            verticalAlignment: Text.AlignVCenter
            height: fieldHeight 
            text: "Import/Export:"
        }
        TextField {
            id: mapString
            anchors.top: helpText.bottom
            anchors.left: mapStringLabel.right
            anchors.leftMargin: 10
            height: fieldHeight
            width: 500
            font.pointSize: 10
            text: ""
        }
        Text {        // spacer
            anchors.top: mapStringLabel.bottom
            text: ""
        }
    }

    // if mapString is valid map, load it into input fields
    function loadMapString() {
        var arr = mapString.text.split(",");
        if (arr.length !== 12) return;
        for (var i = 0; i < 12; i++) { 
            arr[i] = parseInt(arr[i], 10); 
            if (!isCpc(arr[i])) return;
        }
        // load input fields
        for (var j = 0; j < 12; j++) { 
            toRep.itemAt(j).text = arr[j];
        }
    }

    function isCpc(x) {
        return x % 1 === 0 && -1 < x && x < 12;
    }
//    function isTpc(x) {
//        return x % 1 === 0 && -2 < x && x < 34;
//    }

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

    function makeCpcToCpcMapper(cpcToCpcMap) {
        return function(note) {
            var oldTpc = note.tpc;
            var oldCpc = tpcToCpc[oldTpc + 1];
            var newCpc = cpcToCpcMap[oldCpc];
            if (oldCpc === newCpc) return;                  // in case no mapping needed, we're done
                                                            // otherwise handle PITCH first
            note.pitch += ((newCpc - oldCpc + 18) % 12) - 6;
                                                            // and handle TPC with 2 cases
            if (note.tpc1 !== oldTpc) {                     // case (1) concertTpc !== displayedTpc
                note.tpc2 = defaultTpc[newCpc];
                // shift tpc1 by same amount as tpc2
                note.tpc1 += note.tpc2 - oldTpc;
            } else {                                        // case (2) concertTpc === displayedTpc
                note.tpc1 = defaultTpc[newCpc];
                // shift tpc2 by same amount as tpc1
                note.tpc2 += note.tpc1 - oldTpc;
            }
        }
    }

// ================================================================ MAIN
    
    function main(cpcToCpcArr) {
        console.log("-------- applying map");
        curScore.startCmd();
        applyToNotesInSelection(makeCpcToCpcMapper(cpcToCpcArr));
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
            toRep.itemAt(0).forceActiveFocus();
        }
    }
}
