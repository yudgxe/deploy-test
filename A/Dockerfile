FROM ubuntu:20.04

RUN apt-get update && apt-get install openssh-client expect -y 

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

COPY create_key.sh /usr/local/bin/create_key.sh
RUN chmod +x /usr/local/bin/create_key.sh

COPY block_tcp_input.sh /usr/local/bin/block_tcp_input.sh

CMD ["/bin/bash"]