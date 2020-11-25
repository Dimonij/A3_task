vlib work

vlog -sv A2_task.sv
vlog -sv A3_task.sv
vlog -sv A3_task_tb.sv

vsim -novopt A3_task_tb

add log -r /*
add wave -r *

run -all