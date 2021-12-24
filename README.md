# WhatsDown iOS
WhatsDown iOS version

Using WooCommerce.... For Cloning for another project


# Creating New Project from this
Duplicate this folder
Rename the duplicated folder
Open the duplicated folder
Delete .git (hidden file)
Open the SkyeCommerce.xcworkspace
Click on SkyeCommerce workspace
Change Project name, bundle etc
Change SkyeCommerce workplace name to your new name
In the pop dialog allow rename
Remove Pods_SkyeCommerce.framework from framework list
Also delete Pods_SkyeCommerce.framework files in Frameworks folder
Edit Scheme by clicking SkyeCommerce beside run & stop button at the top bar
Click on manage scheme
Uncheck SkyeCommerce
Click on (plus) to add new Scheme (a new scheme will auto generate with your renamed workspace)
Check the new scheme and close
Close or Exit XCode
Open Podfile
Rename SkyCommerce to your new workspace name
Open Terminal, locate your new project folder
Then run this command "pod install"
After success
New .xcworkspace file will be created
Delete the old SkyeCommerce.xcworkspace
ALL DONE
Start opening your new project with the new .xcworkspace file
