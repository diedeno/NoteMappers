// ============================================================================
//  MuseScore: Music Composition & Notation
//  NoteMapper Note to Note Plugin
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
import QtQuick.Controls.Styles 1.3
import QtQuick.Dialogs 1.2
import MuseScore 3.0

MuseScore {
    version: "0.9"
    description: "This plugin maps note to note (letter-names and optional accidentals)"

    menuPath: "Plugins.NoteMapper.Note to Note"
/*  to avoid creating a NoteMapper submenu in your Plugins Menu, swap the menuPath statements above/below this line
    menuPath: "Plugins.Composing Tools.NoteMapper Note to Note"
*/
     
       Component.onCompleted : {
        if (mscoreMajorVersion >= 4) {
            title = qsTr("Notemapper-Note2Note") ;
           // thumbnailName = "thumbnail.png";
            categoryCode = "composing-arranging-tools";
           }
        }   

    property var letters: ["A", "B", "C", "D", "E", "F", "G"]
    property var accidentals: ["\uD834\uDD2B", "\u266D", "\u266E", "\u266F", "\uD834\uDD2A"]
    // unicode accidentals, function checkFont() 
    // reverts these to alphanumeric accidentals if "FreeSerif" font missing

    // tonal pitch classes in an order easily computed from ComboBox inputs
    property var tpcs: [
        3, 10, 17, 24, 31, 5, 12, 19, 26, 33, 0, 7, 14, 21, 28, 
        2, 9, 16, 23, 30, 4, 11, 18, 25, 32, -1, 6, 13, 20, 27, 
        1, 8, 15, 22, 29
    ]
    //  tpcs[invTpcs[n]] = n - 1  //  invTpcs[tpcs[n] + 1] = n
    property var invTpcs: [
        25, 10, 30, 15, 0, 20, 5, 26, 11, 31, 16, 1, 21, 6, 27,
        12, 32, 17, 2, 22, 7, 28, 13, 33, 18, 3, 23, 8, 29, 14,
        34, 19, 4, 24, 9
    ]
    // spellings[n] is English-language name of tpcs[n], with unicode accidentals, 
    // function checkFont() reverts these to alphanumeric accidentals if "FreeSerif" font missing
    property var spellings: [
        "A\uD834\uDD2B","A\u266D","A","A\u266F","A\uD834\uDD2A","B\uD834\uDD2B","B\u266D","B","B\u266F","B\uD834\uDD2A",
        "C\uD834\uDD2B","C\u266D","C","C\u266F","C\uD834\uDD2A","D\uD834\uDD2B","D\u266D","D","D\u266F","D\uD834\uDD2A",
        "E\uD834\uDD2B","E\u266D","E","E\u266F","E\uD834\uDD2A","F\uD834\uDD2B","F\u266D","F","F\u266F","F\uD834\uDD2A",
        "G\uD834\uDD2B","G\u266D","G","G\u266F","G\uD834\uDD2A"
    ]
    // tpcToCpc[n] is cpc (chromatic pitch class) value of tpc n-1
    property var tpcToCpc: [
        3, 10, 5, 0, 7, 2, 9, 4, 11, 6, 1, 8, 3, 10, 5, 0, 7, 2, 9, 4, 11, 
        6, 1, 8, 3, 10, 5, 0, 7, 2, 9, 4, 11, 6, 1 
    ]

    // dialog layout
    property int cbWidth: 75
    property real gap: 6
    property int fSize: 12
    
    // revert to alphanumeric accidentals if "FreeSerif" font missing
    function checkFont() {
        if (Qt.fontFamilies().indexOf("FreeSerif") < 0) {
            spellings = [
                "Abb","Ab","A","A#","Ax","Bbb","Bb","B","B#","Bx","Cbb","Cb","C","C#","Cx",
                "Dbb","Db","D","D#","Dx","Ebb","Eb","E","E#","Ex","Fbb","Fb","F","F#","Fx",
                "Gbb","Gb","G","G#","Gx"
            ];
            accidentals = ["bb", "b", "(nat)", "#", "x"];
            fSize = 10;
        }
    }

// ================================================================ DIALOGS

    // get input from user, then launch MAIN
    Dialog {
        id: getInput
        width: 750
        visible: false
        title: "Map Input"
        standardButtons: StandardButton.Help | StandardButton.Apply | StandardButton.Cancel

        property var tpcToTpcMap: initMap()

        onHelp: {
            console.log("getInput: Help");
            var arr = fillDefaults(tpcToTpcMap.slice()); // slice leaves map untouched
            var str = arr.toString();
            mapString.text = str.replace(/,/g,", "); // for better textWrap
            applyImport.checked = false;
            helpDialog.open(); // this closes getInput dialog on most platforms
        }
        onApply: {
            console.log("getInput: Apply");
            main(fillDefaults(tpcToTpcMap));
        }
        onRejected: {
            console.log("getInput: Cancel");
            quit();
        }

// addMappingArea
        Label {
            id: addHead
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: gap
            text: "Add a mapping..."
        }
        Label {
            id: fromLabel
            anchors.top: addHead.bottom
            anchors.left: addHead.left
            anchors.topMargin: gap
            text: "From: "
        }
        Label {
            anchors.top: fromLabel.top
            anchors.left: cbToLetter.left
            text: "To: "
        }
        
        ComboBox {
            id: cbFromLetter
            style: ComboBoxStyle { font.family: "FreeSerif"; font.pointSize: fSize } // nice accidentals
            anchors.top: fromLabel.bottom
            anchors.left: fromLabel.left
            anchors.topMargin: gap
            width: cbWidth
            activeFocusOnPress: true
            model: letters
        }
        ComboBox {
            id: cbFromAcc
            style: ComboBoxStyle { font.family: "FreeSerif"; font.pointSize: fSize } // nice accidentals
            anchors.top: cbFromLetter.top
            anchors.left: cbFromLetter.right
            anchors.leftMargin: 2 * gap
            width: cbWidth
            activeFocusOnPress: true
            model: accidentals
        }
        ComboBox {
            id: cbToLetter
            style: ComboBoxStyle { font.family: "FreeSerif"; font.pointSize: fSize } // nice accidentals
            anchors.top: cbFromLetter.top
            anchors.left: cbFromAcc.right
            anchors.leftMargin: 4 * gap
            width: cbWidth
            activeFocusOnPress: true
            model: letters
        }
        ComboBox {
            id: cbToAcc
            style: ComboBoxStyle { font.family: "FreeSerif"; font.pointSize: fSize } // nice accidentals
            anchors.top: cbFromLetter.top
            anchors.left: cbToLetter.right
            anchors.leftMargin: 2 * gap
            width: cbWidth
            activeFocusOnPress: true
            model: accidentals
        }

        Button {
            id: addButton
            anchors.top: cbFromLetter.top
            anchors.left: cbToAcc.right
            anchors.leftMargin: 4 * gap
            text: "Add"
            enabled: cbFromLetter.currentIndex >= 0 && cbToLetter.currentIndex >= 0
            opacity: enabled ? 1.0 : 0.5

            onClicked: {
                if (cbFromAcc.currentIndex == -1) cbFromAcc.currentIndex = 2; // if no accidental: nat
                if (cbToAcc.currentIndex == -1) cbToAcc.currentIndex = 2;
                var fromIndex = cbFromLetter.currentIndex * 5 + cbFromAcc.currentIndex;
                var toIndex = cbToLetter.currentIndex * 5 + cbToAcc.currentIndex;
                resetCBs();

                // if no conflict with existing mappings, add the new one...
                if (getInput.tpcToTpcMap[tpcs[fromIndex] + 1] == 99) {
                    mapMessage.opacity = 0;
                    mapModel.append({ "fromIndex": fromIndex, "toIndex": toIndex });
                    // map tpcs[fromIndex] to tpcs[toIndex]
                    getInput.tpcToTpcMap[tpcs[fromIndex] + 1] = tpcs[toIndex];
                    // console.log(getInput.tpcToTpcMap);
                    
                    // ensure new mapping is visible in overview
                    mapList.positionViewAtIndex(mapList.count - 1, ListView.Contain)

                // ... else show msg in dialog
                } else {
                    var message;
                    if (getInput.tpcToTpcMap[tpcs[fromIndex] + 1] == tpcs[toIndex]) {
                        message = " is already included in the map.";
                    } else {
                        message = " was not added, because " + spellings[fromIndex]
                                + " has already been mapped to a different destination.";
                    }
                    showMapMessage(spellings[fromIndex], spellings[toIndex], message);
                }
            }
        }

        Text {
            id: mapMessage
            anchors.top: cbFromLetter.bottom
            anchors.left: cbFromLetter.left
            anchors.right: addButton.left
            anchors.margins: 4 * gap
            opacity: 0
            font.family: "FreeSerif"; font.pointSize: 10
            wrapMode: Text.Wrap
        }
        
        Button {
            text: "Sort"
            anchors.right: addButton.right
            anchors.bottom: mapView.bottom
            
            onClicked: {
                console.log("getInput: sortButton");
                rebuildMapModel(getInput.tpcToTpcMap);
            }
        }

// mapView
        Label {
            id: mapHead
            text: "Map overview:"
            anchors.top: addHead.top
            anchors.left: addButton.right
            anchors.leftMargin: 5 * gap
        }
        
        Rectangle {
          id: mapView
          width: 250; height: 270
          anchors.top: fromLabel.top
          anchors.left: mapHead.left
          anchors.topMargin: 2 * gap
        
          ScrollView {
            anchors.fill: parent
            frameVisible: true

            ListView {
                id: mapList
                anchors.fill: parent
                anchors.topMargin: gap
                model: mapModel
                delegate: mapDelegate

                ListModel {
                    id: mapModel
                    // properties: fromIndex, toIndex -- these index the global arrays "tpcs" and "spellings"
                    // initially empty, user appends ListElement via addButton
                }
                Component {
                    id: mapDelegate
                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        height: 30; spacing: 10
                        Text { text: spellings[fromIndex]; font.family: "FreeSerif"; font.pointSize: 11 }
                        Text { text: "to"; font.family: "FreeSerif"; font.pointSize: 11 }
                        Text { text: spellings[toIndex]; font.family: "FreeSerif"; font.pointSize: 11 }
                        Text {
                            text: "Remove"
                            color: "blue"
                            font.family: "FreeSerif"; font.pointSize: 11
                            font.underline: true
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log(index + " click");
                                    getInput.tpcToTpcMap[tpcs[fromIndex] + 1] = 99; // restore "not yet mapped" status
                                    showMapMessage(spellings[fromIndex], spellings[toIndex], " has been removed.");
                                    cbFromLetter.focus = true;
                                    mapModel.remove(index);
                                }
                            }
                        }
                    } // end Row
                } // end Component "mapDelegate"

            } // end ListView
          } // end ScrollView
        } // end Rectangle "mapView"

        Text { // spacer 
            anchors.top: mapView.bottom
            anchors.left: mapView.left
            height: 3 * gap 
        }

    } // end getInput dialog

// =========== error dialog, terminates execution

    MessageDialog {
        id: errorDialog
        title: "Error"
        visible: false
        onAccepted: {
            quit();
        }
    }

    function error(msg) {
        errorDialog.text = qsTr(msg);
        errorDialog.open();
    }    

// =========== help dialog

    Dialog {
        id: helpDialog
        width: 660
        title: "Help"
        visible: false
        standardButtons: StandardButton.Ok

        onAccepted: {
            if (applyImport.checked) {
                loadMapString();
            }
            getInput.open();
            resetCBs();
        }

        Text {
            id: helpText
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            text: "Use the <b>From</b>/<b>To</b> input boxes across the top of the Map Input window to "
                + "assign a new value (letter-name and optional accidental) to a note throughout the music "
                + "you are processing. Add as many assignments as the map requires.<br /><br />An overview "
                + "of the map is provided on the right side of the window. Click <b>remove</b> to delete "
                + "an individual assignment from the map.<br /><br />Copy the Import/Export string below to "
                + "save it as text in a score or text file. Paste a previously saved string to "
                + "re-use it here.<br />"

            font.pointSize: 10
            textFormat: Text.StyledText
            wrapMode: Text.Wrap            
        }

        Label {
            id: mapStringLabel
            anchors.top: helpText.bottom
            anchors.left: parent.left
            anchors.margins: 10
            text: "Import/Export:"
        }
        TextArea {
            id: mapString
            anchors.top: helpText.bottom
            anchors.left: mapStringLabel.right
            anchors.leftMargin: 10
            height: 90
            width: 500
            font.pointSize: 10
            text: ""
            wrapMode: TextEdit.Wrap
        }
        CheckBox {
            id: applyImport
            anchors.top: mapString.bottom
            anchors.left: mapString.left
            enabled: mapString.text.split(",").length == 35
            opacity: enabled ? 1.0 : 0.5
            text: "Use imported string"
        }

    }

// =========== input functions

    function resetCBs() {
        cbFromLetter.currentIndex = -1; 
        cbFromAcc.currentIndex = -1; 
        cbToLetter.currentIndex = -1; 
        cbToAcc.currentIndex = -1; 
        cbFromLetter.focus = true;
    }
    
    // map[n] is mapped value of tpc n-1; default value map[n] = n-1 filled in later;
    // initially fill map with value 99 signifying "not yet mapped"; 
    // keep track so we don't accept more than 1 mapping per tpc
    function initMap() {
        var arr = [];
        for (var i = 0; i < 35; i++) {
            arr.push(99);
        }
        return arr;
    }

    function fillDefaults(arr) {
        for (var i = 0; i < arr.length; i++) {
            if (arr[i] == 99) arr[i] = i - 1;
        }
        return arr;
    }
    
    function showMapMessage(fromSpelling, toSpelling, message) {
        mapMessage.text = "The mapping from " + fromSpelling + " to " + toSpelling + message;
        mapMessage.opacity = 1;
    }

    // clears mapModel and re-appends non-placeholder values from tpcToTpcMap
    // this sorts the model from Abb thru Gx
    function rebuildMapModel(tpcToTpcMap) {
        mapModel.clear();
        for (var i = 0; i < tpcs.length; i++) {
            if (tpcToTpcMap[tpcs[i] + 1] !== 99) {
                mapModel.append({ "fromIndex": i, "toIndex": invTpcs[tpcToTpcMap[tpcs[i] + 1] + 1] });
            }
        }
    }

    // if mapString is valid map, load it into tpcToTpcMap and rebuildMapModel
    function loadMapString() {
        var arr = mapString.text.split(",");
        if (arr.length !== 35) return;
        for (var i = 0; i < 35; i++) { 
            arr[i] = parseInt(arr[i], 10); 
            if (arr[i] == i - 1) {  // set default values back to placeholder 99
                arr[i] = 99         // so they don't clog up overview
            } else if (!isTpc(arr[i])) return;
        }
        rebuildMapModel(arr);
        getInput.tpcToTpcMap = arr;
    }

    function isTpc(x) {
        return x % 1 === 0 && -2 < x && x < 34;
    }
//    function isCpc(x) {
//        return x % 1 === 0 && -1 < x && x < 12;
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

    // ensure integer n is in range -1 through 33, by shifting in increments of +/-12
    // (enharmonic octave) e.g. B-triple-flat -2 becomes 10 A-flat 
    function tpcRangeAdjust(n) { 
        if (n < -1) {
            do {
                n += 12;
            } while (n < -1);
        } else {
            while (n > 33) {
                n -= 12;
            }
        }
        return n;
    }

    function makeTpcToTpcMapper(tpcToTpcMap) {
        return function(note) {
            var oldTpc = note.tpc;
            var newTpc = tpcToTpcMap[oldTpc + 1];
            if (oldTpc === newTpc) return;            // in case no mapping needed, we're done
                                                      // otherwise handle PITCH first
            var dTpc = newTpc - oldTpc; // min -34 max 34
            var dPitch;
            if (dTpc > 0) {
                dPitch = (((dTpc * 7) + 6) % 12) - 6;
            } else { // (dTpc < 0) 
                dPitch = (((dTpc * -5) + 6) % 12) - 6;
            }
            note.pitch += dPitch;
                                                      // and handle TPC with 2 cases
            if (note.tpc1 !== oldTpc) {               // case (1) concertTpc !== displayedTpc
                note.tpc2 = newTpc;
                note.tpc1 = tpcRangeAdjust(note.tpc1 + dTpc);
            } else {                                  // case (2) concertTpc === displayedTpc
                note.tpc1 = newTpc;
                note.tpc2 = tpcRangeAdjust(note.tpc2 + dTpc);
            }
        }
    }

// ================================================================ MAIN
    
    function main(tpcToTpcMap) {
        console.log("-------- applying map");
        curScore.startCmd();
        applyToNotesInSelection(makeTpcToTpcMapper(tpcToTpcMap));
        curScore.endCmd();
        console.log("end noteMapper");
        quit();
    }    

// ================================================================ RUN
    
    onRun: {
        console.log("begin noteMapper");

        if (typeof curScore === 'undefined' || curScore == null) {
            error("NoteMapper plugin requires an open score.\n");
        } else {
            checkFont();
            getInput.open();
            resetCBs();
        }
    }
}
