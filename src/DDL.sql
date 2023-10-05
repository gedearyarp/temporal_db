CREATE TABLE public.project (
	id serial4 NOT NULL,
	name varchar(255) NOT NULL,
	start_date date NULL,
	end_date date NULL,
	CONSTRAINT project_pkey PRIMARY KEY (id)
);

CREATE TABLE public.teams (
	user_id int4 NOT NULL DEFAULT nextval('teams_id_seq'::regclass),
	"name" varchar(255) NOT NULL,
	start_period date NULL,
	end_period date NULL,
	CONSTRAINT teams_pkey PRIMARY KEY (user_id)
);
