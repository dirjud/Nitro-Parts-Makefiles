# create_bft_batch.tcl
# bft sample design
# A Vivado script that demonstrates a very simple RTL-to-bitstream batch flow
#
# NOTE:  typical usage would be "vivado -mode tcl -source create_bft_batch.tcl"
#
# STEP#0: define output directory area.
#
set outputDir ./work
file mkdir $outputDir

set_part $::env(PART)
set TOP $::env(TOP)
set GEN_MCS $::env(GEN_MCS)
set MCS_ELF $::env(MCS_ELF)

#
# STEP#1: setup design sources and constraints
#

#verilog
set vfiles [read [open "vfiles.txt" r]]
foreach v $vfiles {
    read_verilog $v
}

# constraints
set xdcfiles [read [open "xdcfiles.txt" r]]
foreach x $xdcfiles {
    read_xdc $x
}

set inc_dirs 0
set incpaths [read [open "incpaths.txt"]]
foreach i $incpaths {
    append inc_dirs "\n" $i
}

set xcifiles [read [open "xcifiles.txt" r]]
foreach xci $xcifiles {
    read_ip $xci
}

##ensure generated ip files are up to date.
#foreach ip [local_ip] {
#    generate_target {synthesis implementation} [get_files -all $ip]
#    synth_ip [get_files $ip]
#}

set_property include_dirs $inc_dirs [current_fileset]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]

#
# STEP#2: run synthesis, report utilization and timing estimates, write checkpoint design
#
synth_design -top $TOP -flatten rebuilt \
             -verilog_define ARTIX=1 \
             -verilog_define IMAGERRX_NO_IOB=1

write_checkpoint -force $outputDir/post_synth

report_timing_summary -file $outputDir/post_synth_timing_summary.rpt

report_power -file $outputDir/post_synth_power.rpt
#
# STEP#3: run placement and logic optimization, report utilization and timing estimates, write checkpoint design
#

opt_design
power_opt_design
place_design
phys_opt_design
write_checkpoint -force $outputDir/post_place
report_timing_summary -file $outputDir/post_place_timing_summary.rpt
#
# STEP#4: run router, report actual utilization and timing, write checkpoint design, run drc, write verilog and xdc out
#
route_design
write_checkpoint -force $outputDir/post_route
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type summary -file $outputDir/post_route_timing.rpt
report_clock_utilization -file $outputDir/clock_util.rpt
report_utilization -file $outputDir/post_route_util.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
write_verilog -force $outputDir/bft_impl_netlist.v
write_xdc -no_fixed_only -force $outputDir/bft_impl.xdc
#
# STEP#5: generate a bitstream
#
if {$GEN_MCS == "MCS"} {
    write_mem_info $TOP.mmi -force
    write_bitstream -force $TOP.pre.bit
    exec updatemem -meminfo $TOP.mmi -data $MCS_ELF -bit $TOP.pre.bit \
                -proc MCS/mcs_0/inst/microblaze_I \
                -out $TOP.bit -force

} else {
    write_bitstream -force $TOP.bit
}

exit
