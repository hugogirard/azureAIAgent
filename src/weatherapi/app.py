from fastapi import FastAPI
from models.forecast import region_forecasts
from models.region import TamrielRegion
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
import random

app = FastAPI(title="Tamriel Weather Forecast")

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get('/api/weather')
async def get_weather(region: TamrielRegion):
    forecast = region_forecasts[region]
    temperature_c = random.randint(*forecast["temp_range"])
    description = random.choice(forecast["descriptions"])
    return {
        "region": region.value,
        "temperature_c": temperature_c,
        "description": description
    }

@app.get('/', include_in_schema=False)
async def root():
    return RedirectResponse(url="/docs")