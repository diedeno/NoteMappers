// ============================================================================
//  MuseScore: Music Composition & Notation
//  NoteMapper Adaptive Mapper Plugin
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
    description: "This plugin applies a map originating from any of the following NoteMapper plugins: "
               + "Map Assistant, Note to Note, Pc to Pc, Pitch to Pitch"

    menuPath: "Plugins.NoteMapper.Adaptive"
/*  to avoid creating a NoteMapper submenu in your Plugins Menu, swap the menuPath statements above/below this line
    menuPath: "Plugins.Composing Tools.NoteMapper Adaptive"
*/
     
       Component.onCompleted : {
        if (mscoreMajorVersion >= 4) {
            title = qsTr("Notemapper-Adaptive") ;
           // thumbnailName = "thumbnail.png";
           // categoryCode = "some_category";
           }
        }
        
    property var defaultTpc: [14, 21, 16, 11, 18, 13, 20, 15, 10, 17, 12, 19]
    // default spellings      C   C#  D   Eb  E   F   F#  G   Ab  A   Bb  B 

    // tpcToCpc[n] is cpc (chromatic pitch class) value of tpc n-1
    property var tpcToCpc: [
        3, 10, 5, 0, 7, 2, 9, 4, 11, 6, 1, 8, 3, 10, 5, 0, 7, 2, 9, 4, 11, 
        6, 1, 8, 3, 10, 5, 0, 7, 2, 9, 4, 11, 6, 1 
    ]

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
            helpDialog.open(); // this closes getInput dialog on most platforms
        }
        onApply: {
            console.log("getInput: Apply");
            main(inputArea.text);
        }
        onRejected: {
            console.log("getInput: Cancel");
            quit();
        }

        TextArea {
            id: inputArea
            height: 250
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            font.pointSize: 10
            text: ""
            wrapMode: TextEdit.Wrap
            focus: true
        }

        Text {
            id: instructions
            anchors.top: inputArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            text: "Paste your map (list of numbers) here. Click Help for more information.<br />"
            font.pointSize: 10
            textFormat: Text.StyledText
            wrapMode: Text.Wrap            
        }
    }

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

// =========== retry dialog, re-opens getInput

    MessageDialog {
        id: retryDialog
        title: "Retry"
        visible: false
        onAccepted: {
            getInput.open();
            inputArea.focus = true;
        }
    }

    function retry(msg, n) {  // n optional
        retryDialog.text = qsTr(msg);
        retryDialog.open();
        
        if (n !== undefined) selectNthItem(n);
    }

    // assuming inputArea.text is list of comma-separated values, 
    // sets selection to nth item (counting from 1)
    function selectNthItem(n) {
        var nthCommaIndex = nthIndex(inputArea.text, ",", n);
        if (nthCommaIndex < 0) nthCommaIndex = inputArea.text.length;
        inputArea.cursorPosition = nthCommaIndex - 1;
        inputArea.selectWord();
    }

    // index (counting from 0) of nth occurrence (counting from 1) of pat in str
    function nthIndex(str, pat, n) {
        var len = str.length;
        var i = -1;
        while (n-- && i++ < len) {
            i = str.indexOf(pat, i);
            if (i < 0) break;
        }
        return i; //returns -1 if called with n < 1 or n beyond last occurrence of pat 
    }

// =========== help dialog

    Dialog {
        id: helpDialog
        width: 800
        title: "Help"
        visible: false
        standardButtons: StandardButton.Ok

        onAccepted: {
            getInput.open();
            inputArea.focus=true;
        }

        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            text: "The <b>Adaptive Mapper</b> is a tool for transforming pitch material. It is "
                + "designed to recognize and apply maps originating from various NoteMapper "
                + "plugins: Note to Note, Pc to Pc, and Pitch to Pitch; plus maps derived from "
                + "music notation using the Map Assistant plugin. Maps (which are just comma-"
                + "separated lists of numbers) can be copied from any of these sources and "
                + "pasted into the Adaptive Mapper Input window. To store a map for future use, "
                + "simply paste it as text in a score or text file.<br /><br /><br />"
                + "<b>Map Sources</b><br /><br />"
                + "Note to Note: Import/Export field in Help window (35 tpc values)<br /><br />"
                + "Pc to Pc: Import/Export field in Help window (12 cpc values)<br /><br />"
                + "Pitch to Pitch: Copy from Input window (127 pitch values, not X:Y pairs)<br /><br />"
                + "Map Assistant: Copy from Result window (12, 24, 35, 127, or 254 values, based on "
                + "choice of map type)<br /><br /><br />"
                + "<b>Map Values</b><br /><br />"
                + "CPC (chromatic pitch class): integer 0 – 11, for steps of the chromatic scale<br /><br />"
                + "Pitch: integer 1 – 127, for MIDI pitch<br /><br />"
                + "TPC (tonal pitch class): integer -1 – 33, for letter-name plus accidental<br />"
            font.pointSize: 10
            textFormat: Text.StyledText
            wrapMode: Text.Wrap
        }
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

// ================================================================ MAPPING FUNCTIONS

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

// MAPPING FUNCTIONS
// one of these will be applied based on length of valid map
// makeCpcToCpcMapper           12       12 pcs                              pc: [0, 11]
// makeCpcToCpcAndTpcMapper     24       12 pcs + 12 tpcs                    tpc: [-1, 33]
// makeTpcToTpcMapper           35       35 tpcs                             pitch: [1, 127]
// makePitchToPitchMapper       127      127 pitches
// makePitchToPitchAndTpcMapper 254      127 pitches + 127 tpcs

    function makeCpcToCpcMapper(mapArr) {             // length 12
        return function(note) {
            var oldTpc = note.tpc;
            var oldCpc = tpcToCpc[oldTpc + 1];
            var newCpc = mapArr[oldCpc];
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

    function makeTpcToTpcMapper(mapArr) {             // length 35
        return function(note) {
            var oldTpc = note.tpc;
            var newTpc = mapArr[oldTpc + 1];
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

    function makePitchToPitchMapper(mapArr) {         // length 127
        return function(note) {
            var oldPitch = note.pitch;
            var newPitch = mapArr[oldPitch - 1];
            if (oldPitch === newPitch) return;

            note.pitch = newPitch;

            var oldTpc1 = note.tpc1;
            note.tpc1 = defaultTpc[newPitch % 12];
            // shift tpc2 by same amount as tpc1
            note.tpc2 += note.tpc1 - oldTpc1;
        }
    }

    function makeCpcToCpcAndTpcMapper(mapArr) {       // length 24
        return function(note) {
            var oldTpc = note.tpc;
            var oldCpc = tpcToCpc[oldTpc + 1];
            var newCpc = mapArr[oldCpc];
            if (oldCpc === newCpc) return;                  // in case no mapping needed, we're done
                                                            // otherwise handle PITCH first
            note.pitch += ((newCpc - oldCpc + 18) % 12) - 6;

            var newTpc = mapArr[oldCpc + 12];               // and handle TPC with 2 cases
            var dTpc = newTpc - oldTpc; // min -34 max 34

            if (note.tpc1 !== oldTpc) {                     // case (1) concertTpc !== displayedTpc
                note.tpc2 = newTpc;
                note.tpc1 = tpcRangeAdjust(note.tpc1 + dTpc);
            } else {                                        // case (2) concertTpc === displayedTpc
                note.tpc1 = newTpc;
                note.tpc2 = tpcRangeAdjust(note.tpc2 + dTpc);
            }
        }
    }


    function makePitchToPitchAndTpcMapper(mapArr) {   // length 254
        return function(note) {
            var oldPitch = note.pitch;
            var newPitch = mapArr[oldPitch - 1];

            note.pitch = newPitch;

            var oldTpc1 = note.tpc1;
            note.tpc1 = mapArr[oldPitch + 126];
            // shift tpc2 by same amount as tpc1
            note.tpc2 += note.tpc1 - oldTpc1;
        }
    }

// ================================================================ MAIN
    
    function main(inputStr) {
        var arr = inputStr.split(",");
        var func;
        switch (arr.length) {
            case 12: 
                for (var i = 0; i < 12; i++) { 
                    arr[i] = parseInt(arr[i], 10); 
                    if (!isCpc(arr[i])) {
                        return retry(
                            "Map value " + arr[i] + " is out of range or wrong type. " + 
                            "A map of length 12 requires integers in the range 0 through 11.\n", 
                            i + 1
                        );
                    }
                }
                func = makeCpcToCpcMapper(arr);
                break;
            case 24: 
                for (var i = 0; i < 12; i++) { 
                    arr[i] = parseInt(arr[i], 10); 
                    if (!isCpc(arr[i])) {
                        return retry(
                            "Map value " + arr[i] + " is out of range or wrong type. " + 
                            "A map of length 24 requires integers in the range 0 through 11 " +
                            "in the first 12 places.\n", 
                            i + 1
                        );
                    }
                }
                for (var i = 12; i < 24; i++) { 
                    arr[i] = parseInt(arr[i], 10); 
                    if (!isTpc(arr[i])) {
                        return retry(
                            "Map value " + arr[i] + " is out of range or wrong type. " + 
                            "A map of length 24 requires integers in the range -1 through 33 " +
                            "in the last 12 places.\n", 
                            i + 1
                        );
                    }
                }
                func = makeCpcToCpcAndTpcMapper(arr);
                break;
            case 35: 
                for (var i = 0; i < 35; i++) { 
                    arr[i] = parseInt(arr[i], 10); 
                    if (!isTpc(arr[i])) {
                        return retry(
                            "Map value " + arr[i] + " is out of range or wrong type. " + 
                            "A map of length 35 requires integers in the range -1 through 33.\n", 
                            i + 1
                        );
                    }
                }
                func = makeTpcToTpcMapper(arr);
                break;
            case 127: 
                for (var i = 0; i < 127; i++) { 
                    arr[i] = parseInt(arr[i], 10); 
                    if (!isPitch(arr[i])) {
                        return retry(
                            "Map value " + arr[i] + " is out of range or wrong type. " + 
                            "A map of length 127 requires integers in the range 1 through 127.\n", 
                            i + 1
                        );
                    }
                }
                func = makePitchToPitchMapper(arr);
                break;
            case 254: 
                for (var i = 0; i < 127; i++) { 
                    arr[i] = parseInt(arr[i], 10); 
                    if (!isPitch(arr[i])) {
                        return retry(
                            "Map value " + arr[i] + " is out of range or wrong type. " + 
                            "A map of length 254 requires integers in the range 1 through 127 " +
                            "in the first 127 places.\n", 
                            i + 1
                        );
                    }
                }
                for (var i = 127; i < 254; i++) { 
                    arr[i] = parseInt(arr[i], 10); 
                    if (!isTpc(arr[i])) {
                        return retry(
                            "Map value " + arr[i] + " is out of range or wrong type. " + 
                            "A map of length 254 requires integers in the range -1 through 33 " +
                            "in the last 127 places.\n", 
                            i + 1
                        );
                    }
                }
                func = makePitchToPitchAndTpcMapper(arr);
                break;
            default: 
                return retry(
                    arr.length + " is not a valid map size.\n" +
                    "(Length 12, 24, 35, 127, or 254 is required.)\n"
                );
        }
        console.log("-------- applying map");
        curScore.startCmd();
        applyToNotesInSelection(func);
        curScore.endCmd();
        console.log("end noteMapper");
        quit();
    }

    function isPitch(x) {
        return x % 1 === 0 && 0 < x && x < 128;
    }
    function isTpc(x) {
        return x % 1 === 0 && -2 < x && x < 34;
    }
    function isCpc(x) {
        return x % 1 === 0 && -1 < x && x < 12;
    }

// ================================================================ RUN
    
    onRun: {
        console.log("begin noteMapper");

        if (typeof curScore === 'undefined' || curScore == null) {
            error("NoteMapper plugin requires an open score.\n");
        } else {
            getInput.open();
            inputArea.focus = true;
        }
    }
}
