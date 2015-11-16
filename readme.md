Someone I know is working on an RPG Maker game, and wanted to add achievements without the hassle of writing lots of C++ code. Good news is as of Steamworks SDK 1.32, exports have been added so C++ is not necessary to use most of Steamworks. As such, I have created a script that requires no DLLs other than the Steamworks DLL itself.

Here's how to use the script:

* Copy steam_api.dll from the Steamworks SDK to your project root folder.
* Paste the script into the script editor.
* In an event script or wherever you need it, write the following:
    ```
	steam = SteamUserStatsLite.instance
	steam.set_achievement 'YOUR_ACH_ID_HERE'
	steam.update
	```
* If that second line returns true, the achievement has been set. Otherwise, you'll want to check if you set up achievements properly on Steam.

Please see code for documentation.
