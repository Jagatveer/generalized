FROM datadog/agent:latest

RUN apt-get update && apt-get install openssl ca-certificates wget -y
RUN wget https://github.com/Droplr/aws-env/raw/master/bin/aws-env-linux-amd64 -O /bin/aws-env
RUN chmod +x /bin/aws-env

CMD ["eval $(aws-env) && /init"]