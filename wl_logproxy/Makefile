CC = $(CROSS_COMPILE)gcc
CFLAGS = -O2 -Wall
CFLAGS += -I$(NFSROOT)/usr/include -I$(NFSROOT)/include

ifdef NLROOT
CFLAGS += -I${NLROOT}
endif

LDFLAGS += -L$(NFSROOT)/lib
LIBS += -lm

ifeq ($(NLVER),3)
	CFLAGS+=-DCONFIG_LIBNL32
	LIBS += -lnl-3 -lnl-genl-3
else
	CFLAGS+=-DCONFIG_LIBNL20
	LIBS += -lnl -lnl-genl
endif

OBJS = wl_logproxy.o

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

all: $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) $(LIBS) -o wl_logproxy

uim:
	$(CC) $(CFLAGS) $(LDFLAGS) uim_rfkill/$@.c -o $@

static: $(OBJS)
	$(CC) $(LDFLAGS) --static $(OBJS) $(LIBS) -o wl_logproxy

install:
	@echo Copy files to $(NFSROOT)/usr/share/wl18xx
	@cp -f ./wl_logproxy $(NFSROOT)/usr/share/wl18xx
	@chmod 755 $(NFSROOT)/usr/share/wl18xx/wl_logproxy

clean:
	@rm -f *.o wl_logproxy uim
