import json
import os
from typing import List, Optional, Dict, Any

class FlightRepository:
    def __init__(self, data_file: str = None):
        if data_file is None:
            data_file = os.path.join(os.path.dirname(__file__), '../flight_data.json')
        with open(data_file, 'r', encoding='utf-8') as f:
            self.flights = json.load(f)

    def get_all_flights(self) -> List[Dict[str, Any]]:
        """Return all flights."""
        return self.flights

    def get_flight_by_number(self, flight_number: str) -> Optional[Dict[str, Any]]:
        """Retrieve a flight by its flight number."""
        return next((f for f in self.flights if f["flight_number"] == flight_number), None)

    def get_flights_by_destination(self, city: str, country: str = None) -> List[Dict[str, Any]]:
        """Retrieve flights by destination city (and optionally country)."""
        results = [f for f in self.flights if f["destination_city"].lower() == city.lower()]
        if country:
            results = [f for f in results if f["destination_country"].lower() == country.lower()]
        return results

    def add_flight(self, flight_data: Dict[str, Any]) -> None:
        """Add a new flight to the repository."""
        self.flights.append(flight_data)
        # Optionally, persist to file here

    def update_flight(self, flight_number: str, updates: Dict[str, Any]) -> bool:
        """Update an existing flight by flight number."""
        for flight in self.flights:
            if flight["flight_number"] == flight_number:
                flight.update(updates)
                return True
        return False

    def delete_flight(self, flight_number: str) -> bool:
        """Delete a flight by flight number."""
        for i, flight in enumerate(self.flights):
            if flight["flight_number"] == flight_number:
                del self.flights[i]
                return True
        return False