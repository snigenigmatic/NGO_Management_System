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
Setup
```bash
uv venv; .\.venv\bin\activate
cd api
uv pip install -r requirements.txt
copy .env.example .env  # then edit DB_USER/DB_PASSWORD if needed
```

Run
```bash
uv run uvicorn main:app --reload --host 127.0.0.1 --port 8000
```
Open http://localhost:5000 and use the navbar. The pages map to rubric items below.

Run the frontend:
```bash
cd ./frontend
npm install
npm run dev
```
