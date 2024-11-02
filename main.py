from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from app.routes import blog, pages, search
from app.config import setup_logging

app = FastAPI()

# Set up logging
setup_logging()

# Include routers
app.include_router(blog.router)
app.include_router(pages.router)
app.include_router(search.router)

# Serve static files
app.mount("/", StaticFiles(directory="."), name="static")

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="localhost", port=80)
