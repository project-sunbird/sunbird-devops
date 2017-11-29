FROM vfarcic/jenkins-swarm-agent:17.10.07-4
ENV CQLSH_VERSION=5.0.3

RUN apk --update add tar curl && \
    pip install cassandra-driver

RUN mkdir -p /usr/var/cqlsh && \
    curl -SL https://pypi.python.org/packages/12/a7/13aff4ad358ff4abef6823d872154d0955ff6796739fcaaa2c80a6940aa6/cqlsh-${CQLSH_VERSION}.tar.gz \
    | tar xzvC /usr/var && \
    /usr/var/cqlsh-${CQLSH_VERSION}/cqlsh --version