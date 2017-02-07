# Earth-Observation Time-Series filters: The eotsfilter package

This R package is made of wrappers around filters and smoothers commonly usen on time series of Earth Observation data. This package is meant to be deployed as a RESTful web service in a [opencpu](https://www.opencpu.org/) server.

## Prerequisites

- A running [opencpu](https://www.opencpu.org/) server.

## Installation

This package can be installed using devtools as follows:

```R
library(devtools)
install_github("albhasan/eotsfilter")
```

## Use

This package implements a self-describing function which can be called like this:

```bash
curl http://myOpenCpuServer/ocpu/library/eotsfilter/R/getcapabilities/json -H "Content-Type: application/json" -d ''
```

Each filter is exposed by opencpu as a REST web service:

```bash
curl http://myOpenCpuServer/ocpu/library/eotsfilter/R/whitaker1/json -H "Content-Type: application/json" -d '{"lambda":100,"sample":{"id":"123e4567-e89b-12d3-a456-426655440000","lat":-9,"lon":-57,"label":"sugar cane","timeline":["2000-02-18","2000-03-05","2000-03-21","2000-04-06","2000-04-22","2000-05-08","2000-05-24","2000-06-09","2000-06-25","2000-07-11","2000-07-27","2000-08-12","2000-08-28"],"validdata":[1,1,1,1,1,1,1,1,1,1,1,1,1],"attributes":[{"attribute":"ndvi","values":[4247,5420,7376,7890,8995,8968,8948,8928,8998,8935,8710,8846,8756]},{"attribute":"evi","values":[4549,3895,7290,5158,5273,4991,5326,5362,5198,5701,5174,5563,5356]}]}}'
```

