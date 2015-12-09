SUBDIRS =
DESTDIR =
UBINDIR ?= /usr/bin
LIBDIR ?= /usr/lib
SBINDIR ?= /sbin
USBINDIR ?= /usr/sbin
BINDIR ?= /bin
LIBEXECDIR ?= /usr/libexec
SYSCONFDIR ?= /etc

all:
	for d in $(SUBDIRS); do $(MAKE) -C $$d; done

clean:
	for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done

install:
	for d in $(SUBDIRS); do $(MAKE) -C $$d install; done

	install -d $(DESTDIR)/$(SBINDIR)
	install -d $(DESTDIR)/$(BINDIR)
	install -m 0755 *-functions.sh $(DESTDIR)/$(SBINDIR)/

	install -d $(DESTDIR)/$(USBINDIR)
	install -m 0755 docker_clean $(DESTDIR)/$(USBINDIR)/
	install -m 0755 docker_clean_containers $(DESTDIR)/$(USBINDIR)/
	install -m 0755 docker_clean_images $(DESTDIR)/$(USBINDIR)/

	install -d $(DESTDIR)/$(UBINDIR)
	install -m 0755 docker_squash $(DESTDIR)/$(UBINDIR)/
	install -m 0755 entropy_container $(DESTDIR)/$(UBINDIR)/
	install -m 0755 playground_container $(DESTDIR)/$(UBINDIR)/
	install -m 0755 hook_container $(DESTDIR)/$(UBINDIR)/
	install -m 0755 spawn_container $(DESTDIR)/$(UBINDIR)/
