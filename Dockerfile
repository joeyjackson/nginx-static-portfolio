FROM alpine:latest AS extract
ARG NGINX_HOST
RUN apk add --no-cache unzip
RUN apk add --no-cache envsubst
# Download and extract github artifacts
ADD https://github.com/joeyjackson/css-gears/releases/download/v1.0.2/dist.zip /tmp/gears.zip
RUN unzip /tmp/gears.zip -d /tmp/gears
ADD https://github.com/joeyjackson/modified10print/releases/download/v1.0.2/dist.zip /tmp/lines.zip
RUN unzip /tmp/lines.zip -d /tmp/lines
ADD https://github.com/joeyjackson/boids/releases/download/v1.1.0/dist.zip /tmp/boids.zip
RUN unzip /tmp/boids.zip -d /tmp/boids

COPY ./static/ /tmp/
RUN mkdir /tmp/static
RUN envsubst < /tmp/index.html.template > /tmp/static/index.html
RUN envsubst < /tmp/50x.html.template > /tmp/static/50x.html


FROM nginx:alpine
ARG NGINX_HOST
ENV NGINX_HOST=${NGINX_HOST}
ENV NGINX_PORT=80

# Delete the default configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy content
COPY --from=extract /tmp/gears /var/www/gears
COPY --from=extract /tmp/lines /var/www/lines
COPY --from=extract /tmp/boids /var/www/boids

COPY --from=extract /tmp/static/ /var/www

# By default, image reads template files in /etc/nginx/templates/*.template and
# outputs the result of executing envsubst to /etc/nginx/conf.d.
COPY ./templates /etc/nginx/templates/
