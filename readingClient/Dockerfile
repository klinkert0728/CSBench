FROM python:3.10

COPY readingClient/requirements.txt /
RUN pip install -r /requirements.txt

COPY readingClient/reading_client.py /

CMD ["python3" "/reading_client.py", "ARG IP"]