# nsdeploy

Download and install Azure powershell from here:
https://azure.microsoft.com/en-gb/documentation/articles/powershell-install-configure/

Click on the link in the section 
Step 1: Install

And follow the instructions.

Save the files deploy.ps1 and nightscouttemplate.json to a folder on you computer.

You might be able to double click on deploy.ps1 and it will run, but some computers have this disabled.
if running scripts is disabled, 
	right click on the file deploy.ps1 
	and choose edit.  
	Select all text and click the green arrow for run selection.

When the script starts running you will be prompted for the following information:
Website Name:
Mongo connection string:
API secret:

Website name is whatever you want to call your site, for example if you wanted to call your site mrsmiths-nightscout you would type that in
Your web address would then be https://mrsmiths-nightscout.azurewebsites.net

Mongo connection string is the full connectionstring with username and password, as described in the nightscout set up instructions

API Secrets have to be at least 12 characters long and you should make them a mix of upper and lowercase and numbers.

Thanks to Mike who helped write the script.
	
