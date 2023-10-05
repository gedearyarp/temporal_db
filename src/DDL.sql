CREATE SEQUENCE project_id_seq;
CREATE SEQUENCE teams_id_seq;

CREATE TABLE project (
    id INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('project_id_seq'),
    name VARCHAR(255) NOT NULL,
    start_date DATE,
	end_date DATE
);

CREATE TABLE teams (
    user_id INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('teams_id_seq'),
    name VARCHAR(255) NOT NULL,
    start_period DATE,
	end_period DATE
);