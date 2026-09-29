"""A tiny unit-conversion library, the demo app for the CI/CD pipeline."""


def celsius_to_fahrenheit(c: float) -> float:
    return (c * 9 / 5) + 32


def fahrenheit_to_celsius(f: float) -> float:
    return (f - 32) * 5 / 9


def km_to_miles(km: float) -> float:
    return km * 0.621371


def miles_to_km(miles: float) -> float:
    return miles / 0.621371


if __name__ == "__main__":
    print("25C ->", round(celsius_to_fahrenheit(25), 2), "F")
    print("10km ->", round(km_to_miles(10), 2), "miles")
