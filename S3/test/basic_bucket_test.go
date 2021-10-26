package test

import (
	"fmt"
	"testing"

	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestBasicBucketCreation(t *testing.T) {
	t.Parallel()

	region := "ca-central-1"
	name := "totallyuniquecdstestbucket"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic_bucket",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
		Vars: map[string]interface{}{
			"name": name,
		},
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs from the `terraform apply`
	bucket_arn := terraform.Output(t, terraformOptions, "arn")
	bucket_id := terraform.Output(t, terraformOptions, "id")
	bucket_region := terraform.Output(t, terraformOptions, "region")
	public_access_block_id := terraform.Output(t, terraformOptions, "public_access_block_id")

	assert.Equal(t, bucket_region, region)

	arn := fmt.Sprintf("arn:aws:s3:::%s", name)
	assert.Equal(t, bucket_arn, arn)

	assert.Equal(t, bucket_id, name)
	assert.Equal(t, bucket_region, region)

	assert.Equal(t, name, public_access_block_id)

	// Test the public access block
	s3Client := aws.NewS3Client(t, region)
	req, resp := s3Client.GetPublicAccessBlockRequest(&s3.GetPublicAccessBlockInput{Bucket: &name})
	require.NoError(t, req.Send())

	assert.Equal(t, true, *resp.PublicAccessBlockConfiguration.BlockPublicAcls)
	assert.Equal(t, true, *resp.PublicAccessBlockConfiguration.BlockPublicPolicy)
	assert.Equal(t, true, *resp.PublicAccessBlockConfiguration.IgnorePublicAcls)
	assert.Equal(t, true, *resp.PublicAccessBlockConfiguration.RestrictPublicBuckets)

}
