# Home Alarm System Project
This project involves the development of a mobile application for both Android and iOS platforms, designed to control a home alarm system using the Home Assistant WebSocket API. In this README, I will provide detailed instructions on how to replicate this project on your own machine, allowing you to customize and extend the code for your needs.

# 1. Installing Home Assistant
Before you can use the mobile app, you must have Home Assistant installed and running, as the app interfaces with the Home Assistant WebSocket API to control your alarm system.

You can follow the official Home Assistant installation guide for various platforms [here](https://www.home-assistant.io/installation/).

# 2. Installing HACS (Home Assistant Community Store)
To use the alarm system, we first need to install the Home Assistant Community Store (HACS), which allows you to easily install and manage custom integrations like Alarmo.
 - Make sure you have file access to your Home Assistant instance (via SSH, Samba, or direct access to the files).
 - Enable Advanced Mode in Home Assistant
 - run this command in terminal: wget -O - https://get.hacs.xyz | bash -
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
- Go to the Users section in the Alarmo configuration to set up your master code and other user codes for disarming the system. (__NOTE: CODE MUST BE 4 DIGITS AS PER MOBILE APP IMPLENTAION. IF MASTER CODE IS NOT 4 DIGITS THE APP MAY RUN INTO ERRORS. IF YOU WISH TO CHANGE THIS YOU WILL NEED TO ALTER THE APP IMPLEMNTATION__)
  


 
