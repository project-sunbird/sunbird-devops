FROM vfarcic/jenkins-swarm-agent:17.10.07-4

USER root
RUN apk --update add sudo && \
    apk --update add python py-pip openssl ca-certificates && \
    apk --update add --virtual build-dependencies python-dev libffi-dev openssl-dev build-base && \
    pip install --upgrade pip cffi && \
    pip install "ansible==2.1.3"
RUN pip install PyJWT
RUN apk add --virtual build-deps gcc python-dev musl-dev && \
    apk add py2-psycopg2
RUN pip install retry
