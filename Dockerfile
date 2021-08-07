FROM debian:latest

ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y -qq python3 python3-pip curl zip bash

#RUN apk add --update --no-cache python3 curl zip bash  && ln -sf python3 /usr/bin/python
#RUN python3 -m ensurepip

RUN pip3 install --no-cache --upgrade pip setuptools
RUN pip install mkdocs

EXPOSE 8000

# Start development server by default
# ENTRYPOINT ["mkdocs"]
# CMD ["serve", "--dev-addr=0.0.0.0:8000"]
