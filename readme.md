# Naming conventions
[Naming conventions](https://cloud.google.com/apis/design/naming_convention)

# OpenApi
[source](https://medium.com/hoursofoperation/design-document-and-mock-your-apis-with-swagger-a8dc8f5a57e9)

## JSON Line formating tool
[jq](https://stedolan.github.io/jq/) is a lightweight and flexible command-line JSON processor.

[Download](https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe) and rename to jq.exe and copy to current dir

## Setting up Visual Studio Code
Microsoft’s free Visual Studio Code provides a great set of tools to create, edit, and verify your OpenAPI spec files. After installing VSCode you should install these Extensions (unsurprisingly using the Extensions button on the left):

[YAML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)

[Swagger Viewer](https://marketplace.visualstudio.com/items?itemName=Arjun.swagger-viewer)

[OpenAPI Swagger Editor](https://marketplace.visualstudio.com/items?itemName=42Crunch.vscode-openapi)

[Swagger Snippets - optional](https://marketplace.visualstudio.com/items?itemName=adisreyaj.swagger-snippets)

Once you create a yaml (or json) file and add the basic OpenAPI structure, the API icon will appear on the left and you’ll have the option to preview the documentation using Shift+Option+P.

## Create and edit your OpenAPI spec files
First off, create a *.yaml file. (I will be demonstrating examples in YAML, but JSON is also supported if you are more comfortable with that standard.)
Although you can browse through the specs, it’s probably best to start off with a simple example — this describes a fictional API for the ubiquitous “Todo app”:

```
openapi: 3.0.0
info:
  title: Example Task Manager Project
  description: An example API documentation for a task manager.
  version: "1.0"
servers:
  - url: 'http://127.0.0.1:4010/'
components:
  schemas:
    Task:
      type: object
      properties:
        title:
          type: string
          example: 'Buy eggs'
          description: 'The description task to be done.'
        completed:
          type: boolean
          example: true
          description: 'True or false to mark whether the task has been completed.'
        id:
          type: integer
          example: 3
          description: 'A unique identifier for this task.'

  responses:
    error:
      description: ERROR
      content:
        application/json:
          schema:
            type: object
            properties:
              message:
                description: Describes the error in a human-readable format.
                type: string
                example: Permission denied.

  parameters:
    task:
      name: id
      in: query
      required: true
      description: The identifier of the task at hand.
      schema:
        type: string
paths:
  /tasks:
    get:
      summary: Get tasks
      description: Get a list of tasks
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: array
                items: 
                  $ref: '#/components/schemas/Task'
  /task:
    post:
      summary: Create a task
      description: Creates a new task
      parameters:
        - name: title
          in: query
          description: The new title of the task. Leave out if you don't want to change it.
          schema:
            type: string
            example: Take the dog for a walk
      requestBody:
        content:
          application/x-www-form-urlencoded:
            schema:
              properties:
                name:
                  type: string
                  description: Updated name of the pet
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    description: Returns the id of the new task.
                    type: integer
                    example: 23
        '500':
          $ref: '#/components/responses/error'         
    put:
      summary: Update a task
      description: Modify the task's title or its completed status.
      parameters:
        - $ref: '#/components/parameters/task'
        - name: title
          in: query
          description: The new title of the task. Leave out if you don't want to change it.
          schema:
            type: string
            example: Take the dog for a walk
        - name: completed
          in: query
          description: The completion status of the task. Leave out if you don't want to change it.
          schema:
            type: boolean
            example: true
      responses:
        '200':
          description: OK
        '500':
          $ref: '#/components/responses/error'         
    delete:
      summary: Delete a task
      description: Removes a task completely.
      parameters: [
        $ref: '#/components/parameters/task'
      ]
      responses:
        '200':
          description: OK
        '500':
          $ref: '#/components/responses/error'         
```

I won’t go into too much detail about the specs, as there are many tutorials out there, but as you can hopefully read from the yaml, OpenAPI allows you to specify in detail the requests, endpoints, responses, and data-types of your API. You can also define reusable components that you can then reference several times in your specs (to limit repeating yourself).

A somewhat more complex sample is the [Petstore API yaml](https://gist.github.com/aronbudinszky/bafd2c53e6cf4b4b7b65985a08432429) — this illustrates more advanced features of the [OpenAPI spec.](https://swagger.io/specification/) But probably the best is to start playing around with it (with a generated preview, see below) and just look up stuff in the specs when you run into trouble.

## Generate documentation
Undoubtedly your yaml files are beautiful, but ultimately the goal (or rather one of the goals) is to generate documentation that the less-geeky members of your team can read. In addition, you can live-preview your yaml changes which can aid you a lot while writing the specs.

Though there are [a number](https://swagger.io/docs/open-source-tools/swagger-ui/usage/installation/) of [different](https://github.com/Swagger2Markup/swagger2markup-cli) ways to generate documentation, I prefer using a command line tool for generating a totally dependency-free (and nice looking) HTML via redoc-cli.
First, install redoc-cli with npm (here’s how to [install npm](https://nodejs.org/en/download/) in case you don’t have it yet):

```
npm install -g redoc-cli
```

Now you can generate a full HTML documentation from your OpenAPI specs. You can also start a server that watches for yaml file changes (super useful while you create the specs). Here’s how:
```
# Generates the spec into zero-dependency HTML file
redoc-cli bundle -o ~/desired/path/for/output/index.html ~/path/to/your/openapi.yaml

# Starts a server with spec rendered with ReDoc. Supports SSR mode (--ssr) and can watch the spec (--watch)
redoc-cli serve ~/path/to/your/openapi.yaml --watch
```

## Run a mock API server
As a project’s development gets underway, it often happens that the server API is not yet fully available when you must already rely on it for your app or frontend web development. Of course you can also mock the API data within your app temporarily, but even better is if you had access to a full-fledged mock API server that works identical to documented expectations.

While a service like [SwaggerHub](https://swagger.io/tools/swaggerhub/) can provide this for your entire team, a free and fast alternative is prism. Just install it with npm (again, here’s how to install npm in case you don’t have it yet):
```
npm install -g @stoplight/prism-cli
```

Then run it on localhost. Now you can access your API, as documented in your OpenAPI spec on localhost via the port you defined. Go ahead, test it via curl:

```
# Run the prism server, you can set the port with -p to whatever you want
prism mock -p 4010 ~/path/to/your/openapi.yaml

# Now you can access the fake API endpoints
curl -X GET "http://127.0.0.1:4010/endpoint?parameter=value" -H "accept: application/json"

# If you have json_pp installed (available via Homebrew on macOS) you can even nicely format the response
curl -X GET "http://127.0.0.1:4010/endpoint?parameter=value" -H "accept: application/json" | json_pp

# You can also test specific response codes using the __code query string
curl -X GET "http://127.0.0.1:4010/locations?__code=304"
```

## Use generated data for API responses
So far we’ve created a mock API that will return static responses based on the examples (or data types) set up in our yaml spec. But this is only partly useful — much better is if we could get correctly formatted data generated randomly into each field.

Fortunately this is possible using x-faker tags in our spec. Based on [faker.js](https://github.com/Marak/faker.js), you can specify a wide variety of data types that will then be used to generate realistic, fake data for your mock server response. For example:

```
    Task:
      type: object
      properties:
        title:
          type: string
          x-faker: name.firstName
          example: 'Buy eggs'
          description: 'The description task to be done.'
        completed:
          type: boolean
          x-faker: datatype.number
          example: true
          description: 'True or false to mark whether the task has been completed.'
        id:
          type: integer
          example: 3
          description: 'A unique identifier for this task.'
```          

The above x-faker tags will tell prism to generate a valid, realistic, random first name and an existing photo url for the relevant field. You must then also run prism in dynamic mode using -d or request the endpoint with the __dynamic=true query parameter:

```
# You can run prism in dynamic mode
prism mock -d ~/path/to/your/openapi.yaml

# Or you can force dynamic mode when you call a request 
curl -v "http://127.0.0.1/endpoint?__dynamic=true"
```

## What’s next
There are many other features of Swagger that are outside of the scope of this short intro.

You can use [Swagger CodeGen](https://github.com/swagger-api/swagger-codegen) to generate code stubs for your server and client side.

On the other hand if you have existing code you wish to document you can follow [solutions, stories, and tips for generating OpenAPI specs from existing APIs](https://medium.com/search?q=swagger%20existing).

If you use Gitlab, then your [docs can be generated and published to Gitlab Pages using Gitlab’s shared runners.](https://medium.com/@aronbudinszky/auto-generate-swagger-docs-to-gitlab-pages-ca040230df3a)

