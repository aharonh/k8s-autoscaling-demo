FROM python:3.11.4-alpine3.17
ADD requirements.txt /requirements.txt
RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip3 install -r /requirements.txt
RUN mkdir -p /app/templates
ADD demoClient.py /app/demoClient.py
ADD login.html /app/login.html
ADD templates/publish.html /app/templates/publish.html
WORKDIR /app/
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0", "demoClient:app"]
