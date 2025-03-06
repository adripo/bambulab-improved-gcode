;===== Change filament G-code ===
;===== version: 1.0 =========================
;===== version date: 20250220 ======

M620 S[next_extruder]A
M204 S9000
{if toolchange_count > 1 && (z_hop_types[current_extruder] == 0 || z_hop_types[current_extruder] == 3)}
G17
G2 Z{z_after_toolchange + 0.4} I0.86 J0.86 P1 F10000 ; spiral lift a little from second lift
{endif}
G1 Z{max_layer_z + 3.0} F1200

;M400



M106 P1 S255 ; Set fan 1 (part cooling) to 100% to reduce filament spillage while cutting
M106 P2 S0 ; Auxiliary fan set to zero

;M400

;M104 S[new_filament_temp] ; Nozzle will change its temperature while doing other stuff

; Go to cutting current filament position in two path to avoid problem on cutter actuator
; TODO is this really necessary?? cut is done later... with T
G1 Y0 F24000
G1 Y-3 F9000
G1 X20 F24000

; retract filament before cutting
{if long_retractions_when_cut[previous_extruder]}
M620.11 S1 I[previous_extruder] E-{retraction_distances_when_cut[previous_extruder]} F{old_filament_e_feedrate}
{else}
M620.11 S0
{endif}

; continue to cut filament

{if toolchange_count == 2} ; only executed on first toolchange (after printing with first filament)
; get travel path for change filament
M620.1 X[travel_point_1_x] Y[travel_point_1_y] F24000 P0
M620.1 X[travel_point_2_x] Y[travel_point_2_y] F24000 P1
M620.1 X[travel_point_3_x] Y[travel_point_3_y] F24000 P2
{endif}

M400

;G0 X54 Y265 F24000 ; necessary for the slicer to show position

M620.1 E F[old_filament_e_feedrate] T{nozzle_temperature_range_high[previous_extruder]}
T[next_extruder]
M620.1 E F[new_filament_e_feedrate] T{nozzle_temperature_range_high[next_extruder]}

{if next_extruder < 255} ; check if filament exists (AMS slot number 0-16)

{if long_retractions_when_cut[previous_extruder]}
M620.11 S1 I[next_extruder] E{retraction_distances_when_cut[previous_extruder]} F{new_filament_e_feedrate}
;M628 S1
;G92 E0
;G1 E{retraction_distances_when_cut[previous_extruder]} F[new_filament_e_feedrate]
;M400
;M629 S1
{else}
M620.11 S0
{endif}
G92 E0

{if flush_length_1 > 1}
M83

; always use highest temperature to flush
M400
{if nozzle_temperature_range_high[previous_extruder] > nozzle_temperature_range_high[next_extruder]}
M109 S{nozzle_temperature_range_high[previous_extruder]}
{else}
M109 S{nozzle_temperature_range_high[next_extruder]}
{endif}

; FLUSH_START 1
{if flush_length_1 > 23.7}
G1 E22.7 F{old_filament_e_feedrate * 1.2} ; uses old filament feedrate
G1 E0.2 F120
G1 E{(flush_length_1 - 22.7) * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.2 F120
G1 E{(flush_length_1 - 22.7) * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.2 F120
G1 E{(flush_length_1 - 22.7) * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.2 F120
G1 E{(flush_length_1 - 22.7) * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.2 F120
{else}
G1 E{flush_length_1} F{old_filament_e_feedrate * 1.2} ; uses old filament feedrate
{endif}
; FLUSH_END 1

G1 E-[old_retract_length_toolchange] F1800
G1 E[old_retract_length_toolchange] F300
{endif}

;M104 S{nozzle_temperature_range_high[next_extruder]}

; FLUSH_START 2
{if flush_length_2 > 1}

G91
G1 X3 F12000; move aside to extrude
G90
M83

; FLUSH_START
G1 E{flush_length_2 * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.25 F120
G1 E{flush_length_2 * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.25 F120
G1 E{flush_length_2 * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.25 F120
G1 E{flush_length_2 * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.25 F120
; FLUSH_END 2

G1 E-[new_retract_length_toolchange] F1800
G1 E[new_retract_length_toolchange] F300
{endif}

; FLUSH_START 3
{if flush_length_3 > 1}

G91
G1 X3 F12000; move aside to extrude
G90
M83

; FLUSH_START
G1 E{flush_length_3 * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.25 F120
G1 E{flush_length_3 * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.25 F120
G1 E{flush_length_3 * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.25 F120
G1 E{flush_length_3 * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.25 F120
; FLUSH_END 3

G1 E-[new_retract_length_toolchange] F1800
G1 E[new_retract_length_toolchange] F300
{endif}

; FLUSH_START 4
{if flush_length_4 > 1}

G91
G1 X3 F12000; move aside to extrude
G90
M83

; FLUSH_START
G1 E{flush_length_4 * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.25 F120
G1 E{flush_length_4 * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.25 F120
G1 E{flush_length_4 * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.25 F120
G1 E{flush_length_4 * 0.25} F{new_filament_e_feedrate * 1.2}
G1 E0.25 F120
; FLUSH_END 4

{endif}

; FLUSH_FINAL
M400
M109 R[new_filament_temp]
;G1 E2 F{new_filament_e_feedrate} ;Compensate for filament spillage during waiting temperature
; FLUSH_FINAL_END


M400
G92 E0
G1 E-[new_retract_length_toolchange] F1800
M106 P1 S255
M400 S3 ; Required : if it is present time will be couted as "Travel" time, if it is missing time will be counted as "Sparse/Wall or other Print" time

;G1 X[travel_point_3_x] Y[travel_point_3_y] F18000
G1 Y265 F3000

; try to break the filament before wiping
G1 Y250 F18000
G1 Y245 F18000
G1 Y250 F18000
G1 Y245 F18000
G1 Y265 F18000

; shake to put down garbage
G1 X70 F9000
G1 X75 F18000
G1 X65 F18000
G1 X75 F18000
G1 X65 F18000
G1 X81 F6000
G1 X93 F18000
G1 X81 F18000
G1 Y245 F18000
G1 X93 F18000
G1 Y265 F18000
G1 X80 F18000
G1 X93 F18000
;G1 X128 F18000 ; wipe and shake
G1 Y257 F18000 ; prevent collision, 257 just outside printable area

;G1 X70 F5000
;G1 X90 F3000
;G1 Y255 F4000
;G1 X105 F5000
;G1 Y265 F5000
;G1 X70 F10000
;G1 X100 F5000
;G1 X70 F10000
;G1 X100 F5000

;G1 X70 F10000
;G1 X80 F15000
;G1 X60
;G1 X80
;G1 X60
;G1 X80 ; shake to put down garbage
;G1 X100 F5000
;G1 X165 F15000; wipe and shake
;G1 Y256 ; move Y to aside, prevent collision

M400

G1 Z{max_layer_z + 3.0} F3000

{if layer_z <= (initial_layer_print_height + 0.001)}
M204 S[initial_layer_acceleration]
{else}
M204 S[default_acceleration]
{endif}

{else}
G1 X[x_after_toolchange] Y[y_after_toolchange] Z[z_after_toolchange] F18000
{endif}

M621 S[next_extruder]A
