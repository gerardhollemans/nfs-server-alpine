# nfs-server-alpine

A handy NFS Server image derived from [Steve Iveson's Alpine-based NFS Server image](https://github.com/sjiveson/nfs-server-alpine), using NFS v4 only, over TCP on port 2049.

**Note** This README is an adapted version of the original by Steve Iveson. Any errors are mine, the good part is his.

## Overview

This image is based on [resin/raspberrypi3-alpine](https://hub.docker.com/r/resin/raspberrypi3-alpine/) to make it work as a container on [resinOS](https://resinos.io/) running on a Raspberry Pi 3.

Until the compilation of [confd](https://github.com/kelseyhightower/confd) for the Raspberry Pi is documented, the binary and templates for confd are not included. The image will always make the directory specified in **exports** (`/nfsshare`) available to NFS v4 clients in **read-write** mode.

## Running a container

To run a container on a Raspberry Pi 3 with resinOS that is accessible on the local network, the following is required:

- Push the image to the Raspberry Pi 3 with `resin local push resinpi.local --source .` (see [Getting Started on the Raspberry Pi 3](https://resinos.io/docs/raspberrypi3/gettingstarted/))
- SSH into the Raspberry Pi 3 and stop the container `docker stop <container started by resin>`
- Run the container with the required parameters:

`docker run -d --name nfs-server --privileged --net host --restart always -v <local folder>:/nfsshare <image pushed by resin>`

Where

- `<local folder>` is the folder on the Raspberry Pi 3 running resinOS that needs to be shared
- `<image pushed by resin>` is the name of the image that results from the command `resin local push resinpi.local --source .`

This container shares the mounted volume on the local network and [restarts always](https://docs.docker.com/engine/reference/commandline/run/#restart-policies-restart) when the Docker daemon notices that container is not running.

## Mounting the share on a client

Due to the `fsid=0` parameter set in the **/etc/exports file**, there's no need to specify the folder name when mounting from a client. For example, this works fine even though the folder being mounted and shared is /nfsshare:

`sudo mount -v resinpi.local:/ /some/where/here`

To be a little more explicit:

`sudo mount -v -o vers=4,loud resinpi.local:/ /some/where/here`

To _unmount_:

`sudo umount /some/where/here`

The /etc/exports file contains these parameters:

`*(rw,fsid=0,async,no_subtree_check,no_auth_nlm,insecure,no_root_squash)`

Note that the `showmount` command won't work against the server as rpcbind isn't running.

### What Good Looks Like

To see whether the container started correctly, retrieve the logs with `docker logs <container name>`. This should show the following:

```
Displaying /etc/exports contents...
/nfsshare *(rw,fsid=0,async,no_subtree_check,no_auth_nlm,insecure,no_root_squash)
Starting NFS in the background...
rpc.nfsd: knfsd is currently up
Exporting File System...
exporting *:/nfsshare
Starting Mountd in the background...
```

## Troubleshooting

### Permission denied

For NFS to work properly, the UID and GIDs must be the same on the server and the clients. Because resinOS and Docker let you work as root by default, the exported directory probably is owned by root. You can change the owner to the user that you work with on the client by running the following command on the client:

`sudo chown -R <username>:<groupname> /some/where/here`

### Facilitate debugging container start issues

It is easier to debug issues with the start of the container when it sends its output to the console. This can be achieved by leaving out the `-d` option, like so

`docker run --name nfs-server --privileged --net host --restart always -v <local folder>:/nfsshare <image pushed by resin>`
