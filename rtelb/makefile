#
OBJECTS=\
rte_alarm.o rte_sleep.o rte_time.o rte_prior.o rte_lock.o\
rte2secs.o rte_rawt.o rte_sett.o rte_fixt.o rte_secs.o rte_cmpt.o secs2rte.o\
rte_ticks.o
#
CFLAGS = 
rtelb.a: $(OBJECTS)
	touch rtelb.a
	rm rtelb.a
	ar -qc rtelb.a $(OBJECTS)
	ar s rtelb.a
