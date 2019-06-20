FROM scratch
MAINTAINER Joshua Smith joshmsmith@gmail.com

LABEL io.k8s.description="Monkey Ops - Chaos Monkey Implementation for OpenShift-3 & 4" \
      io.k8s.display-name="Monkey Ops - Chaos Monkey Implementation for OpenShift-3 & 4" \
      io.openshift.tags="chaos,monkey" \
      author="Josh Smith (based on https://github.com/Produban/monkey-ops)" \
      vendor="OpenShift" \
      description="Monkey Ops - Chaos Monkey Implementation for OpenShift-3 & 4" \
      summary="Monkey Ops - Chaos Monkey Implementation for OpenShift-3 & 4" \
      source.url="https://github.com/joshmsmith/monkey-ops" \
      version=".11 alpha" \
      url="https://github.com/joshmsmith/monkey-ops/browse"

#move scripts from here to the container
ADD /image/monkey-ops /

#add default user
RUN useradd -u 1001 -r -g 0 -s /sbin/nologin \
    -c "Default Application User" default \
  && chown -R 1001:0 ./monkey-ops \
  && chmod -R g+rwx ./monkey-ops

USER 1001

# CMD in the place where the scripts are
CMD ["/monkey-ops"]
