
DI=di

TARGS= %Terminal.v %TerminalInst.v
.PRECIOUS: $(TARGS)

$(TARGS): ../$(DI_FILE)
	mkdir -p ../rtl_auto
	$(DI) -o ../rtl_auto -v $(notdir $*) $<

# NOTE this dumps all terminals but
# right now that's the only way to get this file specifically
../rtl_auto/terminals_defs.v: ../$(DI_FILE) 
	mkdir -p ../rtl_auto
	$(DI) -o ../rtl_auto -v all $<

