![Ala15vLogo](https://github.com/alexsm32/Ala15vToolbox/blob/documentation/img/LogoALA15V.png)
# Ala15vToolbox
## Introduction
This is a set of functions oriented to help people with low scripting experience using the DCS framework "**Moose**" (mainly) and others.
## How to use it
1. First, you need to include Moose framework to your mission

![Moose](https://github.com/alexsm32/Ala15vToolbox/blob/documentation/img/SetMoose.png)

2. After including Moose, you need to add thoese *Ala15vToolbox functions* you are going to use

![Ala15vToolbox](https://github.com/alexsm32/Ala15vToolbox/blob/documentation/img/SetAla15vToolbox.png)

3. Now you can use those functions the way you prefere

![UseIt](https://github.com/alexsm32/Ala15vToolbox/blob/documentation/img/UseAla15vToolbox.png)

### In case of error
If something goes wrong, you can get a good hint from the DCS log file in `Saved Games\DCS.openbeta\Logs\dcs.log`

![Error](https://github.com/alexsm32/Ala15vToolbox/blob/documentation/img/ErrorShowCase.png)

The functions also write logs in this file. Those logs can be useful to narrow the problem.

![Logs](https://github.com/alexsm32/Ala15vToolbox/blob/documentation/img/LogsShowCase.png)

- **Info**: shows how is proceeding the functions.
- **Warning**: shows issues that can modify the normal behaviour of the function. Those could be normal for campaings. But in normal missions, the editor should take a look and apply changes.
- **Error**: shows critical issues that will stop the function. In some cases, those could be normal for campaings. But in normal missions, the editor **must** take a look and apply changes.

## Roadmap
- Moose Modules:
    - [x] AI A2A Dispatcher `(Campaing Ready)`
    - [x] AI A2G Dispatcher `(Under testing)`
    - [ ] AI Cargo Dispatcher
    - [ ] Arty
    - [ ] Designate
    - [x] Suppression
    - [x] Warehouse (WIP) `(Campaing Ready)`
    - [x] ATIS `(Campaing Ready)`
    - [x] CSAR
    - [ ] CTLD
    - [x] Recovery Tanker `(Campaing Ready)`
    - [x] Rescue Helo `(Campaing Ready)`
    - [ ] Spawn
    - [ ] User Flag
    - [x] RAT `(Campaing Ready)`
