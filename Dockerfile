FROM nvidia/cuda:11.8.0-base-ubuntu20.04

ENV ANTSPATH="/opt/ants-2.3.4/"
ENV PATH="/opt/ants-2.3.4:$PATH"
ENV TZ=America/Toronto


# SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL required due to
# some dependency listing "scikit-learn" as "sklearn" in its dependencies
ENV SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True

RUN apt-get update -qq && \
    apt-get install -y -q --no-install-recommends \
       ca-certificates \
       curl \
       git

RUN git clone https://github.com/itellaetxe/tractolearn.git /tractolearn

RUN apt install -y jq

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get -yq install libfontconfig1-dev

RUN apt-get install -y -q build-essential \
        autoconf \
        libtool \
        pkg-config \
        libgle3 && \
    apt-get -y install libblas-dev \
        liblapack-dev \
        gfortran \
        libxrender1

RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install -y python3.10 python3.10-dev python3.10-distutils python3.10-venv

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.10 get-pip.py && \
    pip install --upgrade pip

RUN rm -rf /var/lib/apt/lists/* && \
    echo "Downloading ANTs ..." && \
    mkdir -p /opt/ants-2.3.4 && \
    curl -fsSL https://dl.dropbox.com/s/gwf51ykkk5bifyj/ants-Linux-centos6_x86_64-v2.3.4.tar.gz \
        | tar -xz -C /opt/ants-2.3.4 --strip-components 1

RUN cd /tractolearn && pip install -e .

RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

RUN pip install -U numpy==1.23.*

RUN chmod +x /tractolearn/scripts/*

# To use fury in headless mode
ENV DISPLAY=:1
RUN Xvfb :1 -screen 1920x1080x24 > /dev/null 2>1 &
