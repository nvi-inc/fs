#
#CFLAGS= -DDEBUG 
LIBES = ../rclco/rcl/rcl_cmd.o ../rclco/rcl/rcl_pkt.o ../rclco/rcl/rcl_sysn.o\
../rclco/rcl/rcl_util.o ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a 
#
OBJECTS = rclcn.o
#
../bin/rclcn: $(OBJECTS)
	cc  -o ../bin/rclcn $(OBJECTS) $(LIBES)
	strip ../bin/rclcn
#
rclcn:
	rm -f ../bin/rclcn
	make
