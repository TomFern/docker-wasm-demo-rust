.PHONY: clean build build-native build-wasm run

clean:
	rm -rf target

# build in host machine (requires toolchain)
build-native: target/release/docker-wasm-demo-rust.wasm
build-wasm: target/wasm32-wasi/release/docker-wasm-demo-rust.wasm

target/release/docker-wasm-demo-rust.wasm: src/main.rs
	cargo build --release

target/wasm32-wasi/release/docker-wasm-demo-rust.wasm: src/main.rs
	cargo build --target wasm32-wasi --release

# build and run in container (requires only docker)
build:
	docker build --platform wasi/wasm -f Dockerfile.build -t hello .

run:
	docker run --runtime=io.containerd.wasmedge.v1 --platform=wasi/wasm hello