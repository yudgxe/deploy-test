restart: rm build run

build:
	docker build -t sshd_image .

run:
	docker run -d --name sshd_container -p 2022:22 sshd_image

rm: 
	docker stop sshd_container
	docker rm sshd_container
