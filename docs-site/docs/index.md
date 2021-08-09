# Mkdocs.Tools

This is the not the [mkdocs.org](https://www.mkdocs.org) project but a simple toolchain around it.

## Docker image

The docker image is used for local development as well as in CICD for deploying your documenation along with your project.

```dockerfile
!INCLUDE "../../Dockerfile"
```

## Project layout

    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        ...       # Other markdown pages, images and other files.

## Third Layer

    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        ...       # Other markdown pages, images and other files.

### Commit
!INCLUDE "../../.git/refs/heads/main"
