#!/usr/bin/python3

import RPi.GPIO as GPIO
import time
import os

os.system('clear')

print("***** SIXFAB LTE HAT GPIO RESTART SCRIPT *****")

GPIO.setwarnings(False)

rest_seconds = 3
BCM_GPIO = 26
BOARD_GPIO = 37

GPIO.setmode(GPIO.BCM)
GPIO.setup(BCM_GPIO, GPIO.OUT)

print("LET HAT IS NOW: OFF\n")
GPIO.output(BCM_GPIO, 1)

print("SWITCHING LTE HAT TO ON:\n")

for i in range(rest_seconds)
  print(str(rest_seconds-i) + " seconds")
  time.sleep(1)

print("\nLTE HAT IS NOW: ON")

GPIO.output(BCM_GPIO, 0)

GPIO.cleanup()
