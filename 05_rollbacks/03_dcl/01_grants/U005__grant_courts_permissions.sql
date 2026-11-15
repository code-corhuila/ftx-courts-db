-- U005: manual rollback for V005.
REVOKE courts_writer FROM courts_app;
REVOKE SELECT ON courts.courts FROM courts_reader;
REVOKE SELECT, INSERT, UPDATE, DELETE ON courts.courts FROM courts_writer;
REVOKE USAGE ON SCHEMA courts FROM courts_reader, courts_writer;
