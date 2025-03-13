# circuitOS
> An operating system, I guess

## What
circuitOS is a starting project that aims to be similar to macOS, but much more extensible and is FOSS/libre.

## Development
To set up a development environment, source the `devenv` file.

It currently:
- Aliases `ext/build/build.sh` to `build`.

You may also add the below snippet to your `.bashrc` file to automatically source
`devenv` if the starting directory is the path to your clone of this repo.
```bash
if [[ $(pwd) == "<PATH TO REPO>" ]]; then
        source ./devenv
fi
```