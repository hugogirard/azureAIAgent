from typing import Optional

class Flight:
    """
    Represents a flight booking from YUL (Montreal) to a destination city and country.
    """
    def __init__(self, destination_city: str, destination_country: str, departure_airport: str = "YUL"):
        self.departure_airport = departure_airport  # Always YUL
        self.destination_city = destination_city
        self.destination_country = destination_country

    def __repr__(self):
        return f"Flight from {self.departure_airport} to {self.destination_city}, {self.destination_country}"

    def to_dict(self):
        return {
            "from": self.departure_airport,
            "to_city": self.destination_city,
            "to_country": self.destination_country
        }

    @staticmethod
    def from_location_string(location: str) -> Optional['Flight']:
        """
        Create a Flight object from a location string like 'Toronto, Canada'.
        """
        if not location or ',' not in location:
            return None
        city, country = [part.strip() for part in location.split(',', 1)]
        return Flight(destination_city=city, destination_country=country)

# Example usage:
# flight = Flight.from_location_string("Paris, France")
# print(flight)
# print(flight.to_dict())
