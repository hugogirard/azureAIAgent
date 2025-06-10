from .region import TamrielRegion

region_forecasts = {
    TamrielRegion.skyrim: {
        "temp_range": (-10, 5),
        "descriptions": [
            "Snowy and cold, with icy winds.",
            "Blizzard conditions, low visibility.",
            "Clear skies but freezing temperatures.",
            "Overcast and chilly, snow flurries likely."
        ]
    },
    TamrielRegion.morrowind: {
        "temp_range": (12, 22),
        "descriptions": [
            "Ashy skies, warm with volcanic haze.",
            "Humid and cloudy, with ash storms.",
            "Warm and dry, occasional gusts.",
            "Sultry air, distant rumbling from Red Mountain."
        ]
    },
    TamrielRegion.cyrodiil: {
        "temp_range": (10, 22),
        "descriptions": [
            "Mild and pleasant, partly cloudy.",
            "Sunny with a gentle breeze.",
            "Light rain, cool and fresh.",
            "Foggy morning, clearing by noon."
        ]
    },
    TamrielRegion.hammerfell: {
        "temp_range": (25, 40),
        "descriptions": [
            "Hot and dry, desert sun blazing.",
            "Scorching winds, sand swirling.",
            "Clear skies, relentless heat.",
            "Cooler night, but dry air persists."
        ]
    },
    TamrielRegion.highrock: {
        "temp_range": (8, 18),
        "descriptions": [
            "Cool and misty, with light rain.",
            "Overcast skies, occasional drizzle.",
            "Breezy and cloudy, mild temperatures.",
            "Sunny intervals, crisp air."
        ]
    },
    TamrielRegion.elsweyr: {
        "temp_range": (20, 35),
        "descriptions": [
            "Sunny and warm, with dry breezes.",
            "Hot afternoon, cool evening.",
            "Clear skies, desert winds.",
            "Occasional sandstorm, otherwise bright."
        ]
    },
    TamrielRegion.blackmarsh: {
        "temp_range": (18, 28),
        "descriptions": [
            "Cloudy and muddy, humid with fog.",
            "Heavy rain, marshes flooded.",
            "Misty morning, muggy afternoon.",
            "Thunderstorms, dense humidity."
        ]
    },
    TamrielRegion.valenwood: {
        "temp_range": (16, 28),
        "descriptions": [
            "Humid and lush, with scattered showers.",
            "Rainforest mist, warm and green.",
            "Sunlight filtering through thick canopy.",
            "Occasional downpour, otherwise calm."
        ]
    },
    TamrielRegion.summerset: {
        "temp_range": (15, 25),
        "descriptions": [
            "Bright and clear, gentle sea breeze.",
            "Sunny with mild temperatures.",
            "Light clouds, pleasant day.",
            "Cool evening, starry skies."
        ]
    },
    TamrielRegion.orsinium: {
        "temp_range": (0, 10),
        "descriptions": [
            "Chilly and overcast, with mountain winds.",
            "Snow flurries, cold and brisk.",
            "Clear but cold, rocky terrain.",
            "Frosty morning, cloudy afternoon."
        ]
    }
}