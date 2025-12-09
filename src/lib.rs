use std::fs;
use std::path::{Path, PathBuf};

use encoding_rs::{EUC_JP, Encoding, SHIFT_JIS, UTF_8};
use midly::{MetaMessage, Smf, TrackEventKind};

pub fn try_decode(bytes: &[u8]) -> String {
    let encodings: &[&'static Encoding] = &[SHIFT_JIS, EUC_JP, UTF_8];

    for enc in encodings {
        let (text, _, err) = enc.decode(bytes);
        if !err {
            return text.into_owned();
        }
    }
    String::from_utf8_lossy(bytes).into()
}

pub struct ProcessResult {
    pub track_names: Vec<String>,
    pub output_path: PathBuf,
}

pub fn process_midi_file(input_path: &Path) -> Result<ProcessResult, String> {
    let data = fs::read(input_path).map_err(|e| format!("Failed to read file: {}", e))?;

    let mut smf = Smf::parse(&data).map_err(|e| format!("Failed to parse MIDI file: {}", e))?;

    let mut track_names = Vec::new();

    for track in smf.tracks.iter_mut() {
        for event in track.iter_mut() {
            if let TrackEventKind::Meta(MetaMessage::TrackName(name_bytes)) = &event.kind {
                let decoded = try_decode(name_bytes);
                track_names.push(decoded.clone());

                let bytes = decoded.into_bytes();
                let leaked: &'static [u8] = Box::leak(bytes.into_boxed_slice());
                event.kind = TrackEventKind::Meta(MetaMessage::TrackName(leaked));
            }
        }
    }

    let out_path = {
        let mut p = PathBuf::from(input_path);
        let stem = p.file_stem().unwrap().to_string_lossy();
        p.set_file_name(format!("{}_fixed.mid", stem));
        p
    };

    let mut out_bytes = Vec::new();
    smf.write(&mut out_bytes)
        .map_err(|e| format!("Failed to write MIDI file: {}", e))?;

    fs::write(&out_path, out_bytes).map_err(|e| format!("Failed to save file: {}", e))?;

    Ok(ProcessResult {
        track_names,
        output_path: out_path,
    })
}
