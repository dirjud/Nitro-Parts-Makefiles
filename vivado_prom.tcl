set TOP $::env(TOP)

write_cfgmem  -format bin -size $::env(PROM_SIZE) -interface $::env(PROM_INTERFACE) -loadbit "up 0x00000000 $TOP.bit " -checksum -force -file "$TOP.bin"

if {[info exists env(RTL_FILENAME)]} {
    file copy $TOP.bin $::env(RTL_FILENAME)
} else {
    # make a backup copy
    file mkdir rev
    set rev 1
    while { [file isfile rev/${TOP}_rev$rev.bin] == 1 } {
	set rev [ expr {$rev + 1} ]
    }
    file copy $TOP.bin rev/${TOP}_rev$rev.bin
}

exit
