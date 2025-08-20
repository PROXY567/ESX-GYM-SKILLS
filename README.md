# Proxy Skill System ESX Gym

An ESX + oxmysql based gym & skill system for FiveM.  
Tracks **stamina** and **strength** with XP/levels, steroid injections, gym workouts, and more.

---

## Features
- 📈 **Skills**
  - Stamina: run/swim longer, reduced stamina drain, capped speed boost (max 1.5x).
  - Strength: melee damage buff, faster punches.
  - Both saved to SQL (`proxy_skills` table).

- 🏋️ **Gym System**
  - Pushups, situps, yoga, chinups, and free weights.
  - Configurable locations in `config.lua`.
  - Blips for gyms.
  - ox_lib context menu for exercise selection.
  - XP rewards per exercise.

- 💉 **Steroids**
  - Buy from dealer (phone call animation → 5s locked injection into butt with syringe prop).
  - Adds bonus XP.
  - Cooldown prevents spam.
  - If a player spams (5 buys in 5s) → **silent kick** with message: `Stop spamming steroids`.

- 🗂️ **Database**
  - `proxy_skills` table for saving stamina/strength.
  - Auto save on logout.
  - Auto load on login.

---

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
