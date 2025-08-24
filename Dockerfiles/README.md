# Dockerfiles README

This directory contains sample Dockerfiles and recommended best practices:

- Use small base images (e.g., Alpine, distroless) whenever possible.
- Leverage multi-stage builds to minimize image size and reduce secrets exposure.
- Include health checks, use a non-root user, and aim for minimal layers.

It will be ready in the future.