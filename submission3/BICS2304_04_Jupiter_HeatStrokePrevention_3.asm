# ============================================================
# BICS 2304 - Computer Architecture and Assembly Language
# Project Title : Wearable Heat Stroke & Dehydration Prevention System
# Submission    : 3 - Source Code
# Section       : 04
# Lecturer      : Yasir Mehmood
#
# Prepared By:
#   No.  Name                                    Matric No.
#   1    Adam Fawwaz Bin Sazalizam               2416969
#   2    Ahmad Fawwaz Bin Abdul Kadir            2418497
#   3    Wan Abdullah Mikhaiel Bin Wan Shamsuddin 2416229
#   4    Alfyan Shawn Bin Jasni Shirlin          2417841
#
# ============================================================

    .data

# title
msg_title1:     .asciiz "\n============================================\n"
msg_title2:     .asciiz "   JUPITER WEARABLE HEAT STROKE PREVENTION\n"
msg_title3:     .asciiz "      Dehydration Prevention System v1.0\n"
msg_title4:     .asciiz "   BICS2304 | Section 04 | Group: Jupiter\n"
msg_title5:     .asciiz "============================================\n"

# sensor input prompts
msg_prompt_temp:    .asciiz "\n[SENSOR S1] Enter Body Temperature (0-50 C): "
msg_prompt_hr:      .asciiz "[SENSOR S2] Enter Heart Rate (BPM): "
msg_prompt_accel:   .asciiz "[SENSOR S3] Enter Accelerometer G-Force: "
msg_prompt_timer:   .asciiz "[SENSOR S4] Enter Sustained Motion Timer (min): "

# error message for out-of-range temperature
msg_err_temp:   .asciiz "[ERROR]: Out of human physiological bounds! Enter 0 to 50.\n"

# sensor reading display
msg_vitals_hdr:     .asciiz "\n--- SENSOR READINGS ---\n"
msg_disp_temp:      .asciiz "  Body Temperature : "
msg_disp_hr:        .asciiz "  Heart Rate       : "
msg_disp_accel:     .asciiz "  Accelerometer    : "
msg_disp_timer:     .asciiz "  Motion Timer     : "
msg_unit_c:         .asciiz " C\n"
msg_unit_bpm:       .asciiz " BPM\n"
msg_unit_g:         .asciiz " G\n"
msg_unit_min:       .asciiz " min\n"

# status messages
msg_status_hdr:      .asciiz "\n--- SYSTEM STATUS ---\n"
msg_status_safe:     .asciiz "[Status: Safe]\n"
msg_status_break:    .asciiz "[Status: Take a break]\n"
msg_status_water:    .asciiz "[Drink Water]\n"
msg_status_critical: .asciiz "[Status: CRITICAL]\n"

# actuator state output
msg_haptic_off:     .asciiz "  Haptic Motor     : OFF\n"
msg_haptic_pulse:   .asciiz "  Haptic Motor     : BRIEF PULSE\n"
msg_haptic_cont:    .asciiz "  Haptic Motor     : CONTINUOUS PULSE\n"
msg_led_off:        .asciiz "  Hydration LED    : OFF\n"
msg_led_blink:      .asciiz "  Hydration LED    : BLINKING\n"
msg_fan_off:        .asciiz "  Cooling Fan      : OFF\n"
msg_fan_on:         .asciiz "  Cooling Fan      : ACTIVE\n"
msg_gps_off:        .asciiz "  GPS Broadcast    : OFF\n"
msg_gps_sos:        .asciiz "  GPS Broadcast    : SOS TRANSMITTED\n"
msg_gps_coords:     .asciiz "  GPS Location     : [LAT: 3.1390, LON: 101.6869]\n"
msg_sim800l:        .asciiz "  SIM800L Module   : Wireless data stream ACTIVE\n"
msg_timer_reset:    .asciiz "  Motion Timer     : RESET to 0\n"

# system messages
msg_separator:  .asciiz "--------------------------------------------\n"
msg_newcycle:   .asciiz "\n[SYSTEM] Starting new monitoring cycle...\n"
msg_exit:       .asciiz "\n[SYSTEM] Emergency protocol complete. Program exit code 10.\n"

# threshold constants (from hardware design doc)
const_hr_thresh:    .word 130   # max heart rate before heat stress alert
const_temp_thresh:  .word 38    # max body temp before heat stress alert
const_accel_thresh: .word 100   # G-force threshold for fall detection
const_timer_limit:  .word 15    # minutes before hydration reminder
const_temp_min:     .word 0     # valid temp lower bound
const_temp_max:     .word 50    # valid temp upper bound

    .text
    .globl main


# main: program entry point
# initialises timer registers, then runs the monitoring loop

main:
    jal     print_header

    li      $s6, 0        
    li      $t9, 0        

monitor_loop:
    li      $v0, 4
    la      $a0, msg_newcycle
    syscall
    li      $v0, 4
    la      $a0, msg_separator
    syscall

    jal     read_sensors
    jal     display_vitals
    jal     evaluate_priority

    j       monitor_loop

# print_header: prints the system title banner

print_header:
    li      $v0, 4
    la      $a0, msg_title1
    syscall
    li      $v0, 4
    la      $a0, msg_title2
    syscall
    li      $v0, 4
    la      $a0, msg_title3
    syscall
    li      $v0, 4
    la      $a0, msg_title4
    syscall
    li      $v0, 4
    la      $a0, msg_title5
    syscall
    jr      $ra

# read_sensors: reads all 4 sensor values from the user
# outputs: $s0=Temp  $s1=HR  $s2=Accel  $s3=Timer
# calls validate_temp for S1 input validation
read_sensors:
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    # S1 - body temperature (validated)
    li      $v0, 4
    la      $a0, msg_prompt_temp
    syscall
    li      $v0, 5
    syscall
    move    $s0, $v0
    jal     validate_temp

    # S2 - heart rate
    li      $v0, 4
    la      $a0, msg_prompt_hr
    syscall
    li      $v0, 5
    syscall
    move    $s1, $v0

    # S3 - accelerometer G-force
    li      $v0, 4
    la      $a0, msg_prompt_accel
    syscall
    li      $v0, 5
    syscall
    move    $s2, $v0

    # S4 - sustained motion timer
    li      $v0, 4
    la      $a0, msg_prompt_timer
    syscall
    li      $v0, 5
    syscall
    move    $s3, $v0
    move    $s6, $s3       

    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra


# validate_temp: checks $s0 is within 0-50 range
# if invalid, prints error and re-prompts until a valid value is entered

validate_temp:
    lw      $t0, const_temp_min
    lw      $t1, const_temp_max

    blt     $s0, $t0, temp_invalid
    bgt     $s0, $t1, temp_invalid
    jr      $ra

temp_invalid:
    li      $v0, 4
    la      $a0, msg_err_temp
    syscall

    li      $v0, 4
    la      $a0, msg_prompt_temp
    syscall
    li      $v0, 5
    syscall
    move    $s0, $v0

    j       validate_temp   

# display_vitals: prints all 4 sensor readings to console
# inputs: $s0=Temp  $s1=HR  $s2=Accel  $s3=Timer

display_vitals:
    li      $v0, 4
    la      $a0, msg_vitals_hdr
    syscall

    li      $v0, 4
    la      $a0, msg_disp_temp
    syscall
    li      $v0, 1
    move    $a0, $s0
    syscall
    li      $v0, 4
    la      $a0, msg_unit_c
    syscall

    li      $v0, 4
    la      $a0, msg_disp_hr
    syscall
    li      $v0, 1
    move    $a0, $s1
    syscall
    li      $v0, 4
    la      $a0, msg_unit_bpm
    syscall

    li      $v0, 4
    la      $a0, msg_disp_accel
    syscall
    li      $v0, 1
    move    $a0, $s2
    syscall
    li      $v0, 4
    la      $a0, msg_unit_g
    syscall

    li      $v0, 4
    la      $a0, msg_disp_timer
    syscall
    li      $v0, 1
    move    $a0, $s3
    syscall
    li      $v0, 4
    la      $a0, msg_unit_min
    syscall

    jr      $ra


# evaluate_priority: decision engine - checks P1 to P4 in order
# calls the matching state handler based on sensor values

evaluate_priority:
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    li      $v0, 4
    la      $a0, msg_status_hdr
    syscall

    # P1 - fall detection: accel > 100 AND timer = 0
    lw      $t0, const_accel_thresh
    ble     $s2, $t0, check_p2
    bne     $s3, $zero, check_p2
    jal     state_critical          

    # P2 - heat stress: HR > 130 AND temp > 38
check_p2:
    lw      $t0, const_hr_thresh
    ble     $s1, $t0, check_p3
    lw      $t1, const_temp_thresh
    ble     $s0, $t1, check_p3
    jal     state_take_break
    j       eval_done

    # P3 - hydration reminder: timer >= 15
check_p3:
    lw      $t0, const_timer_limit
    blt     $s3, $t0, check_p4
    jal     state_drink_water
    j       eval_done

    # P4 - default safe state
check_p4:
    jal     state_safe

eval_done:
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra


# state_safe: P4 default - all vitals normal, actuators OFF

state_safe:
    li      $v0, 4
    la      $a0, msg_status_safe
    syscall
    li      $v0, 4
    la      $a0, msg_haptic_off
    syscall
    li      $v0, 4
    la      $a0, msg_led_off
    syscall
    li      $v0, 4
    la      $a0, msg_fan_off
    syscall
    li      $v0, 4
    la      $a0, msg_gps_off
    syscall
    jr      $ra


# state_take_break: P2 - heat stress alert
# haptic motor continuous, cooling fan active

state_take_break:
    li      $v0, 4
    la      $a0, msg_status_break
    syscall
    li      $v0, 4
    la      $a0, msg_haptic_cont
    syscall
    li      $v0, 4
    la      $a0, msg_led_off
    syscall
    li      $v0, 4
    la      $a0, msg_fan_on
    syscall
    li      $v0, 4
    la      $a0, msg_gps_off
    syscall
    jr      $ra


# state_drink_water: P3 - hydration milestone reached
# LED blinks, haptic brief pulse, motion timer reset to 0

state_drink_water:
    li      $v0, 4
    la      $a0, msg_status_water
    syscall
    li      $v0, 4
    la      $a0, msg_haptic_pulse
    syscall
    li      $v0, 4
    la      $a0, msg_led_blink
    syscall
    li      $v0, 4
    la      $a0, msg_fan_off
    syscall
    li      $v0, 4
    la      $a0, msg_gps_off
    syscall

    li      $s6, 0          
    li      $t9, 0
    li      $v0, 4
    la      $a0, msg_timer_reset
    syscall

    jr      $ra


# state_critical: P1 - fall/collapse detected
# triggers GPS SOS via SIM800L, then exits with code 10
# does not return

state_critical:
    li      $v0, 4
    la      $a0, msg_status_critical
    syscall
    li      $v0, 4
    la      $a0, msg_haptic_off
    syscall
    li      $v0, 4
    la      $a0, msg_led_off
    syscall
    li      $v0, 4
    la      $a0, msg_fan_off
    syscall
    li      $v0, 4
    la      $a0, msg_gps_sos
    syscall
    li      $v0, 4
    la      $a0, msg_gps_coords
    syscall
    li      $v0, 4
    la      $a0, msg_sim800l
    syscall
    li      $v0, 4
    la      $a0, msg_exit
    syscall

    li      $v0, 17
    li      $a0, 10        
    syscall
