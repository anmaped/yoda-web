# Yoda Web

## Build and Run

```bash
opam install ./yoda-web.opam --deps-only
dune build src/main.bc.js --profile release
cp _build/default/src/main.bc.js ./static/main.bc.js
# Then serve the static folder with a web server and access it in a browser.
```

## Container Image

The repository includes an nginx runtime image in [Containerfile](Containerfile) and a GitHub Actions workflow in [.github/workflows/build-container-image.yml](.github/workflows/build-container-image.yml).
