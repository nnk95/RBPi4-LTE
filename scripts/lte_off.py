#!/usr/bin/python3

import RPi.GPIO as GPIO
import time
import os

os.system('clear')

print("***** SIXFAB LTE HAT GPIO POWER OFF SCRIPT *****")

GPIO.setwarnings(False)

rest_seconds = 3
BCM_GPIO = 26
BOARD_GPIO = 37

GPIO.setmode(GPIO.BCM)
GPIO.setup(BCM_GPIO, GPIO.OUT)

print("LTE HAT IS NOW: OFF\n")
GPIO.output(BCM_GPIO, 1)
