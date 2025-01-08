# Obtiene la lista de todos los directorios dentro de la carpeta "cmd"
CMD_DIRS := $(wildcard ./cmd/functions/*)

# Obtiene la lista de nombres de los programas a partir de los nombres de las carpetas
PROGRAMS := $(notdir $(CMD_DIRS))

# Directorio donde se guardarán los binarios compilados
BUILD_DIR := ./bin

# Flags de compilación (puedes personalizarlos según tus necesidades)
LDFLAGS := -ldflags="-s -w"

# Comando predeterminado: compila todos los programas
all: $(PROGRAMS)

# Regla genérica para compilar programas
$(PROGRAMS):
	@echo "compiling $@..."
	@GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build $(LDFLAGS) -o ./cmd/functions/$@/main ./cmd/functions/$@
	@if [ -d "./cmd/functions/$@/prefill" ]; then \
	    echo "compiling Prefill $@..."; \
	    GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o ./cmd/functions/$@/prefill/main ./cmd/functions/$@/prefill/prefill.go; \
	fi


build: $(PROGRAMS)

deploy:
	make build
	sam validate --lint
	sam deploy \
--config-file samconfig.dev.toml \
--config-env dev --no-fail-on-empty-changeset \
--s3-bucket aws-sam-cli-managed-default-samclisourcebucket-gnubfclunrpu
	make clean

local-deploy:
	make build
	sam local start-api

deploy-promote:
	make build
	sam validate --lint
	sam deploy \
--config-file samconfig.toml \
--config-env prod --no-fail-on-empty-changeset \
--s3-bucket aws-sam-cli-managed-default-samclisourcebucket-gnubfclunrpu
	make clean

deploy-front:
	cd ./hoot && ng build -c=development
	cd ./hoot && aws s3 cp ./dist/hoot/browser/ s3://dev.boardgamemate.com --recursive
	cd ./hoot && rm -rf ./dist/

promote-front:
	cd ./hoot && ng build -c=production
	cd ./hoot && aws s3 cp ./dist/hoot/browser/ s3://boardgamemate.com --recursive
	cd ./hoot && rm -rf ./dist/

deploy-stack:
	make deploy
	make deploy-front

promote-stack:
	make deploy-promote
	make promote-front

# Regla para limpiar los binarios compilados
clean:
	@echo "Cleaning compiled files..."
	@for dir in $(CMD_DIRS); do \
		rm -f $$dir/main; \
		rm -f $$dir/prefill/main; \
	done

# Indicar que "clean" no es un archivo de salida
.PHONY: clean
