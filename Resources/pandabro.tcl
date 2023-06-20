#! /bin/env tclsh

#-----------------------------------------------------------#
#----- Checks whether panda usage is correct or not -----#
#-----------------------------------------------------------#

set generate_sdc 1
set enable_prelayout_timing 1
set working_dir [exec pwd]
set pan_array_length [llength [split [lindex $argv 0] .]]
set input [lindex [split [lindex $argv 0] .] $pan_array_length-1]

#puts [lindex $argv 0]
#puts [split [lindex $argv 0] .]
#uts [llength [split [lindex $argv 0] .]]

#puts $input

if {![regexp {csv} $input] || $argc!=1 } {
	puts "Error in usage"
	puts "Usage: ./panda <.csv>"
	puts "where <.csv> file has below inputs"
	exit
} else {
#-----------------------------------------------------------------------------------------------------------------------------------------------------#
#------ converts .csv to matrix and creates initial variables "DesignName OutputDirectory NetlistDirectory EarlyLibraryPath LateLibraryPath"----------#
#----------- If you are modifying this script, please use above variables as starting point. Use "puts" command to report above variables-------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------#
	set filename [lindex $argv 0]
	package require csv
	package require struct::matrix
	struct::matrix m
	set f [open $filename]
	csv::read2matrix $f m , auto
	close $f
	set columns [m columns]
	#m add columns $columns
	m link my_arr
	set rows [m rows]
	set i 0
	while {$i < $rows} {
		 puts "\nInfo: Setting $my_arr(0,$i) as '$my_arr(1,$i)'"
		 if {$i == 0} {
			 set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
		 } else {
			 set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
		 }
		  set i [expr {$i+1}]
	}
} 

#puts "\nInfo: Below are the list of initial variables and their values. User can use these variables for further debug. Use 'puts <variable name>' command to query value of below variables"
#puts "DesignName = $DesignName"
#puts "OutputDirectory = $OutputDirectory"
#puts "NetlistDirectory = $NetlistDirectory"
#puts "EarlyLibraryPath = $EarlyLibraryPath"
#puts "LateLibraryPath = $LateLibraryPath"
#puts "ConstraintsFile = $ConstraintsFile"


#-------------------------------------------------------------------------------------------#
#-----Below script checks if directories and files mentioned in csv file, exists or not-----#
#-------------------------------------------------------------------------------------------#

if {! [file exists $EarlyLibraryPath] } {
	puts "\nError: Cannot find early cell library in path $EarlyLibraryPath. Exiting... "
	exit
} else {
	puts "\nInfo: Early cell library found in path $EarlyLibraryPath"
}


if {! [file exists $LateLibraryPath]} {
        puts "\nError: Cannot find late cell library in path $LateLibraryPath. Exiting... "
        exit 1
} else {
	puts "\nInfo: Late cell library found in path $LateLibraryPath"
}

if {![file isdirectory $OutputDirectory]} {
	puts "\nInfo: Cannot find output directory $OutputDirectory. Creating $OutputDirectory"
	file mkdir $OutputDirectory
} else {
	puts "\nInfo: Output directory found in path $OutputDirectory"
}

if {! [file isdirectory $NetlistDirectory]} {
	puts "\nError: Cannot find RTL netlist directory in path $NetlistDirectory. Exiting..."
	exit	
} else {
	puts "\nInfo: RTL netlist directory found in path $NetlistDirectory"
}

if {! [file exists $ConstraintsFile] } {
        puts "\nError: Cannot find constraints file in path $ConstraintsFile. Exiting... "
        exit
} else {
        puts "\nInfo: Constraints file found in path $ConstraintsFile"
}
#----------------------------------------------------------------------------#
#----------------------  Constraints FILE creations--------------------------#
#----------------------------- SDC Format -----------------------------------#
#----------------------------------------------------------------------------#

if {$generate_sdc == 1} {
puts "\nInfo: Dumping SDC constraints for $DesignName"
struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints , auto
close $chan
set number_of_rows [constraints rows]
set number_of_columns [constraints columns]

#puts "\nrows = $number_of_rows"
#puts "\ncolumns = $number_of_columns"
#-----check row number for "clocks" and column number for "IO delays and slew section" in constraints.csv---#

set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1] 
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0 ] 0] 
set clock_period_start [lindex [lindex [constraints search all frequency] 0] 0] 
set duty_cycle_start [lindex [lindex [constraints search all duty_cycle] 0] 0] 

#puts "\nclock_start = $clock_start"
#puts "\nclock_start_column = $clock_start_column"
#puts "clock_period = $clock_period"
 
#-----check row number for "inputs" section in constraints.csv---##
set input_ports_start [lindex [lindex [constraints search all INPUTS] 0 ] 1]

#puts "\ninput_ports_start = $input_ports_start" 

#-----check row number for "outputs" section in constraints.csv---##
set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0 ] 1]

#puts "\noutput_ports_start = $output_ports_start"

#-------------------clock constraints--------------------##
#-------------------clock latency constraints------------#

set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  early_rise_delay] 0 ] 0]

set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  early_fall_delay] 0 ] 0]

set clock_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  late_rise_delay] 0 ] 0]

set clock_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  late_fall_delay] 0 ] 0]

#-------------------clock transition constraints------------#

set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  early_rise_slew] 0 ] 0]

set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  early_fall_slew] 0 ] 0]

set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  late_rise_slew] 0 ] 0]

set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  late_fall_slew] 0 ] 0]

set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start-1}]
puts "\nInfo-SDC: Working on clock constraints....."
while { $i < $end_of_ports } {
	#puts "working on [constraints get cell $clock_start $i]...."
    puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell $clock_start $i] -period [constraints get cell $clock_period_start $i] -waveform \{0 [expr {[constraints get cell $clock_period_start $i]*[constraints get cell $duty_cycle_start $i]/100}]\} \[get_ports [constraints get cell $clock_start $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
    puts -nonewline $sdc_file "\nset_clock_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
    puts -nonewline $sdc_file "\nset_clock_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
    puts -nonewline $sdc_file "\nset_clock_latency  -min -rise [constraints get cell $clock_early_rise_delay_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
    puts -nonewline $sdc_file "\nset_clock_latency  -min -fall [constraints get cell $clock_early_fall_delay_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
    puts -nonewline $sdc_file "\nset_clock_latency  -max -rise [constraints get cell $clock_late_rise_delay_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
    puts -nonewline $sdc_file "\nset_clock_latency  -max -fall [constraints get cell $clock_late_fall_delay_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
    set i [expr {$i+1}]
}

#------------------------------------------------------------------------------##
#-------------------create input delay and slew constraints--------------------##
#------------------------------------------------------------------------------##

set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_rise_delay] 0 ] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_fall_delay] 0 ] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_rise_delay] 0 ] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_fall_delay] 0 ] 0]

set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_rise_slew] 0 ] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_fall_slew] 0 ] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_rise_slew] 0 ] 0]
set input_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_fall_slew] 0 ] 0]

set related_clock [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  clocks] 0 ] 0]
#set bussed_status [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  bussed] 0 ] 0]
#puts "\n a = $bussed_status"

set i [expr {$input_ports_start+1}]
set end_of_ports [expr {$output_ports_start-1}]
puts "\nInfo-SDC: Working on IO constraints....."
puts "\nInfo-SDC: Categorizing input ports as bits and bussed"

while { $i < $end_of_ports } {
#---------------differentiating input ports as bussed and bits-------------------#
#glob command is used to match all the files with the same pattern as specified. In our case its matching all the .v files in $NetlistDirectory.
#$netlist will have the path as well as the files stored in it separated by a space 
set netlist [glob -dir $NetlistDirectory *.v] 
set tmp_file [open ./temp/1 w]

#$f will have each file that is present in $netlist. u open the file using fd. u read each line of the file using gets command.
# u set a pattern1 as the name of the input. then compare in each line to check whether it exists using regexp. 
#if it does ull split and take the 0 index term with delimiter as ";". now check if all lines have first term as input by removing spaces b/w in them. 
#if they do make a string s1 by removing the the spaces. finally enter these into $tmp_file while subbing multiple sapces by a single space. now close $fd
foreach f $netlist {
        set fd [open $f]
		#puts "reading file $f"
        while {[gets $fd line] != -1} {
			set pattern1 " [constraints get cell 0 $i];"
            if {[regexp -all -- $pattern1 $line]} {
				#puts "\npattern1 \"$pattern1\" found and matching line in verilog file \"$f\" is \"$line\""
				set pattern2 [lindex [split $line ";"] 0]
				#puts "\ncreating pattern2 by splitting pattern1 using semi-colon as delimiter => \"$pattern2\""
				if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {	
					#puts "\nout of all patterns, \"$pattern2\" has matching string \"input\". So preserving this line and ignoring others"
					set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
					#puts "\nprinting first 3 elements of pattern as \"$s1\" using space as delimiter"
					puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
					#puts "\nreplace multiple spaces in s1 by space and reformat as \"[regsub -all {\s+} $s1 " "]\""
				} 
#				else { puts " \"$pattern2\" didnt have first term as 'input'" }
       		}
   		}
close $fd
}
close $tmp_file

set tmp_file [open ./temp/1 r]
set tmp2_file [open ./temp/2 w]
#read the $tmp_file ; split with \n as delimiter ; lsort - unique --> takes only unique 1 value; join with \n as delimiter; o/p is just 1 input line
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
#each time u open a file in write mode the data in side is overwritten
close $tmp_file
close $tmp2_file
set tmp2_file [open ./temp/2 r]
#count is set to check bussed and non bussed ports
set count [llength [read $tmp2_file]] 
#puts "\nsplitting content of tmp_ using space and counting number of elements as $count"
#set check_bussed [constraints get cell $bussed_status $i]
if {$count > 2} { 
	set inp_ports [concat [constraints get cell 0 $i]*]
	#puts "\nbussed" 
} else {
	set inp_ports [constraints get cell 0 $i]
	#puts "\nnot bussed"
}
	#puts "\ninput port name is $inp_ports since count is $count\n"
        puts -nonewline $sdc_file "\nset_input_delay -clock  [constraints get cell $related_clock $i] -min -rise  [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  [constraints get cell $related_clock $i] -min -fall  [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  [constraints get cell $related_clock $i] -max -rise  [constraints get cell $input_late_rise_delay_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  [constraints get cell $related_clock $i] -max -fall  [constraints get cell $input_late_fall_delay_start $i] \[get_ports $inp_ports\]"

        puts -nonewline $sdc_file "\nset_input_transition -clock  [constraints get cell $related_clock $i] -min -rise  [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  [constraints get cell $related_clock $i] -min -fall  [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  [constraints get cell $related_clock $i] -max -rise  [constraints get cell $input_late_rise_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  [constraints get cell $related_clock $i] -max -fall  [constraints get cell $input_late_fall_slew_start $i] \[get_ports $inp_ports\]"


        set i [expr {$i+1}]
}
close $tmp2_file

#------------------------------------------------------------------------------##
#-------------------create output delay and load constraints--------------------##
#------------------------------------------------------------------------------##

set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  early_rise_delay] 0 ] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  early_fall_delay] 0 ] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  late_rise_delay] 0 ] 0]
set output_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  late_fall_delay] 0 ] 0]
set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  load] 0 ] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  clocks] 0 ] 0]
#et bussed_status [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  bussed] 0 ] 0]

set i [expr {$output_ports_start+1}]
set end_of_op_ports [expr {$number_of_rows}]
puts "\nInfo-SDC: Working on IO constraints....."
puts "\nInfo-SDC: Categorizing output ports as bits and bussed"

while { $i < $end_of_op_ports } {
#----------------differentiating output ports as bussed and bits-----------------------#
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open ./temp/1 w]
foreach f $netlist {
        set fd [open $f]
		#puts "reading file $f"
        while {[gets $fd line] != -1} {
			set pattern1 " [constraints get cell 0 $i];"
            if {[regexp -all -- $pattern1 $line]} {
			#puts "\npattern1 \"$pattern1\" found and matching line in verilog file \"$f\" is \"$line\""
				set pattern2 [lindex [split $line ";"] 0]
			#puts "\ncreating pattern2 by splitting pattern1 using semi-colon as delimiter => \"$pattern2\""
				if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {	
			#puts "\nout of all patterns, \"$pattern2\" has matching string \"input\". So preserving this line and ignoring others"
				set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
				#puts "\nprinting first 3 elements of pattern as \"$s1\" using space as delimiter"
				puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
				#puts "\nreplace multiple spaces in s1 by space and reformat as \"[regsub -all {\s+} $s1 " "]\""
				}
				#else { " \"$pattern2\" didnt have first term as 'output'"}
        	}
        }
close $fd
}
close $tmp_file
set tmp_file [open ./temp/1 r]
set tmp2_file [open ./temp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open ./temp/2 r]
set count [llength [read $tmp2_file]] 
#puts "\nsplitting content of tmp_ using space and counting number of elements as $count"
#set check_bussed [constraints get cell $bussed_status $i]
if {$count > 2} { 
    set op_ports [concat [constraints get cell 0 $i]*]
	#puts "\nbussed"
} else {
    set op_ports [constraints get cell 0 $i]
	#puts "\nnot bussed"
}
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $related_clock $i] -min -rise  [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $related_clock $i] -min -fall  [constraints get cell $output_early_fall_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $related_clock $i] -max -rise  [constraints get cell $output_late_rise_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $related_clock $i] -max -fall  [constraints get cell $output_late_fall_delay_start $i] \[get_ports $op_ports\]"
		puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i] \[get_ports $op_ports\]"

	set i [expr {$i+1}]
}
close $tmp2_file
close $sdc_file

puts "\nInfo: SDC created. Please use constraints in path  $OutputDirectory/$DesignName.sdc"
}

#----------------------------------------------------------------------------#
#--------------------------------Hierarchy Check-----------------------------#
#----------------------------------------------------------------------------#

puts "\nInfo: Creating hierarchy check script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
#puts "data is \"$data\""
set filename "$DesignName.hier.ys"
#puts "filename is \"$filename\""
set fileId [open $OutputDirectory/$filename "w"]
#puts "open \"$OutputDirectory/$filename\" in write mode"
#dump $data into $fileId which has called $filename in write mode
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
#puts "netlist is \"$netlist\""
foreach f $netlist {
	set data $f
	#puts "data is \*$f\""
	puts -nonewline $fileId "\nread_verilog $f"
}

puts -nonewline $fileId "\nhierarchy -check"
close $fileId 

#puts "\nclose \"$OutputDirectory/$filename\"\n"
puts "\nInfo: Checking hierarchy ....."
# [catch {...} msg] to find any errors/exceptions; exec to run a UNIX shell command ;>& to dump execution text in <file>
set my_err [catch { exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
#puts "err flag is $my_err"
if { $my_err } {
	set filename "$OutputDirectory/$DesignName.hierarchy_check.log"
	#puts "log file name is $filename"
	set pattern "referenced in module"
	#puts "pattern is $pattern"
	set count 0
	set fid [open $filename r]
	while {[gets $fid line] != -1} {
		# -- used to say end of command options. everything after this is args
		incr count [regexp -all -- $pattern $line]
		if {[regexp -all -- $pattern $line]} {
			puts "\nError: module [lindex $line 2] is not part of design $DesignName. Please correct RTL in the path '$NetlistDirectory'"
			puts "\nInfo: Hierarchy check FAIL"
		}
	}
	close $fid
} else {
	puts "\nInfo: Hierarchy check PASS"
}
puts "\nInfo: Please find hierarchy check in details in [file normalize $OutputDirectory/$DesignName.hierarchy_check.log] for more info"
cd $working_dir

#----------------------------------------------------------------------------#
#--------------------------Main synthesis script-----------------------------#
#----------------------------------------------------------------------------#
puts "\nInfo: Creating main synthesis script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
#puts "filename is \"$filename\""
set fileId [open $OutputDirectory/$filename "w"]
#puts "open \"$OutputDirectory/$filename\" in write mode"
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
	set data $f
	puts -nonewline $fileId "\nread_verilog $f"
}

puts -nonewline $fileId "\nhierarchy -top $DesignName"
puts -nonewline $fileId "\nsynth -top $DesignName"
puts -nonewline $fileId "\nsplitnets -ports -format __\ndfflibmap -liberty ${LateLibraryPath}\nopt"
puts -nonewline $fileId "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge \niopadmap -outpad BUFX2 A:Y -bits \nopt \nclean"
puts -nonewline $fileId "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileId
puts "\nInfo: Synthesis script created and can be accessed from path $OutputDirectory/$DesignName.ys"
puts "\nInfo: Running synthesis............."

#----------------------------------------------------------------------------#
#----------------------Run synthesis script using yosys----------------------#
#----------------------------------------------------------------------------#
if { !$my_err } {
	set my_err1 [catch { exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]
	if { $my_err1 } {
	puts "\nError: Synthesis failed due to errors. Please refer to log $OutputDirectory/$DesignName.synthesis.log for errors"
	puts "\nInfo: Please refer to $OutputDirectory/$DesignName.synthesis.log"
	exit
	} else {
	puts "\nInfo: Synthesis finished successfully"
	puts "\nInfo: Please refer to $OutputDirectory/$DesignName.synthesis.log"
	}
} else {
	puts "Refer to [file normalize $OutputDirectory/$DesignName.hierarchy_check.log]. Need to ensure Hierachy Check Pass "
}


#----------------------------------------------------------------------------#
#----------------Edit synth.v to be usable by Opentimer----------------------#
#----------------------------------------------------------------------------#


set fileId [open ./temp/1 "w"]
puts -nonewline $fileId [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileId

set output [open $OutputDirectory/$DesignName.final.synth.v "w"]

set filename "./temp/1"
set fid [open $filename r]
	while {[gets $fid line] != -1} {
	puts -nonewline $output [string map {"\\" " "} $line]
	puts -nonewline $output "\n"
}
close $fid 
close $output

puts "\ninfo: Please find the synthesized netlist for $DesignName at below path. You can use this netlist for STA or PNR"
puts "\n$OutputDirectory/$DesignName.final.synth.v"

#----------------------------------------------------------------------------#
#-------------------------STA using Opentimer--------------------------------#
#----------------------------------------------------------------------------#

puts "\nInfo: Timing Analysis Started ... "
puts "\nInfo: initializing number of threads, libraries, sdc, verilog netlist path..."
source /home/vsduser/vsdsynth/procs/reopenStdout.proc
source /home/vsduser/vsdsynth/procs/set_num_threads.proc
reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 8

source /home/vsduser/vsdsynth/procs/read_lib.proc
read_lib -early /home/vsduser/vsdsynth/osu018_stdcells.lib

read_lib -late /home/vsduser/vsdsynth/osu018_stdcells.lib

source /home/vsduser/vsdsynth/procs/read_verilog.proc
read_verilog $OutputDirectory/$DesignName.final.synth.v

source /home/vsduser/vsdsynth/procs/read_sdc.proc
read_sdc $OutputDirectory/$DesignName.sdc
reopenStdout /dev/tty

if {$enable_prelayout_timing == 1} {
	puts "\nInfo: enable prelayout_timing is $enable_prelayout_timing. Enabling zero-wire load parasitics"
	set spef_file [open $OutputDirectory/$DesignName.spef w]
	puts $spef_file "*SPEF \"IEEE 1481-1998\""
	puts $spef_file "*DESIGN \"$DesignName\""
	puts $spef_file "*DATE \"Sun Jun 11 11:59:00 2023\""
	puts $spef_file "*VENDOR \"VLSI System Design\""
	puts $spef_file "*PROGRAM \"TCL Workshop\""
	puts $spef_file "*DATE \"0.0\""
	puts $spef_file "*DESIGN FLOW \"NETLIST_TYPE_VERILOG\""
	puts $spef_file "*DIVIDER /"
	puts $spef_file "*DELIMITER : "
	puts $spef_file "*BUS_DELIMITER [ ]"
	puts $spef_file "*T_UNIT 1 PS"
	puts $spef_file "*C_UNIT 1 FF"
	puts $spef_file "*R_UNIT 1 KOHM"
	puts $spef_file "*L_UNIT 1 UH"
}
close $spef_file

set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer"
puts $conf_file "report_timer"
puts $conf_file "report_wns"
puts $conf_file "report_tns"
puts $conf_file "report_worst_paths -numPaths 10000 " 
close $conf_file


#------------------------find STA runtime--------------------------------#
set tcl_precision 3
set time_elapsed_in_us [time {exec /home/vsduser/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results} 1]
#puts "time_elapsed_in_us is $time_elapsed_in_us"
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}]sec"
#puts "time_elapsed_in_sec is $time_elapsed_in_sec"
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"


#-------------------------find worst output violation--------------------------------#
set worst_RAT_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {RAT}
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		set worst_RAT_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file

#-------------------------find number of output violations--------------------------------#	
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_output_violations $count
close $report_file

#-------------------------find worst setup violation--------------------------------#
set worst_negative_setup_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r] 
set pattern {Setup}
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		set worst_negative_setup_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file

#-------------------------find number of setup violations--------------------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_of_setup_violations $count
close $report_file

#-------------------------find worst hold violation--------------------------------#
set worst_negative_hold_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r] 
set pattern {Hold}
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		set worst_negative_hold_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file

#-------------------------find number of hold violations--------------------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_of_hold_violations $count
close $report_file

#-------------------------find number of instances--------------------------------#

set pattern {Num of gates}
set report_file [open $OutputDirectory/$DesignName.results r] 
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		set Instance_count "[lindex [join $line " "] 4 ]"
		break
	} else {
		continue
	}
}
close $report_file

#puts "DesignName is \{$DesignName\}"
#puts "time_elapsed_in_sec is \{$time_elapsed_in_sec\}"
#puts "Instance_count is \{$Instance_count\}"
#puts "worst_negative_setup_slack is \{$worst_negative_setup_slack\}"
#puts "Number_of_setup_violations is \{$Number_of_setup_violations\}"
#puts "worst_negative_hold_slack is \{$worst_negative_hold_slack\}"
#puts "Number_of_hold_violations is \{$Number_of_hold_violations\}"
#puts "worst_RAT_slack is \{$worst_RAT_slack\}"
#puts "Number_output_violations is \{$Number_output_violations\}"

puts "\n"
puts "						****PRELAYOUT TIMING RESULTS**** 					"
set formatStr "%15s %15s %15s %15s %15s %15s %15s %15s %15s"

puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts [format $formatStr "DesignName" "Runtime" "Instance Count" "WNS Setup" "FEP Setup" "WNS Hold" "FEP Hold" "WNS RAT" "FEP RAT"]
puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
foreach design_name $DesignName runtime $time_elapsed_in_sec instance_count $Instance_count wns_setup $worst_negative_setup_slack fep_setup $Number_of_setup_violations wns_hold $worst_negative_hold_slack fep_hold $Number_of_hold_violations wns_rat $worst_RAT_slack fep_rat $Number_output_violations {
	puts [format $formatStr $design_name $runtime $instance_count $wns_setup $fep_setup $wns_hold $fep_hold $wns_rat $fep_rat]
}

puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts "\n"
	



