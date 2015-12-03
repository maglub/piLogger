CREATE TABLE alias (id text, alias text);
CREATE TABLE sensorgroup (groupname text, sensor_id text);
CREATE TABLE sensormetric (id text, metric text);
CREATE TABLE plotgroup ( groupname TEXT, sensor_id TEXT, plot_type TEXT);
CREATE TABLE version (id text);
CREATE TABLE passwd (uid integer, username string, password string);
CREATE TABLE plotconfig ( name TEXT, plotgroup TEXT, timespan TEXT, size INT, prio INT , visible boolean); CREATE TABLE plotconfig_new( name TEXT, plotgroup TEXT, timespan TEXT, size INT, prio INT , after integer, before integer);
CREATE TABLE sensor (id TEXT,type TEXT,active NUM, metric text, path text);

