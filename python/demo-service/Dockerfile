FROM python:3.11.4-alpine3.17
ADD requirements.txt /requirements.txt
RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip3 install -r /requirements.txt
ADD demoService.py /demoService.py
CMD ["python3", "/demoService.py"]