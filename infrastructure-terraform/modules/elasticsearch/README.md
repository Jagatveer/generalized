# AWS ElasticSearch

## example usage

```
module "elasticsearch" {
  source = "./modules/elasticsearch"

  name                      = "${var.stack_name}-es-${var.environment}"
  vpc_id                    = "${module.vpc.vpc_id}"
  subnet_ids                = "${module.vpc.private_subnets}"
#  zone_id                   = "ZA863HSKDDD9"
  itype                     = "${var.es_itype}"
  ingress_allow_cidr_blocks = [ "${var.vpcs_strings["cidr"]}" ]
}
```
