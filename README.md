
A Rust version might be better
https://medium.com/@guglielmino/docker-webassembly-a-quick-intro-730c38e8390c
:

Application created with `cargo new docker-wasm-demo-rust`

## Build and run with native Rust

```bash
$ cargo run
   Compiling docker-wasm-demo-rust v0.1.0 (/Users/tom/r/demos/docker-wasm-demo-rust)
    Finished dev [unoptimized + debuginfo] target(s) in 0.40s
     Running `target/debug/docker-wasm-demo-rust`
Hello, world!
```

## Build Wwsm target

Requires [rustup](https://rustup.rs/) and [wasmtime](https://wasmtime.dev/)

Install wasm target tools:

```bash
$ rustup target add wasm32-wasi
```

Build wasm binary:

```bash
$ cargo build --target wasm32-wasi --release
```

Run binary:

```bash
$ wasmtime target/wasm32-wasi/debug/docker-wasm-demo-rust.wasm
Hello, world!
```

## Run Wasm inside Docker

Build the wasm target and then the Docker image (which copies the compiled binary):

```bash
$ docker build --platform wasi/wasm -f Dockerfile.compiled -t hello-wasm .
```

Run inside Docker container:

```bash
$ docker run --runtime=io.containerd.wasmedge.v1 --platform=wasi/wasm hello-wasm
Hello, world!
```

Note we no longer need wasmtime to run the wasm binary.

## One step further, build inside container

Need version 4.25.1 version of Docker Desktop and experimental containerd and Wasm options enabled.

Instead of building in the host machine, we build inside the container to provide a clean environment. This builds an OS-less container:

```bash
$ docker build --platform wasi/wasm -f Dockerfile.build -t hello .
```

Run the image:

```bash
$ docker run --runtime=io.containerd.wasmedge.v1 --platform=wasi/wasm hello
```

Note that we only need Docker. No Rust, wasmtime, or wasm32-wasi needed. The binary is compiled and run inside a container.

## Comparing sizes

The smallest binary is the one compiled to the target machine, but can only run on one architecture. The Wasm binary can run anywhere, even in browsers. When coupled with Docker, the smallest size possible is with a "from scratch" image. 

Note that the Rust image is big, but only used in the build process, not for the release. The Alpine image is shown for comparison as it would be an alternative way of running the Wasm binary if

| Type            | Size    | Multiplatform |
|-----------------|---------|---------------|
| Mach-O (native) | 444 kb  | no            |
| Wasm            | 2.1 mb  | yes           |
| Rust image      | 2.05 gb | no            |
| Alpine image    | 18 mb   | no            |
| Wasm image      | 2.66 mb | yes           |

