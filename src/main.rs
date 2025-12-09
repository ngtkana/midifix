use std::fs;
use std::path::PathBuf;

use encoding_rs::{EUC_JP, Encoding, SHIFT_JIS, UTF_8};
use midly::{MetaMessage, Smf, TrackEventKind};

fn try_decode(bytes: &[u8]) -> String {
    let encodings: &[&'static Encoding] = &[SHIFT_JIS, EUC_JP, UTF_8];

    for enc in encodings {
        let (text, _, err) = enc.decode(bytes);
        if !err {
            return text.into_owned();
        }
    }
    String::from_utf8_lossy(bytes).into()
}

fn main() {
    let input = std::env::args().nth(1).expect("Usage: midifix <file.mid>");

    let data = fs::read(&input).expect("Failed to read input file");
    let mut smf = Smf::parse(&data).expect("Invalid MIDI file");

    for track in smf.tracks.iter_mut() {
        for event in track.iter_mut() {
            if let TrackEventKind::Meta(MetaMessage::TrackName(name_bytes)) = &event.kind {
                let decoded = try_decode(name_bytes);
                println!("TrackName → {}", decoded);

                // ★借用をそのまま変更できないので、イベントごと置換する
                // Vec<u8>をリークして&'static [u8]に変換
                let bytes = decoded.into_bytes();
                let leaked: &'static [u8] = Box::leak(bytes.into_boxed_slice());
                event.kind = TrackEventKind::Meta(MetaMessage::TrackName(leaked));
            }
        }
    }

    let out_path = {
        let mut p = PathBuf::from(&input);
        let stem = p.file_stem().unwrap().to_string_lossy();
        p.set_file_name(format!("{}_fixed.mid", stem));
        p
    };

    let mut out_bytes = Vec::new();
    smf.write(&mut out_bytes).expect("Failed to write MIDI");
    fs::write(&out_path, out_bytes).unwrap();

    println!("保存完了 → {}", out_path.display());
}
