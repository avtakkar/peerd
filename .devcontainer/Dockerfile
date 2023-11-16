# This is a dockerfile specifically for running as a devcontainer
FROM mcr.microsoft.com/oss/go/microsoft/golang:1.21-fips-cbl-mariner2.0
RUN tdnf update -y && tdnf install make -y && tdnf install git -y && tdnf install gawk -y

RUN go install github.com/cweill/gotests/gotests@latest && \
    go install github.com/fatih/gomodifytags@latest && \
    go install github.com/josharian/impl@latest && \
    go install github.com/haya14busa/goplay/cmd/goplay@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest && \
    go install honnef.co/go/tools/cmd/staticcheck@latest && \
    go install golang.org/x/tools/gopls@latest

WORKDIR /go/src/github.com/azure/peerd
