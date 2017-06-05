
[![Docker Repository on Quay.io](https://quay.io/repository/mitchese/docker-gitlab-ci-multi-runner-latex/status "Docker Repository on Quay.io")](https://quay.io/repository/mitchese/docker-gitlab-ci-multi-runner-latex)


# mitchese/gitlab-ci-multi-runner-latex:1.1.4-7

- [Introduction](#introduction)
  - [Contributing](#contributing)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Command-line arguments](#command-line-arguments)
  - [Persistence](#persistence)
  - [Deploy Keys](#deploy-keys)
  - [Trusting SSL Server Certificates](#trusting-ssl-server-certificates)
- [Maintenance](#maintenance)
  - [Upgrading](#upgrading)
  - [Shell Access](#shell-access)
- [List of runners using this image](#list-of-runners-using-this-image)

# Introduction

This is an extension of sameersbn's excellent gitlab-ci-multirunner, built for accepting LaTeX builds from Gitlab-CI. I'm using Gitlab to track documents such as my Resume, then gitlab-ci to automatically build a PDF from my resume upon checkin.

A full description of how to use this can be found on [my blog post here](https://www.muzik.ca/).

# Getting started

## Installation

A finished image of this is available on [Dockerhub](https://hub.docker.com/r/mitchese/docker-gitlab-ci-multi-runner-latex) and is the recommended method of installation.

```bash
docker pull mitchese/gitlab-ci-multi-runner-latex:latest
```

Alternatively you can build the image yourself.

```bash
docker build -t mitchese/gitlab-ci-multi-runner-latex github.com/mitchese/docker-gitlab-ci-multi-runner-latex
```

## Quickstart

Before a runner can process your CI jobs, it needs to be authorized to access the the GitLab CI server. The `CI_SERVER_URL`, `RUNNER_TOKEN`, `RUNNER_DESCRIPTION` and `RUNNER_EXECUTOR` environment variables are used to register the runner on GitLab CI.

```bash
docker run --name gitlab-ci-multi-runner-latex -d --restart=always \
  --volume /srv/docker/gitlab-runner:/home/gitlab_ci_multi_runner/data \
  --env='CI_SERVER_URL=http://git.muzik.ca/ci' --env='RUNNER_TOKEN=xxxxxxxxx' \
  --env='RUNNER_DESCRIPTION=latexbuilder' --env='RUNNER_EXECUTOR=shell' \
  mitchese/gitlab-ci-multi-runner-latex:latest
```

Update the values of `CI_SERVER_URL`, `RUNNER_TOKEN` and `RUNNER_DESCRIPTION` in the above command. If these enviroment variables are not specified, you will be prompted to enter these details interactively on first run.

Once the runner is registered with gitlab, add the following configuration to .gitlab-ci.yaml in the root of your git repo to instruct gitlab how to do an automatic build pipeline: 

```yaml
job:
  tags:
    - latex
  when: manual
  script:
    - for i in *.tex; do lualatex $i; done

  artifacts:
    paths:
    - ./*.pdf
    expire_in: 1 week
```

## Persistence

For the image to preserve its state across container shutdown and startup you should mount a volume at `/home/gitlab_ci_multi_runner/data`.

> *The [Quickstart](#quickstart) command already mounts a volume for persistence.*

SELinux users should update the security context of the host mountpoint so that it plays nicely with Docker:

```bash
mkdir -p /srv/docker/gitlab-runner
chcon -Rt svirt_sandbox_file_t /srv/docker/gitlab-runner
```

## Deploy Keys

At first run the image automatically generates SSH deploy keys which are installed at `/home/gitlab_ci_multi_runner/data/.ssh` of the persistent data store. You can replace these keys with your own if you wish to do so.

You can use these keys to allow the runner to gain access to your private git repositories over the SSH protocol.

> **NOTE**
>
> - The deploy keys are generated without a passphrase.
> - If your CI jobs clone repositories over SSH, you will need to build the ssh known hosts file which can be done in the build steps using, for example, `ssh-keyscan github.com | sort -u - ~/.ssh/known_hosts -o ~/.ssh/known_hosts`.

## Trusting SSL Server Certificates

If your GitLab server is using self-signed SSL certificates then you should make sure the GitLab server's SSL certificate is trusted on the runner for the git clone operations to work.

The runner is configured to look for trusted SSL certificates at `/home/gitlab_ci_multi_runner/data/certs/ca.crt`. This path can be changed using the `CA_CERTIFICATES_PATH` enviroment variable.

Create a file named `ca.crt` in a `certs` folder at the root of your persistent data volume. The `ca.crt` file should contain the root certificates of all the servers you want to trust.

With respect to GitLab, append the contents of the `gitlab.crt` file to `ca.crt`. For more information on the `gitlab.crt` file please refer the [README](https://github.com/sameersbn/docker-gitlab/blob/master/README.md#ssl) of the [docker-gitlab](https://github.com/sameersbn/docker-gitlab) container.

Similarly you should also trust the SSL certificate of the GitLab CI server by appending the contents of the `gitlab-ci.crt` file to `ca.crt`.

# Maintenance

## Upgrading

To upgrade to newer releases:

  1. Download the updated Docker image:

  ```bash
  docker pull mitchese/gitlab-ci-multi-runner-latex:latest
  ```

  2. Stop the currently running image:

  ```bash
  docker stop gitlab-ci-multi-runner-latex
  ```

  3. Remove the stopped container

  ```bash
  docker rm -v gitlab-ci-multi-runner-latex
  ```

  4. Start the updated image

  ```bash
  docker run -name gitlab-ci-multi-runner-latex -d \
    [OPTIONS] \
    mitchese/gitlab-ci-multi-runner-latex:latest
  ```
