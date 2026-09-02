from flask import Flask, jsonify, request
import sqlite3
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "clientsphere.db"

app = Flask(__name__)


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    conn = get_db()

    conn.executescript("""
    CREATE TABLE IF NOT EXISTS leads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        company TEXT,
        status TEXT NOT NULL DEFAULT 'new',
        source TEXT,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        company TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        health TEXT DEFAULT 'good',
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS deals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        customer_id INTEGER,
        value REAL NOT NULL DEFAULT 0,
        stage TEXT NOT NULL DEFAULT 'prospecting',
        close_date TEXT,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority TEXT NOT NULL DEFAULT 'medium',
        status TEXT NOT NULL DEFAULT 'pending',
        customer_id INTEGER,
        deal_id INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        subject TEXT NOT NULL,
        description TEXT,
        customer_id INTEGER,
        deal_id INTEGER,
        activity_at TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT DEFAULT 'info',
        read INTEGER NOT NULL DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS profile (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT,
        email TEXT,
        phone TEXT,
        role TEXT,
        quota REAL DEFAULT 0,
        achieved REAL DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        company_name TEXT DEFAULT 'ClientSphere',
        theme TEXT DEFAULT 'system',
        notifications_enabled INTEGER NOT NULL DEFAULT 1
    );
    """)

    conn.execute("""
        INSERT OR IGNORE INTO profile
        (id, name, email, phone, role, quota, achieved)
        VALUES (1, 'ClientSphere User', '', '', 'Sales Representative', 0, 0)
    """)

    conn.execute("""
        INSERT OR IGNORE INTO settings
        (id, company_name, theme, notifications_enabled)
        VALUES (1, 'ClientSphere', 'system', 1)
    """)

    conn.commit()
    conn.close()


def rows_to_dict(rows):
    return [dict(row) for row in rows]


@app.get("/api/health")
def health():
    return jsonify({"status": "ok", "service": "ClientSphere Backend"})


def register_crud(resource, table, fields):
    @app.get(f"/api/{resource}", endpoint=f"{resource}_list")
    def list_items():
        conn = get_db()
        rows = conn.execute(f"SELECT * FROM {table} ORDER BY id DESC").fetchall()
        conn.close()
        return jsonify(rows_to_dict(rows))

    @app.get(f"/api/{resource}/<int:item_id>", endpoint=f"{resource}_get")
    def get_item(item_id):
        conn = get_db()
        row = conn.execute(
            f"SELECT * FROM {table} WHERE id = ?",
            (item_id,)
        ).fetchone()
        conn.close()

        if row is None:
            return jsonify({"error": f"{resource[:-1].capitalize()} not found"}), 404

        return jsonify(dict(row))

    @app.post(f"/api/{resource}", endpoint=f"{resource}_create")
    def create_item():
        data = request.get_json(silent=True) or {}

        missing = [
            field for field in fields
            if field in ("name", "title", "subject") and not data.get(field)
        ]

        if missing:
            return jsonify({"error": "Required field missing", "fields": missing}), 400

        columns = [field for field in fields if field in data]
        values = [data[field] for field in columns]

        if not columns:
            return jsonify({"error": "No valid fields supplied"}), 400

        placeholders = ", ".join(["?"] * len(columns))
        column_sql = ", ".join(columns)

        conn = get_db()
        cursor = conn.execute(
            f"INSERT INTO {table} ({column_sql}) VALUES ({placeholders})",
            values
        )
        conn.commit()

        row = conn.execute(
            f"SELECT * FROM {table} WHERE id = ?",
            (cursor.lastrowid,)
        ).fetchone()

        conn.close()
        return jsonify(dict(row)), 201

    @app.put(f"/api/{resource}/<int:item_id>", endpoint=f"{resource}_update")
    def update_item(item_id):
        data = request.get_json(silent=True) or {}
        columns = [field for field in fields if field in data]

        if not columns:
            return jsonify({"error": "No valid fields supplied"}), 400

        set_sql = ", ".join([f"{field} = ?" for field in columns])
        values = [data[field] for field in columns]
        values.append(item_id)

        conn = get_db()

        existing = conn.execute(
            f"SELECT id FROM {table} WHERE id = ?",
            (item_id,)
        ).fetchone()

        if existing is None:
            conn.close()
            return jsonify({"error": "Resource not found"}), 404

        conn.execute(
            f"UPDATE {table} SET {set_sql} WHERE id = ?",
            values
        )
        conn.commit()

        row = conn.execute(
            f"SELECT * FROM {table} WHERE id = ?",
            (item_id,)
        ).fetchone()

        conn.close()
        return jsonify(dict(row))

    @app.delete(f"/api/{resource}/<int:item_id>", endpoint=f"{resource}_delete")
    def delete_item(item_id):
        conn = get_db()

        cursor = conn.execute(
            f"DELETE FROM {table} WHERE id = ?",
            (item_id,)
        )
        conn.commit()
        conn.close()

        if cursor.rowcount == 0:
            return jsonify({"error": "Resource not found"}), 404

        return jsonify({"message": "Deleted successfully"})


register_crud(
    "leads",
    "leads",
    ["name", "email", "phone", "company", "status", "source", "notes"]
)

register_crud(
    "customers",
    "customers",
    ["name", "email", "phone", "company", "status", "health", "notes"]
)

register_crud(
    "deals",
    "deals",
    ["title", "customer_id", "value", "stage", "close_date", "notes"]
)

register_crud(
    "tasks",
    "tasks",
    ["title", "description", "due_date", "priority", "status", "customer_id", "deal_id"]
)

register_crud(
    "activities",
    "activities",
    ["type", "subject", "description", "customer_id", "deal_id", "activity_at"]
)


@app.get("/api/notifications")
def get_notifications():
    conn = get_db()
    rows = conn.execute(
        "SELECT * FROM notifications ORDER BY id DESC"
    ).fetchall()
    conn.close()
    return jsonify(rows_to_dict(rows))


@app.patch("/api/notifications/<int:item_id>/read")
def mark_notification_read(item_id):
    conn = get_db()
    cursor = conn.execute(
        "UPDATE notifications SET read = 1 WHERE id = ?",
        (item_id,)
    )
    conn.commit()
    conn.close()

    if cursor.rowcount == 0:
        return jsonify({"error": "Notification not found"}), 404

    return jsonify({"message": "Notification marked as read"})


@app.get("/api/profile")
def get_profile():
    conn = get_db()
    row = conn.execute(
        "SELECT * FROM profile WHERE id = 1"
    ).fetchone()
    conn.close()
    return jsonify(dict(row))


@app.put("/api/profile")
def update_profile():
    data = request.get_json(silent=True) or {}

    allowed = ["name", "email", "phone", "role", "quota", "achieved"]
    fields = [field for field in allowed if field in data]

    if not fields:
        return jsonify({"error": "No valid fields supplied"}), 400

    set_sql = ", ".join([f"{field} = ?" for field in fields])
    values = [data[field] for field in fields]

    conn = get_db()
    conn.execute(
        f"UPDATE profile SET {set_sql} WHERE id = 1",
        values
    )
    conn.commit()

    row = conn.execute(
        "SELECT * FROM profile WHERE id = 1"
    ).fetchone()

    conn.close()
    return jsonify(dict(row))


@app.get("/api/settings")
def get_settings():
    conn = get_db()
    row = conn.execute(
        "SELECT * FROM settings WHERE id = 1"
    ).fetchone()
    conn.close()
    return jsonify(dict(row))


@app.put("/api/settings")
def update_settings():
    data = request.get_json(silent=True) or {}

    allowed = ["company_name", "theme", "notifications_enabled"]
    fields = [field for field in allowed if field in data]

    if not fields:
        return jsonify({"error": "No valid fields supplied"}), 400

    set_sql = ", ".join([f"{field} = ?" for field in fields])
    values = [data[field] for field in fields]

    conn = get_db()
    conn.execute(
        f"UPDATE settings SET {set_sql} WHERE id = 1",
        values
    )
    conn.commit()

    row = conn.execute(
        "SELECT * FROM settings WHERE id = 1"
    ).fetchone()

    conn.close()
    return jsonify(dict(row))


@app.get("/api/dashboard")
def dashboard():
    conn = get_db()

    leads = conn.execute("SELECT COUNT(*) FROM leads").fetchone()[0]
    customers = conn.execute("SELECT COUNT(*) FROM customers").fetchone()[0]
    deals = conn.execute("SELECT COUNT(*) FROM deals").fetchone()[0]
    tasks = conn.execute(
        "SELECT COUNT(*) FROM tasks WHERE status != 'completed'"
    ).fetchone()[0]

    pipeline = conn.execute(
        "SELECT COALESCE(SUM(value), 0) FROM deals "
        "WHERE stage NOT IN ('won', 'lost')"
    ).fetchone()[0]

    won_revenue = conn.execute(
        "SELECT COALESCE(SUM(value), 0) FROM deals WHERE stage = 'won'"
    ).fetchone()[0]

    conn.close()

    return jsonify({
        "leads": leads,
        "customers": customers,
        "deals": deals,
        "open_tasks": tasks,
        "pipeline_value": pipeline,
        "won_revenue": won_revenue
    })


@app.get("/api/search")
def global_search():
    query = request.args.get("q", "").strip()

    if not query:
        return jsonify({
            "query": "",
            "results": []
        })

    pattern = f"%{query}%"
    conn = get_db()

    results = []

    for row in conn.execute(
        """
        SELECT id, name, email, company, 'lead' AS type
        FROM leads
        WHERE name LIKE ? OR email LIKE ? OR company LIKE ?
        """,
        (pattern, pattern, pattern)
    ).fetchall():
        results.append(dict(row))

    for row in conn.execute(
        """
        SELECT id, name, email, company, 'customer' AS type
        FROM customers
        WHERE name LIKE ? OR email LIKE ? OR company LIKE ?
        """,
        (pattern, pattern, pattern)
    ).fetchall():
        results.append(dict(row))

    for row in conn.execute(
        """
        SELECT id, title AS name, notes AS email, '' AS company, 'deal' AS type
        FROM deals
        WHERE title LIKE ? OR notes LIKE ?
        """,
        (pattern, pattern)
    ).fetchall():
        results.append(dict(row))

    conn.close()

    return jsonify({
        "query": query,
        "results": results
    })


init_db()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

