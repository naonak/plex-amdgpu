# Plex Docker with AMDGPU-Pro for Hardware Transcoding

## Description

This repository provides a Dockerfile to build a Plex Media Server container that includes support for AMDGPU-Pro drivers, enabling hardware-accelerated video transcoding on AMD GPUs. It leverages `ghcr.io/linuxserver/plex` as the base image and includes the necessary steps to install AMDGPU-Pro drivers and configure Plex to use hardware acceleration with AMD GPUs.

## Features

- **Plex Media Server**: The latest version of Plex from LinuxServer's Docker repository.
- **AMDGPU-Pro Drivers**: Installs the AMDGPU-Pro drivers to enable hardware acceleration for video transcoding.
- **OpenCL (ROCm)**: Includes support for OpenCL with ROCm.
- **VAAPI/VDPAU**: Installs drivers for VAAPI and VDPAU, essential for hardware video decoding and encoding.
- **Hardware Acceleration**: Enables Plex to use AMD GPU for transcoding by adding the Plex user to the video group.

## Requirements

- **AMD GPU**: This setup is intended for machines running AMD GPUs.
- **Docker**: You need to have Docker installed on your machine to use this project.
- **Host Operating System**: This Dockerfile assumes an Ubuntu-based environment inside the container.

## How to Use

### Run the Plex Container

Once the image is built, you can run it with the following command:

```bash
docker run -d \
  --name=plex \
  --restart=unless-stopped \
  -e PLEX_CLAIM="<your_plex_claim_token>" \
  -e PUID=1000 -e PGID=1000 \
  -v /path/to/library:/config \
  -v /path/to/movies:/movies \
  -v /path/to/tvshows:/tvshows \
  -v /path/to/transcode:/transcode \
  --device=/dev/dri \
  ghcr.io/naonak/plex-amdgpu:main  
```

### Hardware Transcoding

Make sure that the GPU device (`/dev/dri`) is passed through to the container. Plex will automatically detect the hardware acceleration capabilities via the installed AMDGPU-Pro drivers.

### Plex Claim Token

Replace `<your_plex_claim_token>` with your Plex claim token, which can be obtained from the [Plex website](https://www.plex.tv/claim).

## Checking GPU Acceleration

You can verify the AMD GPU installation inside the container using the `clinfo` command, which is executed at the end of the Dockerfile.

```bash
docker exec -it plex-amdgpu clinfo
```

This will display details about the installed OpenCL drivers and confirm whether the GPU is available for use.

## Additional Information

- **PUID/PGID**: Set the correct user and group IDs to match the IDs on your host system.
- **Volume Mounts**: Ensure that your Plex configuration directory, media libraries, and transcoding directory are correctly mounted as volumes.

## Troubleshooting

- If Plex doesn't detect the GPU for transcoding, check that the `video` group has the correct permissions and that the `clinfo` command outputs the correct details for your GPU.
- Ensure that you have the necessary OpenCL and VAAPI/VDPAU drivers installed in the container.

## License

This project is open-source and available under the MIT License.
