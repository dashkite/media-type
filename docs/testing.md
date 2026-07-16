# Testing

The testing strategy for `@dashkite/media-type` relies on a suite of unit tests to verify the correctness of the parser and content negotiation logic. 

The tests are written using `@dashkite/amen` and `@dashkite/assert` to construct logical hierarchies of test scenarios. They extensively validate corner cases in media type string formats, including varied capitalization, quoting, spacing, and intricate combinations of complex MIME suffixes. For the `Accept` class, tests ensure that negotiation accurately filters targets according to the `q` (quality) weighting specified in the HTTP standard.

You can execute the test suite by running the following command in the repository root:

```bash
npx genie test
```
