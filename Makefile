################################################################################
# Common aliases lifted from other Makefiles
package  = alpine-haskell
main_exe = demo

# Use GHC options informed by this blog post:
# https://rybczak.net/2016/03/26/how-to-reduce-compilation-times-of-haskell-projects/
ghc_opts   = -j +RTS -A128m -RTS
stack_yaml = STACK_YAML="stack.yaml"

# All stack commands will be executed in the Docker container
stack = $(stack_yaml) stack --docker

################################################################################
# Standard build (runs in the Docker container)
.PHONY: build
build:
	$(stack) build $(package) \
	--ghc-options='$(ghc_opts)'

# Fast build (-O0) (runs in the Docker container)
.PHONY: build-fast
build-fast:
	$(stack) build $(package) \
	--ghc-options='$(ghc_opts)' \
	--fast

# Clean up all build artifacts
clean:
	$(stack) clean

# Run ghcid (runs in the Docker container)
ghcid:
	ghcid \
	--command "$(stack) ghci \
			--ghci-options='-fobject-code $(ghc_opts)' \
			--main-is $(package):$(main_exe)"

################################################################################
# Convenience targets for building GHC locally
#
# The intermediate layers of the multi-stage Docker build file are cached so
# that changes to the Dockerfile don't force us to rebuild GHC when developing

# Build GHC with support for 'integer-gmp' and 'libgmp'
.PHONY: docker-build-gmp
docker-build-gmp: docker-base-gmp docker-ghc-gmp docker-tooling-gmp docker-image-gmp

.PHONY: docker-base-gmp
docker-base-gmp:
	docker build \
	  --build-arg GHC_BUILD_TYPE=gmp \
	  --target base \
	  --tag alpine-haskell-gmp:base \
	  --cache-from alpine-haskell-gmp:base \
	  --file Dockerfile \
	  .

.PHONY: docker-ghc-gmp
docker-ghc-gmp:
	docker build \
	  --build-arg GHC_BUILD_TYPE=gmp \
	  --target build-ghc \
	  --tag alpine-haskell-gmp:build-ghc \
	  --cache-from alpine-haskell-gmp:build-ghc \
	  --cache-from alpine-haskell-gmp:base \
	  --file Dockerfile \
	  .

.PHONY: docker-tooling-gmp
docker-tooling-gmp:
	docker build \
	  --build-arg GHC_BUILD_TYPE=gmp \
	  --target build-tooling \
	  --tag alpine-haskell-gmp:build-tooling \
	  --cache-from alpine-haskell-gmp:build-tooling\
	  --cache-from alpine-haskell-gmp:build-ghc\
	  --cache-from alpine-haskell-gmp:base \
	  --file Dockerfile \
	  .

.PHONY: docker-image-gmp
docker-image-gmp:
	docker build \
	  --build-arg GHC_BUILD_TYPE=gmp \
	  --tag alpine-haskell-gmp:latest \
	  --cache-from alpine-haskell-gmp:latest \
	  --cache-from alpine-haskell-gmp:build-tooling \
	  --cache-from alpine-haskell-gmp:build-ghc \
	  --cache-from alpine-haskell-gmp:base \
	  --file Dockerfile \
	  .

# Build GHC with support for 'integer-simple'
.PHONY: docker-build-simple
docker-build-simple: docker-base-simple docker-ghc-simple docker-tooling-simple docker-image-simple

.PHONY: docker-base-simple
docker-base-simple:
	docker build \
	  --build-arg GHC_BUILD_TYPE=simple \
	  --target base \
	  --tag alpine-haskell-simple:base \
	  --cache-from alpine-haskell-simple:base \
	  --file Dockerfile \
	  .

.PHONY: docker-ghc-simple
docker-ghc-simple:
	docker build \
	  --build-arg GHC_BUILD_TYPE=simple \
	  --target build-ghc \
	  --tag alpine-haskell-simple:build-ghc \
	  --cache-from alpine-haskell-simple:build-ghc \
	  --cache-from alpine-haskell-simple:base \
	  --file Dockerfile \
	  .

.PHONY: docker-tooling-simple
docker-tooling-simple:
	docker build \
	  --build-arg GHC_BUILD_TYPE=simple \
	  --target build-tooling \
	  --tag alpine-haskell-simple:build-tooling \
	  --cache-from alpine-haskell-simple:build-tooling\
	  --cache-from alpine-haskell-simple:build-ghc\
	  --cache-from alpine-haskell-simple:base \
	  --file Dockerfile \
	  .

.PHONY: docker-image-simple
docker-image-simple:
	docker build \
	  --build-arg GHC_BUILD_TYPE=simple \
	  --tag alpine-haskell-simple:latest \
	  --cache-from alpine-haskell-simple:latest \
	  --cache-from alpine-haskell-simple:build-tooling \
	  --cache-from alpine-haskell-simple:build-ghc \
	  --cache-from alpine-haskell-simple:base \
	  --file Dockerfile \
	  .
