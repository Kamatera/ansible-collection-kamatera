FROM ubuntu:18.04
RUN apt update && apt install -y software-properties-common &&\
    apt-add-repository --yes --update ppa:ansible/ansible &&\
    apt install -y ansible python
RUN mkdir /opt/ansible-collection-kamatera
WORKDIR /opt/ansible-collection-kamatera
COPY plugins plugins
COPY tests tests
COPY galaxy.yml .
RUN ansible-galaxy collection build . &&\
    ansible-galaxy collection install kamatera-kamatera-*.tar.gz
ENTRYPOINT ["tests/test_compute.sh"]
