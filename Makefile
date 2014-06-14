
clean:
	find . \( -name '*~' -o -name '*.bak' \) -delete || true

tidy:
	perltidy $$(find . -name '*.pm')

test:
	prove --shuffle t/

upload:
	rsync -vazr --exclude=.git* . www.steve.org.uk:/etc/service/dns-api.org/
	ssh www.steve.org.uk sv restart /etc/service/dns-api.org/