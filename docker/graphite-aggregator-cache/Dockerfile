FROM python:3.6
COPY . /bg/
WORKDIR /bg
RUN pip install carbon \
    && pip install -r requirements.txt \
    && pip install -e .
ENTRYPOINT ["tail", "-F", "/dev/null"]
