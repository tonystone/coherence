-- phpMyAdmin SQL Dump
-- version 3.5.2.2
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Sep 12, 2014 at 12:37 PM
-- Server version: 5.5.38
-- PHP Version: 5.4.24

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `test_hr_schema`
--

-- --------------------------------------------------------

--
-- Table structure for table `Countries`
--

CREATE TABLE IF NOT EXISTS `Countries` (
  `CountryCode` char(2) NOT NULL COMMENT 'Primary key of countries table.',
  `CountryName` varchar(40) DEFAULT NULL COMMENT 'Country Name',
  `RegionID` int(11) NOT NULL COMMENT 'Region ID for the country. Foreign key to region_id column in the departments table.',
  PRIMARY KEY (`CountryCode`),
  KEY `RegionID` (`RegionID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `Departments`
--

CREATE TABLE IF NOT EXISTS `Departments` (
  `DepartmentID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key column of departments table.',
  `DepartmentName` varchar(30) NOT NULL COMMENT 'A not null column that shows name of a department. Administration, Marketing, Purchasing, Human Resources, Shipping, IT, Executive, Public Relations, Sales, Finance, and Accounting. ',
  `ManagerID` int(11) NOT NULL COMMENT 'Manager_id of a department. Foreign key to employee_id column of employees table. The manager_id column of the employee table references this column.',
  `LocationID` int(11) NOT NULL COMMENT 'Location id where a department is located. Foreign key to location_id column of locations table.',
  PRIMARY KEY (`DepartmentID`),
  KEY `ManagerID` (`ManagerID`),
  KEY `LocationID` (`LocationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `Employees`
--

CREATE TABLE IF NOT EXISTS `Employees` (
  `EmployeeID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key of employees table.',
  `FirstName` varchar(20) DEFAULT NULL COMMENT 'First name of the employee. A not null column.',
  `LastName` varchar(25) NOT NULL COMMENT 'Last name of the employee. A not null column.',
  `Email` varchar(50) NOT NULL COMMENT 'Email id of the employee',
  `PhoneNumber` varchar(20) DEFAULT NULL COMMENT 'Phone number of the employee; includes country code and area code',
  `HireDate` date NOT NULL COMMENT 'Date when the employee started on this job. A not null column.',
  `JobID` int(11) NOT NULL COMMENT 'Current job of the employee; foreign key to job_id column of the jobs table. A not null column.',
  `Salary` decimal(8,2) DEFAULT NULL COMMENT 'Monthly salary of the employee. Must be greater than zero (enforced by constraint emp_salary_min)',
  `CommissionPercentage` decimal(2,2) DEFAULT NULL COMMENT 'Commission percentage of the employee; Only employees in sales department elgible for commission percentage',
  `ManagerID` int(11) DEFAULT NULL COMMENT 'Manager id of the employee; has same domain as manager_id in departments table. Foreign key to employee_id column of employees table. (useful for reflexive joins and CONNECT BY query)',
  `DepartmentID` int(11) DEFAULT NULL COMMENT 'Department id where employee works; foreign key to department_id column of the departments table',
  PRIMARY KEY (`EmployeeID`),
  UNIQUE KEY `Email` (`Email`),
  KEY `FirstName` (`FirstName`,`LastName`),
  KEY `JobID` (`JobID`),
  KEY `ManagerID` (`ManagerID`),
  KEY `DepartmentID` (`DepartmentID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `JobHistory`
--

CREATE TABLE IF NOT EXISTS `JobHistory` (
  `EmployeeID` int(11) NOT NULL COMMENT 'A not null column in the complex primary key employee_id+start_date. Foreign key to employee_id column of the employee table''',
  `StartDate` date NOT NULL COMMENT 'A not null column in the complex primary key employee_id+start_date. Must be less than the end_date of the job_history table. (enforced by constraint jhist_date_interval)',
  `EndDate` date NOT NULL COMMENT 'Last day of the employee in this job role. A not null column. Must be greater than the start_date of the job_history table. (enforced by constraint jhist_date_interval)',
  `JobID` int(11) NOT NULL COMMENT 'Job role in which the employee worked in the past; foreign key to job_id column in the jobs table. A not null column.',
  `DepartmentID` int(11) NOT NULL DEFAULT '0' COMMENT 'Department id in which the employee worked in the past; foreign key to deparment_id column in the departments table',
  PRIMARY KEY (`EmployeeID`,`StartDate`),
  KEY `JobID` (`JobID`),
  KEY `DepartmentID` (`DepartmentID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `Jobs`
--

CREATE TABLE IF NOT EXISTS `Jobs` (
  `JobID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key of jobs table.',
  `JobTitle` varchar(35) NOT NULL COMMENT 'A not null column that shows job title, e.g. AD_VP, FI_ACCOUNTANT',
  `MinSalary` float DEFAULT NULL COMMENT 'Minimum salary for a job title.',
  `MaxSalary` float DEFAULT NULL COMMENT 'Maximum salary for a job title',
  PRIMARY KEY (`JobID`),
  UNIQUE KEY `JobID` (`JobID`),
  KEY `JobID_2` (`JobID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `Locations`
--

CREATE TABLE IF NOT EXISTS `Locations` (
  `LocationID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key of locations table',
  `StreetAddress` varchar(40) DEFAULT NULL COMMENT 'Street address of an office, warehouse, or production site of a company. Contains building number and street name',
  `PostalCode` varchar(12) DEFAULT NULL COMMENT 'Postal code of the location of an office, warehouse, or production site of a company. ',
  `City` varchar(30) NOT NULL COMMENT 'A not null column that shows city where an office, warehouse, or production site of a company is located. ',
  `StateProvince` varchar(25) NOT NULL COMMENT 'State or Province where an office, warehouse, or production site of a company is located.',
  `CountryCode` char(2) NOT NULL COMMENT 'Country where an office, warehouse, or production site of a company is located. Foreign key to country_id column of the countries table.',
  PRIMARY KEY (`LocationID`),
  UNIQUE KEY `LocationID` (`LocationID`),
  KEY `CountryCode` (`CountryCode`),
  KEY `LocationID_2` (`LocationID`),
  KEY `StateProvince` (`StateProvince`),
  KEY `City` (`City`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Table structure for table `Regions`
--

CREATE TABLE IF NOT EXISTS `Regions` (
  `RegionID` int(11) NOT NULL AUTO_INCREMENT,
  `RegionName` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`RegionID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=8 ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Countries`
--
ALTER TABLE `Countries`
ADD CONSTRAINT `countries_ibfk_1` FOREIGN KEY (`RegionID`) REFERENCES `Regions` (`RegionID`);

--
-- Constraints for table `Departments`
--
ALTER TABLE `Departments`
ADD CONSTRAINT `departments_ibfk_1` FOREIGN KEY (`ManagerID`) REFERENCES `Employees` (`EmployeeID`),
ADD CONSTRAINT `departments_ibfk_2` FOREIGN KEY (`LocationID`) REFERENCES `Locations` (`LocationID`);

--
-- Constraints for table `Employees`
--
ALTER TABLE `Employees`
ADD CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`JobID`) REFERENCES `Jobs` (`JobID`),
ADD CONSTRAINT `employees_ibfk_2` FOREIGN KEY (`ManagerID`) REFERENCES `Employees` (`EmployeeID`),
ADD CONSTRAINT `employees_ibfk_3` FOREIGN KEY (`DepartmentID`) REFERENCES `Departments` (`DepartmentID`);

--
-- Constraints for table `JobHistory`
--
ALTER TABLE `JobHistory`
ADD CONSTRAINT `jobhistory_ibfk_1` FOREIGN KEY (`JobID`) REFERENCES `Jobs` (`JobID`),
ADD CONSTRAINT `jobhistory_ibfk_2` FOREIGN KEY (`DepartmentID`) REFERENCES `Departments` (`DepartmentID`);

--
-- Constraints for table `Locations`
--
ALTER TABLE `Locations`
ADD CONSTRAINT `locations_ibfk_1` FOREIGN KEY (`CountryCode`) REFERENCES `Countries` (`CountryCode`);
