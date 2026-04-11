from datetime import date, datetime
from flask import Blueprint, render_template, request, redirect, session
from db import get_connection

faculty_bp = Blueprint("faculty", __name__)


@faculty_bp.route("/faculty/dashboard")
def faculty_dashboard():

    if session.get("role") != "faculty":
        return "Unauthorized", 403

    faculty_id = session["faculty_id"]

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT
    sc.sem_course_id,
    c.course_code,
    c.course_name,
    COUNT(DISTINCT r.student_id) as student_count
    FROM semester_courses sc
    JOIN courses c ON sc.course_id = c.course_id
    LEFT JOIN registration r ON sc.sem_course_id = r.sem_course_id 
                              AND r.status = 'Active'
    WHERE sc.faculty_id = :fid
    GROUP BY sc.sem_course_id, c.course_code, c.course_name
    """, {"fid": faculty_id})

    courses = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template("faculty_dashboard.html", courses=courses)


@faculty_bp.route("/faculty/course/<int:sem_course_id>")
def view_course_students(sem_course_id):

    if session.get("role") != "faculty":
        return "Unauthorized", 403

    faculty_id = session["faculty_id"]

    conn = get_connection()
    cursor = conn.cursor()

    # Get course details
    cursor.execute("""
    SELECT c.course_code, c.course_name, sc.faculty_id
    FROM semester_courses sc
    JOIN courses c ON sc.course_id = c.course_id
    WHERE sc.sem_course_id = :cid
    """, {"cid": sem_course_id})
    
    course = cursor.fetchone()

    if not course or course[2] != int(faculty_id):
        cursor.close()
        conn.close()
        return "Unauthorized", 403

    # Get all active students in this course
    cursor.execute("""
    SELECT
    r.registration_id,
    s.student_id,
    s.full_name,
    s.email,
    COALESCE(att.total_lectures, 0) as total_lectures,
    COALESCE(att.present_count, 0) as present_count,
    COALESCE(res.grade, 'Not Graded') as grade,
    r.status
    FROM registration r
    JOIN students s ON r.student_id = s.student_id
    LEFT JOIN (
        SELECT registration_id, COUNT(DISTINCT att_date) as total_lectures, 
                SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as present_count
        FROM attendance
        GROUP BY registration_id
    ) att ON r.registration_id = att.registration_id
    LEFT JOIN results res ON r.registration_id = res.registration_id
    WHERE r.sem_course_id = :cid AND r.status = 'Active'
    ORDER BY s.full_name
    """, {"cid": sem_course_id})

    students = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template(
        "faculty_course_students.html",
        course=course,
        students=students,
        sem_course_id=sem_course_id
    )



@faculty_bp.route("/faculty/course/<int:sem_course_id>/attendance")
def attendance_overview(sem_course_id):
    """Show attendance date picker and history for a course"""

    if session.get("role") != "faculty":
        return "Unauthorized", 403

    faculty_id = session["faculty_id"]

    conn = get_connection()
    cursor = conn.cursor()

    # Get course details including session dates
    cursor.execute("""
    SELECT c.course_code, c.course_name, sc.faculty_id,
           TO_CHAR(s.start_dt, 'YYYY-MM-DD') as start_dt,
           TO_CHAR(s.end_dt, 'YYYY-MM-DD') as end_dt
    FROM semester_courses sc
    JOIN courses c ON sc.course_id = c.course_id
    JOIN semesters s ON sc.semester_id = s.semester_id
    WHERE sc.sem_course_id = :cid
    """, {"cid": sem_course_id})

    course = cursor.fetchone()

    if not course or course[2] != int(faculty_id):
        cursor.close()
        conn.close()
        return "Unauthorized", 403

    # Get all dates already marked for this course with present/total counts
    cursor.execute("""
    SELECT TO_CHAR(a.att_date, 'YYYY-MM-DD') as att_date,
           COUNT(*) as total_students,
           SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) as present_count
    FROM attendance a
    JOIN registration r ON a.registration_id = r.registration_id
    WHERE r.sem_course_id = :cid
    GROUP BY a.att_date
    ORDER BY a.att_date DESC
    """, {"cid": sem_course_id})

    marked_dates = cursor.fetchall()
    cursor.close()
    conn.close()

    today = date.today().strftime("%Y-%m-%d")

    return render_template(
        "faculty_attendance_overview.html",
        course=course,
        sem_course_id=sem_course_id,
        marked_dates=marked_dates,
        today=today
    )


@faculty_bp.route("/faculty/course/<int:sem_course_id>/attendance/<att_date>", methods=["GET", "POST"])
def mark_daily_attendance(sem_course_id, att_date):
    """Mark attendance for all students on a specific date"""

    if session.get("role") != "faculty":
        return "Unauthorized", 403

    faculty_id = session["faculty_id"]

    # Validate date format
    try:
        datetime.strptime(att_date, "%Y-%m-%d")
    except ValueError:
        return "Invalid date format. Use YYYY-MM-DD.", 400

    conn = get_connection()
    cursor = conn.cursor()

    # Get course details and verify faculty ownership
    cursor.execute("""
    SELECT c.course_code, c.course_name, sc.faculty_id
    FROM semester_courses sc
    JOIN courses c ON sc.course_id = c.course_id
    WHERE sc.sem_course_id = :cid
    """, {"cid": sem_course_id})

    course = cursor.fetchone()

    if not course or course[2] != int(faculty_id):
        cursor.close()
        conn.close()
        return "Unauthorized", 403

    if request.method == "GET":
        # Get all active students with their attendance status for this specific date
        cursor.execute("""
        SELECT r.registration_id,
               s.student_id,
               s.full_name,
               s.email,
               COALESCE(a.status, 'Present') as status
        FROM registration r
        JOIN students s ON r.student_id = s.student_id
        LEFT JOIN attendance a ON r.registration_id = a.registration_id
            AND a.att_date = TO_DATE(:att_date, 'YYYY-MM-DD')
        WHERE r.sem_course_id = :cid AND r.status = 'Active'
        ORDER BY s.full_name
        """, {"cid": sem_course_id, "att_date": att_date})

        students = cursor.fetchall()
        cursor.close()
        conn.close()

        return render_template(
            "faculty_attendance_mark.html",
            course=course,
            students=students,
            sem_course_id=sem_course_id,
            att_date=att_date
        )

    elif request.method == "POST":
        # Get all active students for this course
        cursor.execute("""
        SELECT r.registration_id
        FROM registration r
        WHERE r.sem_course_id = :cid AND r.status = 'Active'
        """, {"cid": sem_course_id})

        registrations = [row[0] for row in cursor.fetchall()]

        # Students whose checkbox was checked (present)
        try:
            present_ids = set(int(x) for x in request.form.getlist("present"))
        except (ValueError, TypeError):
            cursor.close()
            conn.close()
            return "Invalid form data.", 400

        for reg_id in registrations:
            status = "Present" if reg_id in present_ids else "Absent"

            # Delete any existing record(s) for this student on this date
            cursor.execute("""
            DELETE FROM attendance
            WHERE registration_id = :rid
              AND att_date = TO_DATE(:att_date, 'YYYY-MM-DD')
            """, {"rid": reg_id, "att_date": att_date})

            # Insert fresh record
            cursor.execute("""
            INSERT INTO attendance (registration_id, att_date, status, marked_by)
            VALUES (:rid, TO_DATE(:att_date, 'YYYY-MM-DD'), :status, :fid)
            """, {"rid": reg_id, "att_date": att_date, "status": status, "fid": faculty_id})

        conn.commit()
        cursor.close()
        conn.close()

        return redirect(f"/faculty/course/{sem_course_id}/attendance")


@faculty_bp.route("/faculty/result/<int:registration_id>", methods=["GET", "POST"])
def manage_result(registration_id):

    if session.get("role") != "faculty":
        return "Unauthorized", 403

    faculty_id = session["faculty_id"]

    conn = get_connection()
    cursor = conn.cursor()

    if request.method == "GET":
        # Show result form
        try:
            cursor.execute("""
            SELECT 
                s.student_id,
                s.full_name,
                c.course_code,
                c.course_name,
                r.registration_id,
                r.sem_course_id,
                COALESCE(res.grade, '') as grade
            FROM registration r
            JOIN students s ON r.student_id = s.student_id
            JOIN semester_courses sc ON r.sem_course_id = sc.sem_course_id
            JOIN courses c ON sc.course_id = c.course_id
            LEFT JOIN results res ON r.registration_id = res.registration_id
            WHERE r.registration_id = :rid AND sc.faculty_id = :fid
            """, {"rid": registration_id, "fid": faculty_id})

            result_info = cursor.fetchone()
            
            if not result_info:
                cursor.close()
                conn.close()
                return "Unauthorized or Registration not found", 403

            cursor.close()
            conn.close()

            return render_template(
                "faculty_result.html",
                result_info=result_info,
                registration_id=registration_id,
                sem_course_id=result_info[5]
            )
            
        except Exception as e:
            cursor.close()
            conn.close()
            print(f"Error in GET: {str(e)}")
            return f"Error: {str(e)}", 500

    elif request.method == "POST":
        # Save result
        try:
            grade = request.form.get("grade", "").upper().strip()

            # Valid grades with their point values
            valid_grades = {
                "AA": 10,
                "AB": 9,
                "BB": 8,
                "BC": 7,
                "CC": 6,
                "FF": 0
            }

            if grade not in valid_grades:
                cursor.close()
                conn.close()
                return "Invalid grade. Use: AA, AB, BB, BC, CC, FF", 400

            grade_points = valid_grades[grade]

            # First get the sem_course_id
            cursor.execute("""
                SELECT sem_course_id FROM registration WHERE registration_id = :rid
            """, {"rid": registration_id})
            
            sem_result = cursor.fetchone()
            if not sem_result:
                cursor.close()
                conn.close()
                return "Registration not found", 404
                
            sem_course_id = sem_result[0]

            # Check if result already exists
            cursor.execute("""
                SELECT result_id FROM results
                WHERE registration_id = :rid
            """, {"rid": registration_id})

            existing_result = cursor.fetchone()

            if existing_result:
                # Update existing result
                cursor.execute("""
                    UPDATE results
                    SET grade = :grade,
                        result_date = SYSDATE,
                        updated_at = SYSDATE
                    WHERE registration_id = :rid
                """, {
                    "grade": grade,
                    "rid": registration_id
                })
            else:
                # Insert new result
                cursor.execute("""
                    INSERT INTO results
                    (registration_id, marks_obtained, total_marks, grade, result_date)
                    VALUES (:rid, :mp, 10, :grade, SYSDATE)
                """, {
                    "rid": registration_id,
                    "mp": grade_points,
                    "grade": grade
                })

            conn.commit()
            cursor.close()
            conn.close()

            # Redirect to course students view
            return redirect(f"/faculty/course/{sem_course_id}")
            
        except Exception as e:
            conn.rollback()
            cursor.close()
            conn.close()
            print(f"Error in POST: {str(e)}")
            return f"Error: {str(e)}", 500