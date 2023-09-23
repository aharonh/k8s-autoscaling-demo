export EDITOR=code
export AWS_PROFILE=harley-systems-mfa
export AWS_SDK_LOAD_CONFIG=1
export NAME=demo.harley.systems
export STATE_BUCKET=demo-harley-systems-state
export OIDC_BUCKET=demo-harley-systems-oidc
export KOPS_STATE_STORE=s3://${STATE_BUCKET}/kops
export KOPS_OIDC_STORE=s3://${OIDC_BUCKET}
unset KOPS_FEATURE_FLAGS 

