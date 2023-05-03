# O Terraform é uma ferramenta de código aberto que permite criar, modificar e
#  gerenciar infraestrutura como código (IaC). É possível usar o Terraform para definir
#  recursos de infraestrutura como serviços de nuvem, instâncias, banco de dados, 
#  redes, entre outros.

# Nesse caso, vamos criar um ambiente básico na AWS com um bucket S3, uma
#  instância EC2 e um CloudWatch, além de definir políticas de controle de usuários
#  por organização para limitar o acesso a determinados recursos. Para isso, vamos
#  seguir os seguintes passos:

# Passo 1: Defina as variáveis necessárias
# Em seguida, defina as variáveis necessárias para o projeto, como nome do bucket, 
#  nome do usuário administrador, ID da conta do usuário administrador, entre outras 
#  informações que você possa precisar.

variable "admin_username" {
  description = "The username of the admin user"
}

variable "admin_account_id" {
  description = "The AWS account ID of the admin user"
}

variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  default     = "example-terraform-bucket"
}

# Passo 2: Configure o provider da AWS
# Em seguida, configure o provider da AWS, que será usado pelo Terraform para criar
#  recursos na nuvem da AWS. Neste exemplo, estamos usando a região us-east-1.

provider "aws" {
  region = "us-east-1"
}

# Passo 3: Crie um recurso IAM para sua organização
# Agora vamos criar um recurso AWS Identity and Access Management (IAM) para a
#  organização. Isso permite definir políticas de controle de acesso para os usuários
#  que serão criados posteriormente.

resource "aws_iam_organization" "example" {
  feature_set = "ALL"

  aws_service_access_principals = ["cloudtrail.amazonaws.com"]
}

# Passo 4: Crie uma política de controle de acesso para o bucket S3
# Agora, vamos criar uma política de controle de acesso para o bucket S3 que limita
#  o acesso apenas ao usuário administrador. Isso é importante para garantir a 
#  segurança dos dados armazenados no bucket.

resource "aws_iam_policy" "bucket_policy" {
  name_prefix = "bucket-policy-"
  policy      = data.aws_iam_policy_document.s3_bucket.json
}

resource "aws_s3_bucket" "example" {
  bucket = "example-terraform-bucket"
  acl    = "private"

  policy = aws_iam_policy.bucket_policy.arn
}

resource "aws_iam_policy_document" "s3_bucket" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.admin_account_id}:user/${var.admin_username}"]
    }

    resources = [
      "${aws_s3_bucket.example.arn}/*"
    ]
  }
}

# Passo 5: Crie um grupo de segurança para a instância EC2
# Agora, vamos criar um grupo de segurança para a instância EC2. Isso é importante
#  para limitar o acesso à instância apenas às portas necessárias. Neste exemplo,
#  estamos permitindo o acesso à porta 22 para permitir a conexão SSH à instância.

resource "aws_security_group" "example" {
  name_prefix = "example-sg-"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Passo 6: Crie uma instância EC2
# Agora, vamos criar uma instância EC2 básica. Estamos usando a AMI
#  ami-0c55b159cbfafe1f0 e o tipo de instância t2.micro.

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = "example-key-pair"
  vpc_security_group_ids = [aws_security_group.example.id]
}

# Passo 7: Crie um grupo de logs para o CloudWatch
# Por fim, vamos criar um grupo de logs para o CloudWatch, que permite monitorar a
#  instância EC2. Isso pode ajudar a detectar problemas ou analisar o desempenho da
#  instância.

resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/ec2/example"
}

# Passo 8: Crie uma política de controle de acesso para o CloudWatch
# Agora, vamos criar uma política de controle de acesso para o CloudWatch que 
#  limita o acesso apenas ao usuário administrador.

resource "aws_iam_policy" "cloudwatch_policy" {
  name_prefix = "cloudwatch-policy-"
  policy      = data.aws_iam_policy_document.cloudwatch.json
}

resource "aws_cloudwatch_log_resource_policy" "example" {
  policy_document = aws_iam_policy.cloudwatch_policy.json
  policy_name     = "example-policy"
  policy_type     = "Resource"
}

resource "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.admin_account_id}:user/${var.admin_username}"]
    }

    resources = [
      aws_cloudwatch_log_group.example.arn
    ]
  }
}

# Passo 9: Crie um usuário administrador
# Por fim, vamos criar um usuário administrador para a organização e dar a ele as
#  permissões necessárias para acessar os recursos criados.

resource "aws_iam_user" "admin" {
  name = var.admin_username
}

resource "aws_iam_access_key" "admin" {
  user = aws_iam_user.admin.name
}

resource "aws_iam_user_policy_attachment" "admin" {
  user       = aws_iam_user.admin.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}

resource "aws_iam_user_policy_attachment" "cloudwatch_admin" {
  user       = aws_iam_user.admin.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}