FROM phalconphp/ubuntu-16.04:php-7.2

# It is not an important part of our image. However, it is useful to pass these
# variables on building stage for future diagnosing a running application
ARG BUILD_ID=0
ARG VERSION=0.0.1

ENV BUILD_ID=${BUILD_ID} \
    APPLICATION_VERSION=${VERSION} \
    DEBIAN_FRONTEND=noninteractive

LABEL build_id="${BUILD_ID}" \
      version="${VERSION}" \
      description="Our application image" \
      maintainer="John Doe <john@doe.com>" \
      vendor=ZenyteBros \
      name="zenytebros.site"

# "/app" is a working directory as it set in parent image. We copy all files
# inside current working dir. This approach implies that we don't use the
# current container to install PHP dependencies using composer and build any
# project related stuff. Any required project dependencies should be obtained
# on host system or via special build images. We're use this image as a real
# container for the application, not as a build system.
COPY /docker /app/docker

# However, composer is here, and you can always use it if this is your strategy
# to build application image.
RUN composer --version

# Copy virtual host, custom PHP configuration and disable default site
RUN rm -f /etc/nginx/sites-enabled/default \
    && cp -R /app/docker/config/nginx/* /etc/nginx/ \
    && ln -s /app/docker/config/php/app.ini /etc/php/7.2/cli/conf.d/100-app.ini \
    && ln -s /app/docker/config/php/app.ini /etc/php/7.2/fpm/conf.d/100-app.ini

# Run custom script after build, e.g cleaning up, custom settings, disabling
# redundant modules, etc
#RUN bash /app/docker/provision/after-build.sh

# Expose required ports
EXPOSE 80 443

# Amend parent volumes
VOLUME /app/storage/logs
