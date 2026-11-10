-- U007 · Reverts V007__create_roles.sql (run U008 first: a role with grants cannot be dropped).
DROP ROLE IF EXISTS courts_writer;
DROP ROLE IF EXISTS courts_reader;
