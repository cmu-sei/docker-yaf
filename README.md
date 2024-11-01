[![Software Engineering Institute](https://avatars.githubusercontent.com/u/12465755?s=200&v=4)](https://www.sei.cmu.edu/)

[![Blog](https://img.shields.io/static/v1.svg?color=468f8b&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=SEI&message=Blog)](https://insights.sei.cmu.edu/blog/ "blog posts from our experts in Software Engineering.")
[![Youtube](https://img.shields.io/static/v1.svg?color=468f8b&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=SEI&message=Youtube&logo=youtube)](https://www.youtube.com/@TheSEICMU/ "vidoes from our experts in Software Engineering.")
[![Podcasts](https://img.shields.io/static/v1.svg?color=468f8b&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=SEI&message=Podcasts&logo=applepodcasts)](https://insights.sei.cmu.edu/podcasts/ "podcasts from our experts in Software Engineering.")
[![GitHub](https://img.shields.io/static/v1.svg?color=468f8b&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=SEI&message=GitHub&logo=github)](https://github.com/cmu-sei "view the source for all of our repositories.")
[![Flow Tools](https://img.shields.io/static/v1.svg?color=468f8b&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=SEI&message=Flow%20Tools)](https://tools.netsa.cert.org/ "documentation and source for all our flow collection and analysis tools.")


At the [SEI](https://www.sei.cmu.edu/), we research software engineering, cybersecurity, and AI engineering problems; create innovative technologies; and put solutions into practice.

Find us at:

* [Blog](https://insights.sei.cmu.edu/blog/) - blog posts from our experts in Software Engineering.
* [Youtube](https://www.youtube.com/@TheSEICMU/) - vidoes from our experts in Software Engineering.
* [Podcasts](https://insights.sei.cmu.edu/podcasts/) - podcasts from our experts in Software Engineering.
* [GitHub](https://github.com/cmu-sei) - view the source for all of our repositories.
* [Flow Tools](https://tools.netsa.cert.org/) - documentation and source for all our flow collection and analysis tools.

# [certcc/yaf](https://tools.netsa.cert.org/yaf2/index.html)

[![CI](https://img.shields.io/github/actions/workflow/status/cmu-sei/docker-yaf/release.yml?style=for-the-badge&logo=github)](https://github.com/cmu-sei/docker-yaf/actions?query=workflow%3ARelease) [![Docker pulls](https://img.shields.io/docker/pulls/cmusei/yaf?color=468f8b&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/cmusei/yaf/)

[YAF](https://tools.netsa.cert.org/yaf2/index.html) is Yet Another Flowmeter. It processes packet data from pcap dumpfiles as generated by [tcpdump](http://www.tcpdump.org/) or via live capture from an interface using pcap into bidirectional flows, then exports those flows to [IPFIX](http://www.ietf.org/html.charters/ipfix-charter.html) Collecting Processes or in an IPFIX-based file format. YAF's output can be used with the [SiLK flow analysis tools](https://tools.netsa.cert.org/silk/index.html), [super_mediator](https://tools.netsa.cert.org/super_mediator/index.html), [Pipeline 5](https://tools.netsa.cert.org/analysis-pipeline5/index.html), and any other IPFIX compliant toolchain.

Why does the world need another network flow event generator? yaf was originally intended as an experimental implementation tracking developments in the IETF IPFIX working group, specifically bidirectional flow representation, archival storage formats, and structured data export with Deep Packet Inspection. It is designed to perform acceptably as a flow sensor on any network on which white-box flow collection with commodity hardware is appropriate. yaf can and should be used on specialty hardware when scalability and performance are of concern.

## Tool Suite

The YAF toolchain presently consists of two primary tools, [yaf](https://tools.netsa.cert.org/yaf2/yaf.html) itself, and [yafscii](https://tools.netsa.cert.org/yaf2/yafscii.html). The YAF applications require the libairframe and libyaf libraries, which are included and installed as part of the YAF distribution. libairframe installs two additional tools, [filedaemon](https://tools.netsa.cert.org/yaf2/filedaemon.html) and [airdaemon](https://tools.netsa.cert.org/yaf2/airdaemon.html). [libyaf](https://tools.netsa.cert.org/yaf2/libyaf/index.html) implements YAF file and network I/O, and contains YAF packet decoder, fragment assembler, and flow table. In addition, two tools to assist in PCAP analysis are also installed with YAF. 

## Documentation

More information [here](https://tools.netsa.cert.org/yaf2/docs.html).

## Usage

The intention of this container image is to allow for usage of the yaf command-line tool for processing pcap dumpfiles into IPFIX output. Here are some example scenarios to help get you started.

### FCCX-15 Reference Data

Example reference pcap data can be found [here](http://tools.netsa.cert.org/silk/referencedata.html).  Download and unpack the data set with:

```bash
curl https://tools.netsa.cert.org/silk/refdata/FCCX-pcap.tar.gz | tar -xz -
```

### Index a Single PCAP

The following example is an update to the one [here](https://tools.netsa.cert.org/yaf/yaf_pcap.html#yp_single).

Using the FCCX PCAP, we create flow records by yaf from the PCAP file `/data/gatewaySensor-1.pcap` (from `$PWD/FCCX-data/` volume mount on the docker host). We supply parameters that add application labeling, avoid packet truncation by employing a generous packet size restriction, and output records compatible with SiLK conversion into `/tmp/test_FCCX-packets.silk` (to `$PWD/output/` volume mount on the docker host):

```bash
docker run --rm -it -v $PWD/FCCX-data:/data:ro -v $PWD/output:/tmp \
  cmusei/yaf:latest \
  --in=/data/gatewaySensor-1.pcap \
  --out=/tmp/test_FCCX-packets.silk \
  --applabel \
  --max-payload=1500 \
  --silk
```

To generate the restricted record format used by SiLK, including VLAN tags, we make use of the [rwipfix2silk](https://tools.netsa.cert.org/silk/rwipfix2silk.html) command found in the `silk_analysis` container image, read the `/tmp/test_FCCX-packets.silk` input file and output to `/tmp/yaf2flow.rw` (from `$PWD/output/` volume mount from the docker host):

```bash
docker run --rm -it -v $PWD/output:/tmp \
  cmusei/silk_analysis:latest \
  rwipfix2silk \
  --silk-output=/tmp/yaf2flow.rw \
  --interface-values=vlan \
  /tmp/test_FCCX-packets.silk
```

We can then use [rwstats](https://tools.netsa.cert.org/silk/rwstats.html), found in the `silk_analysis` container image, to view the top 20 application protocols used in the flow file (from `$PWD/output/` volume mount on the docker host):

```bash
docker run --rm -it -v $PWD/output:/tmp \
  cmusei/silk_analysis:latest \
  rwstats \
  --fields=application \
  --top \
  --count=20 \
  /tmp/yaf2flow.rw
```
```
INPUT: 69833 Records for 11 Bins and 69833 Total Records
OUTPUT: Top 20 Bins by Records
appli|   Records|  %Records|   cumul_%|
    0|     30454| 43.609755| 43.609755|
   80|     14836| 21.244970| 64.854725|
   53|     13417| 19.212980| 84.067704|
  443|      7648| 10.951842| 95.019547|
  137|      1999|  2.862543| 97.882090|
  389|       716|  1.025303| 98.907393|
  139|       540|  0.773273| 99.680667|
  138|       162|  0.231982| 99.912649|
   67|        25|  0.035800| 99.948448|
  123|        20|  0.028640| 99.977088|
   22|        16|  0.022912|100.000000|
```

### Sniff Host Interface

The following example configures yaf to continuously capture packets from the host `ens192` interface and output them to a file rotated every 30 seconds (to a volume mount from the host):

```bash
 docker run --name yaf --cap-add NET_ADMIN --net=host -v $PWD/test:/tmp/ \
   -d cmusei/yaf:latest \
   --in ens192 \
   --live pcap \
   --out /tmp/flows.yaf \
   --rotate 30 \
   --verbose \
   --silk \
   --applabel \
   --max-payload 2048 \
   --plugin-name=/netsa/lib/yaf/dpacketplugin.so
```

We can view output from the running yaf container via:

```bash
docker logs -f yaf
[2023-10-26 17:59:43] yaf starting
[2023-10-26 17:59:43] Initializing Rules From File: /netsa/etc/yafApplabelRules.conf
[2023-10-26 17:59:43] Application Labeler accepted 49 rules.
[2023-10-26 17:59:43] Application Labeler accepted 0 signatures.
[2023-10-26 17:59:43] DPI Running for ALL Protocols
[2023-10-26 17:59:43] Initializing Rules from DPI File /netsa/etc/yafDPIRules.conf
[2023-10-26 17:59:43] DPI rule scanner accepted 52 rules from the DPI Rule File
[2023-10-26 17:59:43] DPI regular expressions cover 6 protocols
[2023-10-26 17:59:43] running as root in --live mode, but not dropping privilege
```

Rotated files are named using the prefix given in the `--out` option, followed by a suffix containing a timestamp in YYYYMMDDhhmmss format, a decimal serial number, and the file extension .yaf.  In our example run, the following files were produced:

```bash
ll
total 16
-rw-r--r--. 1 root root 4202 Oct 26 14:00 flows.yaf-20231026175944-00000.yaf
-rw-r--r--. 1 root root 2726 Oct 26 14:00 flows.yaf-20231026180016-00001.yaf
-rw-r--r--. 1 root root 2753 Oct 26 14:01 flows.yaf-20231026180046-00002.yaf
```

We can quickly view the contents of these files by using [yafscii](https://tools.netsa.cert.org/yaf2/yafscii.html):

```bash
docker run --rm -it --entrypoint=/netsa/bin/yafscii -v $PWD/test:/tmp/ \
  cmusei/yaf:latest \
  --in /tmp/flows.yaf-20231026175944-00000.yaf \
  --out -
```
```
2023-10-26 18:00:00.288 - 18:00:00.384 (0.096 sec) tcp 10.0.0.2:44382 => 10.0.0.3:5666 ffffffff:ffffffff S/APF:AS/APF (11/2511 <-> 7/1425) rtt 0 ms applabel: 443
2023-10-26 18:00:00.385 - 18:00:00.403 (0.018 sec) tcp 10.0.0.2:48182 => 10.0.0.3:22 ffffffff:ffffffff S/APRF:AS/AP (6/333 <-> 4/1125) rtt 1 ms applabel: 22
```

### Connect to [rwflowpack](https://tools.netsa.cert.org/silk/rwflowpack.html) to output SiLK Flow files

The following example configures yaf to continuously capture packets from the host `ens192` interface and output them to a container running rwflowpack listening on port 18001 in order to collect and store binary SiLK Flow files.

First, we start rwflowpack by running the `silk_packing` container. We can make use of the [silk.conf](examples/rwflowpack/silk.conf) and [sensor.conf](examples/rwflowpack/sensor.conf) files included in the [examples](examples/) folder.  Make sure to edit the internal-ipblocks in the [sensor.conf](examples/rwflowpack/sensor.conf) to match your network:

```bash
docker run --name rwflowpack -v $PWD/examples/rwflowpack:/data \
  -p 18001:18001 \
  -d cmusei/silk_packing:latest \
  rwflowpack \
  --input-mode=stream \
  --root-directory=/data \
  --sensor-configuration=/data/sensor.conf \
  --site-config-file=/data/silk.conf \
  --output-mode=local-storage \
  --log-destination=stdout \
  --no-daemon
```

Second, we start yaf through the `yaf` container and configure it to continuously capture packets from the host `ens192` interface. This time we have it output to the rwflowpack container listening on port 18001:
```bash
docker run --name yaf --cap-add NET_ADMIN --net=host \
  -d cmusei/yaf:latest \
  --in ens192 \
  --live pcap \
  --ipfix tcp \
  --out localhost \
  --silk \
  --verbose \
  --ipfix-port=18001 \
  --applabel \
  --max-payload 2048 \
  --plugin-name=/netsa/lib/yaf/dpacketplugin.so
```

We can check on the status of our containers via:
```bash
docker logs -f yaf
docker logs -f rwflowpack
```

Eventually you should see rwflowpack output some log lines similar to the following:
```bash
Oct 30 18:57:43 d23189499d6a rwflowpack[1]: /data/in/2023/10/30/in-S0_20231030.18: 15 recs
Oct 30 18:57:43 d23189499d6a rwflowpack[1]: /data/out/2023/10/30/out-S0_20231030.18: 15 recs
Oct 30 18:57:43 d23189499d6a rwflowpack[1]: /data/inweb/2023/10/30/iw-S0_20231030.18: 1 recs
Oct 30 18:57:43 d23189499d6a rwflowpack[1]: /data/outweb/2023/10/30/ow-S0_20231030.18: 1 recs
```

We can confirm SiLK is creating records by using the `silk_analysis` container:
```bash
docker run -v $PWD/examples/rwflowpack:/data --rm -it \
  --entrypoint=/bin/bash \
  cmusei/silk_analysis:latest \
  -c 'rwfilter --proto=0- --type=all --pass=stdout | rwcut | head'
```
```
     sIP|        dIP|sPort|dPort|pro|   packets|     bytes|   flags|                  sTime| duration|                  eTime|sen|
10.0.0.1|   10.0.0.2| 9998|33342|  6|         8|       447|   PA   |2023/10/30T18:49:20.567|    8.201|2023/10/30T18:49:28.768| S0|
10.0.0.1|   10.0.0.2| 9998|33342|  6|         1|        52|F   A   |2023/10/30T18:49:28.768|    0.000|2023/10/30T18:49:28.768| S0|
10.0.0.3|   10.0.0.2|45476| 5666|  6|        11|      2511|FS PA   |2023/10/30T18:49:47.027|    0.296|2023/10/30T18:49:47.323| S0|
10.0.0.4|   10.0.0.2| 9998|42162|  6|        23|      4408| S PA   |2023/10/30T18:49:28.675|   29.994|2023/10/30T18:49:58.669| S0|
10.0.0.4|   10.0.0.2| 9998|42162|  6|         1|        52|F   A   |2023/10/30T18:49:58.669|    0.000|2023/10/30T18:49:58.669| S0|
10.0.0.3|   10.0.0.2|45698| 5666|  6|        15|      2767|FS PA   |2023/10/30T18:50:17.146|    0.011|2023/10/30T18:50:17.157| S0|
10.0.0.3|   10.0.0.2|45698| 5666|  6|         1|        52|    A   |2023/10/30T18:50:17.157|    0.000|2023/10/30T18:50:17.157| S0|
10.0.0.3|   10.0.0.2|45692| 5666|  6|        15|      2767|FS PA   |2023/10/30T18:50:17.142|    0.038|2023/10/30T18:50:17.180| S0|
10.0.0.3|   10.0.0.2|45692| 5666|  6|         1|        52|    A   |2023/10/30T18:50:17.180|    0.000|2023/10/30T18:50:17.180| S0|
```

### [Use yaf version 3](https://tools.netsa.cert.org/yaf/new_yaf3.html)

A yaf version 3 container image is also maintained, it can be made use of through the version 3 tags.  For example:

```bash
 docker run --name yaf --cap-add NET_ADMIN --net=host -v $PWD/test:/tmp/ \
   -d cmusei/yaf:3 \
   --in ens192 \
   --live pcap \
   --out /tmp/flows.yaf \
   --rotate 30 \
   --verbose \
   --silk \
   --applabel \
   --max-payload 2048 \
   --dpi
```
