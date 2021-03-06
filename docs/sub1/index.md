# Mkdocs.Tools sub 1

This is the not the [mkdocs.org](https://www.mkdocs.org) project but a simple toolchain around it.

## Project layout

    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        ...       # Other markdown pages, images and other files.

## Docker image

The docker image is used for local development as well as in CICD for deploying your documenation along with your project.

```dockerfile
!INCLUDE "../Dockerfile"
```

## Preprocessor

A simple wrapper around https://github.com/jreese/markdown-pp is used for the build task to include any external files you have marked in your markdown files

```bash
!INCLUDE "../preprocessor.sh"
```

## Image
![Alt tag for sample image](img/sample.png "Title for image")

commit-sha
!INCLUDE "../env/COMMIT_HASH"
