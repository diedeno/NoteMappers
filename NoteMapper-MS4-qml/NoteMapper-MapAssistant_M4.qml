// ============================================================================
//  MuseScore: Music Composition & Notation
//  NoteMapper Map Assistant Plugin
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
import MuseScore 3.0

MuseScore {
    version: "0.9"
    description: "This plugin reads two staves of single notes and builds a map that sends the "
               + "1st note of the upper staff to the 1st of the lower, the 2nd of the upper to "
               + "the 2nd of the lower, 3rd to 3rd, and so on. Maps can be configured for use in "
               + "the Note to Note, Pc to Pc, Pitch to Pitch, or Adaptive NoteMapper plugins."

    menuPath: "Plugins.NoteMapper.Map Assistant"
/*  to avoid creating a NoteMapper submenu in your Plugins Menu, swap the menuPath statements above/below this line
    menuPath: "Plugins.Composing Tools.NoteMapper Map Assistant"
*/
     
       Component.onCompleted : {
        if (mscoreMajorVersion >= 4) {
            title = qsTr("Notemapper-MapAssistant") ;
           // thumbnailName = "thumbnail.png";
            categoryCode = "composing-arranging-tools";
           } 
        }
         
    // alerts are set in function loadFromScore ...
    property var alerts: {
        "All but first two staves": false,
        "All but first voice": false,
        "All but top note in chords": false,
        "Surplus notes in 'From' (upper) staff": false,
        "Surplus notes in 'To' (lower) staff": false,
        "Duplicate notes in 'From' (upper) staff": false    // ...  and function makeMap
    }

    property var defaultTpc: [14, 21, 16, 11, 18, 13, 20, 15, 10, 17, 12, 19]
    // default spellings      C   C#  D   Eb  E   F   F#  G   Ab  A   Bb  B 

// ================================================================ DIALOGS

    // errors terminate execution
    MessageDialog {
        id: errorDialog
        title: "Error"
        visible: false
        
        onAccepted: {
            quit();
        }
    }
    
    function error(errorMessage) {
        errorDialog.text = qsTr(errorMessage);
        errorDialog.open();
    }
    
//=========
    // alerts allow execution to continue
    MessageDialog {
        id: alertDialog
        title: "Alert"
        visible: false

        onAccepted: {
            console.log("alertDialog: OK");
            resultDialog.open();
        }
    }
    
    function makeAlertString() {
        var alertString = "";
        for (var msg in alerts) {         // alerts is global object with alert messages as keys
            if (alerts[msg]) {            // if property value has been set to TRUE
                alertString += "\n- " + msg; // then append property key
            }
        }
        if (alertString) {
            alertString = "Ignoring:" + alertString + "\n";
        }
        return alertString;
    }

// =========== confirmScore dialog

    Dialog {
        id: confirmScore
        width: 500
        title: "Please Confirm"
        visible: false
        standardButtons: StandardButton.Ok | StandardButton.Cancel

        onAccepted: {
            console.log("confirmScore: OK");
            getMapType.open();
        }
        onRejected: {
            console.log("confirmScore: Cancel");
            quit();
        }

        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            text: "The current score is significantly larger than a typical score for Map "
                + "Assistant (more than 4 staves and/or more than 64 bars). Recommendation: if "
                + "you haven't saved your work, click Cancel and save before running this plugin.\n"
            font.pointSize: 10
            wrapMode: Text.Wrap            
        }
    }
    
    function isBigScore() {
        if (curScore.nstaves > 4) return true;
        
        var cursor = curScore.newCursor();
        cursor.rewind(0); // start of score
        var measCount = 0;
        do {
            measCount++;
        } while (cursor.nextMeasure() && measCount < 65);
        if (measCount === 65) return true;
        return false;
    }

//=========

    // getMapType launches loadFromScore
    Dialog {
        id: getMapType
        width: 550
        title: "Choose map type"
        visible: false
        standardButtons: StandardButton.Help | StandardButton.Cancel | StandardButton.Ok

        onHelp: {
            console.log("getMapType: Help");
            helpDialog.open(); // this closes getMapType dialog on most platforms
        }
        onAccepted: {
            var mapSize = 12;             // 12 cpcs
            copyTimer.pasteTarget = "import field of the Pc to Pc or input field of the Adaptive";
            if (noteButton.checked) {
                mapSize = 35;             // 35 tpcs
                copyTimer.pasteTarget = "import field of the Note to Note or input field of the Adaptive";
            } else if (pitchButton.checked) {
                mapSize = 127;            // 127 pitches
                copyTimer.pasteTarget = "input field of the Pitch to Pitch or Adaptive";
            } else if (amPcButton.checked) {
                mapSize = 24;             // 12 cpcs + 12 tpcs
                copyTimer.pasteTarget = "input field of the Adaptive";
            } else if (amPitchButton.checked) {
                mapSize = 254;             // 127 cpcs + 127 tpcs
                copyTimer.pasteTarget = "input field of the Adaptive";
            }
            console.log("getMapType: OK button, mapSize = " + mapSize);
            loadFromScore(mapSize);
        }
        onRejected: {
            console.log("getMapType: Cancel");
            quit();
        }

        Text { 
            id: mapTypeHead
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            font.pointSize: 10
            text: "Make map for use in which NoteMapper?" 
        }

        Rectangle {
            id: mapTypeRect
            anchors.top: mapTypeHead.bottom
            anchors.left: mapTypeHead.left
            anchors.right: mapTypeHead.right
            anchors.topMargin: 15
            height: 120
            color: "LightGray"
            border.color: "DarkGray"
            border.width: 2

            Grid {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                flow: Grid.TopToBottom
                columnSpacing: 25
                rowSpacing: 10
                rows: 3

                ExclusiveGroup {
                    id: mapTypeGroup
                }
                RadioButton {
                    id: noteButton
                    text: "Note to Note"
                    exclusiveGroup: mapTypeGroup
                    checked: true
                }
                RadioButton {
                    id: pcButton
                    text: "PC to PC"
                    exclusiveGroup: mapTypeGroup
                }
                RadioButton {
                    id: pitchButton
                    text: "Pitch to Pitch"
                    exclusiveGroup: mapTypeGroup
                }
                Label {
                    height: noteButton.height
                    verticalAlignment: Text.AlignVCenter
                    text: "Adaptive Mapper"
                }
                RadioButton {
                    id: amPcButton
                    text: "12 spelled PCs"
                    exclusiveGroup: mapTypeGroup
                }
                RadioButton {
                    id: amPitchButton
                    text: "127 spelled Pitches"
                    exclusiveGroup: mapTypeGroup
                }
            }
        } // end mapTypeRect

        Text {
            anchors.top: mapTypeRect.bottom
            anchors.left: mapTypeRect.left
            anchors.right: parent.right
            anchors.topMargin: 15
            text: "Map Assistant will build a map based on notes in the current score. "
                 + "Click Help for information about map types and the expected score format.<br />"
            font.pointSize: 10
            textFormat: Text.StyledText
            wrapMode: Text.Wrap            
        }
    }

// =========== help dialog

    Dialog {
        id: helpDialog
        width: 820
        title: "Help"
        visible: false
        standardButtons: StandardButton.Ok

        onAccepted: {
            getMapType.open();
        }

        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            text: "<b>Map Types</b><br /><br /><b>Note to Note.</b> Sends notes (letter-names and "
                + "optional accidentals) to new values. Applies the same mapping in every octave. "
                + "Comma-separated list of 35 tpc values (tonal pitch class: integers in the range "
                + "-1 through 33). Use in Note to Note or Adaptive Mapper.<br /><br /><b>PC to PC.</b> "
                + "Sends steps of the chromatic scale to new values, which will receive default "
                + "spellings when the map is applied. Applies the same mapping in every octave. "
                + "Comma-separated list of 12 cpc values (chromatic pitch class: integers in the "
                + "range 0 through 11). Use in Pc to Pc or Adaptive Mapper.<br /><br /><b>Pitch to "
                + "Pitch.</b> Sends MIDI pitches to new values, which will receive default spellings "
                + "when the map is applied. Comma-separated list of 127 MIDI pitches (integers in "
                + "the range 1 through 127). Use in Pitch to Pitch or Adaptive Mapper.<br /><br /><b>"
                + "12 spelled PCs.</b> Sends steps of the chromatic scale to new values and new "
                + "spellings. Applies the same mapping in every octave. Comma-separated list of "
                + "12 cpc values followed by 12 tpc values. Use in Adaptive Mapper only.<br /><br /><b>"
                + "127 spelled Pitches.</b> Sends MIDI pitches to new values and new spellings. "
                + "Comma-separated list of 127 MIDI pitches followed by 127 tpc values. Use in "
                + "Adaptive Mapper only.<br /><br /><br />"
                + "<b>Score Format</b><br /><br />"
                + "Map Assistant expects a score with two staves, each with a succession of "
                + "single notes, and it produces a map that sends the first note of the upper "
                + "staff to the first of the lower, the second of the upper to the second of the "
                + "lower, third to third, and so on. The alignment of upper-staff and lower-staff "
                + "notes is ignored, as are surplus notes, voices, and staves. A score far outside "
                + "these expectations may cause the plugin to fail.<br />"
            font.pointSize: 9.5
            textFormat: Text.StyledText
            wrapMode: Text.Wrap
        }
    }

//=========
    Dialog {
        id: resultDialog
        width: 800
        title: "Map Assistant: Result"
        visible: false
        standardButtons: StandardButton.Close	// A Close button defined with the RejectRole.

        onRejected: {
            quit();
        }

        TextArea {
            id: resultText
            height: 300
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            font.pointSize: 11
            readOnly: true
            selectByKeyboard: false
            selectByMouse: false
            wrapMode: TextEdit.Wrap
        }

        Button {
            id: copyButton
            text: qsTr("Copy")
            anchors.top: resultText.bottom
            anchors.left: resultText.left
            anchors.topMargin: 20
            
            onClicked: {
                console.log("resultDialog: copyButton");
                resultText.selectAll();
                resultText.copy();
                copyTimer.start();
            }
        }

        Text {
            id: copyInfo
            text: qsTr("Copy result to clipboard.\n\n") // will update when copyButton Clicked
            anchors.top: resultText.bottom
            anchors.left: copyButton.right
            anchors.right: resultText.right
            anchors.topMargin: 20
            anchors.leftMargin: 20
            anchors.rightMargin: 10
            font.pointSize: 10
            wrapMode: Text.Wrap
        }
        
        Timer {
            id: copyTimer
            property var pasteTarget: "" // set in getMapType dialog
            interval: 300
            onTriggered: {
                resultText.select(0,0);
                copyInfo.text = qsTr("Copied. You can paste this result into the " + pasteTarget 
                                   + " NoteMapper plugin.");
            }
        }
    }

// ================================================================ LOAD

    // during score traversal: load fromNotes,toNotes,toSpellings; set alerts and errors;
    function loadFromScore(mapSize) {
        console.log("-------- loading fromNotes,toNotes,toSpellings");
        var fromNotes = [];
        var toNotes = [];
        var toSpellings = []; // if mapSize is 24 or 254, this holds tpcs (otherwise it remains empty)
        
        var cursor = curScore.newCursor();
        var staffCount = curScore.nstaves;
        console.log(staffCount + " staves detected");
        if (staffCount < 2) {
            error("A score with two staves is required.\n"); // this signals quit();
            return; 
        }
        if (staffCount > 2) {
            alerts["All but first two staves"] = true; 
        }
        
        // load fromNotes from staff 0
        cursor.staffIdx = 0;
        
        // process voice 0 fully
        cursor.voice = 0;
        cursor.rewind(0); // beginning of score;

        while (cursor.segment) {
            if (cursor.element && cursor.element.type == Element.CHORD) {
                var notes = cursor.element.notes;
                var topNote = notes[notes.length - 1]; //  (assume notes are in ascending order)
                switch (mapSize) {
                    case 127: 
                    case 254: fromNotes.push(topNote.pitch); break;
                    case 12: 
                    case 24: fromNotes.push(topNote.pitch % 12); break;
                    case 35: fromNotes.push(topNote.tpc1); break;
                }
                if (notes.length > 1) { // disregard remainder of chord
                    alerts["All but top note in chords"] = true;
                }
            }
            cursor.next();
        }

        // check for surplus notes in voices 1-3
        surplusVoiceLoop1: 
        for (var voice = 1; voice < 4; voice++) {
            cursor.voice = voice;
            cursor.rewind(0); // beginning of score;

            while (cursor.segment) {
                if (cursor.element && cursor.element.type == Element.CHORD) {
                    alerts["All but first voice"] = true; 
                    break surplusVoiceLoop1;
                }
            }
        }
        if (fromNotes.length == 0) {
            error("Zero notes found in 'From' (upper) staff.\n"); // this signals quit();
            return; 
        }

        // load toNotes from staff 1
        cursor.staffIdx = 1;
        
        // process voice 0 fully
        cursor.voice = 0;
        cursor.rewind(0); // beginning of score;

        while (cursor.segment) {
            if (cursor.element && cursor.element.type == Element.CHORD) {
                var notes = cursor.element.notes;
                var topNote = notes[notes.length - 1];
                // add topNote to toNotes
                // mapSize 254 or 24: also add corresponding spelling to toSpellings
                switch (mapSize) { 
                    case 254: 
                        toSpellings.push(topNote.tpc1); 
                    case 127: 
                        toNotes.push(topNote.pitch); 
                        break;
                        
                    case 24: 
                        toSpellings.push(topNote.tpc1);
                    case 12: 
                        toNotes.push(topNote.pitch % 12); 
                        break;
                        
                    case 35: 
                        toNotes.push(topNote.tpc1);
                }
                if (notes.length > 1) { // disregard remainder of chord
                    alerts["All but top note in chords"] = true;
                }
            }
            cursor.next();
        }

        if (!alerts["All but first voice"]) { // check for surplus notes in voices 1-3
            surplusVoiceLoop2: 
            for (var voice = 1; voice < 4; voice++) {
                cursor.voice = voice;
                cursor.rewind(0); // beginning of score;

                while (cursor.segment) {
                    if (cursor.element && cursor.element.type == Element.CHORD) {
                        alerts["All but first voice"] = true;
                        break surplusVoiceLoop2;
                    }
                }
            }
        }
        if (toNotes.length == 0) {
            error("Zero notes found in 'To' (lower) staff.\n"); // this signals quit();
            return; 
        }

        // reconcile lengths of fromNotes vs toNotes
        if (fromNotes.length > toNotes.length) {
            alerts["Surplus notes in 'From' (upper) staff"] = true; 
            fromNotes = fromNotes.slice(0, toNotes.length);
        } else if (toNotes.length > fromNotes.length) {
            alerts["Surplus notes in 'To' (lower) staff"] = true; 
            toNotes = toNotes.slice(0, fromNotes.length);
            toSpellings = toSpellings.slice(0, fromNotes.length);
        }
        console.log("\nfromNotes:   " + fromNotes 
                  + "\ntoNotes:     " + toNotes 
                  + "\ntoSpellings: " + toSpellings);
        makeMap(fromNotes,toNotes,toSpellings,mapSize);
    }

// ================================================================ MAKE MAP

    function makeMap(fromNotes,toNotes,toSpellings,mapSize) {
        var noteMap = [];
        var spellingsMap = [];
        var noteCount;
        switch (mapSize) {
            case 24: noteCount = 12; break;
            case 254: noteCount = 127; break;
            default: noteCount = mapSize; 
        }
        for (var i = 0; i < noteCount; i++) { // initialize all map positions to 999
            noteMap.push(999);
            if (mapSize == 24 || mapSize == 254) spellingsMap.push(999);
        }
//   mapSize 12:    noteMap[n] is new cpc value of cpc n            offset 0
//    or 24          spellingsMap[n] is corresponding tpc value
//
//   mapSize 35:    noteMap[n+1] is new tpc value of tpc n          offset 1
//
//   mapSize 127:   noteMap[n-1] is new pitch value of pitch n      offset -1
//    or 254         spellingsMap[n-1] is corresponding tpc value
        var offset;
        switch (mapSize) {
            case 12: 
            case 24: offset = 0; break;
            case 35: offset = 1; break;
            case 127: 
            case 254: offset = -1;
        }
        for (var j = 0; j < fromNotes.length; j++) { // set user values
            if (noteMap[fromNotes[j] + offset] == 999) {
                noteMap[fromNotes[j] + offset] = toNotes[j];
                if (mapSize == 24 || mapSize == 254) spellingsMap[fromNotes[j] + offset] = toSpellings[j];
            } else {
                alerts["Duplicate notes in 'From' (upper) staff"] = true; 
            }
        }

        for (var k = 0; k < noteMap.length; k++) { // fill rest of map with default (identity mapping)
            if (noteMap[k] == 999) {
                noteMap[k] = (k - offset);
                if (mapSize == 24 || mapSize == 254) spellingsMap[k] = defaultTpc[(k - offset) % 12];
            }
        }
        noteMap = noteMap.concat(spellingsMap);
        var mapString = noteMap.toString();
        resultText.text = mapString.replace(/,/g,", "); // for better textWrap

        var alertString = makeAlertString();
        if (alertString) {
            alertDialog.text = qsTr(alertString);
            alertDialog.open();
        } else {
            resultDialog.open();
        }
    }

// ================================================================ RUN

    onRun: {
        console.log("begin noteMapper");

        if (typeof curScore === 'undefined' || curScore == null) {
            error("NoteMapper plugin requires an open score.\n");
        } else if (isBigScore()) {
            confirmScore.open();
        } else {
            getMapType.open();
        }
    }
}
