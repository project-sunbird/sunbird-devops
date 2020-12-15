FROM python:3.9.0-alpine
MAINTAINER Revathi Kotla <revathi21kotla@gmail.com>
RUN mkdir /src
WORKDIR /src
COPY requirements.txt /src/requirements.txt
RUN pip install -r requirements.txt
COPY collector.py /src/collector.py
COPY components.yaml /src/components.yaml
EXPOSE 9999
CMD ["python", "collector.py"]
