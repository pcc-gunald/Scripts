
UPDATE A
SET client_id=B.dst_id
FROM [pcc_staging_db009215].dbo.[admin_consent] A
INNER JOIN 
(
SELECT * FROM EICase00921548clients UNION
SELECT * FROM EICase00921553clients UNION
SELECT * FROM EICase00921572clients UNION
SELECT * FROM EICase00921587clients UNION
SELECT * FROM EICase00921588clients 
)B ON B.src_id=A.[client_id]

