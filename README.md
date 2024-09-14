# Home Alarm System Project
This project involves the development of a mobile application for both Android and iOS platforms, designed to control a home alarm system using the Home Assistant WebSocket API. In this README, I will provide detailed instructions on how to replicate this project on your own machine, allowing you to customize and extend the code for your needs.

# Installing Home Assistant
Before you can use the mobile app, you must have Home Assistant installed and running, as the app interfaces with the Home Assistant WebSocket API to control your alarm system.

You can follow the official Home Assistant installation guide for various platforms [here](https://www.home-assistant.io/installation/).

# Installing HACS (Home Assistant Community Store)
 - Make sure you have file access to your Home Assistant instance (via SSH, Samba, or direct access to the files).
 - Enable Advanced Mode in Home Assistant
 - run this command in Terminal:
    "wget -O - https://get.hacs.xyz | bash -"
    on home assistant.
 - Restart Home Assistant
 - Add HACS to integrations
 
