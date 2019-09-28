conn = database('LocalSQLExpress','','');
tablename = "XTX8003_Data.dbo.PDV_Data";
data = sqlread(conn,tablename);
tail(data,3)
close(conn);