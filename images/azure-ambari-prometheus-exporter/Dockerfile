FROM python:3.9.0-alpine
MAINTAINER Revathi
RUN mkdir /src
WORKDIR /src
COPY requirements.txt /src/requirements.txt
RUN pip install -r requirements.txt
ADD collector.py /src/collector.py
ADD components.yaml /src/components.yaml
EXPOSE 9999
CMD ["python", "collector.py"]
