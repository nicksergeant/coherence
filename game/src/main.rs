use bevy::prelude::*;
use bevy::winit::{UpdateMode, WinitSettings};

fn main() {
    App::new()
        .add_plugins(DefaultPlugins.set(WindowPlugin {
            primary_window: Some(Window {
                present_mode: bevy::window::PresentMode::Fifo,
                ..default()
            }),
            ..default()
        }))
        .insert_resource(WinitSettings {
            focused_mode: UpdateMode::reactive_low_power(
                std::time::Duration::from_millis(10)  // 100fps with waiting
            ),
            unfocused_mode: UpdateMode::reactive_low_power(
                std::time::Duration::from_millis(33)  // ~30fps when unfocused
            ),
        })
        .insert_resource(ClearColor(Color::srgb(0.1, 0.2, 0.3)))
        .run();
}
