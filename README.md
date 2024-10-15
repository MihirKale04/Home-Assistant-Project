# Home Alarm System Project
This project involves the development of a mobile application for both Android and iOS platforms, designed to control a home alarm system using the Home Assistant WebSocket API. In this README, I will provide detailed instructions on how to replicate this project on your own machine, allowing you to customize and extend the code for your needs.

# 1. Installing Home Assistant
Before you can use the mobile app, you must have Home Assistant installed and running, as the app interfaces with the Home Assistant WebSocket API to control your alarm system.

You can follow the official Home Assistant installation guide for various platforms [here](https://www.home-assistant.io/installation/).

# 2. Installing HACS (Home Assistant Community Store)
To use the alarm system, we first need to install the Home Assistant Community Store (HACS), which allows you to easily install and manage custom integrations like Alarmo.
 - Make sure you have file access to your Home Assistant instance (via SSH, Samba, or direct access to the files).
 - Enable Advanced Mode in Home Assistant
 - run this command in terminal: `wget -O - https://get.hacs.xyz | bash -`
 - Restart Home Assistant
 - Add HACS to integrations

# 3. Installing and Setting Up Alarmo
Once HACS is installed, you can now proceed to install and configure the Alarmo integration for managing your home alarm system.
## Install Alarmo via HACS
- Navigate to HACS in the Home Assistant sidebar.
- Click on Integrations.
- Search for Alarmo in the search bar.
- Click on Alarmo and then click Download to install the integration.
 ## Configure Alarmo
- Select which sensors (e.g., door/window sensors, motion detectors) are assigned to each security area.
- Set up actions that should occur when the alarm is triggered (e.g., sending notifications or activating sirens).
- Go to the Users section in the Alarmo configuration to set up your master code and other user codes for disarming the system.

(__NOTE: CODE MUST BE 4 DIGITS. TO CHANGE THIS YOU WILL NEED TO ALTER MOBILE APP IMPLEMENTATION__)
## Setting Up the Alarmo Control Card
- Navigate to the Overview page in your Home Assistant dashboard.
- Click on the three-dot menu in the top right corner and select Edit Dashboard.
- While in edit mode, click the + Add Card button.
- Scroll through the available card types and select the Alarm Panel card.
- In the card configuration window, specify the `entity` that represents your alarm system. For Alarmo, this is typically `alarm_control_panel.alarmo`.
- Customize the title or leave it as the default (e.g., "Home Alarm").
- Configure any additional options, such as which buttons (e.g., arm home, arm away) to show on the card.
  
# 4. Generating a Home Assistant Long-Lived Access Token
To allow the mobile app to communicate with Home Assistant, you'll need to generate a long-lived access token. This token is used for authenticating API requests.
 - In your Home Assistant interface, click on your user profile in the lower left corner.
 - Scroll down to the section labeled Long-Lived Access Tokens.
 - Click Create Token. A dialog will prompt you to name the token (e.g., "Mobile App Access Token").
 - Once you provide a name, a token will be generated. Copy this token immediately as you will not be able to view it again. If you lose it, you will need to generate a new token.
 - Save this token securely in a safe location for use in your mobile app.

# 5. Setting Up Your Development Environment
To build the mobile app, you will need to download and set up a development environment. Choose either Xcode (for iOS) or Android Studio (for Android) based on the platform you want to develop for.

# ANDROID
- Download and install Android Studio from the official site [here](https://developer.android.com/studio).
- Follow the installation prompts for your operating system (available for Windows, macOS, and Linux).
## Creating a New Android Project in Android Studio
1. On the Android Studio welcome screen, click New Project.
2. From the list of available templates, select Empty Activity. This will provide a basic template for your Android app with minimal setup.
3. Follow a similar configuration to the one shown in the screenshot below:
   
    <img width="891" alt="Screenshot 2024-09-14 at 10 56 10 PM" src="https://github.com/user-attachments/assets/9b5224ac-ec79-40d1-942a-c0306975ee02">
    
5. After configuring the project, click Finish. Wait for the project to finish building. Once completed, your project file structure should look like this:

    <img width="628" alt="Screenshot 2024-09-15 at 12 18 52 AM" src="https://github.com/user-attachments/assets/f95fd101-5608-4929-9849-42b68b641cdd">

5. Next, open the file `build.gradle.kts (Module: app)` and add the following lines of code to the dependencies section:
```
implementation(libs.androidx.appcompat)
implementation("com.squareup.okhttp3:okhttp:4.12.0")
```
Refer to the screenshot below for proper placement:

   <img width="519" alt="Screenshot 2024-09-14 at 11 51 09 PM" src="https://github.com/user-attachments/assets/98fb679c-74a6-44c5-830e-44fe223dd08c">

## Updating the AndroidManifest.xml
6. Open the file `AndroidManifest.xml`. Copy the contents from the HassWorkshop repository (found under `main/AndroidManifest.xml`) and paste them into your project's `AndroidManifest.xml` file. Don’t forget to change line 13 to the appropriate package name:
  
   <img width="690" alt="Screenshot 2024-09-14 at 11 59 32 PM" src="https://github.com/user-attachments/assets/c7d01206-ff7d-4bbd-bd23-a29013cb83d7">

## Configuring the MainActivity
7. Next, open `MainActivity.kt`. Copy the contents from `HassWorkshop/main/java/com/mihir/homealarmsystem/MainActivity.kt` and paste them into your project’s `MainActivity.kt` file. Make sure to update line 1 with your project’s correct package name:

   <img width="672" alt="Screenshot 2024-09-15 at 12 08 06 AM" src="https://github.com/user-attachments/assets/6f35e337-725f-4f10-9cc4-d8d0c08fbf8f">

## Creating Layout Files
8. Now, create three new XML layout files in your project’s `res/layout` folder:
   - `activity_configuration.xml`
   - `activity_main.xml`
   - `keypad_layout.xml`
 
 Copy the contents from the corresponding layout files in `HassWorkshop/main/res/layout/` and paste them into your new layout files.

   <img width="1163" alt="Screenshot 2024-09-15 at 12 12 03 AM" src="https://github.com/user-attachments/assets/b4584e26-83c0-4031-9a1e-f729e70cb4a7">

 ## Adding the ConfigurationActivity
 9. Finally, create a new Kotlin class file named `ConfigurationActivity` in your project’s `homealarmcontrol` folder. Copy the contents from `HassWorkshop/main/java/com/mihir/homealarmsystem/ConfigurationActivity.kt` and paste them into the new file. Update line 1 with the appropriate package name:
     
     <img width="862" alt="Screenshot 2024-09-15 at 12 36 13 AM" src="https://github.com/user-attachments/assets/59dd5a2d-07bd-4d4e-8dfa-2a20094ebe20">
  
     <img width="870" alt="Screenshot 2024-09-15 at 12 40 07 AM" src="https://github.com/user-attachments/assets/10070e22-d4cc-4d4a-80b3-b8cdf8736e11">

 ## Running and Configuring the App
 After setting up the project files, you are now ready to run the app. However, before the app can function correctly, you need to configure it by entering the IP address and port of your Home Assistant instance, as well as the long-lived access token generated earlier.
 1. Press Run in Android Studio to launch the app. If everything is set up correctly, the app should now open on your connected device or emulator.
 2. When the app launches, you’ll see the configuration screen, as shown below:

    <img width="365" alt="Screenshot 2024-09-15 at 12 46 04 AM" src="https://github.com/user-attachments/assets/7bff1fe9-613a-4dc6-8f70-12c1fcb26ca8">

 3. In the configuration screen:
    - __Home Assistant URL__: Enter the IP address and port of your Home Assistant instance (e.g., `http://192.168.1.100:8123`).
    - __Access Token__: Enter the long-lived access token you saved earlier during the Home Assistant setup process
 4. After entering the correct details, save the configuration. The app will now be able to communicate with Home Assistant, allowing you to control the alarm system.

# (IOS) IPHONE
To build the app for iOS, you'll need a macOS device and Xcode installed. Xcode is Apple's official IDE for iOS development, and it's required to run, build, and deploy apps on iPhone.
## Ensure You Have a Mac and Xcode Installed
1. Using macOS: Make sure you are using a Mac running macOS.
2. If Xcode is not installed, download it from the Mac App Store or from Apple's developer website.
## Create a New Project in Xcode
1. Create a New Project:
   - On the Xcode welcome screen, click Create a new Xcode project.
   - In the dialog that appears, select App under the iOS section, then click Next.
 
    <img width="736" alt="image" src="https://github.com/user-attachments/assets/30182f4e-209c-474d-a7f9-13b70d017034">

2. Configure the Project:
   - enter a name for your project
   - f you are using a personal Apple ID for development, select your name from the Team dropdown. If you don’t have a development team set up, configure a free or paid Apple developer account.
   - Use a unique identifier.
   - Select Swift for the development language.
   - Choose SwiftUI for the user interface framework.

    <img width="732" alt="image" src="https://github.com/user-attachments/assets/bd61fd97-0426-4a8e-bb8a-6eed4c1c8703">
  
3. Choose a location on your Mac to save the project and click Create.
## Project Overview in Xcode
Once your project is loaded in Xcode, your IDE should look similar to the following screenshot:
    <img width="818" alt="image" src="https://github.com/user-attachments/assets/c299c4bc-f1d5-4539-9637-16830cb58139">
## Copy Code into `ContentView.swift`
1. Navigate to the `HassWorkshop/HASSWebSocketUIClient/HASSWebSocketUIClient/ContentView.swift` file in this GitHub repository and copy all the code.
2. In your Xcode project, locate the `ContentView.swift` file in the file navigator (usually found in the left panel).
3. Open `ContentView.swift` and select any existing code within the file.
4. Right-click and choose Paste, or press Command + V on your keyboard to replace the contents with the copied code.
    <img width="830" alt="image" src="https://github.com/user-attachments/assets/3f001ae6-ddda-4db0-934e-43cc53962bbe">












  

  

  



  
  

  



