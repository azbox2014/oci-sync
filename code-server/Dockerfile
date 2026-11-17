ARG TARGETARCH
ARG BASE_VERSION=latest
FROM docker.io/linuxserver/code-server:${BASE_VERSION}

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# =========================
# base tools
# =========================
RUN apt update && apt install -y --no-install-recommends \
    curl \
    git \
    jq \
    skopeo \
    ca-certificates \
    tzdata \
    wget \
    rsync \
    unzip \
    gnupg \
    zsh \
    sudo \
    aria2 \
    vim \
    gh \
    tmux \
    nfs-common \
    wireguard-tools \
    dnsutils \
    file \
    iputils-ping \
    rclone \
    ripgrep \
    build-essential \
    pkg-config libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# =========================
# nodejs lts
# =========================
RUN set -eux; \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -; \
    apt-get install -y --no-install-recommends nodejs; \
    rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
# =========================
# arch mapping
# =========================
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) ARCH="amd64" ;; \
        arm64) ARCH="arm64" ;; \
        *) echo "unsupported arch: ${TARGETARCH}" && exit 1 ;; \
    esac; \
    echo "ARCH=${ARCH}" > /tmp/arch.env

# =========================
# yq
# =========================
RUN set -eux; \
    . /tmp/arch.env; \
    curl -L "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}" \
      -o /usr/local/bin/yq; \
    chmod +x /usr/local/bin/yq

RUN set -eux; \
    . /tmp/arch.env; \
    REGCTL_VERSION="v0.11.3"; \
    curl -L https://github.com/regclient/regclient/releases/download/${REGCTL_VERSION}/regctl-linux-${ARCH} \
      -o /usr/local/bin/regctl && \
    chmod +x /usr/local/bin/regctl

# =========================
# kubectl
# =========================
RUN set -eux; \
    . /tmp/arch.env; \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl"; \
    chmod +x kubectl; \
    mv kubectl /usr/local/bin/

# =========================
# helm
# =========================
RUN set -eux; curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash

# =========================
# flux
# =========================
RUN set -eux; curl -s https://fluxcd.io/install.sh | bash


RUN set -eux; \
    . /tmp/arch.env; \
    KUSTOMIZE_VERSION="v5.8.1"; \
    case "${ARCH}" in \
        amd64) KUSTOMIZE_ARCH="amd64" ;; \
        arm64) KUSTOMIZE_ARCH="arm64" ;; \
        *) echo "unsupported arch for kustomize: ${ARCH}" && exit 1 ;; \
    esac; \
    curl -L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${KUSTOMIZE_ARCH}.tar.gz" \
      -o /tmp/kustomize.tar.gz; \
    tar -xzf /tmp/kustomize.tar.gz -C /tmp; \
    mv /tmp/kustomize /usr/local/bin/kustomize; \
    chmod +x /usr/local/bin/kustomize; \
    rm -f /tmp/kustomize.tar.gz


# =========================
# docker buildx cli plugin
# =========================
RUN set -eux; \
    . /tmp/arch.env; \
    BUILDX_VERSION="v0.35.0"; \
    case "${ARCH}" in \
        amd64) BUILDX_ARCH="amd64" ;; \
        arm64) BUILDX_ARCH="arm64" ;; \
        *) echo "unsupported arch for buildx: ${ARCH}" && exit 1 ;; \
    esac; \
    mkdir -p /usr/local/lib/docker/cli-plugins; \
    curl -L "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-${BUILDX_ARCH}" \
      -o /usr/local/lib/docker/cli-plugins/docker-buildx; \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx

# =========================
# buildkit (buildctl)
# =========================
RUN set -eux; \
    . /tmp/arch.env; \
    BUILDKIT_VERSION="v0.29.0"; \
    case "${ARCH}" in \
        amd64) BUILDKIT_ARCH="amd64" ;; \
        arm64) BUILDKIT_ARCH="arm64" ;; \
        *) echo "unsupported arch for buildkit: ${ARCH}" && exit 1 ;; \
    esac; \
    mkdir -p /tmp/buildkit-extract; \
    curl -L "https://github.com/moby/buildkit/releases/download/${BUILDKIT_VERSION}/buildkit-${BUILDKIT_VERSION}.linux-${BUILDKIT_ARCH}.tar.gz" -o buildkit.tgz; \
    tar -xzf buildkit.tgz -C /tmp/buildkit-extract; \
    mv /tmp/buildkit-extract/bin/buildctl /usr/local/bin/buildctl; \
    chmod +x /usr/local/bin/buildctl; \
    rm -rf buildkit.tgz /tmp/buildkit-extract

# =========================
# docker cli (remote daemon)
# =========================
RUN set -eux; \
    . /tmp/arch.env; \
    DOCKER_VERSION="29.6.1"; \
    case "${ARCH}" in \
        amd64) DOCKER_ARCH="x86_64" ;; \
        arm64) DOCKER_ARCH="aarch64" ;; \
        *) echo "unsupported arch for docker cli: ${ARCH}" && exit 1 ;; \
    esac; \
    curl -fL "https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-${DOCKER_VERSION}.tgz" -o docker.tgz; \
    tar -xzf docker.tgz; \
    mv docker/docker /usr/local/bin/docker; \
    chmod +x /usr/local/bin/docker; \
    rm -rf docker.tgz docker

# install age
RUN AGE_VERSION=v1.3.1 && \
    curl -L https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz \
    | tar xz && \
    mv age/age /usr/local/bin/ && \
    mv age/age-keygen /usr/local/bin/ && \
    chmod +x /usr/local/bin/age*

# install sops
RUN SOPS_VERSION=v3.12.2 && \
    curl -L https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64 \
    -o /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# Oh My Zsh & 插件（放系统目录）
# gitcode 对数据中心 IP 返回 418 反爬（GitHub Actions runner 必挂），故从 GitHub 克隆，
# 克隆完成后把 origin 改指 gitcode 镜像，容器内后续 git pull 走国内源；
# --depth 1 只取工作区文件（镜像内不做历史相关操作），大幅缩短传输、降低中断概率
RUN set -eux; \
    clone() { \
        dest="$1"; src="$2"; mirror="$3"; \
        ok=""; \
        for i in 1 2 3; do \
            rm -rf "$dest"; \
            if git clone --depth 1 "$src" "$dest"; then ok=1; break; fi; \
            echo "WARN: clone ${src} attempt ${i} failed, retrying..."; \
            sleep 5; \
        done; \
        [ -n "$ok" ] || { echo "ERROR: clone failed: ${src}"; return 1; }; \
        git -C "$dest" remote set-url origin "$mirror"; \
        git -C "$dest" remote -v; \
    }; \
    clone /opt/oh-my-zsh \
        https://github.com/ohmyzsh/ohmyzsh.git \
        https://gitcode.com/gh_mirrors/oh/ohmyzsh.git; \
    clone /opt/oh-my-zsh/custom/themes/powerlevel10k \
        https://github.com/romkatv/powerlevel10k.git \
        https://gitcode.com/GitHub_Trending/po/powerlevel10k.git; \
    clone /opt/oh-my-zsh/custom/plugins/zsh-autosuggestions \
        https://github.com/zsh-users/zsh-autosuggestions.git \
        https://gitcode.com/gh_mirrors/zs/zsh-autosuggestions.git

# 设置默认 shell
RUN usermod -s /usr/bin/zsh abc

# 拷贝初始化脚本
COPY init-zsh.sh /usr/local/bin/init-zsh.sh
RUN chmod +x /usr/local/bin/init-zsh.sh 

# 挂到 linuxserver 启动流程
RUN mkdir -p /custom-cont-init.d && \
    ln -s /usr/local/bin/init-zsh.sh /custom-cont-init.d/10-zsh-init
