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



@faculty_bp.route("/faculty/course/<sem_course_id>/set-lectures", methods=["GET", "POST"])
def set_course_lectures(sem_course_id):
    """Set total lectures for the course"""

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
    
    course_info = cursor.fetchone()

    if not course_info or course_info[2] != int(faculty_id):
        cursor.close()
        conn.close()
        return "Unauthorized", 403

    # Get current total lectures (stored in a simple way - we'll use max count from attendance)
    cursor.execute("""
    SELECT COALESCE(MAX(total_lectures), 0) as total_lectures
    FROM (
        SELECT COUNT(DISTINCT att_date) as total_lectures
        FROM attendance a
        JOIN registration r ON a.registration_id = r.registration_id
        WHERE r.sem_course_id = :cid
    )
    """, {"cid": sem_course_id})
    
    result = cursor.fetchone()
    current_total = result[0] if result else 0

    if request.method == "GET":
        cursor.close()
        conn.close()
        
        return render_template(
            "faculty_set_lectures.html",
            course=course_info,
            sem_course_id=sem_course_id,
            current_total=current_total
        )

    elif request.method == "POST":
        total_lectures = request.form.get("total_lectures", 0)
        
        try:
            total_lectures = int(total_lectures)
        except:
            cursor.close()
            conn.close()
            return "Invalid total lectures", 400

        if total_lectures <= 0:
            cursor.close()
            conn.close()
            return "Total lectures must be greater than 0", 400

        # Store total lectures in a temporary way by setting attendance records
        # First, clear old records
        cursor.execute("""
        DELETE FROM attendance
        WHERE registration_id IN (
            SELECT registration_id FROM registration WHERE sem_course_id = :cid
        )
        """, {"cid": sem_course_id})

        # Create attendance records for all students as "Absent" initially
        cursor.execute("""
        SELECT registration_id FROM registration
        WHERE sem_course_id = :cid AND status = 'Active'
        """, {"cid": sem_course_id})

        registrations = cursor.fetchall()

        for reg in registrations:
            registration_id = reg[0]
            
            # Create dummy absence records for each lecture
            for i in range(total_lectures):
                cursor.execute("""
                    INSERT INTO attendance
                    (registration_id, att_date, status, marked_by)
                    VALUES (:rid, SYSDATE - :day, 'Absent', :fid)
                """, {
                    "rid": registration_id,
                    "day": total_lectures - i,
                    "fid": faculty_id
                })

        conn.commit()
        cursor.close()
        conn.close()

        return render_template(
            "faculty_lectures_set_success.html",
            course=course_info,
            sem_course_id=sem_course_id,
            total_lectures=total_lectures
        )

@faculty_bp.route("/faculty/course/<sem_course_id>/attendance", methods=["GET", "POST"])
def manage_course_attendance(sem_course_id):
    """Manage attendance for students (update present count)"""

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

    # Get total lectures for this course
    cursor.execute("""
    SELECT COALESCE(COUNT(DISTINCT att_date), 0) as total_lectures
    FROM attendance a
    JOIN registration r ON a.registration_id = r.registration_id
    WHERE r.sem_course_id = :cid
    """, {"cid": sem_course_id})
    
    total_lectures = cursor.fetchone()[0]

    if total_lectures == 0:
        cursor.close()
        conn.close()
        return render_template(
            "faculty_no_lectures_set.html",
            course=course,
            sem_course_id=sem_course_id
        )

    if request.method == "GET":
        # Get all active students with their current attendance
        cursor.execute("""
        SELECT
        r.registration_id,
        s.student_id,
        s.full_name,
        s.email,
        SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) as present_count
        FROM registration r
        JOIN students s ON r.student_id = s.student_id
        LEFT JOIN attendance a ON r.registration_id = a.registration_id
        WHERE r.sem_course_id = :cid AND r.status = 'Active'
        GROUP BY r.registration_id, s.student_id, s.full_name, s.email
        ORDER BY s.full_name
        """, {"cid": sem_course_id})

        students = cursor.fetchall()
        cursor.close()
        conn.close()

        return render_template(
            "faculty_attendance_mark.html",
            course=course,
            students=students,
            sem_course_id=sem_course_id,
            total_lectures=total_lectures
        )

    elif request.method == "POST":
        success_count = 0

        # Get all active students in this course
        cursor.execute("""
        SELECT r.registration_id, s.student_id
        FROM registration r
        JOIN students s ON r.student_id = s.student_id
        WHERE r.sem_course_id = :cid AND r.status = 'Active'
        """, {"cid": sem_course_id})

        registrations = cursor.fetchall()

        for reg in registrations:
            registration_id = reg[0]
            
            # Get present count for this student from form
            present_count_key = f"present_{registration_id}"
            present_count = request.form.get(present_count_key, 0)
            
            try:
                present_count = int(present_count)
            except:
                continue

            if present_count > total_lectures or present_count < 0:
                continue

            # Update attendance records
            # First, set all to Absent
            cursor.execute("""
                UPDATE attendance
                SET status = 'Absent'
                WHERE registration_id = :rid
            """, {"rid": registration_id})

            # Then, update first N records to Present
            if present_count > 0:
                cursor.execute("""
                    UPDATE attendance
                    SET status = 'Present'
                    WHERE registration_id = :rid
                    AND rownum <= :count
                """, {"rid": registration_id, "count": present_count})

            success_count += 1

        conn.commit()
        cursor.close()
        conn.close()

        return render_template(
            "faculty_attendance_success.html",
            course=course,
            sem_course_id=sem_course_id,
            total_lectures=total_lectures,
            success_count=success_count
        )

@faculty_bp.route("/faculty/attendance/<registration_id>", methods=["GET", "POST"])
def manage_attendance(registration_id):

    if session.get("role") != "faculty":
        return "Unauthorized", 403

    faculty_id = session["faculty_id"]

    if request.method == "GET":
        # Show attendance form
        conn = get_connection()
        cursor = conn.cursor()

        # Get student and course info
        cursor.execute("""
        SELECT 
            s.student_id,
            s.full_name,
            c.course_code,
            c.course_name,
            r.registration_id,
            COALESCE(att.total_lectures, 0) as total_lectures,
            COALESCE(att.present_count, 0) as present_count
        FROM registration r
        JOIN students s ON r.student_id = s.student_id
        JOIN semester_courses sc ON r.sem_course_id = sc.sem_course_id
        JOIN courses c ON sc.course_id = c.course_id
        LEFT JOIN (
            SELECT registration_id, COUNT(*) as total_lectures, 
                    SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as present_count
            FROM attendance
            GROUP BY registration_id
        ) att ON r.registration_id = att.registration_id
        WHERE r.registration_id = :rid AND sc.faculty_id = :fid
        """, {"rid": registration_id, "fid": faculty_id})

        attendance_info = cursor.fetchone()
        cursor.close()
        conn.close()

        if not attendance_info:
            return "Unauthorized", 403

        return render_template(
            "faculty_attendance.html",
            attendance_info=attendance_info,
            registration_id=registration_id
        )

    elif request.method == "POST":
        # Save attendance
        total_lectures = request.form.get("total_lectures", 0)
        present_count = request.form.get("present_count", 0)

        try:
            total_lectures = int(total_lectures)
            present_count = int(present_count)
        except:
            return "Invalid input", 400

        if present_count > total_lectures:
            return "Present count cannot be greater than total lectures", 400

        conn = get_connection()
        cursor = conn.cursor()

        # Delete old attendance records for this registration
        cursor.execute("""
            DELETE FROM attendance
            WHERE registration_id = :rid
        """, {"rid": registration_id})

        # Insert new attendance records
        for i in range(total_lectures):
            status = "Present" if i < present_count else "Absent"
            cursor.execute("""
                INSERT INTO attendance
                (registration_id, att_date, status, marked_by)
                VALUES (:rid, SYSDATE - :day, :status, :fid)
            """, {
                "rid": registration_id,
                "day": total_lectures - i,
                "status": status,
                "fid": faculty_id
            })

        conn.commit()
        cursor.close()
        conn.close()

        return redirect(f"/faculty/course/{request.form.get('sem_course_id')}")


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