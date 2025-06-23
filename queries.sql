--These queries are written and will be used for showing things
--academic report query
select r.report_id, academic_field, description_of_report, i.name, i.type, i.address, i.year_established
from report r join person p on p.person_id = r.person_id
join academicreport ar on ar.report_id = r.report_id
join institution i on i.institution_id = ar.institution_id
where p.person_id = 3;

--employment report
select r.report_id, summary, er.start_date, er.end_date, job_role, income_per_month
from report r join person p on p.person_id = r.person_id
join employmentreport er on er.report_id = r.report_id
where p.person_id = 5;

--medical report
select r.report_id,summary, next_control_date, d.short_description, d.therapy, d.severity, d.is_chronic, doc.name, doc.surname, doc.specialization
from report r join person p on p.person_id = r.person_id
join medicalreport mr on mr.report_id = r.report_id
join medicalreport_diagnosis mrd on mr.report_id = mrd.report_id
join diagnosis d on mrd.diagnosis_id = d.diagnosis_id
join doctor doc on doc.doctor_id = mr.doctor_id
where p.person_id = 7;

--crime report
select r.report_id, label,severity_level, location, resolved, descriptive_punishment
-- select pu.*
from report r join person p on p.person_id = r.person_id
join criminalreport cr on cr.report_id = r.report_id
join crimetype ct on cr.crime_type_id = ct.crime_type_id
-- join punishment pu on pu.report_id = cr.report_id
where p.person_id = 2;


--report
select count(*) as total_reports
from report