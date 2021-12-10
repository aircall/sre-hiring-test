FROM amazonlinux

ENV SLS_KEY=${SLS_KEY}
ENV SLS_SECRET=${SLS_SECRET}
ENV STAGE=${STAGE}
ENV REGION=${REGION}
ENV BUCKET=${BUCKET}

# Create deploy directory
WORKDIR /deploy

# Install system dependencies
RUN yum -y install git vim npm curl gcc g++ make
RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash -
RUN yum -y install nodejs


# Install serverless
RUN npm install -g serverless

# Copy source
COPY . .

# Install app dependencies
RUN cd /deploy/functions && npm i --production && cd /deploy

#  Run deploy script
CMD ./deploy.sh ; sleep 5m
