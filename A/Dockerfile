FROM ubuntu:20.04

RUN apt-get update && apt-get install openssh-client expect -y 

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

CMD ["/bin/bash"]