output "vault_public_ip" {
    description = "Public IP of the vault server"
    value = aws_instance.vault_server_01.*.public_ip
}