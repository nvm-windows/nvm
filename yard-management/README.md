# Yard Management (React + Node)

## Overview

Simple yard and container management project with:
- user login (token-based)
- container creation and movement
- container search by tag/location
- yard location occupancy tracking
- dashboard analytics (total containers, empty slots)

## Project structure

- `backend/` - Express API server
- `frontend/` - Vite + React app

## Setup

### Backend

```
cd yard-management/backend
npm install
npm start
```

Runs on http://localhost:4000

### Frontend

```
cd yard-management/frontend
npm install
npm run dev
```

Runs on http://localhost:5173 by default.

## API endpoints

- `POST /api/auth/login` { username, password }
- `GET /api/containers`
- `POST /api/containers` { tag, type, locationId }
- `PUT /api/containers/:id/move` { locationId }
- `GET /api/containers/search?q=...`
- `GET /api/yard/summary`
- `GET /api/yard/slots`

## Notes

Default valid user:
- username: `admin`
- password: `admin`
