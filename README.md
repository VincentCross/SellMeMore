# SellMeMore
A simple Avorion mod that alters how many pieces of equipment are sold by shops.

## Install Singleplayer
1. Download and place SellMeMore folder into: %appdata%/Roaming/Avorion/mods/
2. On Avorion main menu, enable the mod in the Mods section of Settings.

## Install Dedicated Server
1. Download and place SellMeMore folder into the location specified in your [modconfig.lua](https://avorion.gamepedia.com/Using_Mods_on_Dedicated_Servers)
2. Add the following to the mods list: {path = prefix .. "SellMeMore"}

## Configuration
In data/config/sellMeNowConfig.lua you can find a few configuration options:
- amountSystemsSold - Sets a flat amount of systems that are sold.
- amountTurretsSold - Sets a flat amount of turrets that are sold.
- randomSoldEquipmentBool - If set to 'true' it will randomize the amount within the below amounts.
- randomSoldEquipmentMin - The minimum amount that should be sold.
- randomSoldEquipmentMax - The maximum amount that should be sold.

