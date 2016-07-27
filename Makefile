
clean:
	find . \( -name '*~' -o -name '*.bak' \) -delete || true

tidy:
	perltidy $$(find . -name '*.pm')

test:
	prove --shuffle t/

deploy:
	ssh s-dns-org@www.steve.org.uk git pull
	ssh www.steve.org.uk sv restart /etc/service/dns-api.org/
