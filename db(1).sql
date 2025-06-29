-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema rideshare
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `rideshare` ;
CREATE SCHEMA IF NOT EXISTS `rideshare` DEFAULT CHARACTER SET utf8 ;
USE `rideshare` ;

-- -----------------------------------------------------
-- Table `rideshare`.`automobile`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `rideshare`.`automobile` ;
CREATE TABLE IF NOT EXISTS `rideshare`.`automobile` (
  `n_telaio` CHAR(17) NOT NULL,
  `targa` VARCHAR(10) NOT NULL,
  `modello` VARCHAR(100) NOT NULL,
  `cilindrata` INT NOT NULL,
  `n_posti` TINYINT NOT NULL,
  PRIMARY KEY (`n_telaio`),
  UNIQUE INDEX `targa_UNIQUE` (`targa` ASC) VISIBLE
) ENGINE=InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `rideshare`.`autista`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `rideshare`.`autista` ;
CREATE TABLE IF NOT EXISTS `rideshare`.`autista` (
  `id_autista` CHAR(16) NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `cognome` VARCHAR(45) NOT NULL,
  `telefono` VARCHAR(20) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `fotografia` BLOB NULL,
  `num_patente` VARCHAR(20) NOT NULL,
  `scadenza_patente` DATE NOT NULL,
  `n_telaio` CHAR(17) NOT NULL,
  PRIMARY KEY (`id_autista`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
  INDEX `n_telaio_idx` (`n_telaio` ASC) VISIBLE,
  CONSTRAINT `fk_autista_auto`
    FOREIGN KEY (`n_telaio`)
    REFERENCES `rideshare`.`automobile` (`n_telaio`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `rideshare`.`passeggero`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `rideshare`.`passeggero` ;
CREATE TABLE IF NOT EXISTS `rideshare`.`passeggero` (
  `id_passeggero` CHAR(16) NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `cognome` VARCHAR(45) NOT NULL,
  `documento` VARCHAR(20) NOT NULL,
  `telefono` VARCHAR(20) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_passeggero`),
  UNIQUE INDEX `documento_UNIQUE` (`documento` ASC) VISIBLE,
  UNIQUE INDEX `telefono_UNIQUE` (`telefono` ASC) VISIBLE,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE
) ENGINE=InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `rideshare`.`viaggio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `rideshare`.`viaggio` ;
CREATE TABLE IF NOT EXISTS `rideshare`.`viaggio` (
  `id_viaggio` INT NOT NULL AUTO_INCREMENT,
  `id_autista` CHAR(16) NOT NULL,
  `citta_partenza` VARCHAR(100) NOT NULL,
  `citta_destinazione` VARCHAR(100) NOT NULL,
  `data_partenza` DATE NOT NULL,
  `orario_partenza` TIME NOT NULL,
  `costo` DECIMAL(8,2) NOT NULL,
  `tempo_stimato` TIME NOT NULL,
  `posti_disponibili` TINYINT NOT NULL,
  `chiuso` BOOLEAN NOT NULL DEFAULT FALSE,
  `bagaglio_ok` BOOLEAN NOT NULL DEFAULT TRUE,
  `animali_ok` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`id_viaggio`),
  UNIQUE INDEX `id_viaggio_UNIQUE` (`id_viaggio` ASC) VISIBLE,
  INDEX `id_autista_idx` (`id_autista` ASC) VISIBLE,
  CONSTRAINT `fk_viaggio_aut`
    FOREIGN KEY (`id_autista`)
    REFERENCES `rideshare`.`autista` (`id_autista`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `rideshare`.`sosta`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `rideshare`.`sosta` ;
CREATE TABLE IF NOT EXISTS `rideshare`.`sosta` (
  `id_viaggio` INT NOT NULL,
  `ordine` TINYINT NOT NULL,
  `localita` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_viaggio`,`ordine`),
  INDEX `id_viaggio_idx` (`id_viaggio` ASC) VISIBLE,
  CONSTRAINT `fk_sosta_viaggio`
    FOREIGN KEY (`id_viaggio`)
    REFERENCES `rideshare`.`viaggio` (`id_viaggio`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `rideshare`.`prenotazione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `rideshare`.`prenotazione` ;
CREATE TABLE IF NOT EXISTS `rideshare`.`prenotazione` (
  `id_prenotazione` INT NOT NULL AUTO_INCREMENT,
  `id_viaggio` INT NOT NULL,
  `id_passeggero` CHAR(16) NOT NULL,
  `data_richiesta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `stato` ENUM('PENDING','ACCEPTED','REJECTED') NOT NULL DEFAULT 'PENDING',
  PRIMARY KEY (`id_prenotazione`),
  UNIQUE INDEX `id_viaggio_passeggero_UNIQUE` (`id_viaggio`,`id_passeggero` ASC) VISIBLE,
  INDEX `id_viaggio_idx` (`id_viaggio` ASC) VISIBLE,
  INDEX `id_passeggero_idx` (`id_passeggero` ASC) VISIBLE,
  CONSTRAINT `fk_prenotazione_viaggio`
    FOREIGN KEY (`id_viaggio`)
    REFERENCES `rideshare`.`viaggio` (`id_viaggio`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_prenotazione_passeggero`
    FOREIGN KEY (`id_passeggero`)
    REFERENCES `rideshare`.`passeggero` (`id_passeggero`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `rideshare`.`feedback_autista`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `rideshare`.`feedback_autista` ;
CREATE TABLE IF NOT EXISTS `rideshare`.`feedback_autista` (
  `id_feedback` INT NOT NULL AUTO_INCREMENT,
  `id_autista` CHAR(16) NOT NULL,
  `id_passeggero` CHAR(16) NOT NULL,
  `voto` TINYINT NOT NULL,
  `commento` TEXT NULL,
  `data_feedback` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_feedback`),
  INDEX `id_autista_idx` (`id_autista` ASC) VISIBLE,
  INDEX `id_passeggero_idx` (`id_passeggero` ASC) VISIBLE,
  CONSTRAINT `fk_feedback_autista_aut`
    FOREIGN KEY (`id_autista`)
    REFERENCES `rideshare`.`autista` (`id_autista`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_feedback_autista_pax`
    FOREIGN KEY (`id_passeggero`)
    REFERENCES `rideshare`.`passeggero` (`id_passeggero`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `rideshare`.`feedback_passeggero`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `rideshare`.`feedback_passeggero` ;
CREATE TABLE IF NOT EXISTS `rideshare`.`feedback_passeggero` (
  `id_feedback` INT NOT NULL AUTO_INCREMENT,
  `id_passeggero` CHAR(16) NOT NULL,
  `id_autista` CHAR(16) NOT NULL,
  `voto` TINYINT NOT NULL,
  `commento` TEXT NULL,
  `data_feedback` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_feedback`),
  INDEX `id_passeggero_idx` (`id_passeggero` ASC) VISIBLE,
  INDEX `id_autista_idx` (`id_autista` ASC) VISIBLE,
  CONSTRAINT `fk_feedback_passeggero_pax`
    FOREIGN KEY (`id_passeggero`)
    REFERENCES `rideshare`.`passeggero` (`id_passeggero`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_feedback_passeggero_aut`
    FOREIGN KEY (`id_autista`)
    REFERENCES `rideshare`.`autista` (`id_autista`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------
DELIMITER $$
CREATE TRIGGER `pren_check_posti`
BEFORE INSERT ON `rideshare`.`prenotazione`
FOR EACH ROW
BEGIN
  IF (SELECT posti_disponibili FROM `rideshare`.`viaggio` WHERE id_viaggio = NEW.id_viaggio) <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nessun posto disponibile per questo viaggio';
  END IF;
END$$

CREATE TRIGGER `pren_after_insert`
AFTER INSERT ON `rideshare`.`prenotazione`
FOR EACH ROW
BEGIN
  IF NEW.stato = 'ACCEPTED' THEN
    UPDATE `rideshare`.`viaggio`
    SET posti_disponibili = posti_disponibili - 1
    WHERE id_viaggio = NEW.id_viaggio;
  END IF;
END$$

CREATE TRIGGER `pren_before_update`
BEFORE UPDATE ON `rideshare`.`prenotazione`
FOR EACH ROW
BEGIN
  IF OLD.stato = 'ACCEPTED' AND NEW.stato <> 'ACCEPTED' THEN
    UPDATE `rideshare`.`viaggio`
    SET posti_disponibili = posti_disponibili + 1
    WHERE id_viaggio = OLD.id_viaggio;
  END IF;
END$$
DELIMITER ;

-- -----------------------------------------------------
-- View: average rating per autista
-- -----------------------------------------------------
CREATE VIEW `rideshare`.`view_avg_rating_autista` AS
SELECT
  id_autista,
  ROUND(AVG(voto),2) AS avg_voto
FROM `rideshare`.`feedback_autista`
GROUP BY id_autista;

-- -----------------------------------------------------
-- Queries
-- -----------------------------------------------------
-- 1) Semplice: elenco viaggi ancora aperti
SELECT * 
FROM `rideshare`.`viaggio`
WHERE chiuso = FALSE;

-- 2) Intermedia: numero di prenotazioni accettate per viaggio
SELECT
  v.id_viaggio,
  v.citta_partenza,
  v.citta_destinazione,
  COUNT(p.id_prenotazione) AS num_prenotazioni_accettate
FROM `rideshare`.`viaggio` v
LEFT JOIN `rideshare`.`prenotazione` p
  ON v.id_viaggio = p.id_viaggio AND p.stato = 'ACCEPTED'
GROUP BY v.id_viaggio;

-- 3) Difficile: per ciascun autista con ≥5 viaggi e voto medio ≥4.5, calcola tot. incasso e ordina
SELECT
  sub.id_autista,
  sub.autista,
  sub.num_viaggi,
  sub.avg_voto,
  sub.totale_incasso
FROM (
  SELECT
    a.id_autista,
    CONCAT(a.nome,' ',a.cognome) AS autista,
    COUNT(DISTINCT v.id_viaggio) AS num_viaggi,
    ROUND(AVG(f.voto),2) AS avg_voto,
    SUM(v.costo) AS totale_incasso
  FROM `rideshare`.`autista` a
  JOIN `rideshare`.`viaggio` v ON a.id_autista = v.id_autista
  JOIN `rideshare`.`prenotazione` p ON v.id_viaggio = p.id_viaggio AND p.stato = 'ACCEPTED'
  LEFT JOIN `rideshare`.`feedback_autista` f ON a.id_autista = f.id_autista
  GROUP BY a.id_autista
) AS sub
WHERE sub.num_viaggi >= 5
  AND sub.avg_voto >= 4.5
ORDER BY sub.totale_incasso DESC;

-- -----------------------------------------------------
-- Stored Procedures
-- -----------------------------------------------------
DELIMITER $$
CREATE PROCEDURE `rideshare`.`getViaggiDisponibili`(
  IN p_citta_partenza VARCHAR(100),
  IN p_citta_destinazione VARCHAR(100),
  IN p_data DATE
)
BEGIN
  SELECT * FROM `rideshare`.`viaggio`
  WHERE citta_partenza = p_citta_partenza
    AND citta_destinazione = p_citta_destinazione
    AND data_partenza = p_data
    AND chiuso = FALSE;
END$$

CREATE PROCEDURE `rideshare`.`getFeedbackAutista`(
  IN p_id_autista CHAR(16)
)
BEGIN
  SELECT id_passeggero, voto, commento, data_feedback
  FROM `rideshare`.`feedback_autista`
  WHERE id_autista = p_id_autista;
END$$

CREATE PROCEDURE `rideshare`.`getFeedbackPasseggero`(
  IN p_id_passeggero CHAR(16)
)
BEGIN
  SELECT id_autista, voto, commento, data_feedback
  FROM `rideshare`.`feedback_passeggero`
  WHERE id_passeggero = p_id_passeggero;
END$$
DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
