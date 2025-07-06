from locust import HttpUser, task, between
import random
from datetime import datetime, timedelta

# --- Configuration ---
MAX_SENSOR_ID = 20000

def skewed_sensor_id():
    # Heavy skew toward low IDs (Zipf-like)
    return int(MAX_SENSOR_ID / (random.random() * 100 + 1))

def bursty_timestamp():
    skew = pow(random.random(), 3.5)  # heavier toward recent
    days_offset = int(skew * 5 * 365)
    dt = datetime.now() - timedelta(days=days_offset)
    return dt.isoformat()

# -------------------
# INSERT PING USER
# -------------------
class InsertPingUser(HttpUser):
    wait_time = between(0.05, 0.3)

    @task("Insert ping")
    def insert_ping(self):
        payload = {
            "sensor_id": skewed_sensor_id(),
            "response_time": round(random.uniform(0, 100), 2),
            "result": "success" if random.random() < 0.9 else "fail",
            "created_at": bursty_timestamp()
        }
        self.client.post("/api/v1/pings", json=payload)

# -------------------
# FAILURE RATE QUERY
# -------------------
class FailureRateUser(HttpUser):
    wait_time = between(0.3, 1.5)

    @task("Get failure rate")
    def get_failure_rate(self):
        sensor_id = skewed_sensor_id()
        self.client.get(f"/api/v1/sensors/{sensor_id}/failure_rate")

# -------------------
# RECENT FAILURES
# -------------------
class RecentFailuresUser(HttpUser):
    wait_time = between(0.2, 1.0)

    @task("Get recent failures")
    def get_recent_failures(self):
        sensor_id = skewed_sensor_id()
        self.client.get(f"/api/v1/sensors/{sensor_id}/recent_failures")

# -------------------
# TIME SERIES STATS
# -------------------
class TimeSeriesUser(HttpUser):
    wait_time = between(1.0, 2.5)

    @task("Get hourly stats")
    def hourly_stats(self):
        sensor_id = skewed_sensor_id()
        self.client.get(f"/api/v1/sensors/{sensor_id}/stats/hourly")

# -------------------
# SENSOR DETAIL VIEW
# -------------------
class SensorDetailUser(HttpUser):
    wait_time = between(0.8, 2.0)

    @task("Get sensor detail")
    def sensor_detail(self):
        sensor_id = skewed_sensor_id()
        self.client.get(f"/api/v1/sensors/{sensor_id}/detail")

# -------------------
# RANDOM / ERROR TRAFFIC
# -------------------
class RandomNoiseUser(HttpUser):
    wait_time = between(1.0, 3.0)

    @task("Random 404s and noise")
    def send_noise(self):
        paths = [
            "/api/v1/sensors/9999999/failure_rate",
            "/api/v1/unknown",
            "/api/v1/pings?sensor_id=abc",
            "/api/v1/sensors//stats/hourly"
        ]
        self.client.get(random.choice(paths))


