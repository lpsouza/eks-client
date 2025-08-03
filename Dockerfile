FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        unzip \
        ca-certificates \
        jq \
        iputils-ping \
        csvkit \
        neovim \
        less \
    && echo "alias vi='nvim'" >> /root/.bashrc \
    && echo "alias vim='nvim'" >> /root/.bashrc \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV EDITOR=nvim
ENV VISUAL=nvim

ARG TARGETARCH
ENV ARCH=${TARGETARCH:-amd64}

RUN set -e; \
    if [ "$ARCH" = "arm64" ]; then \
        AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"; \
    else \
        AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"; \
    fi && \
    curl -ksSL "$AWS_CLI_URL" -o "/tmp/awscli-exe-linux.zip" && \
    unzip /tmp/awscli-exe-linux.zip -d /tmp && \
    /tmp/aws/install --update && \
    rm -rf /tmp/awscli-exe-linux.zip /tmp/aws && \
    curl -ksSL -o kubectl "https://dl.k8s.io/release/$(curl -ksSL https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" && \
    install -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl && \
    HELM_VERSION=$(curl -ksSL https://api.github.com/repos/helm/helm/releases/latest | jq -r .tag_name) && \
    curl -ksSL -o helm.tar.gz "https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz" && \
    tar -zxvf helm.tar.gz && \
    mv linux-${ARCH}/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf helm.tar.gz linux-${ARCH} && \
    curl -sSL -o kubectl-argo-rollouts "https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-${ARCH}" && \
    install -m 0755 kubectl-argo-rollouts /usr/local/bin/kubectl-argo-rollouts && \
    rm kubectl-argo-rollouts && \
    curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-${ARCH}" && \
    install -m 0755 argocd /usr/local/bin/argocd && \
    rm argocd && \
    KUSTOMIZE_VERSION=$(curl -sSL https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest | jq -r .tag_name | sed 's/^kustomize\///') && \
    curl -sSLO "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz" && \
    tar -zxvf kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    mv kustomize /usr/local/bin/kustomize && \
    chmod +x /usr/local/bin/kustomize && \
    rm kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    K9S_VERSION=$(curl -sSL https://api.github.com/repos/derailed/k9s/releases/latest | jq -r .tag_name) && \
    curl -sSL -o k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz" && \
    tar -zxvf k9s.tar.gz k9s && \
    mv k9s /usr/local/bin/k9s && \
    chmod +x /usr/local/bin/k9s && \
    rm k9s.tar.gz && \
    if [ "$ARCH" = "amd64" ]; then \
        KUBECM_ARCH="x86_64"; \
    else \
        KUBECM_ARCH="arm64"; \
    fi && \
    KUBECM_VERSION=$(curl -sSL https://api.github.com/repos/sunny0826/kubecm/releases/latest | jq -r .tag_name) && \
    curl -sSL -o kubecm.tar.gz "https://github.com/sunny0826/kubecm/releases/download/${KUBECM_VERSION}/kubecm_${KUBECM_VERSION}_linux_${KUBECM_ARCH}.tar.gz" && \
    tar -zxvf kubecm.tar.gz kubecm && \
    mv kubecm /usr/local/bin/kubecm && \
    chmod +x /usr/local/bin/kubecm && \
    rm kubecm.tar.gz && \
    if [ "$ARCH" = "amd64" ]; then \
        STARSHIP_ARCH="x86_64"; \
    else \
        STARSHIP_ARCH="aarch64"; \
    fi && \
    STARSHIP_VERSION=$(curl -sSL https://api.github.com/repos/starship/starship/releases/latest | jq -r .tag_name) && \
    curl -sSL -o starship.tar.gz "https://github.com/starship/starship/releases/download/${STARSHIP_VERSION}/starship-${STARSHIP_ARCH}-unknown-linux-musl.tar.gz" && \
    tar -zxvf starship.tar.gz starship && \
    mv starship /usr/local/bin/starship && \
    chmod +x /usr/local/bin/starship && \
    echo 'eval "$(starship init bash)"' >> /root/.bashrc && \
    rm starship.tar.gz

ADD starship.toml /root/.config/starship.toml

ADD scripts/eks.sh /usr/local/bin/kubectl-eks
RUN chmod +x /usr/local/bin/kubectl-eks

WORKDIR /root

CMD ["sleep", "infinity"]
