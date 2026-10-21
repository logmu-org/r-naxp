# Emit a naxp as source code

Writes a naxp as source code in another language: a fragment of
declarations that answer the same questions this package does, for that
one naxp, with no dependency on any naxp library. The header comment,
includes, namespace or wrapping class around it are yours to add.

## Usage

``` r
naxp_emit(
  naxp,
  language = c("csharp", "javascript", "c", "cpp"),
  prefix = "",
  value_type = c("uint64", "int64", "uint32", "int32", "uint16", "int16", "uint8",
    "int8"),
  initial_indent = "",
  new_line = "\n",
  indent = "\t"
)
```

## Arguments

- naxp:

  A naxp from
  [`naxp_parse()`](https://r-naxp.logmu.org/reference/naxp_parse.md), a
  pattern string or a
  [naxp_encoded](https://r-naxp.logmu.org/reference/naxp_encoded.md)
  vector, whose naxp is used.

- language:

  The language to emit: `"csharp"`, `"javascript"`, `"c"` (C99) or
  `"cpp"` (C++17).

- prefix:

  What every generated name starts with, so several naxps can share one
  scope. `""` gives the bare names. Each language applies its own casing
  convention to it.

- value_type:

  The integer type the generated code uses for encoded values. The
  naxp's maximum encoded value must fit it.

- initial_indent:

  What every line starts with ahead of its own indentation, so the
  fragment can sit inside an indented wrapper.

- new_line:

  What ends every line.

- indent:

  What one level of indentation is written as.

## Value

A single string: the fragment.

## Examples

``` r
cat(naxp_emit(r"(\9\9\9\9 \s!! \A\A)", "javascript", prefix = "nl_postcode"))
#> /** The naxp this code was generated from. */
#> const nl_postcodePattern = '\\9\\9\\9\\9 \\s!! \\A\\A';
#> 
#> /** The largest encoded value this naxp produces, which is also how many it has. */
#> const nl_postcodeMaxEncodedValue = 6_760_000;
#> 
#> /** The length of the longest string this naxp can decode a value to. */
#> const nl_postcodeMaxLength = 7;
#> 
#> /** Whether this naxp accepts a string, or the ASCII text in a Uint8Array. A byte outside ASCII is never accepted.
#>  * @param {string | Uint8Array} text
#>  * @returns {boolean}
#>  */
#> function nl_postcodeAccepts(text) {
#>  const bytes = typeof text !== 'string';
#>  let state = 0;
#> 
#>  for (let i = 0; i < text.length; i++) {
#>      const c = bytes ? text[i] : text.charCodeAt(i);
#> 
#>      state = nl_postcodeAcceptStep(state, c);
#> 
#>      if (state < 0) { return false; }
#>  }
#> 
#>  return nl_postcodeIsAccepting(state);
#> }
#> 
#> /** The encoded value of a string, or of the ASCII text in a Uint8Array, from 1 to the largest encoded value, or zero where it is invalid.
#>  * @param {string | Uint8Array} text
#>  * @returns {number}
#>  */
#> function nl_postcodeEncode(text) {
#>  const canonical = nl_postcodeCanonicalise(text);
#> 
#>  return canonical === null ? 0 : nl_postcodeRank(canonical);
#> }
#> 
#> /** The string a value stands for, which is in canonical form.
#>  * @param {number} value
#>  * @returns {string}
#>  * @throws {RangeError} The value is not one this naxp produces.
#>  */
#> function nl_postcodeDecode(value) {
#>  if (value < 1 || value > nl_postcodeMaxEncodedValue) {
#>      throw new RangeError('This naxp encodes the values 1 to 6760000.');
#>  }
#> 
#>  return String.fromCharCode.apply(null, nl_postcodeDecodeCore(value));
#> }
#> 
#> /** The string a value stands for, as ASCII bytes.
#>  * @param {number} value
#>  * @returns {Uint8Array}
#>  * @throws {RangeError} The value is not one this naxp produces.
#>  */
#> function nl_postcodeDecodeToBytes(value) {
#>  if (value < 1 || value > nl_postcodeMaxEncodedValue) {
#>      throw new RangeError('This naxp encodes the values 1 to 6760000.');
#>  }
#> 
#>  return Uint8Array.from(nl_postcodeDecodeCore(value));
#> }
#> 
#> /** The string a value stands for, which is in canonical form, or null where the value is not one this naxp produces.
#>  * @param {number} value
#>  * @returns {string | null}
#>  */
#> function nl_postcodeTryDecode(value) {
#>  if (value < 1 || value > nl_postcodeMaxEncodedValue) { return null; }
#> 
#>  return String.fromCharCode.apply(null, nl_postcodeDecodeCore(value));
#> }
#> 
#> /** The canonical form of a string, or of the ASCII text in a Uint8Array, or null where it is invalid.
#>  * @param {string | Uint8Array} text
#>  * @returns {string | null}
#>  */
#> function nl_postcodeGetCanonicalForm(text) {
#>  const canonical = nl_postcodeCanonicalise(text);
#> 
#>  return canonical === null ? null : String.fromCharCode.apply(null, canonical);
#> }
#> 
#> /** The code points of the canonical form of a string, or of the ASCII text in a Uint8Array, or null where it is invalid. */
#> function nl_postcodeCanonicalise(text) {
#>  const bytes = typeof text !== 'string';
#>  const canonical = [];
#>  let state = 0;
#> 
#>  for (let i = 0; i < text.length; i++) {
#>      const c = bytes ? text[i] : text.charCodeAt(i);
#> 
#>      state = nl_postcodeCanonicalStep(state, c, canonical);
#> 
#>      if (state < 0) { return null; }
#>  }
#> 
#>  return nl_postcodeFinishCanonical(state, canonical) ? canonical : null;
#> }
#> 
#> /** The rank of a canonical string, as code points, within the canonical language, or zero where it is not in it. */
#> function nl_postcodeRank(codes) {
#>  const acc = { total: 0 };
#>  let state = 0;
#> 
#>  for (let i = 0; i < codes.length; i++) {
#>      state = nl_postcodeEncodeStep(state, codes[i], acc);
#> 
#>      if (state < 0) { return 0; }
#>  }
#> 
#>  return nl_postcodeIsCanonicalAccepting(state) ? acc.total + 1 : 0;
#> }
#> 
#> /** The code points of an encoded value already checked against the largest one. */
#> function nl_postcodeDecodeCore(value) {
#>  const codes = [];
#>  const box = { remaining: value };
#>  let state = 0;
#> 
#>  while (state >= 0) {
#>      state = nl_postcodeDecodeStep(state, box, codes);
#>  }
#> 
#>  return codes;
#> }
#> 
#> /** The acceptor's transition: the next state, or -1 where the code point fits nothing. */
#> function nl_postcodeAcceptStep(state, c) {
#>  switch (state) {
#>      case 0:
#>          if (c >= 0x30 && c <= 0x39) { return 1; }
#>          break;
#>      case 1:
#>          if (c >= 0x30 && c <= 0x39) { return 2; }
#>          break;
#>      case 2:
#>          if (c >= 0x30 && c <= 0x39) { return 3; }
#>          break;
#>      case 3:
#>          if (c >= 0x30 && c <= 0x39) { return 4; }
#>          break;
#>      case 4:
#>          if (c === 0x20) { return 5; }
#>          if (c >= 0x41 && c <= 0x5A) { return 6; }
#>          break;
#>      case 5:
#>          if (c >= 0x41 && c <= 0x5A) { return 6; }
#>          break;
#>      case 6:
#>          if (c >= 0x41 && c <= 0x5A) { return 7; }
#>          break;
#>      case 7:
#>          break;
#>  }
#> 
#>  return -1;
#> }
#> 
#> /** Whether the input may end in this state. */
#> function nl_postcodeIsAccepting(state) {
#>  switch (state) {
#>      case 7:
#>          return true;
#>      default:
#>          return false;
#>  }
#> }
#> 
#> /** The canonical machine's transition, accumulating the values skipped: the next state, or -1. */
#> function nl_postcodeEncodeStep(state, c, acc) {
#>  switch (state) {
#>      case 0:
#>          if (c >= 0x30 && c <= 0x39) { acc.total += 676_000 * (c - 0x30); return 1; }
#>          break;
#>      case 1:
#>          if (c >= 0x30 && c <= 0x39) { acc.total += 67_600 * (c - 0x30); return 2; }
#>          break;
#>      case 2:
#>          if (c >= 0x30 && c <= 0x39) { acc.total += 6760 * (c - 0x30); return 3; }
#>          break;
#>      case 3:
#>          if (c >= 0x30 && c <= 0x39) { acc.total += 676 * (c - 0x30); return 4; }
#>          break;
#>      case 4:
#>          if (c === 0x20) { return 5; }
#>          break;
#>      case 5:
#>          if (c >= 0x41 && c <= 0x5A) { acc.total += 26 * (c - 0x41); return 6; }
#>          break;
#>      case 6:
#>          if (c >= 0x41 && c <= 0x5A) { acc.total += (c - 0x41); return 7; }
#>          break;
#>      case 7:
#>          break;
#>  }
#> 
#>  return -1;
#> }
#> 
#> /** Whether the input may end in this state. */
#> function nl_postcodeIsCanonicalAccepting(state) {
#>  switch (state) {
#>      case 7:
#>          return true;
#>      default:
#>          return false;
#>  }
#> }
#> 
#> /** One step of decoding: appends at most one code point and returns the next state, or -1 when the string is complete. */
#> function nl_postcodeDecodeStep(state, box, codes) {
#>  let index;
#> 
#>  switch (state) {
#>      case 0: {
#>          index = Math.floor((box.remaining - 1) / 676_000);
#>          codes.push(0x30 + index);
#>          box.remaining = ((box.remaining - 1) % 676_000) + 1;
#>          return 1;
#>      }
#>      case 1: {
#>          index = Math.floor((box.remaining - 1) / 67_600);
#>          codes.push(0x30 + index);
#>          box.remaining = ((box.remaining - 1) % 67_600) + 1;
#>          return 2;
#>      }
#>      case 2: {
#>          index = Math.floor((box.remaining - 1) / 6760);
#>          codes.push(0x30 + index);
#>          box.remaining = ((box.remaining - 1) % 6760) + 1;
#>          return 3;
#>      }
#>      case 3: {
#>          index = Math.floor((box.remaining - 1) / 676);
#>          codes.push(0x30 + index);
#>          box.remaining = ((box.remaining - 1) % 676) + 1;
#>          return 4;
#>      }
#>      case 4: {
#>          codes.push(0x20);
#>          return 5;
#>      }
#>      case 5: {
#>          index = Math.floor((box.remaining - 1) / 26);
#>          codes.push(0x41 + index);
#>          box.remaining = ((box.remaining - 1) % 26) + 1;
#>          return 6;
#>      }
#>      case 6: {
#>          index = box.remaining - 1;
#>          codes.push(0x41 + index);
#>          box.remaining = 1;
#>          return 7;
#>      }
#>      case 7: {
#>          return -1;
#>      }
#>  }
#> 
#>  return -1;
#> }
#> 
#> /** The canonicalising transition, appending what reading the code point emits: the next state, or -1. */
#> function nl_postcodeCanonicalStep(state, c, canonical) {
#>  switch (state) {
#>      case 0:
#>          if (c >= 0x30 && c <= 0x39) {
#>              canonical.push(c);
#>              return 1;
#>          }
#>          break;
#>      case 1:
#>          if (c >= 0x30 && c <= 0x39) {
#>              canonical.push(c);
#>              return 2;
#>          }
#>          break;
#>      case 2:
#>          if (c >= 0x30 && c <= 0x39) {
#>              canonical.push(c);
#>              return 3;
#>          }
#>          break;
#>      case 3:
#>          if (c >= 0x30 && c <= 0x39) {
#>              canonical.push(c);
#>              return 4;
#>          }
#>          break;
#>      case 4:
#>          if (c === 0x20) { return 5; }
#>          if (c >= 0x41 && c <= 0x5A) {
#>              canonical.push(0x20);
#>              canonical.push(c);
#>              return 6;
#>          }
#>          break;
#>      case 5:
#>          if (c >= 0x41 && c <= 0x5A) {
#>              canonical.push(0x20);
#>              canonical.push(c);
#>              return 6;
#>          }
#>          break;
#>      case 6:
#>          if (c >= 0x41 && c <= 0x5A) {
#>              canonical.push(c);
#>              return 7;
#>          }
#>          break;
#>      case 7:
#>          break;
#>  }
#> 
#>  return -1;
#> }
#> 
#> /** Appends what ending the input emits, and returns whether the input may end here. */
#> function nl_postcodeFinishCanonical(state, canonical) {
#>  switch (state) {
#>      case 7:
#>          return true;
#>  }
#> 
#>  return false;
#> }
```
