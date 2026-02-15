# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Fixed
- Fixed cursor positioning when inserting pipe character on top of an existing pipe
- Fixed cursor positioning on separator row after pipe insertion

## [v0.1.0] - 2026-02-13

### Added
- **Table sorting functionality**: Sort table rows by column or columns by row
  - `:Table SortRows[!] {col} [flags]` - Sort rows by specified column (! for reverse)
  - `:Table SortCols[!] {row} [flags]` - Sort columns by specified row (! for reverse)
  - Support for alphabetical (default), numeric (n), and custom (c) sort flags
  - User-defined sort comparator functions for custom sorting logic
- Versioning system following semantic versioning (vMAJOR.MINOR.PATCH)
- CHANGELOG.md to track changes between versions

### Features
- Multiline rows support
- Cell editing window (floating window in Neovim, split in Vim)
- Text objects for cells, rows, and columns
- Multiple table styles (markdown, org, rst, box-drawing)
- Chunk processing for performance with large tables
- Auto-alignment on pipe insertion
- Context-aware keybindings
- Tab navigation between cells

### Requirements
- Vim 8.1 or later
- Neovim 0.11.5 or later
