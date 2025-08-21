# Proxy Skill System ESX Gym

An ESX + oxmysql based gym & skill system for FiveM.  
Tracks **stamina** and **strength** with XP/levels, steroid injections, gym workouts, and more.



Proxy's Gym & Skills System

## Installation

Place proxys-skills in your server resources folder.

Ensure es_extended and ox_inventory are installed.

Add start proxys-skills to your server.cfg.

Configure exercise locations, treadmill, and weights in config.lua.

Use trainer ped to buy day-pass or permanent membership.

Items (protein, steroids) are in items/ folder with PNGs.

## Features

Stamina & Strength training

Exercises: Pressups, Situps, Yoga, Punching Bag, Weights, Chin-Ups

Running & Treadmill

Punching speed and running speed modifiers

Temporary boosts: Protein (stamina), Steroids (strength)

Day pass / Permanent membership system

Trainer NPC interaction

Configurable locations in config.lua

ESX + ox_inventory compatible

Notes

Protein and Steroids have a temporary effect.

Membership is required to exercise.

Weights and chin-ups locations can be moved via config.

This ZIP includes all old and new features, fully compatible with ESX + ox_inventory.
## Installation
1. Place folder `proxy-skill-system-esx-gym` into your `resources/`.
2. Import SQL:
   ```sql
   CREATE TABLE IF NOT EXISTS `proxy_skills` (
     `identifier` VARCHAR(50) NOT NULL,
     `stamina` INT NOT NULL DEFAULT 0,
     `strength` INT NOT NULL DEFAULT 0,
     PRIMARY KEY (`identifier`)
   );

An sql already comes with the file
