.PHONY: headless master worker all stop

# Run Locust in headless mode
headless:
	@echo "Starting Locust headless mode..."
	@locust -f locustfile.py --host=http://localhost:3000 --headless -u 10 -r 2 -t 30s --loglevel DEBUG

# Start Locust master
master:
	@echo "Starting Locust master..."
	@locust -f locustfile.py --host=http://localhost:3000 --master

# Start Locust worker
worker:
	@echo "Starting Locust worker..."
	@locust -f locustfile.py --host=http://localhost:3000 --worker

# Stop all Locust processes (best effort)
stop:
	@echo "Stopping Locust..."
	-@kill `cat .locust_master.pid 2>/dev/null` 2>/dev/null || true
	-@kill `cat .locust_worker.pid 2>/dev/null` 2>/dev/null || true
	@rm -f .locust_master.pid .locust_worker.pid
