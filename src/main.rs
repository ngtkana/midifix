use eframe::egui;
use std::path::PathBuf;

fn main() -> Result<(), eframe::Error> {
    let args: Vec<_> = std::env::args_os().collect();
    let initial_file = if args.len() > 1 {
        Some(PathBuf::from(&args[1]))
    } else {
        None
    };

    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([600.0, 400.0])
            .with_drag_and_drop(true),
        ..Default::default()
    };

    eframe::run_native(
        "MIDI Fix",
        options,
        Box::new(move |_cc| Ok(Box::new(MidiFixApp::new(initial_file)))),
    )
}

struct MidiFixApp {
    log_messages: Vec<String>,
    processing: bool,
    last_output: Option<PathBuf>,
    initial_file: Option<PathBuf>,
    initialized: bool,
}

impl MidiFixApp {
    fn new(initial_file: Option<PathBuf>) -> Self {
        Self {
            log_messages: Vec::new(),
            processing: false,
            last_output: None,
            initial_file,
            initialized: false,
        }
    }

    fn add_log(&mut self, message: String) {
        self.log_messages.push(message);
    }

    fn process_file(&mut self, path: PathBuf) {
        self.processing = true;
        self.log_messages.clear();
        self.last_output = None;

        self.add_log(format!("Processing: {}", path.display()));

        match midifix::process_midi_file(&path) {
            Ok(result) => {
                self.add_log(format!("Success"));
                self.add_log(format!(""));
                self.add_log(format!("Track names:"));
                for (i, name) in result.track_names.iter().enumerate() {
                    self.add_log(format!("  [{}] {}", i + 1, name));
                }
                self.add_log(format!(""));
                self.add_log(format!("Output: {}", result.output_path.display()));
                self.last_output = Some(result.output_path);
            }
            Err(e) => {
                self.add_log(format!("Error: {}", e));
            }
        }

        self.processing = false;
    }
}

impl eframe::App for MidiFixApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        if !self.initialized {
            if let Some(file) = self.initial_file.take() {
                self.process_file(file);
            }
            self.initialized = true;
        }

        egui::CentralPanel::default().show(ctx, |ui| {
            ui.heading("MIDI Fix");
            ui.add_space(10.0);

            ui.label("Drag and drop a MIDI file or click the button to select one.");
            ui.add_space(10.0);

            if ui.button("Select File").clicked() {
                if let Some(path) = rfd::FileDialog::new()
                    .add_filter("MIDI Files", &["mid", "midi"])
                    .pick_file()
                {
                    self.process_file(path);
                }
            }

            ui.add_space(10.0);
            ui.separator();
            ui.add_space(10.0);

            ui.label("Log:");
            egui::ScrollArea::vertical()
                .max_height(200.0)
                .show(ui, |ui| {
                    for msg in &self.log_messages {
                        ui.label(msg);
                    }
                });

            if let Some(output_path) = &self.last_output {
                ui.add_space(10.0);
                if ui.button("Open Output Folder").clicked() {
                    if let Some(parent) = output_path.parent() {
                        let _ = opener::open(parent);
                    }
                }
            }
        });

        ctx.input(|i| {
            if !i.raw.dropped_files.is_empty() {
                for file in &i.raw.dropped_files {
                    if let Some(path) = &file.path {
                        if path.extension().and_then(|s| s.to_str()) == Some("mid")
                            || path.extension().and_then(|s| s.to_str()) == Some("midi")
                        {
                            self.process_file(path.clone());
                        } else {
                            self.add_log(format!("Not a MIDI file: {}", path.display()));
                        }
                    }
                }
            }
        });
    }
}
