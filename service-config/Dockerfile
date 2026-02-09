FROM hashicorp/consul:1.20
COPY --chown=100:1000 consul.hcl /consul/config/consul.hcl

CMD ["agent", "-config-dir=/consul/config"]