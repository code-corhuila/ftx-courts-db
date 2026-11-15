-- U004: manual rollback for V004; ensure no grants/dependencies remain.
DROP ROLE IF EXISTS courts_writer;
DROP ROLE IF EXISTS courts_reader;
