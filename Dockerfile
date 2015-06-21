FROM java
MAINTAINER kc8viq <markallenhowell@gmail.com>
RUN apt-get update
RUN apt-get -y install ruby
RUN mkdir /minecraft
WORKDIR /minecraft
ADD / /minecraft/
EXPOSE 25565
VOLUME /minecraft
CMD ["./mctl.rb"]
