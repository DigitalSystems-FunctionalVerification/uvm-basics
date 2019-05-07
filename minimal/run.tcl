if [file exists "work"] {vdel -all}
vlib work

# if [file exists "UVM_ADD_SUB"] {vdel -all -lib UVM_ADD_SUB}
# vlib UVM_ADD_SUB

# vlog -reportprogress 300 -work UVM_ADD_SUB add_sub_seq_item.sv
# vlog -reportprogress 300 -work UVM_ADD_SUB add_sub_sequence.sv
# vlog -reportprogress 300 -work UVM_ADD_SUB add_sub_sequencer.sv
# vlog -reportprogress 300 -work UVM_ADD_SUB add_sub_driver.sv
# vlog -reportprogress 300 -work UVM_ADD_SUB add_sub_monitor.sv

vlog design.sv
vlog tb.sv

vsim -novopt top  +UVM_CONFIG_DB_TRACE
set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all