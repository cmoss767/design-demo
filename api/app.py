# Configuration Options:
# - Host: 0.0.0.0 allows external connections
# - Port: 3000 (should match Dockerfile and nginx configuration)
# - Workers: Configured via Dockerfile CMD
# - FastAPI Settings: Add middleware, CORS, or other FastAPI configurations here

from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello World"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3000)