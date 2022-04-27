/* EI Replace Variable Guide

59277				12345
1264					123

SAVA			SRC
PGHC			DST

[sqluspaw29cli01.pccprod.local].us_sava_multi				[pccsql-use2-prod-w21-cli0007.f352397924df.database.windows.net].us_src_multi
[sqluspaw29cli01.pccprod.local]		pccsql-use2-prod-w21-cli0007.f352397924df.database.windows.net
us_sava_multi		us_src_multi
494950444				1000001

[pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi				[pccsql-use2-prod-w21-cli0007.f352397924df.database.windows.net].us_dst_multi
[pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net]		pccsql-use2-prod-w21-cli0007.f352397924df.database.windows.net
us_pghc_multi		us_dst_multi
504954271				2000002		
	
---save

1991232	Database Maintainance Job Case#
1991233		Photos and Docs HOPS Case#

183		SRC fac_id for first facility
173		DST fac_id for first facility
59277183		Case# for the first facility

183				1,2,3,4,5
173				11,12,13,14,15	



---save

[vmuspassvtscon3.pccprod.local].test_usei3sava1		[pccsql-use2-prod-w21-cli0007.f352397924df.database.windows.net].test_usei100
[vmuspassvtscon3.pccprod.local]				Source Server e.g. pccsql-use2-prod-w21-cli0007.f352397924df.database.windows.net
test_usei3sava1				test_usei100
usei3sava1			usei100

[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214		[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei200	
[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]				Destination Server e.g. pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net
test_usei1214				test_usei200		
usei1214			usei200	

[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]		pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net
test_usei1214				test_usei300

ashwin.chaudhari@pointclickcare.com				your PCC email address - Rushabh.Shah@pointclickcare.com
TX				NY
R_CURRESDATE			2021-01-01 00:00:00.000

---save

March 01, 2022					Dec 10, 2020
Tuesday					Wednesday
12pm to 4am					1am to 9am
2022-03-01 12:00:00		2021-01-01 01:00:00
2022-03-02 04:00:00			2021-01-01 09:00:00
15		15
Pasadena Post Acute 			Atherton Gardens, Parkinson Avenue

---save

--Only replace for number of facilities to be copied

183				1
173				101
59277183			12345678901		

R_SRCFACID2				2
R_DSTFACID2				102
R_CASENUMBER2			12345678902

R_SRCFACID3				3
R_DSTFACID3				103
R_CASENUMBER3			12345678903

R_SRCFACID4				4
R_DSTFACID4				104
R_CASENUMBER4			12345678904

R_SRCFACID5				5
R_DSTFACID5				105
R_CASENUMBER5			12345678905

R_SRCFACID6				6
R_DSTFACID6				106
R_CASENUMBER6			12345678906

R_SRCFACID7				7
R_DSTFACID7				107
R_CASENUMBER7			12345678907

R_SRCFACID8				8
R_DSTFACID8				108
R_CASENUMBER8			12345678908

R_SRCFACID9				9
R_DSTFACID9				109
R_CASENUMBER9			12345678909

---save

*/