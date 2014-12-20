--
-- CREATE_SEQUENCE
--

CREATE SEQUENCE person_id_seq
  INCREMENT BY 10
  MINVALUE 1000
  MAXVALUE 5000000
  START 1000
  CACHE 10
  CYCLE
  OWNED BY person.id;

