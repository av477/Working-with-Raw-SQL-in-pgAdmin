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

## Docker

Build and run the application image:

```bash
docker build -t fastapi-calculator .
docker run --rm -p 8000:8000 fastapi-calculator
```

Then open [http://localhost:8000](http://localhost:8000). The container health check requests the homepage using Python's standard library.
