# **YARROW** 
### An open-source Internet scanner that monitors open-directories and detects phishing pages.
<br><br>

Yarrow, an open-source and modular internet scanner that assists in the passive detection of:
- Module 1: Servers with open directories that list executables and 
- Module 2: Server that hosts phishing pages. 

Yarrow's first module intends to ensure that the interet is a safe and secure space by passively blocking threats without actions such as installation of anti-virus or other software(s) by end users. This scanner detects malware on Command and Control (C2) servers, inform the webhosts (admin and abuse contacts), and publishes a list of servers as non-commerical open-source lists. 

Yarrow's second module detects phishing pages across the internet for various email providers via a Ruleset Database (RSD) inspired from Yara rules. RSD is an open-source plugin that will enable detection of any phishing page for email, corporate logins, payment providers, or other pages that may be used to malicisouly harvest credentials. 

Yarrow is supported as a research project by Censys API that enables internet scanning for both the modules. Yarrow uses the results and then drills further by obtaining Portable Executable (EXE) checksums and then analyses them across several malware databases. 

Yarrow is published an open-source non-commerical platform that generates feeds containing list of Servers that host malicious files or phishing pages under MIT license.
<br><br>

**Task List for module**
- [ ] Bridge with malware database
- [ ] Integtate with domain datasbase
- [ ] Generate RSD

<br><br>
**Project Supported by:**<br>
Censys (www.censys.io)
<br><br>
**Project Mentor**: Dr. Nived Chebrolu, Oxford University<br>
**Project Founder**: Aadya Srivastava, Student at NAS Dubai<br>
