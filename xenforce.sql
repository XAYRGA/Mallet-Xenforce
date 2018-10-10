-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.9-log - MySQL Community Server (GPL)
-- Server OS:                    Win64
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping database structure for xenforce
CREATE DATABASE IF NOT EXISTS `xenforce` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `xenforce`;


-- Dumping structure for table xenforce.xen_activations
CREATE TABLE IF NOT EXISTS `xen_activations` (
  `index` int(11) NOT NULL AUTO_INCREMENT,
  `activation_id` tinytext,
  `activated` tinyint(4) DEFAULT NULL,
  `forwho` bigint(20) DEFAULT NULL,
  `group` bigint(20) DEFAULT NULL,
  `whencreated` bigint(20) DEFAULT NULL,
  `activation_checked` tinyint(4) DEFAULT '0',
  `username` text,
  PRIMARY KEY (`index`),
  UNIQUE KEY `activation_id` (`activation_id`(32))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.


-- Dumping structure for table xenforce.xen_drops
CREATE TABLE IF NOT EXISTS `xen_drops` (
  `occurenceid` int(11) NOT NULL AUTO_INCREMENT,
  `type` enum('UTIMEOUT','OTHER','KICK') DEFAULT NULL,
  `time` bigint(20) DEFAULT NULL,
  `idr` bigint(20) DEFAULT NULL,
  `affected` text,
  `desc` text,
  PRIMARY KEY (`occurenceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.


-- Dumping structure for table xenforce.xen_log
CREATE TABLE IF NOT EXISTS `xen_log` (
  `occurenceid` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) DEFAULT NULL,
  `time` bigint(20) DEFAULT NULL,
  `affected` text,
  `desc` text,
  PRIMARY KEY (`occurenceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
