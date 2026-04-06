from flask import Flask, request, redirect, session, render_template
import config
from db import get_connection

from routes.student_routes import student_bp
from routes.faculty_routes import faculty_bp
from routes.advisor_routes import advisor_bp
from routes.admin_routes import admin_bp


# Create Flask app first
app = Flask(__name__)
app.secret_key = config.SECRET_KEY


# HOME ROUTE - Shows enrollment page
@app.route("/", methods=["GET"])
def home():
    """Home page - shows enrollment form"""
    conn = get_connection()
    cursor = conn.cursor()
    
    # Get all departments
    cursor.execute("SELECT department_id, department_name FROM departments ORDER BY department_name")
    departments = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template("admin_enroll.html", departments=departments)


# LOGIN ROUTE - UNIFIED FOR ALL ROLES
@app.route("/login", methods=["GET", "POST"])
def login():
    
    if request.method == "GET":
        return render_template("login.html")
    
    role = request.form.get("role", "").lower()
    user_id = request.form.get("user_id", "").strip()
    password = request.form.get("password", "").strip()
    session_type = request.form.get("session")
    year = request.form.get("year")

    conn = get_connection()
    cursor = conn.cursor()

    try:
        # STUDENT LOGIN
        if role == "student":
            cursor.execute("""
            SELECT student_id
            FROM students
            WHERE student_id=:id
            AND password_hash=:pw
            """, {"id": user_id, "pw": password})

            user = cursor.fetchone()

            if user:
                session["student_id"] = user_id
                session["session_type"] = session_type
                session["year"] = year
                session["role"] = "student"
                cursor.close()
                conn.close()
                return redirect("/student/dashboard")
            else:
                cursor.close()
                conn.close()
                return render_template("login.html", error="Invalid Student ID or Password")

        # FACULTY LOGIN
        elif role == "faculty":
            cursor.execute("""
            SELECT faculty_id
            FROM faculties
            WHERE faculty_id=:id
            AND password_hash=:pw
            AND is_advisor=0
            """, {"id": user_id, "pw": password})

            user = cursor.fetchone()

            if user:
                session["faculty_id"] = user_id
                session["role"] = "faculty"
                cursor.close()
                conn.close()
                return redirect("/faculty/dashboard")
            else:
                cursor.close()
                conn.close()
                return render_template("login.html", error="Invalid Faculty ID or Password")

        # ADVISOR LOGIN
        elif role == "advisor":
            cursor.execute("""
            SELECT faculty_id
            FROM faculties
            WHERE faculty_id=:id
            AND password_hash=:pw
            AND is_advisor=1
            """, {"id": user_id, "pw": password})

            user = cursor.fetchone()

            if user:
                session["advisor_id"] = user_id
                session["role"] = "advisor"
                cursor.close()
                conn.close()
                return redirect("/advisor/dashboard")
            else:
                cursor.close()
                conn.close()
                return render_template("login.html", error="Invalid Advisor ID or Password")

        # ADMIN LOGIN
        elif role == "admin":
            if user_id == "admin" and password == "admin123":
                session["role"] = "admin"
                cursor.close()
                conn.close()
                return redirect("/admin/assign-advisor")
            else:
                cursor.close()
                conn.close()
                return render_template("login.html", error="Invalid Admin Credentials")
        
        else:
            cursor.close()
            conn.close()
            return render_template("login.html", error="Please select a valid role")

    except Exception as e:
        cursor.close()
        conn.close()
        return render_template("login.html", error=f"Login error: {str(e)}")


# LOGOUT
@app.route("/logout")
def logout():
    session.clear()
    return redirect("/")


# Register blueprints
app.register_blueprint(student_bp)
app.register_blueprint(faculty_bp)
app.register_blueprint(advisor_bp)
app.register_blueprint(admin_bp)


if __name__ == "__main__":
    app.run(debug=True)