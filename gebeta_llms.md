### 📄 Gebeta Maps API Reference (`llms.md`)

**1. Introduction**
- **Overview**: Gebeta Maps offers a suite of APIs for location-based services, including geocoding, routing, and optimization.
- **Authentication**: All API requests require an API key, which can be obtained by registering on the [Gebeta Maps Dashboard](https://maps.gebeta.app).

**2. Direction API**
- **Endpoint**: `GET /api/route/direction/`
- **Parameters**:
  - `origin` (string): Latitude and longitude of the starting point (e.g., `9.0225,38.8040`).
  - `destination` (string): Latitude and longitude of the endpoint.
  - `waypoints` (string, optional): Semicolon-separated list of intermediate points.
  - `instruction` (string, optional): Set to `1` to include turn-by-turn instructions.
  - `apiKey` (string): Your API key.
- **Usage Example**:
  ```bash
  curl "https://mapapi.gebeta.app/api/route/direction/?origin=9.0225,38.8040&destination=9.0304,38.7653&apiKey=YOUR_API_KEY"
  ```
- **Sample Response**:
  ```json
  {
    "distance": 5000,
    "duration": 600,
    "geometry": "encoded_polyline",
    "instructions": [
      {"step": 1, "instruction": "Head north on..."},
      {"step": 2, "instruction": "Turn left at..."}
    ]
  }
  ```

**3. Matrix API**
- **Endpoint**: `GET /api/route/matrix/`
- **Parameters**:
  - `json` (string): Array of latitude and longitude pairs (e.g., `[9.0225,38.8040;9.0304,38.7653]`).
  - `apiKey` (string): Your API key.
- **Usage Example**:
  ```bash
  curl "https://mapapi.gebeta.app/api/route/matrix/?json=[9.0225,38.8040;9.0304,38.7653]&apiKey=YOUR_API_KEY"
  ```
- **Sample Response**:
  ```json
  {
    "durations": [[0, 300], [300, 0]],
    "distances": [[0, 2500], [2500, 0]]
  }
  ```

**4. One-to-Many (ONM) API**
- **Endpoint**: `GET /api/route/onm/`
- **Parameters**:
  - `origin` (string): Latitude and longitude of the origin point.
  - `json` (string): Array of destination points.
  - `apiKey` (string): Your API key.
- **Usage Example**:
  ```bash
  curl "https://mapapi.gebeta.app/api/route/onm/?origin=9.0225,38.8040&json=[9.0304,38.7653;9.0400,38.7700]&apiKey=YOUR_API_KEY"
  ```
- **Sample Response**:
  ```json
  {
    "results": [
      {"to": "9.0304,38.7653", "distance": 2600, "duration": 400},
      {"to": "9.0400,38.7700", "distance": 3200, "duration": 500}
    ]
  }
  ```

**5. Route Optimization API**
- **Endpoint**: `GET /api/route/tss/`
- **Parameters**:
  - `json` (string): Array of waypoints.
  - `apiKey` (string): Your API key.
- **Usage Example**:
  ```bash
  curl "https://mapapi.gebeta.app/api/route/tss/?json=[9.0225,38.8040;9.0304,38.7653;9.0400,38.7700]&apiKey=YOUR_API_KEY"
  ```
- **Sample Response**:
  ```json
  {
    "optimized_order": [0, 2, 1],
    "total_distance": 7000,
    "total_duration": 900
  }
  ```

**6. Vehicle Routing Problem (VRP) API**
- **Endpoint**: `POST /api/optimized-trip`
- **Parameters**:
  - `vehicles` (array): List of vehicles with their capacities and current locations.
  - `customers` (array): List of customer locations and demands.
  - `depots` (array): List of depot locations.
  - `apiKey` (string): Your API key.
- **Usage Example**:
  ```bash
  curl -X POST "https://docs.gebeta.app/api/optimized-trip?apiKey=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicles": [{"vehicle_id": 1, "current_location": [9.0225,38.8040], "capacity": 10}],
    "customers": [{"customer_id": 1, "location": [9.0304,38.7653], "demand": 3}],
    "depots": [{"depot_id": 1, "location": [9.0225,38.8040]}]
  }'
  ```
- **Sample Response**:
  ```json
  {
    "routes": [
      {
        "vehicle_id": 1,
        "stops": [
          {"location": [9.0304,38.7653], "arrival_time": "08:30", "departure_time": "08:35"}
        ],
        "total_distance": 3000,
        "total_duration": 500
      }
    ]
  }
  ```

**7. Geocoding API**
- **Forward Geocoding**:
  - **Endpoint**: `GET /api/v1/route/geocoding`
  - **Parameters**:
    - `name` (string): Place name to search for.
    - `apiKey` (string): Your API key.
  - **Usage Example**:
    ```bash
    curl "https://mapapi.gebeta.app/api/v1/route/geocoding?name=bole&apiKey=YOUR_API_KEY"
    ```
  - **Sample Response**:
    ```json
    {
      "results": [
        {
          "name": "Bole",
          "coordinates": [9.0225, 38.8040],
          "type": "neighborhood"
        }
      ]
    }
    ```

- **Reverse Geocoding**:
  - **Endpoint**: `GET /api/v1/route/revgeocoding`
  - **Parameters**:
    - `location` (string): Latitude and longitude coordinates.
    - `apiKey` (string): Your API key.
  - **Usage Example**:
    ```bash
    curl "https://mapapi.gebeta.app/api/v1/route/revgeocoding?location=9.0225,38.8040&apiKey=YOUR_API_KEY"
    ```
  - **Sample Response**:
    ```json
    {
      "name": "Bole",
      "admin": "Addis Ababa",
      "type": "neighborhood"
    }
    ```

**8. API Limits and Restrictions**
- **Rate Limit**: 50 requests per second per API token.
- **Waypoints Limit**: Maximum of 10 waypoints per request.

