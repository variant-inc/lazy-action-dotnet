# Lazy Action - Dotnet

Setting up continuous integration

- [Lazy Action - Dotnet](#lazy-action---dotnet)
  - [Prerequisites](#prerequisites)
    - [1. Setup github action workflow](#1-setup-github-action-workflow)
    - [2. Add lazy action setup](#2-add-lazy-action-setup)

  - [Using Lazy Dotnet Action](#using-lazy-dotnet-action)
    - [Adding lazy dotnet action to workflow](#adding-lazy-dotnet-action-to-workflow)
  - [parameters](#parameters)
    - [Input Parameters](#input-parameters)

## Prerequisites

### 1. Setup github action workflow

1. On GitHub, navigate to the main page of the repository.
2. Under your repository name, click Actions.
3. Find the template that matches the language and tooling you want to use, then click Set up this workflow.Either start with blank workflow or choose any integration workflows.

### 2. Add lazy action setup

1. Add a code checkout step this will be needed to add code to the github workspace.

```yaml
    - uses: actions/checkout@v2
      with:
        fetch-depth: 0
```

2. This is to setup some of the global environment variables we use as part of the lazy dotnet action.

```yaml
    - name: Setup
      uses: variant-inc/lazy-action-setup@feature/init-setup
```


## Using Lazy Dotnet Action

You can set up continuous integration for your project using a lazy workflow action.
After you set up CI, you can customize the workflow to meet your needs.By passing the right input parameters with the lazy    dotnet action.

### Adding lazy dotnet action to workflow

Sample snippet to add lazy action to your workflow code .
See [action.yml](action.yml) for the full documentation for this action's inputs and outputs.

```yaml
jobs:
  build_test_scan:
    runs-on: eks
    name: CI Pipeline
    steps:
    - uses: actions/checkout@v2
      with:
        fetch-depth: 0
        
    - name: Setup
      uses: variant-inc/lazy-action-setup@feature/init-setup
                  
    - name: Lazy action steps
      id: lazy-action
      uses: variant-inc/lazy-action-dotnet@feature/create-release
      env:
        NUGET_TOKEN: ${{ secrets.PKG_READ }}
        AWS_DEFAULT_REGION: us-east-2
        GITHUB_USER: variant-inc
      with:
        src_file_dir_path: '.'
        dockerfile_dir_path: '.'
        ecr_repository: naveen-demo-app/demo-repo
        nuget_push_enabled: 'true'
        sonar_scan_in_docker: 'false'
        nuget_src_project: "src/Variant.ScheduleAdherence.Client/Variant.ScheduleAdherence.Client.csproj"
        nuget_package_name: 'demo-app'
        github_token: ${{ secrets.GITHUB_TOKEN }}
```

## parameters

### Input Parameters

| Parameter                    | Default       | Description                                           | Required |
| ---------------------------- | ------------- | ----------------------------------------------------- | -------- |
| `src_file_dir_path`          | `.`           | Directory path to the solution file                   | true     |
| `dockerfile_dir_path`        | `.`           | Directory path to the dockerfile                      | true     |
| `ecr_repository`             |               | ECR Repository name                                   | true     |
| `sonar_scan_in_docker`       | "false"       | Is sonar scan running as part of Dockerfile           | false    |
| `sonar_scan_in_docker_target`|"sonarscan-env"| sonar scan in docker target.                          | false    |
| `nuget_push_enabled`         | "false"       | If nuget push enabled to package registry. Set this value to true              | false    |
| `nuget_package_name`         |               | Use only if nuget_push_enabled is enabled and want to give nuget pacakage name.By default, it will be the name of the project.| false |
| `nuget_src_project`          |               | Use only if nuget_push_enabled is enabled Path to the nuget project file (.csproj).             | false    |  
| `github_token`               |               | Github Token                                          | false    |  

