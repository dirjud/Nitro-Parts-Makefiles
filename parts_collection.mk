

XML_PATH := $(shell pwd)/parts

.PHONY: default update xml py archive pull clean

default: update xml py

update:
# update the root
	git pull

# update all submodules
	git submodule update --init

# now go through each submodule and update its submodules
	git submodule foreach git submodule update --init \; git submodule foreach git submodule update --init

	make xml
	make py

xml:
# now go through each submodule and build its xml DI file and sym link it in the $(XML_PARTS) directory
	git submodule foreach '\
	    XML_PATH=$(XML_PATH) make xml || :;'


py:
# now go through each submodule and symlink its py directory to the python parts library.
	mkdir -p py/nitro_parts
	touch py/nitro_parts/__init__.py
	git submodule foreach '\
	    if [ -d py/`basename $$path` ]; then \
              mkdir -p ../../../py/nitro_parts/`basename $$(dirname $$path)`; \
              touch ../../../py/nitro_parts/`basename $$(dirname $$path)`/__init__.py; \
              ln -s ../../../$$path/py/`basename $$path` ../../../py/nitro_parts/`basename $$(dirname $$path)`/ || :; \
	    fi;'


status:
	git submodule foreach 'git status | grep Changed || :; git submodule foreach "git status | grep Changed || :"'

pull:
	@git pull
	@git submodule --quiet foreach 'git status | grep -q modified && \
			   { echo "$$name has modified content. Commit or stash before make pull."; echo "X"; } || \
			   :' | grep -v X && exit 1 || echo "Submodules unmodified"
	@git submodule update --remote --recursive --rebase

clean:
	rm -rf $(XML_PATH)
	for x in py/nitro_parts/*; do \
           if [ -d $$x ]; then \
		rm -rf $$x; \
           fi \
        done
	git submodule foreach 'make clean || :'

#ver ?= $(shell python -c "import os, commands; words=open('nitro_parts.spec','r').read().split(); print words[words.index('Version:')+1] except: import commands; commands.getoutput('git rev-parse HEAD')[:10]')")

ver ?= $(shell python -c "`printf "import os, commands\nif os.path.exists('nitro_parts.spec'): words=open('nitro_parts.spec','r').read().split(); print words[words.index('Version:')+1]\nelse: print 'git' + commands.getoutput('git rev-parse HEAD')[:6]"`")

archive:
# create an archive of the built xml files and python files for rpm
# use 'make archive ver=xxx' for a specific version
#	$(MAKE) py
#	$(MAKE) xml
#	$(MAKE) xml
#	$(MAKE) xml
#	$(MAKE) xml
	gtar -chzf nitro_parts-$(ver).tgz --transform "s,^,/nitro_parts-$(ver)/," py parts


#install:
#	cp -r py/nitro_parts `python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`/
#	chmod -R 755 `python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`/nitro_parts
#	cp -r parts /usr/share/nitro_parts
#	chmod -R 755 /usr/share/nitro_parts
#	echo "Remeber to set NITRO_DI_PATH environment variable to /usr/share/nitro_parts"
#	echo " e.g. $ export NITRO_DI_PATH=/usr/share/nitro_parts"
#
#uninstall:
#	rm -rf 	`python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`/nitro_parts
#	rm -rf /usr/share/nitro_parts
