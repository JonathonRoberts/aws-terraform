module "webserver" {
  source="./modules/awsweb"
  AWS_SSH_KEY=var.AWS_SSH_KEY
}
module "appserver" {
  source="./modules/awsapp"
}
