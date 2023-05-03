package test

import (
    "fmt"
    "testing"

    "github.com/aws/aws-sdk-go/aws"
    "github.com/aws/aws-sdk-go/aws/session"
    "github.com/aws/aws-sdk-go/service/cloudwatchlogs"
    "github.com/aws/aws-sdk-go/service/ec2"
    "github.com/aws/aws-sdk-go/service/s3"
    "github.com/gruntwork-io/terratest/modules/aws as awsterra"
    "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAWSResources(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../terraform/",
    }

    // Executa o terraform apply para criar os recursos
    terraform.InitAndApply(t, terraformOptions)

    // Busca as informações de saída do terraform
    bucketName := terraform.Output(t, terraformOptions, "bucket_name")
    instanceID := terraform.Output(t, terraformOptions, "instance_id")

    // Cria uma sessão AWS
    awsSession := session.New(&aws.Config{
        Region: aws.String("us-east-1"),
    })

    // Testa o bucket S3
    s3Client := s3.New(awsSession)
    _, err := s3Client.HeadBucket(&s3.HeadBucketInput{
        Bucket: aws.String(bucketName),
    })
    if err != nil {
        t.Errorf("Falha ao verificar o bucket S3: %v", err)
    }

    // Testa a instância EC2
    ec2Client := ec2.New(awsSession)
    _, err = ec2Client.DescribeInstances(&ec2.DescribeInstancesInput{
        InstanceIds: []*string{
            aws.String(instanceID),
        },
    })
    if err != nil {
        t.Errorf("Falha ao verificar a instância EC2: %v", err)
    }

    // Testa o CloudWatch
    cloudWatchClient := cloudwatchlogs.New(awsSession)
    _, err = cloudWatchClient.DescribeLogGroups(&cloudwatchlogs.DescribeLogGroupsInput{
        LogGroupNamePrefix: aws.String("/aws/ec2/example"),
    })
    if err != nil {
        t.Errorf("Falha ao verificar o CloudWatch: %v", err)
    }
}