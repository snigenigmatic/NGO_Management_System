# NGO Management System 

1. Start your MySQL server and connect as a user with privileges to create databases/tables.

2. From the MySQL shell or a client that supports `SOURCE` run `tests.sql`:

```sql
SOURCE /absolute/path/to/ddl_fixed.sql;
SOURCE /absolute/path/to/insert_data_fixed.sql;
SOURCE /absolute/path/to/procedures_triggers.sql;
SOURCE /absolute/path/to/views.sql;
-- or simply
SOURCE /absolute/path/to/tests.sql;
```

SQL File run order:
```sql
-- 1. Schema (tables, constraints)
SOURCE C:/Users/datta/Documents/SEM5/DBMS/NGO_Management_System/sql/ddl_fixed.sql;

-- 2. Stored procedures & triggers
SOURCE C:/Users/datta/Documents/SEM5/DBMS/NGO_Management_System/sql/procedures_triggers.sql;

-- 3. Views used by the app
SOURCE C:/Users/datta/Documents/SEM5/DBMS/NGO_Management_System/sql/views.sql;

-- 4. Seed base data
SOURCE C:/Users/datta/Documents/SEM5/DBMS/NGO_Management_System/sql/insert_data_fixed_full.sql;

-- 5. Extra data
SOURCE C:/Users/datta/Documents/SEM5/DBMS/NGO_Management_System/sql/insert_additional_data.sql;

-- 6. Some fixes
SOURCE C:/Users/datta/Documents/SEM5/DBMS/NGO_Management_System/sql/update_event_sponsors.sql;
SOURCE C:/Users/datta/Documents/SEM5/DBMS/NGO_Management_System/sql/fix_events_13_14.sql;

-- 7. Fix analytics view (run after data loaded)
SOURCE C:/Users/datta/Documents/SEM5/DBMS/NGO_Management_System/sql/fix_event_roi_view.sql;

-- 8. Cost fixes
SOURCE C:/Users/datta/Documents/SEM5/DBMS/NGO_Management_System/sql/reduce_event1_costs.sql;

-- 9. Demo-only & optional: remove some Event_Vendor rows so we can cleanly show recommendations for vendor 
SOURCE C:/Users/datta/Documents/SEM5/DBMS/NGO_Management_System/sql/remove_some_vendors_for_demo.sql;
```

Setup
```bash
uv venv; source ./.venv/bin/activate (Linux/macOS)
'''or'''
.venv/Scripts/activate (Windows)
------------------------------------------------------
cd api
uv pip install -r requirements.txt
copy .env.example .env  # then edit DB_USER/DB_PASSWORD if needed
```

Run
```bash
uv run uvicorn main:app --reload --host 127.0.0.1 --port 8000
```
Open http://localhost:5000 and use the navbar. 

Run the frontend:
```bash
cd ./frontend
npm install
npm run dev
```

