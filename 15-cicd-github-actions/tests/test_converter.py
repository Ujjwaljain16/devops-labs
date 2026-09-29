import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))

from converter import (
    celsius_to_fahrenheit,
    fahrenheit_to_celsius,
    km_to_miles,
    miles_to_km,
)


def test_celsius_to_fahrenheit():
    assert celsius_to_fahrenheit(0) == 32
    assert celsius_to_fahrenheit(100) == 212


def test_fahrenheit_to_celsius():
    assert fahrenheit_to_celsius(32) == 0
    assert round(fahrenheit_to_celsius(212), 2) == 100


def test_km_to_miles():
    assert round(km_to_miles(1), 4) == 0.6214


def test_miles_to_km():
    assert round(miles_to_km(1), 4) == 1.6093


def test_round_trip_celsius():
    original = 36.6
    converted = fahrenheit_to_celsius(celsius_to_fahrenheit(original))
    assert round(converted, 4) == original
