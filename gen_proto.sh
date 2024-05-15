#!/bin/bash
protoc --dart_out=grpc:./lib/src/generated -I./lib/protobuf ./lib/protobuf/disconnect.proto
