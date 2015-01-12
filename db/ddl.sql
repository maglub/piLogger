create table device (id text, type text, path text);
create table alias (id text, alias text);
create table devicegroup (groupname text, device_id text);
create table plotgroup ( groupname TEXT, device_id TEXT, plot_type TEXT);
create table plotconfig (name text, plotgroup text, timespan text, size integer, prio integer);
create table arne (name text);
