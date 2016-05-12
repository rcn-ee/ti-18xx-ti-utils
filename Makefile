CC = $(CROSS_COMPILE)gcc
CFLAGS = -O2 -Wall
CFLAGS += -I$(NFSROOT)/usr/include -I$(NFSROOT)/include -I/usr/include/libnl3/

ifdef NLROOT
CFLAGS += -I${NLROOT}
endif

LDFLAGS += -L$(NFSROOT)/lib
LIBS += -lm

#ifeq ($(NLVER),3)
	CFLAGS+=-DCONFIG_LIBNL32
	LIBS += -lnl-3 -lnl-genl-3
#else
#	CFLAGS+=-DCONFIG_LIBNL20
#	LIBS += -lnl -lnl-genl
#endif

OBJS = nvs.o misc_cmds.o calibrator.o plt.o wl18xx_plt.o ini.o

%.o: %.c calibrator.h nl80211.h plt.h nvs_dual_band.h
	$(CC) $(CFLAGS) -c -o $@ $<

all: $(OBJS) 
	$(CC) $(LDFLAGS) $(OBJS) $(LIBS) -o calibrator

uim:
	$(CC) $(CFLAGS) $(LDFLAGS) uim_rfkill/$@.c -o $@

static: $(OBJS) 
	$(CC) $(LDFLAGS) --static $(OBJS) $(LIBS) -o calibrator

install:
	@echo Copy files to /usr/local/bin
	@cp -f ./calibrator /usr/local/bin
	@chmod 755 /usr/local/bin/calibrator

clean:
	@rm -f *.o calibrator uim
