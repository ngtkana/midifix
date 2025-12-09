use std::env;
use std::path::PathBuf;
use std::process;

fn main() {
    let args: Vec<_> = env::args_os().collect();

    if args.len() < 2 {
        eprintln!("Usage: midifix <file.mid>");
        process::exit(1);
    }

    let input_path = PathBuf::from(&args[1]);

    println!("Processing: {}", input_path.display());

    match midifix::process_midi_file(&input_path) {
        Ok(result) => {
            println!("Success!");
            println!();
            println!("Track names:");
            for (i, name) in result.track_names.iter().enumerate() {
                println!("  [{}] {}", i + 1, name);
            }
            println!();
            println!("Output: {}", result.output_path.display());
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            process::exit(1);
        }
    }
}
