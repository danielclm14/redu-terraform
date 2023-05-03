O Terraform é uma ferramenta de código aberto que permite criar, modificar e gerenciar infraestrutura como código (IaC). É possível usar o Terraform para definir recursos de infraestrutura como serviços de nuvem, instâncias, banco de dados, redes, entre outros.

Nesse caso, vamos criar um ambiente básico na AWS com um bucket S3, uma instância EC2 e um CloudWatch, além de definir políticas de controle de usuários por organização para limitar o acesso a determinados recursos. 

### Há 4 passos essenciais para a execuçao e validaçao:

1. Dentro do arquivo "main.tf" há um passo a passo de pequenos ajustes que serão necessarios de acordo com a necessidade da sua organizaçao/grupo de projeto.

2. Estabeleça o ambiente terraform inicializando com os 3 comandos basicos: 
```sh
terraform init
terraform plan
terraform apply
```
O comando terraform init instala os plugins necessários para criar os recursos na AWS. O comando terraform plan mostra uma prévia das alterações que serão feitas. O comando terraform apply cria os recursos na nuvem da AWS.
Depois de executar o terraform apply, você poderá visualizar os recursos criados no console da AWS. Certifique-se de que tudo está funcionando corretamente antes de prosseguir.

3. Instale Terratest e as bibliotecas Go necessarias.
Voce pode fazer isso executando os seguintes comandos:
```sh
go get -u github.com/gruntwork-io/terratest/modules/aws
go get -u github.com/gruntwork-io/terratest/modules/terraform
```

4. Executar o código:
```sh
go test -v
```
O código em Golang será responsável por se conectar à AWS, buscar os recursos criados e executar testes em cada um deles para verificar se estão operacionais.
Neste código, estamos:
- Criando as opções do Terraform para buscar as saídas dos recursos.
- Criando uma sessão AWS para se conectar à nuvem da AWS.
- Testando o bucket S3, a instância EC2 e o CloudWatch usando o SDK da AWS para Golang.
- Usando a função 't.Errorf' para registrar erros nos testes.
