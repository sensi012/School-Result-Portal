import os
import psycopg2
from psycopg2 import pool
from flask import Flask, render_template, request, flash
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from werkzeug.security import check_password_hash
from datetime import datetime, timezone

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'dev-key-change-in-prod')

# Initialize Rate Limiter (5 requests per minute for result checks)
limiter = Limiter(
    get_remote_address,
    app=app,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://"
)

# Database configuration from environment
DB_HOST_RAW = os.environ.get('DB_HOST', 'localhost')
if ':' in DB_HOST_RAW:
    DB_HOST = DB_HOST_RAW.split(':')[0]
    DB_PORT = DB_HOST_RAW.split(':')[1]
else:
    DB_HOST = DB_HOST_RAW
    DB_PORT = os.environ.get('DB_PORT', '5432')

DB_NAME = os.environ.get('DB_NAME', 'school_db')
DB_USER = os.environ.get('DB_USER', 'admin')
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'password')

# Database Connection Pool (min 1, max 20 connections)
db_pool = None

def check_and_seed_db(conn):
    try:
        cur = conn.cursor()
        cur.execute("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'students');")
        exists = cur.fetchone()[0]
        if not exists:
            app.logger.info("Initializing RDS database tables and seeding student records...")
            init_sql_path = os.path.join(os.path.dirname(__file__), 'init.sql')
            if os.path.exists(init_sql_path):
                with open(init_sql_path, 'r', encoding='utf-8') as f:
                    cur.execute(f.read())
                conn.commit()
                app.logger.info("RDS Database seeding complete!")
        cur.close()
    except Exception as e:
        app.logger.error(f"Error checking/seeding database: {str(e)}")

def init_db_pool():
    global db_pool
    if db_pool is None:
        try:
            db_pool = psycopg2.pool.ThreadedConnectionPool(
                minconn=1,
                maxconn=20,
                host=DB_HOST,
                database=DB_NAME,
                user=DB_USER,
                password=DB_PASSWORD,
                port=DB_PORT,
                connect_timeout=10
            )
            app.logger.info("Database connection pool initialized.")
            # Seed DB tables if empty
            conn = db_pool.getconn()
            check_and_seed_db(conn)
            db_pool.putconn(conn)
        except Exception as e:
            app.logger.error(f"Failed to initialize database pool: {str(e)}")

def get_db_connection():
    if db_pool is None:
        init_db_pool()
    if db_pool:
        return db_pool.getconn()
    # Fallback to direct connection if pool fails
    return psycopg2.connect(
        host=DB_HOST, database=DB_NAME, user=DB_USER,
        password=DB_PASSWORD, port=DB_PORT, connect_timeout=10
    )

def release_db_connection(conn):
    if conn:
        if db_pool:
            db_pool.putconn(conn)
        else:
            conn.close()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/check-result', methods=['POST'])
@limiter.limit("5 per minute")
def check_result():
    matric_number = request.form.get('matric_number', '').strip().upper()
    pin = request.form.get('pin', '').strip()
    
    if not matric_number or not pin:
        flash('Please enter both Matric Number and PIN.', 'error')
        return render_template('index.html')
    
    conn = None
    cur = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Query student results summary
        cur.execute("""
            SELECT s.student_name, s.class, s.stream, r.term, r.session, 
                   r.grade, r.teacher_remark, r.access_pin
            FROM results r
            JOIN students s ON r.matric_number = s.matric_number
            WHERE r.matric_number = %s
        """, (matric_number,))
        
        result = cur.fetchone()
        
        if result:
            stored_pin = result[7]
            # Support both hashed PINs and legacy plaintext PINs
            pin_valid = False
            if stored_pin.startswith('pbkdf2:') or stored_pin.startswith('scrypt:') or stored_pin.startswith('argon2:'):
                pin_valid = check_password_hash(stored_pin, pin)
            else:
                pin_valid = (stored_pin == pin)
                
            if pin_valid:
                student_class = result[1]
                student_stream = result[2]
                term = result[3]
                session = result[4]
                
                # Query dynamic subject scores for the student
                cur.execute("""
                    SELECT sub.subject_name, sc.score
                    FROM student_scores sc
                    JOIN subjects sub ON sc.subject_id = sub.subject_id
                    WHERE sc.matric_number = %s AND sc.term = %s AND sc.session = %s
                    ORDER BY sub.subject_name ASC
                """, (matric_number, term, session))
                
                score_rows = cur.fetchall()
                subject_scores = [{'subject_name': row[0], 'score': row[1]} for row in score_rows]
                
                # Calculate percentage score
                if subject_scores:
                    percentage = round(sum(s['score'] for s in subject_scores) / len(subject_scores), 1)
                else:
                    percentage = 0.0
                    
                # Calculate Position in Class (across the whole class level, e.g. SS1)
                cur.execute("""
                    WITH class_averages AS (
                        SELECT s.matric_number,
                               AVG(sc.score) as avg_score,
                               RANK() OVER (ORDER BY AVG(sc.score) DESC) as class_rank
                        FROM students s
                        JOIN student_scores sc ON s.matric_number = sc.matric_number
                        WHERE s.class = %s AND sc.term = %s AND sc.session = %s
                        GROUP BY s.matric_number
                    )
                    SELECT class_rank, (SELECT COUNT(*) FROM class_averages) as total_students
                    FROM class_averages
                    WHERE matric_number = %s
                """, (student_class, term, session, matric_number))
                
                rank_row = cur.fetchone()
                if rank_row:
                    rank_pos = rank_row[0]
                    total_students = rank_row[1]
                    suffix = 'th' if 11 <= rank_pos % 100 <= 13 else {1: 'st', 2: 'nd', 3: 'rd'}.get(rank_pos % 10, 'th')
                    position_display = f"{rank_pos}{suffix} out of {total_students}"
                else:
                    position_display = "N/A"
                
                # Format class display (e.g. "SS3 (Science)" or "JSS1")
                class_display = f"{student_class} ({student_stream})" if student_stream and student_stream != 'Junior Secondary' else student_class
                
                result_data = {
                    'student_name': result[0],
                    'class': class_display,
                    'term': term,
                    'session': session,
                    'grade': result[5],
                    'remark': result[6],
                    'percentage': f"{percentage}%",
                    'position': position_display,
                    'subject_scores': subject_scores
                }
                return render_template('result.html', result=result_data)
        
        flash('Invalid Matric Number or PIN. Please check and try again.', 'error')
        return render_template('index.html')
            
    except Exception as e:
        app.logger.error(f"Database error: {str(e)}")
        flash('Unable to retrieve results at this time. Please try again later.', 'error')
        return render_template('index.html')
    finally:
        if cur:
            cur.close()
        release_db_connection(conn)

@app.route('/health')
def health():
    return {'status': 'healthy', 'timestamp': datetime.now(timezone.utc).isoformat()}, 200

if __name__ == '__main__':
    init_db_pool()
    app.run(host='0.0.0.0', port=5000)