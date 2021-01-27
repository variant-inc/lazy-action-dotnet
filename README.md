# LAZY-DOTNET-ACTION

Setting up continuous integration 

- [LAZY-DOTNET-ACTION](#lazy-dotnet-action)
  - [Prerequisites](#prerequisites)
    - [1. Setup github action workflow](#1-setup-github-action-workflow)
  - [Using Lazy Dotnet Action](#using-lazy-dotnet-action)
    - [Adding lazy dotnet action to workflow](#adding-lazy-dotnet-action-to-workflow)
  - [Parameters](#parameters)
    - [Input Parameters](#input-paramters)
    - [Output Parameters](#output-paramters)



## Prerequisites

### 1. Setup github action workflow


1. On GitHub, navigate to the main page of the repository.
2. Under your repository name, click Actions.
3. Find the template that matches the language and tooling you want to use, then click Set up this workflow.Either start with blank workflow or choose any integration workflows.

## Using Lazy Dotnet Action

You can set up continuous integration for your project using a lazy workflow action.
After you set up CI, you can customize the workflow to meet your needs.By passing the right input parameters with the lazy    dotnet action.    

### Adding lazy dotnet action to workflow

Sample snippet to add lazy action to your workflow code .
See [action.yml](action.yml) for the full documentation for this action's inputs and outputs.

```yaml

jobs:
  build_test_scan_publish:
    runs-on: (Use our custom runner)
    name: CI Pipeline
    steps:
    - uses: actions/checkout@v2
      with:
        fetch-depth: 0         
    - name: Lazy action steps
      id: lazy-action
      uses: variant-inc/lazy-action@master
      with:
        src_file_dir: '.'
        dockerfile_dir_path: '.'
        github_token: ${{ secrets.PKG_READ }}
        github_owner_token: ${{ secrets.GITHUB_TOKEN }}
        sonar_token: ${{ secrets.SONAR_TOKEN }}
        aws_access_key_id: ${{ secrets.DEV_AWS_ACCESS_KEY_ID }}
        aws_secret_access_key: ${{ secrets.DEV_AWS_SECRET_ACCESS_KEY }}
        docker_repo_name: 'demo-app'
        docker_image_name: 'demo-repo'
        nuget_push: 'true'
        docker_push: 'true'
        sonar_scan_enabled: 'false'

```

## parameters

### Input Parameters

Input parameters section.

```text

src_file_dir_path:
This is a mandatory input parameter to define directory of the solution file .
Sample input : './' , './src/test'
Required:true
Default: '.'

dockerfile_dir_path:
This is a mandatory input parameter to define directory of the dockerfile .
Sample input : './' , './src/test'
Required:true
Default: '.'

Note : Dockerfile is mandantory for now after our phase 2 release this will go optional , if docker file path is provided , lazy action will process based on passed dockerfile , if not it will use our own dockerfile to build and publish the image.

github_token: 
This is a mandatory input paramter , pass as it is in sample input.This will take secret github token which we set in github account.
Required:true

github_owner_token
This is a mandatory input paramter , pass as it is in sample input.This will take secret github owner token which we set in github account.
Required: true

sonar_token: 
This is a mandatory input paramter , pass as it is in sample input.This will take secret sonar token which we set in github account.
Required: true

aws_access_key_id:  
This is a mandatory input paramter , pass as it is in sample input.This will take secret aws access key id which we set in github account.
Required: true

aws_secret_access_key:
This is a mandatory input paramter , pass as it is in sample input.This will take secret aws secret access key which we set in github account.
Required: true

aws_region: 
This is an optional input paramter where we set aws region . 
Required: false

Default: 'us-east-2'
docker_repo_name: 
This is a mandatory input paramter , should be your docker repository name.
Required: true

docker_image_name:  
This is a mandatory input paramter , should be your docker image name.
Required: true

sonar_project_key: 
This is an optional input paramter where we set sonar project key. 
Required: false
Default: 'variant-inc'

sonar_org: 
This is an optional input paramter where we set sonar organization. 
Required: false
default: 'variant'

sonar_scan_enabled:  
This is a mandatory input paramter , set to true if your repository is sonar scan enabled or can set value as false.
Required: true
default: false

nuget_push:  
This is a mandatory input paramter , set to true if your repository needed push to nuget package registry or can set value as false.
required: true
default: false

docker_push:  
This is a mandatory input paramter , set to true if your repository needed docker push to ECR registry or can set value as false.
Required: true
default: false
```


### Output Parameters

Output parameters section.

```text
image:
Image tag will have docker image name generated.

```

Output parameters can be invoked as mentioned in below snippet.


```yaml

    - name: Get the image name from lazy-action
      run: echo "Image Name:${{ steps.lazy-action.outputs.image }}"

```
steps.lazy-action.outputs.image :

* lazy-action : id from your lazy action invocation.
* image: output parameter id from lazy CI action.