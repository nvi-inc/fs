#
OBJECTS=\
rte_alarm.o rte_sleep.o rte_time.o rte_fpmask.o rte_prior.o rte_lock.o\
rte2secs.o
#
rtelb.a: $(OBJECTS)
	touch rtelb.a
	rm rtelb.a
	ar qc rtelb.a $(OBJECTS)
