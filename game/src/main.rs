use bevy::prelude::*;
use bevy::winit::{UpdateMode, WinitSettings};

fn setup(mut commands: Commands) {
    commands.spawn(Camera2d);

    commands.spawn(Sprite::from_color(Color::WHITE, Vec2::new(50.0, 50.0)));
}

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
                std::time::Duration::from_millis(10), // 100fps with waiting
            ),
            unfocused_mode: UpdateMode::reactive_low_power(
                std::time::Duration::from_millis(33), // ~30fps when unfocused
            ),
        })
        .insert_resource(ClearColor(Color::srgb(0.1, 0.2, 0.3)))
        .add_systems(Startup, setup)
        .run();
}
