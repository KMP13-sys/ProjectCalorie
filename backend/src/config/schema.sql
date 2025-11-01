-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: calories_app
-- ------------------------------------------------------
-- Server version	8.4.6

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activity`
--

DROP TABLE IF EXISTS `activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity` (
  `activity_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `date` date NOT NULL,
  PRIMARY KEY (`activity_id`),
  UNIQUE KEY `uk_user_date` (`user_id`,`date`),
  CONSTRAINT `activity_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity`
--

LOCK TABLES `activity` WRITE;
/*!40000 ALTER TABLE `activity` DISABLE KEYS */;
INSERT INTO `activity` VALUES (1,1,'2025-10-26'),(2,1,'2025-10-29'),(3,1,'2025-10-30'),(5,1,'2025-10-31'),(6,1,'2025-11-01'),(4,2,'2025-10-30'),(7,2,'2025-11-01');
/*!40000 ALTER TABLE `activity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activitydetail`
--

DROP TABLE IF EXISTS `activitydetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activitydetail` (
  `activity_detail_id` int NOT NULL AUTO_INCREMENT,
  `activity_id` int NOT NULL,
  `sport_id` int NOT NULL,
  `time` int NOT NULL,
  `calories_burned` decimal(8,2) DEFAULT NULL,
  PRIMARY KEY (`activity_detail_id`),
  KEY `activity_id` (`activity_id`),
  KEY `sport_id` (`sport_id`),
  CONSTRAINT `activitydetail_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`),
  CONSTRAINT `activitydetail_ibfk_2` FOREIGN KEY (`sport_id`) REFERENCES `sports` (`sport_id`),
  CONSTRAINT `chk_time` CHECK ((`time` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activitydetail`
--

LOCK TABLES `activitydetail` WRITE;
/*!40000 ALTER TABLE `activitydetail` DISABLE KEYS */;
INSERT INTO `activitydetail` VALUES (1,1,5,10,91.70),(2,2,1,10,58.30),(3,2,16,30,149.10),(4,3,16,30,149.10),(5,3,9,10,100.00),(6,4,16,20,99.40),(7,4,8,15,102.75),(8,5,16,30,149.10),(9,6,16,25,124.25),(10,6,9,10,100.00),(11,6,1,15,87.45),(12,7,7,10,150.00),(13,7,10,30,300.00),(14,6,20,5,73.50),(15,7,9,10,100.00);
/*!40000 ALTER TABLE `activitydetail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `admin_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone_number` varchar(15) DEFAULT NULL,
  `address` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login_at` datetime DEFAULT NULL,
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES (1,'admin','admin@gmail.com','$2b$10$D3aDy4XsLHRKUO3V4Dcz7O7dRSEtwc68apOI7bAtG/oBGzCJic2m6','0958593291','15/4 บางรัก กรุงเทพมหานคร','2025-10-25 15:53:35','2025-11-01 14:40:58','2025-11-01 21:40:58');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aianalysis`
--

DROP TABLE IF EXISTS `aianalysis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aianalysis` (
  `analysis_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `food_id` int DEFAULT NULL,
  `confidence_score` decimal(3,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`analysis_id`),
  KEY `user_id` (`user_id`),
  KEY `food_id` (`food_id`),
  CONSTRAINT `aianalysis_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `aianalysis_ibfk_2` FOREIGN KEY (`food_id`) REFERENCES `foods` (`food_id`),
  CONSTRAINT `chk_confidence_score` CHECK ((`confidence_score` between 0 and 1))
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aianalysis`
--

LOCK TABLES `aianalysis` WRITE;
/*!40000 ALTER TABLE `aianalysis` DISABLE KEYS */;
INSERT INTO `aianalysis` VALUES (1,1,19,0.96,'2025-10-26 10:41:12'),(2,1,57,0.96,'2025-10-26 12:33:00'),(3,1,34,0.99,'2025-10-28 11:33:56'),(4,1,6,1.00,'2025-10-28 12:09:02'),(5,1,65,0.58,'2025-10-29 09:45:47'),(6,1,35,1.00,'2025-10-29 09:59:41'),(7,1,34,1.00,'2025-10-29 11:10:16'),(8,1,31,1.00,'2025-10-30 15:08:33'),(9,1,1,0.85,'2025-10-30 15:08:56'),(10,1,97,1.00,'2025-10-30 15:09:09'),(11,1,14,1.00,'2025-10-30 15:36:12'),(12,1,65,0.81,'2025-10-31 09:22:48'),(13,1,97,1.00,'2025-10-31 09:23:08'),(14,1,6,1.00,'2025-10-31 10:29:14'),(15,1,26,1.00,'2025-10-31 19:15:19'),(16,1,47,0.62,'2025-10-31 19:15:33'),(17,1,61,0.88,'2025-10-31 19:15:48'),(18,2,97,1.00,'2025-10-31 20:54:01'),(19,2,73,1.00,'2025-10-31 20:54:22'),(20,2,2,0.85,'2025-10-31 20:54:36'),(21,2,79,1.00,'2025-10-31 20:54:50'),(22,2,74,0.99,'2025-10-31 21:52:52'),(23,1,55,0.96,'2025-11-01 03:09:08');
/*!40000 ALTER TABLE `aianalysis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dailycalories`
--

DROP TABLE IF EXISTS `dailycalories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dailycalories` (
  `daily_calorie_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `date` date NOT NULL,
  `activity_level` decimal(2,1) NOT NULL,
  `target_calories` decimal(8,2) NOT NULL,
  `consumed_calories` decimal(8,2) DEFAULT '0.00',
  `burned_calories` decimal(8,2) DEFAULT '0.00',
  `net_calories` decimal(8,2) GENERATED ALWAYS AS ((`consumed_calories` - `burned_calories`)) STORED,
  `remaining_calories` decimal(8,2) GENERATED ALWAYS AS ((`target_calories` - (`consumed_calories` - `burned_calories`))) STORED,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`daily_calorie_id`),
  UNIQUE KEY `uk_user_date` (`user_id`,`date`),
  CONSTRAINT `dailycalories_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `chk_activity_level` CHECK ((`activity_level` in (1.2,1.4,1.6,1.7,1.9))),
  CONSTRAINT `chk_burned_calories` CHECK ((`burned_calories` >= 0)),
  CONSTRAINT `chk_consumed_calories` CHECK ((`consumed_calories` >= 0)),
  CONSTRAINT `chk_target_calories` CHECK ((`target_calories` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dailycalories`
--

LOCK TABLES `dailycalories` WRITE;
/*!40000 ALTER TABLE `dailycalories` DISABLE KEYS */;
INSERT INTO `dailycalories` (`daily_calorie_id`, `user_id`, `date`, `activity_level`, `target_calories`, `consumed_calories`, `burned_calories`, `created_at`, `updated_at`) VALUES (1,1,'2025-10-26',1.2,1905.80,308.00,91.70,'2025-10-26 07:38:30','2025-10-26 13:44:46'),(2,2,'2025-10-26',1.6,2478.00,0.00,0.00,'2025-10-26 07:39:26','2025-10-26 07:39:26'),(4,1,'2025-10-27',1.6,2374.40,0.00,0.00,'2025-10-27 08:04:25','2025-10-27 08:04:25'),(5,2,'2025-10-27',1.4,2168.25,0.00,0.00,'2025-10-27 08:12:10','2025-10-27 08:12:10'),(6,1,'2025-10-28',1.4,2140.10,711.00,134.00,'2025-10-28 10:46:27','2025-11-01 02:48:29'),(7,1,'2025-10-29',1.7,2491.55,647.00,207.40,'2025-10-29 08:45:08','2025-10-29 11:26:44'),(8,2,'2025-10-29',1.4,2168.25,700.00,0.00,'2025-10-29 08:51:37','2025-11-01 02:48:08'),(9,1,'2025-10-30',1.2,1905.80,842.00,249.10,'2025-10-30 14:40:27','2025-10-30 15:36:12'),(10,2,'2025-10-30',1.6,2478.00,843.00,202.15,'2025-10-30 14:45:29','2025-11-01 02:47:26'),(11,1,'2025-10-31',1.7,2491.55,620.00,149.10,'2025-10-31 09:19:51','2025-10-31 18:45:28'),(12,2,'2025-10-31',1.2,1858.50,910.00,342.00,'2025-10-31 17:31:37','2025-11-01 02:47:52'),(25,1,'2025-11-01',1.7,2491.55,1144.00,385.20,'2025-10-31 19:12:47','2025-11-01 03:09:08'),(26,2,'2025-11-01',1.7,2632.88,983.00,550.00,'2025-10-31 20:53:51','2025-10-31 21:53:05');
/*!40000 ALTER TABLE `dailycalories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `foods`
--

DROP TABLE IF EXISTS `foods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `foods` (
  `food_id` int NOT NULL AUTO_INCREMENT,
  `food_name` varchar(100) NOT NULL,
  `protein_gram` decimal(8,2) DEFAULT '0.00',
  `fat_gram` decimal(8,2) DEFAULT '0.00',
  `carbohydrate_gram` decimal(8,2) DEFAULT '0.00',
  `calories` decimal(8,2) NOT NULL,
  `admin_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`food_id`),
  KEY `admin_id` (`admin_id`),
  CONSTRAINT `foods_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`),
  CONSTRAINT `chk_calories` CHECK ((`calories` > 0)),
  CONSTRAINT `chk_carbohydrate_gram` CHECK ((`carbohydrate_gram` >= 0)),
  CONSTRAINT `chk_fat_gram` CHECK ((`fat_gram` >= 0)),
  CONSTRAINT `chk_protein_gram` CHECK ((`protein_gram` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `foods`
--

LOCK TABLES `foods` WRITE;
/*!40000 ALTER TABLE `foods` DISABLE KEYS */;
INSERT INTO `foods` VALUES (1,'ข้าวผัดอเมริกัน',18.00,18.00,56.50,474.00,1,'2025-10-25 15:54:37','2025-11-01 14:36:42'),(2,'ข้าวหน้าไก่',17.00,9.00,64.00,449.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(3,'ปอเปี๊ยะทอด',9.00,3.50,28.00,195.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(4,'ผัดซีอิ๊ว',19.00,15.50,51.50,424.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(5,'กระเพาะปลาน้ำแดง',28.20,19.80,6.20,331.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(6,'ไส้กรอกอีสาน',16.30,29.50,12.50,397.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(7,'ลาบคั่ว',25.00,23.20,9.40,363.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(8,'ไก่ผัดเม็ดมะม่วงหิมพานต์',29.00,14.00,19.00,334.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(9,'ผัดพริกแกง',17.00,14.00,9.00,249.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(10,'ผัดพริกไทยดำ',19.00,9.00,9.00,219.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(11,'ปลานึ่งซีอิ๊ว',47.00,0.00,1.00,200.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(12,'ผัดแขนง',14.00,9.00,7.00,199.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(13,'ไข่กระทะ',19.00,24.00,4.00,349.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(14,'แกงจืด',11.00,6.00,6.00,149.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(15,'ก๋วยเตี๋ยวเรือ',11.00,7.00,34.00,249.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(16,'ไข่ตุ๋น',12.00,9.00,0.50,149.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(17,'โรตี',5.10,25.00,55.10,496.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(18,'หมูฮ้อง',10.00,20.00,16.00,299.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(19,'น้ำพริกหนุ่ม',0.00,1.00,3.00,34.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(20,'ผัดไทยห่อไข่',19.00,19.00,69.00,549.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(21,'แกงเขียวหวาน',11.60,11.40,4.80,185.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(22,'น้ำพริกอ่อง',2.40,8.80,0.00,105.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(23,'ข้าวแช่',9.50,12.50,51.50,349.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(24,'ข้าวคลุกกะปิ',5.90,7.20,25.80,208.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(25,'ปลาหมึกทอด',16.90,6.50,6.80,174.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(26,'คั่วกลิ้ง',20.70,3.60,5.30,153.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(27,'ผัดคะน้า',2.20,17.70,6.20,203.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(28,'ปลานึ่งมะนาว',32.00,2.00,1.00,164.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(29,'ต้มข่า',12.50,12.50,5.50,199.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(30,'ยำวุ้นเส้น',12.50,10.00,26.50,274.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(31,'ปลาเผา',25.00,2.00,1.00,130.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(32,'ปลาหมึกผัดน้ำดำ',20.00,10.00,8.00,224.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(33,'เกี๊ยวทอด',30.00,20.00,34.00,455.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(34,'กั้งทอดกระเทียม',26.50,15.50,5.50,314.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(35,'ผัดผักบุ้งไฟแดง',4.00,13.00,9.00,199.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(36,'เต้าหู้ทอด',27.80,24.70,0.90,353.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(37,'ยำหอย',14.00,7.00,9.00,179.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(38,'สุกี้แห้ง',17.90,11.30,38.20,327.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(39,'กุ้งทอด',20.40,11.30,10.50,241.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(40,'ปอเปี๊ยะสด',26.50,0.00,16.40,189.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(41,'ผัดพริกสด',19.00,11.00,5.00,219.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(42,'แกงฮังเล',15.70,23.00,11.20,331.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(43,'ขนมจีบ',9.50,11.00,14.00,209.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(44,'ก๋วยเตี๋ยวคั่วไก่',16.40,19.90,58.40,494.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(45,'ปูนิ่มทอดกระเทียม',24.00,19.00,4.00,349.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(46,'กะหล่ำปลีผัดน้ำปลา',2.50,9.00,6.00,139.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(47,'ข้าวหมกไก่',14.30,8.90,79.70,473.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(48,'ผัดกะปิ',47.60,22.60,0.00,417.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(49,'ไส้อั่ว',17.00,35.10,4.70,419.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(50,'ยำปลาดุกฟู',21.50,21.50,10.00,374.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(51,'หอยทอด',21.50,19.00,36.50,424.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(52,'ผัดกะเพรา',21.50,19.00,5.50,324.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(53,'ข้าวสวย',4.60,0.00,61.40,281.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(54,'หอยจ๊อ',23.30,11.00,5.30,236.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(55,'หอยลายผัดพริกเผา',18.00,12.50,8.00,244.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(56,'ข้าวขาหมู',25.50,31.50,0.00,424.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(57,'แกงคั่วหอย',15.50,19.00,8.00,274.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(58,'ข้าวต้ม',10.00,4.00,21.50,164.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(59,'ข้าวหมูแดง',24.00,12.50,5.20,299.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(60,'พะโล้',20.00,15.00,58.00,329.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(61,'คั่วพริกเกลือ',21.50,15.50,5.50,274.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(62,'ราดหน้า',21.50,15.50,51.50,424.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(63,'เต้าเจี้ยวหลน',12.50,15.50,5.50,224.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(64,'เย็นตาโฟ',7.40,7.10,26.60,215.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(65,'ปลาหมึกนึ่งมะนาว',20.00,1.50,4.50,134.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(66,'แกงป่า',15.50,10.00,8.00,199.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(67,'โจ๊ก',33.30,6.10,22.60,295.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(68,'ขนมจีนน้ำเงี้ยว',17.90,4.60,44.60,307.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(69,'ก๋วยจั๊บ',21.00,9.00,46.00,365.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(70,'แกงส้ม',8.00,15.50,10.00,239.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(71,'หอยนางรมทรงเครื่อง',8.00,1.50,4.50,89.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(72,'ขนมจีน',19.00,15.50,56.50,424.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(73,'แกงเหลือง',14.60,0.80,4.80,87.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(74,'กุ้งแช่น้ำปลา',18.00,0.50,1.50,99.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(75,'กุ้งทอดซอสมะขาม',20.10,13.00,16.00,279.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(76,'หมูกรอบ',24.00,45.50,0.00,509.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(77,'ปูผัดผงกะหรี่',20.00,15.50,10.00,299.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(78,'ไข่เจียว',14.00,12.50,0.50,214.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(79,'กุ้งอบวุ้นเส้น',19.00,6.00,24.00,259.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(80,'ผัดฉ่า',18.00,15.50,5.50,274.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(81,'หอยแครงลวก',13.70,0.00,2.60,85.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(82,'ห่อหมก',13.80,13.40,1.00,188.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(83,'ปลาหมึกผัดไข่เค็ม',20.00,15.50,5.50,274.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(84,'ผัดไทย',18.00,15.50,56.50,474.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(85,'ทอดมันกุ้ง',15.50,15.50,12.50,269.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(86,'สะเต๊ะ',35.60,15.50,9.60,346.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(87,'ข้าวมันไก่',18.50,23.60,73.40,596.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(88,'ไก่ทอด',29.00,11.00,0.80,244.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(89,'ลาบ',17.60,5.00,6.10,155.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(90,'ใบเหลียงผัดไข่',9.50,8.50,24.30,233.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(91,'ข้าวซอย',16.40,30.80,73.40,461.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(92,'เกาเหลา',18.00,8.00,3.00,164.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(93,'ทอดมันปลา',12.60,14.20,7.30,218.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(94,'ปูนึ่ง',25.50,0.50,0.00,134.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(95,'หมูย่าง',19.00,19.00,1.00,279.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(96,'ส้มตำ',1.70,0.50,5.70,41.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(97,'กุ้งเผา',19.00,0.00,1.00,89.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(98,'ข้าวผัด',19.00,17.00,64.00,499.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(99,'ต้มยำ',20.80,5.60,9.30,184.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37'),(100,'ปลาทอด',25.50,20.00,5.50,324.00,1,'2025-10-25 15:54:37','2025-10-25 15:54:37');
/*!40000 ALTER TABLE `foods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mealdetails`
--

DROP TABLE IF EXISTS `mealdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mealdetails` (
  `meal_detail_id` int NOT NULL AUTO_INCREMENT,
  `meal_id` int NOT NULL,
  `food_id` int NOT NULL,
  `meal_time` time NOT NULL,
  PRIMARY KEY (`meal_detail_id`),
  KEY `meal_id` (`meal_id`),
  KEY `food_id` (`food_id`),
  CONSTRAINT `mealdetails_ibfk_1` FOREIGN KEY (`meal_id`) REFERENCES `meals` (`meal_id`),
  CONSTRAINT `mealdetails_ibfk_2` FOREIGN KEY (`food_id`) REFERENCES `foods` (`food_id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mealdetails`
--

LOCK TABLES `mealdetails` WRITE;
/*!40000 ALTER TABLE `mealdetails` DISABLE KEYS */;
INSERT INTO `mealdetails` VALUES (1,1,19,'16:20:00'),(2,1,57,'18:20:00'),(3,3,34,'18:33:56'),(4,3,6,'19:09:03'),(5,5,65,'16:45:48'),(6,5,35,'16:59:41'),(7,5,34,'18:10:16'),(8,8,31,'22:08:33'),(9,8,1,'22:08:57'),(10,8,97,'22:09:10'),(11,8,14,'22:36:12'),(12,12,65,'16:22:48'),(13,12,97,'16:23:08'),(14,12,6,'17:29:15'),(15,15,26,'02:15:20'),(16,15,47,'02:15:33'),(17,15,61,'02:15:48'),(18,18,97,'03:54:01'),(19,18,73,'03:54:22'),(20,18,2,'03:54:37'),(21,18,79,'03:54:50'),(22,18,74,'04:52:52'),(23,15,55,'10:09:09');
/*!40000 ALTER TABLE `mealdetails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meals`
--

DROP TABLE IF EXISTS `meals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meals` (
  `meal_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `date` date NOT NULL,
  PRIMARY KEY (`meal_id`),
  UNIQUE KEY `uk_user_date` (`user_id`,`date`),
  CONSTRAINT `meals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meals`
--

LOCK TABLES `meals` WRITE;
/*!40000 ALTER TABLE `meals` DISABLE KEYS */;
INSERT INTO `meals` VALUES (1,1,'2025-10-26'),(3,1,'2025-10-28'),(5,1,'2025-10-29'),(8,1,'2025-10-30'),(12,1,'2025-10-31'),(15,1,'2025-11-01'),(18,2,'2025-11-01');
/*!40000 ALTER TABLE `meals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sports`
--

DROP TABLE IF EXISTS `sports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sports` (
  `sport_id` int NOT NULL AUTO_INCREMENT,
  `sport_name` varchar(100) NOT NULL,
  `burn_out` decimal(8,2) NOT NULL,
  `admin_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`sport_id`),
  KEY `admin_id` (`admin_id`),
  CONSTRAINT `sports_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`),
  CONSTRAINT `chk_burn_out` CHECK ((`burn_out` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sports`
--

LOCK TABLES `sports` WRITE;
/*!40000 ALTER TABLE `sports` DISABLE KEYS */;
INSERT INTO `sports` VALUES (1,'เต้น',5.83,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(2,'บาสเก็ตบอล',9.15,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(3,'มวย',11.67,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(4,'กระโดดเชือก',13.00,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(5,'ปั่นจักยาน',9.17,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(6,'ปิงปอง',4.83,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(7,'เทควันโด',15.00,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(8,'ว่ายน้ำ',6.85,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(9,'วิ่ง',10.00,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(10,'แบดมินตัน',10.00,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(11,'สเกตบอร์ด',8.00,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(12,'วอลเลย์บอล',5.72,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(13,'ฟุตบอล',10.00,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(14,'เซิร์ฟ',8.28,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(15,'ยกน้ำหนัก',3.73,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(16,'โยคะ',4.97,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(17,'แอโรบิค',6.83,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(18,'เครื่องเล่น Elliptical',11.17,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(19,'เทนนิส',8.67,1,'2025-10-25 15:54:57','2025-10-25 15:54:57'),(20,'สควอช',14.70,1,'2025-10-25 15:54:57','2025-10-25 15:54:57');
/*!40000 ALTER TABLE `sports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `image_profile` varchar(100) DEFAULT NULL,
  `phone_number` varchar(15) DEFAULT NULL,
  `age` int DEFAULT NULL,
  `gender` enum('male','female') DEFAULT NULL,
  `height` decimal(5,2) DEFAULT NULL,
  `weight` decimal(5,2) DEFAULT NULL,
  `goal` enum('lose weight','maintain weight','gain weight') DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `refresh_token` varchar(500) DEFAULT NULL,
  `refresh_token_expires_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  CONSTRAINT `chk_age` CHECK ((`age` between 13 and 120)),
  CONSTRAINT `chk_height` CHECK ((`height` between 50 and 300)),
  CONSTRAINT `chk_weight` CHECK ((`weight` between 20 and 300))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'test1','test1@gmail.com','$2b$10$nNsQX3Vo8t0HLElo6wBNTOobgI5XZgJTSbWZjyrgSjm8jSekn58i6','1761966631645-249271792.jpg','0621143476',17,'female',158.00,43.00,'gain weight','2025-10-25 15:57:30','2025-11-01 03:10:31',NULL,NULL,'2025-11-01 10:07:59'),(2,'test2','test2@gmail.com','$2b$10$nooAUjS1nDXD11VGIvgCg.HKSyksdA435rttlDSlgFbpGJxTqfMSK','1761408079477-340424917.jpg','0631873642',25,'male',179.00,55.00,'maintain weight','2025-10-25 16:00:31','2025-10-31 21:52:13',NULL,NULL,'2025-11-01 04:52:13');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'calories_app'
--

--
-- Dumping routines for database 'calories_app'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-01 23:27:11
