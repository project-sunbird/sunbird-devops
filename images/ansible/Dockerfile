FROM alpine:3.5
# making an addtional layer as ssh and python are necessory
# so caching will be efficient
RUN apk --update --no-cache add openssh python-dev
RUN apk --update --no-cache add build-base libffi-dev openssl-dev py-pip \
 && pip install cffi && pip install ansible==2.4.1 \
 && pip uninstall -y cffi \
 && apk del build-base libffi-dev openssl-dev &&rm -rf /root/cache \
 && mkdir /ansible 
ENV ANSIBLE_HOST_KEY_CHECKING=False
ENV SSH_AUTH_SOCK=/ssh-agent
WORKDIR /ansible
CMD ["nc", "-k", "-l", "8000"]

