// hello.rs: a friendly greeting from tico.

use std::env;

fn main() {
    let mut names: Vec<String> = env::args().skip(1).collect();
    if names.is_empty() {
        names.push(String::from("world"));
    }

    for name in &names {
        println!("Hello, {}!", name);
    }
}
