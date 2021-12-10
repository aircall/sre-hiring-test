# deploy.sh

# variables
stage=${STAGE}
region=${REGION}
bucket=${BUCKET}

# Configure your Serverless installation to talk to your AWS account
sls config credentials \
  --provider aws \
  --key ${SLS_KEY} \
  --secret ${SLS_SECRET}

# cd into functions dir
cd /deploy/functions

# Deploy function
echo "------------------"
echo 'Deploying function...'
echo "------------------"
sls deploy


########################
# find and replace the service endpoint
if [ -z ${stage+dev} ]; then echo "Stage is unset."; else echo "Stage is set to '$stage'."; fi

sls info -v
sls info -v | grep ServiceEndpoint > domain.txt
sed -i 's@ServiceEndpoint:\ https:\/\/@@g' domain.txt
sed -i "s@/$stage@@g" domain.txt
domain=$(cat domain.txt)
sed "s@.execute-api.$region.amazonaws.com@@g" domain.txt > id.txt
id=$(cat id.txt)

echo "------------------"
echo "Domain:"
echo "  $domain"
echo "------------------"
echo "API ID:"
echo "  $id"
echo "------------------"
echo 'Bucket endpoint:'
echo "  http://$bucket.s3-website.$region.amazonaws.com/"

rm domain.txt
rm id.txt

echo "------------------"
echo "Service deployed. Press CTRL+C to exit."
