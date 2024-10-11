# Step 1: Base image
FROM ghcr.io/linuxserver/plex:latest AS base

# Step 2: Install basic dependencies and rsync (dependency of amdgpu-install)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    libnuma1 \
    rsync \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 3: Download and install the AMDGPU-Pro package
RUN apt-get update && \
    apt-get install -y curl && \
    VERSION=$(curl -s https://repo.radeon.com/amdgpu-install/latest/ubuntu/noble/ | \
    grep -oP 'amdgpu-install_\K[\d.-]+(?=_all\.deb)' | head -n 1) && \
    curl -sL https://repo.radeon.com/amdgpu-install/latest/ubuntu/noble/amdgpu-install_${VERSION}_all.deb -o amdgpu-install.deb && \
    dpkg -i amdgpu-install.deb || apt-get install -f -y && \
    rm -f amdgpu-install.deb

# Step 4: Run the AMDGPU-Pro script with EULA acceptance and no DKMS
RUN /usr/bin/amdgpu-install -y --accept-eula --no-dkms --opencl=rocr  && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 5: Enable Universe and Multiverse repositories and install VAAPI and VDPAU for hardware transcoding
RUN add-apt-repository universe && \
    add-apt-repository multiverse && \
    apt-get update && \
    apt-get install -y \
    vainfo \
    mesa-va-drivers \
    mesa-vdpau-drivers \
    libdrm-amdgpu1 \
    libva2 \
    libva-drm2 \
    libva-x11-2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 6: Add Plex user to the video group for GPU permissions
RUN usermod -aG video abc

# Environment variables to allow the use of hardware acceleration
ENV PLEX_MEDIA_SERVER_INFO_VENDOR=AMD
ENV PLEX_MEDIA_SERVER_INFO_DEVICE=AMDGPU-Pro

RUN clinfo
