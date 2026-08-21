// Kani proof harnesses, run with `just verify` (cargo kani).
// Only compiled by Kani, never by normal builds.
// Docs: https://model-checking.github.io/kani/
#[cfg(kani)]
mod verification {
    // Example harness: replace with proofs over this crate's functions.
    // kani::any() produces a symbolic value covering every possible u32;
    // the proof holds for all of them, not a sample.
    #[kani::proof]
    fn example_no_overflow() {
        let a: u32 = kani::any();
        kani::assume(a < 1000);
        let b = a + 1;
        assert!(b > a);
    }
}
