#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
FROM python:3.12
MAINTAINER Even Rouault <even.rouault@spatialys.com>

LABEL \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date="2025-10-30" \
    org.label-schema.name="mapproxy" \
    org.label-schema.description="Mapproxy with a plugin for handling HIPS protocol" \
    org.label-schema.url="https://github.com/pole-surfaces-planetaires/docker-mapproxy" \
    org.label-schema.vcs-url="https://github.com/pole-surfaces-planetaires/docker-mapproxy" \
    org.label-schema.vcs-ref="https://github.com/pole-surfaces-planetaires/docker-mapproxy" \
    org.label-schema.vendor="PDSSP (Pole de données et services Surfaces Planétaires)" \
    org.label-schema.version="1.13.1-pdssp"
    
#-------------Application Specific Stuff ----------------------------------------------------

RUN apt-get -y update && \
    apt-get install -y \
    gettext \
    build-essential

RUN pip install pyproj numba Pillow mapproxy_hips uwsgi

EXPOSE 8080
ENV \
    # Run
    PROCESSES=6 \
    THREADS=10 \
    # Run using uwsgi. This is the default behaviour. Alternatively run using the dev server. Not for production settings
    PRODUCTION=true

ADD uwsgi.ini /settings/uwsgi.default.ini
ADD start.sh /start.sh
RUN chmod 0755 /start.sh
RUN mkdir -p /mapproxy /settings
RUN groupadd -r mapproxy -g 10001 && \
    useradd -m -d /home/mapproxy/ --gid 10001 -s /bin/bash -G mapproxy mapproxy
RUN chown -R mapproxy:mapproxy /mapproxy /settings /start.sh
VOLUME [ "/mapproxy"]
USER mapproxy
ENTRYPOINT [ "/start.sh" ]
CMD ["mapproxy-util", "serve-develop", "-b", "0.0.0.0:8080", "mapproxy.yaml"]
