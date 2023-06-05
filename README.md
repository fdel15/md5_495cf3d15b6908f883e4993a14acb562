# README

A simple Ruby on Rails web application that uses the OpenAI API to embed a PDF and allow you query the embedded document.

This project was inspired by [askmybook.com](https://askmybook.com/)

The code in this repository is currently running on [md5_book.delpid.io](https://md5_book.delpid.io/)

## Setup

**Requirements**

- [Docker](https://www.docker.com/)

The app has been dockerized so that you can run it and embed pdfs on your local computer with minimum dependencies. As long as you can run docker, you should be able to run the app.

1. Set up your environment variables

There are two required ENV variables that need to be configured.

- OPENAI_API_KEY={your_api_key}
- RAILS_SERVE_STATIC_FILES=true

Please view all configurable ENVs in `.env.example`

The simplest way to configure your environment is to copy `.env.example` to `.env`.

```
cp .env.example .env
```

Be sure to add your own API key for [OpenAI](https://openai.com/blog/openai-api)

2. Start the webapp

The following command will build a docker image and start a container that
runs the webapp.

The script will let you know when the app has finished booting up.

After it boots you should be able to view the app in your browser by navigating to localhost:3000

3. Embed your pdf

To embed your PDF you need to move it into the `pdfs` directory. This is because we mounted this directory into the docker container in our previous command. Mounting the directory allows the docker container to have access to new files added to this directory. If you try to specify a file path outside of this directory, the conainer will most likely not be able to find the file and will raise an error.

After moving your PDF to the `pdfs` directory run the following command:

```
sh scripts/embed_pdf.sh pdfs/{your_file_name}.pdf
```

This command will generate `embeddings/embeddings.csv`.

And thats it. You can navigate to `localhost:3000` and start querying your document.

## Local Development

This app is running Rails `7.0.4` and the `react-rails` gem.

To install dependencies, configure your database, and precompile assets you want to run the following commands:

```
# Install gems from Gemfile
bundle install

# Install FE dependencies
yarn install

# Setup the DB
rails db:migrate

# Compile Assets
rails assets:precompile
```

For local development you are going to want to run two terminal windows.

In the first window you want to start the rails server

```
rails s
```

In the second terminal window you want to start a webpack server to pickup changes to React components without needing to recompile assets

```
webpack-dev-server
```

There is currently a bug that requires you to recompile assets and restart your Rails server to see CSS changes. This is probably a configuration setting but I have not looked into it yet.

## Architecture Decisions

## Deployment

This app is intended to be used with local files on your local computer. If you decide you want to deploy it, you will probably want to change the DB from `sqlite` to `postgres`

It is possible to deploy it with a `sqlite` database, but if you go this route you need to be mindful that the `sqlite` database is a file that will exist on the server with your application, and to protect this file so that you do not lose data during deployments.

The following is what I did to deploy my application with AWS using a `sqlite` database. It works for me, but it is probably easier using a Platform as a Service (PaaS) such as Heroku and changing the database to Postgres.

1. Launch an EC2 instance on AWS using Amazon Linux OS Image

   - You are going to want to make sure you configure it so that you can ssh into the instance

2. Push production docker image to an ECR registry in AWS
3. SSH into your EC2 instance and pull the image from ECR
4. Use docker run command to run the application.

To route traffic to the EC2 instance, I created an ELB load balancer and a CNAME record for md5_book.delpid.io that points to the ELB.

The ELB is configured to accept HTTPS requests, so I used AWS Certificate Manager to create an SSL/TLS certificate and associated it with the ELB load balancer.

And thats the high level overview for how I deployed it to AWS.
