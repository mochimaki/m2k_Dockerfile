# ADALM2000 Docker Environment

This repository provides a Docker environment for controlling the ADALM2000.

## Features

- Pre-built libraries required for ADALM2000 control (libiio, libm2k)
- Pre-configured Python environment

## Prerequisites

- Docker
- Docker Compose
- ADALM2000 device

### Setup Method

To easily install Docker and Docker Compose, we recommend installing [Docker Desktop](https://www.docker.com/products/docker-desktop/).

## Docker Hub Image

A pre-built Docker image is available on Docker Hub:

```bash
docker pull mochimaki/adalm2000-env:latest
```

This image contains all the necessary libraries and configurations for ADALM2000 control. You can use this image directly or build from source as described below.

## Startup Methods

### Quick Start (Recommended)

The easiest and recommended method using docker-compose.

1. Clone the repository:
```bash
git clone https://github.com/mochimaki/m2k_Dockerfile
cd m2k_Dockerfile
```

2. Start the container:
```bash
docker-compose up -d
```

3. Connect to the container:
```bash
docker exec -it m2k_github-adalm2000-1 bash
```

### Advanced Startup Method

Alternative method using docker run for more detailed configuration.

1. Basic startup:
```bash
docker run -it --rm mochimaki/adalm2000-env:latest /bin/bash
```

2. Startup with mounts and environment variables:
```bash
docker run -it --rm \
  -v $(pwd)/test:/home/m2k/test \
  -v $(pwd)/version_info:/home/m2k/version_info:rw \
  -e PATH=/home/m2k/venv/m2k/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
  -e VIRTUAL_ENV=/home/m2k/venv/m2k \
  -w /home/m2k/test \
  -u m2k \
  mochimaki/adalm2000-env:latest \
  /bin/bash
```

#### Notes

- When using docker run, you need to manually set up mounts and environment variables
- Virtual environment setup must be done manually
- The container will stop when the shell exits

### Recommendations

- Use docker-compose for normal usage
- Use docker run only when customization or detailed configuration is needed

## Using Analog Devices Sample Programs

When using [Analog Devices sample programs](https://github.com/analogdevicesinc/libm2k/tree/master/bindings/python/examples), please note the following:

### 1. Connection Method

Sample programs connect as follows:
```python
ctx = libm2k.m2kOpen()  # Assumes execution on host PC
```

When executing from a container, you need to specify the IP address:
```python
ctx = libm2k.m2kOpen("ip:192.168.2.1")  # Specify ADALM2000 IP address
```

### 2. Graphical Display Options

Some sample programs use `matplotlib` to display graphs, but you cannot directly control the host PC's display from the container. Please choose one of the following two methods:

#### Method A: Save to CSV and Visualize with Spreadsheet Software (Recommended)
The simplest method. Basic Python knowledge is sufficient.

```python
import csv
import numpy as np

# Get data
data = ctx.getSamples(1000)  # Example: Get 1000 samples

# Save to CSV file
with open('measurement_data.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['Time', 'Value'])  # Header
    for i, value in enumerate(data):
        writer.writerow([i, value])
```

You can open the saved CSV file with common tools such as:
- Microsoft Excel
- LibreOffice Calc
- Google Sheets

##### Visualization Example (Excel)
1. Open the CSV file in Excel
2. Select the data
3. Choose "Chart" from the "Insert" tab
4. Select line chart or scatter plot

#### Method B: Web Application (Using Flet)
This method is for users with Python knowledge. No front-end skills are required.

[Flet](https://flet.dev/) allows you to create web applications using only Python. Flet enables you to build web application UIs with Python code and easily visualize data.

### ADALM2000 IP Address Configuration

If you need to use multiple ADALM2000 devices or change network settings, please refer to the [ADALM2000 Configuration Guide](https://wiki.analog.com/university/tools/m2k/common/customizing?redirect=1).

## Notes

- For graphical output, choose one of the two methods above:
  1. Save to CSV and visualize with spreadsheet software (easy)
  2. Create a web application using Flet (Python knowledge required)

## License

MIT License

## Features

- Integration of libiio and libm2k libraries
- Python development environment
- USB device access
- Analog input/output control
- Digital input/output control

## License

This project is published under the MIT License. For details, please see the [LICENSE](LICENSE.md) file.

### Dependent Library Licenses

This project depends on the following libraries:

- libiio: GNU Lesser General Public License Version 2.1
  - Full license text: [COPYING.txt](https://github.com/analogdevicesinc/libiio/blob/main/COPYING.txt)
- libm2k: GNU General Public License v2
  - Full license text: [LICENSE](https://github.com/analogdevicesinc/libm2k/blob/main/LICENSE)

### Commercial Use Notice

Commercial use of libiio and libm2k may require a separate license agreement with Analog Devices.
Please refer to [Analog Devices License Terms](https://www.analog.com/jp/lp/001/analog_devices_software_license_agreement.html) for details.

## Contributing

1. Fork this repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

## Author

mochimaki

## Acknowledgments

- Analog Devices Inc. - For providing ADALM2000 hardware and libraries
- The libiio and libm2k development teams