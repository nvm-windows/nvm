# regexparam [![CI](https://github.com/lukeed/regexparam/actions/workflows/ci.yml/badge.svg)](https://github.com/lukeed/regexparam/actions/workflows/ci.yml)

> A tiny (399B) utility that converts route patterns into RegExp. Limited alternative to [`path-to-regexp`](https://github.com/pillarjs/path-to-regexp) 🙇

With `regexparam`, you may turn a pathing string (eg, `/users/:id`) into a regular expression.

An object with shape of `{ keys, pattern }` is returned, where `pattern` is the `RegExp` and `keys` is an array of your parameter name(s) in the order that they appeared.

Unlike [`path-to-regexp`](https://github.com/pillarjs/path-to-regexp), this module does not create a `keys` dictionary, nor mutate an existing variable. Also, this only ships a parser, which only accept strings. Similarly, and most importantly, `regexparam` **only** handles basic pathing operators:

* Static (`/foo`, `/foo/bar`)
* Parameter (`/:title`, `/books/:title`, `/books/:genre/:title`)
* Parameter w/ Suffix (`/movies/:title.mp4`, `/movies/:title.(mp4|mov)`)
* Optional Parameters (`/:title?`, `/books/:title?`, `/books/:genre/:title?`)
* Wildcards (`*`, `/books/*`, `/books/:genre/*`)
* Optional Wildcard (`/books/*?`)

This module exposes three module definitions:

* **CommonJS**: [`dist/index.js`](https://unpkg.com/regexparam/dist/index.js)
* **ESModule**: [`dist/index.mjs`](https://unpkg.com/regexparam/dist/index.mjs)
* **UMD**: [`dist/index.min.js`](https://unpkg.com/regexparam/dist/index.min.js)

## Install

```
$ npm install --save regexparam
```


## Usage

```js
import { parse, inject } from 'regexparam';

// Example param-assignment
function exec(path, result) {
  let i=0, out={};
  let matches = result.pattern.exec(path);
  while (i < result.keys.length) {
    out[ result.keys[i] ] = matches[++i] || null;
  }
  return out;
}


// Parameter, with Optional Parameter
// ---
let foo = parse('/books/:genre/:title?')
// foo.pattern => /^\/books\/([^\/]+?)(?:\/([^\/]+?))?\/?$/i
// foo.keys => ['genre', 'title']

foo.pattern.test('/books/horror'); //=> true
foo.pattern.test('/books/horror/goosebumps'); //=> true

exec('/books/horror', foo);
//=> { genre: 'horror', title: null }

exec('/books/horror/goosebumps', foo);
//=> { genre: 'horror', title: 'goosebumps' }


// Parameter, with suffix
// ---
let bar = parse('/movies/:title.(mp4|mov)');
// bar.pattern => /^\/movies\/([^\/]+?)\.(mp4|mov)\/?$/i
// bar.keys => ['title']

bar.pattern.test('/movies/narnia'); //=> false
bar.pattern.test('/movies/narnia.mp3'); //=> false
bar.pattern.test('/movies/narnia.mp4'); //=> true

exec('/movies/narnia.mp4', bar);
//=> { title: 'narnia' }


// Wildcard
// ---
let baz = parse('users/*');
// baz.pattern => /^\/users\/(.*)\/?$/i
// baz.keys => ['*']

baz.pattern.test('/users'); //=> false
baz.pattern.test('/users/lukeed'); //=> true
baz.pattern.test('/users/'); //=> true


// Optional Wildcard
// ---
let baz = parse('/users/*?');
// baz.pattern => /^\/users(?:\/(.*))?(?=$|\/)/i
// baz.keys => ['*']

baz.pattern.test('/users'); //=> true
baz.pattern.test('/users/lukeed'); //=> true
baz.pattern.test('/users/'); //=> true


// Injecting
// ---

inject('/users/:id', {
  id: 'lukeed'
}); //=> '/users/lukeed'

inject('/movies/:title.mp4', {
  title: 'narnia'
}); //=> '/movies/narnia.mp4'

inject('/:foo/:bar?/:baz?', {
  foo: 'aaa'
}); //=> '/aaa'

inject('/:foo/:bar?/:baz?', {
  foo: 'aaa',
  baz: 'ccc'
}); //=> '/aaa/ccc'

inject('/posts/:slug/*', {
  slug: 'hello',
}); //=> '/posts/hello'

inject('/posts/:slug/*', {
  slug: 'hello',
  '*': 'x/y/z',
}); //=> '/posts/hello/x/y/z'

// Missing non-optional value
// ~> keeps the pattern in output
inject('/hello/:world', {
  abc: 123
}); //=> '/hello/:world'
```

> **Important:** When matching/testing against a generated RegExp, your path **must** begin with a leading slash (`"/"`)!

## Regular Expressions

For fine-tuned control, you may pass a `RegExp` value directly to `regexparam` as its only parameter.

In these situations, `regexparam` **does not** parse nor manipulate your pattern in any way! Because of this, `regexparam` has no "insight" on your route, and instead trusts your input fully. In code, this means that the return value's `keys` is always equal to `false` and the `pattern` is identical to your input value.

This also means that you must manage and parse your own `keys`~!<br>
You may use [named capture groups](https://javascript.info/regexp-groups#named-groups) or traverse the matched segments manually the "old-fashioned" way:

> **Important:** Please check your target browsers' and target [Node.js runtimes' support](https://node.green/#ES2018-features--RegExp-named-capture-groups)!

```js
// Named capture group
const named = regexparam.parse(/^\/posts[/](?<year>[0-9]{4})[/](?<month>[0-9]{2})[/](?<title>[^\/]+)/i);
const { groups } = named.pattern.exec('/posts/2019/05/hello-world');
console.log(groups);
//=> { year: '2019', month: '05', title: 'hello-world' }

// Widely supported / "Old-fashioned"
const named = regexparam.parse(/^\/posts[/]([0-9]{4})[/]([0-9]{2})[/]([^\/]+)/i);
const [url, year, month, title] = named.pattern.exec('/posts/2019/05/hello-world');
console.log(year, month, title);
//=> 2019 05 hello-world
```


## API

### regexparam.parse(input: RegExp)
### regexparam.parse(input: string, loose?: boolean)
Returns: `Object`

Parse a route pattern into an equivalent RegExp pattern. Also collects the names of pattern's parameters as a `keys` array. An `input` that's already a RegExp is kept as is, and `regexparam` makes no additional insights.

Returns a `{ keys, pattern }` object, where `pattern` is always a `RegExp` instance and `keys` is either `false` or a list of extracted parameter names.

> **Important:** The `keys` will _always_ be `false` when `input` is a RegExp and it will _always_ be an Array when `input` is a string.

#### input
Type: `string` or `RegExp`

When `input` is a string, it's treated as a route pattern and an equivalent RegExp is generated.

> **Note:** It does not matter if `input` strings begin with a `/` &mdash; it will be added if missing.

When `input` is a RegExp, it will be used **as is** – no modifications will be made.

#### loose
Type: `boolean`<br>
Default: `false`

Should the `RegExp` match URLs that are longer than the [`str`](#str) pattern itself?<br>
By default, the generated `RegExp` will test that the URL begins and _ends with_ the pattern.

> **Important:** When `input` is a RegExp, the `loose` argument is ignored!

```js
const { parse } = require('regexparam');

parse('/users').pattern.test('/users/lukeed'); //=> false
parse('/users', true).pattern.test('/users/lukeed'); //=> true

parse('/users/:name').pattern.test('/users/lukeed/repos'); //=> false
parse('/users/:name', true).pattern.test('/users/lukeed/repos'); //=> true
```


### regexparam.inject(pattern: string, values: object)
Returns: `string`

Returns a new string by replacing the `pattern` segments/parameters with their matching values.

> **Important:** Named segments (eg, `/:name`) that _do not_ have a `values` match will be kept in the output. This is true _except for_ optional segments (eg, `/:name?`) and wildcard segments (eg, `/*`).

#### pattern
Type: `string`

The route pattern that to receive injections.

#### values
Type: `Record<string, string>`

The values to be injected. The keys within `values` must match the `pattern`'s segments in order to be replaced.

> **Note:** To replace a wildcard segment (eg, `/*`), define a `values['*']` key.


## Deno

As of version `1.3.0`, you may use `regexparam` with Deno. These options are all valid:

```ts
// The official Deno registry:
import regexparam from 'https://deno.land/x/regexparam/src/index.js';
// Third-party CDNs with ESM support:
import regexparam from 'https://cdn.skypack.dev/regexparam';
import regexparam from 'https://esm.sh/regexparam';
```

> **Note:** All registries support versioned URLs, if desired. <br>The above examples always resolve to the latest published version.


## Related

- [trouter](https://github.com/lukeed/trouter) - A server-side HTTP router that extends from this module.
- [matchit](https://github.com/lukeed/matchit) - Similar (650B) library, but relies on String comparison instead of `RegExp`s.


## License

MIT © [Luke Edwards](https://lukeed.com)
