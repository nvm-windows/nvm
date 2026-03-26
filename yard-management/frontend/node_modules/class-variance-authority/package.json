{
  "name": "class-variance-authority",
  "version": "0.7.1",
  "description": "Class Variance Authority 🧬",
  "keywords": [
    "Class Variance Authority",
    "class-variance-authority",
    "classes",
    "classname",
    "classnames",
    "css",
    "cva",
    "stitches",
    "vanilla-extract",
    "variants"
  ],
  "homepage": "https://github.com/joe-bell/cva#readme",
  "bugs": "https://github.com/joe-bell/cva/issues",
  "repository": "https://github.com/joe-bell/cva.git",
  "funding": "https://polar.sh/cva",
  "license": "Apache-2.0",
  "author": "Joe Bell (https://joebell.co.uk)",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.js",
      "types": "./dist/index.d.ts"
    },
    "./types": {
      "types": "./dist/types.d.ts"
    }
  },
  "main": "dist/index.js",
  "module": "dist/index.mjs",
  "types": "dist/index.d.ts",
  "files": [
    "dist/"
  ],
  "dependencies": {
    "clsx": "^2.1.1"
  },
  "devDependencies": {
    "@swc/cli": "0.3.12",
    "@swc/core": "1.4.16",
    "@types/node": "20.12.7",
    "@types/react": "18.2.79",
    "@types/react-dom": "18.2.25",
    "bundlesize": "0.18.2",
    "npm-run-all": "4.1.5",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "ts-node": "10.9.2",
    "typescript": "5.4.5"
  },
  "scripts": {
    "build": "run-p build:**",
    "build:cjs": "swc ./src/index.ts --config-file ./.config/.swcrc -o dist/index.js -C module.type=commonjs",
    "build:esm": "swc ./src/index.ts --config-file ./.config/.swcrc -o dist/index.mjs -C module.type=es6 ",
    "build:tsc": "tsc --project .config/tsconfig.build.json",
    "check": "tsc --project tsconfig.json --noEmit",
    "bundlesize": "pnpm build && bundlesize -f 'dist/*.js' -s 1.2KB"
  }
}