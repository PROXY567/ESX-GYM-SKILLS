CREATE TABLE IF NOT EXISTS `proxy_skills` (
  `identifier` VARCHAR(60) NOT NULL,
  `stamina` INT NOT NULL DEFAULT 0,
  `strength` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
