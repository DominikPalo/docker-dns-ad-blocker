# oznu/dns-ad-blocker

A simple, lightweight, Dnsmasq DNS server to block traffic to known ad servers.

## Usage

```
docker run -d --restart=always -p 53:53/tcp -p 53:53/udp oznu/dns-ad-blocker
```

You can now set your devices to use the Docker Host's IP Address as the primary DNS resolver,
if you are using [Docker for Windows](https://docs.docker.com/docker-for-windows/) or [Docker for Mac](https://docs.docker.com/docker-for-mac/) this will be 127.0.0.1.

Automatic blacklist updates are enabled by default. This should only be used on conjunction with a
[restart policy](https://docs.docker.com/engine/reference/run/#restart-policies---restart) as the container is killed
when an update is available to refresh Dnsmasq.

### Options

To enable logging of DNS queries set ```DEBUG=1```:

```
docker run -d --restart=always -p 53:53/tcp -p 53:53/udp -e "DEBUG=1" oznu/dns-ad-blocker
```

For verbose logging (including source IP) set ```DEBUG=2```.


By default this image forwards DNS requests for unknown zones to Google's DNS servers, 8.8.8.8 and 8.8.4.4. You can set your own if required:

```
docker run -d --restart=always -p 53:53/tcp -p 53:53/udp -e "NS1=192.168.0.1" -e "NS2=192.168.0.2" oznu/dns-ad-blocker
```

To disable automatic updates set ```AUTO_UPDATE=0```:

```
docker run -d --restart=always -p 53:53/tcp -p 53:53/udp -e "AUTO_UPDATE=0" oznu/dns-ad-blocker
```

## AD Blocking

This image is using the blacklists created by [StevenBlack/hosts](https://github.com/StevenBlack/hosts).

The DNS server works by returning ```0.0.0.0``` when a DNS lookup is made by a browser or device to a blacklisted domain. ```0.0.0.0``` is defined as a non-routable meta-address used to designate an invalid, unknown, or non applicable target which results in the browser rejecting the request.

If you have found a host you think should be blacklisted please submit an issue on the upstream blacklist, [StevenBlack/hosts](https://github.com/StevenBlack/hosts/issues), as
the aim of this project is not to maintain yet another blacklist.

## Optional :: Custom Domains

This image supports adding additional zones that may be used to serve internal DNS zones or to override existing zones.

To do this create a volume share when creating the container:

```
docker run -d -p 53:53/tcp -p 53:53/udp -v /srv/zones:/etc/dnsmasq.d/ oznu/dns-ad-blocker
```

Every file in the ```/srv/zones``` will be included as an extension to the Dnsmasq config.

Example:

```
# Add domains which you want to force to an IP address here.
# The example below send any host in doubleclick.net to a local
# webserver.
address=/doubleclick.net/127.0.0.1

# Return an MX record named "maildomain.com" with target
# servermachine.com and preference 50
mx-host=maildomain.com,servermachine.com,50
```

After adding or updating a zone config file you must restart the container for it to be loaded.
