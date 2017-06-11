WITH create_tx AS (
SELECT [Data_Recipient]
FROM ETH001_BLK_DATA.input.Ethereum_Transactions
WHERE [Data_TxType] = 'create'
)

select *
FROM ETH001_BLK_DATA.input.Ethereum_Transactions tx
            LEFT JOIN
              create_tx tx1
            ON tx.[Data_Sender] = tx1.[Data_Recipient]
            LEFT JOIN
              create_tx tx2
            ON tx.[Data_Recipient] = tx2.[Data_Recipient]
            WHERE COALESCE(tx1.[Data_Recipient],tx2.[Data_Recipient]) IS NOT NULL

ALTER TABLE analysis.Smart_Contract_Transactions
ADD [Contract_Address] VARCHAR(66)
