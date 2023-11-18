resource "tls_private_key" "Par_Chave" {
 algorithm = "RSA"
}
resource "aws_key_pair" "generated_key" {
 key_name = "Par_Chave_Pedro"
 public_key = "${tls_private_key.Par_Chave.public_key_openssh}"
 depends_on = [
  tls_private_key.Par_Chave
 ]
}
resource "local_file" "key" {
 content = "${tls_private_key.Par_Chave.private_key_pem}"
 filename = "Par_Chave_Pedro.pem"
 file_permission ="0400"
 depends_on = [
  tls_private_key.Par_Chave
 ]
}