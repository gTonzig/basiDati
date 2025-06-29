-- -----------------------------------------------------
-- Schema rideshare
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `rideshare`;
CREATE SCHEMA `rideshare` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `rideshare`;

-- -----------------------------------------------------
-- 1) Automobili (una per autista, con posti disponibili)
-- -----------------------------------------------------
DROP TABLE IF EXISTS `automobile`;
CREATE TABLE `automobile` (
  `n_telaio`    CHAR(17)    NOT NULL,
  `targa`       VARCHAR(10) NOT NULL,
  `modello`     VARCHAR(100) NOT NULL,
  `cilindrata`  INT         NOT NULL,
  `n_posti`     TINYINT     NOT NULL,
  PRIMARY KEY (`n_telaio`),
  UNIQUE KEY `uniq_targa` (`targa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- 2) Autisti
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autista`;
CREATE TABLE `autista` (
  `id_autista`        CHAR(16)      NOT NULL,
  `nome`              VARCHAR(45)   NOT NULL,
  `cognome`           VARCHAR(45)   NOT NULL,
  `telefono`          VARCHAR(20)   NOT NULL,
  `email`             VARCHAR(100)  NOT NULL,
  `fotografia`        BLOB          NULL,
  `num_patente`       VARCHAR(20)   NOT NULL,
  `scadenza_patente`  DATE          NOT NULL,
  `n_telaio`          CHAR(17)      NOT NULL,
  PRIMARY KEY (`id_autista`),
  UNIQUE KEY `uniq_email_aut` (`email`),
  INDEX `idx_autista_auto` (`n_telaio`),
  CONSTRAINT `fk_autista_auto`
    FOREIGN KEY (`n_telaio`)
    REFERENCES `automobile` (`n_telaio`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- 3) Passeggeri
-- -----------------------------------------------------
DROP TABLE IF EXISTS `passeggero`;
CREATE TABLE `passeggero` (
  `id_passeggero`    CHAR(16)     NOT NULL,
  `nome`             VARCHAR(45)  NOT NULL,
  `cognome`          VARCHAR(45)  NOT NULL,
  `documento`        VARCHAR(20)  NOT NULL,
  `telefono`         VARCHAR(20)  NOT NULL,
  `email`            VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_passeggero`),
  UNIQUE KEY `uniq_docu_pax` (`documento`),
  UNIQUE KEY `uniq_email_pax` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- 4) Viaggi
--    - ogni viaggio creato dall'autista
--    - disponibilità apertà/chiusa
--    - indicazione bagaglio e animali
-- -----------------------------------------------------
DROP TABLE IF EXISTS `viaggio`;
CREATE TABLE `viaggio` (
  `id_viaggio`           INT           NOT NULL AUTO_INCREMENT,
  `id_autista`           CHAR(16)      NOT NULL,
  `citta_partenza`       VARCHAR(100)  NOT NULL,
  `citta_destinazione`   VARCHAR(100)  NOT NULL,
  `data_partenza`        DATE          NOT NULL,
  `orario_partenza`      TIME          NOT NULL,
  `costo`                DECIMAL(8,2)  NOT NULL,
  `tempo_stimato`        TIME          NOT NULL,
  `posti_disponibili`    TINYINT       NOT NULL,
  `chiuso`               BOOLEAN       NOT NULL DEFAULT FALSE,
  `bagaglio_ok`          BOOLEAN       NOT NULL DEFAULT TRUE,
  `animali_ok`           BOOLEAN       NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`id_viaggio`),
  INDEX `idx_viaggio_aut` (`id_autista`),
  CONSTRAINT `fk_viaggio_aut`
    FOREIGN KEY (`id_autista`)
    REFERENCES `autista` (`id_autista`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- 5) Soste (opzionali lungo il percorso)
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sosta`;
CREATE TABLE `sosta` (
  `id_viaggio`     INT          NOT NULL,
  `ordine`         TINYINT      NOT NULL,
  `localita`       VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_viaggio`,`ordine`),
  INDEX `idx_sosta_viaggio` (`id_viaggio`),
  CONSTRAINT `fk_sosta_viaggio`
    FOREIGN KEY (`id_viaggio`)
    REFERENCES `viaggio` (`id_viaggio`)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- 6) Prenotazioni
--    - stato: PENDING, ACCEPTED, REJECTED
--    - email di notifica gestite a livello applicativo
-- -----------------------------------------------------
DROP TABLE IF EXISTS `prenotazione`;
CREATE TABLE `prenotazione` (
  `id_prenotazione`   INT             NOT NULL AUTO_INCREMENT,
  `id_viaggio`        INT             NOT NULL,
  `id_passeggero`     CHAR(16)        NOT NULL,
  `data_richiesta`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `stato`             ENUM('PENDING','ACCEPTED','REJECTED') NOT NULL DEFAULT 'PENDING',
  PRIMARY KEY (`id_prenotazione`),
  UNIQUE KEY `uniq_viaggio_pax` (`id_viaggio`,`id_passeggero`),
  INDEX `idx_pren_viaggio` (`id_viaggio`),
  INDEX `idx_pren_pax` (`id_passeggero`),
  CONSTRAINT `fk_pren_viaggio`
    FOREIGN KEY (`id_viaggio`)
    REFERENCES `viaggio` (`id_viaggio`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT `fk_pren_passeggero`
    FOREIGN KEY (`id_passeggero`)
    REFERENCES `passeggero` (`id_passeggero`)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- 7) Feedback sull’autista (inserito dal passeggero)
-- -----------------------------------------------------
DROP TABLE IF EXISTS `feedback_autista`;
CREATE TABLE `feedback_autista` (
  `id_feedback`     INT           NOT NULL AUTO_INCREMENT,
  `id_autista`      CHAR(16)      NOT NULL,
  `id_passeggero`   CHAR(16)      NOT NULL,
  `voto`            TINYINT       NOT NULL CHECK(voto BETWEEN 1 AND 5),
  `commento`        TEXT          NULL,
  `data_feedback`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_feedback`),
  INDEX `idx_fba_aut` (`id_autista`),
  INDEX `idx_fba_pax` (`id_passeggero`),
  CONSTRAINT `fk_fba_aut`
    FOREIGN KEY (`id_autista`)
    REFERENCES `autista` (`id_autista`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT `fk_fba_passeggero`
    FOREIGN KEY (`id_passeggero`)
    REFERENCES `passeggero` (`id_passeggero`)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- 8) Feedback sul passeggero (inserito dall’autista)
-- -----------------------------------------------------
DROP TABLE IF EXISTS `feedback_passeggero`;
CREATE TABLE `feedback_passeggero` (
  `id_feedback`     INT           NOT NULL AUTO_INCREMENT,
  `id_passeggero`   CHAR(16)      NOT NULL,
  `id_autista`      CHAR(16)      NOT NULL,
  `voto`            TINYINT       NOT NULL CHECK(voto BETWEEN 1 AND 5),
  `commento`        TEXT          NULL,
  `data_feedback`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_feedback`),
  INDEX `idx_fbp_pax` (`id_passeggero`),
  INDEX `idx_fbp_aut` (`id_autista`),
  CONSTRAINT `fk_fbp_passeggero`
    FOREIGN KEY (`id_passeggero`)
    REFERENCES `passeggero` (`id_passeggero`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT `fk_fbp_autista`
    FOREIGN KEY (`id_autista`)
    REFERENCES `autista` (`id_autista`)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- 9) Indici e pulizia finale
-- -----------------------------------------------------
-- (Qui puoi aggiungere ulteriori indici su colonne molto filtrate o calcoli di view/materialized view)

