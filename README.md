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

  <img width="907" alt="Screenshot 2024-09-14 at 10 46 26 PM" src="https://github.com/user-attachments/assets/900bd465-8410-4880-bbd4-98c97b699e19">
  



