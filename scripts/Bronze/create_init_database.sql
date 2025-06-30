/*

================================================================

Create Dabase and Schemas

================================================================

Script Purpose:

This Script creates a new database named 'DataWarehouse' It then sets up three schemas within database: Bronze, Silver and Gold


*/



USE master;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA Bronze;
GO

CREATE SCHEMA Silver;
GO

CREATE SCHEMA Gold;
GO

