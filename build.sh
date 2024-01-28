#!/bin/bash
rm -rf .tmp

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

DSM6_VERSION="6.0-7321"
DSM7_VERSION="7.0-41890"

update_info() {
    sed -i -e "s/^$1=.*/$1=\"$2\"/" .tmp/INFO
}

build_arch() {
    arch=$1
    dsm6_arch=$2
    dsm7_arch=$3

    echo "building $arch..."

    mkdir .tmp
    cp binary/frpc_linux_$arch package/bin/frpc
    cp binary/natfrp_service_linux_$arch package/bin/natfrp-service
    chmod 755 package/bin/*

    tar --exclude bin/.gitkeep -C package \
        --owner=root --group=root --mtime="$TIMESTAMP" \
        -cpzf .tmp/package.tgz .
    checksum=$(md5sum .tmp/package.tgz | cut -d" " -f1)

    cp -rf spk/* .tmp
    update_info version "$version"
    update_info checksum "$checksum"

    # DSM6 specific files
    cp -rf spk-$DSM6_VERSION/* .tmp
    update_info os_min_ver "$DSM6_VERSION"
    update_info arch "$dsm6_arch"

    tar -C .tmp \
        --group=root --owner=root --mtime="$TIMESTAMP" \
        -cpf "./release/natfrp_${arch}-${DSM6_VERSION}_${version}.spk" \
        package.tgz INFO scripts PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG WIZARD_UIFILES conf

    # DSM7 specific files
    cp -rf spk-$DSM7_VERSION/* .tmp
    update_info os_min_ver "$DSM7_VERSION"
    update_info arch "$dsm7_arch"

    tar -C .tmp \
        --group=root --owner=root --mtime="$TIMESTAMP" \
        -cpf "./release/natfrp_${arch}-${DSM7_VERSION}_${version}.spk" \
        package.tgz INFO scripts PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG WIZARD_UIFILES conf

    rm package/bin/frpc package/bin/natfrp-service
    rm -rf .tmp
}

chmod +x binary/natfrp_service_linux_amd64
version=$(binary/natfrp_service_linux_amd64 -v)
echo "service version: $version"

version=$version-1

# todo: package

build_arch amd64 \
    "apollolake avoton braswell broadwell broadwellnk broadwellntbap bromolow cedarview denverton dockerx64 geminilake grantley purley kvmx64 v1000 x86 x86_64" \
    "apollolake avoton braswell broadwell broadwellnk broadwellnkv2 broadwellntbap bromolow cedarview denverton epyc7002 geminilake grantley kvmx64 purley r1000 v1000"

build_arch arm64 \
    "rtd1296 armada37xx" \
    "rtd1296 rtd1619b armada37xx"


build_arch armv7 \
    "alpine alpine4k armada370 armada375 armada38x armadaxp comcerto2k monaco" \
    "alpine alpine4k armada370 armada375 armada38x armadaxp monaco"
