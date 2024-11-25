.PHONY: ecosensor db osm istat openmeteo all stop refresh clean

ecosensor:
	docker-compose --profile ecosensor up

db:
	docker-compose --profile db up

osm:
	docker-compose --profile osm up

istat:
	docker-compose --profile istat up

openmeteo:
	docker-compose --profile openmeteo up

all:
	docker-compose --profile ecosensor --profile db --profile osm --profile istat --profile openmeteo up

clean:
	docker-compose down --rmi all
	docker-compose pull