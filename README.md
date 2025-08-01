# Portfolio demo application

## ***This repo is work in progress***

This app is meant to showcase my knowledge of following technologies/areas and also their integration:</br>

- Backend
- Mobile
- Embedded
- DevOps
- Node.js
- Android
- BLE protocol
- MQTT protocol
- RTOS
- Docker

| Implemented | Feature |
| ----------- | ------- |
| ✅ (***Phase 1***) | Docker based system for infrastructure |
| ✅ (***Phase 1***) | NodeJS backend application (REST + MQTT) |
| ✅ (***Phase 1***) | ESP32 IDF MQTT app (RTOS) |
| ✅ (***Phase 1***) | PostgreSQL Database |
| ✅ (***Phase 1***) | Linux Embedded Device |
| ✅ (***Phase 1***) | Graphical Embedded Linux App (PySide6) |
| **WIP** (***Phase 2***) | Android App |
| **WIP** (***Phase 2***) | nRF Bluetooth App |

## How to run the demo

Execute only first time:
```bash
    git clone address ~/demoProject
    cd ~/demoProject

    cp ~/demoProject/espProjects/mqtt5/sdkconfig.template ~/demoProject/espProjects/mqtt5/sdkconfig
    # Update in the sdkconfig following lines:
        # CONFIG_BROKER_URL
        # CONFIG_EXAMPLE_WIFI_SSID
        # CONFIG_EXAMPLE_WIFI_PASSWORD
    
    cp nodeBackend/.env.template ~/demoProjectnodeBackend/.env
    # Update in the .env following lines:
        # ACCESS_TOKEN_SECRET
        # REFRESH_TOKEN_SECRET
        # Generate these with:
            $ node
            require('crypto').randomBytes(64).toString('hex')
    
    # Update also in the .env following lines:
        # DATABASE_URL
        # POSTGRES_USER
        # POSTGRES_PASSWORD
        # PGADMIN_DEFAULT_EMAIL
        # PGADMIN_DEFAULT_PASSWORD

    vi ~/demoProject/QtProjects/DemoPySide6V1/configuration.py
        # Update in the configuration.py following lines:
            # SERVER_ADDRESS
            
    # Uncomment the following line in docker-compose.yml to populate the database structure
    - ./sql/create_tables.sql:/docker-entrypoint-initdb.d/create_tables.sql
```

To start the backend:
```bash
    cd ~/demoProject/nodeBackend
    ./start_backend.sh
```

To stop use:
```bash
    docker-compose down
```

### ESP32 IDF App

```bash
    cd ~/demoProject/espProjects/mqtt5
    # Only once when you clone the repo or move folder
        idf.py fullclean
    # To build app
        idf.py build
    # To flash and monitor the app
        idf.py flash monitor
```

### Linux Embedded Device

This demo was done with the RPI 3 and 5inch HDMI Display. Any RPI can be used but 3 was used because of the full size HDMI and I had a HDMI jumper laying around.

- Acquire RPI 3 (If you are using any other SBC (Non RPI variants) you will need to recompile Device Tree).
- Assemble the device.
- Flash the board with the newest Raspbian image. Wayland works ok so it is not limited to X.Org.
- Follow https://www.waveshare.com/wiki/5inch_HDMI_LCD manual for the touch screen support. Display by itself works out of the box or do the 
    1. Download the [waveshare-ads7846.dtbo](https://files.waveshare.com/wiki/10.1inch%20HDMI%20LCD/waveshare-ads7846.dtbo) file. Copy this file to the overlays directory (/boot/overlays/).
    2. Add the following text into /boot/config.txt and reboot:
        ```bash
            hdmi_group=2
            hdmi_mode=87
            hdmi_cvt 800 480 60 6 0 0 0
            hdmi_drive=1
            dtoverlay=waveshare-ads7846,penirq=25,xmin=200,xmax=3900,ymin=200,ymax=3900,speed=50000
        ```
        

### Graphical Embedded Linux App (PySide6) on the Linux Embedded Device
```bash
    # To test it on the host PC or copy it to the device and follow the same steps
    cd /QtProjects/DemoPySide6V1/
    source .qtcreator/Python_3_13_2venv/bin/activate
    python widget.py
```