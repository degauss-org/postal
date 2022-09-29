.PHONY: build test shell clean

build:
	docker build --platform="amd64" -t postal .

test:
	docker run --rm -v "${PWD}/test":/tmp postal address.csv
	docker run --rm -v "${PWD}/test":/tmp postal address.csv expand
	docker run --rm -v "${PWD}/test":/tmp postal address_stub.csv
	docker run --rm -v "${PWD}/test":/tmp postal address_stub.csv expand

shell:
	docker run --rm -it --entrypoint=/bin/bash -v "${PWD}/test":/tmp postal

clean:
	docker system prune -f
