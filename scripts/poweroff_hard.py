
from power_api import SixfabPower, Definition, Event
import time
import os

pms = SixfabPower()
epoch = time.time()
os.system('clear')

print("***** HARD POWEROFF TRIGGERED *****")
print(" ")
# Remove all other events
print("Removing all other SixfabPower scheduled events: " + str(pms.remove_all_scheduled_events(200)))

# create hard reboot event
event = Event()
event.id = 1
event.schedule_type = Definition.EVENT_INTERVAL
event.repeat = Definition.EVENT_ONE_SHOT
event.time_interval = 6
event.interval_type = Definition.INTERVAL_TYPE_SEC
event.action = Definition.HARD_POWER_OFF

result = pms.create_scheduled_event_with_event(event, 500)

print("Sixfab: HARD POWEROFF event created: executing in 5 seconds.")
print("Sending safe poweroff to OS.")
print(" ")
print("Goodbye!")
time.sleep(1)
os.system('poweroff')
