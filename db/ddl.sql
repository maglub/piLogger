create table device (id text, type text, path text);
create table alias (id text, alias text);
create table devicegroup (groupname text, device_id text);
create table plotgroup ( groupname TEXT, device_id TEXT, plot_type TEXT);
CREATE TABLE plotconfig (name text, plotgroup text, timespan text, size integer, prio integer, visible boolean);
create table arne (name text);
