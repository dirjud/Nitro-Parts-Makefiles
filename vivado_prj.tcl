


set TOP $::env(TOP)
create_project -part $::env(PART) -force $TOP prj


#verilog
set vfiles [read [open "vfiles.txt" r]]
add_files $vfiles

# constraints
set xdcfiles [read [open "xdcfiles.txt" r]]
add_files $xdcfiles

set inc_dirs 0
set incpaths [read [open "incpaths.txt"]]
foreach i $incpaths {
    append inc_dirs "\n" $i
}

set xcifiles [read [open "xcifiles.txt" r]]
add_files $xcifiles

set_property include_dirs $inc_dirs [current_fileset]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]
