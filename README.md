# MOST PROBABLY...

... you're looking for [polettix/certificate-example][] instead:

```shell
docker run --rm -it polettix/certificate-example
```

If not, read on...

# Certificate Example

This repository allows you to regenerate the [Docker][] image that is
already available as [polettix/certificate-example][] in the [Docker
Hub][]. It allows you to do some experimentation with [OpenSSL][].

It relies on [dibs][].

## How to use

The `dibs.yml` file is structure in order to minimize development time,
which means that there are two "base" images (one for building, the other
for bundling) that are used over and over but only built once.

The repository is set to work in *alien mode*, so you will have to also
use option `-A` on the command line.

The quickest way to get started from the beginning is to use the `boot`
*stroke*:

```shell
$ dibs -A boot
```

This will take care to build the base images as well as the end image.

If you add things to `src`, it *should* suffice to just run the `quick`
*stroke*, which is also the default:

```shell
$ dibs -A
```

If you change the prerequisites in `src/prereqs` or add Perl modules in
`src/cpanfile` you should do a full round though, because the quick stroke
does not honor prerequisites (i.e. it assumes that nothing changed in that
regard):

```shell
$ dibs -A full
```

Last, if you want to venture into changing the [Alpine Linux][] base image
(e.g. migrate to something newer than `3.6`), keep in mind two things:

- default [OpenSSL][] configuration files are not the same in later
  versions (e.g. see [Going Back on Alpine Linux 3.6][]);
- you will have to get rid of sub-directory `cache` because most probably
  your [Perl][] modules will need to be compiled against a different
  version of [Perl][].

[Docker]: https://www.docker.com/
[polettix/certificate-example]: https://hub.docker.com/repository/docker/polettix/certificate-example
[Docker Hub]: https://hub.docker.com/
[OpenSSL]: https://www.openssl.org/
[dibs]: https://github.com/polettix/dibs
[Alpine Linux]: https://www.alpinelinux.org/
[Going Back on Alpine Linux 3.6]: https://github.polettix.it/ETOOBUSY/2020/02/04/going-back-on-alpine/
[Perl]: https://www.perl.org/
