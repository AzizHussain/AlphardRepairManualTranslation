# Alphard AH20 2nd Gen - Repair Manual Translation
A translation of the Japanese Alphard AH20 electronic repair manual (XML version). Please not that this translation is currently INCOMPLETE and ONGOING.

These are a set of scripts which will carry out the translation - they are not the repair manual itself - you will need to supply your own copy of the repair manual. The repair manual can be bought on Japanese websites such as Yahoo (via Jauce / Buyee), Rakuten, Mercari, Amazon.co.jp etc

# What's done
* Translation of the text repair sections

# What's not done
* Translation of SVG diagram text
* Translation of EWD (Electronic Wiring Diagram)
* Translation of other miscellanous GUI related elements (button images, button text etc)
* Mapping file of manual corrections needed
  
# Requirements
You will require:
- A Japanese copy of the Alphard AH20 repair manual (the XML version)
- A Windows computer with Powershell 5 (Windows 10 will hav it by default)
- The Various PowerShell scripts

# Instructions
Open each script in turn and run it. You will be prompted to select the repair manual source and where to copy a temporary version of the repair manual to. Run each successive script in turn.

# FAQs
**Q1. Will this work on other Toyota electronic repair manuals, e.g. Alphard AH10?**

A1. Possibly, if the repair manual has the same structure with content stored inside XML files and diagrams as SVGz. I am unable to 

**Q2. How do I get the repair manual to load correctly on Windows 10?
**
A2. Modern OSs don't work very well with the old repair manual. You can try open it in Edge's Internet Explorer compatiblity mode, but you will noyl get partialy functionality (e.g. SVGs probably won't load correctly)

**Q3. There are lots of formatting mistakes (random characters in the wrong place, non-capitalised acronyms etc) - why?**

A3. Each string in the XML file is run through Google Translate, unfortunately due to quirks in the original text and/or translation limitations, there are often minor formatting/grammatical errors. There is an attempt in the scripts to 'manually' correct some common errors where they are noticed, but there are hundreds of thousands of individual strings that need to be translated and more resources are needed to manually identify additional common quirks. If you are able to help with this, please get in touch.

**Q4. How can I help with this translation project?**

AA. There are a number of issues still that need to be fixed, and additional resources are required - both technical and non-technical.
* Someone with front end dev skills (HTML, CSS) to help get the repair manual working on modern browsers
* Someone to go through the translations and update the mapping file for manual corrections e.g. where 'ecu' should be 'ECU'
