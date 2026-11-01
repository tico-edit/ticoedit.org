//! Preview: syntax highlighting theme sample.

use std::collections::HashMap;
use std::fmt;

/// A book borrowed from the library.
#[derive(Debug, Clone)]
pub struct Book<'a> {
    pub title: &'a str,
    pub pages: u32,
}

impl<'a> fmt::Display for Book<'a> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{} ({} pages)", self.title, self.pages)
    }
}

#[derive(Debug)]
enum Status {
    Available,
    Borrowed { by: String, days: u16 },
}

fn describe(status: &Status) -> String {
    match status {
        Status::Available => "on the shelf".to_string(),
        Status::Borrowed { by, days } if *days > 30 => {
            format!("overdue, held by {by}")
        }
        Status::Borrowed { by, .. } => format!("out to {by}"),
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut shelf: HashMap<u32, Book> = HashMap::new();
    shelf.insert(1, Book { title: "The Rust Book", pages: 528 });

    for (id, book) in &shelf {
        println!("#{id}: {book} — {}", describe(&Status::Available));
    }
    Ok(())
}
