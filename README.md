# Lazy Action - Dotnet

Setting up continuous integration

- [Lazy Action - Dotnet](#lazy-action---dotnet)
  - [Prerequisites](#prerequisites)
    - [1. Setup github action workflow](#1-setup-github-action-workflow)
  - [Using Lazy Dotnet Action](#using-lazy-dotnet-action)
    - [Adding lazy dotnet action to workflow](#adding-lazy-dotnet-action-to-workflow)
  - [parameters](#parameters)
    - [Input Parameters](#input-parameters)

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
      - uses: variant-inc/lazy-action-setup@v1
      - name: Lazy action steps
        id: lazy-action
        uses: variant-inc/lazy-action@v1
        with:
          src_file_dir: '.'
          dockerfile_dir_path: '.'
          github_token: ${{ secrets.GITHUB_TOKEN }}
          ecr_repository: 'demo-repo'
          nuget_push_enabled: 'true'
          nuget_src_folder: 'src/Variant.ScheduleAdherence.Client/Variant.ScheduleAdherence.Client.csproj'
          container_push_enabled: 'true'
          sonar_scan_enabled: 'false'
```

## parameters

### Input Parameters

| Parameter               | Default       | Description                                           | Required |
| ----------------------- | ------------- | ----------------------------------------------------- | -------- |
| `src_file_dir_path`     | `.`           | Directory of the solution file                        | true     |
| `dockerfile_dir_path`   | `.`           | Directory of the dockerfile                           | true     |
| `github_token`          |               | Github token.Pass same secret as sample snippet       | true     |
| `github_owner_token`    |               | Github owner token.Pass same secret as sample snippet | true     |
| `sonar_token`           |               | Sonar token.Pass same secret as sample snippet.       | true     |
| `aws_access_key_id`     |               | aws access key id.Pass same secret as sample snippet. | true     |
| `aws_secret_access_key` |               | aws secret access key.Same secret as sample snippet.  | true     |
| `aws_region`            |               | aws region.Pass same secret as sample snippet.        | false    |
| `docker_repo_name`      |               | docker repository name.                               | true     |
| `docker_image_name`     |               | docker image name.                                    | true     |
| `sonar_project_key`     | `variant-inc` | sonar project key.                                    | false    |
| `sonar_org`             | `ariant`      | sonar organization.                                   | false    |
| `sonar_scan_enabled`    | `true`        | set to true if sonar scan enabled or set to false.    | false    |
| `nuget_push`            | `true`        | set to true if nuget push is enabled or set to false. | false    |
| `docker_push`           | `true`        | set to true if push to ECR is enabled set to false.   | false    |
