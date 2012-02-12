
DI=di

TARGS= %Terminal.v %TerminalInst.v %TerminalDefs.v
.PRECIOUS: $(TARGS)

$(TARGS): ../$(DI_FILE)
	mkdir -p ../rtl_auto
	$(DI) -o ../rtl_auto -v $(notdir $*) $<

#%Terminal.v: ../$(DI_FILE)
#	$(DI) -o ../rtl_auto -v $(notdir $*) $<
