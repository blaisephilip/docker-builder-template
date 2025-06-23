# Docker Builder Template

## Concept

The use case of building containerized applications with front- and backend is regular.  
The repository provides a template about how to do this, with aspects of content integration from many sources.  

## Prerequisites

- Linux as OS (tested on Ubuntu 24.04.1)
- Prepared sotware environment. Use the following script:  

```bash
cd scripts
./00-setup-environment.sh
```

## Architecture

The system provides a basic frontend-backend web application architecture without any database used.  

### Frontend - Node.js

#### .env files

Attributes with direct environment-based influence can be added here to the build.

#### .npmrc

Private or company-specific NPM package sources can be provided here for the build.  

## Build

The builder scripts:

```bash
cd scripts
./01-build-frontend.sh
```

```bash
cd scripts
./02-build-backend.sh
```

## Modules

## Releases

See the [release notes.](doc/RELEASE_NOTES.md)  

## Deployment

## Operational concepts

**TODO**  
