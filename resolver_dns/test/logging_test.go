package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestLogging(t *testing.T) {
	region := "ca-central-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/logging",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	terraform.InitAndApply(t, terraformOptions)
}
