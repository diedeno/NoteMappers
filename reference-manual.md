# NoteMapper Plugins

A bundle of six pitch-transformation plugins for [MuseScore 2](https://musescore.org). The principal mapping plugins  —  **Note to Note**, **Pc to Pc**, and **Pitch to Pitch** —  map pitches to new values using different models of pitch, as detailed in the descriptions below. The **Map Assistant** plugin lets you design various types of maps with music notation, using a specially formatted score. Maps (which are just comma-separated lists of numbers) can be copied from any of these sources and pasted as text in a score or text file to store them for future use.

Once copied, a map can be pasted into the appropriate mapping plugin, or into the **Adaptive Mapper**, which is designed to recognize and apply any valid map (five types in all). Finally, a **Pc Speller** utility is provided for customizing the spelling of each chromatic step; it is particularly useful in conjunction with the Pc to Pc and Pitch to Pitch plugins, which spell pitches according to built-in defaults that may not suit you.

## Table of Contents
- [Installation](#installation)
- [Uses](#uses)
- THE PLUGINS
  - [Note to Note](#note-to-note)
  - [Pc to Pc](#pc-to-pc)
  - [Pitch to Pitch](#pitch-to-pitch)
  - [Map Assistant](#map-assistant)
  - [Adaptive Mapper](#adaptive-mapper)
  - [Pc Speller](#pc-speller)


## Installation

To use the NoteMapper plugins, you must first install MuseScore. Installations for Windows, Mac, Linux, and BSD are available from the [MuseScore website](https://musescore.org/). These plugins are only compatible with version 2 of MuseScore. 

Next: 

1. **Download** 

  - [NoteMappers](url TBD) at the MuseScore website NoteMappers page
  - _or_ [NoteMappers](https://minhaskamal.github.io/DownGit/#/home?url=https://github.com/paulsantacruz/NoteMappers/tree/master/NoteMapper-qml-files) via Minhas Kamal's DownGit
  
2. This gives you a zipped archive with all six plugins. Unzip; you'll have a folder **NoteMapper-qml-files** with files like "NoteMapper-Adaptive.qml". (Or you can find individual \*.qml files at https://github.com/paulsantacruz/NoteMappers/tree/master/NoteMapper-qml-files.)

3. Follow the MuseScore Handbook instructions for [plugin installation](https://musescore.org/en/handbook/plugins#installation).


## Uses

A common mapping application is to transform melodic material by changing its underlying mode or scale. Purely modal or diatonic material is best suited to this treatment, because chromatic alterations make the identity of each mode/scale less clear and complicate the design of a suitable map. _Composers who work with modal and tonal materials_ may be particularly interested in the Note to Note, Map Assistant, and Adaptive Mapper plugins.

<img src="https://github.com/paulsantacruz/NoteMappers/blob/master/images/NoteToNote_ModeMap_Ex.PNG" title="NoteToNote_ModeMap_Ex.PNG">

Conversely, if your musical language encompasses _atonal and highly/freely chromatic materials_, the Pc to Pc and Pitch to Pitch plugins may be of interest, especially if you are familiar with the integer models of pitch and pitch class that are common in twelve-tone and musical set theory (e.g. https://en.wikipedia.org/wiki/Pitch_class#Integer_notation). The Map Assistant and Adaptive Mapper plugins make some of the same functions accessible to users who prefer to stick with music notation. (But anyone with experimental inclinations might have fun with the Pc to Pc plugin's randomizers!)

<img src="https://github.com/paulsantacruz/NoteMappers/blob/master/images/PcToPc_Map_Ex.PNG" title="PcToPc_Map_Ex.PNG">

A description of each NoteMapper plugin follows. You can access much of the same information within a plugin by clicking on its Help button.


## Note to Note

<img src="https://github.com/paulsantacruz/NoteMappers/blob/master/images/NoteToNote_and_Help.PNG" width="70%" height="70%" title="NoteToNote_and_Help.PNG">

Use the **From**/**To** input boxes across the top of the Map Input window to assign a new value (letter-name and optional accidental) to a note in every octave throughout the music you are processing. Add as many assignments as the map requires. Then click **Apply** to process the currently selected passage, or the entire score if nothing is selected. 

An overview of the map is provided on the right side of the window. Click **remove** to delete an individual assignment from the map. Click the **Sort** button to sort the entire overview alphabetically, from A-double-flat through G-double-sharp.

An **Import/Export** field, located at the bottom of the Help window, contains a string representing the current map that can be saved as text in a score or text file. Paste a previously saved string into the same field (and check the "Use imported string" box) to import it, replacing the current contents of the Map Input window when Help is closed. The Import/Export string format is a comma-separated list of 35 tpc values (tonal pitch class: integers in the range -1 through 33).

The Note to Note plugin is responsive to scores with [transposing instruments](https://musescore.org/en/handbook/transposition#transposing-instruments). When a score is viewed in **concert pitch**, mapped values are calculated and written into the score using concert pitches for all parts. But when the **transposed** (default) score view is in effect, letter-names and accidentals are read as they appear in the transposed score, and mapped values are written with respect to the same transposition. _Example:_ if C is mapped to C-sharp, then written C (concert B-flat) becomes written C-sharp (concert B) in a part for B-flat clarinet. _Recommendation:_ if you want to apply a map to a score in transposed view, plugin behavior may be easier to understand if you select and process one staff at a time.


## Pc to Pc

<img src="https://github.com/paulsantacruz/NoteMappers/blob/master/images/PcToPc.PNG" width="50%" height="50%" title="PcToPc.PNG">
      
Pitch class (pc) values represent steps of the chromatic scale: 0 is C (and its enharmonic equivalents), 1 is C-sharp (ditto), and so on. A map determines how pc values will be changed in the music you are processing. To map pc X to a new value Y, find X in the "From" row at the top of the interface, and enter Y in the "To" field directly below it. Use as many "To" fields as your map requires, or try randomizing all twelve values. Then click **Apply** to process the currently selected passage, or the entire score if nothing is selected. 

New pc values are set in the octave that keeps notes nearest their original positions, and they are spelled according to built-in defaults (e.g. 8 is A-flat rather than G-sharp).

An **Import/Export** field, located at the bottom of the Help window, contains a string representing the current map that can be saved as text in a score or text file. Paste a previously saved string into the same field to import it, replacing the current contents of the Map Input window when Help is closed. The Import/Export string format is a comma-separated list of 12 cpc values (chromatic pitch class: integers in the range 0 through 11).

The Pc to Pc plugin is responsive to scores with [transposing instruments](https://musescore.org/en/handbook/transposition#transposing-instruments). When a score is viewed in concert pitch, mapped values are calculated and written into the score using concert pitches for all parts. But when the transposed (default) score view is in effect, values are read as they appear in the transposed score, and mapped values are written with respect to the same transposition. _Example:_ if 0 is mapped to 3, then written C (concert B-flat) becomes written E-flat (concert D-flat) in a part for B-flat clarinet. _Recommendation:_ if you want to apply a map to a score in transposed view, plugin behavior may be easier to understand if you select and process one staff at a time.


## Pitch to Pitch

<img src="https://github.com/paulsantacruz/NoteMappers/blob/master/images/PitchToPitch.PNG" width="50%" height="50%" title="PitchToPitch.PNG">

A Pitch to Pitch map determines how MIDI pitch values will be changed in the music you are processing. Normally you specify a map with one or more **pairs** of the form `X:Y`, meaning "map X to Y". For example, `60:72` raises every middle C by an octave. You can specify additional pairs on new lines, or put them on the same line separated with commas. So:

    45:46,46:45,47:48,48:47
  
is equivalent to

    45:46
    46:45
    47:48
    48:47

It is also possible to specify a map with a **list** of exactly 127 comma-separated pitch values. In this alternative format, the number in the nth position (counting from 1) determines the new value of pitch n. So a map with 72 in the 60th position will raise every middle C by an octave. While it is hardly practical to construct such a long list by hand, you can use the **Map Assistant** plugin to build a list based on the notes in a score, then paste it into the Pitch to Pitch plugin's Map Input window.

Once a map is entered in either format (pairs or list), click **Apply** to process the currently selected passage, or the entire score if nothing is selected. The Pitch to Pitch plugin currently operates on concert pitch only, due to limitations of the plugin framework. (Specifically: it is not possible for a plugin to determine the octave in which transposed pitches are displayed.) _Recommendation:_ plugin behavior may be easier to understand if you [view your score in concert pitch](https://musescore.org/en/handbook/transposition#transposing-instruments) when transposing instruments are present.


## Map Assistant

<img src="https://github.com/paulsantacruz/NoteMappers/blob/master/images/MapAsst_and_Result.PNG" width="70%" height="70%" title="MapAsst_and_Result.PNG">

Use this plugin to build maps of various types based on notes in the current score. Copy the result and paste it into a suitable NoteMapper to apply it, or save it as text in a score or text file.


### Map Types

**Note to Note.** Sends notes (letter-names and optional accidentals) to new values. Applies the same mapping in every octave. Comma-separated list of 35 tpc values (tonal pitch class: integers in the range -1 through 33). Use in Note to Note or Adaptive Mapper.

**PC to PC.** Sends steps of the chromatic scale to new values, which will receive default spellings when the map is applied. Applies the same mapping in every octave. Comma-separated list of 12 cpc values (chromatic pitch class: integers in the range 0 through 11). Use in Pc to Pc or Adaptive Mapper.

**Pitch to Pitch.** Sends MIDI pitches to new values, which will receive default spellings when the map is applied. Comma-separated list of 127 MIDI pitches (integers in the range 1 through 127). Use in Pitch to Pitch or Adaptive Mapper.

**12 spelled PCs.** Sends steps of the chromatic scale to new values and new spellings. Applies the same mapping in every octave. Comma-separated list of 12 cpc values followed by 12 tpc values. Use in Adaptive Mapper only.

**127 spelled Pitches.** Sends MIDI pitches to new values and new spellings. Comma-separated list of 127 MIDI pitches followed by 127 tpc values. Use in Adaptive Mapper only.


### Score Format

Map Assistant expects a score with two staves, each with a succession of single notes, and it produces a map that sends the first note of the upper staff to the first of the lower, the second of the upper to the second of the lower, third to third, and so on. The alignment of upper-staff and lower-staff notes is ignored, as are surplus notes, voices, and staves (see example). A score far outside these expectations may cause the plugin to fail.

<img src="https://github.com/paulsantacruz/NoteMappers/blob/master/images/MapAsst_ScoreEx.PNG" title="MapAsst_ScoreEx.PNG">


## Adaptive Mapper

<img src="https://github.com/paulsantacruz/NoteMappers/blob/master/images/Adaptive.PNG" width="50%" height="50%" title="Adaptive.PNG">

The Adaptive Mapper is designed to recognize and apply maps originating from various NoteMapper plugins: Note to Note, Pc to Pc, and Pitch to Pitch; plus maps derived from music notation using the Map Assistant plugin. Maps (which are just comma-separated lists of numbers) can be copied from any of these sources and pasted into the Adaptive Mapper Input window. To store a map for future use, simply paste it as text in a score or text file.

Once a map is entered, click **Apply** to process the currently selected passage, or the entire score if nothing is selected. The Adaptive Mapper is responsive to scores with [transposing instruments](https://musescore.org/en/handbook/transposition#transposing-instruments), when it applies maps originating from the Note to Note and Pc to Pc plugins. For details, see the documentation for these plugins. Finally, maps produced by the Map Assistant using the "Note to Note" or "Pc to Pc" formats inherit the same behavior, and the "12 spelled PCs" format is treated similarly.


### Map Sources

**Note to Note:** Import/Export field in Help window (35 tpc values)

**Pc to Pc:** Import/Export field in Help window (12 cpc values)

**Pitch to Pitch:** Copy from Input window (127 pitch values, not X:Y pairs)

**Map Assistant:** Copy from Result window (12, 24, 35, 127, or 254 values, based on choice of map type)


### Map Values

**CPC (chromatic pitch class):** integer 0 – 11, representing steps of the chromatic scale

**Pitch:** integer 1 – 127, representing MIDI pitch

**TPC (tonal pitch class):** integer -1 – 33, representing letter-name plus accidental


## Pc Speller

<img src="https://github.com/paulsantacruz/NoteMappers/blob/master/images/PcSpeller.PNG" width="50%" height="50%" title="PcSpeller.PNG">

Use this plugin to apply a spelling of your choice to each step of the chromatic scale (i.e. to each pitch class 0 through 11). Leave a setting at "--" to preserve a pc's existing spelling(s). For instance, if the music you are processing includes a mixture of G-sharps and A-flats, the plugin can spell them uniformly one way or the other, or leave things as they stand. It cannot choose spellings based on tonal context or make case-by-case decisions. It is mainly intended as a tool for overriding the default spellings used by the Pc to Pc and Pitch to Pitch plugins.

The Pc Speller also provides a function for showing accidentals explicitly on every note, as is commonly done in post-tonal music. There are options to include/exclude notes with naturals and notes with incoming ties in this process. The code that implements this feature is adapted from plugins written by Jörn Eichler.

The Pc Speller plugin is responsive to scores with [transposing instruments](https://musescore.org/en/handbook/transposition#transposing-instruments). When a score is viewed in **concert pitch**, spellings apply to concert pitches, and transposed pitches are left untouched. Conversely, in **transposed view**, spellings apply to transposed pitches, and concert pitches are left untouched.


<!-- GD2md-html version 1.0β13 -->
