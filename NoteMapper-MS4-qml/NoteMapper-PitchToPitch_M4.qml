// ============================================================================
//  MuseScore: Music Composition & Notation
//  NoteMapper Pitch to Pitch Plugin
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
    description: "This plugin maps MIDI pitch to MIDI pitch"

    menuPath: "Plugins.NoteMapper.Pitch to Pitch"
/*  to avoid creating a NoteMapper submenu in your Plugins Menu, swap the menuPath statements above/below this line
    menuPath: "Plugins.Composing Tools.NoteMapper Pitch to Pitch"
*/
	 
       Component.onCompleted : {
        if (mscoreMajorVersion >= 4) {
            title = qsTr("Notemapper-Pitch2Pitch") ;
           // thumbnailName = "thumbnail.png";
            categoryCode = "composing-arranging-tools";
           }
        }   
        
        
    property var initInput: "60:72, 72:60"
    
    property var oneToMany: "" // func buildMap will append X:Z, if input contains X:Y before X:Z, 
                               // so we can signal error if user attempts to map one pitch to more
                               // than one new value
    
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
            text: initInput
            wrapMode: TextEdit.Wrap
            focus: true
        }

        Text {
            id: instructions
            anchors.top: inputArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            text: "A map is a list of pairs X:Y, where X is a MIDI pitch value (1-127) as it "
                + "currently appears in the music you are processing, and Y is a new value "
                + "to replace X. Click Help for more information.<br />"
            font.pointSize: 11
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

// =========== alert dialog, report issues while execution continues

    MessageDialog {
        id: alertDialog
        title: "Alert"
        visible: false
    }

    function alert(msg) {
        alertDialog.text = qsTr(msg);
        alertDialog.open();
    }

// =========== retry dialog, re-opens getInput

    MessageDialog {
        id: retryDialog
        title: "Retry"
        visible: false
        onAccepted: {
            inputArea.selectAll();
            getInput.open();
            inputArea.focus=true;
        }
    }

    function retry(msg) {
        retryDialog.text = qsTr(msg);
        retryDialog.open();
    }    

// =========== help dialog

    Dialog {
        id: helpDialog
        width: 800
        title: "Help"
        visible: false
        standardButtons: StandardButton.Ok

        onAccepted: {
            inputArea.selectAll();
            getInput.open();
            inputArea.focus = true;
        }

        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            text: "A map determines how MIDI pitch values will be changed in the music you are processing. "
                + "Normally you specify a map with one or more <b>pairs</b> of the form <tt>X:Y</tt>, meaning "
                + '“map X to Y”. For example, <tt>60:72</tt> raises every middle C by an octave. You can '
                + "specify additional pairs on new lines, or put them on the same line separated with commas. "
                + "So:<blockquote><tt>45:46,46:45,47:48,48:47</tt></blockquote>is equivalent to<blockquote>"
                + "<tt>45:46<br />46:45<br />47:48<br />48:47</tt></blockquote>It is also possible to specify a "
                + "map with a <b>list</b> of exactly 127 pitch values. In this alternative format, the number "
                + "in the nth position (counting from 1) determines the new value of pitch n. So a map with 72 "
                + "in the 60th position will raise every middle C by an octave. While it is hardly practical to "
                + "construct such a long list by hand, you can use the <b>Map Assistant</b> plugin to build a "
                + "list based on the notes in a score, then paste it here in the Map Input window."
            font.pointSize: 11
            textFormat: Text.RichText 
            // textFormat: Text.StyledText // StyledText doesn't handle <blockquote>
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

    function makePitchToPitchMapper(pitchToPitchArr) {
        return function(note) {
            var oldPitch = note.pitch;
            var newPitch = pitchToPitchArr[oldPitch - 1];
            if (oldPitch === newPitch) return;
            
            note.pitch = newPitch;
            
            var oldTpc1 = note.tpc1;
            note.tpc1 = defaultTpc[newPitch % 12];
            // shift tpc2 by same amount as tpc1
            note.tpc2 += note.tpc1 - oldTpc1;
        }
    }

// ================================================================ MAIN
    
    function main(inputStr) {
        var arr;
        if (inputStr.indexOf(':') == -1) {      // if inputStr doesn't contain ":" then parse as list
            arr = parseList(inputStr);
        } else {                                // else parse as pairs
            arr = parsePairs(inputStr);
        }
        if (Array.isArray(arr)) {   // successfully parsed into valid array ...
            if (oneToMany) {
                alert("A given pitch cannot be mapped to more than one new value, so the "
                    + "following input pairs have been ignored:\n" + oneToMany + "\n");
            }
            console.log("-------- applying map");
            curScore.startCmd();
            applyToNotesInSelection(makePitchToPitchMapper(arr));
            curScore.endCmd();
            console.log("end noteMapper");
            quit();
        } else {                    // ... else: parser returned string representing error msg
            retry(arr);
        }
    }    

// ================================================================ INPUT PARSERS

    // return array, or string representing error msg
    function parseList(inputStr) {
        var arr = inputStr.split(",");    // split input on commas ...
        if (arr.length !== 127) {          // and if bad length
            console.log("can't split on commas, trying on whitespace");
            arr = inputStr.split(/\s+/);  // ... retry split on whitespace
        }
        if (arr.length !== 127) {
            console.log("length error");
            return "Length error: " + arr.length + " values detected. " 
                +  "Map must be 127 values with commas in between (or with whitespace in between and no commas).\n";
        }
        var numArr = arr.map(Number);
        for (var i = 0; i < numArr.length; i++) {
            if (!isPitch(numArr[i])) {
                console.log("range or type error");
                return "Note value '" + arr[i] + "' is out of range or wrong type. (Integer 1-127 is required.)\n";
            }
        }
        return numArr;
    }

    // return array, or string representing error msg
    function parsePairs(inputStr) {
        var pitchPairs = extractPitchPairs(inputStr);
        // pitchPairs is 2D array of pitch vals, or string representing error msg
        console.log("extractPitchPairs returned: " + pitchPairs);

        if (Array.isArray(pitchPairs)) {  // successfully extracted 2D array: continue processing
            return buildMap(pitchPairs);
        } else {                          // ... else: extractPitchPairs returned string representing error msg
            return pitchPairs;            // so return that string
        }
    }

    function extractPitchPairs(pairStr) {
        console.log("extractPitchPairs from\n" + pairStr);
        var normStr = pairStr.replace(/\s*:\s*/g, ":"); // trim whitespace before/after each colon
        normStr = normStr.replace(/,/g, " "); // replace commas with spaces
        normStr = normStr.trim(); // trim leading/trailing whitespace
        console.log('normalized string =\n' + normStr);

        var pairs = normStr.split(/\s+/); // split on whitespace
        console.log("pairs 1-" + pairs.length + ":\n" + pairs); // at this point each pair is a string

        var pitchPairs = [];
        for (var i = 0; i < pairs.length; i++) {
            var pair = pairs[i].split(":");
            if ((pair.length !== 2) || !pair[0] || ! pair[1]) {
                return("Bad pair: " + pairs[i] + "\nExpected format is 'X:Y'.\n");
            }
            var pitchPair = [];
            for (var j = 0; j < 2; j++) {
                var pVal = Number(pair[j]);
                if (isPitch(pVal)) {
                    pitchPair.push(pVal);
                } else {
                    return("Bad pitch value: " + pair[j] + "\nExpecting integer 1-127.\n")
                }
            }
            pitchPairs.push(pitchPair);
        }
        console.log("successfully extracted pitchPairs =\n" + pitchPairs);
        return pitchPairs;
    }

    function buildMap(pitchPairs) { // pitchPairs is 2D array of integers [[from0,to0],[from1,to1],...]
        var noteMap = [];
        for (var i = 0; i < 127; i++) { // initialize all map positions to false
            noteMap.push(false);
        }

        for (var j = 0; j < pitchPairs.length; j++) { // set values from pitchPairs
            var fromPitch = pitchPairs[j][0];
            var toPitch = pitchPairs[j][1];
            if (noteMap[fromPitch - 1]) { // build informative string
                if (oneToMany) {
                    oneToMany += ", ";                
                }
                oneToMany += fromPitch + ":" + toPitch;
            } else {
                noteMap[fromPitch - 1] = toPitch;
            }
        }

        for (var k = 0; k < noteMap.length; k++) { // fill rest of map with default (identity mapping)
            if (!noteMap[k]) {
                noteMap[k] = (k + 1);
            }
        }
        return noteMap;
    }

    function isPitch(x) {
        return x % 1 === 0 && 0 < x && x < 128;
    }

// ================================================================ RUN
    
    onRun: {
        console.log("begin noteMapper");

        if (typeof curScore === 'undefined' || curScore == null) {
            error("NoteMapper plugin requires an open score.\n");
        } else {
            inputArea.selectAll();
            getInput.open();
            inputArea.focus=true;
        }
    }
}
