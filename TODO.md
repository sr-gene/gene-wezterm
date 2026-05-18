# TODO

## Investigate: macOS "config not loaded" warning after reboot

- After macOS reboot, WezTerm shows a "config not loaded" / configuration warning on the restored window.
- Opening a new window has no warning — config loads fine.
- Config itself does no I/O at load time, so this is likely macOS session restore preserving a stale error state, not a real config bug.

**Next time it happens, capture:**

1. Exact warning text from the bad window.
2. Latest log:
   ```sh
   ls -t ~/Library/Logs/wezterm/ | head
   tail -100 ~/Library/Logs/wezterm/wezterm-gui-log-*.log
   ```
3. Whether `Cmd+Shift+R` (reload config) clears the warning in place — if yes, confirms stale-state theory.

**Suspects to rule out:**

- macOS "Reopen windows when logging back in" restoring stale WezTerm state.
- `JetBrainsMono NF` not yet font-registered at boot.
- iCloud-managed `~` not synced at login (only if home is iCloud-backed).
