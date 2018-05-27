FROM swift:4.1

ENV BUILDING_HOME=./building-binary

WORKDIR $BUILDING_HOME

COPY Sources Sources
COPY Tests Tests
COPY Package.swift Package.swift

# RUN swift build -c release
