# README

A simple Ruby on Rails web application that uses the OpenAI API to embed a PDF and allow you query the embedded document. The frontend uses React and integrates with Rails using the `react-rails` gem.

This project was inspired by [askmybook.com](https://askmybook.com/)

The code in this repository is currently running on [md5_book.delpid.io](https://md5_book.delpid.io/)

- [Setup](#setup)
- [Local Development](#local-development)
- [Deployment](#deployment)
- [Architecure decisions](#architecure-decisions)

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

There is a test suite that was created using MiniTest, and you can run it with the following command:

```
rails test
```

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

## Architecure decisions

### Created my own OpenAI library

One of the first decisions I made was to create my own library to interact with OpenAI.

There are Ruby gems that exist to interact with the OpenAI API, but the API was straight forward and I would probably spend as much time learning how to use the gem as I would creating my own client.

The advantages of building the client myself are that I spent most of my time reading the OpenAI documentation and how the different features work, and I had more flexibility to design the client to fit the application.

The tradeoff for this kind of flexibility is that you need to be disciplined to not mingle your business logic with the library. I created the library in the `lib` directory and created a new class for each OpenAI endpoint I used. This allowed me to focus that class on doing just one thing.

### Caching

The user experience is significantly better when using a cached response to a query instead of needing to hit the OpenAI API.

In the database, I store the md5 hash of every question, and index this column. Every time a question is asked, we first check the database for the md5_hash of the question. If it has already been asked, we can return the cached answer, otherwise we use the OpenAI Chat completions endpoint.

To increase the number of questions that map to the same md5_hash, we format the query before calculating the hash. We try to standardize and remove any characters that do not change the query. Currently the steps we take are to downcase the query, remove all white space, and remove any punctuation marks.

### Try to make the cost of change low

We are in the early days of LLMs. OpenAI will create new models and tokenizers in the future, and we want to be able to change as well when it makes sense.

I made the OpenAI configurable using ENV variables. This way you can override the model and tokenizer that is used by default in each library without needing to change any code. More details can be found in the `.env.example` file.

In hindsight I don't love my approach because I think I can do a better job of mapping OpenAI models with their attributes. The way it works now, you will probably need to override several ENVs to make any change and that is a little messy/confusing.

What I would do differenlty next time is create a config file (maybe using yml or json) to define the models with their attributes. I would set ENVs from the config file when the app boots, and from the user perspective it would be more clear how to extend it in the future.

It is not a gurantee that OpenAI will make the most sense in the future. To abstract a dependency on a specific LLM, the embeddings_generator takes an `embedder` as an argument. Any LLM can be used as long as I create an interface that responds to `tokenizer` and `create` methods.

Similary, the QueryResponder takes an argument to map a string to a specific LLM responder. The LLM interface just needs to respond to the `fetch_answer` method, and the details on how it does that can be abstracted away.

### Optimizing for local use

I read through some of the closed issues(https://github.com/slavingia/askmybook/issues?q=is%3Aissue+is%3Aclosed) in the askmybook.com repository and realized people were finding value running it locally with their own content.

Deploying this app to a public url can lead to high costs by pinging the OpenAI API frequently, and requires some thought on the best way to rate limit users.

For these reasons, I wanted to optimize the experience of someone running the app on their local machine to handle their local documents.

I chose `sqlite` for the database because keeping the database in a file in your directory is simpler than running a postgres server or something similar. I knew it would be simple to change to postgres in the future if I needed to, so this was a low risk decision.

I spent time dockerizing the application. This way the only technical skills a person needs is to be able to install Docker and run scripts from the terminal. They can have the app running in a single script, and can embed a document using the running container in another script. This removes the burden of dependencies not working on their local machine.
