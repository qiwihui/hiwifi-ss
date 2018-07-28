help:
	@echo "make"

default:
	tar -C ./ -czvf hiwifi-ss.tar.gz etc lib usr

pack:
	tar -C ./ -czvf hiwifi-ss.tgz manifest.json script hiwifi-ss.tar.gz

all: default pack
