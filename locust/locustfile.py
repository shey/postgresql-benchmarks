from locust import HttpUser, task, between
import random

# --- Config ---
MAX_SENSOR_ID = 5000

def uniform_sensor_id():
    return random.randint(1, MAX_SENSOR_ID)

def skewed_sensor_id():
    return int(MAX_SENSOR_ID / (random.random() * 100 + 1))

def cold_sensor_id():
    return int(MAX_SENSOR_ID - (MAX_SENSOR_ID / (random.random() * 100 + 1)))

# -------------------
# INSERT PINGS
# -------------------
class InsertPingUser(HttpUser):
    wait_time = between(0.05, 0.3)

    @task(3)
    def insert_ping(self):
        payload = {
            "ping": {
                "sensor_id": skewed_sensor_id(),
                "response_time": round(random.uniform(0, 100), 2),
                "status_code": 200 if random.random() < 0.9 else 500
            }
        }
        self.client.post("/pings", json=payload, name="/pings")

# -------------------
# DASHBOARD FAILURE RATE
# -------------------
class FailureRateUser(HttpUser):
    wait_time = between(0.3, 1.5)

    @task(2)
    def get_failure_rate(self):
        sensor_id = skewed_sensor_id()
        self.client.get(
            f"/sensors/{sensor_id}/failure_rate",
            name="/sensors/:id/failure_rate"
        )

# -------------------
# INCIDENT DEBUG VIEW
# -------------------
class RecentFailuresUser(HttpUser):
    wait_time = between(0.2, 1.0)

    @task(3)
    def get_recent_failures(self):
        sensor_id = uniform_sensor_id()
        self.client.get(
            f"/sensors/{sensor_id}/recent_failures",
            name="/sensors/:id/recent_failures"
        )

# -------------------
# TIME SERIES QUERIES
# -------------------
class TimeSeriesUser(HttpUser):
    wait_time = between(1.0, 2.5)

    @task(5)
    def hourly_stats(self):
        sensor_id = uniform_sensor_id()
        self.client.get(
            f"/sensors/{sensor_id}/hourly_stats",
            name="/sensors/:id/hourly_stats"
        )

# -------------------
# BURSTY READ LOAD
# -------------------
class BurstyUser(HttpUser):
    wait_time = between(0.5, 1.2)

    @task(3)
    def bursty_traffic(self):
        sensor_id = skewed_sensor_id()
        if random.random() < 0.05:
            for _ in range(5):
                self.client.get(
                    f"/sensors/{sensor_id}/hourly_stats",
                    name="/sensors/:id/hourly_stats"
                )
        else:
            self.client.get(
                f"/sensors/{sensor_id}/failure_rate",
                name="/sensors/:id/failure_rate"
            )

# -------------------
# SENSOR DETAIL VIEW
# -------------------
class GetSensorUser(HttpUser):
    wait_time = between(0.3, 1.5)

    @task(2)
    def get_sensor(self):
        sensor_id = skewed_sensor_id()
        self.client.get(
            f"/sensors/{sensor_id}/",
            name="/sensors/:id/"
        )

# -------------------
# ERROR / NOISE TRAFFIC
# -------------------
class RandomNoiseUser(HttpUser):
    wait_time = between(1.0, 3.0)

    @task(1)
    def send_noise(self):
        paths = [
            "/sensors/9999999/failure_rate",
            "/unknown",
            "/pings?sensor_id=abc",
            "/sensors//hourly_stats"
        ]
        self.client.get(random.choice(paths), name="/noise")

# -------------------
# RECENT PINGS
# -------------------
class RecentPingsUser(HttpUser):
    wait_time = between(0.8, 2.0)

    @task(4)
    def get_recent_pings(self):
        sensor_id = cold_sensor_id()
        self.client.get(
            f"/sensors/{sensor_id}/recent_pings",
            name="/sensors/:id/recent_pings"
        )

# -------------------
# LATENCY SUMMARY
# -------------------
class LatencySummaryUser(HttpUser):
    wait_time = between(0.8, 2.0)

    @task(2)
    def get_latency_summary(self):
        sensor_id = skewed_sensor_id()
        self.client.get(
            f"/sensors/{sensor_id}/latency_summary",
            name="/sensors/:id/latency_summary"
        )

# -------------------
# INCIDENT SPIKE SIMULATION
# -------------------
class IncidentSpikeUser(HttpUser):
    wait_time = between(0.1, 0.5)

    @task(3)
    def spike_recent_failures(self):
        sensor_id = skewed_sensor_id()
        self.client.get(
            f"/sensors/{sensor_id}/recent_failures",
            name="/sensors/:id/recent_failures"
        )

    @task(2)
    def spike_failure_rate(self):
        sensor_id = skewed_sensor_id()
        self.client.get(
            f"/sensors/{sensor_id}/failure_rate",
            name="/sensors/:id/failure_rate"
        )

    @task(1)
    def spike_hourly_stats(self):
        sensor_id = skewed_sensor_id()
        self.client.get(
            f"/sensors/{sensor_id}/hourly_stats",
            name="/sensors/:id/hourly_stats"
        )
