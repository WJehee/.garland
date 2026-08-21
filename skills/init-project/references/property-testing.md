# Property based testing per language

How to set up and run property based tests in each language that has a mature
library. Use this when the property testing add-on is selected during init, or
whenever adding property tests to an existing project. In all cases: property
tests run as part of the normal test suite, so `just test` covers them; add a
`test` recipe to the justfile if the project does not have one yet.

General guidance for writing the tests themselves: test invariants
(roundtrips like decode(encode(x)) == x, idempotence, commutativity,
comparison against a trivial reference implementation), not example values.
Let the library generate inputs and shrink counterexamples.

## Rust: proptest

Add to `Cargo.toml`:

```toml
[dev-dependencies]
proptest = "1"
```

Example, in a `#[cfg(test)]` module or `tests/`:

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn roundtrip(input in any::<Vec<u8>>()) {
        let encoded = encode(&input);
        prop_assert_eq!(decode(&encoded).unwrap(), input);
    }
}
```

Run with `cargo test`. proptest writes failing seeds to
`proptest-regressions/`; commit that directory so regressions stay pinned.
For state machine style testing use the `proptest-state-machine` crate.

## Python: Hypothesis

```
uv add --dev hypothesis pytest
```

Example:

```python
from hypothesis import given, strategies as st

@given(st.lists(st.integers()))
def test_sort_is_idempotent(xs):
    assert sorted(sorted(xs)) == sorted(xs)
```

Run with `pytest`. Notes: use `@settings(max_examples=...)` to tune effort;
Hypothesis stores its example database in `.hypothesis/` (gitignore it);
`hypothesis.stateful.RuleBasedStateMachine` covers stateful testing.

## Elixir: StreamData

Add to `mix.exs` deps:

```elixir
{:stream_data, "~> 1.1", only: [:dev, :test]}
```

Example:

```elixir
defmodule MyAppPropTest do
  use ExUnit.Case
  use ExUnitProperties

  property "encoding roundtrips" do
    check all input <- binary() do
      assert decode(encode(input)) == {:ok, input}
    end
  end
end
```

Run with `mix test`.

## Gleam: qcheck

```
gleam add --dev qcheck
```

Example, in `test/`:

```gleam
import qcheck

pub fn int_addition_commutativity__test() {
  use n <- qcheck.given(qcheck.small_non_negative_int())
  assert n + 1 == 1 + n
}
```

Run with `gleam test`. Generators live in the `qcheck` module
(`small_non_negative_int`, `string`, `generic_list`, ...); failures shrink
automatically.

## Kotlin / Android: kotest property testing

Add to the module's gradle deps:

```kotlin
testImplementation("io.kotest:kotest-property:6.0.0")
testImplementation("io.kotest:kotest-runner-junit5:6.0.0")
```

Example:

```kotlin
class PropSpec : StringSpec({
    "concatenation length" {
        checkAll<String, String> { a, b ->
            (a + b).length shouldBe a.length + b.length
        }
    }
})
```

Run with `gradle test`.

## Zig

No mature property testing library exists. The closest equivalent is the
built-in fuzzer: write a test that takes fuzz input and run
`zig build test --fuzz`. Assert invariants inside the fuzz test body to get
property-test-like coverage without shrinking.
