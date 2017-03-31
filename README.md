# Create-and-Deploy-Windows-Default-Profiles

Scripts for the creating and deploying of default profiles. Originally made with windows 10 and Fog-project snap-ins in mind.
The idea is to customize a profile for a image to your hearts content. Then you run the create script. This saves the profile as the default profile on that computer (as in any new users on that computer will get the taskbar pins, start screen layout, background, explorer settings, etc.) and also copies it to a network location you specify.

The apply script takes arguments to deploy your choice of created profiles to any new computer. This can be run manually, but it was designed to be used as a fog-project snap-in. Check out fog project here https://github.com/FOGProject

This was originally created for windows 10 and done while trying to make it so my old way of doing this didn't break cortana in windows 10 profiles. You can see a lot more on that discussion here https://forums.fogproject.org/topic/6431/cortana-windows-search-breaks-in-default-profile

I have plans to make this much more universal and for it to use more registry hive editing of specific things, which would in turn allow for editing just one part of an already created profile.

NOTE: Coming Soon - This will be rewritten with powershell with integrations for using chocolatey packages to create and apply the profiles. Check out chocolatey.org. I use chocolatey for business. But some aspects can be done with the free version. 
