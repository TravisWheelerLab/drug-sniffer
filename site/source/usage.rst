Usage
=====

TODO

Docker Images
-------------

Each stage in the Drug Sniffer pipeline has its own Docker image. The images can
be built all at once with the `build-images.sh` script found in the `tool/`
directory, which can be run from the repository root. This script accepts three
parameters as environment variables, listed below. These allow the images to be
built and pushed to registries other than the default locations.

* :code:`IMAGE_REGISTRY` - the registry that will host the image, this doesn't
  matter if the image will only be used locally
* :code:`IMAGE_NAMESPACE` - the owner of the image, this is usually a project or
  organization name and, again, doesn't matter for images that will never be
  pushed to a registry
* :code:`IMAGE_VERSION` - the version identifier to be applied to the image

All of the variables above have usable defaults.
