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

- Copy the contents of HassWorkshop/main/java/com/mihir/homealarmsystem/MainActivity.kt and paste it in the file called `MainActivity.kt`. Change line 1 to the appropriate package name:

  <img width="672" alt="Screenshot 2024-09-15 at 12 08 06 AM" src="https://github.com/user-attachments/assets/6f35e337-725f-4f10-9cc4-d8d0c08fbf8f">

- Now create three XML layout files with the names `activity_configuration.xml`, `activity_main.xml`, `keypad_layout.xml` copying the contents of HassWorkshop/main/res/layout/activity_configuration.xml, HassWorkshop/main/res/layout/activity_main.xml, HassWorkshop/main/res/layout/keypad_layout.xml respectively:

  <img width="1163" alt="Screenshot 2024-09-15 at 12 12 03 AM" src="https://github.com/user-attachments/assets/b4584e26-83c0-4031-9a1e-f729e70cb4a7">

- Now create a Kotlin/Class file `ConfigurationActivity` in the folder `homealarmcontrol` copying the contents of HassWorkshop/main/java/com/mihir/homealarmsystem/ConfigurationActivity.kt. Change line 1 appropriately:

  <img width="862" alt="Screenshot 2024-09-15 at 12 36 13 AM" src="https://github.com/user-attachments/assets/59dd5a2d-07bd-4d4e-8dfa-2a20094ebe20">
  
  <img width="870" alt="Screenshot 2024-09-15 at 12 40 07 AM" src="https://github.com/user-attachments/assets/10070e22-d4cc-4d4a-80b3-b8cdf8736e11">



  

  

  



  
  

  



