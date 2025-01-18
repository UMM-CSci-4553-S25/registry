# Why do we need this registry?

Some of the crates needed for this course are not (yet) provided on [crates.io](https://crates.io), but instead only available through this registry or directly as a git dependency.

This includes both the [evolutionary computation framework](https://github.com/unhindered-ec/unhindered-ec) we'll be using, as well as the [course support crate](https://github.com/UMM-CSci-4553-S25/course-helpers).

> [!TIP]
> To simplify the installation process, we strongly recommend you use this registry to install the packages over direct git dependencies.
>
> This will also make sure you are always on compatible versions

# How to use this registry

To use this registry you need to configure cargo to use an external registry. This can be done in multiple places:

- For the current project, you can set a local configuration inside `.cargo/config.toml` relative to the project root.
- For the current user, you can set a global configuration inside `~/.cargo/config.toml`

> [!TIP]
> All templates provided for exercises in this course will have the registry already configured under the name `ec-course` using the local config file.
> Feel free to skip the remainder of this section if you don't ever plan to use the provided crates for any other cargo project you've created on your own.

To add a registry, add a section according to the following template to any of those configurations:

```toml
# .cargo/config.toml (Note: NOT Cargo.toml)
[registries.<registry-name>]
index = "http://<git-repo>"
```

more specifically for this registry, use

```toml
# .cargo/config.toml (Note: NOT Cargo.toml)
[registries.ec-course]
index = "https://github.com/UMM-CSci-4553-S25/registry.git"
```
to set up a local registry called `ec-course`.

Make sure that, if present, you put the section directly after any existing `[registries]` sections.

> [!NOTE]
> You are of course free to pick another name than `ec-course`. If you do, be aware that:

> [!WARNING]
> In case you pick another name, replace `ec-course` with your own name in the relevant commands and config files. The remaining documentation will assume you are using the name `ec-course`.

# How to install packages from this registry

Once you've set up the registry according to the instructions above, you'll be able to use

```bash
cargo add --registry ec-course <package-name>
```

to install the dependencies specific to this course

> [!TIP]
> This of course doesn't replace the normal installation process for crates available from rust's provided registry, [crates.io](https://crates.io).
> In case you want to install any of the crates from there, just skip the `--registry ec-course` in the command as follows:
>
> ```bash
> cargo add <package-name>
> ```
>
> To discover new crates, you can browse [crates.io's website](https://crates.io). As an alternative, the [lib.rs](https://lib.rs) website also provides a more opinionated interface for the same crates and has a ranking and collections of commonly used crates in their respective categories, so you might want to take a look at that as well.
>
> This will work as long as you have not re-configured your default registry. If you know how to do that and you have, this tutorial probably isn't meant for you :)

This will then add the dependencies to your projects `Cargo.toml` config file.

If you for example installed the crate `ec-core` (using `cargo add --registry ec-course ec-core`) it should have a section similar to this

```toml
[dependencies]
# \/ this is the relevant line
ec-core = { version = "0.1.0-course.1", registry = "ec-course" }
```

(Depending on when you do this the version `0.1.0-course.1` might be different)

> [!TIP]
> If you wish to instead manually add dependencies, you can just edit the `Cargo.toml` and add the line shown above under the `[dependencies]` section.
>
> For the remainder of this course we'll use the `cargo add` command - that's also the way we recommend to add new dependencies.


> [!TIP]
> Lines starting with `#` are comments and will be ignored. To find out more about the configuration format used by rust, namely `toml`, you can take a look at the [official toml website](https://toml.io/en/) which documents the format

> [!NOTE]
> Crates provided by this registry don't have their docs published on rust's official [docs.rs](https://docs.rs) documentation site, which hosts the documentation of all crates provied by [crates.io](https://crates.io). To browse the documentation of crates installed from this registry, you can open the docs for all the crates in the current project by using the `cargo doc --open` command from the project root.
>
> Alternative ways of viewing the documentation might also be provided by some crates. Please see the notes in the respective lectures. 

# How to publish/update this registry
> [!CAUTION]
> This section is meant for contributing to this repository and not relevant for normal usage. If you are a student, this is probably not relevant for you :)

> [!WARNING]
> These steps are meant to be followed on unix-like systems having the bash shell installed, and present in the PATH variable.
> They won't work without modifications on other systems.

> [!NOTE]
> A working rust toolchain installation as well as a recent git version is required. Other tools required will be installed using `cargo install` on the first launch of the script. Currently those are `tomli` and `cargo-http-registry`

This repository contains a [`start-local-registry-server.sh` script](start-local-registry-server.sh). This script can be used to start a local api server for this registry using [cargo-http-registry](https://github.com/d-e-s-o/cargo-http-registry), and register a registry called local-server in the user's global config. 

To do that, run
```bash
./start-local-registry-server.sh
```

A message will appear letting you know when the registry is started.
Be aware that this tries to use the port `35503`, so make sure that port is free in case any errors occur.

Using the local api server you can then use the standard `cargo` infrastructure to publish packages:

```bash
cargo publish --registry local-server
```

You might be asked to login to the registry. If that's the case you can use

```bash
cargo login --registry local-server
```

with any token of your choosing (the local server doesn't validate the token).

Follow any other instructions from the script.

> [!CAUTION]
> It is crucial for the functioning of this registry that the config.toml file in the root of this repositiory won't be modified.
>
> Since the crate used to start a local registry server might reset the config, a revert step was introduced in the script. This should automatically be executed once you exit the server using the signals `INT` or `TERM`.
>
> Please double-check before pushing that that is actually the case.

> [!NOTE]
> The local registy will automatically commit any newly published crate versions in your local copy of this repository.

After you are finished modifying this repository, contribute back your changes using the normal git contribution process.
