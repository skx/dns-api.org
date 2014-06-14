
clean:
	rm *~ *.bak || true

tidy:
	perltidy dns-api

test:
	prove --shuffle t/

upload:
	rsync -vazr . root@www.steve.org.uk:/etc/service/dns-api.org/
	ssh www.steve.org.uk sv restart /etc/service/dns-api.org/