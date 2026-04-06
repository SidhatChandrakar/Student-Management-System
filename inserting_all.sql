INSERT INTO departments (department_name, description)
VALUES ('Computer Science and Engineering', 'CSE Department');

INSERT INTO departments (department_name, description) VALUES 
('Electronics & Communication Engineering', 'Department of Electronics and Communication Engineering');

INSERT INTO departments (department_name, description) VALUES 
('Electrical Engineering', 'Department of Electrical Engineering');

INSERT INTO departments (department_name, description) VALUES 
('Mechanical Engineering', 'Department of Mechanical Engineering');

INSERT INTO departments (department_name, description) VALUES 
('Civil Engineering', 'Department of Civil Engineering');

INSERT INTO departments (department_name, description) VALUES 
('Chemical Engineering', 'Department of Chemical Engineering');

INSERT INTO departments (department_name, description) VALUES 
('Mathematics', 'Department of Mathematics');

INSERT INTO departments (department_name, description) VALUES 
('Physics', 'Department of Physics');

INSERT INTO departments (department_name, description) VALUES 
('Chemistry', 'Department of Chemistry');

INSERT INTO departments (department_name, description) VALUES 
('Architecture', 'Department of Architecture');

select *from departments;

commit;
select *from COURSES;
---inserting program outcomes
INSERT INTO program_outcomes (po_code, description, department_id)
VALUES ('PO1','Engineering knowledge',1);

INSERT INTO program_outcomes (po_code, description, department_id)
VALUES ('PO2','Problem analysis',1);

INSERT INTO program_outcomes (po_code, description, department_id)
VALUES ('PO3','Design solutions',1);

INSERT INTO program_outcomes (po_code, description, department_id)
VALUES ('PO4','Investigate complex problems',1);

---inserting courses
INSERT INTO courses (
course_code,
course_name,
course_type,
lectures,
tutorials,
practicals,
credits,
department_id,
course_content,
text_books,
reference_books,
prerequisites,
course_description
)
VALUES (
'CSL514',
'Advances in Algorithms',
'Theory',
3,
0,
0,
3,
1,
'Asymptotic complexity, divide and conquer, greedy, dynamic programming, backtracking, branch and bound, FFT, NP completeness, approximation and randomized algorithms',
'E. Horowitz, S. Sahni, S. Rajasekaran – Fundamentals of Computer Algorithms',
'Thomas H. Cormen et al. – Introduction to Algorithms',
'Data Structures and Program Design',
'Advanced algorithm design and analysis techniques'
);

commit;

--inserting course outcomes
INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (22,'CO1','Need for analysis of algorithms','Understand');

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (22,'CO2','Analyze best, average and worst case complexities','Analyze');

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (22,'CO3','Understand standard algorithm design techniques','Understand');

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (22,'CO4','Design efficient algorithms for engineering problems','Apply');

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (22,'CO5','Understand NP completeness and algorithm limitations','Analyze');

--inserting co-po mapping
--CO1
INSERT INTO co_po_mapping VALUES (6,5,'High',SYSDATE);
INSERT INTO co_po_mapping VALUES (6,6,'Medium',SYSDATE);
INSERT INTO co_po_mapping VALUES (6,7,'High',SYSDATE);
INSERT INTO co_po_mapping VALUES (6,8,'Low',SYSDATE);
--CO2
INSERT INTO co_po_mapping VALUES (7,5,'High',SYSDATE);
INSERT INTO co_po_mapping VALUES (7,6,'High',SYSDATE);
INSERT INTO co_po_mapping VALUES (7,7,'High',SYSDATE);
INSERT INTO co_po_mapping VALUES (7,8,'Medium',SYSDATE);
--CO3
INSERT INTO co_po_mapping VALUES (8,5,'Low',SYSDATE);
INSERT INTO co_po_mapping VALUES (8,7,'Low',SYSDATE);
INSERT INTO co_po_mapping VALUES (8,8,'Low',SYSDATE);
--CO4
INSERT INTO co_po_mapping VALUES (9,5,'Medium',SYSDATE);
INSERT INTO co_po_mapping VALUES (9,6,'Medium',SYSDATE);
INSERT INTO co_po_mapping VALUES (9,7,'Low',SYSDATE);
INSERT INTO co_po_mapping VALUES (9,8,'Low',SYSDATE);
--CO5
INSERT INTO co_po_mapping VALUES (10,5,'Medium',SYSDATE);
INSERT INTO co_po_mapping VALUES (10,6,'Medium',SYSDATE);
INSERT INTO co_po_mapping VALUES (10,7,'Low',SYSDATE);

-- SELECT co_id, co_number
-- FROM course_outcomes;
-- SELECT po_id, po_code
-- FROM program_outcomes;

--INSERTING ASSESMENT TYPE
INSERT INTO assessment_types (assessment_name,description)
VALUES ('Assignment','Course Assignment');

INSERT INTO assessment_types (assessment_name,description)
VALUES ('Quiz','Short quiz');

INSERT INTO assessment_types (assessment_name,description)
VALUES ('Mid-Sem','Mid semester exam');

INSERT INTO assessment_types (assessment_name,description)
VALUES ('End-Sem','End semester exam');

---INSERTING ASSESMENT STRUCTURE
INSERT INTO course_assessment (course_id,assessment_id,max_marks,percentage)
VALUES (22,9,10,10);

INSERT INTO course_assessment (course_id,assessment_id,max_marks,percentage)
VALUES (22,10,10,10);

INSERT INTO course_assessment (course_id,assessment_id,max_marks,percentage)
VALUES (22,11,20,20);

INSERT INTO course_assessment (course_id,assessment_id,max_marks,percentage)
VALUES (22,12,60,60);

-- SELECT *FROM COURSE_ASSESSMENT;

--------------------------------------------------------------------------------------------------
--inserting MFCS CSL-503
INSERT INTO courses (
course_code,
course_name,
course_type,
lectures,
tutorials,
practicals,
credits,
department_id,
course_description,
course_content,
text_books,
reference_books,
prerequisites
)
VALUES (
'CSL503',
'Mathematical Foundations for Computer Science',
'Theory',
3,
1,
0,
4,
(SELECT department_id FROM departments 
 WHERE department_name='Computer Science and Engineering'),
'Discrete mathematics and mathematical tools for computer science applications',
'Set theory, relations and functions, lattices, Boolean algebra, semigroups, groups, graph theory, discrete probability, statistics, linear algebra',
'Kenneth H. Rosen – Discrete Mathematics and Its Applications',
'Kolman – Discrete Mathematical Structures; Spiegel – Probability and Statistics',
'NONE'
);


--INSERTING COURSE OUTCOME
INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL503'),
'CO1',
'Use different proof techniques and analyze limits using pigeonhole principle',
'Apply'
);

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL503'),
'CO2',
'Solve problems based on set theory, permutations, combinations and probability',
'Apply'
);

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL503'),
'CO3',
'Solve mathematical problems involving partial orders and group theory',
'Analyze'
);

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL503'),
'CO4',
'Model and analyze computational problems in graph theory',
'Analyze'
);

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL503'),
'CO5',
'Formulate linear algebra problems and solve operations research models',
'Evaluate'
);

--INSERTING CO-PO MAPPING
--CO1
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO1'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL503')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO1'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL503')
AND po.po_code='PO3';

--CO2
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL503')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL503')
AND po.po_code='PO3';

--CO3
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL503')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL503')
AND po.po_code='PO3';

--CO4
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL503')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL503')
AND po.po_code='PO3';

--CO5
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO5'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL503')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO5'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL503')
AND po.po_code='PO2';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO5'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL503')
AND po.po_code='PO3';

--INSERTING course ASSESSMENT structure
INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL503'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='Assignment'),
10,
10
);

INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL503'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='Quiz'),
10,
10
);

INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL503'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='Mid-Sem'),
20,
20
);

INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL503'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='End-Sem'),
60,
60
);
commit;
----------------------------------------------------------------------------------------------------------------------
                    --software lab

--inserting course
INSERT INTO courses (
course_code,
course_name,
course_type,
lectures,
tutorials,
practicals,
credits,
department_id,
course_description,
course_content,
text_books,
reference_books,
prerequisites
)
VALUES (
'CSP502',
'Software Lab I',
'Lab',
0,
1,
2,
2,
(SELECT department_id FROM departments
 WHERE department_name='Computer Science and Engineering'),
'Laboratory course introducing Linux environment, programming tools and web technologies',
'Linux commands, scripting, debugging tools, networking tools, web technologies, object oriented programming, advanced programming and data structures',
'Head First Java – Kathy Sierra, Bert Bates',
'Linux in a Nutshell – Ellen Siever, Stephen Figgins, Robert Love',
'None'
);

--inserting course outcomes
INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSP502'),
'CO1',
'Understand Linux environment and basic commands',
'Understand'
);

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSP502'),
'CO2',
'Develop and debug applications using Linux tools',
'Apply'
);

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSP502'),
'CO3',
'Apply object oriented programming and web technologies',
'Apply'
);

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSP502'),
'CO4',
'Use networking and system monitoring tools',
'Analyze'
);

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSP502'),
'CO5',
'Develop programs using advanced data structures and scripting',
'Create'
);

--inserting co-po mapping
--co1
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO1'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP502')
AND po.po_code='PO1';

--co2
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP502')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP502')
AND po.po_code='PO3';

--co3
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP502')
AND po.po_code='PO2';

--co4
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP502')
AND po.po_code='PO3';

--co5
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'High', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO5'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP502')
AND po.po_code='PO1';

--inseting course assessment structure
INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSP502'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='Assignment'),
30,
30
);

INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSP502'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='Quiz'),
20,
20
);

INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSP502'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='Mid-Sem'),
20,
20
);

INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSP502'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='End-Sem'),
30,
30
);
commit;

-----------------------------------------------------------------------------------------------------------
--inseting TECHNICAL HISTORY writing
--inseting course
INSERT INTO courses (
course_code, course_name, course_type,
lectures, tutorials, practicals, credits,
department_id, course_description, prerequisites
)
VALUES (
'CSP529',
'Technical Writing and Publishing',
'Practical',
1,0,2,2,
(SELECT department_id FROM departments
 WHERE department_name='Computer Science and Engineering'),
'Technical writing, documentation, research papers, reports and publishing tools',
'None'
);

UPDATE courses
SET text_books =
'1. Strunk and White – The Elements of Style
2. Gretchen Hargis et al. – Developing Quality Technical Information
3. Leslie Lamport – LaTeX
4. Justin Zobel – Writing for Computer Science'
WHERE course_code = 'CSP529';

--INSERTING COURSE OUTCOMES
INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES ((SELECT course_id FROM courses WHERE course_code='CSP529'),
'CO1','Understand writing process for technical documentation','Understand');

INSERT INTO course_outcomes VALUES (
DEFAULT,
(SELECT course_id FROM courses WHERE course_code='CSP529'),
'CO2',
'Produce technical documents and reports',
'Apply',
SYSDATE
);

INSERT INTO course_outcomes VALUES (
DEFAULT,
(SELECT course_id FROM courses WHERE course_code='CSP529'),
'CO3',
'Understand technical writing concepts and presentation',
'Understand',
SYSDATE
);

INSERT INTO course_outcomes VALUES (
DEFAULT,
(SELECT course_id FROM courses WHERE course_code='CSP529'),
'CO4',
'Interpret and analyze technical literature',
'Analyze',
SYSDATE
);

INSERT INTO course_outcomes VALUES (
DEFAULT,
(SELECT course_id FROM courses WHERE course_code='CSP529'),
'CO5',
'Synthesize research materials and integrate sources',
'Create',
SYSDATE
);

--INSETING CO-PO MAPPING
--INSERTING CO1
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'High', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO1'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'High', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO1'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO2';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO1'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO3';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO1'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO4';

--INSETING CO2
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO2';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'High', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO3';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'High', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO4';

--INSERTING CO3
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'High', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO2';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO3';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO4';

--CO4
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'High', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'High', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO2';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO3';

--INSERTING C05
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'High', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO5'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'High', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO5'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO2';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO5'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO3';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO5'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSP529')
AND po.po_code='PO4';

--INSERTING COURSE ASSESSMENT STRUCTURE
INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSP529'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='Assignment'),
25,
25
);

INSERT INTO course_assessment
VALUES (
DEFAULT,
(SELECT course_id FROM courses WHERE course_code='CSP529'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='Quiz'),
25,
25,
SYSDATE
);

INSERT INTO course_assessment
VALUES (
DEFAULT,
(SELECT course_id FROM courses WHERE course_code='CSP529'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='Mid-Sem'),
20,
20,
SYSDATE
);

INSERT INTO course_assessment
VALUES (
DEFAULT,
(SELECT course_id FROM courses WHERE course_code='CSP529'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='End-Sem'),
30,
30,
SYSDATE
);
commit;

------------------------------------------------------------------------------------------------------------------
--Pattern Recognition
INSERT INTO courses (
course_code, course_name, course_type,
lectures, tutorials, practicals, credits,
department_id, course_description, prerequisites
)
VALUES (
'CSL517',
'Pattern Recognition',
'Theory',
3,0,2,4,
(SELECT department_id FROM departments
 WHERE department_name='Computer Science and Engineering'),
'Statistical and syntactic pattern recognition, classifiers, SVM and unsupervised learning',
'Probability theory, Linear Algebra'
);
UPDATE courses
SET text_books =
'1. Probability and Statistics with Reliability, Queuing, and Computer Science Applications – Kishore Trivedi, John Wiley and Sons, New York, 2001
2. Pattern Recognition (4th Edition) – Sergios Theodoridis, Konstantinos Koutroumbas, Elsevier, ISBN: 9781597492720, 2008
3. Pattern Classification (2nd Edition) – Richard O. Duda, Peter E. Hart, David G. Stork, Wiley, ISBN: 978-0-471-05669'
WHERE course_code = 'CSL517';

--inseting course outcome
INSERT INTO course_outcomes VALUES (
DEFAULT,(SELECT course_id FROM courses WHERE course_code='CSL517'),
'CO1','Understand probability theory and distributions','Understand',SYSDATE);

INSERT INTO course_outcomes VALUES (
DEFAULT,(SELECT course_id FROM courses WHERE course_code='CSL517'),
'CO2','Build classifiers using parametric and non parametric methods','Apply',SYSDATE);

INSERT INTO course_outcomes VALUES (
DEFAULT,(SELECT course_id FROM courses WHERE course_code='CSL517'),
'CO3','Build linear and nonlinear classifiers using SVM','Apply',SYSDATE);

INSERT INTO course_outcomes VALUES (
DEFAULT,(SELECT course_id FROM courses WHERE course_code='CSL517'),
'CO4','Understand unsupervised learning techniques','Analyze',SYSDATE);

INSERT INTO course_outcomes VALUES (
DEFAULT,(SELECT course_id FROM courses WHERE course_code='CSL517'),
'CO5','Understand feature generation and selection','Analyze',SYSDATE);

--inserting co-po mapping
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO1'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO1'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO3';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO1'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO4';

--co2
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO2';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO3';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO4';

--insert co3
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO2';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO3';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO4';

--co4
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO2';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO3';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO4';

--co5
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO5'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO5'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO2';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO5'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO3';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO5'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL517')
AND po.po_code='PO4';

--inserting course assmnt structure
INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL517'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='Assignment'),
25,
25
);

INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL517'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='Quiz'),
10,
10
);

INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL517'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='Mid-Sem'),
30,
30
);

INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL517'),
(SELECT assessment_id FROM assessment_types WHERE assessment_name='End-Sem'),
60,
60
);

--------------------------------------------------------------------
--IS
INSERT INTO courses (
course_code,
course_name,
course_type,
lectures,
tutorials,
practicals,
credits,
department_id,
course_description,
prerequisites
)
VALUES (
'CSL521',
'Intelligent Systems',
'Theory',
3,
0,
2,
4,
(SELECT department_id 
 FROM departments 
 WHERE department_name='Computer Science and Engineering'),
'Mathematical foundations and algorithms for intelligent agents using search, logic and probabilistic reasoning',
'None'
);
UPDATE courses
SET text_books =
'1. Artificial Intelligence: A Modern Approach – Stuart Russell and Peter Norvig, Pearson Education
2. Artificial Intelligence – A Practical Approach – Patterson, Tata McGraw Hill'
WHERE course_code = 'CSL521';
commit;
--inserting course outcome
INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL521'),
'CO1',
'Model problems so that exploratory search can be applied',
'Apply'
);

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL521'),
'CO2',
'Build optimal heuristic and memory bounded search techniques',
'Apply'
);

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL521'),
'CO3',
'Apply formal logic to represent knowledge',
'Analyze'
);

INSERT INTO course_outcomes (course_id,co_number,description,bloom_level)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL521'),
'CO4',
'Analyze different reasoning techniques',
'Analyze'
);

--inserting co-po mapping
--co1
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO1'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL521')
AND po.po_code='PO2';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO1'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL521')
AND po.po_code='PO3';

--co2
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL521')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Medium', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL521')
AND po.po_code='PO3';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO2'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL521')
AND po.po_code='PO4';

--co3
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL521')
AND po.po_code='PO2';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL521')
AND po.po_code='PO3';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO3'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL521')
AND po.po_code='PO4';

--co4
INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL521')
AND po.po_code='PO1';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL521')
AND po.po_code='PO3';

INSERT INTO co_po_mapping
SELECT co.co_id, po.po_id, 'Low', SYSDATE
FROM course_outcomes co, program_outcomes po
WHERE co.co_number='CO4'
AND co.course_id=(SELECT course_id FROM courses WHERE course_code='CSL521')
AND po.po_code='PO4';

--inserting course assessment
INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL521'),
(SELECT assessment_id FROM assessment_types 
 WHERE assessment_name='Assignment'),
25,
25
);

INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL521'),
(SELECT assessment_id FROM assessment_types 
 WHERE assessment_name='Mid-Sem'),
25,
25
);

INSERT INTO course_assessment
(course_id,assessment_id,max_marks,percentage)
VALUES (
(SELECT course_id FROM courses WHERE course_code='CSL521'),
(SELECT assessment_id FROM assessment_types 
 WHERE assessment_name='End-Sem'),
50,
50
);
commit;

--------------------------------------------------------------------------------------------
--creating session and assigning above courses to winter sessn
INSERT INTO semesters
(yr, sess, semester_number, start_dt, end_dt)
VALUES
(2025, 'Winter', 1,
DATE '2025-08-13',
DATE '2025-12-05');

INSERT INTO semesters
(yr, sess, semester_number, start_dt, end_dt)
VALUES
(2025, 'Summer', 2,
DATE '2026-01-07',
DATE '2025-05-10');

--inserting faculties
INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES (
'S. R. Sathe',
'srsathe@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Theoretical Foundations of Computer Science, Cryptography, Discrete Mathematics',
'pass123'
);

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES (
'O.G. Kakde',
'ogkakde@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Language Processor, Compiler Construction',
'pass123'
);

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES (
'P.S. Deshpande',
'psdeshpande@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Database Management Systems, Data Warehousing, Data Mining',
'pass123'
);

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES (
'U.A. Deshpande',
'uadeshpande@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Multi-agent Systems, Distributed Systems',
'pass123'
);

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES (
'R.B. Keskar',
'rbkeskar@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Telecommunication Software, Distributed Systems',
'pass123'
);

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES (
'M.P. Kurhekar',
'mpkurhekar@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Theoretical Computer Science, Bioinformatics',
'pass123'
);

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES (
'A.S. Mokhade',
'asmokhade@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Software Engineering, Software Architecture',
'pass123'
);

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES (
'M.M. Dhabu',
'mmdhabu@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Soft Computing, Network Security',
'pass123'
);

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES ('Ashish Tiwari','atiwari@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Mobile Communication, Information Security','pass123');

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES ('S.A. Raut','saraut@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Data Mining, Business Intelligence','pass123');

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES ('Deepti Shrimankar','dshrimankar@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Parallel Systems, Embedded Systems','pass123');

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES ('M.A. Radke','maradke@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Information Retrieval, NLP','pass123');

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES ('P.A. Sharma','pasharma@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Image Processing, Biometrics','pass123');

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES ('Praveen Kumar','pkumar@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Image Processing, Computer Vision','pass123');

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES ('Dr. Syed Taqi Ali','stali@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Information Security, Cryptography','pass123');

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES ('Dr. Anshul Agarwal','aagarwal@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Cyber Physical Systems, Smart Grids','pass123');

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES ('Dr. Swati Jaiswal','sjaiswal@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Compilers, Program Analysis','pass123');

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES ('Dr. Gaurav Mishra','gmishra@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Data Clustering, Graph Algorithms','pass123');

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES ('Dr. Hemkumar D','hdkumar@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Data Privacy','pass123');

INSERT INTO faculties (faculty_name,email,department_id,specialization,password_hash)
VALUES ('Dr. P.V.N. Prashanth','pvnprashanth@cse.edu',
(SELECT department_id FROM departments WHERE department_name='Computer Science and Engineering'),
'Software Defined Networks, Distributed Ledgers','pass123');

--verification
SELECT faculty_name, specialization,faculty_id
FROM faculties
WHERE department_id =
(SELECT department_id
 FROM departments
 WHERE department_name='Computer Science and Engineering');
commit;

---------------------------------------------------------------------------------------------------
--assigning coureses to winter session
INSERT INTO semester_courses (semester_id, course_id, faculty_id)
SELECT
(SELECT semester_id FROM semesters
 WHERE yr=2025 AND sess='Winter'),
course_id,
CASE course_code
WHEN 'CSL503' THEN 1
WHEN 'CSL514' THEN 18
WHEN 'CSP502' THEN 7
WHEN 'CSP529' THEN 7
WHEN 'CSL517' THEN 3
WHEN 'CSL536' THEN 14
WHEN 'CSL510' THEN 7
WHEN 'CSL521' THEN 4
WHEN 'CSL532' THEN 9
WHEN 'CSL516' THEN 8
END
FROM courses
WHERE course_code IN
('CSL503','CSL514','CSP502','CSP529','CSL517',
 'CSL536','CSL510','CSL521','CSL532','CSL516');
commit;
-----------------------------------------------------------------------------------------------------
--inserting into program table
INSERT INTO programs (program_name,degree,department_id)
VALUES (
'Computer Science and Engineering',
'B.Tech',
(SELECT department_id FROM departments
WHERE department_name='Computer Science and Engineering')
);

INSERT INTO programs (program_name,degree,department_id)
VALUES (
'Computer Science and Engineering',
'M.Tech',
(SELECT department_id FROM departments
WHERE department_name='Computer Science and Engineering')
);
---adding program col in courses
ALTER TABLE courses
ADD program_id NUMBER;

ALTER TABLE courses
ADD CONSTRAINT fk_course_program
FOREIGN KEY (program_id)
REFERENCES programs(program_id);

UPDATE courses
SET program_id =
(SELECT program_id FROM programs WHERE degree='M.Tech')
WHERE course_code IN
('CSL503','CSL514','CSP502','CSP529','CSL517',
 'CSL536','CSL510','CSL521','CSL532','CSL516');

select *from students;
select *from semester_courses;

update semester_courses set faculty_id='18' where course_id=23;
commit;