USE [OCPP.Core]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users] (
    [Userid] [int] IDENTITY(1,1) PRIMARY KEY, 
	[Username] [nvarchar](50),
	[Email] [nvarchar](255),
    [Password] [nvarchar](50),
    [Role] [nvarchar](50)
);
GO

CREATE TABLE [dbo].[Companies](
    [CompanyId] [int] IDENTITY(1,1) PRIMARY KEY,
    [Name] [nvarchar](50),
    [Address] [nvarchar](50),
    [Phone] [nvarchar](50),
    [AdministratorId] [int] NOT NULL
);

CREATE TABLE [dbo].[ChargePoint](
	[ChargePointId] [nvarchar](100) NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Comment] [nvarchar](200) NULL,
	[Username] [nvarchar](50) NULL,
	[Password] [nvarchar](50) NULL,
	[ClientCertThumb] [nvarchar](100) NULL,
	[CompanyId] [int] NULL,
 CONSTRAINT [PK_ChargePoint_1] PRIMARY KEY CLUSTERED 
(
	[ChargePointId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChargeTags](
	[TagId] [nvarchar](50) NOT NULL,
	[TagName] [nvarchar](200) NULL,
	[Email] [nvarchar](200) NULL,
	[ParentTagId] [nvarchar](50) NULL,
	[ExpiryDate] [datetime2](7) NULL,
	[Blocked] [bit] NULL,
	[ChargingTime] [int] NULL,
	[CompanyId] [int] NULL,
 CONSTRAINT [PK_ChargeKeys] PRIMARY KEY CLUSTERED 
(
	[TagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MessageLog](
	[LogId] [int] IDENTITY(1,1) NOT NULL,
	[LogTime] [datetime2](7) NOT NULL,
	[ChargePointId] [nvarchar](100) NOT NULL,
	[ConnectorId] [int] NULL,
	[Message] [nvarchar](100) NOT NULL,
	[Result] [nvarchar](max) NULL,
	[ErrorCode] [nvarchar](100) NULL,
 CONSTRAINT [PK_MessageLog] PRIMARY KEY CLUSTERED 
(
	[LogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transactions](
	[TransactionId] [int] IDENTITY(1,1) NOT NULL,
	[Uid] [nvarchar](50) NULL,
	[ChargePointId] [nvarchar](100) NOT NULL,
	[ConnectorId] [int] NOT NULL,
	[StartTagId] [nvarchar](50) NULL,
	[StartTime] [datetime2](7) NOT NULL,
	[MeterStart] [float] NOT NULL,
	[StartResult] [nvarchar](100) NULL,
	[StopTagId] [nvarchar](50) NULL,
	[StopTime] [datetime2](7) NULL,
	[MeterStop] [float] NULL,
	[StopReason] [nvarchar](100) NULL,
	[TimeConnect] [int] NULL,
 CONSTRAINT [PK_Transactions] PRIMARY KEY CLUSTERED 
(
	[TransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConnectorStatus](
	[ChargePointId] [nvarchar](100) NOT NULL,
	[ConnectorId] [int] NOT NULL,
	[ConnectorName] [nvarchar](100) NULL,
	[LastStatus] [nvarchar](100) NULL,
	[LastStatusTime] [datetime2](7) NULL,
	[LastMeter] [float] NULL,
	[LastMeterTime] [datetime2](7) NULL,
	[CompanyId] [int] NULL,
 CONSTRAINT [PK_ConnectorStatus] PRIMARY KEY CLUSTERED 
(
	[ChargePointId] ASC,
	[ConnectorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ConnectorStatusView]
AS
SELECT cs.ChargePointId, cs.ConnectorId, cs.ConnectorName, cs.LastStatus, cs.LastStatusTime, cs.LastMeter, cs.LastMeterTime, t.TransactionId, t.StartTagId, t.StartTime, t.MeterStart, t.StartResult, t.StopTagId, t.StopTime, t.MeterStop, 
                  t.StopReason, t.TimeConnect 
FROM     dbo.ConnectorStatus AS cs LEFT OUTER JOIN
                  dbo.Transactions AS t ON t.ChargePointId = cs.ChargePointId AND t.ConnectorId = cs.ConnectorId
WHERE  (t.TransactionId IS NULL) OR
                  (t.TransactionId IN
                      (SELECT MAX(TransactionId) AS Expr1
                       FROM      dbo.Transactions
                       GROUP BY ChargePointId, ConnectorId))
GO



SET ANSI_PADDING ON
GO

CREATE UNIQUE NONCLUSTERED INDEX [ChargePoint_Identifier] ON [dbo].[ChargePoint]
(
	[ChargePointId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_MessageLog_ChargePointId] ON [dbo].[MessageLog]
(
	[LogTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Transactions]  WITH CHECK ADD  CONSTRAINT [FK_Transactions_ChargePoint] FOREIGN KEY([ChargePointId])
REFERENCES [dbo].[ChargePoint] ([ChargePointId])
GO
ALTER TABLE [dbo].[Transactions] CHECK CONSTRAINT [FK_Transactions_ChargePoint]
GO
ALTER TABLE [dbo].[Transactions]  WITH CHECK ADD  CONSTRAINT [FK_Transactions_Transactions] FOREIGN KEY([TransactionId])
REFERENCES [dbo].[Transactions] ([TransactionId])
GO
ALTER TABLE [dbo].[Transactions] CHECK CONSTRAINT [FK_Transactions_Transactions]
GO
USE [master]
GO
ALTER DATABASE [OCPP.Core] SET  READ_WRITE 
GO
ALTER TABLE [dbo].[ChargeTags] ADD CONSTRAINT [FK_ChargeTags_Companies] FOREIGN KEY([CompanyId])
REFERENCES [dbo].[Companies] ([CompanyId]) ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Transactions] DROP CONSTRAINT [FK_Transactions_ChargePoint]
GO

ALTER TABLE [dbo].[Transactions] ADD CONSTRAINT [FK_Transactions_ChargePoint] FOREIGN KEY([ChargePointId])
REFERENCES [dbo].[ChargePoint] ([ChargePointId]) ON DELETE CASCADE
GO


