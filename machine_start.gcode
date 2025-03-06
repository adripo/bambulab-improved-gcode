;===== machine: P1P/P1S ========================
;===== date: 20250220 =====================
;===== turn on the HB fan & MC board fan =================
M104 S75 ;set extruder temp to turn on the HB fan and prevent filament oozing from nozzle
M710 A1 S255 ; turn on MC fan by default(P1S)
;===== reset machine status =================

G91
M17 Z0.4 ; lower the z-motor current
G380 S2 Z15 F300 ; G380 is same as G38; lower the hotbed , to prevent the nozzle is below the hotbed
G380 S2 Z-10 F300 ;
;G0 Z5 F300;
G90
M17 X1.2 Y1.2 Z0.75 ; reset motor current to default
M960 S5 P1 ; turn on logo lamp
G90
M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate
M73.2   R1.0 ;Reset left time magnitude
M1002 set_gcode_claim_speed_level : 5
M221 X0 Y0 Z0 ; turn off soft endstop to prevent protential logic problem
G29.1 Z{+0.0} ; clear z-trim value first
M204 S10000 ; init ACC set to 10m/s^2

;===== heatbed preheat ====================
M1002 gcode_claim_action : 2
M140 S[bed_temperature_initial_layer_single] ;set bed temp

;=============turn on fans to prevent PLA jamming=================
{if filament_type[initial_extruder]=="PLA"}
    {if (bed_temperature[initial_extruder] >45)||(bed_temperature_initial_layer[initial_extruder] >45)}
    M106 P3 S180
    {elsif (bed_temperature[initial_extruder] >50)||(bed_temperature_initial_layer[initial_extruder] >50)}
    M106 P3 S255
    {endif};Prevent PLA from jamming
{endif}
M106 P2 S100 ; turn on aux fan, to cool down toolhead

;===== prepare print temperature and material ==========
M104 S[nozzle_temperature_initial_layer] ;set extruder temp
G91
G0 Z10 F1200
G90
G28 X
M975 S1 ; turn on vibration supression
G0 X60 F12000
G0 Y245
G0 Y265 F3000
M620 M
M620 S[initial_extruder]A   ; switch material if AMS exist
    M109 S[nozzle_temperature_initial_layer]
    G0 X120 F12000

    G0 X20 Y50 F12000
    G0 Y-3
    T[initial_extruder]
    G0 X54 F12000
    G0 Y265
    M400
M621 S[initial_extruder]A
M620.1 E F{filament_max_volumetric_speed[initial_extruder]/2.4053*60} T{nozzle_temperature_range_high[initial_extruder]}


M412 S1 ; ===turn on filament runout detection===

M109 S250 ;set nozzle to common flush temp
M106 P1 S0 ; turn off parts fan
G92 E0
G1 E20 F200
M400
M104 S[nozzle_temperature_initial_layer]
G92 E0
G1 E20 F200
M400
M106 P1 S255 ; turn on parts fan
G92 E0
G1 E5 F300
M109 S{nozzle_temperature_range_low[initial_extruder] - 20} ; drop nozzle temp, make filament shink a bit
G92 E0
G1 E-0.5 F300

M1002 gcode_claim_action : 14

; try to break the filament before wiping
G0 Y250 F18000
G0 Y245 F18000
G0 Y250 F18000
G0 Y245 F18000
G0 Y265 F18000

; shake to put down garbage
G0 X70 F9000
G0 X75 F18000
G0 X65 F18000
G0 X75 F18000
G0 X65 F18000
G0 X81 F6000
G0 X93 F18000
G0 X81 F18000
G0 Y245 F18000
G0 X93 F18000
G0 Y265 F18000
G0 X80 F18000
G0 X93 F18000
G0 X128 F18000 ; go to center
G0 Y245 F18000
M400

M104 S140 ; set nozzle temp without waiting
G92 E0 ; reset extruder origin
G1 E-0.5 F300 ; retract more

;M106 P1 S0
;===== prepare print temperature and material end =====


G0 X250 Y6 F20000
M109 S140 ; wait nozzle temp down to heatbed acceptable
M106 P1 S0 ; turn off parts fan

M190 S[bed_temperature_initial_layer_single] ;wait for bed temp


;===== bed leveling ==================================
M1002 judge_flag g29_before_print_flag
M622 J1

    M1002 gcode_claim_action : 1
    G29 A X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]}
    M400
    M500 ; save cali data

M623
;===== bed leveling end ================================

;===== home after wipe mouth============================
M1002 judge_flag g29_before_print_flag
M622 J0

    M1002 gcode_claim_action : 13
    G28

M623
;===== home after wipe mouth end =======================

M975 S1 ; turn on vibration supression


;=============turn on fans to prevent PLA jamming=================
{if filament_type[initial_extruder]=="PLA"}
    {if (bed_temperature[initial_extruder] >45)||(bed_temperature_initial_layer[initial_extruder] >45)}
    	M106 P3 S180
    {endif};
    {if (bed_temperature[initial_extruder] >60)||(bed_temperature_initial_layer[initial_extruder] >60)}
    	M106 P3 S255
    {endif};Prevent PLA from jamming
{endif}
M106 P2 S100 ; turn on big fan ,to cool down toolhead


M104 S{nozzle_temperature_range_low[initial_extruder]} ; set extrude temp earlier, to reduce wait time

;===== mech mode fast check============================
;G0 X128 Y128 Z10 F20000
;M400 P200
;M970.3 Q1 A7 B30 C80  H15 K0
;M974 Q1 S2 P0

;G0 X128 Y128 Z10 F20000
;M400 P200
;M970.3 Q0 A7 B30 C90 Q0 H15 K0
;M974 Q0 S2 P0

;M975 S1 ; turn on vibration supression
;G0 F30000
;G0 X230 Y15
;G28 X ; re-home XY
;===== fmech mode fast check============================


;===== nozzle load line ===============================
M975 S1 ; turn on vibration supression
G90 ; Absolute Positioning
M83 ; E Relative
T1000 ; Select extruder: switch to nozzle

G0 X86 Y-3 Z0.8 F18000 ;Move to start position
M109 S{nozzle_temperature_initial_layer[initial_extruder]}
G0 Z0.2

G1 X90 E4 F300 ; initial blob
G1 X100 E1.5 F{outer_wall_volumetric_speed/(0.3*0.5) * 60}
G1 Y-2 E0.15 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
G1 X110 E1.5 F{outer_wall_volumetric_speed/(0.3*0.5) * 60}
G1 Y-3 E0.15 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
G1 X120 E1.5 F{outer_wall_volumetric_speed/(0.3*0.5) * 60}
G1 Y-2 E0.15 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
G1 X130 E1.5 F{outer_wall_volumetric_speed/(0.3*0.5) * 60}
G1 Y-3 E0.15 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
G1 X140 E1.5 F{outer_wall_volumetric_speed/(0.3*0.5) * 60}
G1 Y-2 E0.15 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
G1 X150 E1.5 F{outer_wall_volumetric_speed/(0.3*0.5) * 60}
G1 Y-3 E0.15 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
G1 X160 E1.5 F{outer_wall_volumetric_speed/(0.3*0.5) * 60}
G1 Y-2 E0.15 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
G1 X170 E1.5 F{outer_wall_volumetric_speed/(0.3*0.5) * 60}
G1 Y-3 E0.15 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}

G0 Y-2.5 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
G1 X120 E2 F{outer_wall_volumetric_speed/(0.3*0.5) * 60}
G0 X100 F{outer_wall_volumetric_speed/(0.3*0.5) * 60}
G0 Y-3 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
G0 X95 F{outer_wall_volumetric_speed/(0.3*0.5) * 60}

M400
G0 Z2.2 F300 ; raising
G0 Y0 F18000
;===== end nozzle load line ===============================

;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==
;curr_bed_type={curr_bed_type}
{if curr_bed_type=="Textured PEI Plate"}
    G29.1 Z{-0.04} ; for Textured PEI Plate
{endif}
;========turn off light and wait extrude temperature =============
M1002 gcode_claim_action : 0
M106 S0 ; turn off fan
M106 P2 S0 ; turn off big fan
M106 P3 S0 ; turn off chamber fan

M975 S1 ; turn on mech mode supression
