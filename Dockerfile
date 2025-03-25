# Dockerfile
FROM expertswe-external-base:20250227-v3

RUN mkdir -p /root/repo

COPY repo.tar.gz /root/repo/repo.tar.gz

RUN tar -xf /root/repo/repo.tar.gz -C /root/repo

# Specific dependancies
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y -y lcov libboost-dev autoconf automake libtool dos2unix ccache ninja-build\
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

 # Trouble with EOL for Linux
RUN cd /root/repo/QuantLib && dos2unix * && find . -name \*.m4|xargs dos2unix \
 && find . -name \*.ac|xargs dos2unix \
 && find . -name \*.am|xargs dos2unix \
 && ./autogen.sh \
 && ./configure

# Unit tests in build directory with cmake toolchain
RUN mkdir /root/repo/QuantLib/build
RUN cd /root/repo/QuantLib/build \
 && cmake .. -GNinja -DBOOST_ROOT=/usr -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -L \
 && cmake --build . --verbose

# Coverage at the root QuantLib directory, to avoid conflict with unit tests
RUN cd /root/repo/QuantLib/ \
 && ./configure --disable-shared CXXFLAGS='-O1 -fprofile-arcs -ftest-coverage' LDFLAGS='-lgcov' \
 && make

# Set the working directory
WORKDIR /root/repo/QuantLib