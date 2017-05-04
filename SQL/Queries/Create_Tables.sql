/*
Name:			Create_Tables
Description:	Create tables for input data

Date:			03-05-2017
*/
CREATE SCHEMA input;
GO

IF OBJECT_ID('input.Ethereum_Blocks', 'U') IS NOT NULL DROP TABLE input.Ethereum_Blocks
GO
CREATE TABLE input.Ethereum_Blocks(
	[status]			NVARCHAR(1) NULL,
	[data#number]		NVARCHAR(6) NULL,
	[data#hash]			NVARCHAR(66) NULL,
	[data#parentHash]	NVARCHAR(66) NULL,
	[data#uncleHash]	NVARCHAR(66) NULL,
	[data#coinbase]		NVARCHAR(42) NULL,
	[data#root]			NVARCHAR(66) NULL,
	[data#txHash]		NVARCHAR(66) NULL,
	[data#difficulty]	NVARCHAR(20) NULL,
	[data#gasLimit]		NVARCHAR(20) NULL,
	[data#gasUsed]		NVARCHAR(20) NULL,
	[data#time]			NVARCHAR(24) NULL,
	[data#extra]		NVARCHAR(128) NULL,
	[data#mixDigest]	NVARCHAR(66) NULL,
	[data#nonce]		NVARCHAR(18) NULL,
	[data#tx_count]		NVARCHAR(6) NULL,
	[data#uncle_count]	NVARCHAR(1) NULL,
	[data#size]			NVARCHAR(20) NULL,
	[data#blockTime]	NVARCHAR(6) NULL,
	[data#reward]		NVARCHAR(20) NULL
)
GO


