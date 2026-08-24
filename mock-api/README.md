# Excelerate Mock REST API

Powered by **json-server**. Simulates production-grade REST endpoints for user authentication, program cataloging, enrollments, and user feedback.

## Requirements
* [Node.js](https://nodejs.org/) (v16+ recommended)

## Installation & Startup
1. Open a terminal and navigate to this folder:
   ```bash
   cd mock-api
   npm install
   npm start
   ```

The API starts at `http://localhost:3000`.

## App connection

- Flutter web and iOS Simulator use `http://localhost:3000`.
- Android Emulator uses `http://10.0.2.2:3000` automatically.
- Sign in with `demo@excelerate.org` and `Demo1234`.

## Endpoints

- `GET /programs` — program catalogue
- `GET /users?email=<email>` and `POST /users` — mock authentication
- `GET` / `POST /enrollments` — enrollment records
- `GET` / `POST /feedback` — feedback records

`json-server` writes registrations, enrollments, and feedback back to `db.json` while it is running.
