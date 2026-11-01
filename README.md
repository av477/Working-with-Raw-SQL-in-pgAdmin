# FastAPI Calculator

A small Python calculator application with a browser-based interface and a JSON API. It supports addition, subtraction, multiplication, and division.

## Features

- Calculator interface served at `/`
- FastAPI endpoints for the four arithmetic operations
- Division-by-zero and request-validation error handling
- Unit, integration, and Playwright end-to-end tests

## Requirements

- Python 3.10 or later
- pip
- For end-to-end tests: Chromium, installed through Playwright
- Optional: Docker

## Run locally

Clone the repository and enter its directory:

```bash
git clone https://github.com/av477/Working-with-Raw-SQL-in-pgAdmin.git
cd Working-with-Raw-SQL-in-pgAdmin
```

Create and activate a virtual environment:

```bash
python -m venv .venv
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

macOS/Linux:

```bash
source .venv/bin/activate
```

Install dependencies and start the application:

```bash
python -m pip install -r requirements.txt
python main.py
```

Open [http://127.0.0.1:8000](http://127.0.0.1:8000) in a browser. The interactive API documentation is available at [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs).

## API

Each operation accepts a JSON object with numeric `a` and `b` values and returns a JSON object containing `result`.

| Method | Endpoint | Operation |
| --- | --- | --- |
| `POST` | `/add` | `a + b` |
| `POST` | `/subtract` | `a - b` |
| `POST` | `/multiply` | `a * b` |
| `POST` | `/divide` | `a / b` |

Example:

```bash
curl -X POST http://127.0.0.1:8000/add \
  -H "Content-Type: application/json" \
  -d "{\"a\": 10, \"b\": 5}"
```

Response:

```json
{"result": 15.0}
```

Invalid input and division by zero return an error response with an `error` field.

## Tests

Run unit and API integration tests:

```bash
python -m pytest tests/unit tests/integration
```

To run the end-to-end browser tests, install the Playwright Chromium browser first:

```bash
python -m playwright install chromium
python -m pytest tests/e2e
```

Run the complete test suite with:

```bash
python -m pytest
```

## PostgreSQL and pgAdmin (Docker Compose)

The Compose stack starts the FastAPI app, PostgreSQL 18, and pgAdmin. Start all three services from the repository root:

```console
docker compose up --build -d
```

Check service status and logs:

```console
docker compose ps
docker compose logs -f db
```

Open the application at [http://localhost:8000](http://localhost:8000) and pgAdmin at [http://localhost:5050](http://localhost:5050).

### Connect pgAdmin to PostgreSQL

Sign in to pgAdmin with the configured default account:

| Setting | Value |
| --- | --- |
| Email | `admin@example.com` |
| Password | `admin` |

In pgAdmin, right-click **Servers** and select **Register > Server**. Enter a name on the **General** tab, then use these values on the **Connection** tab:

| Field | Value |
| --- | --- |
| Host name/address | `db` |
| Port | `5432` |
| Maintenance database | `fastapi_db` |
| Username | `postgres` |
| Password | `postgres` |

Leave the **Parameters** tab at its defaults. The hostname `db` is the Compose service name and works from pgAdmin inside the Compose network. If connecting from a database client installed on your computer, use `localhost` as the host instead.

The database is also available on `localhost:5432` from the host machine. Compose persists database files in the `postgres_data` named volume; `docker compose down` stops and removes the containers but preserves that data.

### Run the SQL setup and CRUD examples

The project includes [`sql/database_setup_and_crud.sql`](./sql/database_setup_and_crud.sql). It creates the `users` and `calculations` tables, seeds example rows, runs SELECT queries including a join, updates Alice's addition result, and deletes Alice's division row. The `calculations.user_id` foreign key demonstrates the one-to-many relationship and cascades calculation deletion when a user is deleted.

Run the complete script from PowerShell while the Compose database is running:

```powershell
Get-Content .\sql\database_setup_and_crud.sql -Raw | docker compose exec -T db psql -U postgres -d fastapi_db
```

Alternatively, open the SQL file in pgAdmin's Query Tool after connecting to `fastapi_db`, then execute it. The script uses `IF NOT EXISTS` and skips duplicate seed rows, so it can be rerun. Review the result sets in pgAdmin's **Data Output** panel; the final query shows the rows remaining after the update and delete.

Stop the stack with:

```console
docker compose down
```

The Compose file supplies `DATABASE_URL` to the app container, but the calculator currently does not read from or write to PostgreSQL; the SQL examples are run directly against the database. These default credentials are for local development only; change them before using the stack in a shared or production environment.

### Build and run the application image alone

To run only the app without PostgreSQL or pgAdmin:

```console
docker build -t fastapi-calculator .
docker run --rm -p 8000:8000 fastapi-calculator
```

Then open [http://localhost:8000](http://localhost:8000). The runtime image excludes pip and the host virtual environment; dependencies are installed during the image build. The container health check requests the homepage using Python's standard library.
