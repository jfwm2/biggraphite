FROM python:3.6
COPY . /bg/
WORKDIR /bg
ENV GRAPHITE_NO_PREFIX=true
RUN pip install graphite-web \
    && pip install -r requirements.txt \
    && pip install -e .
ENTRYPOINT ["tail", "-F", "/dev/null"]
