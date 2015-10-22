onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group aufgabe1_tb -label rst /aufgabe1_test/rst
add wave -noupdate -group aufgabe1_tb -label clk /aufgabe1_test/clk
add wave -noupdate -group aufgabe1_tb -label hlt /aufgabe1_test/hlt
add wave -noupdate -group aufgabe1_tb -label sw /aufgabe1_test/sw
add wave -noupdate -group aufgabe1_tb -label an /aufgabe1_test/an
add wave -noupdate -group aufgabe1_tb -label seg /aufgabe1_test/seg
add wave -noupdate -group aufgabe1_tb -label dp /aufgabe1_test/dp
add wave -noupdate -group aufgabe1_tb -label btn0 /aufgabe1_test/btn0
add wave -noupdate -group aufgabe1_tb -label btn1 /aufgabe1_test/btn1
add wave -noupdate -group aufgabe1_tb -label rst /aufgabe1_test/u1/u1/rst
add wave -noupdate -group aufgabe1 -label rst /aufgabe1_test/u1/rst
add wave -noupdate -group aufgabe1 -label clk /aufgabe1_test/u1/clk
add wave -noupdate -group aufgabe1 -label btn0 /aufgabe1_test/u1/btn0
add wave -noupdate -group aufgabe1 -label btn1 /aufgabe1_test/u1/btn1
add wave -noupdate -group aufgabe1 -label sw /aufgabe1_test/u1/sw
add wave -noupdate -group aufgabe1 -label an /aufgabe1_test/u1/an
add wave -noupdate -group aufgabe1 -label seg /aufgabe1_test/u1/seg
add wave -noupdate -group aufgabe1 -label dp /aufgabe1_test/u1/dp
add wave -noupdate -group aufgabe1 -label data /aufgabe1_test/u1/data
add wave -noupdate -group aufgabe1 -label dpin /aufgabe1_test/u1/dpin
add wave -noupdate -group hex4x7seg -label clk /aufgabe1_test/u1/u1/clk
add wave -noupdate -group hex4x7seg -label en /aufgabe1_test/u1/u1/en
add wave -noupdate -group hex4x7seg -label swrst /aufgabe1_test/u1/u1/swrst
add wave -noupdate -group hex4x7seg -label data /aufgabe1_test/u1/u1/data
add wave -noupdate -group hex4x7seg -label dpin /aufgabe1_test/u1/u1/dpin
add wave -noupdate -group hex4x7seg -label an /aufgabe1_test/u1/u1/an
add wave -noupdate -group hex4x7seg -label dp /aufgabe1_test/u1/u1/dp
add wave -noupdate -group hex4x7seg -label seg /aufgabe1_test/u1/u1/seg
add wave -noupdate -group hex4x7seg -label cnt_1 /aufgabe1_test/u1/u1/cnt_1
add wave -noupdate -group hex4x7seg -label cnt_2 /aufgabe1_test/u1/u1/cnt_2
add wave -noupdate -group hex4x7seg -label mod_4_counter_2_enable /aufgabe1_test/u1/u1/mod_4_counter_2_enable
add wave -noupdate -group hex4x7seg -label dec_5_input /aufgabe1_test/u1/u1/dec_5_input
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {510 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 189
configure wave -valuecolwidth 81
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1130 ns}
