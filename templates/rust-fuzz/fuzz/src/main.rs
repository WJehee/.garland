//! LibAFL in-process fuzzer skeleton.
//!
//! Replace the body of `fuzz_one` with a call into the crate under test,
//! then set coverage signals for the states you care about (or switch to
//! sancov instrumentation with `libafl_targets` for real edge coverage).
//! Run with: just fuzz

use std::{path::PathBuf, ptr::write};

use libafl::{
    corpus::{InMemoryCorpus, OnDiskCorpus},
    events::SimpleEventManager,
    executors::{ExitKind, InProcessExecutor},
    feedbacks::{CrashFeedback, MaxMapFeedback},
    fuzzer::{Fuzzer, StdFuzzer},
    generators::RandPrintablesGenerator,
    inputs::{BytesInput, HasTargetBytes},
    monitors::SimpleMonitor,
    mutators::{havoc_mutations::havoc_mutations, scheduled::HavocScheduledMutator},
    observers::ConstMapObserver,
    schedulers::QueueScheduler,
    stages::mutational::StdMutationalStage,
    state::StdState,
};
use libafl_bolts::{current_nanos, nonnull_raw_mut, nonzero, rands::StdRand, tuples::tuple_list};

/// Coverage map with explicit assignments due to the lack of instrumentation.
const SIGNALS_LEN: usize = 16;
static mut SIGNALS: [u8; SIGNALS_LEN] = [0; SIGNALS_LEN];
static mut SIGNALS_PTR: *mut u8 = &raw mut SIGNALS as _;

/// Assign a signal to the signals map.
fn signals_set(idx: usize) {
    unsafe { write(SIGNALS_PTR.add(idx), 1) };
}

/// The function under fuzz: replace this with a call into your crate, e.g.
/// `changeme::parse(data)`, and drop signals where interesting states are hit.
fn fuzz_one(data: &[u8]) {
    signals_set(0);
    if !data.is_empty() && data[0] == b'a' {
        signals_set(1);
        if data.len() > 1 && data[1] == b'b' {
            signals_set(2);
            if data.len() > 2 && data[2] == b'c' {
                panic!("Artificial bug triggered =)");
            }
        }
    }
}

pub fn main() {
    env_logger::init();

    let mut harness = |input: &BytesInput| {
        let target = input.target_bytes();
        fuzz_one(&target);
        ExitKind::Ok
    };

    // Observation channel over the signals map.
    let observer = unsafe { ConstMapObserver::from_mut_ptr("signals", nonnull_raw_mut!(SIGNALS)) };

    // Rate inputs as interesting when they reach new map entries.
    let mut feedback = MaxMapFeedback::new(&observer);

    // An input is a solution when it crashes the harness.
    let mut objective = CrashFeedback::new();

    let mut state = StdState::new(
        StdRand::with_seed(current_nanos()),
        InMemoryCorpus::new(),
        // Crashes are kept on disk so they survive the fuzzer stopping.
        OnDiskCorpus::new(PathBuf::from("./crashes")).unwrap(),
        &mut feedback,
        &mut objective,
    )
    .unwrap();

    let mon = SimpleMonitor::new(|s| println!("{s}"));
    let mut mgr = SimpleEventManager::new(mon);

    let scheduler = QueueScheduler::new();
    let mut fuzzer = StdFuzzer::new(scheduler, feedback, objective);

    let mut executor = InProcessExecutor::new(
        &mut harness,
        tuple_list!(observer),
        &mut fuzzer,
        &mut state,
        &mut mgr,
    )
    .expect("Failed to create the Executor");

    // Seed the corpus with printable bytearrays of max size 32.
    let mut generator = RandPrintablesGenerator::new(nonzero!(32));
    state
        .generate_initial_inputs(&mut fuzzer, &mut executor, &mut generator, &mut mgr, 8)
        .expect("Failed to generate the initial corpus");

    let mutator = HavocScheduledMutator::new(havoc_mutations());
    let mut stages = tuple_list!(StdMutationalStage::new(mutator));

    fuzzer
        .fuzz_loop(&mut stages, &mut executor, &mut state, &mut mgr)
        .expect("Error in the fuzzing loop");
}
