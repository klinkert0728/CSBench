FROM python:3.10

COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY reading_client.py /

CMD ["python," "/reading_client.py"]