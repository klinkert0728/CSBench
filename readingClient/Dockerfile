FROM python:3.8-slim-buster

COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY reading_client.py /

ENTRYPOINT ["python3", "/reading_client.py"]