CREATE DATABASE  IF NOT EXISTS `gw_calamp_development` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `gw_calamp_development`;
-- MySQL dump 10.13  Distrib 5.5.37-35.0, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: gw_calamp_development
-- ------------------------------------------------------
-- Server version	5.5.37-35.0-55

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `devices`
--

DROP TABLE IF EXISTS `devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `devices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `imei` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ip_address` varchar(15) COLLATE utf8_unicode_ci DEFAULT NULL,
  `port` mediumint(9) DEFAULT NULL,
  `script_version` smallint(6) DEFAULT NULL,
  `config_version` smallint(6) DEFAULT NULL,
  `vehicle_class` smallint(6) DEFAULT NULL,
  `unit_status` smallint(6) DEFAULT NULL,
  `app_number` smallint(6) DEFAULT NULL,
  `app_version` varchar(5) COLLATE utf8_unicode_ci DEFAULT NULL,
  `modem_selection` smallint(6) DEFAULT NULL,
  `mobile_id_type` smallint(6) DEFAULT NULL,
  `query_identifier` int(11) DEFAULT NULL,
  `esn` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `imsi` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `msisdn` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `iccid` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `udp_forward` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_on_imei_uniq` (`imei`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `forwarded_devices`
--

DROP TABLE IF EXISTS `forwarded_devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forwarded_devices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `gw_address` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gw_type` varchar(15) COLLATE utf8_unicode_ci DEFAULT NULL,
  `imei` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inbound`
--

DROP TABLE IF EXISTS `inbound`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inbound` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `imei` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_id` int(11) DEFAULT NULL,
  `message` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `processed` tinyint(4) DEFAULT '0',
  `timestamp` datetime NOT NULL DEFAULT '2016-03-08 13:57:21',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `update_time` datetime DEFAULT NULL,
  `fix_time` datetime DEFAULT NULL,
  `received_at` datetime DEFAULT NULL,
  `msg_type` tinyint(4) DEFAULT NULL,
  `lat` decimal(15,10) DEFAULT NULL,
  `lng` decimal(15,10) DEFAULT NULL,
  `device_id` int(11) DEFAULT NULL,
  `speed` float DEFAULT NULL,
  `direction` float DEFAULT NULL,
  `altitude` float DEFAULT NULL,
  `satellites` int(11) DEFAULT NULL,
  `fix_status` int(11) DEFAULT NULL,
  `event_code` smallint(6) DEFAULT NULL,
  `event_index` smallint(6) DEFAULT NULL,
  `accumulator_count` tinyint(4) DEFAULT NULL,
  `accumulator_0` bigint(20) DEFAULT NULL,
  `accumulator_1` bigint(20) DEFAULT NULL,
  `accumulator_2` bigint(20) DEFAULT NULL,
  `accumulator_3` bigint(20) DEFAULT NULL,
  `accumulator_4` bigint(20) DEFAULT NULL,
  `accumulator_5` bigint(20) DEFAULT NULL,
  `accumulator_6` bigint(20) DEFAULT NULL,
  `accumulator_7` bigint(20) DEFAULT NULL,
  `accumulator_8` bigint(20) DEFAULT NULL,
  `accumulator_9` bigint(20) DEFAULT NULL,
  `accumulator_10` bigint(20) DEFAULT NULL,
  `accumulator_11` bigint(20) DEFAULT NULL,
  `accumulator_12` bigint(20) DEFAULT NULL,
  `accumulator_13` bigint(20) DEFAULT NULL,
  `accumulator_14` bigint(20) DEFAULT NULL,
  `accumulator_15` bigint(20) DEFAULT NULL,
  `accumulator_16` bigint(20) DEFAULT NULL,
  `accumulator_17` bigint(20) DEFAULT NULL,
  `accumulator_18` bigint(20) DEFAULT NULL,
  `accumulator_19` bigint(20) DEFAULT NULL,
  `accumulator_20` bigint(20) DEFAULT NULL,
  `accumulator_21` bigint(20) DEFAULT NULL,
  `accumulator_22` bigint(20) DEFAULT NULL,
  `accumulator_23` bigint(20) DEFAULT NULL,
  `accumulator_24` bigint(20) DEFAULT NULL,
  `accumulator_25` bigint(20) DEFAULT NULL,
  `accumulator_26` bigint(20) DEFAULT NULL,
  `accumulator_27` bigint(20) DEFAULT NULL,
  `accumulator_28` bigint(20) DEFAULT NULL,
  `accumulator_29` bigint(20) DEFAULT NULL,
  `accumulator_30` bigint(20) DEFAULT NULL,
  `accumulator_31` bigint(20) DEFAULT NULL,
  `hdop` float DEFAULT NULL,
  `comm_state` tinyint(4) DEFAULT NULL,
  `rssi` smallint(6) DEFAULT NULL,
  `netwrk_id` smallint(6) DEFAULT NULL,
  `inputs` smallint(6) DEFAULT NULL,
  `unit_status` tinyint(4) DEFAULT NULL,
  `seq_num` int(11) DEFAULT NULL,
  `msg_route` tinyint(4) DEFAULT NULL,
  `msg_id` tinyint(4) DEFAULT NULL,
  `app_msg_type` smallint(6) DEFAULT NULL,
  `user_msg` blob,
  `app_msg` blob,
  `mobile_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_data` blob,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `outbound`
--

DROP TABLE IF EXISTS `outbound`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `outbound` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `device_id` int(11) DEFAULT NULL,
  `imei` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `command` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `response` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(100) COLLATE utf8_unicode_ci DEFAULT 'Processing',
  `start_date_time` datetime NOT NULL DEFAULT '2016-03-08 13:57:21',
  `end_date_time` datetime DEFAULT NULL,
  `transaction_id` varchar(25) COLLATE utf8_unicode_ci DEFAULT NULL,
  `response_message_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_outbound_on_device_id` (`device_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER trig_outbound_after_insert
      AFTER INSERT
      ON outbound
      FOR EACH ROW
    BEGIN
      DECLARE dbName varchar(30);
      DECLARE device_imei varchar(30);
      DECLARE device_esn varchar(30);
      DECLARE device_imsi varchar(30);
      DECLARE device_iccid varchar(30);
      DECLARE device_msisdn varchar(30);
      DECLARE smsxDeviceRecordId int(11);

      SET dbName=DATABASE();
      SELECT imei,esn,imsi,iccid,msisdn INTO device_imei,device_esn,device_imsi,device_iccid,device_msisdn FROM devices WHERE id=NEW.device_id LIMIT 1;
      SELECT id INTO smsxDeviceRecordId FROM smsx.devices WHERE imei=device_imei ORDER BY TIMESTAMP DESC LIMIT 1;

      IF smsxDeviceRecordId is NULL THEN
        INSERT INTO smsx.devices (imei, gateway, esn, imsi, iccid, msisdn) VALUES (device_imei, dbName, device_esn, device_imsi, device_iccid, device_msisdn);
        SET smsxDeviceRecordId=LAST_INSERT_ID();
      ELSE
        UPDATE smsx.devices SET gateway=dbName where id=smsxDeviceRecordId;
      END IF;

      insert into smsx.outbound(device_id, gateway_outbound_id, command, start_date_time, status) values (smsxDeviceRecordId, NEW.id, NEW.command, NEW.start_date_time, NEW.status);
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER trig_outbound_after_update
      AFTER UPDATE
      ON outbound
      FOR EACH ROW
    BEGIN
      IF NEW.status='Processing' THEN
        UPDATE smsx.outbound SET status=NEW.status, end_date_time=NEW.end_date_time WHERE gateway_outbound_id=NEW.id;
      END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `udp_send`
--

DROP TABLE IF EXISTS `udp_send`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `udp_send` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `submit_time` datetime DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `message` varchar(2000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `imei` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `status` int(11) DEFAULT '0',
  `delivered` tinyint(1) DEFAULT NULL,
  `hold` tinyint(1) DEFAULT '1',
  `message_type` int(11) DEFAULT NULL,
  `app_msg_type` int(11) DEFAULT NULL,
  `user_msg_id` int(11) DEFAULT NULL,
  `user_msg_route` int(11) DEFAULT NULL,
  `ttl` int(11) DEFAULT '300',
  `retries` int(11) DEFAULT '3',
  `seq_num` int(11) DEFAULT NULL,
  `retry_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'gw_calamp_development'
--

--
-- Dumping routines for database 'gw_calamp_development'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-03-08 10:31:13
