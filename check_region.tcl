##########################################
# Procedure: check_region
# Checks the current region for gridding
# Projects coordinates if necessary
# Returns number of tiles if region is too large.
proc check_region { } {
global env REGION RESOLUTION mem_size


set mem_size_calc [expr $mem_size * 25000]

set reg "$REGION(0) $REGION(1) $REGION(3) $REGION(2)"
set brk_flag 0

if { ($REGION(0) > -90. && $REGION(0) < 90.) && \
    ($REGION(1) > -90. && $REGION(1) < 90.) && \
    ($REGION(2) > -360. && $REGION(2) < 360.) && \
    ($REGION(3) > -360. && $REGION(2) < 360.) } {
set reg [proj_region]
set REGION(0) [lindex $reg 0]
set REGION(1) [lindex $reg 1]
set REGION(3) [lindex $reg 2]
set REGION(2) [lindex $reg 3]
set REGION(4) $RESOLUTION
set REGION(5) $RESOLUTION
}

set rows [expr 1 + ceil((ceil([lindex $reg 0])-floor([lindex $reg 1]))/$RESOLUTION)]
set cols [expr 1 + ceil((ceil([lindex $reg 2])-floor([lindex $reg 3]))/$RESOLUTION)]
set size [expr $rows*$cols]
set aspect [expr $rows/$cols]

if {$size > $mem_size_calc} {
	set brk [expr ceil($size / $mem_size_calc)]
	Do_Command "g.region -a n=[lindex $reg 0] s=[lindex $reg 1] \
	e=[lindex $reg 2] w=[lindex $reg 3] res=$RESOLUTION"
	if {$rows > $cols} {set brk_flag 1}
	return "1 $brk $brk_flag $aspect"
} else {
	return 0
}

}

