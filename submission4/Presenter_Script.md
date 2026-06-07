# Presenter Script — Jupiter System
## BICS 2304 | Submission 4 | Section 04

---

### Slide 1 — Title

"Good morning/afternoon. Our project is called Jupiter — a Wearable Heat Stroke and Dehydration Prevention System. It simulates an IoT wearable device designed to protect outdoor workers and athletes from heat-related illnesses, built entirely in MIPS Assembly Language using the MARS IDE."

---

### Slide 2 — System Overview

"The Jupiter system is designed for people working or exercising in tropical climates like Malaysia. It works as a continuous monitoring loop — each cycle it reads four sensor inputs and decides what action to take based on the readings.

Everything is simulated in MIPS Assembly. The sensor values are entered by the user in the MARS console, and the actuator responses are printed as output messages. The system runs 3 sensors, 4 actuators, has 4 priority levels, and all 5 test cases pass."

---

### Slide 3 — Hardware Components

"On the sensor side, we use the MAX30205 for body temperature, the MAX30102 for heart rate, and the MPU6050 accelerometer for fall detection. We also track a sustained motion timer in software.

On the actuator side, we have a haptic vibration motor for physical alerts, a hydration LED that blinks, a cooling vest fan, and a GPS emergency broadcast module — the SIM800L — that fires an SOS signal if a fall is detected."

---

### Slide 4 — Priority Decision Logic

"The core of the system is a priority decision engine. It checks four conditions in order, highest priority first — first match wins.

P1 is fall detection: if the accelerometer spike exceeds 100G and the person stops moving completely, the system enters CRITICAL state, broadcasts a GPS SOS, and exits with code 10.

P2 is heat stress: if heart rate exceeds 130 BPM and body temperature exceeds 38 degrees at the same time, the system tells the user to take a break, activates the haptic motor and cooling fan.

P3 is hydration: if the user has been actively moving for 15 minutes, a drink water reminder fires, the LED blinks, and the timer resets to zero.

P4 is the default safe state — all actuators remain off."

---

### Slide 5 — Input Validation

"We also built error handling into the system. If the user enters a temperature value outside the physiological range of 0 to 50 degrees Celsius, the system prints an error message and re-prompts them — it never crashes or accepts bad data. This is test case TC-05, which you can see on the right — entering 120 triggers the error, then entering 37 lets the system continue normally."

---

### Slide 6 — Test Case Results

"We documented and ran five test cases.

TC-01 tests the safe state with normal readings — all actuators off. TC-02 triggers heat stress with high heart rate and temperature. TC-03 fires the hydration reminder at 15 minutes of motion. TC-04 simulates a fall with a high G-force reading and zero motion — the system goes critical and exits. TC-05 confirms error handling works for out-of-range input.

All five test cases pass as expected."

---

### Slide 7 — Conclusion

"To summarize — Jupiter meets all the project requirements. We have more than 3 sensors and 3 actuators, a 4-level priority decision engine, input validation with error recovery, and 9 modular subroutines with a clear register convention. All 5 test cases pass.

Thank you."

---

## Demo Sequence (after slides)

Switch to MARS IDE and run the program. Enter these inputs in order:

1. **TC-01 Safe**: Temp=36, HR=80, Accel=15, Timer=2 → `[Status: Safe]`
2. **TC-05 Error**: Temp=120 → error → enter 37, HR=85, Accel=12, Timer=2 → `[Status: Safe]`
3. **TC-03 Hydration**: Temp=37, HR=85, Accel=12, Timer=15 → `[Drink Water]`
4. **TC-02 Heat Stress**: Temp=39, HR=140, Accel=10, Timer=4 → `[Status: Take a break]`
5. **TC-04 Critical** (run last — exits program): Temp=36, HR=75, Accel=110, Timer=0 → `[Status: CRITICAL]` + exit
