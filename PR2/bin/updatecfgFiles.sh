#!/bin/bash

##############################################################
#                                                            #
# script to update code start address and entry point        #
# in the config files after compilation                      #
#                                                            #
# call via:                                                  #
# ./updatecfgFiles.sh file.dump cfg_files_directory          #
#                                                            #
# embedd in Makefile in the target for dump creation:        #
# $(TARGET).dump: $(TARGET).elf                              # 
# 	$(MIPS_DUMP) $(MIPS_DUMP_FLAGS) $< > $(@:%.elf=%.dump)   #
#	-../../basics/updatecfgFiles.sh $(TARGET).dump .         #
#                                                            #
##############################################################

if [ $# != 2 ]
then
	echo "Usage:"
	echo "$0 file.elf cfg_files_directory"
	exit
fi

# obtaining code start address and entry point from dump file
ENTRY_POINT="0x"$(/cal/homes/brandner/opt/mips-2015.11/bin/mips-linux-gnu-objdump -Ss $1 | grep "<__start>" | sed 's/ <__start>://g')
CODE_START="0x"$(/cal/homes/brandner/opt/mips-2015.11/bin/mips-linux-gnu-objdump -Ss $1 | awk '/Contents of section/ { getline; print $1; exit; }')

echo "Entry: $ENTRY_POINT CodeStart: $CODE_START"

# checking every config file in the local directory for the right entry point
for i in $(ls $2/*.cfg)
do
	echo "Examining: $i"
	ENTRY_POINT_CFG=$(cat $i | grep entry_point | sed 's/entry_point=//g')
	CODE_START_CFG=$(cat $i | grep code_start_addr | sed 's/code_start_addr=//g')

	# entry point does not correspond to one in the config file, replacing it.
	if [ "$ENTRY_POINT" != "$ENTRY_POINT_CFG" ]
	then
		echo "Wrong entry_point ($ENTRY_POINT != $ENTRY_POINT_CFG) -> updating file."
		cat $i | sed "s/entry_point=$ENTRY_POINT_CFG/entry_point=$ENTRY_POINT/" > $i.$$
		mv $i.$$ $i
	fi

	# code start address does not correspond to one in the config file, replacing it.
	if [ "$CODE_START" != "$CODE_START_CFG" ]
	then
		echo "Wrong code_start_addr ($CODE_START != $CODE_START_CFG) -> updating file."
		cat $i | sed "s/code_start_addr=$CODE_START_CFG/code_start_addr=$CODE_START/" > $i.$$
		mv $i.$$ $i
	fi

	egrep -q "^file=" $i
	if [ $? ]
	then
    fo=`egrep "^file=" $i | head -n1`
    f=`egrep "^file=" $i | head -n1 | cut -f 2 -d=`
    d=`realpath $1 | sed s/.elf/.bin/`
    echo "Patching filename: $f -> $d"
    cat $i | sed "s|$fo|file=$d|" > $i.$$
		mv $i.$$ $i
	fi
done
