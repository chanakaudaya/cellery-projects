#!/bin/bash

ballerina build airline_reservation_service.bal
ballerina build car_rental_service.bal
ballerina build hotel_reservation_service.bal
ballerina build travel_agency_service.bal

docker push chanakaudaya/airline_reservation_service:v5.0
docker push chanakaudaya/car_rental_service:v5.0
docker push chanakaudaya/hotel_reservation_service:v5.0
docker push chanakaudaya/travel_agency_service:v5.0


