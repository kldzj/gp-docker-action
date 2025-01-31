# GitHub Action to build and publish Docker Images to GitHub Container registry

## Usage examples:

### Build and publish Docker Image with a `head` tag for the `develop` branch

```yaml
  build-and-publish-head:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop' # Running this job only for develop branch

    steps:
    - uses: actions/checkout@v2 # Checking out the repo

    - name: Build and Publish head Docker image
      uses: kldzj/gp-docker-action@1.3.3
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }} # Provide GITHUB_TOKEN to login into the GitHub Packages
        image-tag: head # Provide Docker image tag
```

### Build and publish Docker Image with a `latest` tag for the `master` branch with different dockerfile

```yaml
  build-and-publish-latest:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/master' # Running this job only for master branch

    steps:
    - uses: actions/checkout@v2 # Checking out the repo

    - name: Build and Publish latest Docker image
      uses: kldzj/gp-docker-action@1.3.3
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }} # Provide GITHUB_TOKEN to login into the GitHub Packages
        dockerfile: Dockerfile_server
```

### Build and publish Docker Image with a tag equal to the commit hash

```yaml
  build-and-publish-tag:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Build and Publish Tag Docker image
      uses: kldzj/gp-docker-action@1.3.3
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }} # Provide GITHUB_TOKEN to login into the GitHub Packages
        extract-commit-sha: true # Provide flag to extract Docker image tag from commit hash
```

```yaml
  build-and-publish-tag:
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/') # Running this job only for tags

    steps:
    - uses: actions/checkout@v2

    - name: Build and Publish Tag Docker image
      uses: kldzj/gp-docker-action@1.3.3
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }} # Provide GITHUB_TOKEN to login into the GitHub Packages
        extract-git-tag: true # Provide flag to extract Docker image tag from git reference
```

### Build and publish Docker Image with a different build context

```yaml
  build-and-publish-dev:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop' # Running this job only for develop branch

    steps:
    - uses: actions/checkout@v2 # Checking out the repo

    - name: Build and Publish head Docker image
      uses: kldzj/gp-docker-action@1.3.3
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }} # Provide GITHUB_TOKEN to login into the GitHub Packages
        build-context: ./dev # Provide path to the folder with the Dockerfile
```

### Passing additional arguments to the docker build command

```yaml
  build-with-custom-args:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop' # Running this job only for develop branch

    steps:
    - uses: actions/checkout@v2 # Checking out the repo

    - name: Build with --build-arg(s)
      uses: kldzj/gp-docker-action@1.3.3
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }} # Provide GITHUB_TOKEN to login into the GitHub Packages
        custom-args: --build-arg some=value --build-arg some_other=value # Pass some additional arguments to the docker build command
```

------

You will encounter the following log message in your GitHub Actions Pipelines:

```
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /github/home/.docker/config.json.
Login Succeeded
```

I would like to ensure you, that I do not store your secrets, passwords, token, or any other information.

This warning informs you about the fact, that this Action passes your GitHub token via the command line argument:
```bash
docker login -u publisher -p ${DOCKER_TOKEN} ghcr.io
```

In a non-safe environment, this could raise a security issue, but this is not the case. We are passing a temporary authorization token, which will expire once the pipeline is completed. It would also require additional code to extract this token from the environment or `docker` internals, that this Action does not have.
