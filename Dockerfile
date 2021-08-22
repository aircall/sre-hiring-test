FROM public.ecr.aws/lambda/nodejs:14

# Copy function code
COPY package*.json ${LAMBDA_TASK_ROOT}/

# only install app dependencies required for production environment
RUN npm install --only=prod

FROM public.ecr.aws/lambda/nodejs:14

COPY --from=0 ${LAMBDA_TASK_ROOT}/node_modules ${LAMBDA_TASK_ROOT}/node_modules

COPY parser.js app.js ${LAMBDA_TASK_ROOT}/
RUN chmod 755 ${LAMBDA_TASK_ROOT}/app.js ${LAMBDA_TASK_ROOT}/parser.js

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "app.lambdaHandler" ]