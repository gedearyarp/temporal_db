select during(
	(select start_date from project where name = 'Project Alpha'),
	(select end_date from project where name = 'Project Alpha'),
	(select start_date from project where name = 'Project Beta'),
	(select end_date from project where name = 'Project Beta')
);

select during_inversed(
	(select start_date from project where name = 'Project Beta'),
	(select end_date from project where name = 'Project Beta'),
	(select start_date from project where name = 'Project Alpha'),
	(select end_date from project where name = 'Project Alpha')
);

select finishes(
	(select start_date from project where name = 'Project Gamma'),
	(select end_date from project where name = 'Project Gamma'),
	(select start_date from project where name = 'Project Beta'),
	(select end_date from project where name = 'Project Beta')
);

select finishes_inversed(
	(select start_date from project where name = 'Project Beta'),
	(select end_date from project where name = 'Project Beta'),
	(select start_date from project where name = 'Project Gamma'),
	(select end_date from project where name = 'Project Gamma')
);

select is_after(
	(select start_date from project where name = 'Project Delta'),
	(select end_date from project where name = 'Project Delta'),
	(select start_date from project where name = 'Project Gamma'),
	(select end_date from project where name = 'Project Gamma')
);

select is_before(
	(select start_date from project where name = 'Project Gamma'),
	(select end_date from project where name = 'Project Gamma'),
	(select start_date from project where name = 'Project Delta'),
	(select end_date from project where name = 'Project Delta')
);

select is_equal(
	(select start_date from project where name = 'Project Delta'),
	(select end_date from project where name = 'Project Delta'),
	(select start_date from project where name = 'Project Epsilon'),
	(select end_date from project where name = 'Project Epsilon')
);

select meets(
	(select start_date from project where name = 'Project Epsilon'),
	(select end_date from project where name = 'Project Epsilon'),
	(select start_date from project where name = 'Project Charlie'),
	(select end_date from project where name = 'Project Charlie')
);

select meets_inversed(
	(select start_date from project where name = 'Project Charlie'),
	(select end_date from project where name = 'Project Charlie'),
	(select start_date from project where name = 'Project Epsilon'),
	(select end_date from project where name = 'Project Epsilon')
);

select overlaps(
	(select start_date from project where name = 'Project Charlie'),
	(select end_date from project where name = 'Project Charlie'),
	(select start_date from project where name = 'Project Golf'),
	(select end_date from project where name = 'Project Golf')
);

select overlaps_inversed(
	(select start_date from project where name = 'Project Golf'),
	(select end_date from project where name = 'Project Golf'),
	(select start_date from project where name = 'Project Charlie'),
	(select end_date from project where name = 'Project Charlie')
);

select starts(
	(select start_date from project where name = 'Project Golf'),
	(select end_date from project where name = 'Project Golf'),
	(select start_date from project where name = 'Project Hotel'),
	(select end_date from project where name = 'Project Hotel')
);

select starts_inversed(
	(select start_date from project where name = 'Project Hotel'),
	(select end_date from project where name = 'Project Hotel'),
	(select start_date from project where name = 'Project Golf'),
	(select end_date from project where name = 'Project Golf')
);

call insert_project('Project Foxy', '2022-01-01', '2022-10-10');
call insert_project('Project Foxy', '2022-10-09', '2022-11-11');
call insert_project('Project Foxy', '2022-12-12', '2022-12-31');

call update_project(11, '2022-12-25', '2022-12-31');

call delete_project(11);

select temporal_coalesce('project', 'name', 'Project Hotel')

select * from project order by id;
select * from teams order by id;