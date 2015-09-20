create table alias (id text, alias text);
create table sensor (id text, type text, path text);
create table sensormetric (id text, metric text);
create table sensorgroup (groupname text, sensor_id text);
create table plotgroup ( groupname TEXT, sensor_id TEXT, plot_type TEXT);
CREATE TABLE plotconfig (name text, plotgroup text, timespan text, size integer, prio integer, visible boolean);
